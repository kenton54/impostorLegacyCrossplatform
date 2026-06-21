function onCreatePost()
{// pico and nene skin support
	var picoSkin:Null<String> = ClientPrefs.equipment.get('picoSkin');
	var neneSkin:Null<String> = ClientPrefs.equipment.get('neneSkin');
	
	if (!PlayState.isStoryMode && picoSkin != null) changeCharacter(picoSkin, 0);
	if (!PlayState.isStoryMode && neneSkin != null) changeCharacter(neneSkin, 2);
}
