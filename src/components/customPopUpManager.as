/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/25/12
 * Time: 11:57 AM
 * To change this template use File | Settings | File Templates.
 */
package components {
import flash.display.DisplayObject;

import mx.core.IFlexDisplayObject;

import mx.managers.PopUpManager;

public class customPopUpManager extends PopUpManager {
    private static var _counter:int = 0;

    public static function get popUpCount():int
    {
        return _counter;
    }

    public static function createPopUp(parent:DisplayObject, className:Class,  modal:Boolean):Object
    {
        _counter++;
        return PopUpManager.createPopUp(parent,  className, modal);
    }

    public static function centerPopUp(popUp:IFlexDisplayObject):void
    {
        PopUpManager.centerPopUp(popUp);
    }

    public static function removePopUp(popUp:IFlexDisplayObject):void
    {
        _counter--;
        PopUpManager.removePopUp(popUp);
    }
}
}
