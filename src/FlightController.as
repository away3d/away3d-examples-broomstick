package {
    import away3d.cameras.Camera3D;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	/**
	 * Makes the camera rotate around a target on drag. Hardly a proper scalable implementation, but this is just to support the simple demo.
	 *
	 * @author David Lenaerts
	 */
	public class FlightController
	{
		private var _stage : Stage;
		private var _camera : Camera3D;
		private var _dragSpeed : Number = .005;
		private var _smoothing : Number = .1;
		private var _drag : Boolean;
		private var _referenceX : Number = 0;
		private var _referenceY : Number = 0;
		private var _xRad : Number = 0;
		private var _yRad : Number = .5;
		private var _targetXRad : Number = 0;
		private var _targetYRad : Number = .5;
        private var _moveSpeed : Number = 5;
        private var _xSpeed : Number = 0;
        private var _zSpeed : Number = 0;
		private var _targetXSpeed : Number = 0;
		private var _targetZSpeed : Number = 0;
		private var _runMult : Number = 1;

		/**
		 * Creates a HoverDragController object
		 * @param camera The camera to control
		 * @param stage The stage that will be receiving mouse events
		 */
		public function FlightController(camera : Camera3D, stage : Stage)
		{
			_stage = stage;
			_camera = camera;

			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
//            _stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onKeyDown(event : KeyboardEvent) : void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
					_targetZSpeed = _moveSpeed;
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					_targetZSpeed = -_moveSpeed;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					_targetXSpeed = -_moveSpeed;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					_targetXSpeed = _moveSpeed;
					break;
			    case Keyboard.SHIFT:
					_runMult = 2;
					break;
			}
		}

		private function onKeyUp(event : KeyboardEvent) : void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.W:
				case Keyboard.S:
					_targetZSpeed = 0;
					break;
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
				case Keyboard.A:
				case Keyboard.D:
					_targetXSpeed = 0;
					break;
				case Keyboard.SHIFT:
					_runMult = 1;
					break;
			}
		}

		/**
		 * Amount of "lag" the camera has
		 */
		public function get smoothing() : Number
		{
			return _smoothing;
		}

		public function set smoothing(value : Number) : void
		{
			_smoothing = value;
		}

		/**
		 * The speed by which the camera rotates
		 */
		public function get dragSpeed() : Number
		{
			return _dragSpeed;
		}

		public function set dragSpeed(value : Number) : void
		{
			_dragSpeed = value;
		}

		/**
		 * The speed by which the camera moves
		 */
		public function get moveSpeed() : Number
		{
			return _moveSpeed;
		}

		public function set moveSpeed(value : Number) : void
		{
			_moveSpeed = value;
		}

		/**
		 * Removes all listeners
		 */
		public function destroy() : void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            _stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Update cam movement towards its target position
		 */
		private function onEnterFrame(event : Event) : void
		{
			if (_drag) updateRotationTarget();

			_xSpeed += (_targetXSpeed*_runMult - _xSpeed)*_smoothing;
			_zSpeed += (_targetZSpeed*_runMult - _zSpeed)*_smoothing;
			_xRad += (_targetXRad - _xRad)*_smoothing;
			_yRad += (_targetYRad - _yRad)*_smoothing;

			_camera.rotationY = _xRad*180/Math.PI;
			_camera.rotationX = _yRad*180/Math.PI;
			_camera.moveForward(_zSpeed);
			_camera.moveRight(_xSpeed);
		}

		/**
		 * If dragging, update the target position's spherical coordinates
		 */
		private function updateRotationTarget() : void
		{
			var mouseX : Number = _stage.mouseX;
			var mouseY : Number = _stage.mouseY;
			var dx : Number = mouseX - _referenceX;
			var dy : Number = mouseY - _referenceY;
			var bound : Number = Math.PI * .5 - .05;

			_referenceX = mouseX;
			_referenceY = mouseY;
			_targetXRad += dx * _dragSpeed;
			_targetYRad -= dy * _dragSpeed;
			if (_targetYRad > bound) _targetYRad = bound;
			else if (_targetYRad < -bound) _targetYRad = -bound;
		}

		/**
		 * Start dragging
		 */
		private function onMouseDown(event : MouseEvent) : void
		{
			_drag = true;
			_referenceX = _stage.mouseX;
			_referenceY = _stage.mouseY;
		}

		/**
		 * Stop dragging
		 */
		private function onMouseUp(event : MouseEvent) : void
		{
			_drag = false;
		}

	}
}
