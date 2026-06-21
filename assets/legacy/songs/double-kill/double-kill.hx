var cargoDarkFG:FlxSprite;
var cargoDarken:Bool = false;
var cargoAirship:FlxSprite;
var showDlowDK:Bool = false;
var defeatDKoverlay:FlxSprite;
var testMode:Bool = false;

function onCreatePost()
{
	if (!hasBfSkin) addCharacterToList('bf-defeat-normal', 0);
	reactorFade = 1;
	cargoAirsip = new FlxSprite(2200, 800).loadGraphic(Paths.image('stages/airship/double-kill/airshipFlashback'));
	cargoAirsip.antialiasing = true;
	cargoAirsip.updateHitbox();
	cargoAirsip.scrollFactor.set(1, 1);
	cargoAirsip.setGraphicSize(Std.int(cargoAirsip.width * 1.3));
	cargoAirsip.alpha = 0.001;
	add(cargoAirsip);
	
	camHUD.visible = false;
	cargoDarkFG = new FlxSprite(-640, -360).makeScaledGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
	cargoDarkFG.scrollFactor.set(0, 0);
	
	defeatDKoverlay = new FlxSprite(900, 350).loadGraphic(Paths.image('stages/void/iluminao omaga'));
	defeatDKoverlay.blend = BlendMode.ADD;
	defeatDKoverlay.alpha = 0.001;
	defeatDKoverlay.scale.set(4, 4);
	defeatDKoverlay.updateHitbox();
	add(defeatDKoverlay);
	add(cargoDarkFG);
	if (testMode) cargoDarkFG.alpha = 0;
	
	camSpecialThing([2000, 1050], [2300, 1050], -1);
}

function onUpdate(elapsed)
{
	// i want to know who did this bullshit in source.
	if (Conductor.songPosition >= 0 && Conductor.songPosition < 1200)
	{
		cargoDarkFG.alpha -= elapsed / 5;
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, FlxMath.bound(elapsed * 3, 0, 1));
	}
	if (cargoDarken)
	{
		cargoDark.alpha = FlxMath.lerp(cargoDark.alpha, 1, FlxMath.bound(elapsed * 1.4, 0, 1));
		dad.alpha = FlxMath.lerp(dad.alpha, 0.001, FlxMath.bound(elapsed * 1.4, 0, 1));
		gf.alpha = FlxMath.lerp(gf.alpha, 0.001, FlxMath.bound(elapsed * 1.4, 0, 1));
		// pet.alpha = FlxMath.lerp(pet.alpha, 0.001, FlxMath.bound(elapsed * 1.4, 0, 1));
		mainoverlayDK.alpha = FlxMath.lerp(mainoverlayDK.alpha, 0.001, FlxMath.bound(elapsed * 1.4, 0, 1));
		lightoverlayDK.alpha = FlxMath.lerp(lightoverlayDK.alpha, 0.001, FlxMath.bound(elapsed * 1.4, 0, 1));
	}
	if (showDlowDK)
	{
		cargoAirsip.alpha = FlxMath.lerp(cargoAirsip.alpha, 0.45, FlxMath.bound(elapsed * 0.1, 0, 1));
	}
	/*if (FlxG.keys.justPressed.Q)
		{
			setSongTime(183 * 1000);
			clearNotesBefore(Conductor.songPosition);
	}*/
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'flash':
			cargoDarkFG.alpha = 0;
			camHUD.visible = true;
		case 'Legacy':
			switch (value1)
			{
				case 'wmc': // weird mid cam
					camSpecialThing([2150, 1050], [2150, 1050]);
				case 'nc': // normal cam
					camSpecialThing([2000, 1050], [2300, 1050]);
				case 'ncy': // normal cam
					camSpecialThing([2000, 1050], [isBfGhost ? 2600 : 2300, 1050]);
				case '356':
					camSpecialThing(-1, [2750, 1150], 1.1);
				case '420':
					camSpecialThing(-1, [2300, 1050], 0.8);
				case '552':
					camSpecialThing([1650, 1180], -1, 1.2);
					if (isBfGhost) FlxTween.tween(yellow, {alpha: 1}, Conductor.stepCrotchet / 1000);
				case '556':
					camSpecialThing([2000, 1050], isBfGhost ? [2600, 1050] : -1, 0.8);
				case 'darken':
					cargoDarken = true;
					camGame.flash(FlxColor.BLACK, 0.55);
				case 'airship':
					showDlowDK = true;
				case 'brighten':
					showDlowDK = false;
					cargoDarken = false;
					cargoAirsip.alpha = 0.001;
					cargoDark.alpha = 0.001;
					dad.alpha = 1;
					gf.alpha = 1;
					// pet.alpha = 1;
					lightoverlayDK.alpha = 0.6;
					mainoverlayDK.alpha = 0.51;
				case 'gonnakill':
					FlxTween.tween(game, {defaultCamZoom: 1}, Conductor.crotchet * .004, {ease: FlxEase.sineInOut});
					FlxTween.tween(cargoDarkFG, {alpha: 1}, Conductor.crotchet * .004);
					
					for (obj in [playHUD.timeBar, playHUD.timeTxt, playHUD.healthBar, playHUD.iconP1, playHUD.iconP2])
						FlxTween.tween(obj, {alpha: 0}, Conductor.crotchet * .004, {ease: FlxEase.circInOut});
					
				case 'readykill':
					if (!hasBfSkin) triggerEventNote('Change Character', '0', 'bf-defeat-normal');
					
					FlxTween.tween(game, {defaultCamZoom: .8}, Conductor.crotchet * .004 * 4, {ease: FlxEase.expoOut});
					
					if (yellow != null) yellow.kill();
					if (ClientPrefs.downScroll) playHUD.scoreTxt.y = FlxG.height * 0.06;
					defeatDKoverlay.alpha = .1;
					lightoverlayDK.alpha = 0;
					cargoDark.alpha = 1;
					dad.alpha = 0;
					cargoDarkFG.alpha = 1;
					FlxTween.tween(cargoDarkFG, {alpha: 0}, 2.75);
					
					mainoverlayDK.flipY = true;
					mainoverlayDK.scale.y *= 3;
					mainoverlayDK.y += 1200;
					
					defeatness();
					
				case 'ending':
					FlxTween.tween(game, {defaultCamZoom: .6}, Conductor.crotchet * .004 * 16);
					FlxTween.tween(defeatDKoverlay, {alpha: 1}, Conductor.crotchet * .004 * 20, {ease: FlxEase.sineInOut});
					FlxTween.tween(mainoverlayDK.scale, {y: mainoverlayDK.scale.y * 2}, Conductor.crotchet * .004 * 24, {ease: FlxEase.sineInOut});
				
				case 'endingcam':
					camSpecialThing([2220, 1050], [2220, 1050]);
					
				case 'kill':
					camGame.flash(FlxColor.RED, 2.75);
					gf.kill();
					pet.kill();
					boyfriend.kill();
					defeatDKoverlay.kill();
					camHUD.visible = false;
			}
	}
}

function defeatness():Void
{
	if (!ClientPrefs.shaders) return;
	
	var defeat:Null<String> = boyfriend.getFlag('variants')?.defeat;
	if (defeat != null) changeCharacter(defeat, 0);
	
	var blackRimlightBase:ExtraDropShadowShader = new funkin.game.shaders.ExtraDropShadowShader();
	
	blackRimlightBase.threshold = .05;
	blackRimlightBase.strength = .85;
	blackRimlightBase.setColorMatrix([
		.4, .5, -.2, 0, -50,
		-.25, .7, -.15, 0, -20,
		.42, -.35, .85, 0, -72,
		0, 0, 0, 1, 0
	]);
	blackRimlightBase.addLayer([
		.7, .5, 1, 0, 192,
		.3, .4, -.5, 0, 64,
		-.1, .2, .35, 0, 74,
		0, 0, 0, 1, 0
	], 10, 14, .01);
	blackRimlightBase.addLayer(
		blackRimlightBase.addLayer([
			.9, .6, .4, 0, 4,
			-.2, .5, .1, 0, -18,
			-.2, .2, .4, 0, -28,
			0, 0, 0, 1, 0
		], 12, 40, .01, .4)
	.colorMatrix, 96, 24, .01, .4);
	
	if (hasBfSkin && boyfriend.getFlag('backlit') != true)
	{
		bfRim = blackRimlightBase;
		bfRim.attachedSprite = boyfriend;
		boyfriend.useRenderTexture = true;
	}
	
	if (hasPet)
	{
		petRim = new funkin.game.shaders.ExtraDropShadowShader().copyFrom(blackRimlightBase);
		petRim.attachedSprite = pet;
		pet.useRenderTexture = true;
	}
}
