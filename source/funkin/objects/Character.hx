package funkin.objects;

import funkin.data.CharacterData.CharacterParser;
import funkin.data.CharacterData.AnimationInfo;
import funkin.data.CharacterData.CharacterInfo;

import animate.FlxAnimate;

// taking some things from base game
// add back miss anim stuff

/**
 * Bopper with extended features to be animated to the strums
 */
// NOT DONE NOT DONE NOT DONE
class Character extends Bopper implements IFlags
{
	public static final DEFAULT_CHARACTER:String = 'bf';
	
	/**
	 * how much the camera moves with the characters sings animations
	 */
	public var camDisplacement:Float = 20;
	
	/**
	 * is the player character
	 * 
	 * changes some things like flipping them
	 */
	public var isPlayer:Bool = false;
	
	/**
	 * Character's json name
	 */
	public var curCharacter:String;
	
	public var holdTimer:Float = 0;
	
	public var animTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var holding(default, set):Bool = false;
	public var stunned:Bool = false;
	
	public var canTaunt:Bool = true;
	
	/**
	 * Multiplier of how long a character holds the sing pose
	 */
	public var singDuration:Float = 4;
	
	public var animSuffix:String = '';
	public var animSuffixExclusions = ['idle', 'danceLeft', 'danceRight', 'miss'];
	
	/**
	 * if true, character uses `danceLeft` and `danceRight` instead of `idle`
	 */
	public var danceIdle:Bool = false;
	
	public var skipDance:Bool = false;
	
	/**
	 * if an idle animation goes over a certain amount of frames, it wont play every couple of beats. set this to `true` to force the idle to play even if the animation isnt' complete
	**/
	public var forceDance:Bool = false;
	
	/**
	 * The characters health icon
	 */
	public var healthIcon:String = 'face';
	
	public var animations:Array<AnimationInfo> = [];
	
	// gameover suttffs
	public var gameoverCharacter:Null<String> = null;
	
	public var gameoverInitialDeathSound:Null<String> = null;
	
	public var gameoverLoopDeathSound:Null<String> = null;
	
	public var gameoverConfirmDeathSound:Null<String> = null;
	
	/**
	 * Character offsets defined by the json
	 */
	public var positionArray:Array<Float> = [0, 0];
	
	/**
	 * Camera offsets defined by the json
	 */
	public var cameraPosition:Array<Float> = [0, 0];
	
	/**
	 * how much the ghost anims move when played
	 */
	public var ghostDisplacement:Float = 40;
	
	/**
	 *	if enabled, ghosts will show on double notes for the character
	 */
	public var ghostsEnabled:Bool = false;
	
	/**
	 * Array of all ghosts
	 */
	public var doubleGhosts:Array<FunkinSprite> = [];
	
	/**
	 * Array of all ghosts tweens
	 */
	public var ghostTweenGrp:Array<FlxTween> = [];
	
	/**
	 * Alpha that the ghosts doubles appear at
	 */
	public var ghostAlpha:Float = 0.6;
	
	/**
	 * The hit time of the last note in milliseconds.
	 * 
	 * Only used for double note ghosts.
	 */
	public var lastHitTime:Float = -1000;
	
	// Used on Character Editor
	public var isPlayerInEditor:Null<Bool> = null;
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	
	/**
	 * disables some functionality for use out of play
	 * 
	 * used in the Character editor
	 */
	public var debugMode:Bool = false;
	
	/**
	 * The Characters health bar colours stored as `[r,g,b]`
	 */
	public var healthColorArray:Array<Int> = [255, 0, 0];
	
	public var healthColour:Int = FlxColor.RED;
	
	/**
	 *	If enabled, the character's singing animation will stop at the last frame while holding a sustain note
	 */
	public var vSliceSustains = false;
	
	public var legacyOffset:Bool = true;
	
	public var flags:haxe.DynamicAccess<Dynamic> = {};
	
	public var pausePortrait:String = '';
	
	public function new(x:Float = 0, y:Float = 0, character:String, isPlayer:Bool = false)
	{
		super(x, y);
		
		this.isPlayer = isPlayer;
		
		loadCharacter(character ?? DEFAULT_CHARACTER);
	}
	
	function genGhosts(count:Int):Void
	{
		while (doubleGhosts.length < count)
		{
			final ghost = new FunkinSprite();
			ghost.useRenderTexture = true;
			ghost.antialiasing = true;
			ghost.visible = false;
			
			doubleGhosts.push(ghost);
		}
	}
	
	public function loadCharacter(name:String, force:Bool = false):Character
	{
		if (curCharacter == name && !force) return this;
		
		for (ghost in doubleGhosts) ghost?.destroy();
		doubleGhosts.resize(0);
		
		loadFile(CharacterParser.fetchInfo(curCharacter = name));
		
		genGhosts(PlayState.SONG?.keys ?? 0);
		
		return this;
	}
	
	// clean this up
	public function loadFile(json:CharacterInfo)
	{
		animOffsets.clear();
		scale.set(1, 1);
		updateHitbox();
		
		this.jsonScale = json.scale;
		this.positionArray = json.position;
		this.cameraPosition = json.camera_position;
		
		this.healthIcon = json.healthicon;
		this.ghostsEnabled = json.afterimages;
		this.vSliceSustains = json.vslice_sustains;
		this.singDuration = json.sing_duration;
		this.noAntialiasing = json.no_antialiasing;
		this.scalableOffsets = json.scalableOffsets;
		
		this.flags = json.flags;
		
		this.pausePortrait = json.pausePortrait;
		
		this.flipX = (json.flip_x != isPlayer);
		this.originalFlipX = (json.flip_x == true);
		this.imageFile = json.image;
		
		this.baseFlipX = (isPlayer ? !originalFlipX : originalFlipX);
		this.baseFlipY = false;
		
		this.antialiasing = !noAntialiasing && ClientPrefs.globalAntialiasing;
		
		this.danceEveryNumBeats = json.dance_every ?? 2;
		
		this.isPlayerInEditor = json._editor_isPlayer;
		
		this.gameoverCharacter = json.gameover_character;
		this.gameoverConfirmDeathSound = json.gameover_confirm_sound;
		this.gameoverLoopDeathSound = json.gameover_loop_sound;
		this.gameoverInitialDeathSound = json.gameover_intial_sound;
		
		loadAtlas(imageFile, LOOSE);
		
		if (jsonScale != 1)
		{
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}
		
		if (json.healthbar_colors != null && json.healthbar_colors.length > 2)
		{
			// temp keep
			this.healthColorArray = json.healthbar_colors;
			
			this.healthColour = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
		}
		else
		{
			this.healthColour = json.healthbar_colour;
		}
		
		this.animations = json.animations;
		if (animations != null && animations.length > 0)
		{
			for (anim in animations)
			{
				final animAnim:String = '' + anim.anim;
				final animName:String = '' + anim.name;
				final animFps:Int = anim.fps;
				final animLoop:Bool = !!anim.loop; // Bruh
				final animIndices:Array<Int> = anim.indices ?? [];
				
				final flipX = anim.flipX ?? false;
				final flipY = anim.flipY ?? false;
				
				if (animIndices.length > 0)
				{
					addAnimByIndices(animAnim, animName, animIndices, animFps, animLoop, flipX, flipY);
				}
				else
				{
					addAnimByPrefix(animAnim, animName, animFps, animLoop, flipX, flipY);
				}
				
				if (anim.offsets != null && anim.offsets.length > 1)
				{
					addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}
				else
				{
					addOffset(anim.anim, 0, 0);
				}
			}
		}
		else
		{
			addAnimByPrefix('idle', 'BF idle dance', 24, false);
		}
		
		dance(true);
		if (!animation.curAnim?.looped) finishAnim();
		setBaseFrameSize();
	}
	
	override function update(elapsed:Float)
	{
		if (debugMode || isAnimNull())
		{
			super.update(elapsed);
			return;
		}
		
		if (animTimer > 0)
		{
			animTimer -= elapsed;
			if (animTimer <= 0)
			{
				animTimer = 0;
				dance(forceDance);
			}
		}
		
		if (specialAnim && isAnimFinished() && !holding)
		{
			specialAnim = false;
			dance(forceDance);
		}
		else if (getAnimName().endsWith('miss') && isAnimFinished() && holdTimer >= Conductor.stepCrotchet * 0.002 * singDuration)
		{
			dance(forceDance);
			finishAnim();
		}
		
		if (getAnimName().startsWith('sing') || holding) holdTimer += elapsed;
		
		if (!holding && holdTimer >= Conductor.stepCrotchet * 0.001 * singDuration)
		{
			dance(forceDance);
			holdTimer = 0;
		}
		
		if (isAnimFinished() && hasAnim(getAnimName() + '-loop')) playAnim(getAnimName() + '-loop');
		
		if (ghostsEnabled)
		{
			for (ghost in doubleGhosts)
				ghost.update(elapsed);
		}
		
		super.update(elapsed);
	}
	
	override function draw()
	{
		if (ghostsEnabled)
		{
			for (ghost in doubleGhosts)
			{
				if (ghost.visible) ghost.draw();
			}
		}
		super.draw();
	}
	
	function set_holding(isIt:Bool):Bool
	{
		if (!isIt && holding && holdTimer >= Conductor.stepCrotchet * 0.001 * singDuration)
		{
			dance(forceDance);
			holdTimer = 0;
		}
		
		return holding = isIt;
	}
	
	/**
	 * Plays the characters idle animation
	 */
	override function dance(forced:Bool = false)
	{
		if (debugMode || specialAnim || skipDance) return;
		
		super.dance(forced);
	}
	
	override function playAnim(animToPlay:String, isForced:Bool = false, isReversed:Bool = false, frame:Int = 0)
	{
		specialAnim = false;
		
		super.playAnim(animToPlay + animSuffix, isForced, isReversed, frame);
	}
	
	override function onBeatHit(beat:Int)
	{
		if (stunned || getAnimName().startsWith('sing') || holding) return;
		
		super.onBeatHit(beat);
	}
	
	public function getSingDisplacement():FlxPoint
	{
		return switch (getAnimName().substr(4).split('-')[0].toLowerCase())
		{
			case 'up':
				FlxPoint.weak(0, -camDisplacement);
			case 'down':
				FlxPoint.weak(0, camDisplacement);
			case 'left':
				FlxPoint.weak(-camDisplacement, 0);
			case 'right':
				FlxPoint.weak(camDisplacement, 0);
			default:
				FlxPoint.weak();
		}
	}
	
	public function playGhostAnim(ghostID:Int = 0, animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
	{
		if (ghostID >= doubleGhosts.length) genGhosts(ghostID + 1);
		
		var ghost = doubleGhosts[ghostID];
		
		if (ghost == null) return trace('what $ghostID');
		
		if (ghost.frames == null)
		{
			ghost.frames = frames;
			ghost.copyAnimController(animation);
		}
		
		ghost.scale.copyFrom(scale);
		ghost.offset.copyFrom(offset);
		ghost.origin.copyFrom(origin);
		ghost.antialiasing = antialiasing;
		ghost.angle = angle;
		ghost.x = x;
		ghost.y = y;
		ghost.width = width;
		ghost.height = height;
		ghost.baseFrameWidth = baseFrameWidth;
		ghost.baseFrameHeight = baseFrameHeight;
		ghost.flipX = flipX;
		ghost.flipY = flipY;
		ghost.baseFlipX = baseFlipX;
		ghost.baseFlipY = baseFlipY;
		ghost.alpha = alpha * ghostAlpha;
		ghost.visible = true;
		ghost.color = healthColour;
		
		ghostTweenGrp[ghostID]?.cancel();
		
		final direction:String = animName.substring(4).split('-')[0];
		
		inline function resolveDir(x:Bool):Float
		{
			return switch (direction)
			{
				default: 0;
				case 'UP': !x ? -ghostDisplacement : 0;
				case 'DOWN': !x ? ghostDisplacement : 0;
				case 'RIGHT': x ? ghostDisplacement : 0;
				case 'LEFT': x ? -ghostDisplacement : 0;
			}
		}
		
		final moveX = x + resolveDir(true);
		final moveY = y + resolveDir(false);
		
		ghostTweenGrp[ghostID] = FlxTween.tween(ghost, {alpha: 0, x: moveX, y: moveY}, 0.75,
			{
				onComplete: (twn) -> {
					ghost.visible = false;
					ghostTweenGrp[ghostID] = null;
				}
			});
			
		ghost.animation.play(animName, force, reversed, frame);
		
		if (animOffsets.exists(animName))
		{
			final daOffset = animOffsets.get(animName);
			ghost.setAnimOffset(daOffset[0], daOffset[1]);
		}
	}
	
	override function destroy()
	{
		if (ghostTweenGrp != null && ghostTweenGrp.length > 0)
		{
			for (i in ghostTweenGrp)
				i?.cancel();
		}
		
		ghostTweenGrp = FlxDestroyUtil.destroyArray(ghostTweenGrp);
		
		doubleGhosts = FlxDestroyUtil.destroyArray(doubleGhosts);
		
		flags = null;
		
		super.destroy();
	}
	
	public override function updateHitbox():Void // im so disgusted
	{
		super.updateHitbox();
		
		if (legacyOffset) offset.set();
	}
	
	public function hasFlag(flag:String):Bool
	{
		return flags.exists(flag);
	}
	
	public function getFlag(flag:String):Dynamic
	{
		return flags.get(flag);
	}
}
