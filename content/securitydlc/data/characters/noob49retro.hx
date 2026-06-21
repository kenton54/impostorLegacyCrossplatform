function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'Defeat Retro':
			var charType:Int = Std.parseInt(value1);
			if (Math.isNaN(charType)) charType = 0;
			switch (charType)
			{
				case 1:
					triggerEventNote('Change Character', '0', 'noob49dark');
			}
	}
}