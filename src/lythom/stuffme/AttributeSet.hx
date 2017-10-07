package lythom.stuffme;
import haxe.ds.StringMap;

class AttributeSet<T> extends StringMap<T> {
    public function new() {
        super();
    }

    public function setAttribute(key:String, value:T):Void {
        super.set(key, value);
    }

    public function getAttribute(key:String):Null<T> {
        return super.get(key);
    }
}
