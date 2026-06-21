import funkin.states.substates.GameOverSubstate;

import animate.FlxAnimateController;
import animate.FlxAnimateFrames;
import animate.FlxAnimate;

var blackkill:Character;

function onGameOverStart()
{
	 {
		blackkill = new Character(PlayState.instance.gf.getScreenPosition().x, PlayState.instance.gf.getScreenPosition().y, gf.curCharacter);
		blackkill.x += gf.positionArray[0] - PlayState.instance.gf.positionArray[0];
		blackkill.y += gf.positionArray[1] - PlayState.instance.gf.positionArray[1];
		blackkill.skipDance = true;
		blackkill.animation.onFinish.add(function(name:String) {
			blackkill.visible = false;
		});
		blackkill.playAnim('kill');
		GameOverSubstate.instance.add(blackkill);
	}
}

function onCreatePost()
{
	if (curSong == 'Delusion' || curSong == 'Blackout' || curSong == 'Neurotic') {
		crowd.alpha = 0.001;
	}
	if (ClientPrefs.bfSkin == 'noob49player')
	{
		gf.flipX = true;
		if (!stage.getFlag('pixel'))gf.x -= 350;
		if (curSong == 'Don\'t Lied') {
			gf.flipX = false;
			gf.x += 350;
		}
	}
}

var readyToKill = false;

function onUpdatePost()
{
	if (boyfriend.curCharacter != "noob49player")
	{
		if (curSong != 'Don\'t Lied') {
			if (health <= 0.6 && !readyToKill)
			{
				gf.stunned = true;
				readyToKill = true;
				gf.playAnim('raiseKnife', true);
				FlxTimer.wait(1.9, () -> {
					gf.playAnim('idleKnife', true);
				});
			}
			else if (health > 0.6 && readyToKill)
			{
				gf.stunned = false;
				readyToKill = false;
				gf.playAnimForDuration('lowerKnife', 0.3, true);
			}
		}
	}
}
