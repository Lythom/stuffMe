package lythom.stuffme;

import lythom.stuffme.Bonus;

using Lambda;

typedef CalculatedStuff = {items:Array<ItemDetail>, values:AttributeValues};

@:keep
class StuffMe {
    public static function with(attributes:AttributeValues, items:Array<Item>):CalculatedStuff {
        if (items.length == 0) {
            return {
                values: attributes,
                items: []
            };
        }
        var itemDetails = StuffMe.calculateItemDetails(attributes, items, null);
        var values = StuffMe.merge(StuffMe.calculateBonusValues(attributes, itemDetails), attributes);
        return {
            items: itemDetails,
            values: values
        };
    }

    public static function calculateBonusValues(
        attributes:AttributeValues,
        itemDetails:Array<ItemDetail>):AttributeValues {
        var thisBonusValues = StuffMe.mergeAll(itemDetails.flatMap(d -> d.bonuses.map(b -> b.value)));
        var childItemDetail = itemDetails.flatMap(d -> d.items);
        if (childItemDetail.length == 0) {
            return thisBonusValues;
        }
        return StuffMe.merge(thisBonusValues, StuffMe.calculateBonusValues(attributes, childItemDetail));
    }

    /**
     * Calculate the bonus items would grant on this attributes.
     * @param attributes
     * @param items
     * @param parentItem
     * @return Array<ItemDetail>
     */
    public static function calculateItemDetails(
        attributes:AttributeValues,
        items:Array<Item>,
        parentItem:Item):Array<ItemDetail> {
        if (items.length == 0) {
            return [];
        }

        var cumulatedBonusDetails:Array<BonusDetail> = [];
        var itemsDetails:Array<ItemDetail> = [];

        // For each item, calculate the BonusDetail by priority
        for (priority in StuffMe.getPrioritiesSorted(items)) {
            // take into account bonus calculated from previous priorities
            var cumulatedValue = StuffMe.merge(StuffMe.mergeAll(
                    cumulatedBonusDetails.map(b -> b.value)
                ), attributes);
            // calculate for each item the list of BonusDetail of current priority
            // from AttributeSet data and cumulatedBonusValues
            var itemsBonusDetailsOfPriority:Array<BonusDetail> = items.flatMap(
                item -> item.getItemBonuses(cumulatedValue, priority, parentItem, items)
            );

            // apply on current attributes the cumulated bonus value in order to include them in next bonuses calculations
            cumulatedBonusDetails = cumulatedBonusDetails.concat(itemsBonusDetailsOfPriority);
        }

        // Now that each item bonus value is calculated,
        // subItems, that are based on the item granted bonus, can be calculated as well.
        for (item in items) {
            var itemBonusDetails = cumulatedBonusDetails.filter(b -> b.item == item);
            var itemAttributeValues = StuffMe.mergeAll(itemBonusDetails.map(b -> b.value));
            itemsDetails.push({
                item: item,
                items: calculateItemDetails(itemAttributeValues, item.equipedItems, item),
                bonuses: itemBonusDetails
            });
        }
        return itemsDetails;
    }

    /**
     * Merge all AttributeValues values in the current AttributeValues by additioning the Float values by key.
     * @param attributes
     * @param bonusValues
     * @return AttributeValues
     */
    static public function merge(attributes:AttributeValues, bonusValues:AttributeValues):AttributeValues {
        for (key => value in bonusValues) {
            var currentVal = attributes.get(key);
            attributes.set(key, currentVal == null ? value : currentVal + value);
        }
        return attributes;
    }

    /**
     * Merge an Array of AttributeValues in the current attributes by additioning the Float values by key.
     * @param attributes
     * @param bonusValuesList
     * @return AttributeValues
     */
    static public function mergeArray(
        attributes:AttributeValues,
        bonusValuesList:Array<AttributeValues>):AttributeValues {
        for (value in bonusValuesList) {
            StuffMe.merge(attributes, value);
        }
        return attributes;
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
     * @param attributes
     * @return AttributeValues
     */
    static public function clear(attributes:AttributeValues):AttributeValues {
        for (key in attributes.keys()) {
            attributes.remove(key);
        }
        return attributes;
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
