package {
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.lights.DirectionalLight;

	import fr.nss.NSSClock;
	import fr.nss.duck.DuckPuppet;
	import fr.nss.duck.Ressource3D;
	import fr.nss.duck.World;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	use namespace arcane; 
	[SWF(width="1280", height="720", frameRate="30")]
	public class AS3SkinExporterStressTest extends Sprite{
		[Embed(source="/../embeds/duck/away.png")]
		private var AwayBMP : Class;
		
		[Embed(source="/../embeds/duck/nss.png")]
		private var NssBMP : Class;
		private var _count : Number = 0; 

		public function AS3SkinExporterStressTest()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		
			setupView3D();
			
			addChild(new AwayStats(World.view));

			World.ressources=new Ressource3D();
			initMesh();
			initCredits();
			addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
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

		private function setupView3D() : void {
			World.view = new View3D();
			World.view.antiAlias=2;
			World.view.backgroundColor=0xCCCCCC;

			World.light = new DirectionalLight(-1, -1, 1);
			World.light.color = 0xffffff;

			World.view.camera.z=-500;
			World.view.camera.y=450;
			World.view.camera.x=-450;
			World.view.camera.lookAt(new Vector3D(0,150,0));

			World.view.scene.addChild(World.light); 
			this.addChild(World.view);
		}

		private function initMesh() : void{

			var duck:DuckPuppet;
			for(var i:uint=0;i<9;i++){
				for(var j:uint=0;j<9;j++){
				
					duck=new DuckPuppet();
					duck.mesh.x=600*i-(600*5);
					duck.mesh.z=600*j-(600*5);
					duck.playAnim(null);
					World.view.scene.addChild(duck.mesh); 
				}
			}
	
		}
		
		
		private function _handleEnterFrame(e : Event) : void{
			NSSClock.tick();
			_count += .01;
			World.view.camera.x = Math.sin(_count)*1200;
			World.view.camera.y = Math.abs(Math.sin(_count*.54)*600);
			World.view.camera.z = Math.cos(_count*.7)*1200;
			World.view.camera.lookAt(new Vector3D(0,150,0));
			World.view.render();
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


