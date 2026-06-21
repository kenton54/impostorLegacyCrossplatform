import flixel.FlxSprite;

public var charlesSpeed:Float = (ClientPrefs.flashing ? 1.3 : .8);

var back:FlxSprite, sky:FlxSprite;
var maskShader = newShader('charlesCloudMask'), maskOffset:Array<Float>;

function onLoad()
{
	back = new FlxSprite(0, 0, Paths.image('characters/henry/charles/charlesBg'));
	back.scale.set(parent.scale.x, parent.scale.y);
	back.updateHitbox();
	
	sky = new FlxSprite(0, 0, Paths.image('characters/henry/charles/charlesBgBack'));
	sky.scale.set(parent.scale.x, parent.scale.y);
	sky.updateHitbox();
	sky.screenCenter();
	sky.shader = maskShader;
	
	dadGroup.insert(0, back);
	dadGroup.insert(0, sky);
	
	var bmp = Paths.image('characters/henry/charles/skyClouds');
	maskShader.setBitmapData('u_mask', bmp.bitmap);
	maskShader.setFloatArray('u_mask_size', [bmp.width, bmp.height]);
	maskShader.setFloatArray('u_mask_offset', [0, -.45]);
	maskOffset = maskShader.data.u_mask_offset;
}

function onUpdatePost(elapsed)
{
	maskOffset.value[0] += (charlesSpeed * elapsed);
	
	back.setPosition(parent.x - 120, parent.y - 47);
	sky.setPosition(parent.x + 75, parent.y - 34);
}
