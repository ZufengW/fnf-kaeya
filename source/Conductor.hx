package;

import Song.BeatEvent;
import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Int;
}

class Conductor
{
	public static var bpm:Int = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	/** How much of the song has played, in ms. **/
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	/** List of all the beats in the song. Ordered by time. If provided, beat
		timing won't be determined by bpm. **/
	public static var beatList:Array<BeatEvent> = [];

	public function new()
	{
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);

		// Not all songs have a beat list.
		beatList = [];
		if (song.beats != null)
		{
			beatList = song.beats.map((b) -> {
				return {
					songTime: b[0],
					kind: Std.int(b[1]),
				};
			});
		}
	}

	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	/** Get the duration in ms of a crochet at the start of the song. If the
		song does not have a beatList, returns the duration of a regular
		crochet. **/
	public static function getFirstBeatCrochetMs(): Float
	{
		if (beatList.length < 2) return crochet;
		return beatList[1].songTime - beatList[0].songTime;
	}

	/** Get the position of the zero beat (in ms after the start of the song).
		The final beat of the countdown should land here. And the song's first
		beat comes after. Can be negative. **/
	public static function getZeroBeatCrochetMs(): Float
	{
		if (beatList.length < 1) return 0;
		return beatList[0].songTime - getFirstBeatCrochetMs();
	}
}
