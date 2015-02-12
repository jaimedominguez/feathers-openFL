/*
Feathers
Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IFocusDisplayObject;
import feathers.core.ITextRenderer;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.skins.StateWithToggleValueSelector;

import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * Dispatched when the the user taps or clicks the button. The touch must
 * remain within the bounds of the button on release to register as a tap
 * or a click. If focus management is enabled, the button may also be
 * triggered by pressing the spacebar while the button has focus.
 *
 * <p>The properties of the event object have the following values:</p>
 * <table class="innertable">
 * <tr><th>Property</th><th>Value</th></tr>
 * <tr><td><code>bubbles</code></td><td>false</td></tr>
 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
 *   event listener that handles the event. For example, if you use
 *   <code>myButton.addEventListener()</code> to register an event listener,
 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
 * <tr><td><code>data</code></td><td>null</td></tr>
 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
 *   it is not always the Object listening for the event. Use the
 *   <code>currentTarget</code> property to always access the Object
 *   listening for the event.</td></tr>
 * </table>
 *
 * @eventType starling.events.Event.TRIGGERED
 */
//[Event(name="triggered",type="starling.events.Event")]

/**
 * Dispatched when the button is pressed for a long time. The property
 * <code>isLongPressEnabled</code> must be set to <code>true</code> before
 * this event will be dispatched.
 *
 * <p>The following example enables long presses:</p>
 *
 * <listing version="3.0">
 * button.isLongPressEnabled = true;
 * button.addEventListener( FeathersEventType.LONG_PRESS, function( event:Event ):Void
 * {
 *     // long press
 * });</listing>
 *
 * <p>The properties of the event object have the following values:</p>
 * <table class="innertable">
 * <tr><th>Property</th><th>Value</th></tr>
 * <tr><td><code>bubbles</code></td><td>false</td></tr>
 * <tr><td><code>currentTarget</code></td><td>The Object that defines the
 *   event listener that handles the event. For example, if you use
 *   <code>myButton.addEventListener()</code> to register an event listener,
 *   myButton is the value of the <code>currentTarget</code>.</td></tr>
 * <tr><td><code>data</code></td><td>null</td></tr>
 * <tr><td><code>target</code></td><td>The Object that dispatched the event;
 *   it is not always the Object listening for the event. Use the
 *   <code>currentTarget</code> property to always access the Object
 *   listening for the event.</td></tr>
 * </table>
 *
 * @eventType feathers.events.FeathersEventType.LONG_PRESS
 * @see #isLongPressEnabled
 * @see #longPressDuration
 */
//[Event(name="longPress",type="starling.events.Event")]

/**
 * A push button control that may be triggered when pressed and released.
 *
 * <p>The following example creates a button, gives it a label and listens
 * for when the button is triggered:</p>
 *
 * <listing version="3.0">
 * var button:Button = new Button();
 * button.label = "Click Me";
 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
 * this.addChild( button );</listing>
 *
 * @see http://wiki.starling-framework.org/feathers/button
 */
class Button extends FeathersControl implements IFocusDisplayObject
{
	/**
	 * @private
	 */
	inline private static var HELPER_POINT:Point = new Point();

	/**
	 * The default value added to the <code>styleNameList</code> of the label.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var DEFAULT_CHILD_NAME_LABEL:String = "feathers-button-label";

	/**
	 * An alternate name to use with Button to allow a theme to give it
	 * a more prominent, "call-to-action" style. If a theme does not provide
	 * a skin for the call-to-action button, the theme will automatically
	 * fall back to using the default button skin.
	 *
	 * <p>An alternate name should always be added to a component's
	 * <code>styleNameList</code> before the component is added to the stage for
	 * the first time. If it is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the call-to-action style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_NAME_CALL_TO_ACTION_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var ALTERNATE_NAME_CALL_TO_ACTION_BUTTON:String = "feathers-call-to-action-button";

	/**
	 * An alternate name to use with Button to allow a theme to give it
	 * a less prominent, "quiet" style. If a theme does not provide
	 * a skin for the quiet button, the theme will automatically fall back
	 * to using the default button skin.
	 *
	 * <p>An alternate name should always be added to a component's
	 * <code>styleNameList</code> before the component is added to the stage for
	 * the first time. If it is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the quiet button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_NAME_QUIET_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var ALTERNATE_NAME_QUIET_BUTTON:String = "feathers-quiet-button";

	/**
	 * An alternate name to use with Button to allow a theme to give it
	 * a highly prominent, "danger" style. An example would be a delete
	 * button or some other button that has a destructive action that cannot
	 * be undone if the button is triggered. If a theme does not provide
	 * a skin for the danger button, the theme will automatically fall back
	 * to using the default button skin.
	 *
	 * <p>An alternate name should always be added to a component's
	 * <code>styleNameList</code> before the component is added to the stage for
	 * the first time. If it is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the danger button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_NAME_DANGER_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var ALTERNATE_NAME_DANGER_BUTTON:String = "feathers-danger-button";

	/**
	 * An alternate name to use with Button to allow a theme to give it
	 * a "back button" style, perhaps with an arrow pointing backward. If a
	 * theme does not provide a skin for the back button, the theme will
	 * automatically fall back to using the default button skin.
	 *
	 * <p>An alternate name should always be added to a component's
	 * <code>styleNameList</code> before the component is added to the stage for
	 * the first time. If it is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the back button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_NAME_BACK_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var ALTERNATE_NAME_BACK_BUTTON:String = "feathers-back-button";

	/**
	 * An alternate name to use with Button to allow a theme to give it
	 * a "forward" button style, perhaps with an arrow pointing forward. If
	 * a theme does not provide a skin for the forward button, the theme
	 * will automatically fall back to using the default button skin.
	 *
	 * <p>An alternate name should always be added to a component's
	 * <code>styleNameList</code> before the component is added to the stage for
	 * the first time. If it is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the forward button style is applied to
	 * a button:</p>
	 *
	 * <listing version="3.0">
	 * var button:Button = new Button();
	 * button.styleNameList.add( Button.ALTERNATE_NAME_FORWARD_BUTTON );
	 * this.addChild( button );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	inline public static var ALTERNATE_NAME_FORWARD_BUTTON:String = "feathers-forward-button";
	
	/**
	 * Identifier for the button's up state. Can be used for styling purposes.
	 *
	 * @see #stateToSkinFunction
	 * @see #stateToIconFunction
	 * @see #stateToLabelPropertiesFunction
	 */
	inline public static var STATE_UP:String = "up";
	
	/**
	 * Identifier for the button's down state. Can be used for styling purposes.
	 *
	 * @see #stateToSkinFunction
	 * @see #stateToIconFunction
	 * @see #stateToLabelPropertiesFunction
	 */
	inline public static var STATE_DOWN:String = "down";

	/**
	 * Identifier for the button's hover state. Can be used for styling purposes.
	 *
	 * @see #stateToSkinFunction
	 * @see #stateToIconFunction
	 * @see #stateToLabelPropertiesFunction
	 */
	inline public static var STATE_HOVER:String = "hover";
	
	/**
	 * Identifier for the button's disabled state. Can be used for styling purposes.
	 *
	 * @see #stateToSkinFunction
	 * @see #stateToIconFunction
	 * @see #stateToLabelPropertiesFunction
	 */
	inline public static var STATE_DISABLED:String = "disabled";
	
	/**
	 * The icon will be positioned above the label.
	 *
	 * @see #iconPosition
	 */
	inline public static var ICON_POSITION_TOP:String = "top";
	
	/**
	 * The icon will be positioned to the right of the label.
	 *
	 * @see #iconPosition
	 */
	inline public static var ICON_POSITION_RIGHT:String = "right";
	
	/**
	 * The icon will be positioned below the label.
	 *
	 * @see #iconPosition
	 */
	inline public static var ICON_POSITION_BOTTOM:String = "bottom";
	
	/**
	 * The icon will be positioned to the left of the label.
	 *
	 * @see #iconPosition
	 */
	inline public static var ICON_POSITION_LEFT:String = "left";

	/**
	 * The icon will be positioned manually with no relation to the position
	 * of the label. Use <code>iconOffsetX</code> and <code>iconOffsetY</code>
	 * to set the icon's position.
	 *
	 * @see #iconPosition
	 * @see #iconOffsetX
	 * @see #iconOffsetY
	 */
	inline public static var ICON_POSITION_MANUAL:String = "manual";
	
	/**
	 * The icon will be positioned to the left the label, and the bottom of
	 * the icon will be aligned to the baseline of the label text.
	 *
	 * @see #iconPosition
	 */
	inline public static var ICON_POSITION_LEFT_BASELINE:String = "leftBaseline";
	
	/**
	 * The icon will be positioned to the right the label, and the bottom of
	 * the icon will be aligned to the baseline of the label text.
	 *
	 * @see #iconPosition
	 */
	inline public static var ICON_POSITION_RIGHT_BASELINE:String = "rightBaseline";
	
	/**
	 * The icon and label will be aligned horizontally to the left edge of the button.
	 *
	 * @see #horizontalAlign
	 */
	inline public static var HORIZONTAL_ALIGN_LEFT:String = "left";
	
	/**
	 * The icon and label will be aligned horizontally to the center of the button.
	 *
	 * @see #horizontalAlign
	 */
	inline public static var HORIZONTAL_ALIGN_CENTER:String = "center";
	
	/**
	 * The icon and label will be aligned horizontally to the right edge of the button.
	 *
	 * @see #horizontalAlign
	 */
	inline public static var HORIZONTAL_ALIGN_RIGHT:String = "right";
	
	/**
	 * The icon and label will be aligned vertically to the top edge of the button.
	 *
	 * @see #verticalAlign
	 */
	inline public static var VERTICAL_ALIGN_TOP:String = "top";
	
	/**
	 * The icon and label will be aligned vertically to the middle of the button.
	 *
	 * @see #verticalAlign
	 */
	inline public static var VERTICAL_ALIGN_MIDDLE:String = "middle";
	
	/**
	 * The icon and label will be aligned vertically to the bottom edge of the button.
	 *
	 * @see #verticalAlign
	 */
	inline public static var VERTICAL_ALIGN_BOTTOM:String = "bottom";

	/**
	 * The default <code>IStyleProvider</code> for all <code>Button</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Constructor.
	 */
	public function Button()
	{
		super();
		this.isQuickHitAreaEnabled = true;
		this.addEventListener(TouchEvent.TOUCH, button_touchHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, button_removedFromStageHandler);
	}

	/**
	 * The value added to the <code>styleNameList</code> of the label. This
	 * variable is <code>private</code> so that sub-classes can customize
	 * the label name in their constructors instead of using the default
	 * name defined by <code>DEFAULT_CHILD_NAME_LABEL</code>.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var labelName:String = DEFAULT_CHILD_NAME_LABEL;
	
	/**
	 * The text renderer for the button's label.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #label
	 * @see #labelFactory
	 * @see #createLabel()
	 */
	private var labelTextRenderer:ITextRenderer;
	
	/**
	 * The currently visible skin. The value will be <code>null</code> if
	 * there is no currently visible skin.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var currentSkin:DisplayObject;
	
	/**
	 * The currently visible icon. The value will be <code>null</code> if
	 * there is no currently visible icon.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var currentIcon:DisplayObject;
	
	/**
	 * The saved ID of the currently active touch. The value will be
	 * <code>-1</code> if there is no currently active touch.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var touchPointID:Int = -1;

	/**
	 * @private
	 */
	override private function get_defaultStyleProvider():IStyleProvider
	{
		return Button.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override public function set_isEnabled(value:Bool):Void
	{
		if(this._isEnabled == value)
		{
			return;
		}
		super.isEnabled = value;
		if(!this._isEnabled)
		{
			this.touchable = false;
			this.currentState = STATE_DISABLED;
			this.touchPointID = -1;
		}
		else
		{
			//might be in another state for some reason
			//let's only change to up if needed
			if(this.currentState == STATE_DISABLED)
			{
				this.currentState = STATE_UP;
			}
			this.touchable = true;
		}
	}
	
	/**
	 * @private
	 */
	private var _currentState:String = STATE_UP;
	
	/**
	 * The current touch state of the button.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function get_currentState():String
	{
		return this._currentState;
	}
	
	/**
	 * @private
	 */
	private function set_currentState(value:String):Void
	{
		if(this._currentState == value)
		{
			return;
		}
		if(this.stateNames.indexOf(value) < 0)
		{
			throw new ArgumentError("Invalid state: " + value + ".");
		}
		this._currentState = value;
		this.invalidate(INVALIDATION_FLAG_STATE);
	}
	
	/**
	 * @private
	 */
	private var _label:String = null;
	
	/**
	 * The text displayed on the button.
	 *
	 * <p>The following example gives the button some label text:</p>
	 *
	 * <listing version="3.0">
	 * button.label = "Click Me";</listing>
	 *
	 * @default null
	 */
	public function get_label():String
	{
		return this._label;
	}
	
	/**
	 * @private
	 */
	public function set_label(value:String):Void
	{
		if(this._label == value)
		{
			return;
		}
		this._label = value;
		this.invalidate(INVALIDATION_FLAG_DATA);
	}

	/**
	 * @private
	 */
	private var _hasLabelTextRenderer:Bool = true;

	/**
	 * Determines if the button's label text renderer is created or not.
	 * Useful for button sub-components that may not display text, like
	 * slider thumbs and tracks, or similar sub-components on scroll bars.
	 *
	 * <p>The following example removed the label text renderer:</p>
	 *
	 * <listing version="3.0">
	 * button.hasLabelTextRenderer = false;</listing>
	 *
	 * @default true
	 */
	public function get_hasLabelTextRenderer():Bool
	{
		return this._hasLabelTextRenderer;
	}

	/**
	 * @private
	 */
	public function set_hasLabelTextRenderer(value:Bool):Void
	{
		if(this._hasLabelTextRenderer == value)
		{
			return;
		}
		this._hasLabelTextRenderer = value;
		this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
	}
	
	/**
	 * @private
	 */
	private var _iconPosition:String = ICON_POSITION_LEFT;

	[Inspectable(type="String",enumeration="top,right,bottom,left,rightBaseline,leftBaseline,manual")]
	/**
	 * The location of the icon, relative to the label.
	 *
	 * <p>The following example positions the icon to the right of the
	 * label:</p>
	 *
	 * <listing version="3.0">
	 * button.label = "Click Me";
	 * button.defaultIcon = new Image( texture );
	 * button.iconPosition = Button.ICON_POSITION_RIGHT;</listing>
	 *
	 * @default Button.ICON_POSITION_LEFT
	 *
	 * @see #ICON_POSITION_TOP
	 * @see #ICON_POSITION_RIGHT
	 * @see #ICON_POSITION_BOTTOM
	 * @see #ICON_POSITION_LEFT
	 * @see #ICON_POSITION_RIGHT_BASELINE
	 * @see #ICON_POSITION_LEFT_BASELINE
	 * @see #ICON_POSITION_MANUAL
	 */
	public function get_iconPosition():String
	{
		return this._iconPosition;
	}
	
	/**
	 * @private
	 */
	public function set_iconPosition(value:String):Void
	{
		if(this._iconPosition == value)
		{
			return;
		}
		this._iconPosition = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private var _gap:Float = 0;
	
	/**
	 * The space, in pixels, between the icon and the label. Applies to
	 * either horizontal or vertical spacing, depending on the value of
	 * <code>iconPosition</code>.
	 * 
	 * <p>If <code>gap</code> is set to <code>Float.POSITIVE_INFINITY</code>,
	 * the label and icon will be positioned as far apart as possible. In
	 * other words, they will be positioned at the edges of the button,
	 * adjusted for padding.</p>
	 *
	 * <p>The following example creates a gap of 50 pixels between the label
	 * and the icon:</p>
	 *
	 * <listing version="3.0">
	 * button.label = "Click Me";
	 * button.defaultIcon = new Image( texture );
	 * button.gap = 50;</listing>
	 *
	 * @default 0
	 * 
	 * @see #iconPosition
	 * @see #minGap
	 */
	public function get_gap():Float
	{
		return this._gap;
	}
	
	/**
	 * @private
	 */
	public function set_gap(value:Float):Void
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
	private var _minGap:Float = 0;

	/**
	 * If the value of the <code>gap</code> property is
	 * <code>Float.POSITIVE_INFINITY</code>, meaning that the gap will
	 * fill as much space as possible, the final calculated value will not be
	 * smaller than the value of the <code>minGap</code> property.
	 *
	 * <p>The following example ensures that the gap is never smaller than
	 * 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * button.gap = Float.POSITIVE_INFINITY;
	 * button.minGap = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #gap
	 */
	public function get_minGap():Float
	{
		return this._minGap;
	}

	/**
	 * @private
	 */
	public function set_minGap(value:Float):Void
	{
		if(this._minGap == value)
		{
			return;
		}
		this._minGap = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private var _horizontalAlign:String = HORIZONTAL_ALIGN_CENTER;

	[Inspectable(type="String",enumeration="left,center,right")]
	/**
	 * The location where the button's content is aligned horizontally (on
	 * the x-axis).
	 *
	 * <p>The following example aligns the button's content to the left:</p>
	 *
	 * <listing version="3.0">
	 * button.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;</listing>
	 *
	 * @default Button.HORIZONTAL_ALIGN_CENTER
	 *
	 * @see #HORIZONTAL_ALIGN_LEFT
	 * @see #HORIZONTAL_ALIGN_CENTER
	 * @see #HORIZONTAL_ALIGN_RIGHT
	 */
	public function get_horizontalAlign():String
	{
		return this._horizontalAlign;
	}
	
	/**
	 * @private
	 */
	public function set_horizontalAlign(value:String):Void
	{
		if(this._horizontalAlign == value)
		{
			return;
		}
		this._horizontalAlign = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private var _verticalAlign:String = VERTICAL_ALIGN_MIDDLE;

	[Inspectable(type="String",enumeration="top,middle,bottom")]
	/**
	 * The location where the button's content is aligned vertically (on
	 * the y-axis).
	 *
	 * <p>The following example aligns the button's content to the top:</p>
	 *
	 * <listing version="3.0">
	 * button.verticalAlign = Button.VERTICAL_ALIGN_TOP;</listing>
	 *
	 * @default Button.VERTICAL_ALIGN_MIDDLE
	 *
	 * @see #VERTICAL_ALIGN_TOP
	 * @see #VERTICAL_ALIGN_MIDDLE
	 * @see #VERTICAL_ALIGN_BOTTOM
	 */
	public function get_verticalAlign():String
	{
		return _verticalAlign;
	}
	
	/**
	 * @private
	 */
	public function set_verticalAlign(value:String):Void
	{
		if(this._verticalAlign == value)
		{
			return;
		}
		this._verticalAlign = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * Quickly sets all padding properties to the same value. The
	 * <code>padding</code> getter always returns the value of
	 * <code>paddingTop</code>, but the other padding values may be
	 * different.
	 *
	 * <p>The following example gives the button 20 pixels of padding on all
	 * sides:</p>
	 *
	 * <listing version="3.0">
	 * button.padding = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #paddingTop
	 * @see #paddingRight
	 * @see #paddingBottom
	 * @see #paddingLeft
	 */
	public function get_padding():Float
	{
		return this._paddingTop;
	}

	/**
	 * @private
	 */
	public function set_padding(value:Float):Void
	{
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		this.paddingLeft = value;
	}

	/**
	 * @private
	 */
	private var _paddingTop:Float = 0;

	/**
	 * The minimum space, in pixels, between the button's top edge and the
	 * button's content.
	 *
	 * <p>The following example gives the button 20 pixels of padding on the
	 * top edge only:</p>
	 *
	 * <listing version="3.0">
	 * button.paddingTop = 20;</listing>
	 *
	 * @default 0
	 */
	public function get_paddingTop():Float
	{
		return this._paddingTop;
	}

	/**
	 * @private
	 */
	public function set_paddingTop(value:Float):Void
	{
		if(this._paddingTop == value)
		{
			return;
		}
		this._paddingTop = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _paddingRight:Float = 0;

	/**
	 * The minimum space, in pixels, between the button's right edge and the
	 * button's content.
	 *
	 * <p>The following example gives the button 20 pixels of padding on the
	 * right edge only:</p>
	 *
	 * <listing version="3.0">
	 * button.paddingRight = 20;</listing>
	 *
	 * @default 0
	 */
	public function get_paddingRight():Float
	{
		return this._paddingRight;
	}

	/**
	 * @private
	 */
	public function set_paddingRight(value:Float):Void
	{
		if(this._paddingRight == value)
		{
			return;
		}
		this._paddingRight = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _paddingBottom:Float = 0;

	/**
	 * The minimum space, in pixels, between the button's bottom edge and
	 * the button's content.
	 *
	 * <p>The following example gives the button 20 pixels of padding on the
	 * bottom edge only:</p>
	 *
	 * <listing version="3.0">
	 * button.paddingBottom = 20;</listing>
	 *
	 * @default 0
	 */
	public function get_paddingBottom():Float
	{
		return this._paddingBottom;
	}

	/**
	 * @private
	 */
	public function set_paddingBottom(value:Float):Void
	{
		if(this._paddingBottom == value)
		{
			return;
		}
		this._paddingBottom = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _paddingLeft:Float = 0;

	/**
	 * The minimum space, in pixels, between the button's left edge and the
	 * button's content.
	 *
	 * <p>The following example gives the button 20 pixels of padding on the
	 * left edge only:</p>
	 *
	 * <listing version="3.0">
	 * button.paddingLeft = 20;</listing>
	 *
	 * @default 0
	 */
	public function get_paddingLeft():Float
	{
		return this._paddingLeft;
	}

	/**
	 * @private
	 */
	public function set_paddingLeft(value:Float):Void
	{
		if(this._paddingLeft == value)
		{
			return;
		}
		this._paddingLeft = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _labelOffsetX:Float = 0;

	/**
	 * Offsets the x position of the label by a certain number of pixels.
	 * This does not affect the measurement of the button. The button will
	 * measure itself as if the label were not offset from its original
	 * position.
	 *
	 * <p>The following example offsets the x position of the button's label
	 * by 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * button.labelOffsetX = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #labelOffsetY
	 */
	public function get_labelOffsetX():Float
	{
		return this._labelOffsetX;
	}

	/**
	 * @private
	 */
	public function set_labelOffsetX(value:Float):Void
	{
		if(this._labelOffsetX == value)
		{
			return;
		}
		this._labelOffsetX = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _labelOffsetY:Float = 0;

	/**
	 * Offsets the y position of the label by a certain number of pixels.
	 * This does not affect the measurement of the button. The button will
	 * measure itself as if the label were not offset from its original
	 * position.
	 *
	 * <p>The following example offsets the y position of the button's label
	 * by 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * button.labelOffsetY = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #labelOffsetX
	 */
	public function get_labelOffsetY():Float
	{
		return this._labelOffsetY;
	}

	/**
	 * @private
	 */
	public function set_labelOffsetY(value:Float):Void
	{
		if(this._labelOffsetY == value)
		{
			return;
		}
		this._labelOffsetY = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _iconOffsetX:Float = 0;

	/**
	 * Offsets the x position of the icon by a certain number of pixels.
	 * This does not affect the measurement of the button. The button will
	 * measure itself as if the icon were not offset from its original
	 * position.
	 *
	 * <p>The following example offsets the x position of the button's icon
	 * by 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * button.iconOffsetX = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #iconOffsetY
	 */
	public function get_iconOffsetX():Float
	{
		return this._iconOffsetX;
	}

	/**
	 * @private
	 */
	public function set_iconOffsetX(value:Float):Void
	{
		if(this._iconOffsetX == value)
		{
			return;
		}
		this._iconOffsetX = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _iconOffsetY:Float = 0;

	/**
	 * Offsets the y position of the icon by a certain number of pixels.
	 * This does not affect the measurement of the button. The button will
	 * measure itself as if the icon were not offset from its original
	 * position.
	 *
	 * <p>The following example offsets the y position of the button's icon
	 * by 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * button.iconOffsetY = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #iconOffsetX
	 */
	public function get_iconOffsetY():Float
	{
		return this._iconOffsetY;
	}

	/**
	 * @private
	 */
	public function set_iconOffsetY(value:Float):Void
	{
		if(this._iconOffsetY == value)
		{
			return;
		}
		this._iconOffsetY = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * Determines if a pressed button should remain in the down state if a
	 * touch moves outside of the button's bounds. Useful for controls like
	 * <code>Slider</code> and <code>ToggleSwitch</code> to keep a thumb in
	 * the down state while it is dragged around.
	 *
	 * <p>The following example ensures that the button's down state remains
	 * active when the button is pressed but the touch moves outside the
	 * button's bounds:</p>
	 *
	 * <listing version="3.0">
	 * button.keepDownStateOnRollOut = true;</listing>
	 */
	public var keepDownStateOnRollOut:Bool = false;

	/**
	 * @private
	 */
	private var _stateNames:Array<String> = new <String>
	[
		STATE_UP, STATE_DOWN, STATE_HOVER, STATE_DISABLED
	];

	/**
	 * A list of all valid touch state names for use with <code>currentState</code>.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #currentState
	 */
	private function get_stateNames():Array<String>
	{
		return this._stateNames;
	}

	/**
	 * @private
	 */
	private var _originalSkinWidth:Float = NaN;

	/**
	 * @private
	 */
	private var _originalSkinHeight:Float = NaN;

	/**
	 * @private
	 */
	private var _stateToSkinFunction:Dynamic;

	/**
	 * Returns a skin for the current state.
	 *
	 * <p>The following function signature is expected:</p>
	 * <pre>function(target:Button, state:Object, oldSkin:DisplayObject = null):DisplayObject</pre>
	 *
	 * @default null
	 */
	public function get_stateToSkinFunction():Function
	{
		return this._stateToSkinFunction;
	}

	/**
	 * @private
	 */
	public function set_stateToSkinFunction(value:Dynamic):Void
	{
		if(this._stateToSkinFunction == value)
		{
			return;
		}
		this._stateToSkinFunction = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _stateToIconFunction:Dynamic;

	/**
	 * Returns an icon for the current state.
	 *
	 * <p>The following function signature is expected:</p>
	 * <pre>function(target:Button, state:Object, oldIcon:DisplayObject = null):DisplayObject</pre>
	 *
	 * @default null
	 */
	public function get_stateToIconFunction():Function
	{
		return this._stateToIconFunction;
	}

	/**
	 * @private
	 */
	public function set_stateToIconFunction(value:Dynamic):Void
	{
		if(this._stateToIconFunction == value)
		{
			return;
		}
		this._stateToIconFunction = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _stateToLabelPropertiesFunction:Dynamic;

	/**
	 * Returns a text format for the current state.
	 *
	 * <p>The following function signature is expected:</p>
	 * <pre>function(target:Button, state:Object):Object</pre>
	 *
	 * @default null
	 */
	public function get_stateToLabelPropertiesFunction():Function
	{
		return this._stateToLabelPropertiesFunction;
	}

	/**
	 * @private
	 */
	public function set_stateToLabelPropertiesFunction(value:Dynamic):Void
	{
		if(this._stateToLabelPropertiesFunction == value)
		{
			return;
		}
		this._stateToLabelPropertiesFunction = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 * Chooses an appropriate skin based on the state and the selection.
	 */
	private var _skinSelector:StateWithToggleValueSelector = new StateWithToggleValueSelector();
	
	/**
	 * The skin used when no other skin is defined for the current state.
	 * Intended for use when multiple states should use the same skin.
	 *
	 * <p>The following example gives the button a default skin to use for
	 * all states when no specific skin is available:</p>
	 *
	 * <listing version="3.0">
	 * button.defaultSkin = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #stateToSkinFunction
	 * @see #upSkin
	 * @see #downSkin
	 * @see #hoverSkin
	 * @see #disabledSkin
	 */
	public function get_defaultSkin():DisplayObject
	{
		return DisplayObject(this._skinSelector.defaultValue);
	}
	
	/**
	 * @private
	 */
	public function set_defaultSkin(value:DisplayObject):Void
	{
		if(this._skinSelector.defaultValue == value)
		{
			return;
		}
		this._skinSelector.defaultValue = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * The skin used for the button's up state. If <code>null</code>, then
	 * <code>defaultSkin</code> is used instead.
	 *
	 * <p>The following example gives the button a skin for the up state:</p>
	 *
	 * <listing version="3.0">
	 * button.upSkin = new Image( texture );</listing>
	 *
	 * @default null
	 * 
	 * @see #defaultSkin
	 */
	public function get_upSkin():DisplayObject
	{
		return DisplayObject(this._skinSelector.getValueForState(STATE_UP, false));
	}
	
	/**
	 * @private
	 */
	public function set_upSkin(value:DisplayObject):Void
	{
		if(this._skinSelector.getValueForState(STATE_UP, false) == value)
		{
			return;
		}
		this._skinSelector.setValueForState(value, STATE_UP, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * The skin used for the button's down state. If <code>null</code>, then
	 * <code>defaultSkin</code> is used instead.
	 *
	 * <p>The following example gives the button a skin for the down state:</p>
	 *
	 * <listing version="3.0">
	 * button.downSkin = new Image( texture );</listing>
	 *
	 * @default null
	 * 
	 * @see #defaultSkin
	 */
	public function get_downSkin():DisplayObject
	{
		return DisplayObject(this._skinSelector.getValueForState(STATE_DOWN, false));
	}
	
	/**
	 * @private
	 */
	public function set_downSkin(value:DisplayObject):Void
	{
		if(this._skinSelector.getValueForState(STATE_DOWN, false) == value)
		{
			return;
		}
		this._skinSelector.setValueForState(value, STATE_DOWN, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * The skin used for the button's hover state. If <code>null</code>, then
	 * <code>defaultSkin</code> is used instead.
	 *
	 * <p>The following example gives the button a skin for the hover state:</p>
	 *
	 * <listing version="3.0">
	 * button.hoverSkin = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #defaultSkin
	 */
	public function get_hoverSkin():DisplayObject
	{
		return DisplayObject(this._skinSelector.getValueForState(STATE_HOVER, false));
	}

	/**
	 * @private
	 */
	public function set_hoverSkin(value:DisplayObject):Void
	{
		if(this._skinSelector.getValueForState(STATE_HOVER, false) == value)
		{
			return;
		}
		this._skinSelector.setValueForState(value, STATE_HOVER, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * The skin used for the button's disabled state. If <code>null</code>,
	 * then <code>defaultSkin</code> is used instead.
	 *
	 * <p>The following example gives the button a skin for the disabled state:</p>
	 *
	 * <listing version="3.0">
	 * button.disabledSkin = new Image( texture );</listing>
	 *
	 * @default null
	 * 
	 * @see #defaultSkin
	 */
	public function get_disabledSkin():DisplayObject
	{
		return DisplayObject(this._skinSelector.getValueForState(STATE_DISABLED, false));
	}
	
	/**
	 * @private
	 */
	public function set_disabledSkin(value:DisplayObject):Void
	{
		if(this._skinSelector.getValueForState(STATE_DISABLED, false) == value)
		{
			return;
		}
		this._skinSelector.setValueForState(value, STATE_DISABLED, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	private var _labelFactory:Dynamic;

	/**
	 * A function used to instantiate the button's label text renderer
	 * sub-component. By default, the button will use the global text
	 * renderer factory, <code>FeathersControl.defaultTextRendererFactory()</code>,
	 * to create the label text renderer. The label text renderer must be an
	 * instance of <code>ITextRenderer</code>. To change properties on the
	 * label text renderer, see <code>defaultLabelProperties</code> and the
	 * other "<code>LabelProperties</code>" properties for each button
	 * state.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>The following example gives the button a custom factory for the
	 * label text renderer:</p>
	 *
	 * <listing version="3.0">
	 * button.labelFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 * @see feathers.controls.text.BitmapFontTextRenderer
	 * @see feathers.controls.text.TextFieldTextRenderer
	 */
	public function get_labelFactory():Function
	{
		return this._labelFactory;
	}

	/**
	 * @private
	 */
	public function set_labelFactory(value:Dynamic):Void
	{
		if(this._labelFactory == value)
		{
			return;
		}
		this._labelFactory = value;
		this.invalidate(INVALIDATION_FLAG_TEXT_RENDERER);
	}
	
	/**
	 * @private
	 */
	private var _labelPropertiesSelector:StateWithToggleValueSelector = new StateWithToggleValueSelector();
	
	/**
	 * The default label properties are a set of key/value pairs to be
	 * passed down to the button's label text renderer, and it is used when
	 * no specific properties are defined for the button's current state.
	 * Intended for use when multiple states should share the same
	 * properties. The label text renderer is an <code>ITextRenderer</code>
	 * instance. The available properties depend on which <code>ITextRenderer</code>
	 * implementation is returned by <code>labelFactory</code>. The most
	 * common implementations are <code>BitmapFontTextRenderer</code> and
	 * <code>TextFieldTextRenderer</code>.
	 *
	 * <p>The following example gives the button default label properties to
	 * use for all states when no specific label properties are available
	 * (this example assumes that the label text renderer is a
	 * <code>BitmapFontTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * button.defaultLabelProperties.textFormat = new BitmapFontTextFormat( bitmapFont );
	 * button.defaultLabelProperties.wordWrap = true;</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.controls.text.BitmapFontTextRenderer
	 * @see feathers.controls.text.TextFieldTextRenderer
	 * @see #stateToLabelPropertiesFunction
	 */
	public function get_defaultLabelProperties():Object
	{
		var value:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.defaultValue);
		if(!value)
		{
			value = new PropertyProxy(childProperties_onChange);
			this._labelPropertiesSelector.defaultValue = value;
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public function set_defaultLabelProperties(value:Object):Void
	{
		if(!(value is PropertyProxy))
		{
			value = PropertyProxy.fromObject(value);
		}
		var oldValue:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.defaultValue);
		if(oldValue)
		{
			oldValue.removeOnChangeCallback(childProperties_onChange);
		}
		this._labelPropertiesSelector.defaultValue = value;
		if(value)
		{
			PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * A set of key/value pairs to be passed down ot the button's label
	 * text renderer when the button is in the up state. If <code>null</code>,
	 * then <code>defaultLabelProperties</code> is used instead. The label
	 * text renderer is an <code>ITextRenderer</code> instance. The
	 * available properties depend on which <code>ITextRenderer</code>
	 * implementation is returned by <code>labelFactory</code>. The most
	 * common implementations are <code>BitmapFontTextRenderer</code> and
	 * <code>TextFieldTextRenderer</code>.
	 *
	 * <p>The following example gives the button label properties for the
	 * up state:</p>
	 *
	 * <listing version="3.0">
	 * button.upLabelProperties.textFormat = new BitmapFontTextFormat( bitmapFont );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.controls.text.BitmapFontTextRenderer
	 * @see feathers.controls.text.TextFieldTextRenderer
	 * @see #defaultLabelProperties
	 */
	public function get_upLabelProperties():Object
	{
		var value:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_UP, false));
		if(!value)
		{
			value = new PropertyProxy(childProperties_onChange);
			this._labelPropertiesSelector.setValueForState(value, STATE_UP, false);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public function set_upLabelProperties(value:Object):Void
	{
		if(!(value is PropertyProxy))
		{
			value = PropertyProxy.fromObject(value);
		}
		var oldValue:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_UP, false));
		if(oldValue)
		{
			oldValue.removeOnChangeCallback(childProperties_onChange);
		}
		this._labelPropertiesSelector.setValueForState(value, STATE_UP, false);
		if(value)
		{
			PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * A set of key/value pairs to be passed down ot the button's label
	 * text renderer when the button is in the down state. If <code>null</code>,
	 * then <code>defaultLabelProperties</code> is used instead. The label
	 * text renderer is an <code>ITextRenderer</code> instance. The
	 * available properties depend on which <code>ITextRenderer</code>
	 * implementation is returned by <code>labelFactory</code>. The most
	 * common implementations are <code>BitmapFontTextRenderer</code> and
	 * <code>TextFieldTextRenderer</code>.
	 *
	 * <p>The following example gives the button label properties for the
	 * down state:</p>
	 *
	 * <listing version="3.0">
	 * button.downLabelProperties.textFormat = new BitmapFontTextFormat( bitmapFont );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.controls.text.BitmapFontTextRenderer
	 * @see feathers.controls.text.TextFieldTextRenderer
	 * @see #defaultLabelProperties
	 */
	public function get_downLabelProperties():Object
	{
		var value:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_DOWN, false));
		if(!value)
		{
			value = new PropertyProxy(childProperties_onChange);
			this._labelPropertiesSelector.setValueForState(value, STATE_DOWN, false);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public function set_downLabelProperties(value:Object):Void
	{
		if(!(value is PropertyProxy))
		{
			value = PropertyProxy.fromObject(value);
		}
		var oldValue:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_DOWN, false));
		if(oldValue)
		{
			oldValue.removeOnChangeCallback(childProperties_onChange);
		}
		this._labelPropertiesSelector.setValueForState(value, STATE_DOWN, false);
		if(value)
		{
			PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * A set of key/value pairs to be passed down ot the button's label
	 * text renderer when the button is in the hover state. If <code>null</code>,
	 * then <code>defaultLabelProperties</code> is used instead. The label
	 * text renderer is an <code>ITextRenderer</code> instance. The
	 * available properties depend on which <code>ITextRenderer</code>
	 * implementation is returned by <code>labelFactory</code>. The most
	 * common implementations are <code>BitmapFontTextRenderer</code> and
	 * <code>TextFieldTextRenderer</code>.
	 *
	 * <p>The following example gives the button label properties for the
	 * hover state:</p>
	 *
	 * <listing version="3.0">
	 * button.hoverLabelProperties.textFormat = new BitmapFontTextFormat( bitmapFont );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.controls.text.BitmapFontTextRenderer
	 * @see feathers.controls.text.TextFieldTextRenderer
	 * @see #defaultLabelProperties
	 */
	public function get_hoverLabelProperties():Object
	{
		var value:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_HOVER, false));
		if(!value)
		{
			value = new PropertyProxy(childProperties_onChange);
			this._labelPropertiesSelector.setValueForState(value, STATE_HOVER, false);
		}
		return value;
	}

	/**
	 * @private
	 */
	public function set_hoverLabelProperties(value:Object):Void
	{
		if(!(value is PropertyProxy))
		{
			value = PropertyProxy.fromObject(value);
		}
		var oldValue:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_HOVER, false));
		if(oldValue)
		{
			oldValue.removeOnChangeCallback(childProperties_onChange);
		}
		this._labelPropertiesSelector.setValueForState(value, STATE_HOVER, false);
		if(value)
		{
			PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * A set of key/value pairs to be passed down ot the button's label
	 * text renderer when the button is in the disabled state. If <code>null</code>,
	 * then <code>defaultLabelProperties</code> is used instead. The label
	 * text renderer is an <code>ITextRenderer</code> instance. The
	 * available properties depend on which <code>ITextRenderer</code>
	 * implementation is returned by <code>labelFactory</code>. The most
	 * common implementations are <code>BitmapFontTextRenderer</code> and
	 * <code>TextFieldTextRenderer</code>.
	 *
	 * <p>The following example gives the button label properties for the
	 * disabled state:</p>
	 *
	 * <listing version="3.0">
	 * button.disabledLabelProperties.textFormat = new BitmapFontTextFormat( bitmapFont );</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.controls.text.BitmapFontTextRenderer
	 * @see feathers.controls.text.TextFieldTextRenderer
	 * @see #defaultLabelProperties
	 */
	public function get_disabledLabelProperties():Object
	{
		var value:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_DISABLED, false));
		if(!value)
		{
			value = new PropertyProxy(childProperties_onChange);
			this._labelPropertiesSelector.setValueForState(value, STATE_DISABLED, false);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public function set_disabledLabelProperties(value:Object):Void
	{
		if(!(value is PropertyProxy))
		{
			value = PropertyProxy.fromObject(value);
		}
		var oldValue:PropertyProxy = PropertyProxy(this._labelPropertiesSelector.getValueForState(STATE_DISABLED, false));
		if(oldValue)
		{
			oldValue.removeOnChangeCallback(childProperties_onChange);
		}
		this._labelPropertiesSelector.setValueForState(value, STATE_DISABLED, false);
		if(value)
		{
			PropertyProxy(value).addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private var _iconSelector:StateWithToggleValueSelector = new StateWithToggleValueSelector();
	
	/**
	 * The icon used when no other icon is defined for the current state.
	 * Intended for use when multiple states should use the same icon.
	 *
	 * <p>The following example gives the button a default icon to use for
	 * all states when no specific icon is available:</p>
	 *
	 * <listing version="3.0">
	 * button.defaultIcon = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #stateToIconFunction
	 * @see #upIcon
	 * @see #downIcon
	 * @see #hoverIcon
	 * @see #disabledIcon
	 */
	public function get_defaultIcon():DisplayObject
	{
		return DisplayObject(this._iconSelector.defaultValue);
	}
	
	/**
	 * @private
	 */
	public function set_defaultIcon(value:DisplayObject):Void
	{
		if(this._iconSelector.defaultValue == value)
		{
			return;
		}
		this._iconSelector.defaultValue = value;
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * The icon used for the button's up state. If <code>null</code>, then
	 * <code>defaultIcon</code> is used instead.
	 *
	 * <p>The following example gives the button an icon for the up state:</p>
	 *
	 * <listing version="3.0">
	 * button.upIcon = new Image( texture );</listing>
	 *
	 * @default null
	 * 
	 * @see #defaultIcon
	 */
	public function get_upIcon():DisplayObject
	{
		return DisplayObject(this._iconSelector.getValueForState(STATE_UP, false));
	}
	
	/**
	 * @private
	 */
	public function set_upIcon(value:DisplayObject):Void
	{
		if(this._iconSelector.getValueForState(STATE_UP, false) == value)
		{
			return;
		}
		this._iconSelector.setValueForState(value, STATE_UP, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * The icon used for the button's down state. If <code>null</code>, then
	 * <code>defaultIcon</code> is used instead.
	 *
	 * <p>The following example gives the button an icon for the down state:</p>
	 *
	 * <listing version="3.0">
	 * button.downIcon = new Image( texture );</listing>
	 *
	 * @default null
	 * 
	 * @see #defaultIcon
	 */
	public function get_downIcon():DisplayObject
	{
		return DisplayObject(this._iconSelector.getValueForState(STATE_DOWN, false));
	}
	
	/**
	 * @private
	 */
	public function set_downIcon(value:DisplayObject):Void
	{
		if(this._iconSelector.getValueForState(STATE_DOWN, false) == value)
		{
			return;
		}
		this._iconSelector.setValueForState(value, STATE_DOWN, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * The icon used for the button's hover state. If <code>null</code>, then
	 * <code>defaultIcon</code> is used instead.
	 *
	 * <p>The following example gives the button an icon for the hover state:</p>
	 *
	 * <listing version="3.0">
	 * button.hoverIcon = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #defaultIcon
	 */
	public function get_hoverIcon():DisplayObject
	{
		return DisplayObject(this._iconSelector.getValueForState(STATE_HOVER, false));
	}

	/**
	 * @private
	 */
	public function set_hoverIcon(value:DisplayObject):Void
	{
		if(this._iconSelector.getValueForState(STATE_HOVER, false) == value)
		{
			return;
		}
		this._iconSelector.setValueForState(value, STATE_HOVER, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * The icon used for the button's disabled state. If <code>null</code>, then
	 * <code>defaultIcon</code> is used instead.
	 *
	 * <p>The following example gives the button an icon for the disabled state:</p>
	 *
	 * <listing version="3.0">
	 * button.disabledIcon = new Image( texture );</listing>
	 *
	 * @default null
	 * 
	 * @see #defaultIcon
	 */
	public function get_disabledIcon():DisplayObject
	{
		return DisplayObject(this._iconSelector.getValueForState(STATE_DISABLED, false));
	}
	
	/**
	 * @private
	 */
	public function set_disabledIcon(value:DisplayObject):Void
	{
		if(this._iconSelector.getValueForState(STATE_DISABLED, false) == value)
		{
			return;
		}
		this._iconSelector.setValueForState(value, STATE_DISABLED, false);
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 * Used for determining the duration of a long press.
	 */
	private var _touchBeginTime:Int;

	/**
	 * @private
	 */
	private var _hasLongPressed:Bool = false;

	/**
	 * @private
	 */
	private var _longPressDuration:Float = 0.5;

	/**
	 * The duration, in seconds, of a long press.
	 *
	 * <p>The following example changes the long press duration to one full second:</p>
	 *
	 * <listing version="3.0">
	 * button.longPressDuration = 1.0;</listing>
	 *
	 * @default 0.5
	 *
	 * @see #event:longPress
	 * @see #isLongPressEnabled
	 */
	public function get_longPressDuration():Float
	{
		return this._longPressDuration;
	}

	/**
	 * @private
	 */
	public function set_longPressDuration(value:Float):Void
	{
		this._longPressDuration = value;
	}

	/**
	 * @private
	 */
	private var _isLongPressEnabled:Bool = false;

	/**
	 * Determines if <code>FeathersEventType.LONG_PRESS</code> will be
	 * dispatched.
	 *
	 * <p>The following example enables long presses:</p>
	 *
	 * <listing version="3.0">
	 * button.isLongPressEnabled = true;
	 * button.addEventListener( FeathersEventType.LONG_PRESS, function( event:Event ):Void
	 * {
	 *     // long press
	 * });</listing>
	 *
	 * @default false
	 *
	 * @see #event:longPress
	 * @see #longPressDuration
	 */
	public function get_isLongPressEnabled():Bool
	{
		return this._isLongPressEnabled;
	}

	/**
	 * @private
	 */
	public function set_isLongPressEnabled(value:Bool):Void
	{
		this._isLongPressEnabled = value;
		if(!value)
		{
			this.removeEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
		}
	}
	
	/**
	 * @private
	 */
	override private function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_STYLES);
		var sizeInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_SIZE);
		var stateInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_STATE);
		var textRendererInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_TEXT_RENDERER);
		var focusInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_FOCUS);

		if(textRendererInvalid)
		{
			this.createLabel();
		}
		
		if(textRendererInvalid || stateInvalid || dataInvalid)
		{
			this.refreshLabel();
		}

		if(stylesInvalid || stateInvalid)
		{
			this.refreshSkin();
			this.refreshIcon();
		}

		if(textRendererInvalid || stylesInvalid || stateInvalid)
		{
			this.refreshLabelStyles();
		}

		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		if(stylesInvalid || stateInvalid || sizeInvalid)
		{
			this.scaleSkin();
		}
		
		if(textRendererInvalid || stylesInvalid || stateInvalid || dataInvalid || sizeInvalid)
		{
			this.layoutContent();
		}

		if(sizeInvalid || focusInvalid)
		{
			this.refreshFocusIndicator();
		}
	}

	/**
	 * If the component's dimensions have not been set explicitly, it will
	 * measure its content and determine an ideal size for itself. If the
	 * <code>explicitWidth</code> or <code>explicitHeight</code> member
	 * variables are set, those value will be used without additional
	 * measurement. If one is set, but not the other, the dimension with the
	 * explicit value will not be measured, but the other non-explicit
	 * dimension will still need measurement.
	 *
	 * <p>Calls <code>setSizeInternal()</code> to set up the
	 * <code>actualWidth</code> and <code>actualHeight</code> member
	 * variables used for layout.</p>
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 */
	private function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this.explicitWidth != this.explicitWidth; //isNaN
		var needsHeight:Bool = this.explicitHeight != this.explicitHeight; //isNaN
		if(!needsWidth && !needsHeight)
		{
			return false;
		}
		this.refreshMaxLabelWidth(true);
		if(this.labelTextRenderer)
		{
			this.labelTextRenderer.measureText(HELPER_POINT);
		}
		else
		{
			HELPER_POINT.setTo(0, 0);
		}
		var newWidth:Float = this.explicitWidth;
		if(needsWidth)
		{
			if(this.currentIcon && this.label)
			{
				if(this._iconPosition != ICON_POSITION_TOP && this._iconPosition != ICON_POSITION_BOTTOM &&
					this._iconPosition != ICON_POSITION_MANUAL)
				{
					var adjustedGap:Float = this._gap;
					if(adjustedGap == Float.POSITIVE_INFINITY)
					{
						adjustedGap = this._minGap;
					}
					newWidth = this.currentIcon.width + adjustedGap + HELPER_POINT.x;
				}
				else
				{
					newWidth = Math.max(this.currentIcon.width, HELPER_POINT.x);
				}
			}
			else if(this.currentIcon)
			{
				newWidth = this.currentIcon.width;
			}
			else if(this.label)
			{
				newWidth = HELPER_POINT.x;
			}
			newWidth += this._paddingLeft + this._paddingRight;
			if(newWidth != newWidth) //isNaN
			{
				newWidth = this._originalSkinWidth;
				if(newWidth != newWidth)
				{
					newWidth = 0;
				}
			}
			else if(this._originalSkinWidth == this._originalSkinWidth) //!isNaN
			{
				if(this._originalSkinWidth > newWidth)
				{
					newWidth = this._originalSkinWidth;
				}
			}
		}

		var newHeight:Float = this.explicitHeight;
		if(needsHeight)
		{
			if(this.currentIcon && this.label)
			{
				if(this._iconPosition == ICON_POSITION_TOP || this._iconPosition == ICON_POSITION_BOTTOM)
				{
					adjustedGap = this._gap;
					if(adjustedGap == Float.POSITIVE_INFINITY)
					{
						adjustedGap = this._minGap;
					}
					newHeight = this.currentIcon.height + adjustedGap + HELPER_POINT.y;
				}
				else
				{
					newHeight = Math.max(this.currentIcon.height, HELPER_POINT.y);
				}
			}
			else if(this.currentIcon)
			{
				newHeight = this.currentIcon.height;
			}
			else if(this.label)
			{
				newHeight = HELPER_POINT.y;
			}
			newHeight += this._paddingTop + this._paddingBottom;
			if(newHeight != newHeight)
			{
				newHeight = this._originalSkinHeight;
				if(newHeight != newHeight)
				{
					newHeight = 0;
				}
			}
			else if(this._originalSkinHeight == this._originalSkinHeight) //!isNaN
			{
				if(this._originalSkinHeight > newHeight)
				{
					newHeight = this._originalSkinHeight;
				}
			}
		}

		return this.setSizeInternal(newWidth, newHeight, false);
	}

	/**
	 * Creates the label text renderer sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #labelTextRenderer
	 * @see #labelFactory
	 */
	private function createLabel():Void
	{
		if(this.labelTextRenderer)
		{
			this.removeChild(DisplayObject(this.labelTextRenderer), true);
			this.labelTextRenderer = null;
		}

		if(this._hasLabelTextRenderer)
		{
			var factory:Dynamic = this._labelFactory != null ? this._labelFactory : FeathersControl.defaultTextRendererFactory;
			this.labelTextRenderer = ITextRenderer(factory());
			this.labelTextRenderer.styleNameList.add(this.labelName);
			this.addChild(DisplayObject(this.labelTextRenderer));
		}
	}

	/**
	 * @private
	 */
	private function refreshLabel():Void
	{
		if(!this.labelTextRenderer)
		{
			return;
		}
		this.labelTextRenderer.text = this._label;
		this.labelTextRenderer.visible = this._label != null && this._label.length > 0;
		this.labelTextRenderer.isEnabled = this._isEnabled;
	}

	/**
	 * Sets the <code>currentSkin</code> property.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function refreshSkin():Void
	{
		var oldSkin:DisplayObject = this.currentSkin;
		if(this._stateToSkinFunction != null)
		{
			this.currentSkin = DisplayObject(this._stateToSkinFunction(this, this._currentState, oldSkin));
		}
		else
		{
			this.currentSkin = DisplayObject(this._skinSelector.updateValue(this, this._currentState, this.currentSkin));
		}
		if(this.currentSkin != oldSkin)
		{
			if(oldSkin)
			{
				this.removeChild(oldSkin, false);
			}
			if(this.currentSkin)
			{
				this.addChildAt(this.currentSkin, 0);
			}
		}
		if(this.currentSkin &&
			(this._originalSkinWidth != this._originalSkinWidth || //isNaN
			this._originalSkinHeight != this._originalSkinHeight))
		{
			if(this.currentSkin is IValidating)
			{
				IValidating(this.currentSkin).validate();
			}
			this._originalSkinWidth = this.currentSkin.width;
			this._originalSkinHeight = this.currentSkin.height;
		}
	}
	
	/**
	 * Sets the <code>currentIcon</code> property.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function refreshIcon():Void
	{
		var oldIcon:DisplayObject = this.currentIcon;
		if(this._stateToIconFunction != null)
		{
			this.currentIcon = DisplayObject(this._stateToIconFunction(this, this._currentState, oldIcon));
		}
		else
		{
			this.currentIcon = DisplayObject(this._iconSelector.updateValue(this, this._currentState, this.currentIcon));
		}
		if(this.currentIcon is IFeathersControl)
		{
			IFeathersControl(this.currentIcon).isEnabled = this._isEnabled;
		}
		if(this.currentIcon != oldIcon)
		{
			if(oldIcon)
			{
				this.removeChild(oldIcon, false);
			}
			if(this.currentIcon)
			{
				//we want the icon to appear below the label text renderer
				var index:Int = this.numChildren;
				if(this.labelTextRenderer)
				{
					index = this.getChildIndex(DisplayObject(this.labelTextRenderer));
				}
				this.addChildAt(this.currentIcon, index);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshLabelStyles():Void
	{
		if(!this.labelTextRenderer)
		{
			return;
		}
		if(this._stateToLabelPropertiesFunction != null)
		{
			var properties:Object = this._stateToLabelPropertiesFunction(this, this._currentState);
		}
		else
		{
			properties = this._labelPropertiesSelector.updateValue(this, this._currentState);
		}
		for(var propertyName:String in properties)
		{
			var propertyValue:Object = properties[propertyName];
			this.labelTextRenderer[propertyName] = propertyValue;
		}
	}
	
	/**
	 * @private
	 */
	private function scaleSkin():Void
	{
		if(!this.currentSkin)
		{
			return;
		}
		this.currentSkin.x = 0;
		this.currentSkin.y = 0;
		if(this.currentSkin.width != this.actualWidth)
		{
			this.currentSkin.width = this.actualWidth;
		}
		if(this.currentSkin.height != this.actualHeight)
		{
			this.currentSkin.height = this.actualHeight;
		}
		if(this.currentSkin is IValidating)
		{
			IValidating(this.currentSkin).validate();
		}
	}
	
	/**
	 * Positions and sizes the button's content.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function layoutContent():Void
	{
		this.refreshMaxLabelWidth(false);
		if(this._label && this.labelTextRenderer && this.currentIcon)
		{
			this.labelTextRenderer.validate();
			this.positionSingleChild(DisplayObject(this.labelTextRenderer));
			if(this._iconPosition != ICON_POSITION_MANUAL)
			{
				this.positionLabelAndIcon();
			}

		}
		else if(this._label && this.labelTextRenderer && !this.currentIcon)
		{
			this.labelTextRenderer.validate();
			this.positionSingleChild(DisplayObject(this.labelTextRenderer));
		}
		else if((!this._label || !this.labelTextRenderer) && this.currentIcon && this._iconPosition != ICON_POSITION_MANUAL)
		{
			this.positionSingleChild(this.currentIcon);
		}

		if(this.currentIcon)
		{
			if(this._iconPosition == ICON_POSITION_MANUAL)
			{
				this.currentIcon.x = this._paddingLeft;
				this.currentIcon.y = this._paddingTop;
			}
			this.currentIcon.x += this._iconOffsetX;
			this.currentIcon.y += this._iconOffsetY;
		}
		if(this._label && this.labelTextRenderer)
		{
			this.labelTextRenderer.x += this._labelOffsetX;
			this.labelTextRenderer.y += this._labelOffsetY;
		}
	}

	/**
	 * @private
	 */
	private function refreshMaxLabelWidth(forMeasurement:Bool):Void
	{
		if(this.currentIcon is IValidating)
		{
			IValidating(this.currentIcon).validate();
		}
		var calculatedWidth:Float = this.actualWidth;
		if(forMeasurement)
		{
			calculatedWidth = this.explicitWidth;
			if(calculatedWidth != calculatedWidth) //isNaN
			{
				calculatedWidth = this._maxWidth;
			}
		}
		if(this._label && this.labelTextRenderer && this.currentIcon)
		{
			if(this._iconPosition == ICON_POSITION_LEFT || this._iconPosition == ICON_POSITION_LEFT_BASELINE ||
				this._iconPosition == ICON_POSITION_RIGHT || this._iconPosition == ICON_POSITION_RIGHT_BASELINE)
			{
				var adjustedGap:Float = this._gap;
				if(adjustedGap == Float.POSITIVE_INFINITY)
				{
					adjustedGap = this._minGap;
				}
				this.labelTextRenderer.maxWidth = calculatedWidth - this._paddingLeft - this._paddingRight - this.currentIcon.width - adjustedGap;
			}
			else
			{
				this.labelTextRenderer.maxWidth = calculatedWidth - this._paddingLeft - this._paddingRight;
			}

		}
		else if(this._label && this.labelTextRenderer && !this.currentIcon)
		{
			this.labelTextRenderer.maxWidth = calculatedWidth - this._paddingLeft - this._paddingRight;
		}
	}
	
	/**
	 * @private
	 */
	private function positionSingleChild(displayObject:DisplayObject):Void
	{
		if(this._horizontalAlign == HORIZONTAL_ALIGN_LEFT)
		{
			displayObject.x = this._paddingLeft;
		}
		else if(this._horizontalAlign == HORIZONTAL_ALIGN_RIGHT)
		{
			displayObject.x = this.actualWidth - this._paddingRight - displayObject.width;
		}
		else //center
		{
			displayObject.x = this._paddingLeft + Math.round((this.actualWidth - this._paddingLeft - this._paddingRight - displayObject.width) / 2);
		}
		if(this._verticalAlign == VERTICAL_ALIGN_TOP)
		{
			displayObject.y = this._paddingTop;
		}
		else if(this._verticalAlign == VERTICAL_ALIGN_BOTTOM)
		{
			displayObject.y = this.actualHeight - this._paddingBottom - displayObject.height;
		}
		else //middle
		{
			displayObject.y = this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - displayObject.height) / 2);
		}
	}
	
	/**
	 * @private
	 */
	private function positionLabelAndIcon():Void
	{
		if(this._iconPosition == ICON_POSITION_TOP)
		{
			if(this._gap == Float.POSITIVE_INFINITY)
			{
				this.currentIcon.y = this._paddingTop;
				this.labelTextRenderer.y = this.actualHeight - this._paddingBottom - this.labelTextRenderer.height;
			}
			else
			{
				if(this._verticalAlign == VERTICAL_ALIGN_TOP)
				{
					this.labelTextRenderer.y += this.currentIcon.height + this._gap;
				}
				else if(this._verticalAlign == VERTICAL_ALIGN_MIDDLE)
				{
					this.labelTextRenderer.y += Math.round((this.currentIcon.height + this._gap) / 2);
				}
				this.currentIcon.y = this.labelTextRenderer.y - this.currentIcon.height - this._gap;
			}
		}
		else if(this._iconPosition == ICON_POSITION_RIGHT || this._iconPosition == ICON_POSITION_RIGHT_BASELINE)
		{
			if(this._gap == Float.POSITIVE_INFINITY)
			{
				this.labelTextRenderer.x = this._paddingLeft;
				this.currentIcon.x = this.actualWidth - this._paddingRight - this.currentIcon.width;
			}
			else
			{
				if(this._horizontalAlign == HORIZONTAL_ALIGN_RIGHT)
				{
					this.labelTextRenderer.x -= this.currentIcon.width + this._gap;
				}
				else if(this._horizontalAlign == HORIZONTAL_ALIGN_CENTER)
				{
					this.labelTextRenderer.x -= Math.round((this.currentIcon.width + this._gap) / 2);
				}
				this.currentIcon.x = this.labelTextRenderer.x + this.labelTextRenderer.width + this._gap;
			}
		}
		else if(this._iconPosition == ICON_POSITION_BOTTOM)
		{
			if(this._gap == Float.POSITIVE_INFINITY)
			{
				this.labelTextRenderer.y = this._paddingTop;
				this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
			}
			else
			{
				if(this._verticalAlign == VERTICAL_ALIGN_BOTTOM)
				{
					this.labelTextRenderer.y -= this.currentIcon.height + this._gap;
				}
				else if(this._verticalAlign == VERTICAL_ALIGN_MIDDLE)
				{
					this.labelTextRenderer.y -= Math.round((this.currentIcon.height + this._gap) / 2);
				}
				this.currentIcon.y = this.labelTextRenderer.y + this.labelTextRenderer.height + this._gap;
			}
		}
		else if(this._iconPosition == ICON_POSITION_LEFT || this._iconPosition == ICON_POSITION_LEFT_BASELINE)
		{
			if(this._gap == Float.POSITIVE_INFINITY)
			{
				this.currentIcon.x = this._paddingLeft;
				this.labelTextRenderer.x = this.actualWidth - this._paddingRight - this.labelTextRenderer.width;
			}
			else
			{
				if(this._horizontalAlign == HORIZONTAL_ALIGN_LEFT)
				{
					this.labelTextRenderer.x += this._gap + this.currentIcon.width;
				}
				else if(this._horizontalAlign == HORIZONTAL_ALIGN_CENTER)
				{
					this.labelTextRenderer.x += Math.round((this._gap + this.currentIcon.width) / 2);
				}
				this.currentIcon.x = this.labelTextRenderer.x - this._gap - this.currentIcon.width;
			}
		}
		
		if(this._iconPosition == ICON_POSITION_LEFT || this._iconPosition == ICON_POSITION_RIGHT)
		{
			if(this._verticalAlign == VERTICAL_ALIGN_TOP)
			{
				this.currentIcon.y = this._paddingTop;
			}
			else if(this._verticalAlign == VERTICAL_ALIGN_BOTTOM)
			{
				this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
			}
			else
			{
				this.currentIcon.y = this._paddingTop + Math.round((this.actualHeight - this._paddingTop - this._paddingBottom - this.currentIcon.height) / 2);
			}
		}
		else if(this._iconPosition == ICON_POSITION_LEFT_BASELINE || this._iconPosition == ICON_POSITION_RIGHT_BASELINE)
		{
			this.currentIcon.y = this.labelTextRenderer.y + (this.labelTextRenderer.baseline) - this.currentIcon.height;
		}
		else //top or bottom
		{
			if(this._horizontalAlign == HORIZONTAL_ALIGN_LEFT)
			{
				this.currentIcon.x = this._paddingLeft;
			}
			else if(this._horizontalAlign == HORIZONTAL_ALIGN_RIGHT)
			{
				this.currentIcon.x = this.actualWidth - this._paddingRight - this.currentIcon.width;
			}
			else
			{
				this.currentIcon.x = this._paddingLeft + Math.round((this.actualWidth - this._paddingLeft - this._paddingRight - this.currentIcon.width) / 2);
			}
		}
	}

	/**
	 * @private
	 */
	private function resetTouchState(touch:Touch = null):Void
	{
		this.touchPointID = -1;
		this.removeEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
		if(this._isEnabled)
		{
			this.currentState = STATE_UP;
		}
		else
		{
			this.currentState = STATE_DISABLED;
		}
	}

	/**
	 * Triggers the button.
	 */
	private function trigger():Void
	{
		this.dispatchEventWith(Event.TRIGGERED);
	}

	/**
	 * @private
	 */
	private function childProperties_onChange(proxy:PropertyProxy, name:Object):Void
	{
		this.invalidate(INVALIDATION_FLAG_STYLES);
	}

	/**
	 * @private
	 */
	override private function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
	}

	/**
	 * @private
	 */
	override private function focusOutHandler(event:Event):Void
	{
		super.focusOutHandler(event);
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		this.stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);

		if(this.touchPointID >= 0)
		{
			this.touchPointID = -1;
			if(this._isEnabled)
			{
				this.currentState = STATE_UP;
			}
			else
			{
				this.currentState = STATE_DISABLED;
			}
		}
	}

	/**
	 * @private
	 */
	private function button_removedFromStageHandler(event:Event):Void
	{
		this.resetTouchState();
	}
	
	/**
	 * @private
	 */
	private function button_touchHandler(event:TouchEvent):Void
	{
		if(!this._isEnabled)
		{
			this.touchPointID = -1;
			return;
		}

		if(this.touchPointID >= 0)
		{
			var touch:Touch = event.getTouch(this, null, this.touchPointID);
			if(!touch)
			{
				//this should never happen
				return;
			}

			touch.getLocation(this.stage, HELPER_POINT);
			var isInBounds:Bool = this.contains(this.stage.hitTest(HELPER_POINT, true));
			if(touch.phase == TouchPhase.MOVED)
			{
				if(isInBounds || this.keepDownStateOnRollOut)
				{
					this.currentState = STATE_DOWN;
				}
				else
				{
					this.currentState = STATE_UP;
				}
			}
			else if(touch.phase == TouchPhase.ENDED)
			{
				this.resetTouchState(touch);
				//we we dispatched a long press, then triggered and change
				//won't be able to happen until the next touch begins
				if(!this._hasLongPressed && isInBounds)
				{
					this.trigger();
				}
			}
			return;
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this, TouchPhase.BEGAN);
			if(touch)
			{
				this.currentState = STATE_DOWN;
				this.touchPointID = touch.id;
				if(this._isLongPressEnabled)
				{
					this._touchBeginTime = getTimer();
					this._hasLongPressed = false;
					this.addEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
				}
				return;
			}
			touch = event.getTouch(this, TouchPhase.HOVER);
			if(touch)
			{
				this.currentState = STATE_HOVER;
				return;
			}

			//end of hover
			this.currentState = STATE_UP;
		}
	}

	/**
	 * @private
	 */
	private function longPress_enterFrameHandler(event:Event):Void
	{
		var accumulatedTime:Float = (getTimer() - this._touchBeginTime) / 1000;
		if(accumulatedTime >= this._longPressDuration)
		{
			this.removeEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
			this._hasLongPressed = true;
			this.dispatchEventWith(FeathersEventType.LONG_PRESS);
		}
	}

	/**
	 * @private
	 */
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		if(event.keyCode == Keyboard.ESCAPE)
		{
			this.touchPointID = -1;
			this.currentState = STATE_UP;
		}
		if(this.touchPointID >= 0 || event.keyCode != Keyboard.SPACE)
		{
			return;
		}
		this.touchPointID = Int.MAX_VALUE;
		this.currentState = STATE_DOWN;
	}

	/**
	 * @private
	 */
	private function stage_keyUpHandler(event:KeyboardEvent):Void
	{
		if(this.touchPointID != Int.MAX_VALUE || event.keyCode != Keyboard.SPACE)
		{
			return;
		}
		this.resetTouchState();
		this.trigger();
	}
}