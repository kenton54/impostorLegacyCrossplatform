package funkin.objects.menu;

import flixel.group.FlxSpriteGroup;

import funkin.data.GameFlags;
import funkin.data.Lang;

class AwardPopup extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;
	
	// just doing this everywhere hopefully it all looks good ok friends
	static final NAME_TEXT_BASE_SIZE:Int = 27;
	static final NAME_TEXT_MIN_SIZE:Int = 14;
	static final DESC_TEXT_BASE_SIZE:Int = 20;
	static final DESC_TEXT_MIN_SIZE:Int = 12;
	static final DESC_TEXT_MAX_HEIGHT:Int = 50;
	
	var alphaTween:FlxTween;
	var bg:FlxSprite;
	var icon:FlxSprite;
	var nameText:FlxText;
	var descText:FlxText;
	var anchorX:Float;
	var anchorY:Float;
	
	public static var activeCount:Int = 0;
	
	public function new(id:String, playSound:Bool = true)
	{
		super();
		
		y += 120;
		anchorX = FlxG.width - 430;
		anchorY = FlxG.height - 110 - (activeCount * 115);
		activeCount++;
		
		bg = new FlxSprite(0, 0).makeGraphic(410, 100, 0xAA000000);
		bg.scrollFactor.set();
		add(bg);
		
		var iconName:String = GameFlags.getAchievementIcon(id);
		if (!Paths.fileExists('images/awards/$iconName.png', LOOSE)) iconName = 'blank';
		icon = new FlxSprite(0, 0);
		icon.loadGraphic(Paths.image('awards/$iconName', LOOSE));
		icon.antialiasing = ClientPrefs.globalAntialiasing;
		icon.scrollFactor.set();
		icon.setGraphicSize(75, 75);
		icon.updateHitbox();
		add(icon);
		
		nameText = new FlxText(0, 0, 300, Lang.str('AWARDNAME_$id', 'Award Unlocked'), 27);
		nameText.setFormat(Paths.font('vcr.ttf'), NAME_TEXT_BASE_SIZE, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nameText.borderSize = 2;
		nameText.antialiasing = ClientPrefs.globalAntialiasing;
		nameText.scrollFactor.set();
		fitNameText();
		add(nameText);
		
		descText = new FlxText(0, 0, 300, Lang.str('AWARDBIO_$id', ''), 20);
		descText.setFormat(Paths.font('vcr.ttf'), DESC_TEXT_BASE_SIZE, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;
		descText.antialiasing = ClientPrefs.globalAntialiasing;
		descText.scrollFactor.set();
		fitDescText();
		add(descText);
		
		reposition();
		
		alpha = 0;
		FlxTween.tween(this, {y: 0}, 0.35, {ease: FlxEase.circOut});
		if (playSound) FlxG.sound.play(Paths.sound('confirmMenu'), 0.8);
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.2,
			{
				onComplete: function(_) {
					alphaTween = FlxTween.tween(this, {alpha: 0}, 0.35,
						{
							startDelay: 3.3,
							onComplete: function(_) {
								alphaTween = null;
								activeCount = Std.int(Math.max(0, activeCount - 1));
								kill();
								if (onFinish != null) onFinish();
							}
						});
				}
			});
	}
	
	function fitNameText():Void
	{
		var size:Int = NAME_TEXT_BASE_SIZE;
		nameText.setFormat(Paths.font('vcr.ttf'), size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nameText.borderSize = 2;
		nameText.textField.wordWrap = false;
		nameText.textField.multiline = false;
		
		while (size > NAME_TEXT_MIN_SIZE && nameText.textField.textWidth > nameText.fieldWidth)
		{
			size--;
			nameText.setFormat(Paths.font('vcr.ttf'), size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			nameText.borderSize = 2;
			nameText.textField.wordWrap = false;
			nameText.textField.multiline = false;
		}
	}
	
	function fitDescText():Void
	{
		var size:Int = DESC_TEXT_BASE_SIZE;
		descText.setFormat(Paths.font('vcr.ttf'), size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;
		descText.textField.wordWrap = true;
		descText.textField.multiline = true;
		
		while (size > DESC_TEXT_MIN_SIZE && descText.textField.textHeight > DESC_TEXT_MAX_HEIGHT)
		{
			size--;
			descText.setFormat(Paths.font('vcr.ttf'), size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			descText.borderSize = 2;
			descText.textField.wordWrap = true;
			descText.textField.multiline = true;
		}
	}
	
	function reposition():Void
	{
		bg.setPosition(anchorX, anchorY);
		icon.setPosition(anchorX + 8, anchorY + 7);
		nameText.setPosition(anchorX + 92, anchorY + 6);
		descText.setPosition(anchorX + 92, anchorY + 42);
	}
	
	override function destroy():Void
	{
		if (alphaTween != null)
		{
			alphaTween.cancel();
			activeCount = Std.int(Math.max(0, activeCount - 1));
		}
		super.destroy();
	}
}
