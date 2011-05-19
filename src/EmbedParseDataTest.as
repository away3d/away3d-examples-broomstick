﻿package {	[SWF(width="1168", height="630", frameRate="60")]			import away3d.cameras.Camera3D;	import away3d.cameras.lenses.PerspectiveLens;	import away3d.containers.ObjectContainer3D;	import away3d.containers.View3D;	import away3d.events.LoaderEvent;	import away3d.library.AssetLibrary;	import away3d.loaders.Loader3D;	import away3d.loaders.misc.AssetLoaderContext;	import away3d.loaders.parsers.AC3DParser;	import away3d.tools.MeshHelper;		import flash.display.Sprite;	import flash.events.Event;	import flash.geom.Vector3D;
		public class EmbedParseDataTest extends Sprite	{		//UNCOMMENT TO TEST PER TYPE		//[Embed(source="assets/models/turtle.obj", mimeType="application/octet-stream")]		//[Embed(source="assets/models/f360.3ds", mimeType="application/octet-stream")]		//[Embed(source="assets/models/turtleawd1.awd", mimeType="application/octet-stream")]		[Embed(source="assets/models/head.ac", mimeType="application/octet-stream")]		private var EmbeddedFile : Class;				private var _view : View3D;		private var _loader : Loader3D;				public function EmbedParseDataTest()		{			_view = new View3D();			_view.antiAlias = 2;			var camera:Camera3D = _view.camera;			camera.lens = new PerspectiveLens();			var eps:Number = 0.00000001;			camera.x = eps;			camera.y = eps;			camera.z = eps;			addChild(_view);						_loader = new Loader3D(false);			_loader.addEventListener(LoaderEvent.LOAD_ERROR, onResourceLoadingError);			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceRetrieved);						//ObjParser: loads texture from mtl is one is provided and url provided is correct			//_loader.parseData(new EmbeddedFile(), "assets/models/", false, OBJParser);						//Max3DSParser			// At this time of dev, parsing of embedded 3ds file doesn't support loading maps			//_loader.parseData(new EmbeddedFile(), "assets/models/", false, Max3DSParser);						//AWD1Parser: requires the directory of the awd			//_loader.parseData(new EmbeddedFile(), "assets/models/textures", false, AWD1Parser);						//AC3DParser: requires the url of the ac file			_loader.parseData(new EmbeddedFile(), new AC3DParser(), new AssetLoaderContext(true, 'assets/models'));						_view.scene.addChild(_loader);			_view.camera.lookAt(_loader.position);					}				private function cleanUP() : void		{			_loader.removeEventListener(LoaderEvent.LOAD_ERROR, onResourceLoadingError);			_loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceRetrieved);		}				private function onResourceLoadingError(e:LoaderEvent) : void		{			trace("Oh boy oh boy, model load has failed: ["+e.url+"]");			cleanUP();		}				private function onResourceMapsLoadingError(e:LoaderEvent) : void		{			trace("Oh noooo, a map failed to load in this model: ["+e.url+"]");			cleanUP();		}				private function onResourceRetrieved(e:LoaderEvent) : void		{			trace("Yeah my file has loaded :)");			cleanUP();						var scale:uint = 10;//if container needs rescaling			_loader.scale(scale);			var radiusObject:Number = MeshHelper.boundingRadiusContainer(_loader);						_view.camera.moveBackward(radiusObject*5);			_view.camera.lens.near = 5;			_view.camera.lens.far = (Vector3D.distance(_loader.position, _view.camera.position)*scale)+(radiusObject*5);						this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);		}				private function handleEnterFrame(e:Event) : void		{			_loader.rotationY += 1;			_view.render();		}	}}