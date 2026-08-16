import '../../models/seasonal_template.dart';

// Bundled with the app rather than stored per-farm: these are generic
// crop playbooks, not user data, so there's nothing to migrate or persist.
const _seasonalTemplates = [
  SeasonalTemplate(
    id: 'maize-main-season',
    name: 'Maize main season',
    crop: 'Maize',
    season: 'Main rainy season',
    description:
        'A practical maize workflow from land prep through harvest, with finance-ready records.',
    activities: [
      SeasonalActivityTemplate(
        activityType: 'Land preparation',
        timing: '4-6 weeks before planting',
        notes:
            'Record field area, labour days, tractor hire, and boundary condition before planting.',
        inputs: ['Labour', 'Tractor hire', 'Fuel'],
      ),
      SeasonalActivityTemplate(
        activityType: 'Planting',
        timing: 'First effective rains',
        notes: 'Capture variety, seed rate, row spacing, and planting team.',
        inputs: ['Certified seed', 'Basal fertilizer', 'Labour'],
      ),
      SeasonalActivityTemplate(
        activityType: 'Top dressing',
        timing: '3-5 weeks after emergence',
        notes: 'Record fertilizer type, quantity, unit cost, and crop condition.',
        inputs: ['Urea', 'CAN', 'Labour'],
      ),
      SeasonalActivityTemplate(
        activityType: 'Harvesting',
        timing: 'Dry down and maturity',
        notes:
            'Capture harvest labour, bags harvested, moisture notes, and storage location.',
        inputs: ['Harvest labour', 'Bags', 'Transport'],
      ),
    ],
    payroll: [
      SeasonalPayrollTemplate(
        role: 'Planting crew',
        payRateUnit: 'day',
        notes: 'Track workers per field and planting date.',
      ),
      SeasonalPayrollTemplate(
        role: 'Weeding crew',
        payRateUnit: 'day',
        notes: 'Separate first and second weeding costs.',
      ),
      SeasonalPayrollTemplate(
        role: 'Harvest crew',
        payRateUnit: 'bag',
        notes: 'Use piece-rate payroll when paid per bag.',
      ),
    ],
    sales: [
      SeasonalSalesTemplate(
        category: 'Crop sales',
        description: 'Maize grain sale',
        evidence: [
          'Buyer name',
          'Quantity and unit',
          'Price per unit',
          'Receipt or delivery note',
        ],
      ),
    ],
    recordPackHints: [
      'Loan cashflow',
      'Buyer traceability',
      'Insurance acreage and harvest proof',
    ],
  ),
  SeasonalTemplate(
    id: 'soya-commercial',
    name: 'Soya commercial block',
    crop: 'Soya beans',
    season: 'Commercial grain season',
    description:
        'Designed for buyer contracts, aggregation, and audit-ready input tracking.',
    activities: [
      SeasonalActivityTemplate(
        activityType: 'Seed inoculation',
        timing: 'Planting day',
        notes: 'Capture inoculant batch, seed lot, and handling notes.',
        inputs: ['Soya seed', 'Inoculant', 'Labour'],
      ),
      SeasonalActivityTemplate(
        activityType: 'Weeding',
        timing: '2-4 weeks after emergence',
        notes: 'Record labour, herbicide where used, and field pressure.',
        inputs: ['Labour', 'Herbicide'],
      ),
      SeasonalActivityTemplate(
        activityType: 'Harvesting',
        timing: 'Pods dry and mature',
        notes: 'Capture bags, field losses, storage, and quality remarks.',
        inputs: ['Harvest labour', 'Bags', 'Transport'],
      ),
    ],
    payroll: [
      SeasonalPayrollTemplate(
        role: 'Scout',
        payRateUnit: 'day',
        notes: 'Use for pest and disease checks before flowering.',
      ),
      SeasonalPayrollTemplate(
        role: 'Harvest crew',
        payRateUnit: 'bag',
        notes: 'Useful when aggregating by buyer lot.',
      ),
    ],
    sales: [
      SeasonalSalesTemplate(
        category: 'Crop sales',
        description: 'Soya beans contract sale',
        evidence: [
          'Contract buyer',
          'Lot number',
          'Moisture or quality grade',
          'Weighbridge ticket',
        ],
      ),
    ],
    recordPackHints: [
      'Buyer contract file',
      'Audit input log',
      'Loan repayment projection',
    ],
  ),
  SeasonalTemplate(
    id: 'groundnut-quality',
    name: 'Groundnut quality season',
    crop: 'Groundnuts',
    season: 'Quality managed season',
    description:
        'Focuses on timing, aflatoxin risk controls, and buyer documentation.',
    activities: [
      SeasonalActivityTemplate(
        activityType: 'Ridging and planting',
        timing: 'Start of rains',
        notes: 'Capture ridge quality, seed source, and field hygiene notes.',
        inputs: ['Seed', 'Labour'],
      ),
      SeasonalActivityTemplate(
        activityType: 'Pest and disease scouting',
        timing: 'Every 2 weeks',
        notes: 'Record symptoms, affected zones, and action taken.',
        inputs: ['Scout labour', 'Treatment where needed'],
      ),
      SeasonalActivityTemplate(
        activityType: 'Drying and grading',
        timing: 'Immediately after harvest',
        notes: 'Capture drying surface, rejected quantity, and storage method.',
        inputs: ['Drying mats', 'Bags', 'Grading labour'],
      ),
    ],
    payroll: [
      SeasonalPayrollTemplate(
        role: 'Grading crew',
        payRateUnit: 'day',
        notes: 'Separate quality-control labour from harvest labour.',
      ),
      SeasonalPayrollTemplate(
        role: 'Drying attendant',
        payRateUnit: 'day',
        notes: 'Useful for insurance and buyer quality records.',
      ),
    ],
    sales: [
      SeasonalSalesTemplate(
        category: 'Crop sales',
        description: 'Groundnut sale',
        evidence: [
          'Quality grade',
          'Buyer receipt',
          'Rejected quantity',
          'Storage batch',
        ],
      ),
    ],
    recordPackHints: [
      'Buyer quality file',
      'Audit proof',
      'Insurance loss evidence',
    ],
  ),
];

class TemplatesRepository {
  Future<List<SeasonalTemplate>> getTemplates() async => _seasonalTemplates;
}
