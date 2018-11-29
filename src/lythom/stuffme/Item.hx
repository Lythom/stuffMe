package lythom.stuffme;

import haxe.ds.StringMap;
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
class Item extends AttributeSet {
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

    /**
     * calculated bonuses. Automatically updated.
     */
    // private var bonusValues:BonusValues;
    // TODO: custom properties

    /**
     * Creates an Item. An Item can provide bonuses to an AttributeSet.
     * @param id 			Must be unique among the tree
     * @param bonuses 		Array of the bonuses this Item grant to an AttributeSet
     * @param equipedItems 	Sub-Items this Item have. Sub-Items will provide bonuses based on this item.
     */
    public function new(id:String, bonuses:Array<Bonus>, ?equipedItems:Array<Item>) {
        super();
        this.id = id;
        this.bonuses = bonuses;
        this.equipedItems = (equipedItems != null) ? equipedItems : [];
    }

    public function getItemBonuses(attributeValues:AttributeValues, priority:Priority):Array<BonusDetail> {
        var bonusDetailList:Array<BonusDetail> = [];
        var bonusesOfCurrentPriority = this.bonuses.filter(b -> b.priority == priority);
        for (bonus in bonusesOfCurrentPriority) {
            bonusDetailList.push({
                value: bonus.formula(attributeValues),
                item: this,
                bonus: bonus,
                description: null, // TODO: bonus.dynamicDescription()
            });
        }
        return bonusDetailList;
    }
}
