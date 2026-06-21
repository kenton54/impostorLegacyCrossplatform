function onKeyPress(k:Int):Void
{
	if (k == 2 && parent.getAnimName() == 'idle' && (focusPlayer == null || focusPlayer == parent))
	{
		parent.playAnim('singUP');
		parent.specialAnim = true;
		parent.animCurFrame = 5;
		parent.holding = true;
	}
}
