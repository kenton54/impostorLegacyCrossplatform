package funkin.data;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

import funkin.backend.DebugDisplay;
import funkin.input.Controls;

// i did this cuz options are stupid
enum abstract VsyncMode(String) from String to String
{
	var OFF = 'Off';
	var ON = 'On';
	var ADAPTIVE = 'Adaptive';
	
	@:to
	public function toLimeVsyncMode():lime.ui.WindowVSyncMode
	{
		return switch (this)
		{
			default: lime.ui.WindowVSyncMode.OFF;
			case ON: lime.ui.WindowVSyncMode.ON;
			case ADAPTIVE: lime.ui.WindowVSyncMode.ADAPTIVE;
		}
	}
	
	@:from
	public static function fromInt(v:Int):VsyncMode
	{
		return switch (v)
		{
			default: OFF;
			case 1: ON;
			case -1: ADAPTIVE;
		}
	}
}

/**
 * to add new save options, make a static var with the `@saveVar` meta and itll be handled on its own
 * 
 * if you want to manually handle load and save add params to saveVar like `@saveVar(autoSave,autoLoad)`
 * 
 * for better reference on this look at keybinds
 */
@:build(funkin.backend.macro.SaveMacro.buildSaveVars('im gonna make this do smth later okay just not rn'))
class ClientPrefs
{
	// legacy ------------------------------------------------------------------------//
	@saveVar public static var finaleState:FinaleState = INACTIVE;
	
	@saveVar public static var activeCosmicube:String = 'impostor';
	
	@saveVar public static var cosmicubeUnlocks:Array<String> = [];
	
	@saveVar public static var checkoutUnlockedSongs:Array<String> = [];
	
	@saveVar public static var unlockedSongs:Array<String> = [];
	
	@saveVar public static var doubletrouble:Bool = false;
	
	@saveVar public static var money:Map<String, Int> = [];
	
	@saveVar public static var equipment:Map<String, Null<String>> = ['playerSkin' => null, 'speakerSkin' => null, 'pet' => null];
	
	public static var bfSkin(get, set):String;
	
	public static var gfSkin(get, set):String;
	
	public static var pet(get, set):String;
	
	@saveVar public static var forceUnlockReq:Bool = false;
	
	@saveVar public static var forceUnlock:Bool = false;
	
	@saveVar public static var colorText = 'Enabled';
	
	@saveVar public static var language:String = 'english';
	
	@saveVar public static var subtitles:Bool = true;
	
	@saveVar public static var achievements:Array<String> = [];
	
	@saveVar public static var tidbits:Array<String> = [];
	
	@saveVar public static var totalPlayTime:Float = 0;
	
	// my bullshit ------------------------------------------------------------------------//
	@saveVar public static var fnafStateVisited:Bool = false;
	
	@saveVar public static var scaryDefeat:Bool = false;
	
	@saveVar public static var scaryZared:Bool = false;
	
	@saveVar public static var fnafHintCode:String = '';
	
	// debug ------------------------------------------------------------------------//
	@saveVar public static var inDevMode:Bool = false;
	
	@saveVar public static var fpsDisplayType:String = 'Disabled';
	
	@saveVar public static var streamedMusic:Bool = false;
	
	@saveVar public static var autoPause:Bool = true;
	
	// graphics ------------------------------------------------------------------------//
	@saveVar public static var gpuCaching:Bool = true;
	
	@saveVar public static var globalAntialiasing:Bool = true;
	
	@saveVar public static var lowQuality:Bool = false;
	
	@saveVar public static var shaders:Bool = true;
	
	@saveVar public static var framerate:Int = 60;
	
	@saveVar public static var unlockedFramerate:Bool = false;
	
	@saveVar public static var vsyncMode:VsyncMode = OFF;
	
	// visuals ------------------------------------------------------------------------//
	@saveVar public static var jumpGhosts:Bool = true;
	
	@saveVar public static var noteSplashes:Bool = true;
	
	@saveVar public static var noteCovers:Bool = true;
	
	@saveVar public static var hideHud:Bool = false;
	
	@saveVar public static var timeBarType:String = 'Song Name';
	
	@saveVar public static var hudRankDisplay:String = 'Both';
	
	@saveVar public static var flashing(get, set):Bool;
	
	@saveVar public static var photosensitive:Bool = true;
	
	@saveVar public static var camZooms:Bool = true;
	
	@saveVar public static var scoreZoom:Bool = true;
	
	@saveVar public static var healthBarAlpha:Float = 1;
	
	@saveVar public static var showFPS:Bool = false;
	
	@saveVar public static var discordRPC(default, set):Bool = true;
	
	// its aura ok
	@saveVar public static var camFollowsCharacters:Bool = true;
	
	// gameplay ------------------------------------------------------------------------//
	@saveVar public static var mechanics:Bool = true;
	
	@saveVar public static var modcharts:Bool = true;
	
	@saveVar public static var downScroll:Bool = false;
	
	@saveVar public static var middleScroll:Bool = false;
	
	@saveVar public static var opponentStrums:Bool = true;
	
	@saveVar public static var ghostTapping:Bool = true;
	
	@saveVar public static var noReset:Bool = false;
	
	@saveVar public static var laneUnderlayAlpha:Float = 0;
	
	@saveVar public static var laneUnderlayStyle:String = 'A';
	
	@saveVar public static var opponentLaneUnderlay:Bool = true;
	
	@saveVar public static var hitsoundVolume:Float = 0;
	
	@saveVar public static var ratingOffset:Int = 0;
	
	@saveVar public static var useEpicRankings:Bool = true;
	
	@saveVar public static var toggleSplashScreen:Bool = true;
	
	@saveVar public static var epicWindow:Float = 22.5;
	
	@saveVar public static var sickWindow:Float = 45.0;
	
	@saveVar public static var goodWindow:Float = 90.0;
	
	@saveVar public static var badWindow:Float = 135.0;
	
	@saveVar public static var safeFrames:Float = 10.0;
	
	@saveVar public static var noteOffset:Int = 0;
	
	@saveVar public static var quants:Bool = false;
	
	@saveVar public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];
	
	// note colours ------------------------------------------------------------------------//
	@saveVar public static var arrowRGBdef:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]];
		
	@saveVar public static var arrowRGBquant:Array<Array<FlxColor>> = [
		[0xFFE51919, 0xFFFFFF, 0xFF5B0A30], // 4th
		[0xFF193BE5, 0xFFFFFF, 0xFF0A3B5B], // 8th
		[0xFFA119E5, 0xFFFFFF, 0xFF1D0A5B], // 12th
		[0xFF26D93E, 0xFFFFFF, 0xFF24560F], // 16th
		[0xFF0000B2, 0xFFFFFF, 0xFF002247], // 20th
		[0xFFA119E5, 0xFFFFFF, 0xFF1D0A5B], // 24th
		[0xFFE5C319, 0xFFFFFF, 0xFF5B2A0A], // 32nd
		[0xFFA119E5, 0xFFFFFF, 0xFF1D0A5B], // 48th
		[0xFF13ECA4, 0xFFFFFF, 0xFF085D18], // 64th
		[0xFF3A3A6C, 0xFFFFFF, 0xFF17202B], // 96th
		[0xFF3A3A6C, 0xFFFFFF, 0xFF17202B] // 192nd
	];
	
	@saveVar public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	@saveVar public static var quantHSV:Array<Array<Int>> = [
		[0, -20, 0], // 4th
		[-130, -20, 0], // 8th
		[-80, -20, 0], // 12th
		[128, -30, 0], // 16th
		[-120, -70, -35], // 20th
		[-80, -20, 0], // 24th
		[50, -20, 0], // 32nd
		[-80, -20, 0], // 48th
		[160, -15, 0], // 64th
		[-120, -70, -35], // 96th
		[-120, -70, -35] // 192nd
	];
	@saveVar public static var quantStepmania:Array<Array<Int>> = [
		[10, -20, 0], // 4th
		[-110, -40, 0], // 8th
		[140, -20, 0], // 12th
		[50, 25, 0], // 16th
		[0, -100, -50], // 20th
		[-80, -40, 0], // 24th
		[-180, 10, -10], // 32nd
		[-35, 50, 30], // 48th
		[160, -15, 0], // 64th
		[-120, -70, -35], // 96th
		[-120, -70, -35] // 192nd
	];
	
	// keybinds ------------------------------------------------------------------------//
	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	@saveVar(false, false) public static var keyBinds:Map<Action, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'note_taunt' => [SPACE, NONE],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN, NONE],
		'debug_2' => [EIGHT, NONE]
	];
	
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	
	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		defaultGamepadBinds = gamepadBinds.copy();
	}
	
	@saveVar(false, false) public static var gamepadBinds:Map<Action, Array<FlxGamepadInputID>> = [
		'note_up' => [DPAD_UP, Y],
		'note_down' => [DPAD_DOWN, A],
		'note_left' => [DPAD_LEFT, X],
		'note_right' => [DPAD_RIGHT, B],
		'note_taunt' => [LEFT_SHOULDER, NONE],
	];
	
	public static var defaultGamepadBinds:Map<Action, Array<FlxGamepadInputID>> = null;
	
	// Editor Colours ------------------------------------------------------------------------//
	@saveVar public static var editorUIColor:FlxColor = FlxColor.fromRGB(102, 163, 255);
	@saveVar public static var editorGradColors:Array<FlxColor> = [FlxColor.fromRGB(83, 21, 78), FlxColor.fromRGB(21, 62, 83)];
	@saveVar public static var editorBoxColors:Array<FlxColor> = [FlxColor.fromRGB(58, 112, 159), FlxColor.fromRGB(138, 173, 202)];
	@saveVar public static var editorGradVis:Bool = true;
	
	@saveVar public static var chartPresetList:Array<String> = ["Default"];
	
	@saveVar public static var chartPresets:Map<String, Array<Dynamic>> = [
		"Default" => [
			[FlxColor.fromRGB(0, 0, 0), FlxColor.fromRGB(0, 0, 0)],
			false,
			[FlxColor.fromRGB(255, 255, 255), FlxColor.fromRGB(210, 210, 210)],
			FlxColor.fromRGB(250, 250, 250)
		]
	];
	
	/**
	 * Contains keys that mute the game volume
	 * 
	 * default is `0`
	 */
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	
	/**
	 * Contains keys that turn down the game volume
	 * 
	 * default is `-`
	 */
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	
	/**
	 * Contains keys that turn up the game volume
	 * 
	 * default is `+`
	 */
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	
	public static final maxBackups:Int = 10;
	
	public static function flush()
	{
		flushSave();
		
		flushControls();
	}
	
	public static function flushSave():Void
	{
		FlxG.save.data.date = Date.now().toString();
		
		backupSave();
		
		FlxG.save.flush();
	}
	
	public static function flushControls():Void
	{
		var save:FlxSave = getControlsSave(); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.data.customGamepadControls = gamepadBinds;
		save.close();
	}
	
	public static inline function getControlsSave():FlxSave
	{
		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'MotorFrog', function(data:String, exception:haxe.Exception) {
			trace('controls save data was corrupted: ${exception.message}. controls have been reset');
			
			return {};
		});
		
		return save;
	}
	
	public static function backupSave(name:String = 'funkin'):Void // surely theres better ways right but whatever
	{
		final path:String = SaveUtil.getPath('', FlxG.stage.application.meta.get('file') + '/$name');
		final sav = path.withoutExtension();
		
		if (FileSystem.exists(path))
		{
			if (FileSystem.exists('$sav-backup.sol')) FileSystem.deleteFile('$sav-backup.sol');
			
			try
			{
				File.copy(path, '$sav-backup.sol');
				
				function push(i:Int)
				{
					if (!FileSystem.exists('$sav-backup$i.sol')) return;
					
					if (FileSystem.exists('$sav-backup${i + 1}.sol')) push(i + 1);
					
					if (i + 1 <= maxBackups)
					{
						FileSystem.rename('$sav-backup$i.sol', '$sav-backup${i + 1}.sol');
					}
					else
					{
						FileSystem.deleteFile('$sav-backup$i.sol');
					}
				}
				
				push(1);
			}
			catch (e:haxe.Exception)
			{
				trace('sigh ${e.message}');
			}
			
			if (FileSystem.exists('$sav-backup.sol')) FileSystem.rename('$sav-backup.sol', '$sav-backup1.sol');
		}
	}
	
	public static function tryBindingSave(name:String = 'funkin'):Void
	{
		FlxG.save.bind(name, CoolUtil.getSavePath(), function(data:String, exception:haxe.Exception) {
			final file = @:privateAccess FlxSave.validate(FlxG.stage.application.meta.get('file'));
			final path = SaveUtil.getPath('', '$file/$name');
			
			if (FileSystem.exists(path))
			{
				final corruptedPath = path.withoutExtension() + ' (corrupted) ${Date.now().toString().replace(':', '_')}.sol';
				FileSystem.rename(path, corruptedPath);
				
				trace('save was corrupted: ${exception.message}. corrupted save was placed at $corruptedPath');
				
				// can someone add a freaking notiifcation or sometihng
			}
			
			return attemptLoadBackup(name);
		});
	}
	
	public static function attemptLoadBackup(name:String = 'funkin'):Dynamic
	{
		final path:String = SaveUtil.getPath('', FlxG.stage.application.meta.get('file') + '/funkin');
		final sav = path.withoutExtension();
		
		var backupSave:FlxSave = new FlxSave();
		
		function attempt(postfix:String):Dynamic
		{
			if (FileSystem.exists('$sav-backup$postfix.sol'))
			{
				if (backupSave.bind('$name-backup$postfix', CoolUtil.getSavePath()))
				{
					var data = backupSave.data;
					backupSave.destroy();
					
					FileSystem.deleteFile('$sav-backup$postfix.sol');
					
					trace('loaded $name-backup$postfix (${data.date})');
					
					return data;
				}
				else
				{
					trace('cant load bak $postfix');
					
					FileSystem.deleteFile('$sav-backup$postfix.sol');
				}
			}
			
			return null;
		}
		
		final result = attempt('');
		
		if (result != null) return result;
		
		var i:Int = 0;
		while (++i <= maxBackups)
		{
			final result = attempt(Std.string(i));
			
			if (result != null) return result;
		}
		
		return {};
	}
	
	/**
	 * You can add your own functionality here if needed beyond what `@saveVar` does. 
	 * 
	 * that being just loading the values from the flixel save
	 */
	public static function load()
	{
		if (FlxG.save.data.autoPause != null) FlxG.autoPause = FlxG.save.data.autoPause;
		
		if (FlxG.save.data.volume != null) FlxG.sound.volume = FlxG.save.data.volume;
		else FlxG.sound.volume = 0.6; // I'm doing them a fucking favor.
		
		if (FlxG.save.data.mute != null) FlxG.sound.muted = FlxG.save.data.mute;
		
		if (DebugDisplay.instance != null) DebugDisplay.instance.visible = showFPS;
		
		if (FlxG.save.data.framerate == null) framerate = Std.int(FlxMath.bound(FlxG.stage.application.window.displayMode.refreshRate, 60, 240));
		
		changeFps(framerate);
		
		if (FlxG.save.data.beans != null)
		{
			ClientPrefs.money.set('beans', FlxG.save.data.beans);
			
			Reflect.deleteField(FlxG.save.data, 'beans');
			
			trace('migrated beans');
		}
		
		for (oldField => newField in ['bfSkin' => 'playerSkin', 'gfSkin' => 'speakerSkin', 'pet' => 'pet'])
		{
			if (Reflect.hasField(FlxG.save.data, oldField))
			{
				var value:String = Reflect.field(FlxG.save.data, oldField);
				
				if (value == 'default' || value == '') value = null;
				
				ClientPrefs.equipment.set(newField, value);
				
				Reflect.deleteField(FlxG.save.data, oldField);
				
				trace('migrated $oldField');
			}
		}
		
		var save:FlxSave = getControlsSave();
		if (save.data?.customControls is haxe.ds.StringMap) CoolUtil.copyMapValues(save.data.customControls, keyBinds);
		if (save.data?.customGamepadControls is haxe.ds.StringMap) CoolUtil.copyMapValues(save.data.customGamepadControls, gamepadBinds);
		reloadControls();
		save.destroy();
	}
	
	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic
	{
		return (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}
	
	public static function reloadControls()
	{
		Controls.instance.setKeyboardScheme(KeyboardScheme.Solo);
		
		final gamepads = Controls.instance.gamepadsAdded.copy();
		Controls.instance.removeGamepad();
		for (id in gamepads)
			Controls.instance.addDefaultGamepad(id);
			
		ClientPrefs.muteKeys = copyKey(keyBinds.get('volume_mute'));
		ClientPrefs.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		ClientPrefs.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		
		FlxG.sound.muteKeys = ClientPrefs.muteKeys;
		FlxG.sound.volumeDownKeys = ClientPrefs.volumeDownKeys;
		FlxG.sound.volumeUpKeys = ClientPrefs.volumeUpKeys;
	}
	
	public static function changeFps(fps:Int = 60)
	{
		fps = unlockedFramerate ? 0 : Std.int(FlxMath.bound(fps, 60, 400));
		
		if (fps > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = fps;
			FlxG.drawFramerate = fps;
		}
		else
		{
			FlxG.drawFramerate = fps;
			FlxG.updateFramerate = fps;
		}
	}
	
	public static function updateVsyncMode()
	{
		FlxG.stage.window.setVSyncMode(ClientPrefs.vsyncMode);
	}
	
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;
		
		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		
		return copiedArray;
	}
	
	static function get_bfSkin():String return (equipment.get('playerSkin') ?? 'default');
	
	static function get_gfSkin():String return (equipment.get('speakerSkin') ?? 'default');
	
	static function get_pet():String return (equipment.get('pet') ?? '');
	
	static function set_bfSkin(now:String):String
	{
		equipment.set('playerSkin', now == 'default' ? null : now);
		return now;
	}
	
	static function set_gfSkin(now:String):String
	{
		equipment.set('speakerSkin', now == 'default' ? null : now);
		return now;
	}
	
	static function set_pet(now:String):String
	{
		equipment.set('pet', now == '' ? null : now);
		return now;
	}
	
	static function get_flashing():Bool
	{
		return !photosensitive;
	}
	
	static function set_flashing(now:Bool):Bool
	{
		return photosensitive = !now;
	}
	
	static function set_discordRPC(now:Bool):Bool
	{
		discordRPC = now;
		
		funkin.api.DiscordClient.check();
		
		return now;
	}
}

@:access(flixel.util.FlxSave)
private class SaveUtil
{
	public static function getPath(localPath:String, name:String):String
	{
		// Avoid ever putting .sol files directly in AppData
		if (localPath == "") localPath = getDefaultLocalPath();
		
		var directory = lime.system.System.applicationStorageDirectory;
		var path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		
		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");
		
		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}
		
		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}
		
		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";
			
			for (i in 0...(split.length - 1))
			{
				name += split[i] + "/";
			}
			
			name += split[split.length - 1];
		}
		
		return path + name + ".sol";
	}
	
	public static function getDefaultLocalPath()
	{
		var meta = openfl.Lib.current.stage.application.meta;
		var path = meta["company"];
		if (path == null || path == "") path = "HaxeFlixel";
		else path = FlxSave.validate(path);
		
		return path;
	}
}
