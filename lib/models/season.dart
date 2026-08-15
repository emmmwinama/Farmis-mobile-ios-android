class SeasonCropRow {
  final String id;
  final String cropName;
  final String variety;
  final String fieldName;
  final String status;
  final double areaPlanted;
  final double totalCost;
  final double revenue;
  final double totalYieldKg;

  const SeasonCropRow({
    required this.id,
    required this.cropName,
    required this.variety,
    required this.fieldName,
    required this.status,
    required this.areaPlanted,
    required this.totalCost,
    required this.revenue,
    required this.totalYieldKg,
  });

  factory SeasonCropRow.fromJson(Map<String, dynamic> json) => SeasonCropRow(
        id: json['id'] as String,
        cropName: json['cropName'] as String? ?? '',
        variety: json['variety'] as String? ?? '',
        fieldName: json['fieldName'] as String? ?? '',
        status: json['status'] as String? ?? '',
        areaPlanted: (json['areaPlanted'] as num? ?? 0).toDouble(),
        totalCost: (json['totalCost'] as num? ?? 0).toDouble(),
        revenue: (json['revenue'] as num? ?? 0).toDouble(),
        totalYieldKg: (json['totalYieldKg'] as num? ?? 0).toDouble(),
      );
}

class SeasonSummary {
  final String season;
  final List<String> fields;
  final List<String> crops;
  final List<SeasonCropRow> cropRows;
  final int cropCount;
  final double totalArea;
  final double totalCost;
  final double revenue;
  final double totalYieldKg;
  final int activeCrops;
  final int archivedCrops;
  final int activityCount;
  final double netProfit;
  final double yieldPerHa;
  final double costPerHa;
  final double? costPerKg;

  const SeasonSummary({
    required this.season,
    required this.fields,
    required this.crops,
    required this.cropRows,
    required this.cropCount,
    required this.totalArea,
    required this.totalCost,
    required this.revenue,
    required this.totalYieldKg,
    required this.activeCrops,
    required this.archivedCrops,
    required this.activityCount,
    required this.netProfit,
    required this.yieldPerHa,
    required this.costPerHa,
    this.costPerKg,
  });

  factory SeasonSummary.fromJson(Map<String, dynamic> json) => SeasonSummary(
        season: json['season'] as String? ?? '',
        fields: List<String>.from(json['fields'] as List? ?? const []),
        crops: List<String>.from(json['crops'] as List? ?? const []),
        cropRows: (json['cropRows'] as List? ?? const [])
            .map((e) => SeasonCropRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        cropCount: (json['cropCount'] as num? ?? 0).toInt(),
        totalArea: (json['totalArea'] as num? ?? 0).toDouble(),
        totalCost: (json['totalCost'] as num? ?? 0).toDouble(),
        revenue: (json['revenue'] as num? ?? 0).toDouble(),
        totalYieldKg: (json['totalYieldKg'] as num? ?? 0).toDouble(),
        activeCrops: (json['activeCrops'] as num? ?? 0).toInt(),
        archivedCrops: (json['archivedCrops'] as num? ?? 0).toInt(),
        activityCount: (json['activityCount'] as num? ?? 0).toInt(),
        netProfit: (json['netProfit'] as num? ?? 0).toDouble(),
        yieldPerHa: (json['yieldPerHa'] as num? ?? 0).toDouble(),
        costPerHa: (json['costPerHa'] as num? ?? 0).toDouble(),
        costPerKg: (json['costPerKg'] as num?)?.toDouble(),
      );
}

class SeasonsData {
  final List<String> allSeasons;
  final List<SeasonSummary> seasons;
  final String? selectedSeason;

  const SeasonsData({
    required this.allSeasons,
    required this.seasons,
    this.selectedSeason,
  });

  factory SeasonsData.fromJson(Map<String, dynamic> json) => SeasonsData(
        allSeasons: List<String>.from(json['allSeasons'] as List? ?? const []),
        seasons: (json['seasons'] as List? ?? const [])
            .map((e) => SeasonSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        selectedSeason: json['selectedSeason'] as String?,
      );
}

class SeasonCompareRow {
  final String id;
  final String cropName;
  final String fieldName;
  final String variety;
  final double areaPlanted;
  final String status;

  const SeasonCompareRow({
    required this.id,
    required this.cropName,
    required this.fieldName,
    required this.variety,
    required this.areaPlanted,
    required this.status,
  });

  factory SeasonCompareRow.fromJson(Map<String, dynamic> json) =>
      SeasonCompareRow(
        id: json['id'] as String,
        cropName: json['cropName'] as String? ?? '',
        fieldName: json['fieldName'] as String? ?? '',
        variety: json['variety'] as String? ?? '',
        areaPlanted: (json['areaPlanted'] as num? ?? 0).toDouble(),
        status: json['status'] as String? ?? '',
      );
}

class SeasonCompareSide {
  final String season;
  final int cropCount;
  final List<String> cropTypes;
  final double totalArea;
  final double totalCost;
  final double revenue;
  final double netProfit;
  final double totalYieldKg;
  final double yieldPerHa;
  final double costPerHa;
  final double? costPerKg;
  final List<SeasonCompareRow> rows;

  const SeasonCompareSide({
    required this.season,
    required this.cropCount,
    required this.cropTypes,
    required this.totalArea,
    required this.totalCost,
    required this.revenue,
    required this.netProfit,
    required this.totalYieldKg,
    required this.yieldPerHa,
    required this.costPerHa,
    this.costPerKg,
    required this.rows,
  });

  factory SeasonCompareSide.fromJson(Map<String, dynamic> json) =>
      SeasonCompareSide(
        season: json['season'] as String? ?? '',
        cropCount: (json['cropCount'] as num? ?? 0).toInt(),
        cropTypes: List<String>.from(json['cropTypes'] as List? ?? const []),
        totalArea: (json['totalArea'] as num? ?? 0).toDouble(),
        totalCost: (json['totalCost'] as num? ?? 0).toDouble(),
        revenue: (json['revenue'] as num? ?? 0).toDouble(),
        netProfit: (json['netProfit'] as num? ?? 0).toDouble(),
        totalYieldKg: (json['totalYieldKg'] as num? ?? 0).toDouble(),
        yieldPerHa: (json['yieldPerHa'] as num? ?? 0).toDouble(),
        costPerHa: (json['costPerHa'] as num? ?? 0).toDouble(),
        costPerKg: (json['costPerKg'] as num?)?.toDouble(),
        rows: (json['rows'] as List? ?? const [])
            .map((e) => SeasonCompareRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SeasonMetricDelta {
  final double value;
  final double? pct;
  final bool? improved;

  const SeasonMetricDelta({required this.value, this.pct, this.improved});

  factory SeasonMetricDelta.fromJson(Map<String, dynamic> json) =>
      SeasonMetricDelta(
        value: (json['value'] as num? ?? 0).toDouble(),
        pct: (json['pct'] as num?)?.toDouble(),
        improved: json['improved'] as bool?,
      );
}

class SeasonComparisonDeltas {
  final SeasonMetricDelta crops;
  final SeasonMetricDelta area;
  final SeasonMetricDelta totalCost;
  final SeasonMetricDelta revenue;
  final SeasonMetricDelta netProfit;
  final SeasonMetricDelta totalYieldKg;
  final SeasonMetricDelta yieldPerHa;
  final SeasonMetricDelta costPerHa;
  final SeasonMetricDelta? costPerKg;

  const SeasonComparisonDeltas({
    required this.crops,
    required this.area,
    required this.totalCost,
    required this.revenue,
    required this.netProfit,
    required this.totalYieldKg,
    required this.yieldPerHa,
    required this.costPerHa,
    this.costPerKg,
  });

  factory SeasonComparisonDeltas.fromJson(Map<String, dynamic> json) {
    SeasonMetricDelta delta(String key) =>
        SeasonMetricDelta.fromJson(json[key] as Map<String, dynamic>? ?? const {});
    return SeasonComparisonDeltas(
      crops: delta('crops'),
      area: delta('area'),
      totalCost: delta('totalCost'),
      revenue: delta('revenue'),
      netProfit: delta('netProfit'),
      totalYieldKg: delta('totalYieldKg'),
      yieldPerHa: delta('yieldPerHa'),
      costPerHa: delta('costPerHa'),
      costPerKg: json['costPerKg'] != null
          ? SeasonMetricDelta.fromJson(json['costPerKg'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SeasonCompareData {
  final List<String> allSeasons;
  final SeasonCompareSide seasonA;
  final SeasonCompareSide seasonB;
  final SeasonComparisonDeltas comparison;

  const SeasonCompareData({
    required this.allSeasons,
    required this.seasonA,
    required this.seasonB,
    required this.comparison,
  });

  factory SeasonCompareData.fromJson(Map<String, dynamic> json) =>
      SeasonCompareData(
        allSeasons: List<String>.from(json['allSeasons'] as List? ?? const []),
        seasonA:
            SeasonCompareSide.fromJson(json['seasonA'] as Map<String, dynamic>),
        seasonB:
            SeasonCompareSide.fromJson(json['seasonB'] as Map<String, dynamic>),
        comparison: SeasonComparisonDeltas.fromJson(
            json['comparison'] as Map<String, dynamic>),
      );
}
