package lythom.stuffme;

import lythom.stuffme.Bonus;

using Lambda;

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
    public static var ID_GENERATOR:Int = 0;

    /**
     * Must be unique among the item tree
     */
    public var id:String;

    /**
     * Array of the bonuses this Item grant to an AttributeSet
     */
    public final bonuses:Array<Bonus>;

    /**
     * Sub-Items this Item have. Sub-Items will provide bonuses based on this item.
     */
    public var equipedItems:Array<Item>;

    private var parent:Item;

    /**
     * Creates an Item. An Item can provide bonuses to an AttributeSet.
     * @param id 			Must be unique among the tree
     * @param bonuses 		Array of the bonuses this Item grant to an AttributeSet
     * @param equipedItems 	Sub-Items this Item have. Sub-Items will provide bonuses based on this item.
     */
    public function new(?id:String, bonuses:Array<Bonus>, ?equipedItems:Array<Item>) {
        this.id = id != null ? id : Std.string(ID_GENERATOR++);
        this.bonuses = bonuses;
        this.equipedItems = (equipedItems != null) ? equipedItems : [];
    }

    public function getItemBonuses(
        attributeValues:AttributeValues,
        priority:Priority,
        parentItem:Item,
        siblings:Array<Item>):Array<BonusDetail> {
        var bonusDetails:Array<BonusDetail> = [];
        var bonusesOfCurrentPriority = this.bonuses.filter(b -> b.priority == priority);
        for (bonus in bonusesOfCurrentPriority) {
            var formulaArgs = {
                values: attributeValues,
                item: this,
                parent: parentItem,
                siblings: siblings,
                bonus: bonus
            }
            bonusDetails.push({
                value: bonus.formula(formulaArgs),
                item: this,
                bonus: bonus,
                description: (bonus.desc != null ? bonus.desc(formulaArgs) : '')
            });
        }
        return bonusDetails;
    }

    public function toString() {
        return "Item(" + this.id + ")";
    }
}
