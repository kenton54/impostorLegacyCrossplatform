function onKeyPress(k:Int):Void
{
	if (k == 0 && boyfriend.curCharacter == 'evilbfold' && (focusPlayer == null || focusPlayer == parent))
	{
		boyfriend.playAnim('wow');
		boyfriend.specialAnim = true;
		boyfriend.holding = true;
	}
}