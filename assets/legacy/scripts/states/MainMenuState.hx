import funkin.data.ClientPrefs;
import funkin.data.FinaleState;
import funkin.data.CosmicubeData;
import funkin.states.TitleState;

import flixel.text.FlxText;

function onLoad()
{
	if (!ClientPrefs.inDevMode) return;
	var debugText = new FlxText(0, 0, 1280,
		'content/scripts/states/MainMenuState.hx\nPress 9 to go to credits roll sequence\nPress Shift 7 to toggle Finale Endgame Sequence\nPress 6 to Force unlock Cosmicube requirements\nPress 5 to delete Cosmicube unlocks\nPress 4 to toggle Force Unlock for freeplay and story mode\nPress 3 to delete bought songs\nPress 2 to be rich\nPress 1 to be poor',
		12.5);
	debugText.alignment = 'right';
	add(debugText);
}

function onUpdate()
{
	if (!ClientPrefs.inDevMode) return;
	
	if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.SEVEN)
	{
		ClientPrefs.finaleState = (ClientPrefs.finaleState == FinaleState.ACTIVE ? FinaleState.INACTIVE : FinaleState.ACTIVE);
		ClientPrefs.flush();
		TitleState.initialized = false;
		FlxG.resetGame();
	}
	if (FlxG.keys.justPressed.NINE)
	{
		persistentUpdate = persistentDraw = false;
		openSubState(new funkin.states.substates.CreditsRollSubState(true, function() persistentUpdate = persistentDraw = true, function() persistentUpdate = persistentDraw = true));
	}
	if (FlxG.keys.justPressed.SIX)
	{
		ClientPrefs.forceUnlockReq = !ClientPrefs.forceUnlockReq;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlockReq ? 'FORCE UNLOCK REQ ON' : 'FORCE UNLOCK REQ OFF');
	}
	if (FlxG.keys.justPressed.FIVE)
	{
		ClientPrefs.cosmicubeUnlocks.resize(0);
		ClientPrefs.flush();
		trace('Cosmicube progress reset');
	}
	if (FlxG.keys.justPressed.FOUR)
	{
		ClientPrefs.forceUnlock = !ClientPrefs.forceUnlock;
		ClientPrefs.doubletrouble = ClientPrefs.forceUnlock;
		ClientPrefs.flush();
		trace(ClientPrefs.forceUnlock ? 'FORCE UNLOCK ON' : 'FORCE UNLOCK OFF');
	}
	if (FlxG.keys.justPressed.THREE)
	{
		ClientPrefs.unlockedSongs = [];
		ClientPrefs.flush();
		trace('WIPED SONG DATA');
	}
	if (FlxG.keys.justPressed.TWO)
	{
		CosmicubeData.currentMoney += 1000000;
		ClientPrefs.flush();
		trace('FREE MONEY');
	}
	if (FlxG.keys.justPressed.ONE)
	{
		CosmicubeData.currentMoney = 0;
		ClientPrefs.flush();
		trace('no money :(');
	}
}
