package lythom.stuffme;

import lythom.stuffme.BonusValues;

using lythom.stuffme.StuffMe;

/**
 *  ## Item
 *
 *  id should be unique within the item tree:
 *
 *  * this is not required for the calculations to run,
 *  * this is required for the itemTreeCrawler to work,
 *  * it might be required for your game logic to work (depends on what you do).
 *
 *  Additional custom properties can be added to the item, they will be kept in the calculatedItems result, in the parameters given to bonus, and in the itemTreeCrawler functions.
 *  This allows to write complex bonus calculation behaviours based on holder or other items custom properties.
 *
 */
@:keep
class Item {
    /**
     * Must be unique among the item tree
     */
    public var id:String;

    /**
     * Array of the bonuses this Item grant to an AttributeSet
     */
    public final bonuses:ItemDefinition;

    /**
     * Sub-Items this Item have. Sub-Items will provide bonuses based on this item.
     */
    public var equipedItems:Array<Item>;
    public var BonusValues:BonusValues;

    // TODO: custom properties

    /**
     * Creates an Item. An Item can provide bonuses to an AttributeSet.
     * @param id 			Must be unique among the tree
     * @param bonuses 		Array of the bonuses this Item grant to an AttributeSet
     * @param equipedItems 	Sub-Items this Item have. Sub-Items will provide bonuses based on this item.
     */
    public function new(id:String, bonuses:ItemDefinition, ?equipedItems:Array<Item>) {
        this.id = id;
        this.bonuses = bonuses;

        if (equipedItems != null) {
            this.equipedItems = equipedItems;
        }
    }

    public function updateItemBonuses(attributeSet:AttributeSet, priority:Priority) {
        var currentPriorityBonuses = this.bonuses.filter(b -> b.priority == priority);
        for (bonus in currentPriorityBonuses) {
            var bonusValues = bonus.formula(attributeSet);
            this.BonusValues.merge(bonusValues);
        }
    }
}
