/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.1
 *
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 *
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to install, execute and perform the Spine Runtimes
 * Software (the "Software") solely for internal use. Without the written
 * permission of Esoteric Software (typically granted by licensing Spine), you
 * may not (a) modify, translate, adapt or otherwise create derivative works,
 * improvements of the Software or develop new applications using the Software
 * or (b) remove, delete, alter or obscure any trademarks or any copyright,
 * trademark, patent or other intellectual property or proprietary rights
 * notices on or in the Software, including any copy thereof. Redistributions
 * in binary or source form must include this license and terms.
 *
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spinehaxe;

import spinehaxe.animation.Animation;
import spinehaxe.attachments.BoundingBoxAttachment;
import spinehaxe.attachments.MeshAttachment;
import spinehaxe.attachments.RegionAttachment;
import spinehaxe.attachments.SkinnedMeshAttachment;
import spinehaxe.Exception;
import haxe.ds.Vector;

class SkeletonData {
	public var name:String;
	public var bones:Array<BoneData> = new Array();
	// Ordered parents first.
	public var slots:Array<SlotData> = new Array();
	// Setup pose draw order.
	public var skins:Array<Skin> = new Array();
	public var defaultSkin:Skin;
	public var events:Array<EventData> = new Array();
	public var animations:Array<Animation> = new Array();
	public var ikConstraints:Array<IkConstraintData> = new Array();
	public var width:Float = 0;
	public var height:Float = 0;
	public var version:String;
	public var hash:String;
	
	public function dispose() 
	{
		if (bones != null) {
			for (i in 0...bones.length) {
				if (bones[i] != null) {
					bones[i].parent = null;
					bones[i] = null;
				}
			}
			bones = null;
		}
		
		if (slots != null) {
			for (i in 0...slots.length) {
				if (slots[i] != null) {
					slots[i].attachmentName = null;
					slots[i].name = null;
					if (slots[i].boneData != null) {
						slots[i].boneData.name = null;
						slots[i].boneData.parent = null;
						slots[i].boneData = null;
					}
				}
				slots[i]= null;
			}
			slots = null;
		}
		
		if (skins != null) {
			for (i in 0...skins.length) {
				if (skins[i] != null) {
					skins[i].dispose();
					skins[i] = null;
				}
			}
			skins = null;
		}
		
		if (defaultSkin != null) {
			defaultSkin.dispose();
			defaultSkin = null;
		}
		
		if (events != null) {
			for (i in 0...events.length) {
				events[i].name = null;
				events[i].stringValue = null;
				events[i] = null;
			}
			events = null;
		}
		
		if (animations != null) {
			for (i in 0...animations.length) {
				if (animations[i] != null) {
					animations[i].name = null;
					if (animations[i].timelines != null) {
						for (j in 0...animations[i].timelines.length) {
							animations[i].timelines[j] = null;
						}
						animations[i].timelines = null;
					}
					animations[i] = null;
				}
			}
			animations = null;
		}
		
		if (ikConstraints != null) {
			for (i in 0...ikConstraints.length) {
				if (ikConstraints[i] != null) {
					if (ikConstraints[i].bones != null) {
						for (j in 0...ikConstraints[i].bones.length) {
							ikConstraints[i].bones[j].name = null;
							ikConstraints[i].bones[j].parent = null;
							ikConstraints[i].bones[j] = null;
						}
					}
					ikConstraints[i].name = null;
					ikConstraints[i].target = null;
					ikConstraints[i] = null;
				}
			}
			ikConstraints = null;
		}
	}

	// --- Bones.

	public function addBone(bone:BoneData):Void {
		if (bone == null)
			throw new IllegalArgumentException("bone cannot be null.");
		bones[bones.length] = bone;
	}

	/** @return May be null. */
	public function findBone(boneName:String):BoneData {
		if (boneName == null) throw new IllegalArgumentException("boneName cannot be null.");

		for (bone in bones)
			if (bone.name == boneName) return bone;

		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findBoneIndex(boneName:String):Int {
		if (boneName == null)
			throw new IllegalArgumentException("boneName cannot be null.");

		for (i in 0 ... bones.length)
			if (bones[i].name == boneName) return i;

		return -1;
	}

	// --- Slots.

	/** @return May be null. */
	public function findSlot(slotName:String):SlotData {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");

		for (slot in slots)
			if (slot.name == slotName) return slot;

		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findSlotIndex(slotName:String):Int {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");

		for (i in 0 ... slots.length)
			if (slots[i].name == slotName) return i;

		return -1;
	}

	// --- Skins.}

	/** @return May be null. */
	public function findSkin(skinName:String):Skin {
		if (skinName == null) throw new IllegalArgumentException("skinName cannot be null.");

		for (skin in skins)
			if (skin.name == skinName) return skin;

		return null;
	}

	// --- Events.

	/** @return May be null. */
	public function findEvent(eventName:String):EventData {
		if (eventName == null) throw new IllegalArgumentException("eventName cannot be null.");

		for (eventData in events)
			if (eventData.name == eventName) return eventData;

		return null;
	}

	// --- Animations.

	/** @return May be null. */
	public function findAnimation(animationName:String):Animation {
		if (animationName == null)
			throw new IllegalArgumentException("animationName cannot be null.");

		for (animation in animations)
			if (animation.name == animationName) return animation;

		return null;
	}

	// --- IK Constraints.

	/** @return May be null. */
	public function findIkConstraint (ikConstraintName:String) : IkConstraintData {
		if (ikConstraintName == null) throw new IllegalArgumentException("ikConstraintName cannot be null.");

		for (ikConstraintData in ikConstraints)
			if (ikConstraintData.name == ikConstraintName) return ikConstraintData;

		return null;
	}

	// ---

	public function toString():String {
		return (name != null) ? name : ("" + this);
	}

	public function new() {}
}
