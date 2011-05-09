package fr.nss {
	import flash.utils.getTimer;

	/**
	 * @author Seraf
	 */
	public class NSSClock {
		private static var _currentTime : uint=0;

		public static function tick() : void {
			_currentTime=getTimer();
	}
		public static function get currentTime() : uint{
			return _currentTime;
		}
	}
}
