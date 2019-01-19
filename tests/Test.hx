import lythom.stuffme.AttributeValues;
import lythom.stuffme.Bonus;
import lythom.stuffme.Item;

using buddy.Should;
using Lambda;
using lythom.stuffme.StuffMe;

class SwordItem extends Item {}

class Test extends buddy.SingleSuite {
    public function new() {
        var desc = describe;
        var itShould = it;

        var baseAttributes:AttributeValues;
        var RANGE = "Range";
        var DAMAGE = "Damage";

        var blindEffetInArray = ['blind'];

        desc("StuffMe calculation", Sync(() -> {
            var bonuses = [
                "dmgFlatBonus" => new Bonus(
                    args -> [DAMAGE => 5],
                    Priority.Normal
                ),
                "dmgMultBonus" => new Bonus(
                    args -> [DAMAGE => args.values.get(DAMAGE) * 0.2],
                    Priority.After
                ),
                "dmgMultBaseBonus" => new Bonus(
                    args -> [DAMAGE => args.values.get(DAMAGE) * 0.1],
                    Priority.Normal
                ),
                "dmgFromRangeBonus" => new Bonus(
                    args -> [DAMAGE => args.values.get(RANGE) * 0.05],
                    Priority.After
                ),
                "rangeAndDamageBonus" => new Bonus(
                    args -> [DAMAGE => 4, RANGE => 4],
                    Priority.Normal
                ),
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
                calculatedStuff.items.length.should.be(0);
                calculatedStuff.values.should.be(baseAttributes);
            }));

            itShould(
                "return a new AttributeSet with calculated attributes, when at least on item is equiped",
                Sync(() -> {
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
                })
            );

            itShould("calculate bonus of same priorities from baseAttributes", Sync(() -> {
                var normalPriorityBonus = new Bonus(
                    args -> [DAMAGE => args.values.get(DAMAGE) * 1.0],
                    Priority.Normal
                );
                var normalPriorityBonus2 = new Bonus(
                    args -> [DAMAGE => args.values.get(DAMAGE) * 0.1],
                    Priority.Normal
                );
                var equipedItems = [new Item("same priorities", [normalPriorityBonus2, normalPriorityBonus])];
                var calculatedAttributes = baseAttributes.with(equipedItems).values;
                // base + bonus=100% of base + bonbonus=10% of base
                var expected = baseAttributes.get(DAMAGE) + 10 + 1;
                calculatedAttributes.get(DAMAGE).should.be(expected);
            }));

            itShould("take first priorities into account when calculating later priorities", Sync(() -> {
                var normalPriorityBonus = new Bonus(
                    args -> [DAMAGE => args.values.get(DAMAGE) * 1.0],
                    Priority.Normal
                );
                var afterPriorityBonus = new Bonus(
                    args -> [DAMAGE => args.values.get(DAMAGE) * 0.1],
                    Priority.After
                );

                // base + bonus=100% of base + bonbonus=10% of (base + bonus)
                var expected = baseAttributes.get(DAMAGE) + 10 + 2;

                var calculatedAttributes = baseAttributes.with(
                    [new Item("different priorities", [afterPriorityBonus, normalPriorityBonus])]
                ).values;
                calculatedAttributes.get(DAMAGE).should.be(expected);

                // confirm with a different bonus order
                var calculatedAttributes2 = baseAttributes.with(
                    [new Item("different priorities", [normalPriorityBonus, afterPriorityBonus])]
                ).values;
                calculatedAttributes2.get(DAMAGE).should.be(expected);
            }));

            itShould("calculate root items then subitems", Sync(() -> {
                var bonus10pRange = new Bonus(
                    args -> [RANGE => args.values.get(RANGE) * 0.1],
                    Priority.Normal
                );
                var subItem2 = new Item('sub2', [bonus10pRange]);
                var subItem1 = new Item('sub1', [bonus10pRange], [subItem2]);
                var rootItem = new Item('root', [bonus10pRange], [subItem1]);

                // base + 10% of previous + 10% of previous + 10% of previous
                var expected = 100 + 10 + 1 + 0.1;

                var calculated = baseAttributes.with([rootItem]);
                calculated.values.get(RANGE).should.be(expected);
                calculated.items[0].bonuses[0].item.id.should.be(rootItem.id);
                calculated.items[0].bonuses[0].value.get(RANGE).should.be(10);
                calculated.items[0].items[0].bonuses[0].item.id.should.be(subItem1.id);
                calculated.items[0].items[0].bonuses[0].value.get(RANGE).should.be(1);
                calculated.items[0].items[0].items[0].bonuses[0].item.id.should.be(subItem2.id);
                calculated.items[0].items[0].items[0].bonuses[0].value.get(RANGE).should.be(0.1);
            }));

            itShould("calculate conditional bonuses: a specific sibling item is equiped", Sync(() -> {
                // use closure to give context to the bonus
                var swordSynergy = new Bonus(
                    args -> {
                        if (args.siblings.exists(i -> Std.is(i, SwordItem))) {
                            return [DAMAGE => 5];
                        }
                        return new AttributeValues();
                    },
                    args -> {
                        if (args.siblings.exists(i -> Std.is(i, SwordItem))) {
                            return '[with sword] +5 $DAMAGE';
                        }
                        return '[requires sword] +5 $DAMAGE';
                    }
                );

                var sword = new SwordItem("Sword", [], []);
                var shield = new Item("Shield", [swordSynergy]); // base + 10% of previous + 10% of previous + 10% of previous

                var calculated = baseAttributes.with([sword, shield]);
                calculated.values.get(DAMAGE).should.be(15);
                calculated.items[1].bonuses[0].description.should.be("[with sword] +5 Damage");

                var calculated = baseAttributes.with([shield]);
                calculated.values.get(DAMAGE).should.be(10);
                calculated.items[0].bonuses[0].description.should.be("[requires sword] +5 Damage");
            }));

            itShould("calculate conditional bonuses: bonus depends on the parent", Sync(() -> {
                // use closure to give context to the bonus
                var ambivalentGemBonus = new Bonus(
                    args -> {
                        if (args.parent != null && args.parent.id == "Sword") {
                            return [DAMAGE => 5];
                        }
                        if (args.parent != null && args.parent.id == "Shield") {
                            return [RANGE => 2];
                        }
                        return new AttributeValues();
                    },
                    args -> {
                        if (args.parent != null && args.parent.id == "Sword") {
                            return '[with sword] Add 5 $DAMAGE';
                        }
                        if (args.parent != null && args.parent.id == "Shield") {
                            return '[with shield] Add 2 $RANGE';
                        }
                        return 'This item must be equiped on a sword or a shield.';
                    }
                );

                var gem = new Item("Gem", [ambivalentGemBonus]);
                var sword = new Item("Sword", [], [gem]);
                var shield = new Item("Shield", [], [gem]);

                var calculated = baseAttributes.with([sword]);
                calculated.values.get(DAMAGE).should.be(15);
                calculated.values.get(RANGE).should.be(100);
                calculated.items[0].items[0].bonuses[0].description.should.be('[with sword] Add 5 $DAMAGE');

                var calculated = baseAttributes.with([shield]);
                calculated.values.get(DAMAGE).should.be(10);
                calculated.values.get(RANGE).should.be(102);
                calculated.items[0].items[0].bonuses[0].description.should.be('[with shield] Add 2 $RANGE');

                var calculated = baseAttributes.with([sword, shield]);
                calculated.values.get(DAMAGE).should.be(15);
                calculated.values.get(RANGE).should.be(102);
                calculated.items[0].item.id.should.be("Sword");
                calculated.items[0].items[0].bonuses[0].description.should.be('[with sword] Add 5 $DAMAGE');
                calculated.items[1].item.id.should.be("Shield");
                calculated.items[1].items[0].bonuses[0].description.should.be('[with shield] Add 2 $RANGE');
            }));
        }));
    }
}
