import funkin.backend.FunkinShader.FunkinRuntimeShader;

var lightsShader:FunkinRuntimeShader;
public var dimShader = (ClientPrefs.shaders ? new funkin.game.shaders.ColorMatrixShader() : null);
public var hudDarkShader:ExtraDropShadowShader;
public var darkShader:ExtraDropShadowShader;
public var vignette:Bool = false;
var isDark:Bool = false;
var noshader:Bool = false;

function onLoad()
{
	readDialogue();
	
	var dark:Null<String> = boyfriend.getFlag('variants')?.dark;
	if (dark != null) addCharacterToList(dark, 0);
	
	addCharacterToList('green-dark', 1);
	
	darkShader = new funkin.game.shaders.ExtraDropShadowShader();
	
	darkShader.threshold = .03;
	darkShader.setHollowColorMatrix([
		0, 0, 0, 0, 255,
		0, 0, 0, 0, 255,
		0, 0, 0, 0, 255,
		0, 0, 0, 1, 0
	]);
	darkShader.setColorMatrix([
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, 0, 1, 0
	]);
	darkShader.antialiasStages = 4;
	
	hudDarkShader = new funkin.game.shaders.ExtraDropShadowShader().copyFrom(darkShader);
	hudDarkShader.threshold = .12;
	hudDarkShader.setHollowColorMatrix([
		0, 0, 0, 0, 224,
		0, 0, 0, 0, 224,
		0, 0, 0, 0, 224,
		0, 0, 0, 1, 0
	]);
	
	darkShader.addLayer([
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, 0, 1, 0
	], -70, 22, 0);
	darkShader.addLayer([
		0, 0, 0, 0, 255,
		0, 0, 0, 0, 255,
		0, 0, 0, 0, 255,
		0, 0, 0, 1, 0
	], 140, 10, 0);
	darkShader.addLayer([
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, 0, 0, 0,
		0, 0, 0, 1, 0
	], -32, 12, 0);
	
	darkShader.attachedSprite = boyfriend;
	boyfriend.useRenderTexture = true;
	boyfriend.shader = null;
}

function onCreatePost()
{
	if (!hasBfSkin) bfvent.alpha = 0.001;
	if (gf.getFlag('lightsDownSpeaker')) ldSpeaker.alpha = 0.001;
}

function setVignette(yea:Bool):Void
{
	vignette = yea;
	
	boyfriend.shader = dad.shader = gf.shader = pet.shader = bg.shader = fg.shader = tn.shader = dimShader;
	
	if (dimShader == null) return;
	
	FlxTween.num(ClientPrefs.flashing ? .5 : 0, 1, .5, {ease: ClientPrefs.flashing ? FlxEase.elasticOut : FlxEase.sineOut}, function(n) {
		if (!yea) n = (1 - n);
		dimShader.setAdjustColor(n * -80, n * -20, n * -50, n * 20);
	});
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'Legacy':
			switch (value1)
			{
				case 'Vignette On':
					setVignette(true);
				case 'Vignette Off':
					setVignette(false);
				case 'ending':
					setVignette(false);
					triggerEventNote('Lights on', '', '');
					boyfriend.visible = false;
					gf.visible = false;
					triggerEventNote('HUD Fade', '0', '');
					triggerEventNote('Play Animation', 'liveReaction', 'dad');
					if (!hasBfSkin)
					{
						bfvent.alpha = 1;
						bfvent.animation.play('vent', true);
					}
					if (gf.getFlag('lightsDownSpeaker'))
					{
						ldSpeaker.animation.play('boom', true);
						ldSpeaker.alpha = 1;
					}
				case 'bye':
					camGame.alpha = 0;
			}
		case 'Lights out':
			if (value1 == '2' /* ????? */ || (value1 == '1' && !ClientPrefs.flashing)) return;
			
			isDark = true;
			
			// My favorite VS IMPOSTOR moment is when we loaded the dad shader despite this never being used outside of this song/character.
			camGame.flash(ClientPrefs.flashing ? FlxColor.WHITE : FlxColor.BLACK, 0.35);
			gf.alpha = 0;
			pet.alpha = 0;
			loBlack.alpha = 1;
			playHUD.iconP1.shader = hudDarkShader;
			playHUD.iconP2.shader = hudDarkShader;
			
			triggerEventNote('Change Character', '1', 'green-dark');
			dad.shader = null;
			
			playHUD.healthBar.bg.setColorTransform(0, 0, 0, 1, 224, 224, 224);
			
			var dark:Null<String> = boyfriend.getFlag('variants')?.dark;
			if (dark != null)
			{
				changeCharacter(dark, 0);
				boyfriend.shader = null;
				noshader = true;
			}
			else if (boyfriend.getFlag('dark') != true)
			{
				boyfriend.shader = darkShader;
			}
			
			playHUD.healthBar.setColors(FlxColor.BLACK, 0xffe0e0e0);
		case 'Lights on':
			if (value1 == '1' && !ClientPrefs.flashing) return;
			
			isDark = false;
			
			gf.alpha = 1;
			pet.alpha = 1;
			playHUD.iconP1.shader = null;
			playHUD.iconP2.shader = null;
			camGame.flash(FlxColor.BLACK, 0.35);
			loBlack.alpha = 0;
			
			playHUD.healthBar.bg.setColorTransform();
			
			if (noshader) changeCharacter(hasBfSkin ? ClientPrefs.bfSkin : PlayState.SONG.player1, 0);
			
			setVignette(vignette);
			triggerEventNote('Change Character', '1', PlayState.SONG.player2);
	}
}

function onGhostAnim(anim, note)
{
	if (isDark) return Function_Stop;
}
