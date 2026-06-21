package funkin.backend;

import funkin.scripting.PluginsManager;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionSprite.TransitionStatus;

import funkin.backend.BaseTransitionState;
import funkin.states.transitions.SwipeTransition;
import funkin.input.Controls;
import funkin.scripts.*;

class MusicBeatState extends FlxUIState
{
	static final _defaultTransState:Class<BaseTransitionState> = SwipeTransition;
	
	// change these to change the transition
	public static var transitionInState:Null<Class<BaseTransitionState>> = null;
	public static var transitionOutState:Null<Class<BaseTransitionState>> = null;
	
	public function new() super();
	
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;
	
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	
	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;
	
	// poppy playtime (rozebud edition)
	private static var playTimeHooksBound:Bool = false;
	private static var playTimeDirty:Bool = false;
	private static var playTimeTimestamp:Float = -1;
	private static var playTimeDirtyTimer:Float = 0;
	private static final PLAY_TIME_SAVE_INTERVAL:Float = 30;
	
	// script related vars
	public var scripted:Bool = false;
	public var scriptName:String = '';
	public var scriptGroup:ScriptGroup = new ScriptGroup();
	
	inline function isHardcodedState() return (scriptGroup != null && !scriptGroup.call('customMenu') == true) || (scriptGroup == null);
	
	public function initStateScript(?scriptName:String, callOnLoad:Bool = true):Bool
	{
		if (scriptName == null)
		{
			final stateName = Type.getClassName(Type.getClass(this)).split('.').pop();
			scriptName = stateName ?? '???';
		}
		
		scriptGroup.scriptShareables.set('parent', this);
		
		this.scriptName = scriptName;
		
		final scriptFile = FunkinScript.getPath('scripts/states/$scriptName');
		if (scriptGroup.exists(scriptFile)) return true;
		
		if (FunkinAssets.exists(scriptFile))
		{
			var newScript = FunkinScript.fromFile(scriptFile, scriptName, scriptGroup.scriptShareables);
			if (newScript.__garbage)
			{
				newScript = FlxDestroyUtil.destroy(newScript);
				return false;
			}
			
			scriptGroup.parent = this;
			
			Logger.log('script [$scriptName] initialized', NOTICE);
			
			scriptGroup.addScript(newScript);
			scripted = true;
		}
		
		if (callOnLoad) scriptGroup.call('onLoad', []);
		
		return scripted;
	}
	
	inline function get_controls():Controls return Controls.instance;
	
	private static inline function now():Float
	{
		return haxe.Timer.stamp();
	}
	
	private static function beginPlayTimeTracking():Void
	{
		if (playTimeTimestamp < 0) playTimeTimestamp = now();
	}
	
	private static function stopPlayTimeTracking():Void
	{
		playTimeTimestamp = -1;
	}
	
	private static function addPlayTimeDelta():Void
	{
		if (playTimeTimestamp < 0) return;
		
		final newTime:Float = now();
		final delta:Float = newTime - playTimeTimestamp;
		playTimeTimestamp = newTime;
		
		if (delta <= 0) return;
		
		ClientPrefs.totalPlayTime += delta;
		playTimeDirtyTimer += delta;
		
		if (playTimeDirtyTimer >= PLAY_TIME_SAVE_INTERVAL)
		{
			playTimeDirtyTimer %= PLAY_TIME_SAVE_INTERVAL;
			playTimeDirty = true;
		}
	}
	
	private static function bindPTH():Void
	{
		if (playTimeHooksBound) return;
		playTimeHooksBound = true;
		
		// flush when states switch
		FlxG.signals.preStateSwitch.add(function() {
			addPlayTimeDelta();
			flushPlayTime();
			stopPlayTimeTracking();
		});
		
		// pause/flush when alt-tabbed
		FlxG.signals.focusLost.add(function() {
			addPlayTimeDelta();
			flushPlayTime();
			stopPlayTimeTracking();
		});
		
		// resume timestamp on refocus
		FlxG.signals.focusGained.add(beginPlayTimeTracking);
	}
	
	private static function flushPlayTime():Void
	{
		if (!playTimeDirty) return;
		playTimeDirty = false;
		ClientPrefs.flushSave();
	}
	
	override function create()
	{
		updateMods();
		
		super.create();
		bindPTH();
		beginPlayTimeTracking();
		
		if (!FlxTransitionableState.skipNextTransOut)
		{
			openSubState(Type.createInstance(transitionOutState ?? _defaultTransState, [TransitionStatus.OUT]));
		}
		
		FlxTransitionableState.skipNextTransOut = false;
		
		PluginsManager.callOnScripts('onStateCreate');
	}
	
	var _updatedMods:Bool = false;
	
	public function updateMods(hard:Bool = false):Void
	{
		if (!hard && _updatedMods) return;
		
		_updatedMods = true;
		
		#if MODS_ALLOWED
		Mods.updateModList();
		Mods.pushGlobalMods();
		#end
	}
	
	/**
	 * Sorts a `FlxTypedGroup` based on objects `zIndex`.
	 * 
	 * used for stage layering primarily
	 * @param group 
	 */
	public function refreshZ(?group:FlxTypedGroup<FlxBasic>)
	{
		group ??= FlxG.state;
		group.sort(SortUtil.sortByZ, flixel.util.FlxSort.ASCENDING);
	}
	
	override function update(elapsed:Float)
	{
		addPlayTimeDelta();
		
		final oldStep:Int = curStep;
		
		updateCurStep();
		updateBeat();
		
		if (curStep > oldStep)
		{
			if (curStep >= 0) for (step in oldStep...curStep)
			{
				curStep = step + 1;
				updateBeat();
				stepHit();
				updateSection();
			}
		}
		else if (PlayState.SONG != null) rollbackSection();
		
		final scriptArgs = [elapsed];
		scriptGroup.call('onUpdate', scriptArgs);
		PluginsManager.callOnScripts('onUpdate', scriptArgs);
		super.update(elapsed);
	}
	
	private function updateSection():Void
	{
		if (stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}
	
	private function rollbackSection():Void
	{
		if (curStep < 0) return;
		
		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep) break;
				
				curSection++;
			}
		}
		
		if (curSection > lastSection) sectionHit();
	}
	
	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}
	
	private function updateCurStep():Void
	{
		curStep = Math.floor(curDecStep = Conductor.getStep(Conductor.songPosition - ClientPrefs.noteOffset));
	}
	
	public static function getState():MusicBeatState
	{
		return cast FlxG.state;
	}
	
	public static function getSubState(?state:flixel.FlxState)
	{
		state ??= FlxG.state;
		
		return (state.subState == null || state.subState is BaseTransitionState ? state : getSubState(state.subState));
	}
	
	public function stepHit():Void
	{
		scriptGroup.call('onStepHit', []);
		PluginsManager.callOnScripts('onStepHit');
		
		if (curStep % 4 == 0) beatHit();
	}
	
	public function beatHit():Void
	{
		scriptGroup.call('onBeatHit', []);
		PluginsManager.callOnScripts('onBeatHit');
	}
	
	public function sectionHit():Void
	{
		scriptGroup.call('onSectionHit', []);
		PluginsManager.callOnScripts('onSectionHit');
	}
	
	function getBeatsOnSection():Float
	{
		return PlayState.SONG?.notes[curSection]?.sectionBeats ?? 4.0;
	}
	
	override function startOutro(onOutroComplete:() -> Void)
	{
		final sub = getSubState()?.subState;
		
		if (sub is BaseTransitionState)
		{
			switch (@:privateAccess (cast sub : BaseTransitionState).status) // okey
			{
				case IN | FULL: return;
				
				default:
			}
		}
		
		if (!FlxTransitionableState.skipNextTransIn)
		{
			getSubState().openSubState(Type.createInstance(transitionInState ?? _defaultTransState, [TransitionStatus.IN, onOutroComplete]));
			return;
		}
		
		FlxTransitionableState.skipNextTransIn = false;
		
		super.startOutro(onOutroComplete);
	}
	
	override function destroy()
	{
		scriptGroup.call('onDestroy');
		
		scriptGroup = FlxDestroyUtil.destroy(scriptGroup);
		
		super.destroy();
	}
	
	override function closeSubState()
	{
		scriptGroup.call('onCloseSubState', []);
		super.closeSubState();
	}
}
