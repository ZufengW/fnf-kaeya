package;

import Controls.Control;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ControlsSubState extends MusicBeatSubstate {
	/** Current selected menu item. **/
	var curSelected:Int = 0;

	/** The control to set next. Null means the Reset All button. **/
	var curSelectedControl:Null<Control> = LEFT;

	/** True means waiting for the user to pick a key. **/
	var isSettingControl:Bool = false;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	var headingText:FlxText;

	private static final TEXT_MARGIN_LEFT_PX = 20;

	public function new() {
		super();

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		headingText = new FlxText(TEXT_MARGIN_LEFT_PX, 20, 0, 'Configure controls', 42);
		add(headingText);

		for (i in 0...Controls.CUSTOMIZABLE_CONTROLS.length + 1) {
			final message = i == Controls.CUSTOMIZABLE_CONTROLS.length
				? 'Reset all to default'
				: get_controls().getCustomControlNameAndKey(Controls.CUSTOMIZABLE_CONTROLS[i]);

			final optionText:FlxText = new FlxText(TEXT_MARGIN_LEFT_PX,
					76 + (i * 50), 0, message, 32);
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}
	}

	/** Call this after a keybinding changes. **/
	private function updateControlsText() {
		final overlappingControls = get_controls().getOverlappingControls();

		for (i in 0...Controls.CUSTOMIZABLE_CONTROLS.length) {
			for (text in grpOptionsTexts) {
				if (text.ID >= Controls.CUSTOMIZABLE_CONTROLS.length) continue;
				final control = Controls.CUSTOMIZABLE_CONTROLS[text.ID];
				final overlapWarning = overlappingControls.contains(control)
					? '  (!)' : '';
				text.text = get_controls().getCustomControlNameAndKey(control)
					+ overlapWarning;
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (isSettingControl) {
			if (controls.BACK) {
				isSettingControl = false;
				return;
			}
			if (FlxG.keys.anyJustPressed([ANY]) && FlxG.keys.getIsDown().length > 0) {
				final result = get_controls().setCustomControlKey(
						curSelectedControl, FlxG.keys.getIsDown()[0].ID);
				if (!result) {
					headingText.text = 'Reserved key. Press a different key';
					return;
				}
				isSettingControl = false;
				updateControlsText();
				return;
			}
			return;
		}

		if (controls.ACCEPT) {
			if (!isSettingControl) {
				if (curSelectedControl != null) {
					isSettingControl = true;
					headingText.text = 'Press the new key. '
						+ controls.getDialogueNameForControl(BACK)
						+ ' to cancel';
				} else {
					get_controls().resetCustomControlKeys();
					updateControlsText();
				}
			}
			return;
		}
		if (controls.BACK) {
			// FlxG.state.closeSubState();
			// FlxG.state.openSubState(new OptionsSubState());

			// Go straight to the main menu because Controls is the only
			// functioning part of the options menu.
			FlxG.switchState(new MainMenuState());
			return;
		}

		if (controls.UP_P)
			curSelected -= 1;
		else if (controls.DOWN_P)
			curSelected += 1;

		if (curSelected < 0)
			curSelected = grpOptionsTexts.length - 1;
		else if (curSelected >= grpOptionsTexts.length)
			curSelected = 0;

		curSelectedControl = null;
		grpOptionsTexts.forEach(function(txt:FlxText) {
			txt.color = FlxColor.WHITE;
			txt.x = TEXT_MARGIN_LEFT_PX;

			if (txt.ID == curSelected) {
				txt.color = FlxColor.YELLOW;
				txt.x = 32;
				if (txt.ID < Controls.CUSTOMIZABLE_CONTROLS.length) {
					curSelectedControl = Controls.CUSTOMIZABLE_CONTROLS[txt.ID];
				}
			}
		});

		if (curSelectedControl != null) {
			headingText.text = 'Press ' + get_controls().getDialogueNameForControl(ACCEPT) + ' to configure';
		} else {
			// Assuming this is the reset all button.
			headingText.text = 'Press ' + get_controls().getDialogueNameForControl(ACCEPT) + ' to reset all bindings';
		}
	}
}
