/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 1:45 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
import components.*;
import fieldSettingsDialogs.CommonLists;
import flash.geom.Point;
import mx.controls.Image;
import mx.core.FlexGlobals;
import flash.utils.getQualifiedClassName;

public class Layer {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);
    public static var layer:Object;
    public static var textAreaMaxLength:int = 0;

    public static function addNewField(fieldType:String, left:int, top:int):Object{
        var field:Object = new Object();
        field["id"] = FieldsManager.createId(fieldType + "_" + Page.currentPage.toString() + "_", 1);
        field["role"] = CommonLists.getDefaultRole();
        field["left"] = left;
        field["top"] = top;
        field["type"] = fieldType;
        field["page"] = Page.currentPage.toString();
        field["reference"] = "";
        field["native"] = "false";
        field["readonly"] = "false";
        switch (fieldType)
        {
            case "checkbox":
                field["use"] = "O";
                field["name"] = field["id"];
                field["value"] = "";
                field["className"] = "";
                field["groupId"] = "";
                field["test"] = "";
                field["checked"] = false;
                break;
            case "date":
                field["use"] = "R";
                field["dateFormat"] = "";
                field["subType"] = "";
                field["name"] = field["id"];
                field["width"] = 100;
                field["height"] = 20;
                break;
            case "profile":
                field["use"] = "R";
                field["subType"] = "";
                field["font"] = "";
                field["name"] = field["id"];
                field["width"] = 100;
                field["height"] = 20;
                break;
            case "select":
                field["use"] = "O";
                field["name"] = field["id"];
                field["binding"] = "";
                field["className"] = "";
                field["width"] = 100;
                field["height"] = 20;
                field["test"] = "";
                field["font"] = "";
                break;
            case "text":
                field["use"] = "O";
                field["name"] = field["id"];
                field["value"] = "";
                field["maxLength"] = 40;
                field["className"] = "";
                field["width"] = 100;
                field["height"] = 20;
                field["pattern"] = "";
                field["customPattern"] = "";
                field["subType"] = "";
                field["test"] = "";
                field["font"] = "";
                break;
            case "textarea":
                field["use"] = "O";
                field["name"] = field["id"];
                field["value"] = "";
                field["maxLength"] = textAreaMaxLength;
                field["className"] = "";
                field["width"] = 100;
                field["height"] = 40;
                field["pattern"] = "";
                field["customPattern"] = "";
                field["subType"] = "";
                field["test"] = "";
                field["font"] = "";
                field["rows"] = 10;
                field["columns"] = 10;
                break;
        }
        layer["fields"].push(field);
        return field;
    }

    public static function addNewSignature(sigType:String, left:int,  top:int):Object{
        var field:Object = new Object();
        field["id"] = FieldsManager.createId(sigType+"_" + Page.currentPage.toString() + "_", 1);
        field["sigId"] = field["id"];
        field["role"] = CommonLists.getDefaultRole();
        field["left"] = left;
        field["top"] = top;
        field["page"] = Page.currentPage.toString();
        field["className"] = "";
        field["image"] = "";
        field["data"] = "";
        field["native"] = "false";

        switch (sigType)
        {
            case "signature":
                field["type"] = "click";
                field["width"] = 200;
                field["height"] = 37;
                field["recordTime"] = "";
                break;
            case "initial":
                field["type"] = "initial";
                field["reference"] = "";
                field["groupId"] = "";
                field["width"] = 21;
                field["height"] = 21;
                break;
        }
        layer["fields"].push(field);
        return field;
    }

    public static function deleteField(id:String):void{
        var fields:Array = layer["fields"];
        for(var i:int = 0; i<fields.length; i++){
            if(fields[i]["id"] == id){
                fields.splice(i,1);
                return;
            }
        }
    }

    public static function drawLayer():void{
        Requests.setDirtyFunction(true);
        History.saveLayer();
        // Save the document and remove all fields.
        var inSelection:Array = new Array();
        for(var j:int=0; j<mainApp.panel.getChildren().length; j++){
            if(getQualifiedClassName(mainApp.panel.getChildAt(j))=="mx.controls::Image") continue;
            if(Field(mainApp.panel.getChildAt(j)).inSelection)
                inSelection.push(Field(mainApp.panel.getChildAt(j)).name);
        }
        refreshCanvas();

        // Draw fields
        var fields:Array = layer["fields"];
        for(var i:int=0; i<fields.length; i++)
        {
            if(fields[i]["page"] != Page.currentPage.toString())	continue;	// draw current page fields only
            if(mainApp.fieldInfoTip.show) { mainApp.reveal.source = Images.img_hide; }
            else { mainApp.reveal.source = Images.img_reveal; }

            var elemInSelection:Boolean = false;
            for(j=0; j<inSelection.length; j++){
                if(fields[i]["id"] == inSelection[j]) elemInSelection = true;
            }

            var elem:Field;
            switch(fields[i]["type"].toString())
            {
                case "checkbox": elem = new FieldCheckbox(); break;
                case "date": elem = new FieldDate(); break;
                case "profile": elem = new FieldProfile(); break;
                case "select": elem = new FieldSelect(); break;
                case "text": elem = new FieldText(); break;
                case "textarea": elem = new FieldTextArea(); break;
            }
            if(FieldsManager.isSignature(fields[i]["type"])){
                elem = new FieldSignature();
            }
            else if(FieldsManager.isInitial(fields[i]["type"])){
                elem = new FieldInitial();
            }
            elem.fieldData = layer["fields"][i];
            elem.isNative = layer["fields"][i]["native"] == "true";
            mainApp.panel.addChild(elem);
            elem.inSelection = false;
            elem.inSelection = elemInSelection;
        }
        if(FieldsManager.getSelectedFields().length>1){
            FieldsManager.setGroupContextMenu();
        }
    }

    public static function refreshCanvas():void{
        var documentPageImage:Image = mainApp.mimg;
        mainApp.panel.removeAllChildren();
        mainApp.panel.addChild(documentPageImage);
    }

    public static function scalePoint(p:Point):Point{
        p.x = mainApp.mimg.x + p.x;
        p.y = mainApp.mimg.y + p.y;
        return p;
    }

    public static function deScalePoint(p:Point):Point{
        p.x = p.x - mainApp.mimg.x;
        p.y = p.y - mainApp.mimg.y;
        return p;
    }
}
}
