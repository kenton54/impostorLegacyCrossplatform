var ext = 'stages/jorsawsee/voting-time/';
var voting5:FlxSprite;
var voting6:FlxSprite;
var redmungus:Character;

function onLoad()
{
	var bars:FlxSpriteGroup = new FlxSpriteGroup();
	bars.cameras = [camHUD];
	add(bars);
	
	for (i in 0...2) // maybe this is doin too much idk
	{
		var bar = new FlxSprite().makeGraphic(FlxG.width + 3, 90, FlxColor.BLACK);
		bar.y = i == 1 ? 630 : 0;
		bars.add(bar);
	}
	
	var voting1:FlxSprite = new FlxSprite(610, 168).loadGraphic(Paths.image(ext + 'back'));
	voting1.scrollFactor.set(.93, .93);
	add(voting1);
	
	var voting2:FlxSprite = new FlxSprite(-472, -295).loadGraphic(Paths.image(ext + 'front'));
	voting2.scrollFactor.set(.95, .97);
	add(voting2);
	
	var jorsawsee:FlxSprite = new FlxSprite(1690, 480).loadGraphic(Paths.image(ext + 'jorsawsee'));
	jorsawsee.scrollFactor.set(.975, .99);
	jorsawsee.scale.set(.7, .7);
	jorsawsee.updateHitbox();
	add(jorsawsee);
	
	var votinguh:FlxSprite = new FlxSprite(500, 590).loadGraphic(Paths.image(ext + 'chair3'));
	votinguh.scrollFactor.set(.95, .95);
	add(votinguh);
	
	var voting3:FlxSprite = new FlxSprite(160, 625).loadGraphic(Paths.image(ext + 'chair2'));
	voting3.scrollFactor.set(.98, .98);
	add(voting3);
	
	var voting4:FlxSprite = new FlxSprite(-190, 700).loadGraphic(Paths.image(ext + 'chair1'));
	add(voting4);
	
	redmungus = new Character(1760, 225, 'madgus');
	game.startCharacterPos(redmungus);
	add(redmungus);
	redmungus.scale.set(1.2, 1.2);
	redmungus.danceEveryNumBeats = 1;
}

function onCreatePost()
{
	pet.zIndex = 1;
	redmungus.zIndex = 2;
	for (playField in playFields)
		if (playField.ID != 0) playField.playerControls = false;
	
	pet.scrollFactor.set(.95, .94);
	gf.scrollFactor.set(1.05, 1);
	redmungus.scrollFactor.set(.96, 1);
	boyfriend.scrollFactor.set(.95 /* genius! */, 1.05);
	dad.scrollFactor.set(1.05, 1.05);
		
	game.boyfriend.scale.x *= 1.2;
	game.boyfriend.scale.y *= 1.2;
	game.dad.scale.set(1.2, 1.2);
	game.boyfriend.updateHitbox();
	game.boyfriend.offset.set();
	game.boyfriend.dance();
	var voting5:FlxSprite = new FlxSprite(-90, 732).loadGraphic(Paths.image(ext + 'table'));
	voting5.scale.set(1.5 / 1.8, 1.5 / 1.8);
	voting5.scrollFactor.set(1.04, 1.15);
	voting5.updateHitbox();
	voting5.zIndex = 3;
	add(voting5);
	
	var voting6:FlxSprite = new FlxSprite(-428, 20).loadGraphic(Paths.image(ext + 'light'));
	voting6.scrollFactor.set(.7, .8);
	voting6.scale.set(6, 6);
	voting6.updateHitbox();
	voting6.blend = BlendMode.ADD;
	voting6.alpha = .8;
	voting6.zIndex = 3;
	add(voting6);
	
	snapCamToPos(1205, 575);
	// snapCamToPos(1800, 575);
	game.isCameraOnForcedPos = true;
	
	playFields.members[2].owner = game.gf;
	playFields.members[2].isPlayer = playFields.members[3].isPlayer = false;
	playFields.members[3].owner = redmungus;
	
	for (i in playFields.members)
	{
		final orgID = (3 - i.ID);
		final wrap = Math.floor(orgID / 2) == 1;
		
		i.visible = (i.ID == 0 || ClientPrefs.opponentStrums);
		
		if (wrap)
		{
			i.zIndex = 999;
		}
		else
		{
			i.underlay.kill();
			
			modManager.setValue("noteAlpha", 1, i.ID);
			modManager.setValue("alpha", 0.7, i.ID);
			modManager.setValue("stealth", 0.5, i.ID);
			// modManager.setValue("sustainSplashAlpha", 1, i.ID);
			// modManager.setValue("reverse", 1, i.ID);
			modManager.setValue("transformZ", -1, i.ID);
			modManager.setValue("transformY", -90 * (ClientPrefs.downScroll ? -1 : 1), i.ID);
			modManager.setValue("stealthPastReceptors", 1, i.ID);
			
			final space = 865;
			
			if (!ClientPrefs.middleScroll) modManager.setValue("transformX", i.ID == 2 ? -(space) : space, i.ID);
			else if (!ClientPrefs.opponentStrums) i.visible = false;
			// modManager.setValue("")
		}
	}
	
	refreshZ(playFields);
	
	if (boyfriend.gameoverLoopDeathSound == null) boyfriend.gameoverLoopDeathSound = 'Jorsawsee_Loop';
	if (boyfriend.gameoverConfirmDeathSound == null) boyfriend.gameoverConfirmDeathSound = 'Jorsawsee_End';
}

function onCountdownTick(tick:Int)
{
	if (tick < 4) redmungus.onBeatHit(curBeat);
}

function onBeatHit()
{
	redmungus.onBeatHit(curBeat);
}

function changeUI(who:Character)
{
	if (hasColor) scoreTxt.color = who.healthColour;
	if (who != boyfriend)
	{
		iconP2.changeIcon(who.healthIcon);
		playHUD.healthBar.setColors(who.healthColour, boyfriend.healthColour);
	}
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'Cam lock in Voting Time':
			if (value1 == 'in')
			{
				FlxG.camera.zoom = .9;
				defaultCamZoom = .9;
				
				if (value2 == 'dad')
				{
					snapCamToPos(460, 700);
					changeUI(dad);
				}
				else
				{
					changeUI(boyfriend);
					snapCamToPos(2100, 700);
				}
			}
			else if (value1 == 'close')
			{
				FlxG.camera.zoom = 1;
				defaultCamZoom = 1;
				
				if (value2 == 'dad')
				{
					snapCamToPos(480, 680);
					changeUI(gf);
				}
				else
				{
					snapCamToPos(2100, 680);
					changeUI(redmungus);
				}
			}
			else
			{
				defaultCamZoom = 0.55;
				FlxG.camera.zoom = 0.55;
				snapCamToPos(1205, 575);
			}
			
		case 'Play Animation':
			if (value1 == 'redmungus')
			{
				redmungus.playAnim(value2, true);
				redmungus.specialAnim = true;
			}
	}
}
