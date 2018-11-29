import buddy.BuddySuite;
import lythom.stuffme.Priority;
import lythom.stuffme.Bonus;
import lythom.stuffme.Attribute;
import lythom.stuffme.AttributeSet;
import lythom.stuffme.Item;
import lythom.stuffme.StuffMe;

using buddy.Should;

class RunTests extends buddy.SingleSuite {
    public function new() {
        var desc = describe;
        var itShould = it;

        var baseAttributes:AttributeSet;
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
                baseAttributes = new AttributeSet();
                baseAttributes.set(RANGE, 100);
                // baseAttributes.set(RANGESTR, "test");
                baseAttributes.set(DAMAGE, 10);
            });

            itShould("return empty array in to Items are specified", Sync(() -> {
                var calculatedDetails = baseAttributes.with([]);
                calculatedDetails.length.should.be(0);
            }));

            itShould("return initial AttributeSet if no bonusDetails are calculated", Sync(() -> {
                var calculatedAttributes = baseAttributes.calculateAttributeValues(baseAttributes.with([]));
                calculatedAttributes.get(DAMAGE).should.be(baseAttributes.get(DAMAGE));
                calculatedAttributes.get(RANGE).should.be(baseAttributes.get(RANGE));
            }));

            itShould("return a new AttributeSet with calculated attributes, when at least on item is equiped", Sync(() -> {
                var expected = [
                    "dmgFlatBonus" => baseAttributes.copy().set(DAMAGE, 15),
                    "dmgMultBonus" => baseAttributes.copy().set(DAMAGE, 12),
                    "dmgMultBaseBonus" => baseAttributes.copy().set(DAMAGE, 11),
                    "dmgFromRangeBonus" => baseAttributes.copy().set(DAMAGE, 15),
                    "rangeAndDamageBonus" => baseAttributes.copy().set(DAMAGE, 14).set(RANGE, 104),
                ];

                for (bonusKey => bonus in bonuses) {
                    var equipedItems = [new Item(bonusKey, [bonus])];
                    var calculatedAttributes = baseAttributes.calculateAttributeValues(baseAttributes.with(equipedItems));
                    calculatedAttributes.get(RANGE).should.be(expected.get(bonusKey).get(RANGE));
                    calculatedAttributes.get(DAMAGE).should.be(expected.get(bonusKey).get(DAMAGE));
                }
            }));
        }));

        desc("StuffMe AttributeSet", Sync(() -> {
            beforeEach({
                // start from fresh attribute set
                baseAttributes = new AttributeSet();
                baseAttributes.set(RANGE, 10);
                // baseAttributes.set(RANGESTR, "test");
                baseAttributes.set(DAMAGE, 100);
            });

            itShould("contains base values", Sync(() -> {
                baseAttributes.get(RANGE).should.be(10);
                baseAttributes.get(DAMAGE).should.be(100);
            }));

            itShould("preserve attributes when copied", Sync(() -> {
                var otherBaseAttribut = baseAttributes.copy();
                otherBaseAttribut.get(RANGE).should.be(10);
                otherBaseAttribut.get(DAMAGE).should.be(100);
            }));

            itShould("be able to list all attributes and values using keyValueIterator", Sync(() -> {
                var keys:Array<String> = [];
                var values:Array<Any> = [];

                for (key => value in baseAttributes.keyValueIterator()) {
                    keys.push(key);
                    values.push(value);
                }
                keys.should.containAll(["Range", "Damage"]);
                values.should.contain(10);
                values.should.contain(100);
            }));

            afterEach({});
        }));
    }
}
