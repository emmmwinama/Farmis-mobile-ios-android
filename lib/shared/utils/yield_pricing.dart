/// Break-even and suggested selling price for a harvested crop, mirroring
/// the web app's `/api/yields/suggestions` calculation: break-even is pure
/// cost recovery (totalCost / totalYieldKg); suggested price applies a flat
/// markup on top of break-even at the given target margin.
class YieldPriceSuggestion {
  final double? breakEvenPerKg;
  final double? breakEvenPerBag50;
  final double? breakEvenPerTonne;
  final double? suggestedPerKg;
  final double? suggestedPerBag50;
  final double? projectedProfit;

  const YieldPriceSuggestion({
    this.breakEvenPerKg,
    this.breakEvenPerBag50,
    this.breakEvenPerTonne,
    this.suggestedPerKg,
    this.suggestedPerBag50,
    this.projectedProfit,
  });

  factory YieldPriceSuggestion.compute({
    required double totalCost,
    required double totalYieldKg,
    required double marginPercent,
  }) {
    if (totalYieldKg <= 0) return const YieldPriceSuggestion();

    final breakEvenPerKg = totalCost / totalYieldKg;
    final suggestedPerKg = breakEvenPerKg * (1 + marginPercent / 100);
    final projectedRevenue = suggestedPerKg * totalYieldKg;

    return YieldPriceSuggestion(
      breakEvenPerKg: breakEvenPerKg,
      breakEvenPerBag50: breakEvenPerKg * 50,
      breakEvenPerTonne: breakEvenPerKg * 1000,
      suggestedPerKg: suggestedPerKg,
      suggestedPerBag50: suggestedPerKg * 50,
      projectedProfit: projectedRevenue - totalCost,
    );
  }
}
