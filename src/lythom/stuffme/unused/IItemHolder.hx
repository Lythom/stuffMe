package lythom.stuffme;

import haxe.ds.StringMap;

using lythom.stuffme.StuffMe;

@:keep
interface IItemHolder {
    public var equipedItems:Array<Item>;

    public function equip(item:Item);

    public function unequip(item:Item);

    public function copy():IItemHolder;

    public function set(key:String, value:Float):Void {
        values.set(key, value);
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
