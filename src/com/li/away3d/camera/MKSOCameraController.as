/**
 * Created by IntelliJ IDEA.
 * User: li
 * Date: 1/29/11
 * Time: 5:40 PM
 * To change this template use File | Settings | File Templates.
 */
package com.li.away3d.camera
{
import away3d.cameras.Camera3D;

import com.li.away3d.camera.*;

import com.li.general.keyboard.KeyManager;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/*
    MouseKeyboardSmoothOrbitCameraController.
    Idem. SmoothOrbitCameraController but can be controlled via mouse and keyboard.
 */
public class MKSOCameraController extends Sprite
{
    private var _sOCameraController:SOCameraController;
    private var _mouseIsDown:Boolean;
    private var _lastMouseX:Number;
    private var _lastMouseY:Number;
    private var _dx:Number;
    private var _dy:Number;
    private var _keyManager:KeyManager;

    public var mouseEasing:Number = 0.005;
    public var keyboardAngularSpeed:Number = 0.1;
    public var keyboardLinearSpeed:Number = 10;
    public var showInteractionArea:Boolean = false;
    public var mouseInteractionEnabled:Boolean = true;

    public function MKSOCameraController(camera:Camera3D)
    {
        super();
        _sOCameraController = new SOCameraController(camera);
        addEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
    }

    private function init():void
    {
        _lastMouseX = stage.mouseX;
        _lastMouseY = stage.mouseY;

        _keyManager = KeyManager.getInstance(stage);

        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

        stage.addEventListener(Event.RESIZE, stage_resizeHandler);
        resize();
    }

    public function update():void
    {
        updateKeyboardInput();
        _sOCameraController.update();
    }

    public function get soCameraController():SOCameraController
    {
        return _sOCameraController;
    }

    // TODO: Assumes that the 3D view will always be the size of the stage.
    private function resize():void
    {
        graphics.beginFill(0xFF0000, showInteractionArea ? 0.25 : 0.0);
        graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        graphics.endFill();
    }

    private function updateKeyboardInput():void
    {
        if(_keyManager.keyIsDown(KeyManager.KEY_RIGHT) || _keyManager.keyIsDown(KeyManager.KEY_D))
            _sOCameraController.azimuth -= keyboardAngularSpeed;
        if(_keyManager.keyIsDown(KeyManager.KEY_LEFT) || _keyManager.keyIsDown(KeyManager.KEY_A))
            _sOCameraController.azimuth += keyboardAngularSpeed;
        if(_keyManager.keyIsDown(KeyManager.KEY_UP) || _keyManager.keyIsDown(KeyManager.KEY_W))
            _sOCameraController.elevation -= keyboardAngularSpeed;
        if(_keyManager.keyIsDown(KeyManager.KEY_DOWN) || _keyManager.keyIsDown(KeyManager.KEY_S))
            _sOCameraController.elevation += keyboardAngularSpeed;
        if(_keyManager.keyIsDown(KeyManager.KEY_Z))
            _sOCameraController.radius += keyboardLinearSpeed;
        if(_keyManager.keyIsDown(KeyManager.KEY_X))
            _sOCameraController.radius -= keyboardLinearSpeed;
    }

    private function updateMouseInput():void
    {
        if(!mouseInteractionEnabled)
            return;

        _dx = _lastMouseX - stage.mouseX;
        _dy = _lastMouseY - stage.mouseY;
        _sOCameraController.azimuth -= _dx*mouseEasing;
        _sOCameraController.elevation += _dy*mouseEasing;
    }

    private function stageInitHandler(evt:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, stageInitHandler);
        init();
    }

    private function mouseDownHandler(event:MouseEvent):void
    {
        _mouseIsDown = true;
    }

    private function mouseUpHandler(event:MouseEvent):void
    {
        _mouseIsDown = false;
    }

    private function mouseMoveHandler(event:MouseEvent):void
    {
        if(_mouseIsDown)
            updateMouseInput();

        _lastMouseX = stage.mouseX;
        _lastMouseY = stage.mouseY;
    }

    private function stage_resizeHandler(event:Event):void
    {
        resize();
    }
}
}
