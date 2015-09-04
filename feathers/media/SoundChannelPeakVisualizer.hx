/*
Feathers
Copyright 2012-2015 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.media
{
import feathers.core.FeathersControl;
import feathers.events.MediaPlayerEventType;
import feathers.skins.IStyleProvider;

import flash.media.SoundChannel;

import starling.display.Quad;
import starling.events.Event;

/**
 * A visualization of the left and right peaks of the
 * <code>flash.media.SoundChannel</code> from a <code>SoundPlayer</code>
 * component.
 *
 * @see ../../../help/sound-player.html How to use the Feathers SoundPlayer component
 */
class SoundChannelPeakVisualizer extends FeathersControl implements IMediaPlayerControl
{
	/**
	 * The default <code>IStyleProvider</code> for all
	 * <code>SoundChannelPeakVisualizer</code> components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Constructor.
	 */
	public function SoundChannelPeakVisualizer()
	{
	}

	/**
	 * @private
	 */
	override private function get_defaultStyleProvider():IStyleProvider
	{
		return SoundChannelPeakVisualizer.globalStyleProvider;
	}

	/**
	 * @private
	 */
	private var leftPeakBar:Quad;

	/**
	 * @private
	 */
	private var rightPeakBar:Quad;

	/**
	 * @private
	 */
	private var _gap:Number = 0;

	/**
	 * The gap, in pixels, between the bars.
	 */
	public function get_gap():Number
	{
		return this._gap;
	}

	/**
	 * @private
	 */
	public function set_gap(value:Number):Number
	{
		if(this._gap == value)
		{
			return;
		}
		this._gap = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _mediaPlayer:SoundPlayer;

	/**
	 * @inheritDoc
	 */
	public function get_mediaPlayer():IMediaPlayer
	{
		return this._mediaPlayer;
	}

	/**
	 * @private
	 */
	public function set_mediaPlayer(value:IMediaPlayer):IMediaPlayer
	{
		if(this._mediaPlayer == value)
		{
			return;
		}
		if(this._mediaPlayer)
		{
			this._mediaPlayer.removeEventListener(MediaPlayerEventType.PLAYBACK_STATE_CHANGE, mediaPlayer_playbackStateChange);
		}
		this._mediaPlayer = value as SoundPlayer;
		if(this._mediaPlayer)
		{
			this.handlePlaybackStateChange();
			this._mediaPlayer.addEventListener(MediaPlayerEventType.PLAYBACK_STATE_CHANGE, mediaPlayer_playbackStateChange);
		}
		this.invalidate(INVALIDATION_FLAG_DATA);
	}

	/**
	 * @private
	 */
	override public function dispose():Void
	{
		this.mediaPlayer = null;
		super.dispose();
	}

	/**
	 * @private
	 */
	override private function initialize():Void
	{
		if(!this.leftPeakBar)
		{
			this.leftPeakBar = new Quad(1, 1);
			this.addChild(this.leftPeakBar);
		}
		if(!this.rightPeakBar)
		{
			this.rightPeakBar = new Quad(1, 1);
			this.addChild(this.rightPeakBar);
		}
	}

	/**
	 * @private
	 */
	override private function draw():Void
	{
		this.autoSizeIfNeeded();
		
		if(this._mediaPlayer && this._mediaPlayer.soundChannel)
		{
			var soundChannel:SoundChannel = this._mediaPlayer.soundChannel;
			var maxHeight:Number = this.actualHeight - 1;
			this.leftPeakBar.height = 1 + maxHeight * soundChannel.leftPeak;
			this.rightPeakBar.height = 1 + maxHeight * soundChannel.rightPeak;
		}
		else
		{
			this.leftPeakBar.height = 1;
			this.rightPeakBar.height = 1;
		}
		var barWidth:Number = (this.actualWidth / 2) - this._gap;
		this.leftPeakBar.y = this.actualHeight - this.leftPeakBar.height;
		this.leftPeakBar.width = barWidth;
		this.rightPeakBar.x = barWidth + this._gap;
		this.rightPeakBar.y = this.actualHeight - this.rightPeakBar.height;
		this.rightPeakBar.width = barWidth;
		super.draw();
	}

	/**
	 * @private
	 */
	private function autoSizeIfNeeded():Boolean
	{
		var needsWidth:Boolean = this.explicitWidth != this.explicitWidth; //isNaN
		var needsHeight:Boolean = this.explicitHeight != this.explicitHeight; //isNaN
		if(!needsWidth && !needsHeight)
		{
			return false;
		}
		var newWidth:Number = this.explicitWidth;
		if(needsWidth)
		{
			newWidth = 4 + this._gap;
		}
		var newHeight:Number = this.explicitHeight;
		if(needsHeight)
		{
			newHeight = 3;
		}
		return this.setSizeInternal(newWidth, newHeight, false);
	}

	/**
	 * @private
	 */
	private function handlePlaybackStateChange():Void
	{
		if(this._mediaPlayer.isPlaying)
		{
			this.addEventListener(Event.ENTER_FRAME, peakVisualizer_enterFrameHandler);
		}
		else
		{
			this.removeEventListener(Event.ENTER_FRAME, peakVisualizer_enterFrameHandler);
		}
	}

	/**
	 * @private
	 */
	private function mediaPlayer_playbackStateChange(event:Event):Void
	{
		this.handlePlaybackStateChange();
	}

	/**
	 * @private
	 */
	private function peakVisualizer_enterFrameHandler(event:Event):Void
	{
		this.invalidate(INVALIDATION_FLAG_DATA);
	}
}
}
