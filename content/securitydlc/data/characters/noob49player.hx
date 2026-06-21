function onCreatePost()
{
	var petScale:FlxPoint = new flixel.math.FlxBasePoint(pet.scale.x, pet.scale.y);
	
	if (hasPet)
	{
		pet.loadPet('greypet');
	}
	else
	{
		iconP1.changeIcon('noob49alone');
	}
	
	if (stage.getFlag('pixel')) {
		if (hasGfSkin)
		{
			pet.scale.set(petScale.x, petScale.y);
			pet.updateHitbox();
		}
		else
		{
			iconP1.changeIcon('noob49alone');
		}
	}

	if (stage.getFlag('pixel')){
		boyfriend.setPosition(600,-180);
	}

	if (curSong == 'Identity Crisis')
	{
		copyPet.loadPet('greypet');
	}
	if (curSong == 'Delusion' || curSong == 'Blackout' || curSong == 'Neurotic')
	{
		changeCharacter('noob49dark', 0);
		iconP1.changeIcon('noob49alone');
		
		if (FlxG.random.bool()) // 50%/50% easter egg
		{
			changeCharacter('minigreyopscary', 1);
			pet.alpha = 0.001;
			dad.x = 900;
			dad.y = 680;
		}
		else
		{
			pet.alpha = 0.001;
		}
	}
	if (curSong == 'Danger' && hasPet)
	{
		petBoard.visible = true;
	}
	if (curSong == 'Triple Threat' || curSong == 'Turbulence' || gf.curCharacter == "triplespeaker")
	{
		pet.alpha = 0.001;
		iconP1.changeIcon('noob49alone');
	}
	if (curSong == 'Pinkwave' || curSong == 'Heartbeat')
	{
		greymira.alpha = 0.001;
	}
	if (curSong == 'Sauces Moogus')
	{
		gray.alpha = 0.001;
	}
}
