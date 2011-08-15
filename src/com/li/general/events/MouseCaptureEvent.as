package com.li.general.events
{
import flash.events.Event;

/**
 * @author Li
 */
public class MouseCaptureEvent extends Event
{
    // ------------------------------------------------------------------------------------
    // Public fields.
    // ------------------------------------------------------------------------------------

    public static const MOUSE_DELTA:String = "mouse_delta";

    public var deltaX:Number;
    public var deltaY:Number;

    // ------------------------------------------------------------------------------------
    // Public methods.
    // ------------------------------------------------------------------------------------

    public function MouseCaptureEvent(type:String, deltaX:Number, deltaY:Number)
    {
        this.deltaX = deltaX;
        this.deltaY = deltaY;

        super(type);
    }
}
}
