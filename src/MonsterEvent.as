package 
{
	import flash.events.Event;

	public class MonsterEvent extends Event
	{
		public static const MESH_COMPLETE : String = 'meshComplete';
		
		public function MonsterEvent(type : String)
		{
			super(type);
		}
		
		
		public override function clone() : Event
		{
			return new MonsterEvent(type);
		}
	}
}