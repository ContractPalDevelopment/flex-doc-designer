/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/12/12
 * Time: 2:51 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
import components.Field;
import components.ShadowField;
import components.customPopUpManager;

import dialogs.checkboxGroupEditor;

import fieldSettingsDialogs.fieldDateSettings;
import fieldSettingsDialogs.fieldProfileSettings;

import flash.display.DisplayObject;

import flash.events.ContextMenuEvent;

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import mx.controls.Image;

import mx.core.FlexGlobals;
import flash.utils.getQualifiedClassName;

import mx.core.mx_internal;

use namespace mx_internal;

public class FieldsManager {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);
    private static var newFieldShadow:ShadowField;
    private static var serializedCopyField:String;

    // column names keepers -- needed to cast the layer to the datalist format
    public static var fieldColumnNames:Array;
    public static var signatureColumnNames:Array;

    public static function requestToFields(fields:Object):void{
        var recordCount:int = int(fields["recordCount"]);
        var columnCount:int = int(fields["columnCount"]);
        var columnNames:Array = fields["columnNames"].split(",");
        for(var i:int=0; i<recordCount; i++){
            var newRec:Object = new Object();
            var row:Array = fields["rows"][i];
            for(var j:int=0; j<columnCount; j++){
                newRec[columnNames[j]] = row[j];
                if(columnNames[j] == "sigId"){
                    newRec["id"] = row[j];
                }
            }
            Layer.layer["fields"].push(newRec);
        }
        fieldColumnNames = columnNames;
    }

    public static function requestToSignatures(fields:Object):void{
        var recordCount:int = int(fields["recordCount"]);
        var columnCount:int = int(fields["columnCount"]);
        var columnNames:Array = fields["columnNames"].split(",");
        for(var i:int=0; i<recordCount; i++){
            var newRec:Object = new Object();
            var row:Array = fields["rows"][i];
            for(var j:int=0; j<columnCount; j++){
                newRec[columnNames[j]] = row[j];
                if(columnNames[j] == "sigId"){
                    newRec["id"] = row[j];
                }
            }
            Layer.layer["fields"].push(newRec);
        }
        signatureColumnNames = columnNames;
    }

    public static function fieldsToResponse():Object{
        var obj:Array = Layer.layer["fields"];
        var res:Object = new Object();
        res["columnCount"] = fieldColumnNames.length;
        res["columnNames"] = fieldColumnNames.join(",");
        var rows:Array = new Array();
        for(var i:int = 0; i<obj.length; i++)
        {
            var objRec:Object = obj[i];
            if(FieldsManager.isSignatureOrInitial(objRec["type"])){
                continue;
            }
            var rec:Array = new Array();
            for(var j:int = 0; j<fieldColumnNames.length; j++)
            {
                rec.push(objRec[fieldColumnNames[j]]);
            }
            rows.push(rec);
        }
        res["recordCount"] = rows.length;
        res["rows"] = rows;
        return res;
    }

    public static function signaturesToResponse():Object{
        var obj:Array = Layer.layer["fields"];
        var res:Object = new Object();
        res["columnCount"] = signatureColumnNames.length;
        res["columnNames"] = signatureColumnNames.join(",");
        var rows:Array = new Array();
        for(var i:int = 0; i<obj.length; i++)
        {
            var objRec:Object = obj[i];
            if(!FieldsManager.isSignatureOrInitial(objRec["type"])){
                continue;
            }
            var rec:Array = new Array();
            for(var j:int = 0; j<signatureColumnNames.length; j++)
            {
                rec.push(objRec[signatureColumnNames[j]]);
            }
            rows.push(rec);
        }
        res["recordCount"] = rows.length;
        res["rows"] = rows;
        return res;
    }

    public static function isSignatureOrInitial(fieldType:String):Boolean{
        return isSignature(fieldType) || isInitial(fieldType);
    }

    public static function isSignature(fieldType:String):Boolean{
        switch(fieldType)
        {
            case "signature":
            case "click":
            case "image":
            case "audio":
                return true;
        }
        return false;
    }

    public static function isInitial(fieldType:String):Boolean{
        switch(fieldType)
        {
            case "initial":
            case "click-initial":
            case "initial-ex":
                return true;
        }
        return false;
    }

    public static function isBindedSignature(fieldType:String):Boolean{
        switch(fieldType)
        {
            case "signature":
            case "click":
            case "image":
            case "audio":
            case "click-initial":
                return true;
        }
        return false;
    }

    public static function isAllCheckBoxes():Boolean{
        var fields:Array = getSelectedFields();
        for(var i:int=0; i<fields.length; i++){
            var field:Field = Field(fields[i]);
            if(field.fieldData["type"].toString() != "checkbox") return false;
        }
        return true;
    }

    public static function createId(name:String, counter:int):String{
        var testName:String = name+counter.toString();
        if(getElementIndexById(testName) == -1)
        {
            return testName;
        }
        else
        {
            return createId(name, counter+1);
        }
    }

    public static function getElementIndexById(id:String):int{
        var fields:Array = Layer.layer["fields"];
        for(var i:int=0; i<fields.length; i++){
            if(fields[i]["id"] == id) return i;
        }
        return -1;
    }

    public static function getAllFields():Array{
        var arr:Array = new Array();
        for(var i:int=0; i < mainApp.panel.getChildren().length; i++){
            if(getQualifiedClassName(mainApp.panel.getChildAt(i))=="mx.controls::Image") continue;
            arr.push(mainApp.panel.getChildAt(i));
        }
        return arr;
    }

    public static function getSelectedFields():Array{
        var fields:Array = getAllFields();
        var res:Array = new Array();
        for(var i:int=0; i<fields.length; i++){
            if(Field(fields[i]).inSelection){
                res.push(fields[i]);
            }
        }
        return res;
    }

    public static function createNewField(e:MouseEvent):void{
        var type:String = Image(e.currentTarget).name;
        newFieldShadow = new ShadowField();
        newFieldShadow.fieldType = type;
        mainApp.panel.addChild(newFieldShadow);

        newFieldShadow.startDrag();
        newFieldShadow.addEventListener(MouseEvent.MOUSE_UP, placeNewFieldOnPanel);
    }

    private static function placeNewFieldOnPanel(e:MouseEvent):void{
        newFieldShadow.stopDrag();
        var pos:Point = Layer.deScalePoint(new Point(newFieldShadow.mx_internal::$x, newFieldShadow.mx_internal::$y));
        var type:String = newFieldShadow.fieldType;
        mainApp.panel.removeChild(newFieldShadow);
        if (pos.x <= 0) {
            pos.x = 0;
        }
        if (pos.x + newFieldShadow.width >= mainApp.mimg.width) {
            pos.x = mainApp.mimg.width - newFieldShadow.width;
        }
        if (pos.y <= 0) {
            pos.y = 0;
        }
        if (pos.y + newFieldShadow.height >= mainApp.mimg.height) {
            pos.y = mainApp.mimg.height - newFieldShadow.height;
        }

        var newFieldData:Object;
        if (FieldsManager.isSignatureOrInitial(type)) {
            newFieldData = Layer.addNewSignature(type, pos.x, pos.y);
        }
        else {
            newFieldData = Layer.addNewField(type, pos.x, pos.y);
        }
        Layer.drawLayer();

        var allFields:Array = getAllFields();
        var curField:Field;
        for(var i:int = 0; i<allFields.length; i++)
        {
            var field:Field = Field(allFields[i]);
            if(field.fieldData["id"] == newFieldData["id"])
            {
                curField = field;
                unSelectAll(field);
                break;
            }
        }
        switch (type) {
            case "date":
                var dateSettingsD:fieldDateSettings = fieldDateSettings(customPopUpManager.createPopUp(mainApp.docContainer, fieldDateSettings, true));
                dateSettingsD.fieldData = newFieldData;
                customPopUpManager.centerPopUp(dateSettingsD);
                curField.adjustDialogPosition(dateSettingsD, Layer.scalePoint(new Point(0, int(newFieldData["top"]))).y);
                break;
            case "profile":
                var profileSettingsD:fieldProfileSettings = fieldProfileSettings(customPopUpManager.createPopUp(mainApp.docContainer, fieldProfileSettings, true));
                profileSettingsD.fieldData = newFieldData;
                profileSettingsD.miniDialog = true;
                customPopUpManager.centerPopUp(profileSettingsD);
                curField.adjustDialogPosition(profileSettingsD, Layer.scalePoint(new Point(0, int(newFieldData["top"]))).y);
                break;
        }
    }

    public static function unCreateNewField(e:MouseEvent):void {
        mainApp.panel.removeChild(newFieldShadow);
    }

    public static function setGroupContextMenu():void {
        var cm:ContextMenu = new ContextMenu();
        cm.hideBuiltInItems();
        const alignLeft:ContextMenuItem = new ContextMenuItem("Align Left");
        alignLeft.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        const alignRight:ContextMenuItem = new ContextMenuItem("Align Right");
        alignRight.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        const alignTop:ContextMenuItem = new ContextMenuItem("Align Top");
        alignTop.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        const alignBottom:ContextMenuItem = new ContextMenuItem("Align Bottom");
        alignBottom.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        const resizeHMax:ContextMenuItem = new ContextMenuItem("Resize Height to Max");
        resizeHMax.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        resizeHMax.separatorBefore = true;
        const resizeHMin:ContextMenuItem = new ContextMenuItem("Resize Height to Min");
        resizeHMin.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        const resizeWMax:ContextMenuItem = new ContextMenuItem("Resize Width to Max");
        resizeWMax.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        const resizeWMin:ContextMenuItem = new ContextMenuItem("Resize Width to Min");
        resizeWMin.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxAlign);
        const deleteSelected:ContextMenuItem = new ContextMenuItem("Delete Selected");
        deleteSelected.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxDeleteField);
        deleteSelected.separatorBefore = true;

        cm.customItems = [alignLeft, alignRight, alignTop, alignBottom, resizeHMax, resizeHMin, resizeWMax, resizeWMin, deleteSelected];

        if (FieldsManager.isAllCheckBoxes()) {
            const groupCheckBoxes:ContextMenuItem = new ContextMenuItem("Set Common Properties");
            groupCheckBoxes.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxGroupCheckboxes);
            groupCheckBoxes.separatorBefore = true;
            cm.customItems = [alignLeft, alignRight, alignTop, alignBottom, resizeHMax, resizeHMin, resizeWMax, resizeWMin, groupCheckBoxes, deleteSelected];
        }

        var fields:Array = FieldsManager.getSelectedFields();
        for (var i:int = 0; i < fields.length; i++) {
            var field:Field = Field(fields[i]);
            field.contextMenu = cm;
        }
    }

    public static function unSelectAll(selField:Field = null):void {
        var redrawAfter:Boolean = false;
        if (FieldsManager.getSelectedFields().length > 1) {
            redrawAfter = true;
        }
        var fields:Array = FieldsManager.getAllFields();
        for (var i:int = 0; i < fields.length; i++) {
            Field(fields[i]).inSelection = false;
            Field(fields[i]).addContextMenu();
        }
        if (selField) selField.inSelection = true;
    }

    ///////////////////////////
    // Other Events Handles  //
    ///////////////////////////
    public static function ctxDeleteField(evt:ContextMenuEvent):void {
        if (evt.target.caption == "Delete Selected") {
            var fields:Array = FieldsManager.getSelectedFields();
            for (var i:int = 0; i < fields.length; i++) {
                var field:Field = Field(fields[i]);
                if(field.isNative){ continue; }
                Layer.deleteField(field.name);
            }
            Layer.drawLayer();
        }
        else {
            var child:DisplayObject = mainApp.panel.getChildByName(evt.contextMenuOwner.name);
            Layer.deleteField(child.name);
            mainApp.panel.removeChild(child);
        }
    }

    public static function ctxCopyElement(evt:ContextMenuEvent):void {
        var fields:Array = Layer.layer["fields"];
        var fieldType:String = "";
        for (var i:int = 0; i < fields.length; i++) {
            if (fields[i]["id"] == evt.contextMenuOwner.name) {
                fieldType = fields[i]["type"].toString();
                serializedCopyField = JSON.stringify(fields[i]);
                break;
            }
        }
        var ctxText:String = "";
        switch (fieldType) {
            case "date":
                ctxText = "Paste Date Field";
                break;
            default:
                ctxText = "Paste Field";
                break;
        }
        if(isInitial(fieldType)){ ctxText = "Paste Initial"; }
        if(isSignature(fieldType)){ ctxText = "Paste Signature"; }
        var cm:ContextMenu = new ContextMenu();
        cm.hideBuiltInItems();
        const pasteElement:ContextMenuItem = new ContextMenuItem(ctxText);
        pasteElement.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ctxPasteElement);
        cm.customItems = [pasteElement];
        cm.addEventListener(ContextMenuEvent.MENU_SELECT, mainApp.leftMouseClick);
        mainApp.mimg.contextMenu = cm;
    }

    public static function ctxPasteElement(evt:ContextMenuEvent):void {
        var newField:Object = new Object();
        newField = JSON.parse(serializedCopyField);
        newField["id"] = createId(newField["type"] + "_" + Page.currentPage.toString() + "_", 1);
        if(isSignature(newField["type"]))
        {
            newField["id"] = createId("signature_" + Page.currentPage.toString() + "_", 1);
            newField["sigId"] = newField["id"];
        }
        else if(isInitial(newField["type"]))
        {
            newField["id"] = createId("initial_" + Page.currentPage.toString() + "_", 1);
            newField["sigId"] = newField["id"];
        }
        newField["page"] = Page.currentPage.toString();
        newField["native"] = false;

        newField["top"] = mainApp.mimg.getConstraintValue("mouseY");
        newField["left"] = mainApp.mimg.getConstraintValue("mouseX");
        Layer.layer["fields"].push(newField);

        Layer.drawLayer();

        var allFields:Array = getAllFields();
        for(var i:int = 0; i<allFields.length; i++)
        {
            var field:Field = Field(allFields[i]);
            if(field.fieldData["id"] == newField["id"])
            {
                unSelectAll(field);
                break;
            }
        }
    }

    public static function ctxAlign(evt:ContextMenuEvent):void {
        var newValue:int;
        var selectedFields:Array = FieldsManager.getSelectedFields();
        for (var i:int = 0; i < selectedFields.length; i++) {
            var field:Field = Field(selectedFields[i]);
            var itemValue:int;
            switch (evt.target.caption) {
                case "Align Left":
                    itemValue = field.x;
                    break;
                case "Align Right":
                    itemValue = field.x + field.width;
                    break;
                case "Align Top":
                    itemValue = field.y;
                    break;
                case "Align Bottom":
                    itemValue = field.y + field.height;
                    break;
                case "Resize Height to Max":
                case "Resize Height to Min":
                    itemValue = field.height;
                    break;
                case "Resize Width to Max":
                case "Resize Width to Min":
                    itemValue = field.width;
                    break;
            }
            if (itemValue) {
                if (!newValue) {
                    newValue = itemValue;
                }
                switch (evt.target.caption) {
                    case "Align Left":
                    case "Align Top":
                    case "Resize Height to Min":
                    case "Resize Width to Min":
                        if (itemValue < newValue) newValue = itemValue;
                        break;
                    case "Align Right":
                    case "Align Bottom":
                    case "Resize Height to Max":
                    case "Resize Width to Max":
                        if (itemValue > newValue) newValue = itemValue;
                        break;
                }
            }
        }
        if (newValue) {
            for (i = 0; i < selectedFields.length; i++) {
                field = Field(selectedFields[i]);
                if(field.isNative) { continue; }
                var p:Point = Layer.deScalePoint(new Point(newValue, newValue));
                var fields:Array = Layer.layer["fields"];
                switch (evt.target.caption) {
                    case "Align Left":
                        fields[getElementIndexById(field.name)]["left"] = p.x;
                        break;
                    case "Align Right":
                        fields[getElementIndexById(field.name)]["left"] = p.x - field.width;
                        break;
                    case "Align Top":
                        fields[getElementIndexById(field.name)]["top"] = p.y;
                        break;
                    case "Align Bottom":
                        fields[getElementIndexById(field.name)]["top"] = p.y - field.height;
                        break;
                    case "Resize Height to Max":
                    case "Resize Height to Min":
                        if (fields[getElementIndexById(field.name)]["height"]) {
                            fields[getElementIndexById(field.name)]["height"] = newValue;
                        }
                        break;
                    case "Resize Width to Max":
                    case "Resize Width to Min":
                        if (fields[getElementIndexById(field.name)]["width"]) {
                            fields[getElementIndexById(field.name)]["width"] = newValue;
                        }
                        break;
                }
            }
            Layer.drawLayer();
        }
    }

    public static function ctxGroupCheckboxes(evt:ContextMenuEvent):void {
        var newPopUp:checkboxGroupEditor = checkboxGroupEditor(customPopUpManager.createPopUp(mainApp.docContainer, checkboxGroupEditor, true));
        var fields:Array = FieldsManager.getSelectedFields();
        for (var i:int = 0; i < fields.length; i++) {
            var field:Field = Field(fields[i]);
            newPopUp.idArray.push(getElementIndexById(field.name));
        }
        customPopUpManager.centerPopUp(newPopUp);
    }

    public static function moveSelected(dispX:int, dispY:int):void {
        var selFields:Array = getSelectedFields();
        for (var i:int = 0; i < selFields.length; i++) {
            var field:Field = Field(selFields[i]);
            if(field.isNative) { continue; }
            var fields:Array = Layer.layer["fields"];
            for (var j:int = 0; j < fields.length; j++) {
                if (fields[j]["id"] == field.name) {
                    field.x += dispX;
                    field.y += dispY;
                    fields[j]["left"] = int(fields[j]["left"]) + dispX;
                    fields[j]["top"] = int(fields[j]["top"]) + dispY;
                   break;
                }
            }
        }
    }

    public static function getDragRectangle(dragField:Rectangle):Rectangle {
        var result:Rectangle = new Rectangle(mainApp.mimg.x, mainApp.mimg.y, mainApp.mimg.width - dragField.width, mainApp.mimg.height - dragField.height);
        var fields:Array = getSelectedFields();
        var difValue:int = 0;
        for (var i:int = 0; i < fields.length; i++) {
            var field:Field = Field(fields[i]);
            var fieldW:int = field.width;
            var fieldH:int = field.height;

            if (field.x + fieldW > dragField.x + dragField.width) {
                difValue = field.x + fieldW - dragField.x - dragField.width;
                result.width -= difValue;
                dragField.width += difValue;
            }
            if (field.x < dragField.x) {
                difValue = dragField.x - field.x;
                result.x += difValue;
                result.width -= difValue;
                dragField.x -= difValue;
                dragField.width += difValue;
            }
            if (field.y + fieldH > dragField.y + dragField.height) {
                difValue = field.y + fieldH - dragField.y - dragField.height;
                result.height -= difValue;
                dragField.height += difValue;
            }
            if (field.y < dragField.y) {
                difValue = dragField.y - field.y;
                result.y += difValue;
                result.height -= difValue;
                dragField.y -= difValue;
                dragField.height += difValue;
            }
        }
        return result;
    }

    public static function getSelectedFieldsRectangle():Rectangle{
        var selectedFields:Array = getSelectedFields();
        var result:Rectangle = new Rectangle(selectedFields[0].x, selectedFields[0].y, selectedFields[0].width, selectedFields[0].height);
        var difValue:int = 0;
        for(var i:int=0; i<selectedFields.length; i++){
            var field:Field = Field(selectedFields[i]);
            if(field.x < result.x)
            {
                difValue = result.x - field.x;
                result.x -= difValue;
                result.width += difValue;
            }
            if(field.y < result.y)
            {
                difValue = result.y - field.y;
                result.y -= difValue;
                result.height += difValue;
            }
            if(field.x + field.width > result.x + result.width)
            {
                difValue = field.x + field.width - result.x - result.width;
                result.width += difValue;
            }
            if(field.y + field.height > result.y + result.height)
            {
                difValue = field.y + field.height - result.y - result.height;
                result.height += difValue;
            }
        }

        return result;
    }
}
}