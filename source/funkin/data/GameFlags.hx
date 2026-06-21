package funkin.data;

import funkin.data.ClientPrefs;
import funkin.states.StoryMenuState;
import funkin.utils.ProgressionUtil;

typedef AwardEntry =
{
	var id:String;
	var icon:String;
	var title:String;
	var hint:String;
	var desc:String;
	var hidden:Bool;
	var songs:Array<String>;
	var weeks:Array<String>;
};

class GameFlags
{
	static var cachedAwards:Array<AwardEntry> = null;
	
	/**
		game flags menu
		used for saving information that could probably be moved to
		funkin/data/clientprefs.hx for optimization
	**/
	public static function hasAchievement(id:String)
	{
		return ClientPrefs.achievements.contains(id);
	}
	
	public static function giveAchievement(id:String):Bool
	{
		if (hasAchievement(id)) return false;
		
		ClientPrefs.achievements.push(id);
		ClientPrefs.flush();
		trace('Unlocked achievement: $id');
		return true;
	}
	
	public static function getAchievementIcon(id:String):String
	{
		for (award in getAwards())
		{
			if (award.id == id) return award.icon;
		}
		
		return id;
	}
	
	public static function getAwards(forceReload:Bool = false):Array<AwardEntry>
	{
		if (cachedAwards != null && !forceReload) return cachedAwards;
		
		cachedAwards = [];
		
		final path = Paths.getPath('data/awards.json', NORMAL);
		if (!FunkinAssets.exists(path, TEXT)) return cachedAwards;
		
		final jsonData:Dynamic = FunkinAssets.parseJson(FunkinAssets.getContent(path));
		if (jsonData == null) return cachedAwards;
		
		final entries:Array<Dynamic> = cast Reflect.field(jsonData, 'awards');
		if (entries == null) return cachedAwards;
		
		for (i in 0...entries.length)
		{
			final raw:Dynamic = entries[i];
			if (raw == null) continue;
			
			var id:String = Reflect.field(raw, 'id');
			if (id == null || id.trim().length == 0) id = Reflect.field(raw, 'img');
			if (id == null || id.trim().length == 0) id = Paths.sanitize(Std.string(Reflect.field(raw, 'name') ?? 'award_$i').toLowerCase());
			
			var icon:String = Reflect.field(raw, 'img');
			if (icon == null || icon.trim().length == 0) icon = id;
			
			var title:String = Reflect.field(raw, 'name');
			if (title == null) title = id;
			
			var hint:String = Reflect.field(raw, 'hint');
			if (hint == null) hint = '';
			
			var desc:String = Reflect.field(raw, 'desc');
			if (desc == null) desc = '';
			
			final songs = parseCSV(Reflect.field(raw, 'songs') ?? Reflect.field(raw, 'song'), true);
			final weeks = parseCSV(Reflect.field(raw, 'weeks') ?? Reflect.field(raw, 'week'), false);
			
			cachedAwards.push(
				{
					id: id,
					icon: icon,
					title: title,
					hint: hint,
					desc: desc,
					hidden: (Reflect.field(raw, 'hidden') == true),
					songs: songs,
					weeks: weeks
				});
		}
		
		return cachedAwards;
	}
	
	public static function unlockAwardsFromJson(?currentSong:String = null, ?extraCompletedWeeks:Array<String> = null):Array<String>
	{
		final unlocked:Array<String> = [];
		final songId = currentSong != null ? Paths.sanitize(currentSong.toLowerCase()) : '';
		
		for (award in getAwards())
		{
			if (hasAchievement(award.id)) continue;
			
			final hasSongRule = award.songs.length > 0;
			final hasWeekRule = award.weeks.length > 0;
			if (!hasSongRule && !hasWeekRule) continue;
			
			var songsMet:Bool = true;
			if (hasSongRule)
			{
				for (song in award.songs)
				{
					if (songId == song) continue;
					if (Highscore.getScore(song, 1) <= 0)
					{
						songsMet = false;
						break;
					}
				}
			}
			
			var weeksMet:Bool = true;
			if (hasWeekRule)
			{
				for (week in award.weeks)
				{
					if (StoryMenuState.weekCompleted.exists(week) && StoryMenuState.weekCompleted.get(week)) continue;
					
					if (extraCompletedWeeks != null && extraCompletedWeeks.contains(week)) continue;
					
					weeksMet = false;
					break;
				}
			}
			
			if (songsMet && weeksMet && giveAchievement(award.id)) unlocked.push(award.id);
		}
		
		return unlocked;
	}
	
	static function parseCSV(raw:Dynamic, sanitizeSongName:Bool):Array<String>
	{
		final values:Array<String> = [];
		if (raw == null) return values;
		
		for (entry in Std.string(raw).split(','))
		{
			var trimmed = entry.trim();
			if (trimmed.length == 0) continue;
			if (sanitizeSongName) trimmed = Paths.sanitize(trimmed.toLowerCase());
			if (!values.contains(trimmed)) values.push(trimmed);
		}
		
		return values;
	}
	
	public static function hasFlag(id:String)
	{
		return ClientPrefs.tidbits.contains(id);
	}
	
	public static function giveFlag(id:String)
	{
		if (hasFlag(id)) return;
		
		ClientPrefs.tidbits.push(id);
		ClientPrefs.flush();
		trace('Added flag: $id');
	}
}
