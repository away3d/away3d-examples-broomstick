package com.li.general.keyboard
{
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.Dictionary;

public class KeyManager
{
    // ---------------------------------------------------------------------------------------------------------
    // Private variables.
    // ---------------------------------------------------------------------------------------------------------

    public static const KEY_LEFT:uint = 37;
    public static const KEY_RIGHT:uint = 39;
    public static const KEY_UP:uint = 38;
    public static const KEY_DOWN:uint = 40;
    public static const KEY_W:uint = 87;
    public static const KEY_A:uint = 65;
    public static const KEY_S:uint = 83;
    public static const KEY_D:uint = 68;
    public static const KEY_Z:uint = 90;
    public static const KEY_X:uint = 88;

    // ---------------------------------------------------------------------------------------------------------
    // Private variables.
    // ---------------------------------------------------------------------------------------------------------

    private static var _instance:KeyManager;

    private var _keysDown:Dictionary;

    // ---------------------------------------------------------------------------------------------------------
    // Public methods.
    // ---------------------------------------------------------------------------------------------------------

    public function KeyManager(stage:Stage)
    {
        _keysDown = new Dictionary();

        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
    }

    public static function getInstance(stage:Stage):KeyManager
    {
        if(!_instance)
            _instance = new KeyManager(stage);
        return _instance;
    }

    public function keyIsDown(keyCode:uint):Boolean
    {
        return _keysDown[keyCode] ? _keysDown[keyCode] : false;
    }

    // ---------------------------------------------------------------------------------------------------------
    // Event handlers.
    // ---------------------------------------------------------------------------------------------------------

    private function keyDownHandler(evt:KeyboardEvent):void
    {
        _keysDown[evt.keyCode] = true;
    }

    private function keyUpHandler(evt:KeyboardEvent):void
    {
        _keysDown[evt.keyCode] = false;
    }
}
}