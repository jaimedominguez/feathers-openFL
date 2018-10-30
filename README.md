# feathers-openfl
Unofficial port of Feathers UI Framework. Currently based on Feathers 2.2.0, designed for openFL and Starling 1.8.
Modified to suits my needs and port it quickly to Haxe keeping all or almost all needed functionalities for Beekyr Reloaded menus.

Install
-------

    haxelib git openfl https://github.com/vroad/feathers-openfl

Dependencies:

  [starling-openfl and its dependent libraries](https://github.com/vroad/starling-openfl)

Current Limitations
-------------------

* ScrollText doesn't work correctly?
* TextInput doesn't work correctly.
* Numeric Stepper is buggy.
* TextBlockTextRenderer is not supported.
* On HTML5, Texts are rendered with TextFieldTextRenderer.
  * Texts on html5 may look diffrent from that of native targets.
* On native targets, Texts are rendered with BitmapFontTextRenderer.
  * Outline fonts are rendered with FreeType renderer implemented top of BitmapFont.
* If you move the mouse cursor outside of the window, touch processor still think that cursor is inside.



Differences with official Feathers
----------------------------------

* ScaleFactor factor moved to 'FeathersDisplayUtil.scaleFactor'.  We need to match it to Starling.current.contentScaleFactor manually.
* Setting properties has to be done using *.*Properties.setProperty();  I.E:  skinSelector.imageProperties.setProperty("width", 66);

