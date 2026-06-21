var strumTweens:Array<FlxTween>;

var ratio:Float = (FlxG.width / 1920);

var scaleAnimIcons:Float = 1;

var countdownSprite:FlxSprite;

countdownSounds = false;

function onCreatePost():Void
{
	strumTweens = [for (playField in playFields) [for (strum in playField) null]];
	
	FlxG.sound.load(Paths.sound('stage/topMiss'));
	
	Paths.image('ui/top/ready'); Paths.image('ui/top/set'); Paths.image('ui/top/go');
	countdownSprite = add(new FlxSprite());
	countdownSprite.scale.set(ratio, ratio);
	countdownSprite.camera = camHUD;
	countdownSprite.alpha = .9;
	countdownSprite.kill();
	
	gf.kill();
	
	var xf:Int = 0;
	for (i => playField in playFields)
	{
		modManager.setValue('dark', .1, i);
		
		for (j => strum in playField)
		{
			var xf = (j + xf);
			
			modManager.updateObject(0, strum, modManager.getPos(0, 0, 0, 0, strum.noteData, i, strum), i);
			
			modManager.setValue('transform${j}X', Math.round(((i == 0 ? (ClientPrefs.middleScroll ? 568 : 1020) : 0) + 180 * (j % 4) + 120 - 85) * ratio - strum.x), i);
			modManager.setValue('transform${j}Y', Math.round(((ClientPrefs.downScroll ? 930 : 150) - 85) * ratio - strum.y), i);
			
			strum.useRGBShader = strum.rgbShader.enabled = false;
		}
		
		xf += playField.keyCount;
	}
	
	if (!ClientPrefs.middleScroll) comboX -= 32;
	cameraSpeed = 1.25;
	
	// most ofthis is based on decompilwd code lolwaut it wasnt decompiled
	
	camZoomingMult = 0;
	
	playHUD.timeBar.kill();
	playHUD.timeTxt.kill();
	
	botplayTxt.setFormat(Paths.font('ariblk.ttf'), 26, FlxColor.WHITE, FlxTextAlign.CENTER);
	botplayTxt.x -= 40;
	
	playHUD.scoreTxt.setFormat(Paths.font('ariblk.ttf'), 26 * ratio, FlxColor.WHITE, FlxTextAlign.RIGHT);
	playHUD.scoreTxt.setPosition(Math.round(1430 * ratio - playHUD.scoreTxt.width), Math.round((ClientPrefs.downScroll ? 100 : 1010) * ratio - 3));
	playHUD.scoreTxt.origin.x = playHUD.scoreTxt.width;
	
	playHUD.healthBar.remove(playHUD.healthBar.bg);
	playHUD.healthBar.insert(0, playHUD.healthBar.bg);
	
	playHUD.healthBar.bg.color = FlxColor.BLACK;
	playHUD.healthBar.bg.makeGraphic((1440 - 505) * ratio, (1010 - 980) * ratio, FlxColor.WHITE);
	playHUD.healthBar.rightBar.loadGraphic(playHUD.healthBar.leftBar.loadGraphic(playHUD.healthBar.bg.graphic));
	
	playHUD.healthBar.barOffset.set(9 * ratio, 9 * ratio);
	playHUD.healthBar.barWidth = (playHUD.healthBar.bg.width - 18 * ratio);
	playHUD.healthBar.barHeight = (playHUD.healthBar.bg.height - 18 * ratio);
	playHUD.healthBar.setColors(FlxColor.RED, FlxColor.BLUE);
	playHUD.healthBar.updateBar();
	
	playHUD.healthBar.setPosition(Math.round(505 * ratio), Math.round((ClientPrefs.downScroll ? 70 : 980) * ratio));
	
	playHUD.iconP1.changeIcon('jugador');
	playHUD.iconP2.changeIcon('enemigo');
	
	playHUD.updateIconAnimation = playHUD.updateIconScale = playHUD.updateIconPos = false;
	playHUD.iconP1.updateOffset = playHUD.iconP2.updateOffset = false;
	playHUD.iconP1.updateHitbox();
	playHUD.iconP2.updateHitbox();
	playHUD.iconP1.y = playHUD.iconP2.y = ((ClientPrefs.downScroll ? 85 : 995) * ratio - playHUD.iconP1.height * .5);
	
	new FlxTimer().start(1, function(_) scaleAnimIcons = 1.15, 0);
	
	overrideScoreText();
}

function noteMissPress(_):Void
{
	health -= (healthLoss * pressMissDamage * (++ missCombo + 1) / 2);
	
	FlxG.sound.play(Paths.sound('stage/topMiss'));
	
	return Function_Stop;
}

function onGhostTap(k:Int):Void
{
	for (i => playField in playFields)
	{
		if (!playField.isPlayer || playField.autoPlayed) continue;
		
		var strum = playField.members[k];
		
		if (strum != null) squishStrum(k, i);
	}
}

function squishStrum(key:Int, playField:Int):Void
{
	strumTweens[playField][key]?.cancel();
	strumTweens[playField][key] = FlxTween.num(.1, 0, 1 / .02 / 60 * .1, null, function(n:Float)
	{
		modManager.setValue('receptor${key}ScaleX', n, playField);
		modManager.setValue('receptor${key}ScaleY', n, playField);
	});
	
	modManager.setValue('receptor${key}ScaleX', .1, playField);
	modManager.setValue('receptor${key}ScaleY', .1, playField);
}

function genericNoteHit(note:Note):Void
{
	final playField = note.playField;
	
	if (playField == null) return; //idk
	
	final k:Int = note.noteData;
	final i:Int = playField.ID;
	
	strumTweens[i][k]?.cancel();
	strumTweens[i][k] = FlxTween.num(-.1, 0, 1 / .02 / 60 * .1, {onComplete: function(_) {
		if (playField.isPlayer) squishStrum(k, i);
	}}, function(n:Float) {
		modManager.setValue('receptor${k}ScaleX', n, i);
		modManager.setValue('receptor${k}ScaleY', n, i);
	});
	
	modManager.setValue('receptor${k}ScaleX', -.1, i);
	modManager.setValue('receptor${k}ScaleY', -.1, i);
	
	final strum:StrumNote = note.strum;
	if (strum != null) // siii g h h hh
	{
		strum.useRGBShader = true;
		strum.copyNoteColor(note);
		strum.useRGBShader = false;
	}
}

function onSpawnNoteSplash(splash:NoteSplash):Void
{
	splash.animation.timeScale = (30 / 24);
}

function goodNoteHit(note:Note):Void genericNoteHit(note);
function extraNoteHit(note:Note):Void genericNoteHit(note);
function opponentNoteHit(note:Note):Void genericNoteHit(note);
function onUpdateScorePost(_):Void overrideScoreText();

function onSpawnNote(note:Note):Void
{
	note.rgbGraphics.mult = 0;
	
	note.color = note.rgbGraphics.r;
}

function onUpdatePost(elapsed:Float):Void
{
	for (i => playField in playFields)
	{
		for (j => strum in playField)
		{
			var escalas:Float = (1 - modManager.getValue('receptor${strum.noteData}ScaleX', i));
			
			strum.color = {
				if (escalas > 1)
				{
					(playField.isPlayer ? FlxColor.interpolate(strum.rgbGraphics.r, FlxColor.WHITE, .35 + (escalas - 1) / .1 * .15, 0) : strum.rgbGraphics.r);
				}
				else
				{
					FlxColor.GRAY;
				}
			}
		}
	}
	
	var pointsPlayer:Float = (health * 50);
	var posBaseIcons:Float = (510 + (925 / 100) * (100 - pointsPlayer));
	
	playHUD.iconP1.x = ((posBaseIcons + 75) * ratio - playHUD.iconP1.width * .5);
	playHUD.iconP2.x = ((posBaseIcons - 75) * ratio - playHUD.iconP2.width * .5);
	
	scaleAnimIcons = Math.max(scaleAnimIcons - elapsed * 60 * 0.02, 1);
	
	playHUD.iconP1.scale.set(scaleAnimIcons * ratio, scaleAnimIcons * ratio);
	playHUD.iconP2.scale.set(scaleAnimIcons * ratio, scaleAnimIcons * ratio);
	
	playHUD.iconP1.animation.curAnim.curFrame = Math.floor((100 - pointsPlayer) * .02 + .5);
	playHUD.iconP2.animation.curAnim.curFrame = Math.ceil(pointsPlayer * .02 - .5);
}

function overrideScoreText():Void
{
	if (playHUD?.scoreTxt == null || ClientPrefs.hideHud) return;
	
	playHUD.scoreTxt.text = playHUD.scoreTxt.text.toLowerCase();
	
	playHUD.healthLerp = health;
}

function onCountdownTick(tick:Int):Void
{
	function changeCountdownSprite(asset:String):Void
	{
		countdownSprite.loadGraphic(Paths.image('ui/top/$asset'));
		countdownSprite.screenCenter();
	}
	
	switch (tick)
	{
		case 0:
			FlxG.sound.play(Paths.sound('intro1'));
			
		case 1:
			FlxG.sound.play(Paths.sound('intro2'));
			changeCountdownSprite('ready');
			countdownSprite.revive();
			countdownReady.kill();
			
		case 2:
			FlxG.sound.play(Paths.sound('intro3'));
			changeCountdownSprite('set');
			countdownSet.kill();
			
		case 3:
			FlxG.sound.play(Paths.sound('introGo'));
			changeCountdownSprite('go');
			countdownGo.kill();
			
		case 4:
			countdownSprite.destroy();
	}
}
