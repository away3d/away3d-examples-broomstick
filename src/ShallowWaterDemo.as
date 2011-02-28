package
{
import away3d.cameras.lenses.PerspectiveLens;
import away3d.containers.View3D;
import away3d.core.math.Matrix3DUtils;
import away3d.debug.AwayStats;
import away3d.lights.LightBase;
import away3d.lights.PointLight;
import away3d.materials.BitmapMaterial;
import away3d.materials.ColorMaterial;

import away3d.materials.methods.BasicDiffuseMethod;
import away3d.materials.methods.BasicDiffuseMethod;
import away3d.materials.methods.EnvMapDiffuseMethod;
import away3d.materials.methods.EnvMapMethod;
import away3d.materials.methods.FogMethod;
import away3d.materials.methods.ShadingMethodBase;
import away3d.materials.utils.CubeMap;
import away3d.primitives.Cube;
import away3d.primitives.Plane;

import away3d.primitives.SkyBox;

import com.li.away3d.camera.MKSOCameraController;
import com.li.fluids.shallow.DisturbanceBrush;
import com.li.fluids.shallow.FluidDisturb;
import com.li.fluids.shallow.ShallowFluid;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.ui.Keyboard;
import flash.utils.Timer;

import uk.co.soulwire.gui.SimpleGUI;

// TODO: Finish native mouse implementation - waiting for resolution of mouse occlusion topic.

public class ShallowWaterDemo extends Sprite
{
//    // Image used as height info for the terrain (generated in prefab).
//    [Embed(source="terrainPerlin1.jpg")]
//    private var HeightMapAsset:Class;

    // Environment map.
    [Embed(source="../embeds/envMap/snow_positive_x.jpg")]
    private var EnvPosX:Class;
    [Embed(source="../embeds/envMap/snow_positive_y.jpg")]
    private var EnvPosY:Class;
    [Embed(source="../embeds/envMap/snow_positive_z.jpg")]
    private var EnvPosZ:Class;
    [Embed(source="../embeds/envMap/snow_negative_x.jpg")]
    private var EnvNegX:Class;
    [Embed(source="../embeds/envMap/snow_negative_y.jpg")]
    private var EnvNegY:Class;
    [Embed(source="../embeds/envMap/snow_negative_z.jpg")]
    private var EnvNegZ:Class;

    // Liquid image assets.
    [Embed(source="../embeds/assets.swf", symbol="ImageClip")]
    private var ImageClip:Class;
    [Embed(source="../embeds/assets.swf", symbol="ImageClip1")]
    private var ImageClip1:Class;
    [Embed(source="../embeds/assets.swf", symbol="ImageClip2")]
    private var ImageClip2:Class;

    // Signature asset.
    [Embed(source="../embeds/assets.swf", symbol="AwaySignature")]
    private var AwaySignature:Class;

    // Disturbance brushes.
    [Embed(source="../embeds/assets.swf", symbol="Brush1")]
    private var Brush1:Class;
    [Embed(source="../embeds/assets.swf", symbol="Brush2")]
    private var Brush2:Class;
    [Embed(source="../embeds/assets.swf", symbol="Brush3")]
    private var Brush3:Class;
    [Embed(source="../embeds/assets.swf", symbol="Brush4")]
    private var Brush4:Class;
    [Embed(source="../embeds/assets.swf", symbol="Brush5")]
    private var Brush5:Class;
    [Embed(source="../embeds/assets.swf", symbol="Brush6")]
    private var Brush6:Class;

    public var mouseBrushStrength:Number = 5;
    public var rainBrushStrength:Number = 10;
    public var mouseBrushLife:uint = 0;

    public var fluid:ShallowFluid;
    private var _view:View3D;
    private var _cameraController:MKSOCameraController;
    private var _plane:Plane;
    private var _pressing:Boolean;
    private var _light:LightBase;
    private var _dropTmr:Timer;
    private var _fluidDisturb:FluidDisturb;
    private var _cubeMap:CubeMap;
    public var brushClip1:Sprite;
    public var brushClip2:Sprite;
    public var brushClip3:Sprite;
    public var brushClip4:Sprite;
    public var brushClip5:Sprite;
    public var brushClip6:Sprite;
    public var brushClips:Array;
    private var _activeMouseBrushClip:Sprite;
    private var _rainBrush:DisturbanceBrush;
    private var _imageBrush:DisturbanceBrush;
    private var _mouseBrush:DisturbanceBrush;
    private var _liquidShading:Boolean = true;
    private var _showingLiquidImage:Boolean;
    private var _showingLiquidImage1:Boolean;
    private var _showingLiquidImage2:Boolean;
    private var _gui:SimpleGUI;
    private var _rain:Boolean;
    private var _inverse:Matrix3D = new Matrix3D();
    private var _projX:Number, _projY:Number;
    public var hx:Number, hy:Number, hz:Number;
    private var _min:Number;
    private var _max:Number;
    private var _colorMaterial:ColorMaterial;
    private var _liquidMaterial:ColorMaterial;

    public function ShallowWaterDemo():void
    {
        // Init stage.
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.frameRate = 60;

        // Init 3D core.
        _view = new View3D();
        addChild(_view);

        // Show Away3D stats.
        var stats:AwayStats = new AwayStats(_view);
        stats.x = stage.stageWidth - stats.width;
        addChild(stats);

        // Signature.
        var sig:Sprite = new AwaySignature() as Sprite;
        sig.y = stage.stageHeight;
        sig.useHandCursor = sig.buttonMode = true;
        sig.getChildByName("awayHit").addEventListener(MouseEvent.CLICK, logoClickHandler);
        sig.getChildByName("liHit").addEventListener(MouseEvent.CLICK, liClickHandler);
        sig.getChildByName("davidHit").addEventListener(MouseEvent.CLICK, davidClickHandler);
        addChild(sig);

        // Init camera controller.
        _view.camera.z = -250;
        _view.camera.y = 200;
        _view.camera.lens.far = 5000000;
        _view.backgroundColor = 0x000000;          s
        _cameraController = new MKSOCameraController(_view.camera);
        _cameraController.soCameraController.oCameraController.maxElevation = -0.1;
        _cameraController.soCameraController.oCameraController.minRadius = 300;
        _cameraController.soCameraController.oCameraController.maxRadius = 2000;
        _view.parent.addChildAt(_cameraController, 0);

        // Fluid.
        var gridN:uint = 200; // Not larget than 255.
        var gridSpacing:Number = 400/gridN;
        var dt:Number = 1/stage.frameRate;
        var viscosity:Number = 0.3;
        var waveVelocity:Number = 0.99; // < 1 or the sim will collapse.
        fluid = new ShallowFluid(gridN, gridN, gridSpacing, dt, waveVelocity, viscosity);

        // Disturbance util.
        _fluidDisturb = new FluidDisturb(fluid);

        // Lights.
        _light = new PointLight(); // DirectionalLight();
        _light.color = 0x0000FF;
        _light.specular = 0.5;
        _light.diffuse = 2;
        _view.scene.addChild(_light);

        // Skybox.
        _cubeMap = new CubeMap(new EnvPosX().bitmapData, new EnvNegX().bitmapData,
                new EnvPosY().bitmapData, new EnvNegY().bitmapData,
                new EnvPosZ().bitmapData, new EnvNegZ().bitmapData);
        _view.scene.addChild(new SkyBox(_cubeMap));

        // Init plane materials.
        _liquidMaterial = new ColorMaterial(0xFFFFFF);
        _liquidMaterial.specular = 0.5;
        _liquidMaterial.ambient = 0.25;
        _liquidMaterial.ambientColor = 0x111199;
        _liquidMaterial.addMethod(new EnvMapMethod(_cubeMap, 1));
        _liquidMaterial.lights = [_light];
        _colorMaterial = new ColorMaterial(_liquidMaterial.color);
        _colorMaterial.specular = _liquidMaterial.specular;
        _colorMaterial.ambient = _liquidMaterial.ambient;
        _colorMaterial.ambientColor = 0x555555;
        _colorMaterial.diffuseMethod = new BasicDiffuseMethod();
        _colorMaterial.lights = [_light];

        // Init plane.
        _plane = new Plane(_liquidMaterial);
        _plane.x -= gridSpacing/2 + gridN*gridSpacing/2;
        _plane.z -= gridSpacing/2 + gridN*gridSpacing/2;
        _plane.geometry.subGeometries[0].autoDeriveVertexNormals = false;
        _plane.geometry.subGeometries[0].autoDeriveVertexTangents = false;
        _plane.segmentsW = _plane.segmentsH = (gridN - 1);
        _plane.rotationX = -90;
        _plane.width = _plane.height = (gridN - 1)*gridSpacing;
        _min = -_plane.width/2;
        _max = _plane.width/2;
        _view.scene.addChild(_plane);

        var fog:FogMethod = new FogMethod(2500, 0x000000);

        // Pool.
        var poolHeight:Number = 500000;
        var poolWallDepth:Number = 5;
        var poolOffset:Number = 5;
        var tex:BitmapData = new BitmapData(512, 512, false, 0);
        tex.perlinNoise(25, 25, 8, 1, false, true, 7, true);
        var white:Number = 0;
        tex.colorTransform(tex.rect, new ColorTransform(0.1, 0.1, 0.1, 1, white, white, white, 0));
        var poolMat:BitmapMaterial = new BitmapMaterial(tex);
        poolMat.addMethod(fog);
        var left:Cube = new Cube(poolMat);
        var s:uint = 1;
        left.segmentsW = left.segmentsH = left.segmentsD = s;
        left.x = -_plane.width/2 - poolWallDepth/2;
        left.y = -poolHeight/2 + poolOffset;
        left.width = poolWallDepth;
        left.height = poolHeight;
        left.depth = _plane.width + 2*poolWallDepth;
        _view.scene.addChild(left);
        var right:Cube = new Cube(poolMat);
        right.segmentsW = right.segmentsH = right.segmentsD = s;
        right.x = _plane.width/2 + poolWallDepth/2;
        right.y = left.y;
        right.width = poolWallDepth;
        right.height = poolHeight;
        right.depth = _plane.width + 2*poolWallDepth;
        _view.scene.addChild(right);
        var back:Cube = new Cube(poolMat);
        back.segmentsW = back.segmentsH = back.segmentsD = s;
        back.z = _plane.width/2 + poolWallDepth/2;
        back.y = left.y;
        back.depth = poolWallDepth;
        back.height = poolHeight;
        back.width = _plane.width;
        _view.scene.addChild(back);
        var front:Cube = new Cube(poolMat);
        front.segmentsW = front.segmentsH = front.segmentsD = s;
        front.z = -_plane.width/2 - poolWallDepth/2;
        front.y = left.y;
        front.depth = poolWallDepth;
        front.height = poolHeight;
        front.width = _plane.width;
        _view.scene.addChild(front);

        // Landscape.
//        var imgWidth:Number = 512;
//        var map:Bitmap = new HeightMapAsset() as Bitmap;
//        var floor:Bitmap = new FloorAsset() as Bitmap;
//        var t:BitmapData = new BitmapData(256, 256, false, 0xFFFFFF);
//        var p:BitmapData = map.bitmapData;
//        var m:BitmapMaterial = new BitmapMaterial(t);
//        m.addMethod(fog);
//        var landscape:Plane = new Plane(m);
//        var res:uint = 100;
//        landscape.segmentsW = landscape.segmentsH = res - 1;
//        landscape.width = landscape.height = 2000;
//        landscape.rotationX = -90;
//        var h:Number = 200;
//        landscape.y = -65;
////        _view.scene.addChild(landscape);
//        var i:uint, j:uint;
//        var imgx:uint, imgy:uint, gray:uint, index:uint;
//        var d:Number = imgWidth/res;
//        var newVerts:Vector.<Number> = landscape.geometry.subGeometries[0].vertexData.concat();
//        p.lock();
//        for(i = 0; i < res; i++)
//        {
//            for(j = 0; j < res; j++)
//            {
//                imgx = i*d;
//                imgy = j*d;
//                gray = p.getPixel(imgx, imgy) & 0x0000FF;
//                index = 3*(j*res + i);
//                newVerts[index + 2] -= h*gray/255;
//            }
//        }
//        p.unlock();
//        landscape.geometry.subGeometries[0].updateVertexData(newVerts);

        // For disturbances.
        initBrushes();

        // Rain.
        _dropTmr = new Timer(50);
        _dropTmr.addEventListener(TimerEvent.TIMER, _dropTmr_timerHandler);

        // Start loop.
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);

        // SimpleGUI based on minimalcomps.
        initGUI();

        // Stage clicks.
        stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
    }

    private function logoClickHandler(evt:MouseEvent):void
    {
        navigateToURL(new URLRequest("http://www.away3d.com"), "_blank");
    }

    private function liClickHandler(evt:MouseEvent):void
    {
        navigateToURL(new URLRequest("http://www.lidev.com.ar"), "_blank");
    }

    private function davidClickHandler(evt:MouseEvent):void
    {
        navigateToURL(new URLRequest("http://www.derschmale.com/"), "_blank");
    }

    // ----------------------
    // GUI.
    // ----------------------

    private function initGUI():void
    {
        _gui = new SimpleGUI(this, "");

        _gui.addColumn("Simulation");
        _gui.addSlider("fluid.speed", 0.0, 0.95, {label:"speed", tick:0.01});
        _gui.addSlider("fluid.viscosity", 0.0, 1.7, {label:"viscosity", tick:0.01});
        _gui.addToggle("toggleShading", {label:"reflective shading"});

        var instr:String = "Instructions:\n";
        instr += "Click and drag on the stage to rotate camera.\n";
        instr += "Click on the fluid to disturb it.\n";
        instr += "Keyboard arrows and WASD also rotate camera.\n";
        instr += "Keyboard Z and X zoom camera.\n";
        _gui.addLabel(instr);

        _gui.addColumn("Rain");
        _gui.addToggle("toggleRain", {label:"enabled"});
        _gui.addSlider("rainTime", 10, 1000, {label:"speed", tick:10});
        _gui.addSlider("rainBrushStrength", 1, 50, {label:"strength", tick:0.01});

        _gui.addColumn("Mouse Brush");
        _gui.addComboBox("activeMouseBrushClip", brushClips, {label:"brush"});
        _gui.addSlider("mouseBrushStrength", -10, 10, {label:"strength", tick:0.01});
        _gui.addSlider("mouseBrushLife", 0, 10000, {label:"life", tick:10});

        _gui.addColumn("Liquid Image");
        _gui.addToggle("toggleLiquidImage", {label:"away"});
        _gui.addToggle("toggleLiquidImage2", {label:"mustang"});
        _gui.addToggle("toggleLiquidImage1", {label:"winston"});
        _gui.show();
    }

    // ----------------------
    // BRUSHES.
    // ----------------------

    private function initBrushes():void
    {
        // Init brush clips.
        brushClip1 = new Brush1() as Sprite;
        brushClip2 = new Brush2() as Sprite;
        brushClip3 = new Brush3() as Sprite;
        brushClip4 = new Brush4() as Sprite;
        brushClip5 = new Brush5() as Sprite;
        brushClip6 = new Brush6() as Sprite;
        brushClips = [
            {label:"drop", data:brushClip3},
            {label:"star", data:brushClip1},
            {label:"box", data:brushClip2},
            {label:"triangle", data:brushClip4},
            {label:"stamp", data:brushClip5},
            {label:"butter", data:brushClip6}
        ];
        _activeMouseBrushClip = brushClip3;

        // Init brushes.
        _rainBrush = new DisturbanceBrush();
        _rainBrush.fromSprite(brushClip3);
        _mouseBrush = new DisturbanceBrush();
        _mouseBrush.fromSprite(_activeMouseBrushClip);
        _imageBrush = new DisturbanceBrush();
        _imageBrush.fromSprite(new ImageClip() as Sprite);
    }

    public function set activeMouseBrushClip(value:Sprite):void
    {
        _activeMouseBrushClip = value;
        _mouseBrush.fromSprite(_activeMouseBrushClip, 2);
    }

    public function get activeMouseBrushClip():Sprite
    {
        return _activeMouseBrushClip;
    }

    public function set rainTime(delay:uint):void
    {
        _dropTmr.delay = delay;
    }

    public function get rainTime():uint
    {
        return _dropTmr.delay;
    }

    // ---------------
    // MATERIALS.
    // ---------------

    public function set toggleShading(value:Boolean):void
    {
        _liquidShading = value;
        if(_liquidShading)
            _plane.material = _liquidMaterial;
        else
            _plane.material = _colorMaterial;
    }

    public function get toggleShading():Boolean
    {
        return _liquidShading;
    }

    // ---------------
    // LIQUID IMAGE.
    // ---------------

    public function set toggleLiquidImage(value:Boolean):void
    {
        _showingLiquidImage = value;
        if(_showingLiquidImage)
        {
            _imageBrush.fromSprite(new ImageClip() as Sprite);
            _fluidDisturb.disturbBitmapMemory(0.5, 0.5, -10, _imageBrush.bitmapData, -1, 0.01);
        }
        else
            _fluidDisturb.releaseMemoryDisturbances();
    }
    public function get toggleLiquidImage():Boolean
    {
        return _showingLiquidImage;
    }

    public function set toggleLiquidImage1(value:Boolean):void
    {
        _showingLiquidImage1 = value;
        if(_showingLiquidImage1)
        {
            _imageBrush.fromSprite(new ImageClip1() as Sprite);
            _fluidDisturb.disturbBitmapMemory(0.5, 0.5, -15, _imageBrush.bitmapData, -1, 0.01);
        }
        else
            _fluidDisturb.releaseMemoryDisturbances();
    }
    public function get toggleLiquidImage1():Boolean
    {
        return _showingLiquidImage1;
    }

    public function set toggleLiquidImage2(value:Boolean):void
    {
        _showingLiquidImage2 = value;
        if(_showingLiquidImage2)
        {
            _imageBrush.fromSprite(new ImageClip2() as Sprite);
            _fluidDisturb.disturbBitmapMemory(0.5, 0.5, -15, _imageBrush.bitmapData, -1, 0.01);
        }
        else
            _fluidDisturb.releaseMemoryDisturbances();
    }
    public function get toggleLiquidImage2():Boolean
    {
        return _showingLiquidImage2;
    }

    // ---------------
    // RAIN.
    // ---------------

    public function set toggleRain(value:Boolean):void
    {
        _rain = value;
        if(_rain)
            _dropTmr.start();
        else
            _dropTmr.stop();
    }

    public function get toggleRain():Boolean
    {
        return _rain;
    }

    private function _dropTmr_timerHandler(event:TimerEvent):void
    {
        _fluidDisturb.disturbBitmapInstant(randNum(0.1, 0.9), randNum(0.1, 0.9), rainBrushStrength, _rainBrush.bitmapData);
    }

    // ---------------
    // MOUSE.
    // ---------------

    private function stage_mouseDownHandler(event:MouseEvent):void
    {
        _pressing = true;

        updateMouse();

        if(hx > _min && hx < _max && hz > _min && hz < _max)
            _cameraController.mouseInteractionEnabled = false;
        else
            _pressing = false;
    }

    private function stage_mouseUpHandler(event:MouseEvent):void
    {
        _pressing = false;
        _cameraController.mouseInteractionEnabled = true;
    }

    /*
     Decided not to use built in mouse interactivity.
     Using this chunk of code I stole from the engine instead.
     */
    private function updateMouse():void
    {
        _projX = 1 - 2*stage.mouseX/stage.stageWidth;
        _projY = 2*stage.mouseY/stage.stageHeight - 1;

        // calculate screen ray and find exact intersection position with triangle
        var rx:Number, ry:Number, rz:Number;
        var ox:Number, oy:Number, oz:Number, ow:Number;
        var t:Number;
        var raw:Vector.<Number>;

        _inverse.copyFrom(_view.camera.lens.matrix);
        _inverse.invert();
        raw = Matrix3DUtils.RAW_DATA_CONTAINER;
        _inverse.copyRawDataTo(raw);

        // unproject projection point, gives ray dir in cam space
        ox = raw[0]*_projX + raw[4]*_projY + raw[12];
        oy = raw[1]*_projX + raw[5]*_projY + raw[13];
        oz = raw[2]*_projX + raw[6]*_projY + raw[14];
        ow = raw[3]*_projX + raw[7]*_projY + raw[15];
        ox /= -ow;
        oy /= -ow;
        oz /= ow;

        // transform ray dir and origin (cam pos) to object space
        _inverse.copyFrom(_view.camera.sceneTransform);
        _inverse.copyRawDataTo(raw);
        rx = raw[0]*ox + raw[4]*oy + raw[8]*oz;
        ry = raw[1]*ox + raw[5]*oy + raw[9]*oz;
        rz = raw[2]*ox + raw[6]*oy + raw[10]*oz;

        ox = raw[12];
        oy = raw[13];
        oz = raw[14];

        t = -oy/ry;

        hx = ox + rx*t;
        hy = oy + ry*t;
        hz = oz + rz*t;

        if(hx > _min && hx < _max && hz > _min && hz < _max)
        {
            // Disturb mouse.
            var evtx:Number = 0.5*(hx + _max)/_max;
            var evty:Number = 0.5*(hz + _max)/_max;
            if(mouseBrushLife == 0)
                _fluidDisturb.disturbBitmapInstant(evtx, evty, -mouseBrushStrength, _mouseBrush.bitmapData);
            else
                _fluidDisturb.disturbBitmapMemory(evtx, evty,
                        -5*mouseBrushStrength,
                        _mouseBrush.bitmapData,
                        mouseBrushLife,
                        0.2);
        }
    }

    // ---------------
    // LOOP.
    // ---------------

    private function enterFrameHandler(event:Event):void
    {
        // Update camera.
        _cameraController.update();

        // Update fluid.
        fluid.evaluate();

        // Update memory disturbances.
        _fluidDisturb.updateMemoryDisturbances();

        // Update plane to fluid.
        _plane.geometry.subGeometries[0].updateVertexData(fluid.points);
        _plane.geometry.subGeometries[0].updateVertexNormalData(fluid.normals);
        _plane.geometry.subGeometries[0].updateVertexTangentData(fluid.tangents);

        // Update light.
        _light.transform = _view.camera.transform.clone();

        // Render.
        _view.render();

        if(_pressing)
            updateMouse();
    }

    // ---------------
    // UTILS.
    // ---------------

    private function randNum(min:Number, max:Number):Number
    {
        return (max - min)*Math.random() + min;
    }

    private function clampNum(value:Number, min:Number, max:Number):Number
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
