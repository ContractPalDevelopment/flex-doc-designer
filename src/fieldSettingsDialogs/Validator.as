/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/11/12
 * Time: 3:33 PM
 * To change this template use File | Settings | File Templates.
 */
package fieldSettingsDialogs {
import components.Field;
import components.ValidationFormItem;
import components.customPopUpManager;
import dialogs.referenceFailureDialog;
import helpers.FieldsManager;
import helpers.Layer;
import helpers.Messaging;
import helpers.Page;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

public class Validator {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);

    public static function validateValidationFormItems(fiArray:Array):Boolean{
        var isValid:Boolean = true;
        for(var i:int = 0; i<fiArray.length; i++)
        {
            if(fiArray[i] is ValidationFormItem)
            {
                var tempRes:Boolean = ValidationFormItem(fiArray[i]).Validate();
                if(!tempRes) isValid = false;
            }
        }
        return isValid;
    }

    public static function validateReferences():Boolean{
        var fields:Array = Layer.layer["fields"];
        var failedAC:ArrayCollection = new ArrayCollection();
        for(var i:int=0; i<fields.length; i++)
        {
            var field:Object = fields[i];
            if(FieldsManager.isBindedSignature(field["type"])) continue;
            if(field["reference"] == "") continue;
            if(field["reference"] == null) continue;
            var reference:String = field["reference"];
            var sigLayerIndex:int = FieldsManager.getElementIndexById(reference);
            if(sigLayerIndex == -1)
            {
                failedAC.addItem(field);
            }
            else if(!FieldsManager.isBindedSignature(fields[sigLayerIndex]["type"]))
            {
                failedAC.addItem(field);
            }
        }
        if(failedAC.length > 0)
        {
            var alertD:referenceFailureDialog = referenceFailureDialog(customPopUpManager.createPopUp(mainApp.docContainer, referenceFailureDialog, true));
            alertD.referencesAC = failedAC;
            customPopUpManager.centerPopUp(alertD);
            return false;
        }
        return true;
    }

    public static function validateLayer():Boolean {
        var errorText:String = "";
        var fields:Array = Layer.layer["fields"];
        for (var i:int = 0; i < fields.length; i++) {
            var fieldData:Object = fields[i];
            if (fieldData["use"] == "test" && fieldData["test"] == "") {
                errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Test parameter required\n";
                if(int(fieldData["page"]) == Page.currentPage){
                    Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                }
            }
            if (fieldData["use"] == "role" && fieldData["role"] == "") {
                errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Role required\n";
                if(int(fieldData["page"]) == Page.currentPage){
                    Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                }
            }
            if (fieldData["name"] && fieldData["name"] == "") {
                errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Name required\n";
                if(int(fieldData["page"]) == Page.currentPage){
                    Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                }
            }
            switch (fieldData["type"].toString()) {
                case "checkbox":
                    if (fieldData["value"] == "") {
                        errorText += fieldData["type"] + ' "' + fieldData["id"] + '" has no value. (Page ' + fieldData["page"] + ")\n";
                        if(int(fieldData["page"]) == Page.currentPage){
                            Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                        }
                    }
                    break;
                case "date":
                    if (fieldData["subType"] == "") {
                        errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Type required\n";
                        if(int(fieldData["page"]) == Page.currentPage){
                            Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                        }
                    }
                    if (fieldData["subType"] == "participant" && fieldData["role"] == "") {
                        errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Role required\n";
                        if(int(fieldData["page"]) == Page.currentPage){
                            Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                        }
                    }
                    if (fieldData["subType"] == "custom" && fieldData["name"] == "") {
                        errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Name required\n";
                        if(int(fieldData["page"]) == Page.currentPage){
                            Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                        }
                    }
                    break;
                case "profile":
                    if (fieldData["subType"] == "") {
                        errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Type required\n";
                        if(int(fieldData["page"]) == Page.currentPage){
                            Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                        }
                    }
                    break;
            }

            if(FieldsManager.isInitial(fieldData["type"])){
                switch(fieldData["type"]){
                    case "initial-ex":
                        if(fieldData["reference"] == ""){
                            errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Main Signature required\n";
                            if(int(fieldData["page"]) == Page.currentPage){
                                Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                            }
                        }
                        if(fieldData["groupId"] == ""){
                            errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Group required\n";
                            if(int(fieldData["page"]) == Page.currentPage){
                                Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                            }
                        }
                        break;
                    case "initial":
                        if(fieldData["reference"] == ""){
                            errorText += fieldData["type"] + ' "' + fieldData["id"] + '" on page ' + fieldData["page"] + ", Main Signature required\n";
                            if(int(fieldData["page"]) == Page.currentPage){
                                Field(mainApp.panel.getChildByName(fieldData["id"])).showWarning = true
                            }
                        }
                        break;
                }
            }
        }
        if (errorText == "") return true;
        else {
            Messaging.displayError(errorText);
            return false;
        }
    }
}
}
