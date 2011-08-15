package com.li.general.mouse
{
import com.li.away3d.*;

import com.li.general.events.MouseCaptureEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * @author Li
 */
public class MouseCapture extends Sprite
{
    // ------------------------------------------------------------------------------------
    // Private fields.
    // ------------------------------------------------------------------------------------

    private var _captureSprite:Sprite;
    private var _width:Number;
    private var _height:Number;
    private var _lastMouseX:Number;
    private var _lastMouseY:Number;
    private var _mouseDeltaX:Number;
    private var _mouseDeltaY:Number;

    // ------------------------------------------------------------------------------------
    // Public methods.
    // ------------------------------------------------------------------------------------

    public function MouseCapture(width:Number, height:Number)
    {
        super();

        _width = width;
        _height = height;

        // Wait until the sprite is added to stage for initialization.
        addEventListener(Event.ADDED_TO_STAGE, captureSpriteAddedToStageHandler);
    }

    public function resize(width:Number, height:Number):void
    {
        drawFill(width, height);
        _width = width;
        _height = height;
    }

    // ------------------------------------------------------------------------------------
    // Private methods.
    // ------------------------------------------------------------------------------------

    private function initializeCaptureSprite():void
    {
        // Initialize capture sprite.
        _captureSprite = new Sprite();
        drawFill(_width, _height);

        // Attach mouse listeners to capture sprite.
        _captureSprite.addEventListener(MouseEvent.MOUSE_DOWN, captureSpriteMouseDownHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, captureSpriteMouseUpHandler);

        // Also listen for the mouse leaving the stage.
        stage.addEventListener(Event.MOUSE_LEAVE, stageMouseLeaveHandler);
    }

    private function drawFill(width:Number, height:Number):void
    {
        _captureSprite.graphics.clear();
        _captureSprite.graphics.beginFill(0xFF0000, 0.0);
        _captureSprite.graphics.drawRect(0, 0, width, height);
        _captureSprite.graphics.endFill();
        addChild(_captureSprite);
    }

    private function startEnterframe():void
    {
        _captureSprite.addEventListener(Event.ENTER_FRAME, enterframeHandler);
    }

    private function stopEnterframe():void
    {
        _captureSprite.removeEventListener(Event.ENTER_FRAME, enterframeHandler);
    }

    private function update():void
    {
        _mouseDeltaX = _lastMouseX - _captureSprite.mouseX;
        _mouseDeltaY = _lastMouseY - _captureSprite.mouseY;
        notifyMouseDelta();
        _lastMouseX = _captureSprite.mouseX;
        _lastMouseY = _captureSprite.mouseY;
    }

    private function notifyMouseDelta():void
    {
        var evt:MouseCaptureEvent = new MouseCaptureEvent(MouseCaptureEvent.MOUSE_DELTA, _mouseDeltaX, _mouseDeltaY);
        dispatchEvent(evt);
    }

    // ------------------------------------------------------------------------------------
    // Event handlers.
    // ------------------------------------------------------------------------------------

    private function captureSpriteAddedToStageHandler(event:Event):void
    {
        // Remove initialization listener.
        removeEventListener(Event.ADDED_TO_STAGE, captureSpriteAddedToStageHandler);

        // Initialize.
        initializeCaptureSprite();
    }

    private function captureSpriteMouseDownHandler(event:MouseEvent):void
    {
        //            trace("capture mouse down.");
        _lastMouseX = _captureSprite.mouseX;
        _lastMouseY = _captureSprite.mouseY;
        startEnterframe();
    }

    private function captureSpriteMouseUpHandler(event:MouseEvent):void
    {
        //            trace("capture mouse up.");
        stopEnterframe();
    }

    private function stageMouseLeaveHandler(event:Event):void
    {
        stopEnterframe();
    }

    private function enterframeHandler(event:Event):void
    {
        update();
    }
}
}
