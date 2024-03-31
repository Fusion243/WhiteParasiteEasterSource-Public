package;

import flixel.input.mouse.FlxMouseEvent;
import flixel.addons.effects.FlxTrail;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class SpookyMenuState extends MusicBeatState
{
	var bg:FlxSprite;
	var bgLeft:FlxSprite;
	var bgRight:FlxSprite;
	var play:FlxSprite;
	var fgLeft:FlxSprite;
	var fgRight:FlxSprite;

	var transitioning:Bool = false;
	var buttonHover:Bool = false;

	override public function create():Void
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("???", null);
		#end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;

		super.create();

		FlxG.sound.playMusic(Paths.music('spookyMenu'), 0);
		FlxG.sound.music.fadeIn(20, 0, 0.7);

		bgLeft = new FlxSprite();
		bgLeft.loadGraphic(Paths.image("mainmenu/newcrap/spooky/bgLeft"));
		add(bgLeft);

		bgRight = new FlxSprite();
		bgRight.loadGraphic(Paths.image("mainmenu/newcrap/spooky/bgRight"));
		add(bgRight);

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image("mainmenu/newcrap/spooky/bg"));
		bg.frames = Paths.getSparrowAtlas('mainmenu/newcrap/spooky/bg');
		bg.animation.addByPrefix('idle', 'staticScreen', 1, false);
		bg.animation.addByPrefix('cut', 'cutScreen', 24, false);
		bg.animation.play('idle');
		add(bg);

		play = new FlxSprite(100, 400);
		play.loadGraphic(Paths.image("mainmenu/newcrap/play"));
		play.setGraphicSize(Std.int(play.width * 0.8));
		play.color = 0xFFBABAC5;
		add(play);

		fgLeft = new FlxSprite();
		fgLeft.loadGraphic(Paths.image("mainmenu/newcrap/spooky/fgLeft"));
		add(fgLeft);

		fgRight = new FlxSprite();
		fgRight.loadGraphic(Paths.image("mainmenu/newcrap/spooky/fgRight"));
		add(fgRight);

		FlxMouseEvent.add(play, spr -> {
			if (!transitioning && !pushPlay) {
				pushPlay = true;
			}
		}, null, spr -> {
			if (!buttonHover && !transitioning)
				FlxG.sound.play(Paths.sound("scrollMenu"));
			play.color = FlxColor.WHITE;
		}, spr -> {
			if (buttonHover && !transitioning)
				buttonHover = false;
			play.color = 0xFFBABAC5;
		});
	}

	var pushPlay:Bool = false;

	override function update(elapsed:Float)
	{
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		// EASTER EGG

		if(!transitioning && (pressedEnter || pushPlay))
		{
			FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('spookyConfirmMenu'), 0.7);

			FlxTween.tween(play, {alpha: 0}, 1.2);
			transitioning = true;
			FlxG.mouse.visible = false;

			new FlxTimer().start(1.8, function(tmr:FlxTimer)
			{
				FlxTween.tween(fgLeft, {x: fgLeft.x - 300}, 2.2, {ease: FlxEase.quadInOut});
				FlxTween.tween(fgRight, {x: fgRight.x + 300}, 2.2, {ease: FlxEase.quadInOut});
			});
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				bg.animation.play('cut');
				FlxG.sound.play(Paths.sound('cut'), 0.7);
			});
			new FlxTimer().start(6.2, function(tmr:FlxTimer)
			{
				bg.visible = false;
				FlxTween.tween(bgLeft, {x: bgLeft.x - 400}, 2.3, {ease: FlxEase.quadInOut});
				FlxTween.tween(bgRight, {x: bgRight.x + 400}, 2.3, {ease: FlxEase.quadInOut});
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 1.2}, 3.3, {ease: FlxEase.quadInOut});
			});
			new FlxTimer().start(7, function(tmr:FlxTimer)
			{
				bg.visible = false;
				FlxTween.tween(bgLeft, {alpha: 0}, 0.7);
				FlxTween.tween(bgRight, {alpha: 0}, 0.7);
			});
			new FlxTimer().start(8, function(tmr:FlxTimer)
			{
				goToSong('annihilation');
			});
		}

		super.update(elapsed);
	}

	public static function goToSong(name:String) {
        PlayState.isStoryMode = false;
		
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		
		var p:String = Highscore.formatSong(name.toLowerCase(), PlayState.storyDifficulty);
		PlayState.SONG = Song.loadFromJson(name, name);
        LoadingState.loadAndSwitchState(new PlayState());
    }
}
