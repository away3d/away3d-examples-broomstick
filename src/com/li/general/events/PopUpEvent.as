package com.li.general.events
{
import flash.events.Event;

public class PopUpEvent extends Event
{
    public static const CLOSE_POP_UP:String = "CLOSE_POP_UP";
    public static const POP_UP_CLOSED:String = "POP_UP_CLOSED";

    public function PopUpEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }

    override public function clone():Event
    {
        var clone:PopUpEvent = new PopUpEvent(type);
        return clone;
    }
}
}