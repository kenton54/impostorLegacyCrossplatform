package funkin.objects.menu;

import flixel.util.FlxStringUtil;
import flixel.group.FlxSpriteGroup;

import funkin.data.CosmicubeData;

class BeansPopup extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;
	
	var alphaTween:FlxTween;
	var bean:FlxSprite;
	var text:FlxText;
	var lerpScore:Int = 0;
	var canLerp:Bool = false;
	var anchorX:Float;
	var anchorY:Float;
	
	public function new(amount:Int, currency:String = 'beans')
	{
		super();
		
		amount = FlxMath.maxInt(0, amount); // no more negative money. im sorry.
		
		y -= 100;
		lerpScore = amount;
		
		if (currency.length == 0) // no cosmicube acitve
		{
			new FlxTimer().start(0, function(_) if (onFinish != null) onFinish());
			kill();
			
			return;
		}
		
		CosmicubeData.setMoney(currency, CosmicubeData.getMoney(currency) + amount);
		ClientPrefs.flush();
		
		anchorX = FlxG.width - 150;
		anchorY = 50;
		
		bean = new FlxSprite(0, 0).loadGraphic(Paths.image('currency/$currency', LOOSE));
		bean.antialiasing = ClientPrefs.globalAntialiasing;
		bean.updateHitbox();
		bean.scrollFactor.set();
		add(bean);
		
		text = new FlxText(0, 0, 200, Std.string(amount), 35);
		text.setFormat(Paths.font('ariblk.ttf'), 35, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.updateHitbox();
		text.borderSize = 3;
		text.scrollFactor.set();
		text.antialiasing = ClientPrefs.globalAntialiasing;
		add(text);
		
		reposition();
		
		FlxTween.tween(this, {y: 0}, 0.35, {ease: FlxEase.circOut});
		
		new FlxTimer().start(0.9, function(_) {
			canLerp = true;
			FlxTween.color(bean, 0.8, 0xFF7CFFBA, FlxColor.WHITE, {ease: FlxEase.expoOut});
			FlxTween.color(text, 0.8, 0xFF7CFFBA, FlxColor.WHITE, {ease: FlxEase.expoOut});
			
			if (amount > 0)
			{
				var soundPath:String = (Paths.fileExists('sounds/get$currency.ogg', LOOSE) || Paths.fileExists('sounds/get$currency.wav', LOOSE) ? 'get$currency' : 'getbeans');
				FlxG.sound.play(Paths.sound(soundPath, LOOSE), 0.9);
			}
		});
		
		alpha = 0;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5,
			{
				onComplete: function(_) {
					alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5,
						{
							startDelay: 2.5,
							onComplete: function(_) {
								alphaTween = null;
								kill();
								if (onFinish != null) onFinish();
							}
						});
				}
			});
	}
	
	override function update(elapsed:Float)
	{	
		super.update(elapsed);
		
		if (canLerp)
		{
			lerpScore = Math.floor(FlxMath.lerp(lerpScore, 0, FlxMath.bound(elapsed * 4, 0, 1) / 1.5));
			if (Math.abs(lerpScore) < 10) lerpScore = 0;
		}
		
		text.text = Std.string(FlxStringUtil.formatMoney(lerpScore, false));
		reposition();
	}
	
	function reposition():Void
	{
		bean.setPosition(anchorX - 90, anchorY - (bean.height / 2));
		text.setPosition(anchorX - 10, anchorY - (text.height / 2));
	}
	
	override function destroy():Void
	{
		if (alphaTween != null) alphaTween.cancel();
		
		super.destroy();
	}
}
