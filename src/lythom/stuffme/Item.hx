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
    public function new(id:String, bonuses:Array<Bonus>, ?equipedItems:Array<Item>) {
        this.id = id;
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

    /**
     * Find a parent item by looking for the current item in an Item tree.
     * Item must be unique in the tree for this function to work.
     * @param items root items from where to search the current item.
     * @return Item parent of the current item in the tree.
     */
    // public function getParent(items:Array<Item>):Item {
    //     // search in items if one is the parent of the passedItem
    //     var parent = items.find(item -> item.equipedItems.exists(i -> i == this));
    //     if (parent != null) {
    //         return parent;
    //     }
    //     // if the parent is not among items, look into subitems recursively
    //     for (item in items) {
    //         var p = this.getParent(item.equipedItems);
    //         if (p != null) {
    //             return p;
    //         }
    //     }
    //     return null;
    // }

    /**
     * Find all sibling items, including current item, in an Item tree.
     * Item must be unique in the tree for this function to work.
     * @param items root items from where to search the current item.
     * @return Array<Item> items that are on the same tree level of the current item.
     */
    // public function getSiblings(items:Array<Item>):Array<Item> {
    //     if (items.exists(i -> i == this)) {
    //         return items;
    //     }
    //     for (item in items) {
    //         var s = getSiblings(item.equipedItems);
    //         if (s != null) {
    //             return s;
    //         }
    //     }
    //     return null;
    // }
    public function toString() {
        return "Item(" + this.id + ")";
    }
}
