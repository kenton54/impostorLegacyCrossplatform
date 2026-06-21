var ext = 'stages/dlc/security/';
public var player:FlxSprite;
public var loBlack:FlxSprite;
public var discuss:FlxSprite;

function onLoad()
{
	var bg:FlxSprite = new FlxSprite(-550, -270).loadGraphic(Paths.image(ext + 'wall'));
	add(bg);

	var cabinets:FlxSprite = new FlxSprite(-552, -140).loadGraphic(Paths.image(ext + 'cabinets'));
	cabinets.scrollFactor.set(0.95,1);
	add(cabinets);
	
	//shit = new FlxSprite(350, 480).loadGraphic(Paths.image(ext + 'deadshit'));
	//shit.scrollFactor.set(0.98,1);
	//add(shit); //removed because it looked bad behind noob49
	
	tawny = new FlxSprite(-130, 400).loadGraphic(Paths.image(ext + 'deadtawny'));
	tawny.scrollFactor.set(0.93,1);
	add(tawny);

	var props:FlxSprite = new FlxSprite(180,20).loadGraphic(Paths.image(ext + 'props'));
	props.scrollFactor.set(0.98,1);
	add(props);

	var table:FlxSprite = new FlxSprite(35, 210).loadGraphic(Paths.image(ext + 'table'));
	table.scrollFactor.set(0.97,1);
	add(table);

	var substract:FlxSprite = new FlxSprite(-550, -270).loadGraphic(Paths.image(ext + 'substract'));
	substract.blend = BlendMode.SUBTRACT;
	substract.scrollFactor.set(0,0);
	substract.alpha = 0.4;
	add(substract);
}

function onCreatePost()
{
	snapCamToPos(800, 450);
	camSpecialThing([650, 450], [700, 450]);

	player = new FlxSprite(-900, 400);
	player.frames = Paths.getSparrowAtlas(ext + 'player');
	player.animation.addByPrefix('bop', 'playerguy', 24, false);
	player.zIndex = 2;
	add(player);

	var vignette:FlxSprite = new FlxSprite(-550, -270).loadGraphic(Paths.image(ext + 'vignette'));
	vignette.scrollFactor.set(0,0);
	vignette.zIndex = 3;
	add(vignette);

//checks if the user doesnt have low quality option on
	if (!ClientPrefs.lowQuality) { 
		var mist4 = new flixel.addons.display.FlxBackdrop(Paths.image(ext + 'mistBack'), FlxAxes.X);
		mist4.scrollFactor.set(0.8, 0.8);
		mist4.color = 0xFF5c5c5c;
		mist4.alpha = 1;
		mist4.velocity.x = 15;
		mist4.scale.set(2,0.9);
		mist4.blend = BlendMode.SCREEN;
		mist4.zIndex = 3;
		add(mist4);

		var mist5 = new flixel.addons.display.FlxBackdrop(Paths.image(ext + 'mistMid'), FlxAxes.X);
		mist5.scrollFactor.set(0.5, 0.5);
		mist5.color = 0xFF5c5c5c;
		mist5.alpha = 1;
		mist5.scale.set(2,0.9);
		mist5.velocity.x = -15;
		mist5.blend = BlendMode.SCREEN;
		mist5.zIndex = 3;
		add(mist5);
		
		mist4.y = mist5.y = -270;
	}

	loBlack = new FlxSprite().makeGraphic(FlxG.width * 4, FlxG.height + 700, FlxColor.BLACK);
	loBlack.alpha = 0.001;
	loBlack.screenCenter();
	loBlack.zIndex = 3;
	add(loBlack);

	discuss = new FlxSprite(350,90).loadGraphic(Paths.image(ext + 'discuss'));
	discuss.alpha = 0.001;
	discuss.scrollFactor.set(0,0);
	discuss.zIndex = 3;
	add(discuss);

	refreshZ();
}
function onEvent(name, v1, v2)
{
	switch (name)
	{
		case 'Legacy':
			switch (v1)
			{
				case 'detective':
					isCameraOnForcedPos = true;
					snapCamToPos(500, 450);
				case 'pico':
					isCameraOnForcedPos = true;
					snapCamToPos(850, 450);
				case 'normal':
					isCameraOnForcedPos = false;
			}
	}
}