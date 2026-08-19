class FinanceSummary {
  final double totalIncome;
  final double totalActivityCost;
  final double totalOverheadCost;
  final double net;

  const FinanceSummary({
    required this.totalIncome,
    required this.totalActivityCost,
    required this.totalOverheadCost,
    required this.net,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> j) =>
      FinanceSummary(
        totalIncome:       (j['totalIncome']       as num).toDouble(),
        totalActivityCost: (j['totalActivityCost'] as num).toDouble(),
        totalOverheadCost: (j['totalOverheadCost'] as num).toDouble(),
        net:               (j['net']               as num).toDouble(),
      );
}

class SeasonReport {
  final String       season;
  final List<String> fields;
  final List<String> crops;
  final double       totalArea;
  final int          cropCount;
  final double       labourCost;
  final double       inputCost;
  final double       otherCost;
  final double       totalCost;
  final double       costPerHectare;
  final double       revenue;
  final double       netProfit;

  const SeasonReport({
    required this.season,
    required this.fields,
    required this.crops,
    required this.totalArea,
    required this.cropCount,
    required this.labourCost,
    required this.inputCost,
    required this.otherCost,
    required this.totalCost,
    required this.costPerHectare,
    required this.revenue,
    required this.netProfit,
  });

  factory SeasonReport.fromJson(Map<String, dynamic> j) =>
      SeasonReport(
        season:         j['season']                    as String,
        fields:         List<String>.from(j['fields']  as List),
        crops:          List<String>.from(j['crops']   as List),
        totalArea:      (j['totalArea']      as num).toDouble(),
        cropCount:      j['cropCount']       as int,
        labourCost:     (j['labourCost']     as num).toDouble(),
        inputCost:      (j['inputCost']      as num).toDouble(),
        otherCost:      (j['otherCost']      as num).toDouble(),
        totalCost:      (j['totalCost']      as num).toDouble(),
        costPerHectare: (j['costPerHectare'] as num).toDouble(),
        revenue:        (j['revenue']        as num? ?? 0).toDouble(),
        netProfit:      (j['netProfit']      as num? ?? 0).toDouble(),
      );
}

class CropReport {
  final String       cropName;
  final List<String> seasons;
  final double       totalArea;
  final int          count;
  final double       labourCost;
  final double       inputCost;
  final double       totalCost;
  final double       costPerHectare;
  final double       revenue;
  final double       netProfit;

  const CropReport({
    required this.cropName,
    required this.seasons,
    required this.totalArea,
    required this.count,
    required this.labourCost,
    required this.inputCost,
    required this.totalCost,
    required this.costPerHectare,
    required this.revenue,
    required this.netProfit,
  });

  factory CropReport.fromJson(Map<String, dynamic> j) =>
      CropReport(
        cropName:       j['cropName']                    as String,
        seasons:        List<String>.from(j['seasons']   as List),
        totalArea:      (j['totalArea']      as num).toDouble(),
        count:          j['count']           as int,
        labourCost:     (j['labourCost']     as num).toDouble(),
        inputCost:      (j['inputCost']      as num).toDouble(),
        totalCost:      (j['totalCost']      as num).toDouble(),
        costPerHectare: (j['costPerHectare'] as num).toDouble(),
        revenue:        (j['revenue']        as num? ?? 0).toDouble(),
        netProfit:      (j['netProfit']      as num? ?? 0).toDouble(),
      );
}

class FieldReport {
  final String       fieldId;
  final String       fieldName;
  final String       soilType;
  final double       totalArea;
  final double       totalAreaPlanted;
  final List<String> crops;
  final double       labourCost;
  final double       inputCost;
  final double       totalCost;
  final double       costPerHectare;

  const FieldReport({
    required this.fieldId,
    required this.fieldName,
    required this.soilType,
    required this.totalArea,
    required this.totalAreaPlanted,
    required this.crops,
    required this.labourCost,
    required this.inputCost,
    required this.totalCost,
    required this.costPerHectare,
  });

  factory FieldReport.fromJson(Map<String, dynamic> j) =>
      FieldReport(
        fieldId:          j['fieldId']                     as String,
        fieldName:        j['fieldName']                   as String,
        soilType:         j['soilType']                    as String,
        totalArea:        (j['totalArea']        as num).toDouble(),
        totalAreaPlanted: (j['totalAreaPlanted'] as num).toDouble(),
        crops:            List<String>.from(j['crops']     as List),
        labourCost:       (j['labourCost']       as num).toDouble(),
        inputCost:        (j['inputCost']        as num).toDouble(),
        totalCost:        (j['totalCost']        as num).toDouble(),
        costPerHectare:   (j['costPerHectare']   as num).toDouble(),
      );
}

class CropFieldDetail {
  final String id;
  final String cropName;
  final String variety;
  final String fieldName;
  final String season;
  final double areaPlanted;
  final String status;
  final double labour;
  final double inputs;
  final double other;
  final double totalCost;
  final double costPerHectare;

  const CropFieldDetail({
    required this.id,
    required this.cropName,
    required this.variety,
    required this.fieldName,
    required this.season,
    required this.areaPlanted,
    required this.status,
    required this.labour,
    required this.inputs,
    required this.other,
    required this.totalCost,
    required this.costPerHectare,
  });

  factory CropFieldDetail.fromJson(Map<String, dynamic> j) =>
      CropFieldDetail(
        id:             j['id']             as String,
        cropName:       j['cropName']       as String,
        variety:        j['variety']        as String,
        fieldName:      j['fieldName']      as String,
        season:         j['season']         as String,
        areaPlanted:    (j['areaPlanted']   as num).toDouble(),
        status:         j['status']         as String,
        labour:         (j['labour']        as num).toDouble(),
        inputs:         (j['inputs']        as num).toDouble(),
        other:          (j['other']         as num).toDouble(),
        totalCost:      (j['totalCost']     as num).toDouble(),
        costPerHectare: (j['costPerHectare']as num).toDouble(),
      );
}

class EmployeeReport {
  final String employeeId;
  final String name;
  final String role;
  final int    activities;
  final double totalDays;
  final double totalHours;
  final double totalEarned;

  const EmployeeReport({
    required this.employeeId,
    required this.name,
    required this.role,
    required this.activities,
    required this.totalDays,
    required this.totalHours,
    required this.totalEarned,
  });

  String get initials => name
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();

  factory EmployeeReport.fromJson(Map<String, dynamic> j) =>
      EmployeeReport(
        employeeId:  j['employeeId']  as String,
        name:        j['name']        as String,
        role:        j['role']        as String,
        activities:  j['activities']  as int,
        totalDays:   (j['totalDays']  as num).toDouble(),
        totalHours:  (j['totalHours'] as num).toDouble(),
        totalEarned: (j['totalEarned']as num).toDouble(),
      );
}

class InputReport {
  final String inputName;
  final String category;
  final String unit;
  final double totalQuantity;
  final int    usageCount;
  final double totalCost;

  const InputReport({
    required this.inputName,
    required this.category,
    required this.unit,
    required this.totalQuantity,
    required this.usageCount,
    required this.totalCost,
  });

  factory InputReport.fromJson(Map<String, dynamic> j) =>
      InputReport(
        inputName:     j['inputName']     as String,
        category:      j['category']      as String,
        unit:          j['unit']          as String,
        totalQuantity: (j['totalQuantity']as num).toDouble(),
        usageCount:    j['usageCount']    as int,
        totalCost:     (j['totalCost']    as num).toDouble(),
      );
}

class YieldByType {
  final String cropName;
  final int    records;
  final double totalAreaPlanted;
  final double totalYieldKg;
  final double totalCost;
  final double yieldPerHa;
  final double costPerKg;

  const YieldByType({
    required this.cropName,
    required this.records,
    required this.totalAreaPlanted,
    required this.totalYieldKg,
    required this.totalCost,
    required this.yieldPerHa,
    required this.costPerKg,
  });

  String get displayKg => totalYieldKg >= 1000
      ? '${(totalYieldKg / 1000).toStringAsFixed(2)} t'
      : '${totalYieldKg.round()} kg';

  factory YieldByType.fromJson(Map<String, dynamic> j) =>
      YieldByType(
        cropName:        j['cropName']                     as String,
        records:         j['records']                      as int,
        totalAreaPlanted:(j['totalAreaPlanted'] as num).toDouble(),
        totalYieldKg:    (j['totalYieldKg']     as num).toDouble(),
        totalCost:       (j['totalCost']         as num).toDouble(),
        yieldPerHa:      (j['yieldPerHa']        as num).toDouble(),
        costPerKg:       (j['costPerKg']         as num).toDouble(),
      );
}

class YieldDetailRecord {
  final String cropFieldId;
  final String cropName;
  final String variety;
  final String fieldName;
  final String season;
  final double areaPlanted;
  final double totalYieldKg;
  final double totalCost;
  final double costPerKg;
  final double yieldPerHa;

  const YieldDetailRecord({
    required this.cropFieldId,
    required this.cropName,
    required this.variety,
    required this.fieldName,
    required this.season,
    required this.areaPlanted,
    required this.totalYieldKg,
    required this.totalCost,
    required this.costPerKg,
    required this.yieldPerHa,
  });

  String get displayKg => totalYieldKg >= 1000
      ? '${(totalYieldKg / 1000).toStringAsFixed(2)} t'
      : '${totalYieldKg.round()} kg';

  factory YieldDetailRecord.fromJson(Map<String, dynamic> j) =>
      YieldDetailRecord(
        cropFieldId:  j['cropFieldId']  as String,
        cropName:     j['cropName']     as String,
        variety:      j['variety']      as String,
        fieldName:    j['fieldName']    as String,
        season:       j['season']       as String,
        areaPlanted:  (j['areaPlanted'] as num).toDouble(),
        totalYieldKg: (j['totalYieldKg']as num).toDouble(),
        totalCost:    (j['totalCost']   as num).toDouble(),
        costPerKg:    (j['costPerKg']   as num).toDouble(),
        yieldPerHa:   (j['yieldPerHa']  as num).toDouble(),
      );
}

class YieldsReport {
  final List<YieldByType>      byType;
  final List<YieldDetailRecord> records;

  const YieldsReport({
    required this.byType,
    required this.records,
  });

  factory YieldsReport.fromJson(Map<String, dynamic> j) =>
      YieldsReport(
        byType: (j['byType'] as List)
            .map((e) => YieldByType.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        records: (j['records'] as List)
            .map((e) => YieldDetailRecord.fromJson(
            e as Map<String, dynamic>))
            .toList(),
      );
}

class LivestockReport {
  final String livestockType;
  final int    animalCount;
  final double saleIncome;
  final double productionIncome;
  final double healthCost;
  final double otherCost;
  final double totalCost;
  final double revenue;
  final double netProfit;

  const LivestockReport({
    required this.livestockType,
    required this.animalCount,
    required this.saleIncome,
    required this.productionIncome,
    required this.healthCost,
    required this.otherCost,
    required this.totalCost,
    required this.revenue,
    required this.netProfit,
  });

  factory LivestockReport.fromJson(Map<String, dynamic> j) =>
      LivestockReport(
        livestockType:    j['livestockType']              as String,
        animalCount:       j['animalCount']    as int,
        saleIncome:        (j['saleIncome']        as num).toDouble(),
        productionIncome:  (j['productionIncome']  as num).toDouble(),
        healthCost:        (j['healthCost']        as num).toDouble(),
        otherCost:         (j['otherCost']         as num).toDouble(),
        totalCost:         (j['totalCost']         as num).toDouble(),
        revenue:           (j['revenue']           as num).toDouble(),
        netProfit:         (j['netProfit']         as num).toDouble(),
      );
}

class ReportData {
  final FinanceSummary        financeSummary;
  final List<SeasonReport>    seasonReport;
  final List<CropReport>      cropReport;
  final List<FieldReport>     fieldReport;
  final List<CropFieldDetail> cropFieldDetail;
  final List<EmployeeReport>  employeeReport;
  final List<InputReport>     inputReport;
  final YieldsReport          yieldsReport;
  final List<LivestockReport> livestockReport;

  const ReportData({
    required this.financeSummary,
    required this.seasonReport,
    required this.cropReport,
    required this.fieldReport,
    required this.cropFieldDetail,
    required this.employeeReport,
    required this.inputReport,
    required this.yieldsReport,
    required this.livestockReport,
  });

  factory ReportData.fromJson(Map<String, dynamic> j) =>
      ReportData(
        financeSummary: FinanceSummary.fromJson(
            j['financeSummary'] as Map<String, dynamic>),
        seasonReport: (j['seasonReport'] as List)
            .map((e) => SeasonReport.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        cropReport: (j['cropReport'] as List)
            .map((e) => CropReport.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        fieldReport: (j['fieldReport'] as List)
            .map((e) => FieldReport.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        cropFieldDetail: (j['cropFieldDetail'] as List)
            .map((e) => CropFieldDetail.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        employeeReport: (j['employeeReport'] as List)
            .map((e) => EmployeeReport.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        inputReport: (j['inputReport'] as List)
            .map((e) => InputReport.fromJson(
            e as Map<String, dynamic>))
            .toList(),
        yieldsReport: YieldsReport.fromJson(
            j['yieldsReport'] as Map<String, dynamic>),
        livestockReport: (j['livestockReport'] as List? ?? const [])
            .map((e) => LivestockReport.fromJson(
            e as Map<String, dynamic>))
            .toList(),
      );
}