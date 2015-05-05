/**
 * Created by IntelliJ IDEA.
 * User: szarub
 * Date: 10/17/12
 * Time: 3:42 PM
 * To change this template use File | Settings | File Templates.
 */
package helpers {
public class Images {
    [Embed(source="/assets/editor/first_record.png")]		        [Bindable] public static var firstRec:Class;
    [Embed(source="/assets/editor/first_record_disabled.png")]      [Bindable] public static var firstRecDis:Class;
    [Embed(source="/assets/editor/previous_record.png")]		    [Bindable] public static var prevRec:Class;
    [Embed(source="/assets/editor/previous_record_disabled.png")]   [Bindable] public static var prevRecDis:Class;
    [Embed(source="/assets/editor/next_record.png")]			    [Bindable] public static var nextRec:Class;
    [Embed(source="/assets/editor/next_record_disabled.png")]       [Bindable] public static var nextRecDis:Class;
    [Embed(source="/assets/editor/last_record.png")]		    	[Bindable] public static var lastRec:Class;
    [Embed(source="/assets/editor/last_record_disabled.png")]       [Bindable] public static var lastRecDis:Class;

    [Embed(source="/assets/warning.png")]					        [Bindable] public static var img_warning:Class;
    [Embed(source="/assets/editor/hide.png")]				        [Bindable] public static var img_hide:Class;
    [Embed(source="/assets/editor/reveal.png")]				        [Bindable] public static var img_reveal:Class;
}
}
