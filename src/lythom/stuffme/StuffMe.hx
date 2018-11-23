package lythom.stuffme;

import haxe.ds.StringMap;

@:keep
class StuffMe {
    static public function merge(attributeSet:StringMap<Float>, BonusValues:BonusValues) {
        for (key => value in BonusValues) {
            var currentVal = attributeSet.get(key);
            attributeSet.set(key, currentVal == null ? value : currentVal + value);
        }
    }
}
