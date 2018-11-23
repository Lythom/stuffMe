package lythom.stuffme;

import haxe.ds.StringMap;

/**
 * A Bonus can calculate a bonus values to one or several attributes based on a reference AttributeSet.
 * A Bonus is usually held by an Item.
 * The reference AttributeSet is provided as argument to the formula, it will correspond to the Item parent AttributeSet.
 */
@:keep
class Bonus {
    public var id:String;
    public var formula:AttributeSet->BonusValues;
    public var priority:Priority;

    /**
     * A Bonus can calculate a bonus values to one or several attributes based on a reference AttributeSet.
     * @param id 		Used to document the bonus behaviour. Ie: Use as translation key
     * @param formula 	Returns a collection of attribute->value where value is the additional bonus granted to the attribute
     * @param priority 	Normal (0) priority are applied first, After(1) and Finally(2) priorities will include calculated bonuses from previous priorities in their own calculation.
     */
    public function new(id:String, formula:AttributeSet->BonusValues, priority:Priority = Priority.Normal) {
        this.id = id;
        this.formula = formula;
        this.priority = priority;
    }
}
