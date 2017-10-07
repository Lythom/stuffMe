package lythom.stuffme;

import haxe.Log;
import haxe.ds.StringMap;

typedef Bonus = Float;
typedef Item = Array<Bonus>;

@:keep
class StuffMe {
    public static function resolve(attributes:AttributeSet<Float>, items:Array<Item>) {
        attributes.setAttribute("test", items.length);
        return attributes;
    }
}
