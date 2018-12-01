package lythom.stuffme;

import haxe.ds.StringMap;
import lythom.stuffme.BonusDetail;
import lythom.stuffme.ItemDetail;

using lythom.stuffme.StuffMe;


@:keep
class AttributeSet {
    private var values:AttributeValues = new AttributeValues();

    public function new(?values:AttributeValues) {
        this.values = (values != null) ? values : new AttributeValues();
    }


    public function copy():AttributeSet {
        return new AttributeSet(values.copy());
    }

    public function set(key:String, value:Float):AttributeSet {
        values.set(key, value);
        return this;
    }

    public function get(key:String):Float {
        return values.get(key);
    }

    public function exists(key:String):Bool {
        return values.exists(key);
    }

    public function remove(key:String):Bool {
        return values.remove(key);
    }

    public function keys():Iterator<String> {
        return values.keys();
    }

    public function keyValueIterator():KeyValueIterator<String, Float> {
        return values.keyValueIterator();
    }
}
