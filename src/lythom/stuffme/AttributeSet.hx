package lythom.stuffme;

import haxe.ds.StringMap;
import lythom.stuffme.BonusDetail;
import lythom.stuffme.ItemDetail;

using lythom.stuffme.StuffMe;
using Lambda;

@:keep
class AttributeSet {
    private var values:AttributeValues = new AttributeValues();

    public function new(?values:AttributeValues) {
        this.values = (values != null) ? values : new AttributeValues();
    }

    public function with(items:Array<Item>):Array<ItemDetail> {
        if (items.length == 0) {
            return [];
        }
        return this.getItemsDetails(this.values, items);
    }

    public function calculateAttributeValues(itemDetails:Array<ItemDetail>):AttributeValues {
        var thisBonusValues = itemDetails.flatMap(d -> d.bonusDetailList.map(b -> b.value)).mergeAll();
        var childItemDetail = itemDetails.flatMap(d -> d.items);
        if (childItemDetail.length == 0) {
            return thisBonusValues.merge(this.values);
        }
        return thisBonusValues.merge(calculateAttributeValues(childItemDetail)).merge(this.values);
    }

    /**
     * Calculate the bonus items would grant on this baseValues.
     * @param baseValues
     * @param items
     * @return Array<ItemDetail>
     */
    public function getItemsDetails(baseValues:AttributeValues, items:Array<Item>):Array<ItemDetail> {
        var cumulatedBonusDetails:Array<BonusDetail> = [];
        var itemsDetails:Array<ItemDetail> = [];

        // For each item, calculate the BonusDetail by priority
        for (priority in items.getPrioritiesSorted()) {
            // take into account bonus calculated from previous priorities
            var cumulatedValue = cumulatedBonusDetails.map(b -> b.value).mergeAll().merge(baseValues);
            // calculate for each item the list of BonusDetail of current priority from AttributeSet data and cumulatedBonusValues
            var itemsBonusDetailsOfPriority:Array<BonusDetail> = items.flatMap(item -> item.getItemBonuses(cumulatedValue, priority));

            // apply on current attributes the cumulated bonus value in order to include them in next bonuses calculations
            cumulatedBonusDetails = cumulatedBonusDetails.concat(itemsBonusDetailsOfPriority);
        }

        // Now that each item bonus value is calculated, subItems, that are based on the item granted bonus, can be calculated as well.
        for (item in items) {
            var itemBonusDetailList = cumulatedBonusDetails.filter(b -> b.item == item);
            var itemAttributeValues = itemBonusDetailList.map(b -> b.value).mergeAll();
            itemsDetails.push({
                item: item,
                items: item.getItemsDetails(itemAttributeValues, item.equipedItems),
                bonusDetailList: itemBonusDetailList
            });
        }
        return itemsDetails;
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
