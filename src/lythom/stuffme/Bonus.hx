package lythom.stuffme;

@:enum
abstract Priority(Int) from Int to Int {
    var Normal = 0;
    var After = 1;
    var Finally = 2;
}

typedef FormulaArgs = {
    /**
     * Attributes the bonus should be based on.
     */
    var values:AttributeValues;

    /**
     * Item the bonus is applied on.
     */
    var item:Item;

    /**
     * The current bonus.
     */
    var bonus:Bonus;

    /**
     * Other items on the same level
     */
    var siblings:Array<Item>;

    /**
     * Parent item. null if root item.
     */
    var parent:Item;
};

/**
 * Calculate an AttributeValues (bonus granted) from :
 * - base attributeValues (The entity reference stats with)
 * - current item
 * - root items equipped
 */
typedef Formula = FormulaArgs->AttributeValues;

/**
 * Renders a description from baseAttributes
 */
typedef DynamicDescription = FormulaArgs->String;

/**
 * A Bonus can calculate a bonus values to one or several attributes based on a reference AttributeSet.
 * A Bonus is usually held by an Item.
 * The reference AttributeSet is provided as argument to the formula, it will correspond to the Item parent AttributeSet.
 */
@:keep
class Bonus {
    /**
     * Calculate an AttributeValues (bonus granted) from base attributeValues (The entity reference stats with)
     */
    public var formula:Formula;
    /**
     * Normal (0) priority are applied first, After(1) and Finally(2)
     * priorities will include calculated bonuses from previous priorities in their own calculation.
     */
    public var priority:Priority;
    /**
     *  Returns a string calculated from attributes.
     */
    public var desc:DynamicDescription;

    /**
     * A Bonus can calculate a bonus values to one or several attributes based on a reference AttributeSet.
     * @param formula 	Returns an AttributeValues where values are the additional bonus granted to the attribute
     * @param desc      Returns a string calculated from attributes.
     * @param priority 	Normal (0) priority are applied first, After(1) and Finally(2)
     * priorities will include calculated bonuses from previous priorities in their own calculation.
     */
    public function new(formula:Formula, ?desc:DynamicDescription, priority:Priority = Priority.Normal) {
        this.formula = formula;
        this.desc = desc;
        this.priority = priority;
    }
}
