import lythom.stuffme.AttributeValues;
import buddy.BuddySuite;
import lythom.stuffme.Priority;
import lythom.stuffme.Bonus;
import lythom.stuffme.Attribute;
import lythom.stuffme.Item;
import haxe.ds.StringMap;

using buddy.Should;
using lythom.stuffme.StuffMe;

class Test extends buddy.SingleSuite {
    public function new() {
        var desc = describe;
        var itShould = it;

        var baseAttributes:AttributeValues;
        var RANGE = new Attribute("Range");
        var DAMAGE = new Attribute("Damage");

        var blindEffetInArray = ['blind'];

        desc("StuffMe calculation", Sync(() -> {
            var bonuses = [
                "dmgFlatBonus" => new Bonus('Add 5 damage', attr -> [DAMAGE => 5], Priority.Normal),
                "dmgMultBonus" => new Bonus('Add 20% damage + bonus', attr -> [DAMAGE => attr.get(DAMAGE) * 0.2], Priority.After),
                "dmgMultBaseBonus" => new Bonus('Add 10% base damage', attr -> [DAMAGE => attr.get(DAMAGE) * 0.1], Priority.Normal),
                "dmgFromRangeBonus" => new Bonus('Add 5% range as damage', attr -> [DAMAGE => attr.get(RANGE) * 0.05], Priority.After),
                "rangeAndDamageBonus" => new Bonus('Add 4 range and 4 damage', attr -> [DAMAGE => 4, RANGE => 4], Priority.Normal),
            ];

            beforeEach({
                // start from fresh attribute set
                baseAttributes = new AttributeValues();
                baseAttributes.set(RANGE, 100);
                // baseAttributes.set(RANGESTR, "test");
                baseAttributes.set(DAMAGE, 10);
            });

            itShould("return empty array and base attributes if no Items are specified", Sync(() -> {
                var calculatedStuff = baseAttributes.with([]);
                calculatedStuff.details.length.should.be(0);
                calculatedStuff.values.should.be(baseAttributes);
            }));

            itShould("return a new AttributeSet with calculated attributes, when at least on item is equiped", Sync(() -> {
                var expected = [
                    "dmgFlatBonus" => [DAMAGE => 15, RANGE => 100],
                    "dmgMultBonus" => [DAMAGE => 12, RANGE => 100],
                    "dmgMultBaseBonus" => [DAMAGE => 11, RANGE => 100],
                    "dmgFromRangeBonus" => [DAMAGE => 15, RANGE => 100],
                    "rangeAndDamageBonus" => [DAMAGE => 14, RANGE => 104]
                ];

                for (bonusKey => bonus in bonuses) {
                    var equipedItems = [new Item(bonusKey, [bonus])];
                    var calculatedAttributes = baseAttributes.with(equipedItems).values;
                    calculatedAttributes.get(RANGE).should.be(expected.get(bonusKey).get(RANGE));
                    calculatedAttributes.get(DAMAGE).should.be(expected.get(bonusKey).get(DAMAGE));
                }
            }));
        }));
    }
}
