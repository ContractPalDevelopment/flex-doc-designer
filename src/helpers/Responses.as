/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 12:28 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {

import flash.external.ExternalInterface;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

public class Responses {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);

    public static function initResponse(event:ResultEvent):void
    {
        if(isErrorMessage(event.message.body.toString())){ return; }
        Messaging.log("Result: " + event.message.body.toString());
        Messaging.log("---------------------------");

        var result:Object = JSON.parse(event.message.body.toString());
        Page.displayPage(result["configPage"]["base64"]);
        if(result["configThumbnail"]){
            Page.displayThumbnails(result["configThumbnail"]["base64"]);
            Page.addThumbnailFrames(result["configThumbnailMap"]);
            Page.showThumbDivider();
        }
        Layer.layer = new Object();
        Layer.layer["fields"] = new Array();
        FieldsManager.requestToFields(result["fields"]);
        FieldsManager.requestToSignatures(result["signatures"]);
        handleGlobalLists(result);

        //Layer.drawLayer();
        mainApp.showLoading(false);
    }

    public static function getPage(event:ResultEvent):void
    {
        try
        {
            var result:String = event.message.body.toString();
            if(isErrorMessage(result)){ return; }
            Messaging.log("Result: " + result);
            Messaging.log("-----------------");
            Page.displayPage(JSON.parse(result)["base64"]);
        }
        catch(err:Error)
        {
            if(event.message.body.indexOf('Session Timeout')!=-1)
            {
                Messaging.displayError("Your session has expired. \nYou will need to close your browser and start again.");
            }
            else
            {
                Messaging.displayError("Error: " + err.message);// event.message.body.toString());
            }
        }
        mainApp.showLoading(false);
    }

    public static function httpFault(event:FaultEvent):void
    {
        var faultString:String = event.fault.faultString;
        Messaging.log("Fault: " + faultString);
        Messaging.log("----------------------");
        if(faultString.indexOf("Session Timeout")!=-1)
        {
            if(Requests.errorFunction != null && Requests.errorFunction != ""){
                ExternalInterface.call(Requests.errorFunction, "timeout");
            }
            else{
                Messaging.displayError("Your session has expired.  You will need to close your browser and start again.");
            }
        }
        else if(faultString.indexOf("HTTP request error")!=-1)
        {
            Messaging.displayError("Unable to communicate with the server. \nCheck your Internet connection.");
        }
        else
        {
            Messaging.displayError(faultString);
        }
        mainApp.showLoading(false);
    }

    public static function isErrorMessage(message:String):Boolean{
        var mesObject:Object;
        try{
            mesObject = JSON.parse(message);
        }
        catch(err:Error){
            if(Requests.errorFunction != null && Requests.errorFunction != ""){
                Messaging.log(message);
                ExternalInterface.call(Requests.errorFunction, "error", "The response was not a JSON string");
            }
            else{
                Messaging.log(message);
                Messaging.displayError("Unknown error: " + "The response was not a JSON string");
            }
            mainApp.showLoading(false);
            return true;
        }
        if(mesObject["code"] && mesObject["code"] == "error"){
            if(Requests.errorFunction != null && Requests.errorFunction != ""){
                Messaging.log(message);
                ExternalInterface.call(Requests.errorFunction, "error", mesObject["message"]);
            }
            else{
                Messaging.log(message);
                Messaging.displayError("Workflow error: " + mesObject["message"]);
            }
            mainApp.showLoading(false);
            return true;
        }
        else if(mesObject["code"] && mesObject["code"] == "unknownAction"){
            if(Requests.errorFunction != null && Requests.errorFunction != ""){
                Messaging.log(message);
                ExternalInterface.call(Requests.errorFunction, "error", mesObject["message"]);
            }
            else{
                Messaging.log(message);
                Messaging.displayError("Unknown error.");
            }
            mainApp.showLoading(false);
            return true;
        }
        else if(mesObject["code"] && mesObject["code"] == "timeout"){
            if(Requests.errorFunction != null && Requests.errorFunction != ""){
                ExternalInterface.call(Requests.errorFunction, "timeout");
            }
            else{
                Messaging.displayError("Your session has expired.  You will need to close your browser and start again.");
            }
            mainApp.showLoading(false);
            return true;
        }
        return false;
    }

    private static function handleGlobalLists(resp:Object):void
    {
        mainApp.roleAC = new ArrayCollection();
        for(var i:int=0; i<resp["configRoleList"]["recordCount"]; i++){
            var role:String = resp["configRoleList"]["rows"][i][0];
            if(role == null){ role = ""; }
            var isDefault:Boolean = false;
            if(resp["configRoleList"]["rows"][i][1] == "true") isDefault = true;
            mainApp.roleAC.addItem({label:role,  data:role, isDefault:isDefault});
        }
        mainApp.profileTypeAC = new ArrayCollection();
        for(i = 0; i<resp["configProfileTypeList"]["recordCount"]; i++){
            var data:String = resp["configProfileTypeList"]["rows"][i][0];
            var label:String = resp["configProfileTypeList"]["rows"][i][1];
            mainApp.profileTypeAC.addItem({label:label, data:data});
        }
        mainApp.dateTypeAC = new ArrayCollection();
        for(i = 0; i<resp["configDateTypeList"]["recordCount"]; i++){
            data = resp["configDateTypeList"]["rows"][i][0];
            label = resp["configDateTypeList"]["rows"][i][1];
            mainApp.dateTypeAC.addItem({label:label, data:data});
        }
        mainApp.dateFormatAC = new ArrayCollection();
        for(i = 0; i<resp["configDateFormatList"]["recordCount"]; i++){
            data = resp["configDateFormatList"]["rows"][i][0];
            label = data;
            mainApp.dateFormatAC.addItem({label:label, data:data});
        }
        mainApp.fieldClassAC = new ArrayCollection();
        for(i = 0; i<resp["configFieldClassList"]["recordCount"]; i++){
            data = resp["configFieldClassList"]["rows"][i][0];
            label = data;
            mainApp.fieldClassAC.addItem({label:label, data:data});
        }
        mainApp.sigClassAC = new ArrayCollection();
        for(i = 0; i<resp["configSigClassList"]["recordCount"]; i++){
            data = resp["configSigClassList"]["rows"][i][0];
            label = data;
            mainApp.sigClassAC.addItem({label:label,  data:data});
        }
        mainApp.patternAC = new ArrayCollection();
        for(i = 0; i<resp["configPatternList"]["recordCount"]; i++){
            data = resp["configPatternList"]["rows"][i][0];
            label = resp["configPatternList"]["rows"][i][0];
            var toolTip:String = resp["configPatternList"]["rows"][i][1];
            mainApp.patternAC.addItem({label:label,  data:data,  toolTip:toolTip});
        }
        mainApp.sigImageAC = new ArrayCollection();
        for(i = 0; i<resp["configSigImageList"]["recordCount"]; i++){
            data = resp["configSigImageList"]["rows"][i][0];
            label = resp["configSigImageList"]["rows"][i][1];
            mainApp.sigImageAC.addItem({label:label, data:data});
        }
        mainApp.selectBindingAC = new ArrayCollection();
        for(i = 0; i<resp["configBindingList"]["recordCount"]; i++){
            data = resp["configBindingList"]["rows"][i][0];
            label = resp["configBindingList"]["rows"][i][1];
            var source:String = resp["configBindingList"]["rows"][i][2];
            mainApp.selectBindingAC.addItem({Label:label, Binding:data, Type:source});
        }

        mainApp.docBindingObj = new Object();
        for(i = 0; i<mainApp.selectBindingAC.length; i++){
            if(mainApp.selectBindingAC[i].Type != "doc") { continue; }
            var listName:String = mainApp.selectBindingAC[i].Binding;
            mainApp.docBindingObj[listName] = resp[listName];
        }
    }

}
}

