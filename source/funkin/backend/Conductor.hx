package funkin.backend;

import funkin.data.Song;

typedef BPMChangeEvent =
{
	var bpm:Float;
	var stepTime:Int;
	var songTime:Float;
	var sectionBeats:Int;
	@:optional var stepCrotchet:Float;
}

class Conductor
{
	public static var bpm(default, set):Float = 100;
	
	public static var visualPosition:Float = 0;
	public static var crotchet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrotchet:Float = crotchet / 4; // steps in milliseconds
	public static var songPosition:Float = 0;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;
	
	public static var ROWS_PER_BEAT = 48; // from Stepmania
	public static var BEATS_PER_MEASURE = 4; // TODO: time sigs
	public static var ROWS_PER_MEASURE = ROWS_PER_BEAT * BEATS_PER_MEASURE; // from Stepmania
	public static var MAX_NOTE_ROW = 1 << 30; // from Stepmania
	
	public inline static function beatToRow(beat:Float):Int return Math.round(beat * ROWS_PER_BEAT);
	
	public inline static function rowToBeat(row:Int):Float return row / ROWS_PER_BEAT;
	
	public inline static function secsToRow(sex:Float):Int return Math.round(getBeat(sex) * ROWS_PER_BEAT);
	
	// public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (ClientPrefs.safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	
	public function new() {}
	
	inline public static function beatToNoteRow(beat:Float):Int
	{
		return Math.round(beat * Conductor.ROWS_PER_BEAT);
	}
	
	inline public static function noteRowToBeat(row:Float):Float
	{
		return row / Conductor.ROWS_PER_BEAT;
	}
	
	public static function timeSinceLastBPMChange(time:Float):Float
	{
		var lastChange = getBPMFromSeconds(time);
		return time - lastChange.songTime;
	}
	
	public static function getBeatInMeasure(time:Float):Float
	{
		var lastBPMChange = getBPMFromSeconds(time);
		return (time - lastBPMChange.songTime) / (lastBPMChange.stepCrotchet * 4);
	}
	
	public static function getCrotchetAtTime(time:Float)
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepCrotchet * 4;
	}
	
	public static function getBPMFromSeconds(time:Float)
	{
		var lastChange:BPMChangeEvent = null;
		
		for (change in bpmChangeMap) {
			if (time >= change.songTime || lastChange == null)
				lastChange = change;
		}
		
		return (lastChange ?? {bpm: Conductor.bpm, stepTime: 0, songTime: 0, sectionBeats: 4, stepCrotchet: calculateCrochet(Conductor.bpm) * .25});
	}
	
	public static function getBPMFromStep(step:Float)
	{
		var lastChange:BPMChangeEvent = null;
		
		for (change in bpmChangeMap) {
			if (step >= change.stepTime || lastChange == null)
				lastChange = change;
		}
		
		return (lastChange ?? {bpm: Conductor.bpm, stepTime: 0, songTime: 0, sectionBeats: 4, stepCrotchet: calculateCrochet(Conductor.bpm) * .25});
	}
	
	public static function stepToSeconds(step:Float):Float
	{
		final lastChange = getBPMFromStep(step);
		
		return (lastChange.songTime + (step - lastChange.stepTime) * lastChange.stepCrotchet);
	}
	
	public inline static function beatToSeconds(beat:Float):Float
	{
		return stepToSeconds(beat * 4);
	}
	
	public static function sectionToSeconds(section:Float):Float {
		var curSectionBeats:Int = bpmChangeMap[0].sectionBeats;
		var curBPM:Float = bpmChangeMap[0].bpm;
		
		var lastSection:Float = 0;
		var lastTime:Float = 0;
		var lastStep:Float = 0;
		
		for (change in bpmChangeMap) {
			final beatDiff:Float = ((change.stepTime - lastStep) / 4);
			final nextSection:Float = (lastSection + beatDiff / curSectionBeats);
			
			if (nextSection >= section) break;
			
			lastTime += (beatDiff * calculateCrochet(curBPM));
			lastStep = change.stepTime;
			lastSection = nextSection;
			
			curBPM = change.bpm;
			curSectionBeats = change.sectionBeats;
		}
		
		return ((section - lastSection) * calculateCrochet(curBPM) * curSectionBeats + lastTime);
	}
	
	public static function getStep(time:Float)
	{
		final lastChange = getBPMFromSeconds(time);
		
		return (lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrotchet);
	}
	
	public static function getStepRounded(time:Float)
	{
		return Math.floor(getStep(time));
	}
	
	public static function getBeat(time:Float)
	{
		return getStep(time) / 4;
	}
	
	public inline static function getBeatRounded(time:Float):Int
	{
		return Math.floor(getStepRounded(time) / 4);
	}
	
	public static function getSection(time:Float):Float { // psych's conductor is such a brainfuck
		var curSectionBeats:Int = bpmChangeMap[0].sectionBeats;
		var curBPM:Float = bpmChangeMap[0].bpm;
		
		var lastSection:Float = 0;
		var lastTime:Float = 0;
		
		for (change in bpmChangeMap) {
			if (change.songTime >= time) break;
			
			lastSection += ((change.songTime - lastTime) / calculateCrochet(curBPM * curSectionBeats));
			lastTime = change.songTime;
			
			curBPM = change.bpm;
			curSectionBeats = change.sectionBeats;
		}
		
		return ((time - lastTime) / calculateCrochet(curBPM * curSectionBeats) + lastSection);
	}
	
	public inline static function getSectionRounded(time:Float):Int
	{
		return Math.floor(getSection(time));
	}
	
	public static function mapBPMChanges(?song:Song)
	{
		if (song == null) {
			bpmChangeMap = defaultBPMChangeMap(Conductor.bpm);
			return;
		}
		
		var initialBeats:Int = (song.notes[0]?.sectionBeats ?? 4);
		bpmChangeMap = defaultBPMChangeMap(song.bpm, initialBeats);
		
		var curSectionBeats:Int = initialBeats;
		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			var hasChange:Bool = false;
			var sectionBeats:Int = getSectionBeats(song, i);
			
			if (sectionBeats != curSectionBeats) {
				curSectionBeats = sectionBeats;
				hasChange = true;
			}
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;
				hasChange = true;
			}
			
			if (hasChange) {
				bpmChangeMap.push({
					sectionBeats: curSectionBeats,
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM,
					stepCrotchet: calculateCrochet(curBPM) / 4
				});
			}

			var deltaSteps:Int = (sectionBeats * 4);
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}
	
	public inline static function defaultBPMChangeMap(bpm:Float = 100, sectionBeats:Int = 4):Array<BPMChangeEvent> {
		return [{ // psych mint teehee
			bpm: bpm,
			stepTime: 0,
			songTime: 0,
			sectionBeats: sectionBeats,
			stepCrotchet: calculateCrochet(bpm) * .25
		}];
	}
	
	static function getSectionBeats(song:Song, section:Int):Int
	{
		var val:Null<Int> = null;
		if (song.notes[section] != null) val = song.notes[section].sectionBeats;
		return (val != null ? val : 4);
	}
	
	inline public static function calculateCrochet(bpm:Float)
	{
		return (60000 / bpm);
	}
	
	static function set_bpm(value:Float):Float
	{
		bpm = value;
		crotchet = calculateCrochet(bpm);
		stepCrotchet = crotchet / 4;
		
		return bpm;
	}
}
