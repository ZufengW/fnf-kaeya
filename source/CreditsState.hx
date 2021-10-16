package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class CreditsState extends MusicBeatState {
	final lineData:Array<String> = [
		"Original FNF by ninjamuffin99, PhantomArcade, evilsk8r, and Kawaisprite",
		"Genshin art by Kurxmi",
		"Genshin songs composed by Yu-Peng Chen",
		"Genshin song charts and additional code by Inkplane",
	];

	/** The target y position of each line item. **/
	var lineTargetY:Array<Float> = [];

	/** The current selected line. **/
	var curLine:Int = 0;

	var grpLineText:FlxTypedGroup<FlxText>;
	var grpCharacters:FlxTypedGroup<MenuCharacter>;

	override function create() {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null) {
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		final RECT_OFFSET_V = 56;
		final RECT_HEIGHT = FlxG.height - RECT_OFFSET_V * 2;
		var yellowBG:FlxSprite = new FlxSprite(0, RECT_OFFSET_V)
			.makeGraphic(FlxG.width, RECT_HEIGHT, 0xFFF9CF51);
		var blackBG:FlxSprite = new FlxSprite(FlxG.width * 0.175, RECT_OFFSET_V)
			.makeGraphic(Std.int(FlxG.width * 0.65), RECT_HEIGHT, 0xFF000000);

		grpLineText = new FlxTypedGroup<FlxText>();
		grpCharacters = new FlxTypedGroup<MenuCharacter>();

		for (i in 0...lineData.length) {
			var lineText:FlxText = new FlxText(0, yellowBG.y + yellowBG.height + 10, FlxG.width * 0.6, lineData[i]);
			lineText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
			lineText.y += ((lineText.height + 20) * i);
			lineTargetY.push(i);
			grpLineText.add(lineText);

			lineText.screenCenter(X);
			lineText.antialiasing = true;
		}

		// Add dad on the left.  Vertically centered.
		var weekCharacterLeft:MenuCharacter = new MenuCharacter(0, 'dad');
		weekCharacterLeft.y += (FlxG.height * 0.5) - weekCharacterLeft.height * 0.25;
		weekCharacterLeft.antialiasing = true;
		weekCharacterLeft.setGraphicSize(Std.int(weekCharacterLeft.width * 0.5));
		weekCharacterLeft.updateHitbox();
		grpCharacters.add(weekCharacterLeft);
		// Add mom on the right. Vertically centered.
		var weekCharacterRight:MenuCharacter = new MenuCharacter(FlxG.width, 'mom');
		weekCharacterRight.y += (FlxG.height * 0.5) - weekCharacterRight.height * 0.25;
		weekCharacterRight.x -= weekCharacterRight.width * 0.5;
		weekCharacterRight.antialiasing = true;
		weekCharacterRight.setGraphicSize(Std.int(weekCharacterRight.width * 0.5));
		weekCharacterRight.updateHitbox();
		grpCharacters.add(weekCharacterRight);

		// Order matters. Bottom to top.
		add(yellowBG);
		add(grpCharacters);
		add(blackBG);
		add(grpLineText);

		// Update the initial state of the lines.
		changeLine();

		super.create();
	}

	override function update(elapsed:Float) {
		if (!movedBack) {
			if (controls.UP_P) {
				changeLine(-1);
			}

			if (controls.DOWN_P) {
				changeLine(1);
			}
		}

		if (controls.BACK && !movedBack) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		for (i in 0...lineData.length) {
			var y = grpLineText.members[i].y;
			// Copied from MenuItem.hx.
			grpLineText.members[i].y = FlxMath.lerp(y, (lineTargetY[i] * 120) + 80, 0.17);
		}

		super.update(elapsed);
	}

	/** Whether or not we're moving back to the previous menu. To prevent
		duplicate actions.
	**/
	var movedBack:Bool = false;

	/** Change the line number. Relative diff. **/
	function changeLine(change:Int = 0):Void {
		curLine += change;

		if (curLine >= lineData.length) {
			curLine = 0;
		} if (curLine < 0) {
			curLine = lineData.length - 1;
		}

		for (i in 0...lineData.length) {
			lineTargetY[i] = i - curLine;

			if (lineTargetY[i] == Std.int(0))
				grpLineText.members[i].alpha = 1;
			else
				grpLineText.members[i].alpha = 0.6;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
