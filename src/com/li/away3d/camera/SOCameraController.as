/**
 * Created by IntelliJ IDEA.
 * User: li
 * Date: 1/29/11
 * Time: 1:38 AM
 * To change this template use File | Settings | File Templates.
 */
package com.li.away3d.camera
{
import away3d.cameras.Camera3D;

import com.li.away3d.camera.*;

import flash.geom.Vector3D;

/*
    SmootherOrbitCameraController.
    Idem. OrbitCameraController but with easing.
 */
public class SOCameraController
{
    private var _orbitCameraController:OCameraController;
    private var _targetSphericalCoordinates:Vector3D;
    private var _targetCenter:Vector3D;
    private var _dx:Number, _dy:Number, _dz:Number, _dsq:Number;
    private var _sphericalDirty:Boolean, _targetDirty:Boolean;
    private var _dirtyTolerance:Number = 0.00001;

    public var orbitEasing:Number = 0.2;
    public var centerEasing:Number = 0.2;

    public function SOCameraController(camera:Camera3D)
    {
        _orbitCameraController = new OCameraController(camera);
        _targetSphericalCoordinates = _orbitCameraController.sphericalCoordinates.clone();
        _targetCenter = new Vector3D();
    }

    public function get oCameraController():OCameraController
    {
        return _orbitCameraController;
    }

    // Should be called continuously.
    public function update():void
    {
        // Update target.
        if(_targetDirty)
        {
            _dx = _targetCenter.x - _orbitCameraController.centerX;
            _dy = _targetCenter.y - _orbitCameraController.centerY;
            _dz = _targetCenter.z - _orbitCameraController.centerZ;
            _dsq = _dx*_dx + _dy*_dy + _dz*_dz;
            if(_dsq < _dirtyTolerance)
            {
                _targetDirty = false;
                _orbitCameraController.centerX = _targetCenter.x;
                _orbitCameraController.centerY = _targetCenter.y;
                _orbitCameraController.centerZ = _targetCenter.z;
            }
            else
            {
                _orbitCameraController.centerX += _dx*centerEasing;
                _orbitCameraController.centerY += _dy*centerEasing;
                _orbitCameraController.centerZ += _dz*centerEasing;
            }
        }

        // Update spherical.
        if(_sphericalDirty)
        {
            _dx = _targetSphericalCoordinates.x - _orbitCameraController.azimuth;
            _dy = _targetSphericalCoordinates.y - _orbitCameraController.elevation;
            _dz = _targetSphericalCoordinates.z - _orbitCameraController.radius;
            _dsq = _dx*_dx + _dy*_dy + _dz*_dz;
            if(_dsq < _dirtyTolerance)
            {
                _sphericalDirty = false;
                _orbitCameraController.azimuth = _targetSphericalCoordinates.x;
                _orbitCameraController.elevation = _targetSphericalCoordinates.y;
                _orbitCameraController.radius = _targetSphericalCoordinates.z;
            }
            else
            {
                _orbitCameraController.azimuth += _dx*orbitEasing;
                _orbitCameraController.elevation += _dy*orbitEasing;
                _orbitCameraController.radius += _dz*orbitEasing;
            }
        }
    }

    // --------------------
    // Position change.
    // --------------------

    // Azimuth.
    public function set azimuth(value:Number):void
    {
        if(_orbitCameraController.useAzimuthLimit)
            _targetSphericalCoordinates.x = containValue(value, _orbitCameraController.minAzimuth, _orbitCameraController.maxAzimuth);
        else
            _targetSphericalCoordinates.x = value;

        _sphericalDirty = true;
        update();
    }
    public function get azimuth():Number
    {
        return _targetSphericalCoordinates.x;
    }

    // Elevation.
    public function set elevation(value:Number):void
    {
        _targetSphericalCoordinates.y = containValue(value, _orbitCameraController.minElevation, _orbitCameraController.maxElevation);
        _sphericalDirty = true;
        update();
    }
    public function get elevation():Number
    {
        return _targetSphericalCoordinates.y;
    }

    // Radius.
    public function set radius(value:Number):void
    {
        _targetSphericalCoordinates.z = containValue(value, _orbitCameraController.minRadius, _orbitCameraController.maxRadius);
        _sphericalDirty = true;
        update();
    }
    public function get radius():Number
    {
        return _targetSphericalCoordinates.z;
    }

    // --------------------
    // Target (look at) position change.
    // --------------------

    // X.
    public function set centerX(value:Number):void
    {
        _targetCenter.x = value;
        _targetDirty = true;
        update();
    }
    public function get centerX():Number
    {
        return _targetCenter.x;
    }

    // Y.
    public function set centerY(value:Number):void
    {
        _targetCenter.y = value;
        _targetDirty = true;
        update();
    }
    public function get centerY():Number
    {
        return _targetCenter.y;
    }

    // Z.
    public function set centerZ(value:Number):void
    {
        _targetCenter.z = value;
        _targetDirty = true;
        update();
    }
    public function get centerZ():Number
    {
        return _targetCenter.z;
    }

    // --------------------
    // Private.
    // --------------------

    // Contains a value between a min and a max.
    private function containValue(value:Number, min:Number, max:Number):Number
    {
        if(value < min)
            return min;
        else if(value > max)
            return max;
        else
            return value;
    }
}
}
