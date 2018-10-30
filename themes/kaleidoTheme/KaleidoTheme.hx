/*
 Copyright (c) 2012 Josh Tynjala
 Edited for Beekyr Reloaded port to HAXE in October 2018.
 Not everything is working but it is there mostly.

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
package feathers.themes.kaleidoTheme;



import feathers.controls.Button;
import feathers.controls.ButtonGroup;
import feathers.controls.Callout;
import feathers.controls.Check;
import feathers.controls.Header;
import feathers.controls.ImageLoader;
import feathers.controls.Label;
import feathers.controls.PageIndicator;
import feathers.controls.PickerList;
import feathers.controls.ProgressBar;
import feathers.controls.Radio;
import feathers.controls.Screen;
import feathers.controls.ScrollText;
import feathers.controls.SimpleScrollBar;
import feathers.controls.Slider;
import feathers.controls.TabBar;
import feathers.controls.TextInput;
import feathers.controls.ToggleSwitch;
import feathers.controls.popups.CalloutPopUpContentManager;
import feathers.controls.popups.VerticalCenteredPopUpContentManager;
import feathers.controls.renderers.BaseDefaultItemRenderer;
import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
import feathers.controls.renderers.DefaultGroupedListItemRenderer;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.text.StageTextTextEditor;
import feathers.controls.text.TextFieldTextRenderer;
import feathers.core.DisplayListWatcher;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.display.Scale3Image;
import feathers.display.Scale9Image;
import feathers.layout.VerticalLayout;
import feathers.skins.ImageStateValueSelector;
import feathers.skins.Scale9ImageStateValueSelector;
import feathers.skins.StandardIcons;
import feathers.system.DeviceCapabilities;
import feathers.textures.Scale3Textures;
import feathers.textures.Scale9Textures;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.events.Event;
import starling.text.BitmapFont;
import starling.textures.Texture;
import starling.textures.TextureAtlas;



class KaleidoTheme extends DisplayListWatcher
{
    public var originalDPI(get, never) : Int;
    public var scaleToDPI(get, never) : Bool;

   
    private static inline var PROGRESS_BAR_SCALE_3_FIRST_REGION : Float = 12;
    private static inline var PROGRESS_BAR_SCALE_3_SECOND_REGION : Float = 12;
    private static var BUTTON_SCALE_9_GRID : Rectangle = new Rectangle(8, 8, 15, 49);
    private static inline var SLIDER_FIRST : Float = 16;
    private static inline var SLIDER_SECOND : Float = 8;
    private static var CALLOUT_SCALE_9_GRID : Rectangle = new Rectangle(8, 24, 15, 33);
    private static var SCROLL_BAR_THUMB_SCALE_9_GRID : Rectangle = new Rectangle(4, 4, 4, 4);
    
    private static inline var BACKGROUND_COLOR : Int = 0x13171a;
    public static inline var PRIMARY_TEXT_COLOR : Int = 0xffffff;
    private static inline var SELECTED_TEXT_COLOR : Int = 0xe5e5e5;
    
    private static inline var ORIGINAL_DPI_IPHONE_RETINA : Int = 326;
    private static inline var ORIGINAL_DPI_IPAD_RETINA : Int = 264;
    
    private static function textRendererFactory() : TextFieldTextRenderer
    {
        return new TextFieldTextRenderer();
    }
    
    private static function textEditorFactory() : StageTextTextEditor
    {
        return new StageTextTextEditor();
    }
    
    public function new(root : DisplayObjectContainer, scaleToDPI : Bool = true)
    {
        super(root);
        Starling.current.nativeStage.color = BACKGROUND_COLOR;
        if (root.stage!=null)
        {
            root.stage.color = BACKGROUND_COLOR;
        }
        else
        {
            root.addEventListener(Event.ADDED_TO_STAGE, root_addedToStageHandler);
        }
        _scaleToDPI = scaleToDPI;
        initialize();
    }
    
    private var _originalDPI : Int;
    
    private function get_originalDPI() : Int
    {
        return _originalDPI;
    }
    
    private var _scaleToDPI : Bool;
    
    private function get_scaleToDPI() : Bool
    {
        return _scaleToDPI;
    }
    
    private var scale : Float;
    public var fontSize : Int;
    public var fontName : String;
    public var fontBold : Bool;
    
    private var atlas : TextureAtlas;
    private var atlasBitmapData : BitmapData;
    
    private var bitmapFont : BitmapFont;
    
    private var buttonUpSkinTextures : Scale9Textures;
    private var buttonDownSkinTextures : Scale9Textures;
    private var buttonDisabledSkinTextures : Scale9Textures;
    
    private var hSliderMinimumTrackUpSkinTextures : Scale3Textures;
    private var hSliderMinimumTrackDownSkinTextures : Scale3Textures;
    private var hSliderMinimumTrackDisabledSkinTextures : Scale3Textures;
    
    private var hSliderMaximumTrackUpSkinTextures : Scale3Textures;
    private var hSliderMaximumTrackDownSkinTextures : Scale3Textures;
    private var hSliderMaximumTrackDisabledSkinTextures : Scale3Textures;
    
    private var vSliderMinimumTrackUpSkinTextures : Scale3Textures;
    private var vSliderMinimumTrackDownSkinTextures : Scale3Textures;
    private var vSliderMinimumTrackDisabledSkinTextures : Scale3Textures;
    
    private var vSliderMaximumTrackUpSkinTextures : Scale3Textures;
    private var vSliderMaximumTrackDownSkinTextures : Scale3Textures;
    private var vSliderMaximumTrackDisabledSkinTextures : Scale3Textures;
    
    private var sliderThumbUpSkinTexture : Texture;
    private var sliderThumbDownSkinTexture : Texture;
    private var sliderThumbDisabledSkinTexture : Texture;
    
    private var scrollBarThumbSkinTextures : Scale9Textures;
    
    private var progressBarBackgroundSkinTextures : Scale3Textures;
    private var progressBarBackgroundDisabledSkinTextures : Scale3Textures;
    private var progressBarFillSkinTextures : Scale3Textures;
    private var progressBarFillDisabledSkinTextures : Scale3Textures;
    
    private var insetBackgroundSkinTextures : Scale9Textures;
    private var insetBackgroundDisabledSkinTextures : Scale9Textures;
    
    private var pickerIconTexture : Texture;
    
    private var listItemUpTexture : Texture;
    private var listItemDownTexture : Texture;
    
    private var groupedListHeaderBackgroundSkinTexture : Texture;
    
    private var toolBarBackgroundSkinTexture : Texture;
    
    private var tabSelectedSkinTexture : Texture;
    
    private var calloutBackgroundSkinTextures : Scale9Textures;
    private var calloutTopArrowSkinTexture : Texture;
    private var calloutBottomArrowSkinTexture : Texture;
    private var calloutLeftArrowSkinTexture : Texture;
    private var calloutRightArrowSkinTexture : Texture;
    
    private var checkUpIconTexture : Texture;
    private var checkDownIconTexture : Texture;
    private var checkDisabledIconTexture : Texture;
    private var checkSelectedUpIconTexture : Texture;
    private var checkSelectedDownIconTexture : Texture;
    private var checkSelectedDisabledIconTexture : Texture;
    
    private var radioUpIconTexture : Texture;
    private var radioDownIconTexture : Texture;
    private var radioDisabledIconTexture : Texture;
    private var radioSelectedUpIconTexture : Texture;
    private var radioSelectedDisabledIconTexture : Texture;
    
    private var pageIndicatorSelectedSkinTexture : Texture;
    private var pageIndicatorNormalSkinTexture : Texture;
	
    
    override public function dispose() : Void
    {
        if (root != null)
        {
            root.removeEventListener(Event.ADDED_TO_STAGE, root_addedToStageHandler);
        }
        if (atlas != null)
        {
            atlas.dispose();
            atlas = null;
        }
        if (atlasBitmapData != null)
        {
            atlasBitmapData.dispose();
            atlasBitmapData = null;
        }
        super.dispose();
    }
    
    private function initialize() : Void
    {
        var scaledDPI : Int = Std.int(DeviceCapabilities.dpi / Starling.current.contentScaleFactor);
        if (_scaleToDPI)
        {
            if (DeviceCapabilities.isTablet(Starling.current.nativeStage))
            {
                _originalDPI = ORIGINAL_DPI_IPAD_RETINA;
            }
            else
            {
                _originalDPI = ORIGINAL_DPI_IPHONE_RETINA;
            }
        }
        else
        {
            _originalDPI = scaledDPI;
        }
        scale = scaledDPI / _originalDPI;
        fontBold = true;
		
		fontSize = initFontSize();
       
        
        Callout.stagePaddingTop = Callout.stagePaddingRight = Callout.stagePaddingBottom =
                                Callout.stagePaddingLeft = 16 * scale;
        

		atlas = getUsedAtlas();					

    
        buttonUpSkinTextures = new Scale9Textures(atlas.getTexture("button-up-skin"), BUTTON_SCALE_9_GRID);
        buttonDownSkinTextures = new Scale9Textures(atlas.getTexture("button-down-skin"), BUTTON_SCALE_9_GRID);
        buttonDisabledSkinTextures = new Scale9Textures(atlas.getTexture("button-disabled-skin"), BUTTON_SCALE_9_GRID);
      		
        hSliderMinimumTrackUpSkinTextures = new Scale3Textures(atlas.getTexture("hslider-minimum-track-up-skin"), SLIDER_FIRST, SLIDER_SECOND, Scale3Textures.DIRECTION_HORIZONTAL);
        hSliderMinimumTrackDownSkinTextures = new Scale3Textures(atlas.getTexture("hslider-minimum-track-down-skin"), SLIDER_FIRST, SLIDER_SECOND, Scale3Textures.DIRECTION_HORIZONTAL);
        hSliderMinimumTrackDisabledSkinTextures = new Scale3Textures(atlas.getTexture("hslider-minimum-track-disabled-skin"), SLIDER_FIRST, SLIDER_SECOND, Scale3Textures.DIRECTION_HORIZONTAL);
        
        hSliderMaximumTrackUpSkinTextures = new Scale3Textures(atlas.getTexture("hslider-maximum-track-up-skin"), 0, SLIDER_SECOND, Scale3Textures.DIRECTION_HORIZONTAL);
        hSliderMaximumTrackDownSkinTextures = new Scale3Textures(atlas.getTexture("hslider-maximum-track-down-skin"), 0, SLIDER_SECOND, Scale3Textures.DIRECTION_HORIZONTAL);
        hSliderMaximumTrackDisabledSkinTextures = new Scale3Textures(atlas.getTexture("hslider-maximum-track-disabled-skin"), 0, SLIDER_SECOND, Scale3Textures.DIRECTION_HORIZONTAL);
        
        vSliderMinimumTrackUpSkinTextures = new Scale3Textures(atlas.getTexture("vslider-minimum-track-up-skin"), 0, SLIDER_SECOND, Scale3Textures.DIRECTION_VERTICAL);
        vSliderMinimumTrackDownSkinTextures = new Scale3Textures(atlas.getTexture("vslider-minimum-track-down-skin"), 0, SLIDER_SECOND, Scale3Textures.DIRECTION_VERTICAL);
        vSliderMinimumTrackDisabledSkinTextures = new Scale3Textures(atlas.getTexture("vslider-minimum-track-disabled-skin"), 0, SLIDER_SECOND, Scale3Textures.DIRECTION_VERTICAL);
        
        vSliderMaximumTrackUpSkinTextures = new Scale3Textures(atlas.getTexture("vslider-maximum-track-up-skin"), SLIDER_FIRST, SLIDER_SECOND, Scale3Textures.DIRECTION_VERTICAL);
        vSliderMaximumTrackDownSkinTextures = new Scale3Textures(atlas.getTexture("vslider-maximum-track-down-skin"), SLIDER_FIRST, SLIDER_SECOND, Scale3Textures.DIRECTION_VERTICAL);
        vSliderMaximumTrackDisabledSkinTextures = new Scale3Textures(atlas.getTexture("vslider-maximum-track-disabled-skin"), SLIDER_FIRST, SLIDER_SECOND, Scale3Textures.DIRECTION_VERTICAL);
        
        sliderThumbUpSkinTexture = atlas.getTexture("slider-thumb-up-skin");
        sliderThumbDownSkinTexture = atlas.getTexture("slider-thumb-down-skin");
        sliderThumbDisabledSkinTexture = atlas.getTexture("slider-thumb-disabled-skin");
        
        scrollBarThumbSkinTextures = new Scale9Textures(atlas.getTexture("simple-scroll-bar-thumb-skin"), SCROLL_BAR_THUMB_SCALE_9_GRID);
        
        progressBarBackgroundSkinTextures = new Scale3Textures(atlas.getTexture("progress-bar-background-skin"), PROGRESS_BAR_SCALE_3_FIRST_REGION, PROGRESS_BAR_SCALE_3_SECOND_REGION, Scale3Textures.DIRECTION_HORIZONTAL);
        progressBarBackgroundDisabledSkinTextures = new Scale3Textures(atlas.getTexture("progress-bar-background-disabled-skin"), PROGRESS_BAR_SCALE_3_FIRST_REGION, PROGRESS_BAR_SCALE_3_SECOND_REGION, Scale3Textures.DIRECTION_HORIZONTAL);
        progressBarFillSkinTextures = new Scale3Textures(atlas.getTexture("progress-bar-fill-skin"), PROGRESS_BAR_SCALE_3_FIRST_REGION, PROGRESS_BAR_SCALE_3_SECOND_REGION, Scale3Textures.DIRECTION_HORIZONTAL);
        progressBarFillDisabledSkinTextures = new Scale3Textures(atlas.getTexture("progress-bar-fill-disabled-skin"), PROGRESS_BAR_SCALE_3_FIRST_REGION, PROGRESS_BAR_SCALE_3_SECOND_REGION, Scale3Textures.DIRECTION_HORIZONTAL);
        
        insetBackgroundSkinTextures = new Scale9Textures(atlas.getTexture("inset-skin"), BUTTON_SCALE_9_GRID);
        insetBackgroundDisabledSkinTextures = new Scale9Textures(atlas.getTexture("inset-disabled-skin"), BUTTON_SCALE_9_GRID);
        
        pickerIconTexture = atlas.getTexture("picker-icon");
        
        listItemUpTexture = atlas.getTexture("list-item-up-skin");
        listItemDownTexture = atlas.getTexture("list-item-down-skin");
        
        groupedListHeaderBackgroundSkinTexture = atlas.getTexture("grouped-list-header-background-skin");
        
        toolBarBackgroundSkinTexture = atlas.getTexture("toolbar-background-skin");
        
        tabSelectedSkinTexture = atlas.getTexture("tab-selected-skin");
        
        calloutBackgroundSkinTextures = new Scale9Textures(atlas.getTexture("callout-background-skin"), CALLOUT_SCALE_9_GRID);
        calloutTopArrowSkinTexture = atlas.getTexture("callout-arrow-top-skin");
        calloutBottomArrowSkinTexture = atlas.getTexture("callout-arrow-bottom-skin");
        calloutLeftArrowSkinTexture = atlas.getTexture("callout-arrow-left-skin");
        calloutRightArrowSkinTexture = atlas.getTexture("callout-arrow-right-skin");
        
        checkUpIconTexture = atlas.getTexture("check-up-icon");
        checkDownIconTexture = atlas.getTexture("check-down-icon");
        checkDisabledIconTexture = atlas.getTexture("check-disabled-icon");
        checkSelectedUpIconTexture = atlas.getTexture("check-selected-up-icon");
        checkSelectedDownIconTexture = atlas.getTexture("check-selected-down-icon");
        checkSelectedDisabledIconTexture = atlas.getTexture("check-selected-disabled-icon");
        
        radioUpIconTexture = atlas.getTexture("radio-up-icon");
        radioDownIconTexture = atlas.getTexture("radio-down-icon");
        radioDisabledIconTexture = atlas.getTexture("radio-disabled-icon");
        radioSelectedUpIconTexture = atlas.getTexture("radio-selected-up-icon");
        radioSelectedDisabledIconTexture = atlas.getTexture("radio-selected-disabled-icon");
        
        pageIndicatorNormalSkinTexture = atlas.getTexture("page-indicator-normal-skin");
        pageIndicatorSelectedSkinTexture = atlas.getTexture("page-indicator-selected-skin");
        
        FeathersControl.defaultTextRendererFactory = textRendererFactory;
        FeathersControl.defaultTextEditorFactory = textEditorFactory;
        
        StandardIcons.listDrillDownAccessoryTexture = atlas.getTexture("list-accessory-drill-down-icon");
        
        setInitializerForClassAndSubclasses(Screen, screenInitializer);
        setInitializerForClass(Label, labelInitializer);
        setInitializerForClass(ScrollText, scrollTextInitializer);
        setInitializerForClass(TextFieldTextRenderer, itemRendererAccessoryLabelInitializer, BaseDefaultItemRenderer.DEFAULT_CHILD_NAME_ACCESSORY_LABEL);
        setInitializerForClass(Button, buttonInitializer);
        setInitializerForClass(Button, buttonGroupButtonInitializer, ButtonGroup.DEFAULT_CHILD_NAME_BUTTON);
        setInitializerForClass(Button, tabInitializer, TabBar.DEFAULT_CHILD_NAME_TAB);
        setInitializerForClass(Button, headerButtonInitializer, Header.DEFAULT_CHILD_NAME_ITEM);
        setInitializerForClass(Button, scrollBarThumbInitializer, SimpleScrollBar.DEFAULT_CHILD_NAME_THUMB);
        setInitializerForClass(Button, sliderThumbInitializer, Slider.DEFAULT_CHILD_NAME_THUMB);
        setInitializerForClass(Button, pickerListButtonInitializer, PickerList.DEFAULT_CHILD_NAME_BUTTON);
        setInitializerForClass(Button, toggleSwitchOnTrackInitializer, ToggleSwitch.DEFAULT_CHILD_NAME_ON_TRACK);
        setInitializerForClass(Button, nothingInitializer, Slider.DEFAULT_CHILD_NAME_MINIMUM_TRACK);
        setInitializerForClass(Button, nothingInitializer, Slider.DEFAULT_CHILD_NAME_MAXIMUM_TRACK);
        setInitializerForClass(ButtonGroup, buttonGroupInitializer);
        setInitializerForClass(Slider, sliderInitializer);
        setInitializerForClass(SimpleScrollBar, scrollBarInitializer);
       // setInitializerForClass(Check, checkInitializer);
       // setInitializerForClass(Radio, radioInitializer);
        setInitializerForClass(ToggleSwitch, toggleSwitchInitializer);
        setInitializerForClass(DefaultListItemRenderer, itemRendererInitializer);
        setInitializerForClass(DefaultGroupedListItemRenderer, itemRendererInitializer);
        setInitializerForClass(DefaultGroupedListHeaderOrFooterRenderer, headerOrFooterRendererInitializer);
        setInitializerForClass(PickerList, pickerListInitializer);
        setInitializerForClass(Header, headerInitializer);
        setInitializerForClass(TextInput, textInputInitializer);
       // setInitializerForClass(PageIndicator, pageIndicatorInitializer);
       // setInitializerForClass(ProgressBar, progressBarInitializer);
        setInitializerForClass(Callout, calloutInitializer);
		
		
    }
	
	private function initFontSize():Int {
		return Std.int(30 * scale);
       
	}
	
	private function getUsedAtlas():TextureAtlas {
		//here you need to return the atlas where the images have been uploaded.
		
	}
    
    private function pageIndicatorNormalSymbolFactory() : DisplayObject
    {
        var symbol : ImageLoader = new ImageLoader();
        symbol.source = pageIndicatorNormalSkinTexture;
        symbol.textureScale = scale;
        return symbol;
    }
    
    private function pageIndicatorSelectedSymbolFactory() : DisplayObject
    {
        var symbol : ImageLoader = new ImageLoader();
        symbol.source = pageIndicatorSelectedSkinTexture;
        symbol.textureScale = scale;
        return symbol;
    }
    
    private function imageLoaderFactory() : ImageLoader
    {
        var image : ImageLoader = new ImageLoader();
        image.textureScale = scale;
        return image;
    }
    
    private function nothingInitializer(nothing : IFeathersControl) : Void
    {
    }
    
    private function screenInitializer(screen : Screen) : Void
    {  //screen.originalDPI = _originalDPI;  
        
    }
    
    private function labelInitializer(label : Label) : Void
    {
        label.textRendererProperties.setProperty("textFormat", new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold));
        label.textRendererProperties.setProperty("embedFonts", true);
    }
    
    
    
    private function scrollTextInitializer(text : ScrollText) : Void
    {
        text.textFormat = new TextFormat("Lato,Roboto,Helvetica,Arial,_sans", fontSize, PRIMARY_TEXT_COLOR, fontBold);
        text.paddingTop = text.paddingBottom = text.paddingLeft = 32 * scale;
        text.paddingRight = 36 * scale;
    }
    
    private function itemRendererAccessoryLabelInitializer(renderer : TextFieldTextRenderer) : Void
    {
       renderer.textFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
       renderer.embedFonts = true;
    }
    
    private function buttonInitializer(button : Button) : Void
    {
		
		//trace("buttonInitializer!");
        var skinSelector : Scale9ImageStateValueSelector= new Scale9ImageStateValueSelector();
        skinSelector.defaultValue = buttonUpSkinTextures;
        skinSelector.defaultSelectedValue = buttonDownSkinTextures;
        skinSelector.setValueForState(buttonDownSkinTextures, Button.STATE_DOWN, false);
        skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
        skinSelector.imageProperties.setProperty("width", 66 * scale);
        skinSelector.imageProperties.setProperty("height", 66 * scale);
        skinSelector.imageProperties.setProperty("textureScale", scale);
              
        button.stateToSkinFunction = skinSelector.updateValue;
        button.defaultLabelProperties.setProperty("textFormat", new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR));

        button.paddingTop = button.paddingBottom = 8 * scale;
        button.paddingLeft = button.paddingRight = 16 * scale;
        button.gap = 12 * scale;
        button.minWidth = button.minHeight = 66 * scale;
        button.minTouchWidth = button.minTouchHeight = 88 * scale;
    }
    
    private function buttonGroupButtonInitializer(button : Button) : Void
    {
        var skinSelector : Scale9ImageStateValueSelector = new Scale9ImageStateValueSelector();
        skinSelector.defaultValue = buttonUpSkinTextures;
        skinSelector.defaultSelectedValue = buttonDownSkinTextures;
        skinSelector.setValueForState(buttonDownSkinTextures, Button.STATE_DOWN, false);
        skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
        skinSelector.imageProperties.setProperty("width", 88 * scale);
        skinSelector.imageProperties.setProperty("height", 88 * scale);
        skinSelector.imageProperties.setProperty("textureScale", scale);
        button.stateToSkinFunction = skinSelector.updateValue;
        
	 
        button.paddingTop = button.paddingBottom = 8 * scale;
        button.paddingLeft = button.paddingRight = 16 * scale;
        button.gap = 12 * scale;
        button.minWidth = button.minHeight = 88 * scale;
        button.minTouchWidth = button.minTouchHeight = 88 * scale;
    }
    
    private function pickerListButtonInitializer(button : Button) : Void
    //styles for the pickerlist button come from above, and then we're
    {
        
        //adding a little bit extra.
        buttonInitializer(button);
        
        var pickerListButtonDefaultIcon : Image = new Image(pickerIconTexture);
        pickerListButtonDefaultIcon.scaleX = pickerListButtonDefaultIcon.scaleY = scale;
        button.defaultIcon = pickerListButtonDefaultIcon;
        button.gap = Math.POSITIVE_INFINITY;  //fill as completely as possible  
        button.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
        button.iconPosition = Button.ICON_POSITION_RIGHT;
    }
    
    private function toggleSwitchOnTrackInitializer(track : Button) : Void
    {
        var defaultSkin : Scale9Image = new Scale9Image(insetBackgroundSkinTextures, scale);
        defaultSkin.width = 200 * scale;
        defaultSkin.height = 66 * scale;
        track.defaultSkin = defaultSkin;
        track.minTouchWidth = track.minTouchHeight = 88 * scale;
    }
    
    private function scrollBarThumbInitializer(thumb : Button) : Void
    {
        var scrollBarDefaultSkin : Scale9Image = new Scale9Image(scrollBarThumbSkinTextures, scale);
        scrollBarDefaultSkin.width = 8 * scale;
        scrollBarDefaultSkin.height = 8 * scale;
        thumb.defaultSkin = scrollBarDefaultSkin;
        thumb.minTouchWidth = thumb.minTouchHeight = 12 * scale;
    }
    
    private function sliderThumbInitializer(thumb : Button) : Void
    {
        var skinSelector : ImageStateValueSelector = new ImageStateValueSelector();
        skinSelector.defaultValue = sliderThumbUpSkinTexture;
        skinSelector.defaultSelectedValue = tabSelectedSkinTexture;
        skinSelector.setValueForState(sliderThumbDownSkinTexture, Button.STATE_DOWN, false);
        skinSelector.setValueForState(sliderThumbDisabledSkinTexture, Button.STATE_DISABLED, false);
        skinSelector.imageProperties.setProperty("width", 66 * scale);
        skinSelector.imageProperties.setProperty("height", 66 * scale);
     
        thumb.stateToSkinFunction = skinSelector.updateValue;
        
        thumb.minTouchWidth = thumb.minTouchHeight = 88 * scale;
    }
    
    private function tabInitializer(tab : Button) : Void
    {
        var skinSelector : ImageStateValueSelector = new ImageStateValueSelector();
        skinSelector.defaultValue = toolBarBackgroundSkinTexture;
        skinSelector.defaultSelectedValue = tabSelectedSkinTexture;
        skinSelector.setValueForState(tabSelectedSkinTexture, Button.STATE_DOWN, false);
        skinSelector.imageProperties.setProperty("width", 88 * scale);
        skinSelector.imageProperties.setProperty("height", 88 * scale);

        tab.stateToSkinFunction = skinSelector.updateValue;
        
        tab.minWidth = tab.minHeight = 88 * scale;
        tab.minTouchWidth = tab.minTouchHeight = 88 * scale;
        tab.paddingTop = tab.paddingRight = tab.paddingBottom =
                                tab.paddingLeft = 16 * scale;
        tab.gap = 12 * scale;
        tab.iconPosition = Button.ICON_POSITION_TOP;
        
       // tab.defaultLabelProperties.textFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
    }
    
    private function headerButtonInitializer(button : Button) : Void
    {
        var skinSelector : Scale9ImageStateValueSelector = new Scale9ImageStateValueSelector();
        skinSelector.defaultValue = buttonUpSkinTextures;
        skinSelector.defaultSelectedValue = buttonDownSkinTextures;
        skinSelector.setValueForState(buttonDownSkinTextures, Button.STATE_DOWN, false);
        skinSelector.setValueForState(buttonDisabledSkinTextures, Button.STATE_DISABLED, false);
		skinSelector.imageProperties.setProperty("width", 60 * scale);
        skinSelector.imageProperties.setProperty("height", 60 * scale);
        skinSelector.imageProperties.setProperty("textureScale", scale);
        button.stateToSkinFunction = skinSelector.updateValue;
        
		var tf :TextFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
		
        //button.defaultLabelProperties.textFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
        button.defaultLabelProperties.setProperty("textFormat", tf);// = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
      
        button.paddingTop = button.paddingBottom = 8 * scale;
        button.paddingLeft = button.paddingRight = 16 * scale;
        button.gap = 12 * scale;
        button.minWidth = button.minHeight = 60 * scale;
        button.minTouchWidth = button.minTouchHeight = 88 * scale;
    }
    
    private function buttonGroupInitializer(group : ButtonGroup) : Void
    {
        group.minWidth = 560 * scale;
        group.gap = 18 * scale;
    }
    
    private function sliderInitializer(slider : Slider) : Void
    {
        slider.trackLayoutMode = Slider.TRACK_LAYOUT_MODE_MIN_MAX;
		 var sliderMinimumTrackDefaultSkin : Scale3Image;
		  var sliderMinimumTrackDownSkin : Scale3Image;
		  var sliderMinimumTrackDisabledSkin : Scale3Image;
		  var sliderMaximumTrackDefaultSkin : Scale3Image;
		  var sliderMaximumTrackDownSkin : Scale3Image;
		  var sliderMaximumTrackDisabledSkin : Scale3Image;
        if (slider.direction == Slider.DIRECTION_VERTICAL)
        {
            sliderMinimumTrackDefaultSkin = new Scale3Image(vSliderMinimumTrackUpSkinTextures, scale);
            sliderMinimumTrackDefaultSkin.width *= scale;
            sliderMinimumTrackDefaultSkin.height = 198 * scale;
            sliderMinimumTrackDownSkin = new Scale3Image(vSliderMinimumTrackDownSkinTextures, scale);
            sliderMinimumTrackDownSkin.width *= scale;
            sliderMinimumTrackDownSkin.height = 198 * scale;
            sliderMinimumTrackDisabledSkin = new Scale3Image(vSliderMinimumTrackDisabledSkinTextures, scale);
            sliderMinimumTrackDisabledSkin.width *= scale;
            sliderMinimumTrackDisabledSkin.height = 198 * scale;
            slider.minimumTrackProperties.setProperty("defaultSkin", sliderMinimumTrackDefaultSkin);
            slider.minimumTrackProperties.setProperty("downSkin", sliderMinimumTrackDownSkin);
            slider.minimumTrackProperties.setProperty("disabledSkin", sliderMinimumTrackDisabledSkin);
            
            sliderMaximumTrackDefaultSkin  = new Scale3Image(vSliderMaximumTrackUpSkinTextures, scale);
            sliderMaximumTrackDefaultSkin.width *= scale;
            sliderMaximumTrackDefaultSkin.height = 198 * scale;
            sliderMaximumTrackDownSkin  = new Scale3Image(vSliderMaximumTrackDownSkinTextures, scale);
            sliderMaximumTrackDownSkin.width *= scale;
            sliderMaximumTrackDownSkin.height = 198 * scale;
            sliderMaximumTrackDisabledSkin = new Scale3Image(vSliderMaximumTrackDisabledSkinTextures, scale);
            sliderMaximumTrackDisabledSkin.width *= scale;
            sliderMaximumTrackDisabledSkin.height = 198 * scale;
            slider.maximumTrackProperties.setProperty("defaultSkin", sliderMaximumTrackDefaultSkin);
            slider.maximumTrackProperties.setProperty("downSkin", sliderMaximumTrackDownSkin);
            slider.maximumTrackProperties.setProperty("disabledSkin", sliderMaximumTrackDisabledSkin);
        }
        //horizontal
        else
        {
            
            {
                sliderMinimumTrackDefaultSkin = new Scale3Image(hSliderMinimumTrackUpSkinTextures, scale);
                sliderMinimumTrackDefaultSkin.width = 198 * scale;
                sliderMinimumTrackDefaultSkin.height *= scale;
                sliderMinimumTrackDownSkin = new Scale3Image(hSliderMinimumTrackDownSkinTextures, scale);
                sliderMinimumTrackDownSkin.width = 198 * scale;
                sliderMinimumTrackDownSkin.height *= scale;
                sliderMinimumTrackDisabledSkin = new Scale3Image(hSliderMinimumTrackDisabledSkinTextures, scale);
                sliderMinimumTrackDisabledSkin.width = 198 * scale;
                sliderMinimumTrackDisabledSkin.height *= scale;
                slider.minimumTrackProperties.setProperty("defaultSkin", sliderMinimumTrackDefaultSkin);
                slider.minimumTrackProperties.setProperty("downSkin", sliderMinimumTrackDownSkin);
                slider.minimumTrackProperties.setProperty("disabledSkin", sliderMinimumTrackDisabledSkin);
                
                sliderMaximumTrackDefaultSkin = new Scale3Image(hSliderMaximumTrackUpSkinTextures, scale);
                sliderMaximumTrackDefaultSkin.width = 198 * scale;
                sliderMaximumTrackDefaultSkin.height *= scale;
                sliderMaximumTrackDownSkin = new Scale3Image(hSliderMaximumTrackDownSkinTextures, scale);
                sliderMaximumTrackDownSkin.width = 198 * scale;
                sliderMaximumTrackDownSkin.height *= scale;
                sliderMaximumTrackDisabledSkin = new Scale3Image(hSliderMaximumTrackDisabledSkinTextures, scale);
                sliderMaximumTrackDisabledSkin.width = 198 * scale;
                sliderMaximumTrackDisabledSkin.height *= scale;
                slider.maximumTrackProperties.setProperty("defaultSkin", sliderMaximumTrackDefaultSkin);
                slider.maximumTrackProperties.setProperty("downSkin", sliderMaximumTrackDownSkin);
                slider.maximumTrackProperties.setProperty("disabledSkin", sliderMaximumTrackDisabledSkin);
            }
        }
    }
    
    private function scrollBarInitializer(scrollBar : SimpleScrollBar) : Void
    {
        scrollBar.paddingTop = scrollBar.paddingRight = scrollBar.paddingBottom =
                                scrollBar.paddingLeft = 2 * scale;
    }
    
    private function checkInitializer(check : Check) : Void
    {
        var iconSelector : ImageStateValueSelector = new ImageStateValueSelector();
        iconSelector.defaultValue = checkUpIconTexture;
        iconSelector.defaultSelectedValue = checkSelectedUpIconTexture;
        iconSelector.setValueForState(checkDownIconTexture, Button.STATE_DOWN, false);
        iconSelector.setValueForState(checkDisabledIconTexture, Button.STATE_DISABLED, false);
        iconSelector.setValueForState(checkSelectedDownIconTexture, Button.STATE_DOWN, true);
        iconSelector.setValueForState(checkSelectedDisabledIconTexture, Button.STATE_DISABLED, true);

		iconSelector.imageProperties.setProperty("scaleX", scale);
        iconSelector.imageProperties.setProperty("scaleY", scale);
       
				
				
				
        check.stateToIconFunction = iconSelector.updateValue;
        
        //check.defaultLabelProperties.textFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
       // check.defaultSelectedLabelProperties.textFormat = new TextFormat(fontName, fontSize, SELECTED_TEXT_COLOR, fontBold);
        
        check.minTouchWidth = check.minTouchHeight = 88 * scale;
        check.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
        check.verticalAlign = Button.VERTICAL_ALIGN_MIDDLE;
    }
    
    private function radioInitializer(radio : Radio) : Void
    {
        var iconSelector : ImageStateValueSelector = new ImageStateValueSelector();
        iconSelector.defaultValue = radioUpIconTexture;
        iconSelector.defaultSelectedValue = radioSelectedUpIconTexture;
        iconSelector.setValueForState(radioDownIconTexture, Button.STATE_DOWN, false);
        iconSelector.setValueForState(radioDisabledIconTexture, Button.STATE_DISABLED, false);
        iconSelector.setValueForState(radioSelectedDisabledIconTexture, Button.STATE_DISABLED, true);
        iconSelector.imageProperties.setProperty("scaleX", scale);
        iconSelector.imageProperties.setProperty("scaleY", scale);
       
        radio.stateToIconFunction = iconSelector.updateValue;
        
        //radio.defaultLabelProperties.textFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
        //radio.defaultSelectedLabelProperties.textFormat = new TextFormat(fontName, fontSize, SELECTED_TEXT_COLOR, fontBold);
        
        radio.minTouchWidth = radio.minTouchHeight = 88 * scale;
        radio.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
        radio.verticalAlign = Button.VERTICAL_ALIGN_MIDDLE;
    }
    
    private function toggleSwitchInitializer(toggleSwitch : ToggleSwitch) : Void
    {
        toggleSwitch.trackLayoutMode = ToggleSwitch.TRACK_LAYOUT_MODE_SINGLE;
        
        //toggleSwitch.defaultLabelProperties.textFormat = new TextFormat(fontName, Std.int(fontSize * 0.9), PRIMARY_TEXT_COLOR, fontBold);
       // toggleSwitch.onLabelProperties.textFormat = new TextFormat(fontName, Std.int(fontSize * 0.9), SELECTED_TEXT_COLOR, fontBold);
    }
    
    private function itemRendererInitializer(renderer : BaseDefaultItemRenderer) : Void
    {
		
		
        var skinSelector : ImageStateValueSelector = new ImageStateValueSelector();
        skinSelector.defaultValue = listItemUpTexture;
        skinSelector.defaultSelectedValue = listItemDownTexture;
        skinSelector.setValueForState(listItemDownTexture, Button.STATE_DOWN, false);
		skinSelector.imageProperties.setProperty("width", 88 * scale);
        skinSelector.imageProperties.setProperty("height", 88 * scale);
        skinSelector.imageProperties.setProperty("blendMode", BlendMode.NONE);
		
        renderer.stateToSkinFunction = skinSelector.updateValue;
        
        renderer.defaultLabelProperties.setProperty("textFormat", new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold));
         
        renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
        renderer.paddingTop = renderer.paddingBottom = 11 * scale;
        renderer.paddingLeft = renderer.paddingRight = 20 * scale;
        renderer.minWidth = 88 * scale;
        renderer.minHeight = 88 * scale;
        
        renderer.gap = 10 * scale;
        renderer.iconPosition = Button.ICON_POSITION_LEFT;
        renderer.accessoryGap = Math.POSITIVE_INFINITY;
        renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
        
        renderer.accessoryLoaderFactory = imageLoaderFactory;
        renderer.iconLoaderFactory = imageLoaderFactory;
		
		
		//renderer.fac.itemRendererFactory.
		// _list.itemRendererProperties.setProperty("iconSourceField","thumbnail");
       // _list.itemRendererProperties.setProperty("labelField","label");
    }
    
    private function headerOrFooterRendererInitializer(renderer : DefaultGroupedListHeaderOrFooterRenderer) : Void
    {
        var backgroundSkin : Image = new Image(groupedListHeaderBackgroundSkinTexture);
        backgroundSkin.width = 44 * scale;
        backgroundSkin.height = 44 * scale;
        renderer.backgroundSkin = backgroundSkin;
        
        //renderer.contentLabelProperties.textFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
        
        renderer.paddingTop = renderer.paddingBottom = 9 * scale;
        renderer.paddingLeft = renderer.paddingRight = 16 * scale;
        renderer.minWidth = renderer.minHeight = 44 * scale;
        
        renderer.contentLoaderFactory = imageLoaderFactory;
    }
    
    private function pickerListInitializer(list : PickerList) : Void
    {
       trace("PICKER LIST INITIALIZER!");
		
		
		if (DeviceCapabilities.isTablet(Starling.current.nativeStage))
        {
            list.popUpContentManager = new CalloutPopUpContentManager();
        }
        else
        {
            var centerStage : VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
            centerStage.marginTop = centerStage.marginRight = centerStage.marginBottom =
                                    centerStage.marginLeft = 16 * scale;
            list.popUpContentManager = centerStage;
        }
        
        var layout : VerticalLayout = new VerticalLayout();
        layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_BOTTOM;
        layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
        layout.useVirtualLayout = true;
        layout.gap = 0;
        layout.paddingTop = layout.paddingRight = layout.paddingBottom =layout.paddingLeft = 0;
        list.listProperties.setProperty("layout", layout);
       
		
		
		// list.listProperties.setProperty("scrollerProperties", Scroller.SCROLL_POLICY_ON);
		//ORIGINAL AS3
		//list.listProperties.@scrollerProperties.verticalScrollPolicy = Scroller.SCROLL_POLICY_ON;
        
        if (DeviceCapabilities.isTablet(Starling.current.nativeStage))
        {
            list.listProperties.setProperty("minWidth", 264 * scale);
            list.listProperties.setProperty("maxHeight", 352 * scale);
        }
        else
        {
            var backgroundSkin : Scale9Image = new Scale9Image(insetBackgroundSkinTextures, scale);
            backgroundSkin.width = 20 * scale;
            backgroundSkin.height = 20 * scale;
            list.listProperties.setProperty("backgroundSkin", backgroundSkin);
            list.listProperties.setProperty("paddingTop", 8 * scale);
            list.listProperties.setProperty("paddingRight", 8 * scale);
            list.listProperties.setProperty("paddingBottom", 8 * scale);
            list.listProperties.setProperty("paddingLeft", 8 * scale);
		
        }
    }
    
    private function headerInitializer(header : Header) : Void
    {
        var backgroundSkin : Image = new Image(toolBarBackgroundSkinTexture);
        backgroundSkin.width = 88 * scale;
        backgroundSkin.height = 88 * scale;
        backgroundSkin.blendMode = BlendMode.NONE;
        header.backgroundSkin = backgroundSkin;
       // header.titleProperties.textFormat = new TextFormat(fontName, fontSize, PRIMARY_TEXT_COLOR, fontBold);
        header.paddingTop = header.paddingRight = header.paddingBottom =
                                header.paddingLeft = 14 * scale;
        header.minHeight = 88 * scale;
		
		header.titleProperties.setProperty("textFormat", new TextFormat(Assets.FONT_NAME_MENU, fontSize, 0xffffff, false));
        header.titleProperties.setProperty("embedFonts", true);
    }
    
    private function textInputInitializer(input : TextInput) : Void
    {
        input.minWidth = input.minHeight = 66 * scale;
        input.minTouchWidth = input.minTouchHeight = 66 * scale;
        input.paddingTop = input.paddingBottom = 14 * scale;
        input.paddingLeft = input.paddingRight = 16 * scale;
        input.textEditorProperties.setProperty("fontFamily", "Helvetica");
        input.textEditorProperties.setProperty("fontSiz", 30 * scale);
        input.textEditorProperties.setProperty("color", 0xffffff);
        
        var backgroundSkin : Scale9Image = new Scale9Image(insetBackgroundSkinTextures, scale);
        backgroundSkin.width = 264 * scale;
        backgroundSkin.height = 66 * scale;
        input.backgroundSkin = backgroundSkin;
        
        var backgroundDisabledSkin : Scale9Image = new Scale9Image(insetBackgroundDisabledSkinTextures, scale);
        backgroundDisabledSkin.width = 264 * scale;
        backgroundDisabledSkin.height = 66 * scale;
        input.backgroundDisabledSkin = backgroundDisabledSkin;
    }
    
    private function pageIndicatorInitializer(pageIndicator : PageIndicator) : Void
    {
        pageIndicator.normalSymbolFactory = pageIndicatorNormalSymbolFactory;
        pageIndicator.selectedSymbolFactory = pageIndicatorSelectedSymbolFactory;
        pageIndicator.gap = 6 * scale;
        pageIndicator.paddingTop = pageIndicator.paddingRight = pageIndicator.paddingBottom =
                                pageIndicator.paddingLeft = 6 * scale;
        pageIndicator.minTouchWidth = pageIndicator.minTouchHeight = 44 * scale;
    }
    
    private function progressBarInitializer(progress : ProgressBar) : Void
    {
        var backgroundSkin : Scale3Image = new Scale3Image(progressBarBackgroundSkinTextures, scale);
        backgroundSkin.width = ((progress.direction == ProgressBar.DIRECTION_HORIZONTAL) ? 264 : 24) * scale;
        backgroundSkin.height = ((progress.direction == ProgressBar.DIRECTION_HORIZONTAL) ? 24 : 264) * scale;
        progress.backgroundSkin = backgroundSkin;
        
        var backgroundDisabledSkin : Scale3Image = new Scale3Image(progressBarBackgroundDisabledSkinTextures, scale);
        backgroundDisabledSkin.width = ((progress.direction == ProgressBar.DIRECTION_HORIZONTAL) ? 264 : 24) * scale;
        backgroundDisabledSkin.height = ((progress.direction == ProgressBar.DIRECTION_HORIZONTAL) ? 24 : 264) * scale;
        progress.backgroundDisabledSkin = backgroundDisabledSkin;
        
        var fillSkin : Scale3Image = new Scale3Image(progressBarFillSkinTextures, scale);
        fillSkin.width = 24 * scale;
        fillSkin.height = 24 * scale;
        progress.fillSkin = fillSkin;
        
        var fillDisabledSkin : Scale3Image = new Scale3Image(progressBarFillDisabledSkinTextures, scale);
        fillDisabledSkin.width = 24 * scale;
        fillDisabledSkin.height = 24 * scale;
        progress.fillDisabledSkin = fillDisabledSkin;
    }
    
    private function calloutInitializer(callout : Callout) : Void
    {
        callout.paddingTop = callout.paddingRight = callout.paddingBottom =
                                callout.paddingLeft = 16 * scale;
        
        var backgroundSkin : Scale9Image = new Scale9Image(calloutBackgroundSkinTextures, scale);
        backgroundSkin.width = 48 * scale;
        backgroundSkin.height = 48 * scale;
        callout.backgroundSkin = backgroundSkin;
        
        var topArrowSkin : Image = new Image(calloutTopArrowSkinTexture);
        topArrowSkin.scaleX = topArrowSkin.scaleY = scale;
        callout.topArrowSkin = topArrowSkin;
        callout.topArrowGap = 0 * scale;
        
        var bottomArrowSkin : Image = new Image(calloutBottomArrowSkinTexture);
        bottomArrowSkin.scaleX = bottomArrowSkin.scaleY = scale;
        callout.bottomArrowSkin = bottomArrowSkin;
        callout.bottomArrowGap = -1 * scale;
        
        var leftArrowSkin : Image = new Image(calloutLeftArrowSkinTexture);
        leftArrowSkin.scaleX = leftArrowSkin.scaleY = scale;
        callout.leftArrowSkin = leftArrowSkin;
        callout.leftArrowGap = 0 * scale;
        
        var rightArrowSkin : Image = new Image(calloutRightArrowSkinTexture);
        rightArrowSkin.scaleX = rightArrowSkin.scaleY = scale;
        callout.rightArrowSkin = rightArrowSkin;
        callout.rightArrowGap = -1 * scale;
    }
    
    private function root_addedToStageHandler(event : Event) : Void
    {
        cast((event.currentTarget), DisplayObject).stage.color = BACKGROUND_COLOR;
    }
}
