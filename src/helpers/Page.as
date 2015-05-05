/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 12:37 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.events.MouseEvent;
import flash.utils.ByteArray;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import mx.controls.Image;
import mx.core.FlexGlobals;
import mx.utils.Base64Decoder;

public class Page {
    private static const mainApp:FlexDocDesigner = FlexDocDesigner(FlexGlobals.topLevelApplication);
    private static var initInterval:int;
    private static var thumbInterval:int;
    public static var currentPage:int=1;

    public static function displayPage(base64:String):void
    {
        var byteArr:ByteArray;
        var base64Dec:Base64Decoder = new Base64Decoder();
        base64Dec.decode(base64);
        byteArr = base64Dec.toByteArray();
        mainApp.mimg.load(byteArr);

        mainApp.panel.removeAllChildren();
        Layer.refreshCanvas();
        initInterval = setInterval(centerImage, 100);
    }

    public static function displayThumbnails(base64:String):void{
        mainApp.thumbnails.includeInLayout = true;

        var byteArr:ByteArray;
        var base64Dec:Base64Decoder = new Base64Decoder();
        base64Dec.decode(base64);
        byteArr = base64Dec.toByteArray();

        var img:Image = new Image();
        img.load(byteArr);
        img.x = 0;
        img.y = 0;
        mainApp.thumbnails.removeAllChildren();
        mainApp.thumbnails.addChild(img);

        thumbInterval = setInterval(function():void{
            if(mainApp.thumbnails.getChildAt(0).height > 0){
                clearInterval(thumbInterval);
                if(mainApp.thumbnails.width < mainApp.thumbnails.getChildAt(0).width){
                    mainApp.thumbnails.height += 16;
                }
            }
        }, 100);
    }

    public static function showThumbDivider():void {
        mainApp.thumbnails.visible = true;
    }

    public static function displayCoBrandingIcon(base64:String):void{
        if(base64 == null || base64 == "") return;

        base64 = base64.replace(/ /g, "+");

        var byteArr:ByteArray;
        var base64Dec:Base64Decoder = new Base64Decoder();
        base64Dec.decode(base64);
        byteArr = base64Dec.toByteArray();
        mainApp.coBrandingIcon.load(byteArr);
    }

    public static function displaySaveIcon(base64:String):void{
        if(base64 == null || base64 == "") return;

        base64 = base64.replace(/ /g, "+");

        var byteArr:ByteArray;
        var base64Dec:Base64Decoder = new Base64Decoder();
        base64Dec.decode(base64);
        byteArr = base64Dec.toByteArray();
        mainApp.saveIcon.load(byteArr);
    }

    public static function displayExitIcon(base64:String):void{
        if(base64 == null || base64 == "") return;

        base64 = base64.replace(/ /g, "+");

        var byteArr:ByteArray;
        var base64Dec:Base64Decoder = new Base64Decoder();
        base64Dec.decode(base64);
        byteArr = base64Dec.toByteArray();
        mainApp.exitIcon.load(byteArr);
    }


    public static function addThumbnailFrames(DL:Object):void{
        var arr:Array = DL["rows"];
        for(var i:int = 0; i<arr.length; i++){
            var rec:Array = arr[i][1].split(",");
            var width:int = int(rec[2]) - int(rec[0]);
            var height:int = int(rec[3]) - int(rec[1]);
            var frame:Image = new Image();
            frame.graphics.lineStyle(3, 0x23a3fe, 1.0, false, "normal", CapsStyle.SQUARE, JointStyle.MITER);
            frame.graphics.drawRect(0, 0, width,  height);
            frame.x = int(rec[0]);
            frame.y = int(rec[1]);
            frame.name = "frame_" + i.toString();
            frame.id = "frame_" + i.toString();
            frame.visible = i + 1 == currentPage;
            mainApp.thumbnails.addChild(frame);

            var clickArea:Image = new Image();
            clickArea.graphics.lineStyle(1, 0xff0000, 0, false, "normal", CapsStyle.SQUARE, JointStyle.MITER);
            clickArea.graphics.beginFill(0xff0000, 0);
            clickArea.graphics.drawRect(0, 0, width,  height);
            clickArea.graphics.endFill();
            clickArea.x = int(rec[0]);
            clickArea.y = int(rec[1]);
            clickArea.name = "click_" + i.toString();
            clickArea.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void{
                var index:int = int(e.currentTarget.name.replace("click_", ""));
                for(var j:int = 0; j<mainApp.thumbnails.getChildren().length; j++){
                    var img:Image = Image(mainApp.thumbnails.getChildAt(j));
                    if(img.name == "frame_"+index.toString()){ img.visible = true; }
                }
            });
            clickArea.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void{
                var currIndex:int = currentPage - 1;
                for(var j:int = 0; j<mainApp.thumbnails.getChildren().length; j++){
                    var img:Image = Image(mainApp.thumbnails.getChildAt(j));
                    if(img.name.indexOf("frame_") > -1){
                        img.visible = img.name == "frame_"+currIndex.toString();
                    }
                }
            });
            clickArea.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
                var index:int = int(e.currentTarget.name.replace("click_", ""));
                currentPage = index+1;
                Requests.getPage(currentPage);
                //mainApp.fPageNumber.text = (index+1).toString();
                //Navigator.getPageByNumber();
                for(var j:int = 0; j<mainApp.thumbnails.getChildren().length; j++){
                    var img:Image = Image(mainApp.thumbnails.getChildAt(j));
                    if(img.name.indexOf("frame_") > -1){
                        img.visible = img.name == "frame_"+index.toString();
                    }
                }

            });
            mainApp.thumbnails.addChild(clickArea);
        }
    }

    private static function centerImage():void
    {
        if(mainApp.mimg.width>0)
        {
            clearInterval(initInterval);
            var centerImgX:int = Math.floor((mainApp.panel.width - mainApp.mimg.width)/2);
            var centerImgY:int = Math.floor((mainApp.panel.height - 32 - mainApp.mimg.height)/2);
            if(centerImgX<0) { centerImgX = 0; }
            if(centerImgY<0) { centerImgY = 0; }

            mainApp.mimg.x = centerImgX;
            mainApp.mimg.y = centerImgY;
            Layer.drawLayer();
        }
    }

    public static function getPageWidth():int
    {
        return mainApp.mimg.width;
    }
    public static function getPageHeight():int
    {
        return mainApp.mimg.height;
    }
}
}
