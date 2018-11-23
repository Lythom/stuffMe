package lythom.stuffme;

import haxe.ds.StringMap;

@:keep
class AttributeSet {
    private var values:StringMap<Float> = new StringMap<Float>();
    private var bonusValues:BonusValues = new BonusValues();

    public var equipedItems:Array<Item> = new Array<Item>();

    public function new(?values:StringMap<Float>, ?equipedItems:Array<Item>) {
        this.values = (values != null) ? values : new StringMap<Float>();
        this.equipedItems = (equipedItems != null) ? equipedItems : new Array<Item>();
    }

    public function update():AttributeSet {
        if (this.equipedItems.length == 0) {
            return attributes;
        }
        this.calculateItemTreeBonusValues(this.equipedItems);
        this.calculateAttributes();
    }

    public function calculateItemTreeBonusValues(subitems:Array<Item>):BonusValues {
        // calculate the bonus this items would grant on this attributeSet
        this.calculateItemsBonusValues();
        var bonusesValue:AttributeSet = getTotalBonusesValue(calculatedItems);
        // the subItems applies on the combinedBonusesValue of the item. Now that each item is calculated, subItems can be calculated as well.

        for (item in equipedItems) {
            bonusesValue.calculateItemTreeBonusValues();
        }
        var calculatedItemsAndSubItems = calculatedItems.map(item => Object.assign({}, item, {
                equipedItems: calculateBonusValues(bonusesValue, item.equipedItems, rootItems)
            }));
    }

    public function calculateItemsBonusValues():BonusValues {
        var allBonuses = [
            for (item in equipedItems)
                for (bonus in item.bonuses)
                    bonus];
        var priorities = [for (bonus in allBonuses) bonus.priority];
        var distinctPriorities = [];
        for (p in priorities) {
            if (distinctPriorities.indexOf(p) == -1)
                distinctPriorities.push(p);
        }
        distinctPriorities.sort((priority1, priority2) -> priority1 - priority2);

		for (priority in distinctPriorities) {
			// apply on current attributes the cumulated bonus value in order to include them in next bonuses calculations
			this.updateBonusValues();
			for (item in this.equipedItems) {
				// for each item, calculate the bonus granted cumulated by priority
				item.updateItemBonuses(this, priority);
			}
 			// // apply on attributes the cumulated bonus value in order to calculate next bonuses
            // var cumulatedBonusesValue = getTotalBonusesValue(cumulatedItems)
            // var cumulatedAttr = applyBonusValue(attributes, cumulatedBonusesValue)

            // // for each item, calculate the bonus granted cumulated by priority
            // var itemsWithCumulatedBonus = cumulatedItems.map(item => {
            //     return calculateItemBonuses(item, cumulatedAttr, priority, rootItems)
            // })

		}
		 return itemsWithCalculatedBonusValues
    }

	function getTotalBonusesValue(items:Array<Item>) {
		for (item in items) {
			for (bonus in item.bonuses) {
				this.bonusValues.set(bonus.)
			}
		}
		// return applyBonusesValue({}, [].concat(...items.map(item => item.bonusList.map(b => b.calculatedValue))))
	}

	static function applyBonusesValue(attributes:AttributeSet, BonusValues:BonusValues) {
		if (BonusValues == null) return;

		for(key => value in BonusValues) {
			attributes.bonusValues.set(key, attributes.bonusValues.get(key) + value);
		}
		return attributes;
	}

    public function calculateAttributes(BonusValues:BonusValues):AttributeSet {}

    public function equip(item:Item) {
        this.equipedItems.push(item);
    }

    public function unequip(item:Item):Bool {
        return this.equipedItems.remove(item);
    }

    public function copy():AttributeSet {
        return new AttributeSet(values.copy(), equipedItems.copy());
    }

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
