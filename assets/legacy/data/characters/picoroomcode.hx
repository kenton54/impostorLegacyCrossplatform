import funkin.states.substates.GameOverSubstate;

import animate.FlxAnimateController;
import animate.FlxAnimateFrames;
import animate.FlxAnimate;

var nene:Character;
var retry:FlxAnimate;

function onGameOverStart()
{
	if (gf.getFlag('knifenene')) {
		nene = new Character(PlayState.instance.gf.getScreenPosition().x, PlayState.instance.gf.getScreenPosition().y, gf.curCharacter);
		nene.x += gf.positionArray[0] - PlayState.instance.gf.positionArray[0];
		nene.y += gf.positionArray[1] - PlayState.instance.gf.positionArray[1];
		nene.skipDance = true;
		nene.animation.onFinish.add(function(name:String) {
			nene.visible = false;
		});
		nene.playAnim('kill');
		GameOverSubstate.instance.add(nene);
	}
	
	retry = new FlxAnimate(boyfriend.getScreenPosition().x + 312.25, boyfriend.getScreenPosition().y - 1.5);
	retry.frames = Paths.getSparrowAtlas("characters/gameover/Pico_Death_Assets");
	retry.animation.addByPrefix('idle', "retry loop0", 24, true);
	retry.animation.addByPrefix('confirm', "retry confirm0", 24, false);
	retry.visible = false;
}

function onGameOverPost()
{
	GameOverSubstate.instance.add(retry);
	GameOverSubstate.instance.boyfriend.animation.onFrameChange.add((animName, frameNumber, frameIndex) -> {
		if (animName == 'firstDeath' && frameNumber == 36)
		{
			retry.visible = true;
			retry.animation.play('idle');
		}
	});
}

function onGameOverConfirm()
{
	retry.animation.play('confirm');
	retry.x -= 250;
	retry.y -= 200;
}
