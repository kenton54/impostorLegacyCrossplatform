import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

function onLoad()
{
    videoCutscene('suspect');
}
function onCreatePost()
{
	var picoSkin:Null<String> = ClientPrefs.equipment.get('picoSkin');
	var neneSkin:Null<String> = ClientPrefs.equipment.get('neneSkin');
	
	if (!PlayState.isStoryMode && picoSkin != null) changeCharacter(picoSkin, 0);
	if (!PlayState.isStoryMode && neneSkin != null) changeCharacter(neneSkin, 2);

	if (!PlayState.isStoryMode && picoSkin == null)
	{
		switch (ClientPrefs.bfSkin)
		{
			case 'detectiveplayer', 'bobby', 'LIMEGREENPlayable':
				changeCharacter(ClientPrefs.bfSkin, 0);
			
			default:
		}
	}
}

function onStepHit()
{
	switch (curStep)
	{
		case 0:
			defaultCamZoom = 0.8;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 8, {ease: FlxEase.quadIn});
		case 48:
			loBlack.alpha = 1;
			camHUD.visible = false;
			camSpecialThing([500, 450], [850, 450]);
		case 60:
			discuss.alpha = 1;
		case 64:
			discuss.alpha = 0.001;
			camHUD.visible = true;
			defaultCamZoom = 0.75;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
			loBlack.alpha = 0.001;
		case 176:
			defaultCamZoom = 0.77;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 192:
			defaultCamZoom = 0.70;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1, {ease: FlxEase.quadOut});
		case 304:
			defaultCamZoom = 0.73;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 310:
			defaultCamZoom = 0.76;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 316:
			defaultCamZoom = 0.79;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 318:
			defaultCamZoom = 0.81;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 320:
			defaultCamZoom = 0.7;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1, {ease: FlxEase.quadInOut});
		case 448:
			defaultCamZoom = 0.75;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.1, {ease: FlxEase.quadOut});
			triggerEventNote('Legacy', 'detective', '');
		case 460:
			triggerEventNote('Legacy', 'pico', '');
		case 464:
			triggerEventNote('Legacy', 'detective', '');
		case 476:
			triggerEventNote('Legacy', 'pico', '');
		case 480:
			triggerEventNote('Legacy', 'detective', '');
		case 492:
			triggerEventNote('Legacy', 'pico', '');
		case 496:
			triggerEventNote('Legacy', 'normal', '');
			defaultCamZoom = 0.7;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1.5, {ease: FlxEase.quadOut});
		case 576:
			defaultCamZoom = 0.72;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1, {ease: FlxEase.quadOut});
		case 704:
			defaultCamZoom = 0.76;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1, {ease: FlxEase.quadOut});
		case 800:
			defaultCamZoom = 0.78;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 804:
			defaultCamZoom = 0.79;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 808:
			defaultCamZoom = 0.8;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 805:
			boyfriend.animation.play('lock in', true);
			boyfriend.specialAnim = true;
	    	player.animation.play('bop');
		case 812:
			defaultCamZoom = 0.81;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
			boyfriend.animation.play('cock', true);
			boyfriend.specialAnim = true;
		case 816:
	    	boyfriend.animation.play('blast', true);
			boyfriend.specialAnim = true;
			dad.animation.play('shock', true);
			dad.specialAnim = true;
		case 814:
			defaultCamZoom = 0.7;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1, {ease: FlxEase.expoInOut});
		case 824:
			defaultCamZoom = 0.72;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
		case 842:
			defaultCamZoom = 0.7;
			FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadOut});
    }
}