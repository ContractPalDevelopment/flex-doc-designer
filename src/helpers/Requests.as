/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 12:12 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
import fieldSettingsDialogs.Validator;

import flash.external.ExternalInterface;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

public class Requests {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);
    public static var cpURL:String; // the url provided by the platform for communicating with the workflow engine
    public static var errorFunction:String;
    public static var exitFunction:String;
    public static var dirtyFunction:String;

    public static function initRequest():void
    {
        mainApp.showLoading(true);
        var params:Object = {};
        params["action"]="init";
        Messaging.log("Request: \naction = init");
        var service:HTTPService = new HTTPService();
        service.url = cpURL;
        service.method = "POST";
        service.addEventListener("result", Responses.initResponse);
        service.addEventListener("fault", Responses.httpFault);
        service.send(params);
    }

    public static function getPage(pageNumber:int):void
    {
        mainApp.showLoading(true);
        var params:Object = {};
        params["page"] = pageNumber;
        params["action"] = "getPage";
        Messaging.clearLogs();
        Messaging.log("Request: \naction = getPage\npageNumber = " + Page.currentPage);
        var service:HTTPService = new HTTPService();
        service.url = cpURL;
        service.method = "POST";
        service.addEventListener("result", Responses.getPage);
        service.addEventListener("fault", Responses.httpFault);
        service.send(params);
    }

    public static function saveChanges():void
    {
        if(!Validator.validateReferences()) return;
        if(!Validator.validateLayer()) return;

        var params:Object = {};
        var layer:Object = new Object();
        layer["fields"] = FieldsManager.fieldsToResponse();
        layer["signatures"] = FieldsManager.signaturesToResponse();
        layer["configBindingList"] = bindingListToResponse();
        for(var i:int = 0; i<mainApp.selectBindingAC.length; i++)
        {
            if(mainApp.selectBindingAC[i].Type != "doc") { continue; }
            var listName:String  = mainApp.selectBindingAC[i].Binding;
            layer[listName] = mainApp.docBindingObj[listName];
        }
        params["layer"] = JSON.stringify(layer);
        params["action"] = "save";
        Messaging.log("Request: \naction = saveLayer\nlayer = " + JSON.stringify(layer));
        var service:HTTPService = new HTTPService();
        service.url = cpURL;
        service.method = "POST";
        service.addEventListener("result", function(event:ResultEvent):void{
            Messaging.log("Result: "+event.message.body.toString());
            if(Responses.isErrorMessage(event.message.body.toString())){ return; }
            setDirtyFunction(false);
            mainApp.showLoading(false);
        });
        service.addEventListener("fault", Responses.httpFault);
        service.send(params);
        mainApp.showLoading(true);
    }

    private static function bindingListToResponse():Object{
        var AC:ArrayCollection = mainApp.selectBindingAC;

        var res:Object = new Object();
        res["columnCount"] = 3;
        res["columnNames"] = "binding,label,source";
        res["recordCount"] = AC.length;
        var rows:Array = new Array();
        for(var i:int = 0; i<AC.length; i++)
        {
            var rec:Array = new Array();
            rec.push(AC[i].Binding);
            rec.push(AC[i].Label);
            rec.push(AC[i].Type);
            rows.push(rec);
        }
        res["rows"] = rows;
        return res;
    }

    public static function exit():void {
        if (ExternalInterface.available && exitFunction) {
            setDirtyFunction(false);
            ExternalInterface.call(exitFunction);
        }
        else {
            Messaging.displayError("exitFunction not configured in parameters.");
        }
    }

    public static function setDirtyFunction(value:Boolean):void{
        if (dirtyFunction != null && dirtyFunction != "") {
            ExternalInterface.call(dirtyFunction, value);
        }
    }
}
}
