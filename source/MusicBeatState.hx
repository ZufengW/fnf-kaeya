package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

/** Songs with a beatList will specify whether each beat is Minor or Major. **/
enum BeatKind {
	/**
		Use this for the existing songs without a beatList. Whether the beat is
		minor or major depends on the beat number.
	**/
	Default;
	/** No zoom effect. **/
	Minor;
	/** Do a zoom effect on major beats. **/
	Major;
}

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	/** Also used as the index of the next beat to play in the beatList. **/
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// Custom logic for songs with a beatList.
		if (Conductor.beatList.length > 0)
		{
			// Get the songtime of next beat and the previous beat.
			var prevBeatTimeMs:Float = 0;
			var nextBeatTimeMs:Float = 0;
			var nextBeatKind:BeatKind = Minor;

			if (curBeat >= Conductor.beatList.length)
			{
				// Current beat exceeds the end of the list. Extrapolate using
				// the time difference between the final two beats.
				final len = Conductor.beatList.length;
				if (len < 2) throw 'BeatList len too short: ${len}';
				final endBeatTimeMs = Conductor.beatList[len - 1].songTime;
				final diffMs = endBeatTimeMs - Conductor.beatList[len - 2].songTime;
				prevBeatTimeMs = endBeatTimeMs + (curBeat - len) * diffMs;
				nextBeatTimeMs = prevBeatTimeMs + diffMs;
			}
			else
			{
				final beatEvent = Conductor.beatList[curBeat];
				nextBeatTimeMs = beatEvent.songTime;
				if (beatEvent.kind == 0) nextBeatKind = Minor;
				else nextBeatKind = Major;

				if (curBeat > 0)
				{
					prevBeatTimeMs = Conductor.beatList[curBeat - 1].songTime;
				}
			}
			// Divide the time diff between the next and prev beat into
			// quarters. These are the steps.
			final quarter = curStep - (4 * curBeat);
			final nextStepTimeMs = FlxMath.lerp(prevBeatTimeMs, nextBeatTimeMs, quarter * 0.25);

			if (Conductor.songPosition >= nextStepTimeMs)
			{
				stepHit(nextBeatKind);
				if (quarter == 0)
				{
					beatHit(nextBeatKind);
					curBeat++;
				}
				curStep++;
			}

			super.update(elapsed);
			return;
		}

		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit(Default);

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit(kind:BeatKind):Void
	{
		// Default steps perform a beatHit every 4 steps.
		if (kind == Default && curStep % 4 == 0) beatHit(kind);
	}

	public function beatHit(kind:BeatKind):Void
	{
		//do literally nothing dumbass
	}
}
