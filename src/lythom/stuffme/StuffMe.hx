package lythom.stuffme;

import haxe.ds.StringMap;

using Lambda;

typedef CalculatedStuff = {details:Array<ItemDetail>, values:AttributeValues};

@:keep
class StuffMe {
    public static function with(attributes:AttributeValues, items:Array<Item>):CalculatedStuff {
        if (items.length == 0) {
            return {
                values: attributes,
                details: []
            };
        }
        var details = StuffMe.calculateItemDetails(attributes, items);
        var values = StuffMe.calculateAttributeValues(attributes, details);
        return {
            details: details,
            values: values
        };
    }

    public static function calculateAttributeValues(attributes:AttributeValues, itemDetails:Array<ItemDetail>):AttributeValues {
        var thisBonusValues = StuffMe.mergeAll(itemDetails.flatMap(d -> d.bonusDetailList.map(b -> b.value)));
        var childItemDetail = itemDetails.flatMap(d -> d.items);
        if (childItemDetail.length == 0) {
            return StuffMe.merge(thisBonusValues, attributes);
        }
        return StuffMe.mergeAll([
            StuffMe.calculateAttributeValues(attributes, childItemDetail),
            thisBonusValues,
            attributes
        ]);
    }

    /**
     * Calculate the bonus items would grant on this attributes.
     * @param attributes
     * @param items
     * @return Array<ItemDetail>
     */
    public static function calculateItemDetails(attributes:AttributeValues, items:Array<Item>):Array<ItemDetail> {
        if (items.length == 0) {
            return [];
        }

        var cumulatedBonusDetails:Array<BonusDetail> = [];
        var itemsDetails:Array<ItemDetail> = [];

        // For each item, calculate the BonusDetail by priority
        for (priority in StuffMe.getPrioritiesSorted(items)) {
            // take into account bonus calculated from previous priorities
            var cumulatedValue = StuffMe.merge(
                StuffMe.mergeAll(cumulatedBonusDetails.map(b -> b.value)),
                attributes
            );
            // calculate for each item the list of BonusDetail of current priority from AttributeSet data and cumulatedBonusValues
            var itemsBonusDetailsOfPriority:Array<BonusDetail> = items.flatMap(item -> item.getItemBonuses(cumulatedValue, priority));

            // apply on current attributes the cumulated bonus value in order to include them in next bonuses calculations
            cumulatedBonusDetails = cumulatedBonusDetails.concat(itemsBonusDetailsOfPriority);
        }

        // Now that each item bonus value is calculated, subItems, that are based on the item granted bonus, can be calculated as well.
        for (item in items) {
            var itemBonusDetailList = cumulatedBonusDetails.filter(b -> b.item == item);
            var itemAttributeValues = StuffMe.mergeAll(itemBonusDetailList.map(b -> b.value));
            itemsDetails.push({
                item: item,
                items: calculateItemDetails(itemAttributeValues, item.equipedItems),
                bonusDetailList: itemBonusDetailList
            });
        }
        return itemsDetails;
    }

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
