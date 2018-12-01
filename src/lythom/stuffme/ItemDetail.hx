package lythom.stuffme;

import lythom.stuffme.AttributeValues;
import lythom.stuffme.BonusDetail;

typedef ItemDetail = {
    var item:Item;
    var items:Array<ItemDetail>;
    var bonuses:Array<BonusDetail>;
}
