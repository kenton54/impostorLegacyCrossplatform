import StringTools;
var baseX:Float = boyfriend.scale.x;
var baseY:Float = boyfriend.scale.y;
var scaleTween:FlxTween;
var dragging:Bool = false;
var draggingdad:Bool = false;
var draggingpet:Bool = false;
var dragOffsetX:Float = 0;
var dragOffsetY:Float = 0;

var velX:Float = 0;
var velY:Float = 0;
var lastMX:Float = 0;
var lastMY:Float = 0;
var baseYstage:Float = 0;

function noteMiss()
{
    if (FlxG.random.bool(50))
    {
        PlayState.instance.triggerEventNote("Alt Idle Animation", "boyfriend", "-alt");
    }
    else
    {
        PlayState.instance.triggerEventNote("Alt Idle Animation", "boyfriend", "");
    }
}
function onCreatePost()
{
    boyfriend.origin.set(boyfriend.frameWidth / 2, boyfriend.frameHeight);

    baseYstage = boyfriend.y;
    idleheight = boyfriend.height;
}

function onUpdate(elapsed:Float)
{

    if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(boyfriend))
    {
		boyfriend.animation.play('ou', true);
        boyfriend.specialAnim = true;

        var baseX:Float = boyfriend.scale.x;
        var baseY:Float = boyfriend.scale.y;
        
        if (scaleTween != null) scaleTween.cancel();

        boyfriend.scale.set(baseX * 1.5, baseY * 0.75);

        scaleTween = FlxTween.tween(boyfriend.scale, {x: baseX, y: baseY}, 1, {
            ease: FlxEase.elasticOut
        });

        dragging = true;

        dragOffsetX = boyfriend.x - FlxG.mouse.x;
        dragOffsetY = boyfriend.y - FlxG.mouse.y;
        dragging = true;

        lastMX = FlxG.mouse.x;
        lastMY = FlxG.mouse.y;
    }

    if (dad.curCharacter == "LIMEGREENWEEKINVSIMPOSTOR" && FlxG.mouse.justPressed && FlxG.mouse.overlaps(dad))
    {
        draggingdad = true;

        dragOffsetX = dad.x - FlxG.mouse.x;
        dragOffsetY = dad.y - FlxG.mouse.y;

        if (scaleTween != null) scaleTween.cancel();

        dad.scale.set(1.5, 0.75);

        scaleTween = FlxTween.tween(dad.scale, {x: 1, y: 1}, 1, {
            ease: FlxEase.elasticOut
        });
    }
    if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(pet))
    {
        draggingpet = true;

        dragOffsetX = pet.x - FlxG.mouse.x;
        dragOffsetY = pet.y - FlxG.mouse.y;

        if (scaleTween != null) scaleTween.cancel();

        pet.scale.set(1.5, 0.75);

        scaleTween = FlxTween.tween(pet.scale, {x: 1, y: 1}, 1, {
            ease: FlxEase.elasticOut
        });
    }
    if (FlxG.mouse.justReleased)
    {
        dragging = false;
        draggingdad = false;
        draggingpet = false;
    }

    if (dragging)
    {
        boyfriend.x = FlxG.mouse.x + dragOffsetX;
        boyfriend.y = FlxG.mouse.y + dragOffsetY;
        velX = (FlxG.mouse.x - lastMX) / elapsed;
        velY = (FlxG.mouse.y - lastMY) / elapsed;
        lastMX = FlxG.mouse.x;
        lastMY = FlxG.mouse.y;

        if (!FlxG.mouse.pressed)
        {
            dragging = false;
        }
    }
    else
    {
        var floorY:Float = baseYstage;

        velY += 3200 * elapsed;
        boyfriend.x += velX * elapsed;
        boyfriend.y += velY * elapsed;
        var leftWall:Float = -900;
        var rightWall:Float = 2000;

        if (boyfriend.x < leftWall)
        {
            boyfriend.x = leftWall;
            velX *= -0.8;
        }
        if (boyfriend.x > rightWall)
        {
            boyfriend.x = rightWall;
            velX *= -0.8;
        }

        velX *= 1;
        velY *= 1;
        if (boyfriend.y > floorY)
        {
            boyfriend.y = floorY;
            velY *= -0.75;
            velX *= 0.95;
        }
    }

    if (draggingdad)
    {
        dad.x = FlxG.mouse.x + dragOffsetX;
        dad.y = FlxG.mouse.y + dragOffsetY;
    }

    if (draggingpet)
    {
        pet.x = FlxG.mouse.x + dragOffsetX;
        pet.y = FlxG.mouse.y + dragOffsetY;
    }

    if (FlxG.mouse.justPressedRight && FlxG.mouse.overlaps(boyfriend))
    {
		boyfriend.animation.play('ou', true);
        boyfriend.specialAnim = true;

        var baseX:Float = boyfriend.scale.x;
        var baseY:Float = boyfriend.scale.y;
        
        if (scaleTween != null) scaleTween.cancel();

        boyfriend.scale.set(baseX * 1.5, baseY * 0.75);

        scaleTween = FlxTween.tween(boyfriend.scale, {x: baseX, y: baseY}, 1, {
            ease: FlxEase.elasticOut
        });
        boyfriend.flipX = !boyfriend.flipX;
    }

    if (dad.curCharacter == "LIMEGREENWEEKINVSIMPOSTOR" && FlxG.mouse.justPressedRight && FlxG.mouse.overlaps(dad))
    {
        var baseX:Float = dad.scale.x;
        var baseY:Float = dad.scale.y;
        
        if (scaleTween != null) scaleTween.cancel();

        dad.scale.set(1.5, 0.75);

        scaleTween = FlxTween.tween(dad.scale, {x: 1, y: 1}, 1, {
            ease: FlxEase.elasticOut
        });
        dad.flipX = !dad.flipX;
    }
}