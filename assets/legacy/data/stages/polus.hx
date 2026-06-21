import funkin.objects.SnowEmitter;

public var speaker:FlxSprite;
public var bfdead:FlxSprite;
var snowAlpha = 1;
var snowEmitter:SnowEmitter;
var crowd:FlxSprite;
var outroVid:PsychVideoSprite;
var ext = 'stages/polus/red/';

function onLoad()
{
	var sky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image(ext + 'polus_custom_sky'));
	sky.scrollFactor.set(0.5, 0.5);
	sky.setGraphicSize(Std.int(sky.width * 1.4));
	add(sky);
	
	var rocks:FlxSprite = new FlxSprite(-700, -300).loadGraphic(Paths.image(ext + 'polusrocks'));
	rocks.scrollFactor.set(0.6, 0.6);
	add(rocks);
	
	var hills:FlxSprite = new FlxSprite(-1050, -180.55).loadGraphic(Paths.image(ext + 'polusHills'));
	hills.scrollFactor.set(0.9, 0.9);
	add(hills);
	
	var warehouse:FlxSprite = new FlxSprite(50, -400).loadGraphic(Paths.image(ext + 'polus_custom_lab'));
	add(warehouse);
	
	var ground:FlxSprite = new FlxSprite(-1350, 80).loadGraphic(Paths.image(ext + 'polus_custom_floor'));
	add(ground);
	
	snowEmitter = new SnowEmitter(-600, -600, 2700);
	snowEmitter.start(false, ClientPrefs.lowQuality ? 0.1 : 0.05);
	snowEmitter.scrollFactor.x.set(1, 1.5);
	snowEmitter.scrollFactor.y.set(1, 1.5);
	add(snowEmitter);
	snowEmitter.alpha.active = false;
	snowEmitter.onEmit.add((particle) -> particle.alpha = snowAlpha);
	snowEmitter.zIndex = 13;
	snowEmitter.lifespan.set(5);
	
	speaker = new FlxSprite(300, 185);
	speaker.frames = Paths.getSparrowAtlas(ext + 'speakerlonely');
	speaker.animation.addByPrefix('bop', 'speakers lonely', 24, false);
	speaker.animation.play('bop');
	speaker.alpha = 0;
	add(speaker);
	
	bfdead = new FlxSprite(600, 525).loadGraphic(Paths.image(ext + 'bfdead'));
	bfdead.setGraphicSize(Std.int(bfdead.width * 0.8));
	bfdead.updateHitbox();
	bfdead.alpha = 0;
	add(bfdead);
	
	// wh.color = FlxColor.RED;
	// wh.alpha = 0.2;
}

function onCreatePost()
{
	camSpecialThing([470, 250], [820, 250]);
	if (gf.curCharacter == 'gf-ghost' && curSong.toLowerCase() != 'top 10')
	{
		speaker.alpha = 1;
		gf.y -= 240;
	}
	if (boyfriend.curCharacter == 'bf-ghost') bfdead.alpha = 1;
	
	crowd = new FlxSprite(-900, 150);
	crowd.frames = Paths.getSparrowAtlas(ext + 'boppers_meltdown');
	crowd.animation.addByPrefix('bop', 'BoppersMeltdown', 24, false);
	crowd.animation.play('bop');
	crowd.scale.set(0.9,0.9);
	crowd.scrollFactor.set(1.5, 1.5);
	crowd.antialiasing = true;
	// crowd2.scale.set(1, 1); // are we fucking fr
	if (PlayState.SONG.song.toLowerCase() == 'meltdown')
	{
		add(crowd);
	}
}

function onSongStart()
{
	if (hasBfSkin && game.boyfriend.curCharacter == 'redp' && pet.curPet == 'minicrewmate') game.unlockAchievementPopup('red_handed');
}

function onBeatHit()
{
	if (curBeat % 1 == 0) speaker.animation.play('bop');
	if (curBeat % 2 == 0) crowd.animation.play('bop');
}

function onStartCountdown()
{
	var fakeStartTimer = new FlxTimer().start((Conductor.crotchet / 1000) / playbackRate, function(tmr:FlxTimer) {
		if (tmr.loopsLeft % 2 == 0) crowd.animation.play('bop');
		if (tmr.loopsLeft % 1 == 0) speaker.animation.play('bop');
	}, 5);
}
