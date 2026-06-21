var ext:String = 'stages/freeplay/roomcode/';
var fakenenebox:FlxSprite;
public var fakenenebox:FlxSprite;

function onLoad()
{
	var bg:FlxSprite = new FlxSprite(-1119.5, -649).loadGraphic(Paths.image(ext + "roomcodebg"));
	add(bg);
	
	var bg2:FlxSprite = new FlxSprite(-74.65, 530.85).loadGraphic(Paths.image(ext + "box"));
	add(bg2);
}

function onCreatePost()
{
	snapCamToPos(750, 580);
	camSpecialThing([500, 580], [1000, 580]);
}

function onEvent(name, v1, v2)
{
	switch (name)
	{
		case 'Legacy':
			switch (v1)
			{
				case 'powers':
					isCameraOnForcedPos = true;
					snapCamToPos(500, 600);
				case 'pico':
					isCameraOnForcedPos = true;
					snapCamToPos(1000, 600);
				case 'nene':
					isCameraOnForcedPos = true;
					snapCamToPos(750, 500);
				case 'normal':
					isCameraOnForcedPos = false;
			}
	}
}
