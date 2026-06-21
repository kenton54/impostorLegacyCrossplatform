package funkin.states.options;

import funkin.states.options.Option;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

class VisualsUISubState extends BaseOptionsMenu
{
	var notesLabelIdx:Int = -1;
	var spacerBeforeIdx:Int = -1;
	var spacerAfterIdx:Int = -1;
	var splitUnderlayTop:FlxSprite = null;
	var splitUnderlayBottom:FlxSprite = null;
	var splitUnderlayTopBaseY:Float = 0;
	var splitUnderlayBottomBaseY:Float = 0;
	
	public function new()
	{
		var notesGapBeforeRows:Int = 0;
		var notesGapAfterRows:Int = 0;
		
		title = 'visualsui';
		rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence
		
		var option:Option = new Option(Lang.str('opt_hidehud', 'Hide HUD'), Lang.str('opt_hidehud_desc', 'If checked, hides most HUD elements.'), 'hideHud', 'bool', false);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_timebar', 'Time Bar:'), Lang.str('opt_timebar_desc', "What should the Time Bar display?"), 'timeBarType', 'string', 'Time Left',
			[Lang.str('choice_timebar_timeleft',
				'Time Left'), Lang.str('choice_timebar_timeelapsed', 'Time Elapsed'), Lang.str('choice_timebar_songname', 'Song Name'), Lang.str('choice_generic_disabled', 'Disabled')],
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_hudrankdisplay', 'HUD Rank Display:'), Lang.str('opt_hudrankdisplay_desc', "What should be displayed on the HUD?"), 'hudRankDisplay', 'string',
			'Both', [Lang.str('choice_scoredisplay_both', 'Both'), Lang.str('choice_scoredisplay_accuracy', 'Accuracy'), Lang.str('choice_scoredisplay_rank', 'Rank')], ['Both', 'Accuracy', 'Rank']);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_coloredui', 'Colored UI:'),
			Lang.str('opt_coloredui_desc', "Colors UI elements based on the opponent's icon color.\n(Some colors might be hard to read.)"), 'colorText', 'string', 'Enabled',
			[Lang.str('choice_generic_enabled', 'Enabled'), Lang.str('choice_generic_disabled', 'Disabled')], ['Enabled', 'Disabled']);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_photosensitivemode', 'Photosensitive Mode'),
			Lang.str('opt_photosensitivemode_desc', "If checked, flashing lights and other imagery that may affect photosensitive individuals will be disabled."), 'photosensitive', 'bool', true);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_camerazooms', 'Camera Zooms'), Lang.str('opt_camerazooms_desc', "Allows camera to zoom in on a beat hit. Uncheck to disable."), 'camZooms',
			'bool', true);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_scoretextzoom', 'Score Text Zoom on Hit'),
			Lang.str('opt_scoretextzoom_desc', "If unchecked, disables the Score text zooming\neverytime you hit a note."), 'scoreZoom', 'bool', true);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_afterimages', 'Afterimages'), Lang.str('opt_afterimages_desc', "Characters will leave afterimages on double notes. Uncheck to disable."),
			'jumpGhosts', 'bool', true);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_discord', 'Discord'), Lang.str('opt_discord_desc'), 'discordRPC', 'bool', true);
		addOption(option);
		
		spacerBeforeIdx = optionsArray.length;
		addSpacerRows(notesGapBeforeRows);
		
		var option:Option = new Option(Lang.str('opt_category_notes', 'NOTES').toUpperCase(), '', '', 'label');
		addOption(option);
		
		spacerAfterIdx = optionsArray.length;
		addSpacerRows(notesGapAfterRows);
		
		var option:Option = new Option(Lang.str('opt_quants', 'Quants Enabled'), Lang.str('opt_quants_desc', 'Colors notes in-game based on their step value. Helpful for timing your note hits.'),
			'quants', 'bool', false);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_notesplashes', 'Note Splashes'), Lang.str('opt_notesplashes_desc', "If unchecked, hitting \"Sick!\" or \"Kutty!\" notes won't show particles."),
			'noteSplashes', 'bool', true);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_opponentnotes', 'Opponent Notes'), Lang.str('opt_opponentnotes_desc', 'If unchecked, opponent notes get hidden.'), 'opponentStrums', 'bool', true);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_laneunderlay', 'Lane Underlay'), Lang.str('opt_laneunderlay_desc', 'Adds a semi-transparent background behind the notes.'), 'laneUnderlayAlpha',
			'percent', 0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		
		var option:Option = new Option(Lang.str('opt_laneUnderlayStyle'), Lang.str('opt_laneUnderlayStyle_desc'), 'laneUnderlayStyle', 'string', 'A', [
				Lang.str('choice_laneUnderlayStyle_a'), Lang.str('choice_laneUnderlayStyle_b'), Lang.str('choice_laneUnderlayStyle_c'), Lang.str('choice_laneUnderlayStyle_d')
			], ['A', 'B', 'C', 'D']);
		addOption(option);
		
		var option:Option = new Option(Lang.str('opt_opponentLaneUnderlay'), Lang.str('opt_opponentLaneUnderlay_desc'), 'opponentLaneUnderlay', 'bool', true);
		addOption(option);
		
		super();
		
		notesLabelIdx = findNotesLabelIndex();
		if (notesLabelIdx == -1) return;
		
		for (txt in grpOptions)
		{
			if (txt.ID == notesLabelIdx)
			{
				txt.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				// txt.borderSize = 1.5;
				// txt.bold = true;
				break;
			}
		}
		
		refreshSplitUnderlays(notesGapAfterRows);
	}
	
	function addSpacerRows(count:Int)
	{
		for (_ in 0...count)
		{
			var option:Option = new Option('', '', '', 'label');
			addOption(option);
		}
	}
	
	function findNotesLabelIndex():Int
	{
		for (i => opt in optionsArray)
		{
			if (opt.type == 'label' && StringTools.trim(opt.name).length > 0)
			{
				return i;
			}
		}
		return -1;
	}
	
	function refreshSplitUnderlays(notesGapAfterRows:Int)
	{
		final underlayPadding:Int = 5;
		final underlayWidth:Int = 676;
		
		if (splitUnderlayTop != null)
		{
			remove(splitUnderlayTop, true);
			splitUnderlayTop = null;
		}
		if (splitUnderlayBottom != null)
		{
			remove(splitUnderlayBottom, true);
			splitUnderlayBottom = null;
		}
		
		for (member in members)
		{
			if (!Std.isOfType(member, FlxSprite)) continue;
			var spr:FlxSprite = cast member;
			if (Math.abs(spr.x - panelX) < 1 && Math.abs(spr.y - (optionStartY - underlayPadding)) < 1)
			{
				spr.visible = false;
				break;
			}
		}
		
		var insertPos:Int = members.indexOf(grpOptions);
		if (insertPos < 0) insertPos = 0;
		// 2 underlays
		var topEndIdx:Int = spacerBeforeIdx - 1;
		if (topEndIdx >= 0)
		{
			final h1:Int = Std.int(optionSpacing * (topEndIdx + 1)) + underlayPadding;
			splitUnderlayTopBaseY = optionStartY - underlayPadding;
			splitUnderlayTop = new FlxSprite(panelX, splitUnderlayTopBaseY).makeGraphic(underlayWidth, h1, FlxColor.BLACK);
			splitUnderlayTop.alpha = 0.5;
			insert(insertPos, splitUnderlayTop);
		}
		
		var bottomStartIdx:Int = spacerAfterIdx + notesGapAfterRows;
		if (bottomStartIdx < optionsArray.length)
		{
			final ok:Int = Std.int(optionStartY + optionSpacing * bottomStartIdx - underlayPadding);
			final spongebob:Int = Std.int(optionSpacing * (optionsArray.length - bottomStartIdx)) + underlayPadding;
			splitUnderlayBottomBaseY = ok;
			splitUnderlayBottom = new FlxSprite(panelX, splitUnderlayBottomBaseY).makeGraphic(underlayWidth, spongebob, FlxColor.BLACK);
			splitUnderlayBottom.alpha = 0.5;
			insert(insertPos + 1, splitUnderlayBottom);
		}
		
		updateSplitUnderlays();
	}
	
	function clipUnderlayToPanel(spr:FlxSprite):Void
	{
		if (spr == null) return;
		if (spr.clipRect == null) spr.clipRect = new FlxRect(0, 0, spr.width, spr.height);
		
		if (spr.y < topBound)
		{
			var yDiff = topBound - spr.y;
			spr.clipRect.set(0, yDiff, spr.width, spr.height - yDiff);
		}
		else if (spr.y + spr.height > bottomBound)
		{
			var yDiff = spr.y + spr.height - bottomBound;
			spr.clipRect.set(0, 0, spr.width, spr.height - yDiff);
		}
		else
		{
			spr.clipRect.set(0, 0, spr.width, spr.height);
		}
		spr.clipRect = spr.clipRect;
	}
	
	function updateSplitUnderlays():Void
	{
		if (splitUnderlayTop != null)
		{
			splitUnderlayTop.y = splitUnderlayTopBaseY + currentScrollY;
			clipUnderlayToPanel(splitUnderlayTop);
		}
		if (splitUnderlayBottom != null)
		{
			splitUnderlayBottom.y = splitUnderlayBottomBaseY + currentScrollY;
			clipUnderlayToPanel(splitUnderlayBottom);
		}
	}
	
	override function selectOption(id:Int)
	{
		if (id < 0 || id >= optionsArray.length || optionsArray[id].type == 'label')
		{
			return;
		}
		super.selectOption(id);
	}
	
	override function changeSelection(change:Int = 0, silent:Bool = false)
	{
		super.changeSelection(change, silent);
		if (change == 0) return;
		var dir:Int = (change > 0) ? 1 : -1;
		var guard:Int = 0;
		while (optionsArray[curSelected].type == 'label' && guard < optionsArray.length)
		{
			super.changeSelection(dir, true);
			guard++;
		}
	}
	
	override function refreshOptionVisuals()
	{
		super.refreshOptionVisuals();
		if (notesLabelIdx != -1)
		{
			for (txt in grpOptions)
			{
				if (txt.ID == notesLabelIdx)
				{
					txt.alpha = 1;
					txt.color = FlxColor.WHITE;
				}
				else if (optionsArray[txt.ID].type == 'label')
				{
					txt.alpha = 0;
				}
			}
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateSplitUnderlays();
	}
}
