package lythom.stuffme;

import haxe.ds.StringMap;

@:keep
class StuffMe {

    /**
     * Merge all AttributeValues values in the current AttributeValues by additioning the Float values by key.
     * @param attributeSet 
     * @param bonusValues 
     * @return AttributeValues
     */
    static public function merge(attributeSet:AttributeValues, bonusValues:AttributeValues):AttributeValues {
        for (key => value in bonusValues) {
            var currentVal = attributeSet.get(key);
            attributeSet.set(key, currentVal == null ? value : currentVal + value);
        }
        return attributeSet;
    }

    /**
     * Merge an Array of AttributeValues in the current attributeSet by additioning the Float values by key.
     * @param attributeSet 
     * @param bonusValuesList 
     * @return AttributeValues
     */
    static public function mergeArray(attributeSet:AttributeValues, bonusValuesList:Array<AttributeValues>):AttributeValues {
        for (value in bonusValuesList) {
            StuffMe.merge(attributeSet, value);
        }
        return attributeSet;
    }

    /**
     * Create a new AttributeValues that merge all AttributeValues stats by additioning the Float values by key.
     * @param bonusValuesList 
     * @return AttributeValues
     */
    static public function mergeAll(bonusValuesList:Array<AttributeValues>):AttributeValues {
        return StuffMe.mergeArray(new AttributeValues(), bonusValuesList);
    }

    /**
     * Remove all values from an AttributeValues
     * @param attributeSet 
     * @return AttributeValues
     */
    static public function clear(attributeSet:AttributeValues):AttributeValues {
        for (key in attributeSet.keys()) {
            attributeSet.remove(key);
        }
        return attributeSet;
    }

    /**
     * Extract all existing priority from a list of items and return them sorted ASC (lower priority go first).
     * @param items 
     * @return Array<Priority>
     */
    static public function getPrioritiesSorted(items:Array<Item>):Array<Priority> {
        var allBonuses = [
            for (item in items)
                for (bonus in item.bonuses)
                    bonus];
        var priorities = [for (bonus in allBonuses) bonus.priority];
        var distinctPriorities = [];
        for (p in priorities) {
            if (distinctPriorities.indexOf(p) == -1)
                distinctPriorities.push(p);
        }
        distinctPriorities.sort((priority1, priority2) -> priority1 - priority2);
        return distinctPriorities;
    }
}
