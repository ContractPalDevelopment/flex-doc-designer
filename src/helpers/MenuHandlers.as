/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 3:41 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
import components.customPopUpManager;

import dialogs.tipDialog;

import mx.core.FlexGlobals;

public class MenuHandlers {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);

    public static function toggleReveal():void{
        if(!mainApp.fieldInfoTip.show)
        {
            mainApp.fieldInfoTip.show = true;
            var newPopUp:tipDialog = tipDialog(customPopUpManager.createPopUp(mainApp.docContainer, tipDialog, true));
            customPopUpManager.centerPopUp(newPopUp);
        }
        else
        {
            mainApp.fieldInfoTip.show = false;
            Layer.drawLayer();
        }
    }

    public static function undoChanges():void {
        Layer.layer = History.getPrevious();
        Layer.drawLayer();
    }

}
}
