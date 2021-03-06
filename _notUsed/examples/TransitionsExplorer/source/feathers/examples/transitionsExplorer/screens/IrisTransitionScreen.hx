package feathers.examples.transitionsExplorer.screens;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.motion.Iris;

import starling.display.DisplayObject;

import starling.events.Event;

class IrisTransitionScreen extends PanelScreen
{
	private static function irisCloseAtRandomPosition(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Dynamic):Void
	{
		var randomX:Float = Math.random() * (oldScreen != null ? oldScreen.width : newScreen.width);
		var randomY:Float = Math.random() * (oldScreen != null ? oldScreen.height : newScreen.height);
		Iris.createIrisCloseTransitionAt(randomX, randomY)(oldScreen, newScreen, completeCallback);
	}
	
	private static function irisOpenAtRandomPosition(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Dynamic):Void
	{
		var randomX:Float = Math.random() * (oldScreen != null ? oldScreen.width : newScreen.width);
		var randomY:Float = Math.random() * (oldScreen != null ? oldScreen.height : newScreen.height);
		Iris.createIrisOpenTransitionAt(randomX, randomY)(oldScreen, newScreen, completeCallback);
	}
	
	inline public static var TRANSITION:String = "transition";
	
	public function new()
	{
		super();
	}

	private var _list:List;
	private var _backButton:Button;

	override private function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();

		this.title = "Iris";

		this.layout = new AnchorLayout();

		this._list = new List();
		this._list.dataProvider = new ListCollection(
		[
			{ label: "Iris Open", transition: Iris.createIrisOpenTransition() },
			{ label: "Iris Close", transition: Iris.createIrisCloseTransition() },
			{ label: "Iris Open At", transition: irisOpenAtRandomPosition },
			{ label: "Iris Close At", transition: irisCloseAtRandomPosition },
		]);
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._list.clipContent = false;
		this._list.autoHideBackground = true;

		this._list.itemRendererFactory = function():IListItemRenderer
		{
			var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();

			//enable the quick hit area to optimize hit tests when an item
			//is only selectable and doesn't have interactive children.
			renderer.isQuickHitAreaEnabled = true;

			renderer.labelField = "label";

			renderer.accessoryLabelField = "accessory";
			return renderer;
		};

		this._list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
		this._list.revealScrollBars();
		this.addChild(this._list);

		this.headerFactory = this.customHeaderFactory;
	}

	private function customHeaderFactory():Header
	{
		var header:Header = new Header();

		this._backButton = new Button();
		this._backButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON);
		this._backButton.label = "Transitions";
		this._backButton.addEventListener(Event.TRIGGERED, backButton_triggeredHandler);
		header.leftItems = [this._backButton];

		return header;
	}

	private function list_triggeredHandler(event:Event, item:Dynamic):Void
	{
		var transition:Dynamic = item.transition;
		this.dispatchEventWith(TRANSITION, false, transition);
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}
}
