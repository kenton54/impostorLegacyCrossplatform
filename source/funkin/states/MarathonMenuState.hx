package funkin.states;

import funkin.data.*;
import funkin.data.Song;
import funkin.data.NodeData;
import funkin.data.WeekData;
import funkin.objects.menu.*;
import funkin.objects.menu.BaseNode;
import funkin.states.*;
import funkin.game.marathon.*;

import animate.FlxAnimate;
import animate.FlxAnimateFrames;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxDestroyUtil;

typedef MarathonWeek =
{
	// JSON variables
	var songs:Array<Dynamic>;
	var title:String;
}

class MarathonMenuState extends AmongUIState
{
	var bg:FlxSprite;
	var deskBro:FlxSprite;
	var wallBro:FlxSprite;
	var wallBro2:FlxSprite;
	var addThing:FlxSprite;
	var button:FlxSprite;
	var detective:FlxAnimate;
	var detectiveHands:FlxAnimate;
	var peekers:FlxAnimate;
	var peekerCycleTimer:Float = 15;
	var ext = 'menu/marathon/';
	
	var weeks:Array<MarathonWeek> = [];
	
	public var composers:Array<String> = ['EthanTheDoodler', 'Punkett', 'Rareblin']; // FOR PEOPLE WITH TOO MANY SOLO SONGS
	
	public static var marathonArray:Array<String> = [];
	public static var marathonSeed:Int;
	
	override function create()
	{
		initStateScript();
		
		detective = new FlxAnimate();
		detective.frames = FlxAnimateFrames.fromAnimate(Paths.getPath('images/${ext}detective/base', NORMAL));
		
		detective.anim.addByFrameLabel('idle', 'idle', 24, true);
		detective.anim.addByFrameLabel('talk', 'talk', 24, true);
		
		if (detective.anim.exists('idle')) detective.anim.play('idle', true);
		detective.antialiasing = ClientPrefs.globalAntialiasing;
		detective.setPosition(200, 280);
		detective.scale.set(0.7, 0.7);
		detective.updateHitbox();
		add(detective);
		
		detectiveHands = new FlxAnimate();
		detectiveHands.frames = FlxAnimateFrames.fromAnimate(Paths.getPath('images/${ext}detective/hands', NORMAL));
		detectiveHands.anim.addByFrameLabel('idle', 'idle', 24, true);
		detectiveHands.anim.addByFrameLabel('1', '1', 24, false);
		detectiveHands.anim.addByFrameLabel('2', '2', 24, false);
		detectiveHands.anim.addByFrameLabel('3', '3', 24, false);
		detectiveHands.anim.addByFrameLabel('4', '4', 24, false);
		if (detectiveHands.anim.exists('idle')) detectiveHands.anim.play('idle', true);
		detectiveHands.antialiasing = ClientPrefs.globalAntialiasing;
		detectiveHands.setPosition(145, 290);
		detectiveHands.scale.set(0.7, 0.7);
		detectiveHands.updateHitbox();
		
		peekers = new FlxAnimate();
		peekers.frames = FlxAnimateFrames.fromAnimate(Paths.getPath('images/${ext}/peekers', NORMAL));
		peekers.anim.addByFrameLabel('red', 'red', 24, false);
		peekers.anim.addByFrameLabel('gray', 'gray', 24, false);
		peekers.anim.addByFrameLabel('yellow', 'yellow', 24, false);
		peekers.antialiasing = ClientPrefs.globalAntialiasing;
		peekers.setPosition(-425, 50);
		peekers.scale.set(0.7, 0.7);
		peekers.updateHitbox();
		peekers.visible = false;
		
		button = new FlxSprite(200, 200).loadGraphic(Paths.image(ext + 'button'));
		// add(button);
		
		weeks = addWeeks();
		
		if (PlayState.isChallenge) PlayState.isChallenge = false;
		
		super.create();
		
		wallBro2 = new FlxSprite(250, -185).loadGraphic(Paths.image(ext + 'wall bro 2'));
		wallBro2.scale.set(0.7, 0.7);
		add(wallBro2);
		
		wallBro = new FlxSprite(-150, -250).loadGraphic(Paths.image(ext + 'wall bro'));
		wallBro.scale.set(0.7, 0.7);
		add(wallBro);
		
		remove(peekers, true);
		add(peekers);
		
		remove(detective, true);
		add(detective);
		
		deskBro = new FlxSprite(-185, 470).loadGraphic(Paths.image(ext + 'desk bro'));
		deskBro.scale.set(0.7, 0.7);
		add(deskBro);
		
		remove(detectiveHands, true);
		add(detectiveHands);
		
		addThing = new FlxSprite(-50, -60).loadGraphic(Paths.image(ext + 'add'));
		addThing.scale.set(0.7, 0.7);
		addThing.updateHitbox();
		addThing.blend = ADD;
		add(addThing);
		
		scriptGroup.call('onCreatePost', []);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (lockMovement) return;
		
		// debug keys for testing the animations
		if (FlxG.keys.justPressed.ONE) detective.anim.play('idle', true);
		if (FlxG.keys.justPressed.TWO || FlxG.keys.justPressed.THREE || FlxG.keys.justPressed.FOUR || FlxG.keys.justPressed.FIVE) detective.anim.play('talk', true);
		
		if (FlxG.keys.justPressed.ONE) detectiveHands.anim.play('idle', true);
		if (FlxG.keys.justPressed.TWO) detectiveHands.anim.play('1', true);
		if (FlxG.keys.justPressed.THREE) detectiveHands.anim.play('2', true);
		if (FlxG.keys.justPressed.FOUR) detectiveHands.anim.play('3', true);
		if (FlxG.keys.justPressed.FIVE) detectiveHands.anim.play('4', true);
		
		if (peekers.visible)
		{
			if (peekers.anim.finished)
			{
				peekers.visible = false;
				peekerCycleTimer = 15;
			}
		}
		else
		{
			peekerCycleTimer -= elapsed;
			if (peekerCycleTimer <= 0)
			{
				if (FlxG.random.bool(50))
				{
					peekers.visible = true;
					peekers.anim.play(FlxG.random.getObject(['red', 'gray', 'yellow']), true);
				}
				else
				{
					peekerCycleTimer = 15;
				}
			}
		}
		
		if (controls.ACCEPT) marathonMode();
	}
	
	function marathonMode()
	{
		marathonArray = []; // The list of songs
		
		for (i in 0...weeks.length) // Gets all the songs and puts them into marathonArray
		{
			for (j in 0...weeks[i].songs.length)
			{
				marathonArray.push(weeks[i].songs[j][0]);
			}
		}
		
		var canShuffle:Bool = true;
		
		if (canShuffle) shuffleSeed();
		
		trace(marathonSeed);
		trace(marathonArray);
		
		PlayState.storyMeta.playlist = marathonArray;
		PlayState.isStoryMode = false;
		PlayState.isChallenge = true;
		PlayState.SONG = Chart.fromSong(PlayState.storyMeta.playlist[0], PlayState.storyMeta.difficulty);
		
		// var mods = [
		// 	new FPSModifier(),
		// 	new SnowModifier()
		// ];
		// var modifier = FlxG.random.getObject(mods);
		// PlayState.marathonModifiers.push(modifier);
		
		PlayState.marathonModifiers.push(new FPSModifier());
		PlayState.marathonModifiers.push(new SnowModifier());
		PlayState.marathonModifiers.push(new DirectionModifier());
		
		FlxG.switchState(PlayState.new);
		// PlayState.addModifier(new FPSModifier());
	}
	
	function shuffleSeed()
	{
		// FlxG.random.currentSeed = marathonSeed;
		FlxG.random.shuffle(marathonArray);
	}
	
	function addWeeks()
	{
		weeks = [];
		// Todo: PORT THIS TO A SOFTCODE MAYBE
		weeks.push(
			{
				songs: [
					["Sussus Moogus", "red", 'red', FlxColor.RED, 'story', ['sussus-moogus'], 0, composers[0]],
					["Sabotage", "red", 'red', FlxColor.RED, 'story', ['sabotage'], 0, composers[0]],
					["Meltdown", "red-meltdown", 'red', FlxColor.RED, 'story', ['meltdown'], 0, composers[1]],
					["Sussus Toogus", "green-crewmate", 'green', FlxColor.fromRGB(0, 255, 0), 'story', ['sussus-toogus'], 0, 'EthanTheDoodler, fabs'],
					["Lights Down", "green", 'green', FlxColor.fromRGB(0, 255, 0), 'story', ['lights-down'], 0, composers[2]],
					["Reactor", "green", 'green', FlxColor.fromRGB(0, 255, 0), 'story', ['reactor'], 0, composers[2]],
					["Ejected", "green-parasite", 'greenp', FlxColor.fromRGB(0, 255, 0), 'story', ['ejected'], 0, composers[2]],
					// ["Double Trouble", "double-trouble", 'greenp', FlxColor.fromRGB(0, 255, 0), 'story', ['ejected'], 0, composers[2]],
					["Mando", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67), 'story', ['mando'], 0, 'Emihead, Rareblin'],
					["D'low", "yellow", 'yellow', FlxColor.fromRGB(255, 218, 67), 'story', ["d'low"], 0, composers[1]],
					["Oversight", "white", 'white', FlxColor.WHITE, 'story', ['oversight'], 0, 'Emihead, Rareblin'],
					["Danger", "black", 'black', FlxColor.fromRGB(179, 0, 255), 'story', ['danger'], 0, composers[2]],
					["Double Kill", "double-kill", 'black', FlxColor.fromRGB(179, 0, 255), 'story', ['double-kill'], 0, composers[2]],
					["Defeat", "black", 'black', FlxColor.fromRGB(179, 0, 255), 'story', ['defeat'], 0, composers[2]],
					["Identity Crisis", "monotone", 'monotone', FlxColor.BLACK, 'special', ['meltdown', 'ejected', 'double-kill', 'defeat', 'boiling-point', 'neurotic', 'pretender'], 0, 'Vruzzen, Rareblin, Doguy'],
					["Finale", "black", 'blackp', FlxColor.fromRGB(179, 0, 255), 'special', ['finale'], 0, 'Vruzzen, Punkett']
				],
				title: 'Story Mode'
			});
			
		weeks.push(
			{
				songs: [
					["Ashes", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0), 'story', ['ashes'], 0, composers[0]],
					["Magmatic", "maroon", 'maroon', FlxColor.fromRGB(181, 0, 0), 'story', ['magmatic'], 0, 'Rozebud'],
					["Boiling Point", "maroon-parasite", 'maroonp', FlxColor.fromRGB(181, 0, 0), 'story', ['boiling-point'], 0, '${composers[0]}, ${composers[2]}'],
					["Delusion", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), 'story', ['delusion'], 0, 'Fluffyhairs'],
					["Blackout", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), 'story', ['blackout'], 0, 'Cval'],
					["Neurotic", "gray", 'grey', FlxColor.fromRGB(139, 157, 168), 'story', ['neurotic'], 0, 'Nii-san'],
					["Heartbeat", "pink", 'pink', FlxColor.fromRGB(255, 0, 222), 'story', ['heartbeat'], 0, 'Saster'],
					["Pinkwave", "pink", 'pink', FlxColor.fromRGB(255, 0, 222), 'story', ['pinkwave'], 0, 'Fluffyhairs'],
					["Pretender", "pretender", 'pink', FlxColor.fromRGB(255, 0, 222), 'story', ['pretender'], 0, composers[0]],
					["Sauces Moogus", "chef", 'chef', FlxColor.fromRGB(242, 114, 28), 'special', ['ashes', 'delusion', 'heartbeat'], 0, 'Saster']
				],
				title: 'Triple Trouble'
			});
			
		weeks.push(
			{
				songs: [
					["O2", "jorsawsee", 'jorsawsee', FlxColor.fromRGB(38, 127, 230), 'story', ['o2'], 0, composers[1]],
					["Voting Time", "votingtime", 'warchief', FlxColor.fromRGB(153, 67, 196), 'story', ['voting-time'], 0, 'Punkett, JADS'],
					["Turbulence", "redmungus", 'mungusp', FlxColor.RED, 'story', ['turbulence'], 0, 'Keegan'],
					["Victory", "warchief", 'warchief', FlxColor.fromRGB(153, 67, 196), 'story', ['victory'], 0, composers[1]],
					["ROOMCODE", "powers", 'powers', FlxColor.fromRGB(80, 173, 235), 'special', ['victory'], 0, 'Keegan']
				],
				title: 'Jorsawsee\'s Jams'
			});
			
		weeks.push(
			{
				songs: [
					["Sussy Bussy", "tomongus", 'mech', FlxColor.fromRGB(255, 90, 134), 'story', ['sussy-bussy'], 0, 'Saruky'],
					["Rivals", "tomongus", 'mech', FlxColor.fromRGB(255, 90, 134), 'story', ['rivals'], 0, 'Keoni'],
					["Chewmate", "hamster", 'tomo', FlxColor.fromRGB(255, 90, 134), 'story', ['chewmate'], 0, 'Moonmistt'],
					["Tomongus Tuesday", "tuesday", 'mech', FlxColor.fromRGB(255, 90, 134), 'special', ['chewmate'], 0, 'Emihead']
				],
				title: 'Tomongus Week'
			});
			
		weeks.push(
			{
				songs: [
					["Lemon Lime", "jads", 'jads', 0xFF66FF66, 'story', ['lemon-lime'], 0, 'Rozebud'],
					["Chlorophyll", "jads", 'jads', 0xFF66FF66, 'story', ['chlorophyll'], 0, 'JADS'],
					["Inflorescence", "jads", 'jads', 0xFF66FF66, 'story', ['inflorescence'], 0, 'Rozebud'],
					["Stargazer", "jads", 'jads', 0xFF66FF66, 'story', ['stargazer'], 0, composers[1]]
				],
				title: 'JADS Week'
			});
			
		weeks.push(
			{
				songs: [
					["Titular", "henry", 'henry', FlxColor.ORANGE, 'story', ['titular'], 0, composers[0]],
					["Greatest Plan", "charles", 'charles', FlxColor.RED, 'story', ['greatest-plan'], 0, composers[0]],
					["Reinforcements", "ellie", 'ellie', FlxColor.ORANGE, 'story', ['reinforcements'], 0, '${composers[0]}, Philiplol'],
					["Armed", "right-hand-man", 'rhm', FlxColor.ORANGE, 'story', ['armed'], 0, '${composers[0]}, ${composers[1]}']
				],
				title: 'Henry Week'
			});
		/*
			weeks.push(
				{
					songs: [
						["Alpha Moogus", "oldpostor", 'alpha', FlxColor.RED, 'shop', [], 250, 'idk'],
						["Actin Sus", "oldpostor", 'alpha', FlxColor.RED, 'shop', [], 250, 'idk']
					],
					title: 'Alpha Week'
				});
		 */
		weeks.push(
			{
				songs: [
					["Ow", "kills", 'ow', FlxColor.fromRGB(84, 167, 202), 'shop', [], 400, 'fabs'],
					["Who", "whoguys", 'who', FlxColor.fromRGB(22, 65, 240), 'shop', [], 500, composers[0]],
					["Insane Streamer", "jerma", 'jerma', FlxColor.BLACK, 'shop', [], 400, '${composers[0]}, Neato'],
					["Sussus Nuzzus", "nuzzles", 'nuzzus', FlxColor.BLACK, 'shop', [], 400, 'Lunaxis'],
					["Idk", "idk", 'idk', FlxColor.fromRGB(255, 140, 177), 'shop', [], 350, 'Kiwiquest'],
					["Esculent", "dead", 'esculent', FlxColor.BLACK, 'shop', [], 350, 'Nii-san'],
					["Drippypop", "drippy", 'drip', FlxColor.fromRGB(188, 106, 223), 'shop', [], 425, '${composers[0]}, Neato'],
					["Crewicide", "dave", 'dave', FlxColor.BLUE, 'shop', [], 450, composers[1]],
					["Monotone Attack", "attack", 'attack', FlxColor.WHITE, 'shop', [], 400, 'Biddle3'],
					["Top 10", "top", 'awesome', FlxColor.RED, 'shop', [], 200, 'Top 10']
				],
				title: 'Bonus Songs'
			});
			
		weeks.push(
			{
				songs: [
					["Chippin", "cvp", 'cval', FlxColor.fromRGB(255, 60, 38), 'shop', [], 300, 'Ziffy'],
					["Chipping", "cvp", 'cval', FlxColor.fromRGB(255, 60, 38), 'shop', [], 300, 'Ziffy'],
					["Torture", "ziffyclumper", 'torture', FlxColor.fromRGB(188, 106, 223), 'special', ['chippin', 'chipping'], 0, 'Cval, JADS, Fluffyhairs, Ziffy']
				],
				title: 'Cval vs. Pip'
			});
			
		return weeks;
	}
	
	override function destroy()
	{
		if (detective != null)
		{
			remove(detective, true);
			detective = FlxDestroyUtil.destroy(detective);
		}
		
		super.destroy();
	}
}
