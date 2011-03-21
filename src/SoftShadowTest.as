package {
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.primitives.Plane;
	import away3d.primitives.Sphere;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	use namespace arcane; 
	/**
	 * @author Seraf
	 */
	[SWF(width="1000", height="700", frameRate="60")]
	public class SoftShadowTest extends Sprite{
		[Embed(source="/../embeds/duck/away.png")]
		private var AwayBMP : Class;
		
		[Embed(source="/../embeds/duck/nss.png")]
		private var NssBMP : Class;

		
		private var _count : Number = 0; 
		private var view : View3D;
		private var light : DirectionalLight;

		public function SoftShadowTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		
		
			setupView3D();
			initMesh();
			initCredits();
			
			this.addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
		}

		private function setupView3D() : void{
			
			view = new View3D();
			view.antiAlias=2;
			view.backgroundColor=0xCCCCCC;

			light = new DirectionalLight(-1, -1, 1);
			light.color = 0xffffee;
			light.position=new Vector3D(1000,1000,1000);
			
			
			view.camera.z=-1000;
			view.camera.y=1000;
			view.camera.x=-1000;
			view.camera.lookAt(new Vector3D(0,0,0));

			view.scene.addChild(light); 
			this.addChild(view);
			addChild(new AwayStats(view));
			
		
		}
		
		private function initMesh() : void{
			
		
			var planeMaterial:ColorMaterial=new ColorMaterial(0xCCCCCC );
			planeMaterial.lights = [light];
			
			//Material ambientColor affect the contrast of the shadow 
			planeMaterial.ambientColor = 0xCCCCCC;
			//SoftShadowMapMethod step size is to change the neighbour filtering
			planeMaterial.shadowMethod = new SoftShadowMapMethod(light);
			var plane : Plane = new Plane(planeMaterial, 2000, 2000, 1, 1, false);
		
			plane.castsShadows=true; 
			view.scene.addChild(plane);
			
			var material:ColorMaterial=new ColorMaterial(0xFFFF00 );
			material.shadowMethod = new SoftShadowMapMethod(light);
			material.lights = [light];
			material.ambientColor = 0xCCCCCC;
			var sphere:Sphere=new Sphere(material,50);
			sphere.y=50;
			sphere.castsShadows=true;
			view.scene.addChild(sphere);
			
			var material2:ColorMaterial=new ColorMaterial(0xFF0000 );
			material2.shadowMethod = new SoftShadowMapMethod(light);
			material2.lights = [light];
			material2.ambientColor = 0xCCCCCC;
			var sphere2:Sphere=new Sphere(material2,150);
			sphere2.y=250;
			sphere2.x=250;
			sphere2.castsShadows=true;
			view.scene.addChild(sphere2);
			
		}
		
		private function initCredits() : void {
			
			var awayButton:LinkPicture=new LinkPicture(new AwayBMP(),"http://www.away3d.com");
			awayButton.y=stage.stageHeight-awayButton.height;
			addChild(awayButton);
			var nssButton:LinkPicture=new LinkPicture(new NssBMP(),"http://www.not-so-stupid.com");
			nssButton.y=stage.stageHeight-nssButton.height;
			nssButton.x=awayButton.width;
			addChild(nssButton);
			
		}
		private function _handleEnterFrame(ev : Event) : void
		{
			
			_count += .01;
			light.x = Math.sin(_count)*1200;
			light.y = 300+Math.abs(Math.sin(_count)*1200);
			light.z = Math.cos(_count)*1200;
			var direction:Vector3D=light.position.clone();
			direction.negate();
			direction.normalize();
			light.direction=direction;
			view.render();
			
		}
		
	
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.navigateToURL;

class LinkPicture extends Sprite {
	private var _url : String;
	
	public function LinkPicture(_b:Bitmap,url:String) {

		_url = url;
		
		addChild(_b);
		buttonMode=true;
		
		addEventListener(MouseEvent.CLICK,clickEvt);
		addEventListener(MouseEvent.ROLL_OVER,rollEvt);
		addEventListener(MouseEvent.ROLL_OUT,outEvt);
	}
		
	private function outEvt(event : MouseEvent) : void {
		alpha=1;
	}

	private function rollEvt(event : MouseEvent) : void {
		alpha=.5;		
	}
	private function clickEvt(event : MouseEvent) : void {
		try { 
			var link:URLRequest = new URLRequest(  _url);
			   navigateToURL ( link , "_self");
		} 
		catch (myError:Error) { 
			ExternalInterface.call("window.open", _url, "_self", "");
		}
	}
 }
