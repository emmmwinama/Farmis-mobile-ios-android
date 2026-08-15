import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/shared/utils/yield_pricing.dart';

void main() {
  test('matches the web app\'s break-even/suggested price numbers', () {
    // Real numbers from the web Yields page: Maize, MWK 6,297,547 total
    // cost, 6,750 kg total yield, 30% target margin.
    final suggestion = YieldPriceSuggestion.compute(
      totalCost: 6297547,
      totalYieldKg: 6750,
      marginPercent: 30,
    );

    expect(suggestion.breakEvenPerKg!.round(), 933);
    expect(suggestion.breakEvenPerBag50!.round(), 46648);
    expect(suggestion.breakEvenPerTonne!.round(), 932970);
    expect(suggestion.suggestedPerKg!.round(), 1213);
    expect(suggestion.suggestedPerBag50!.round(), 60643);
    expect(suggestion.projectedProfit!.round(), 1889264);
  });

  test('returns nulls when there is no recorded yield yet', () {
    final suggestion = YieldPriceSuggestion.compute(
      totalCost: 100000,
      totalYieldKg: 0,
      marginPercent: 30,
    );

    expect(suggestion.breakEvenPerKg, isNull);
    expect(suggestion.suggestedPerKg, isNull);
    expect(suggestion.projectedProfit, isNull);
  });

  test('suggested price is a flat markup on break-even, not a margin-on-revenue', () {
    final suggestion = YieldPriceSuggestion.compute(
      totalCost: 1000,
      totalYieldKg: 10,
      marginPercent: 50,
    );

    // break-even = 100/kg; suggested = 100 * 1.5 = 150/kg (not 100 / (1-0.5) = 200)
    expect(suggestion.breakEvenPerKg, 100);
    expect(suggestion.suggestedPerKg, 150);
    expect(suggestion.projectedProfit, 500); // (150-100) * 10
  });
}
