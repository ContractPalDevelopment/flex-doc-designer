/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 2:55 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
import mx.core.FlexGlobals;

public class History {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);
    private static var history:Array = new Array();


    public static function saveLayer():void
    {
        history[history.length] = JSON.stringify(Layer.layer);
        if(history.length > 1)
        {
            mainApp.undoButton.enabled = true;
        }
        if(history.length < 2){ Requests.setDirtyFunction(false); }
    }

    public static function getPrevious():Object
    {
        if(history.length > 1)
        {
            history.pop();
        }
        var result:Object = JSON.parse(history.pop());
        if(history.length < 2)
        {
            mainApp.undoButton.enabled = false;
        }
        return result;
    }
}
}
