/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/11/12
 * Time: 12:22 PM
 * To change this template use File | Settings | File Templates.
 */
package fieldSettingsDialogs {
import helpers.FieldsManager;
import helpers.Layer;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.formatters.DateFormatter;

public class CommonLists {

    private static var mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);

    public static function getPatternList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:"", toolTip:""});
        for(var i:int = 0; i<mainApp.patternAC.length; i++){
            result.addItem(mainApp.patternAC[i]);
        }
        return result;
    }

    public static function getProfileTypeList():ArrayCollection{
        var profileTypeList:ArrayCollection = new ArrayCollection();
        profileTypeList.addItem({label:"", data:""});
        for(var i:int = 0; i<mainApp.profileTypeAC.length; i++)
        {
            profileTypeList.addItem(mainApp.profileTypeAC[i]);
        }
        return profileTypeList;
    }

    public static function getMainSigList():ArrayCollection{
        var sigList:ArrayCollection = new ArrayCollection();
        var fields:Array = Layer.layer["fields"];
        sigList.addItem({label:"", data:""});
        for(var i:int=0; i<fields.length; i++)
        {
            if(FieldsManager.isBindedSignature(fields[i]["type"]))
            {
                sigList.addItem({label:fields[i]["sigId"], data:fields[i]["sigId"]});
            }
        }
        return sigList;
    }

    public static function getRoleList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:""});
        for(var i:int=0; i<mainApp.roleAC.length; i++)
        {
            result.addItem(mainApp.roleAC[i]);
        }
        return result;
    }

    public static function getDefaultRole():String{
        for(var i:int = 0; i<mainApp.roleAC.length; i++)
        {
            if(mainApp.roleAC[i]["isDefault"] || mainApp.roleAC[i]["isDefault"] == "true") return mainApp.roleAC[i]["data"];
        }
        return "";
    }

    public static function getDateTypeList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:""});
        for(var i:int=0; i<mainApp.dateTypeAC.length; i++)
        {
            result.addItem(mainApp.dateTypeAC[i]);
        }
        return result;
    }

    public static function getDateFormatList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:""});

        var dateFormatter:DateFormatter = new DateFormatter();
        var currentDate:Date = new Date();
        for(var i:int=0; i<mainApp.dateFormatAC.length; i++){
            var data:String = mainApp.dateFormatAC[i].data;
            dateFormatter.formatString = data;
            var label:String = dateFormatter.format(currentDate);
            result.addItem({label:label, data:data});
        }
        return result;
    }

    public static function getInitialTypeList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"click-initial", data:"click-initial"});
        result.addItem({label:"initial-ex", data:"initial-ex"});
        result.addItem({label:"initial", data:"initial"});
        return result;
    }

    public static function getSignatureTypeList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"click", data:"click"});
        result.addItem({label:"image", data:"image"});
        result.addItem({label:"audio", data:"audio"});
        return result;
    }

    public static function getFieldClassList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:""});
        for(var i:int=0; i<mainApp.fieldClassAC.length; i++)
        {
            result.addItem(mainApp.fieldClassAC[i]);
        }
        return result;
    }

    public static function getSelectBindingsList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:""});
        for(var i:int = 0; i<mainApp.selectBindingAC.length; i++)
        {
            var label:String = mainApp.selectBindingAC[i].Label;
            var data:String = mainApp.selectBindingAC[i].Binding;
            result.addItem({label:label, data:data});
        }
        return result;
    }

    public static function getSigImageList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:""});
        for(var i:int = 0; i<mainApp.sigImageAC.length; i++)
        {
            result.addItem(mainApp.sigImageAC[i]);
        }
        return result;
    }

    public static function getRecordTimeList():ArrayCollection{
        var result:ArrayCollection = new ArrayCollection();
        result.addItem({label:"", data:""});
        result.addItem({label:"1 minute", data:"1"});
        result.addItem({label:"2 minutes", data:"2"});
        result.addItem({label:"5 minutes", data:"5"});
        result.addItem({label:"10 minutes", data:"10"});
        result.addItem({label:"60 minutes", data:"60"});
        return result;
    }
}
}
