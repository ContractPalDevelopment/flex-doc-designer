/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/11/12
 * Time: 3:07 PM
 * To change this template use File | Settings | File Templates.
 */
package fieldSettingsDialogs {
import mx.collections.ArrayCollection;
import mx.controls.ComboBox;
import mx.core.FlexGlobals;

public class CommonMethods {

    private static var mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);

    public static function getSelectedIndex(comboBox:ComboBox, value:String):int
    {
        var AC:ArrayCollection = ArrayCollection(comboBox.dataProvider);
        if(value == null) { value = ""; }
        for(var i:int=0; i<AC.length; i++)
        {
            if(AC[i]["data"] == value) return i;
        }
        return -1;
    }
}
}
