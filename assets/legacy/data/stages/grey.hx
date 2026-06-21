import funkin.game.shaders.ChromaticAbberation;
import funkin.game.shaders.DropShadowShader;

import openfl.filters.ShaderFilter;

var ext = 'stages/airship/gray/';
var isChrom:Bool;
var chromAmount:Float = 0;
var chromFreq:Int = 1;
var chromTween:FlxTween;
public var crowd:FlxSprite;
var caShader:ChromaticAbberation;
var bfdead:FlxSprite;

function onBeatHit()
{
	if (curBeat % chromFreq == 0)
	{
		if (chromTween != null) chromTween.cancel();
		caShader.amount = chromAmount;
		chromTween = FlxTween.tween(caShader, {amount: 0}, 0.45, {ease: FlxEase.sineOut});
	}
	if (curBeat % 4 == 0) crowd.animation.play('bop', true);
}

function onLoad()
{
	var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(ext + 'graybg'));
	add(bg);
	
	var thebackground = new FlxSprite(1930, 400);
	thebackground.frames = Paths.getSparrowAtlas(ext + 'grayglowy');
	thebackground.animation.addByPrefix('bop', 'jar??', 24, true);
	thebackground.animation.play('bop');
	thebackground.antialiasing = true;
	thebackground.scrollFactor.set(1, 1);
	thebackground.setGraphicSize(Std.int(thebackground.width * 1));
	thebackground.active = true;
	add(thebackground);
	
	crowd = new FlxSprite(200, 350);
	crowd.frames = Paths.getSparrowAtlas(ext + 'grayblack');
	crowd.animation.addByPrefix('bop', 'who instance 1', 18, false);
	crowd.animation.play('bop');
	add(crowd);
	
	bfdead = new FlxSprite(600, 525).loadGraphic(Paths.image('stages/polus/red/bfdead'));
	bfdead.setGraphicSize(Std.int(bfdead.width * 0.8));
	bfdead.updateHitbox();
	bfdead.alpha = 0;
}

function onCreatePost()
{
	snapCamToPos(1300, 700);
	camSpecialThing([1300, 700], [1800, 700]);
	// Lol
	if (boyfriend.curCharacter == 'bf-ghost')
	{
		bfdead.alpha = 1;
		bfdead.setPosition(boyfriend.x - 150, boyfriend.y + 350);
		stage.insert(stage.members.indexOf(boyfriendGroup) - 1, bfdead);
		
		if (ClientPrefs.shaders)
		{
			var rim:DropShadowShader;
			rim = new DropShadowShader();
			rim.setAdjustColor(-40, -25, -25, -25);
			rim.color = 0xFF447F80;
			rim.angle = 45;
			rim.threshold = 0.5;
			rim.distance = 25;
			bfdead.shader = rim;
			rim.attachedSprite = boyfriend;
			rim.updateFrameInfo(boyfriend.frame);
		}
		else
		{
			bfdead.color = 0xffa0c0d6;
		}
	}
	caShader = new ChromaticAbberation(0);
	caShader.amount = -0.5;
	if (ClientPrefs.shaders) FlxG.camera.filters = [new ShaderFilter(caShader.shader)];
	
	var grayfg:FlxSprite = new FlxSprite(1200, 1030).loadGraphic(Paths.image(ext
		+ 'grayfg'
		+ (boyfriend.curCharacter == 'yellowplayable' ? '_noyellow' : '')));
	grayfg.scrollFactor.set(1.1, 1.1);
	add(grayfg);
	
	var lightadd:FlxSprite = new FlxSprite(-150, -200).loadGraphic(Paths.image(ext + 'grayadd'));
	lightadd.scale.set(2, 2);
	lightadd.updateHitbox();
	lightadd.blend = BlendMode.ADD;
	lightadd.alpha = 1;
	add(lightadd);
	
	var lightsubtract:FlxSprite = new FlxSprite(-900, -200).loadGraphic(Paths.image(ext + 'graysubtract'));
	lightsubtract.scale.set(2, 2);
	lightsubtract.updateHitbox();
	lightsubtract.blend = BlendMode.SUBTRACT;
	lightsubtract.alpha = 1;
	add(lightsubtract);
	
	if (hasGfSkin && gf.curCharacter == 'gfmira') changeCharacter('gf-pretender', 2);
	if (ClientPrefs.shaders)
	{
		var rimlightBase:ExtraDropShadowShader = new funkin.game.shaders.ExtraDropShadowShader();
		
		rimlightBase.setColorMatrix([
			0.3, 0.2, 0, 0, 9,
		    -0.5, 0.77, 0.2, 0, 13,
			   0, -0.1, 0.69, 0, 20,
			   0, 0, 0, 1, 0
		]);
		rimlightBase.threshold = .02;
		rimlightBase.strength = .7;
		rimlightBase.addLayer(
			rimlightBase.addLayer([
				1.5, 0, 0, 0, -8,
				0, .8, .1, 0, 59,
				.1, 0, .8, 0, 57,
				0, 0, 0, 1, 0
			], 20, 25, .01)
		.colorMatrix, 90, 15, .01);
		
		if (hasBfSkin && boyfriend.curCharacter != 'bfairship' && boyfriend.getFlag('backlit') != true)
		{
			bfRim = rimlightBase;
			bfRim.attachedSprite = boyfriend;
			boyfriend.useRenderTexture = true;
		}
		
		if (hasGfSkin && gf.getFlag('backlit') != true)
		{
			gfRim = new funkin.game.shaders.ExtraDropShadowShader().copyFrom(rimlightBase);
			gfRim.layers[0].distance = gfRim.layers[1].distance = 20;
			gfRim.layers[0].angle = 60;
			gfRim.layers[1].angle = 120;
			gfRim.attachedSprite = gf;
			gf.useRenderTexture = true;
		}
		if (hasPet)
		{
			petRim = new funkin.game.shaders.ExtraDropShadowShader().copyFrom(rimlightBase);
			petRim.attachedSprite = pet;
		}
	}
	else
	{
		if (hasBfSkin && boyfriend.curCharacter != 'bfairship') boyfriend.color = 0xffa0c0d6;
		
		if (hasGfSkin) gf.color = 0xffa0c0d6;
		
		if (hasPet) pet.color = 0xffa0c0d6;
	}
}

function onUpdatePost()
{
	if (ClientPrefs.inDevMode && showDevInfo) dbText = dbText + ('\nchrom (am, freq): ' + [chromAmount, chromFreq]);
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'chromToggle':
			var theAmount:Float = Std.parseFloat(value1 ?? 0);
			var theAmount2:Int = Std.int(value2 ?? (theAmount > 0 ? 1 : 0));
			if (showDevInfo) trace([theAmount, theAmount2]);
			
			if (theAmount > 0)
			{
				isChrom = true;
				chromAmount = theAmount;
				chromFreq = theAmount2;
				return;
			}
			else
			{
				isChrom = false;
				chromAmount = 0;
				return;
			}
	}
}
