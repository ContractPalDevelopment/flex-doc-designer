/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 12:20 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
import mx.controls.Alert;
import mx.core.FlexGlobals;

public class Messaging {
    private static var mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);

    public static function displayError(msg:String):void
    {
        Alert.show(msg, "Warning", 4, mainApp.docContainer, null, Images.img_warning);
    }

    public static function log(s:String):void
    {
        if(mainApp.logsButton.height > 0)
            mainApp.logs.text = s + "\n\n" + mainApp.logs.text;
    }
    public static function clearLogs():void
    {
        mainApp.logs.text = "";
    }
}
}
