import '../../models/crop_detail.dart';
import '../../models/crop_timeline.dart';

class CropTimelineCatalog {
  static const _generalSources = [
    'https://www.knowledgebank.irri.org/',
    'https://www.fao.org/4/y1177e/y1177e04.htm',
    'https://extension.okstate.edu/fact-sheets/soybean-production-calendar',
  ];

  static CropTimelinePlan buildPlan({
    required CropDetail crop,
    DateTime? today,
  }) {
    final now = _dateOnly(today ?? DateTime.now());
    final planted = _dateOnly(crop.plantingDate);
    final daysAfterPlanting = now.difference(planted).inDays;
    final expectedDuration =
        crop.expectedHarvestDate.difference(crop.plantingDate).inDays;
    final normalizedCrop = _normalize(crop.cropTypeName);
    final definition = _definitionFor(normalizedCrop);
    final steps = _fitHarvestWindow(
      definition.steps,
      expectedDuration > 0 ? expectedDuration : definition.defaultDurationDays,
    );

    final entries = steps.map((step) {
      final completedDate = _completedDate(
        crop.activities,
        step,
        crop.plantingDate,
      );
      final status = _statusFor(
        step: step,
        daysAfterPlanting: daysAfterPlanting,
        completedDate: completedDate,
      );
      return CropTimelineEntry(
        step: step,
        status: status,
        startDate: planted.add(Duration(days: step.startDay)),
        dueDate: planted.add(Duration(days: step.dueDay)),
        endDate: planted.add(Duration(days: step.endDay)),
        completedDate: completedDate,
      );
    }).toList();

    return CropTimelinePlan(
      cropName: definition.displayName,
      sourceLabel: definition.sourceLabel,
      sourceUrls: definition.sourceUrls,
      entries: entries,
    );
  }

  static List<String> expectedActivityTypesFor(String cropName) {
    final definition = _definitionFor(_normalize(cropName));
    final types = <String>[];
    for (final step in definition.steps) {
      if (!types.contains(step.title)) types.add(step.title);
    }
    if (!types.contains('Other')) types.add('Other');
    return types;
  }

  static List<CropTimelineStep> _fitHarvestWindow(
    List<CropTimelineStep> steps,
    int duration,
  ) {
    return steps.map((step) {
      if (step.id == 'harvest') {
        return step.copyWith(
          startDay: (duration - 14).clamp(0, duration).toInt(),
          dueDay: duration,
          endDay: duration + 14,
        );
      }
      if (step.id == 'drying_storage') {
        return step.copyWith(
          startDay: duration,
          dueDay: duration + 3,
          endDay: duration + 21,
        );
      }
      return step;
    }).toList();
  }

  static DateTime? _completedDate(
    List<CropActivity> activities,
    CropTimelineStep step,
    DateTime plantingDate,
  ) {
    final matches = activities.where((activity) {
      final haystack = _normalize(activity.activityType);
      final activityDay =
          _dateOnly(activity.date).difference(_dateOnly(plantingDate)).inDays;
      final isInWindow =
          activityDay >= step.startDay - 3 && activityDay <= step.endDay + 7;
      final aliases = [
        step.title,
        step.activityType,
        ...step.matchTerms,
      ];
      return isInWindow &&
          aliases.any((term) => haystack.contains(_normalize(term)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return matches.isEmpty ? null : _dateOnly(matches.first.date);
  }

  static CropTimelineStatus _statusFor({
    required CropTimelineStep step,
    required int daysAfterPlanting,
    DateTime? completedDate,
  }) {
    if (completedDate != null) return CropTimelineStatus.done;
    if (daysAfterPlanting > step.endDay) return CropTimelineStatus.overdue;
    if (daysAfterPlanting >= step.startDay) return CropTimelineStatus.due;
    return CropTimelineStatus.upcoming;
  }

  static _CropTimelineDefinition _definitionFor(String cropName) {
    for (final entry in _definitions.entries) {
      if (entry.value.aliases.any(cropName.contains)) return entry.value;
    }
    return _genericDefinition;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  static final _definitions = {
    'maize': _CropTimelineDefinition(
      displayName: 'Maize',
      aliases: ['maize', 'corn'],
      defaultDurationDays: 120,
      sourceLabel: 'General maize extension guidance',
      sourceUrls: [
        'https://www.bamis.gov.bd/en/croppnp/1/all/8/',
        'https://www.cimmyt.org/work/maize-research/',
      ],
      steps: [
        _landPreparation,
        _planting,
        _gapFilling,
        CropTimelineStep(
          id: 'basal_fertilizer',
          title: 'Basal fertilizer application',
          activityType: 'Fertilizing',
          startDay: 0,
          dueDay: 3,
          endDay: 10,
          recommendation:
              'Apply basal fertilizer at planting or very soon after planting according to soil and extension recommendations.',
          matchTerms: ['basal', 'fertiliz', 'fertilizer', 'manure'],
        ),
        CropTimelineStep(
          id: 'first_weeding',
          title: 'First weeding and thinning',
          activityType: 'Weeding',
          startDay: 14,
          dueDay: 21,
          endDay: 30,
          recommendation:
              'Thin weak stands and remove early weeds before they compete with the crop.',
          matchTerms: ['weeding', 'thinning'],
        ),
        CropTimelineStep(
          id: 'top_dress_1',
          title: 'First top dressing',
          activityType: 'Fertilizing',
          startDay: 25,
          dueDay: 30,
          endDay: 35,
          recommendation:
              'Apply the first nitrogen top dressing around 25-30 days after emergence where recommended.',
          matchTerms: ['fertiliz', 'top dress', 'manure'],
        ),
        CropTimelineStep(
          id: 'top_dress_2',
          title: 'Second top dressing',
          activityType: 'Fertilizing',
          startDay: 40,
          dueDay: 45,
          endDay: 55,
          recommendation:
              'Review crop vigor and apply the second split before rapid growth and tasseling.',
          matchTerms: ['fertiliz', 'top dress', 'manure'],
        ),
        _pestScouting.copyWith(startDay: 35, dueDay: 50, endDay: 90),
        _harvest,
        _dryingStorage,
      ],
    ),
    'rice': _CropTimelineDefinition(
      displayName: 'Rice',
      aliases: ['rice', 'paddy'],
      defaultDurationDays: 120,
      sourceLabel: 'IRRI Rice Knowledge Bank guidance',
      sourceUrls: [
        'https://www.knowledgebank.irri.org/step-by-step-production/pre-planting/land-preparation',
        'https://www.knowledgebank.irri.org/',
      ],
      steps: [
        _landPreparation,
        _planting,
        CropTimelineStep(
          id: 'transplant_check',
          title: 'Transplanting or stand check',
          activityType: 'Planting',
          startDay: 7,
          dueDay: 14,
          endDay: 25,
          recommendation:
              'Confirm direct-seeded emergence or transplant seedlings at the correct leaf stage.',
          matchTerms: ['transplant', 'planting', 'stand'],
        ),
        CropTimelineStep(
          id: 'weed_water',
          title: 'Weed and water management',
          activityType: 'Weeding',
          startDay: 20,
          dueDay: 25,
          endDay: 35,
          recommendation:
              'Control weeds around tillering and maintain suitable field water depth.',
          matchTerms: ['weeding', 'water', 'irrigation'],
        ),
        CropTimelineStep(
          id: 'tillering_fertilizer',
          title: 'Tillering top dressing',
          activityType: 'Fertilizing',
          startDay: 25,
          dueDay: 35,
          endDay: 45,
          recommendation:
              'Apply top dressing around active tillering if soil and variety recommendations call for it.',
          matchTerms: ['fertiliz', 'top dress', 'manure'],
        ),
        _pestScouting.copyWith(startDay: 35, dueDay: 55, endDay: 95),
        _harvest,
        _dryingStorage,
      ],
    ),
    'soybean': _CropTimelineDefinition(
      displayName: 'Soybean',
      aliases: ['soybean', 'soya', 'soy'],
      defaultDurationDays: 110,
      sourceLabel: 'Soybean production calendar guidance',
      sourceUrls: [
        'https://extension.okstate.edu/fact-sheets/soybean-production-calendar',
        'https://cals.cornell.edu/field-crops/soybeans/planting-soybeans',
      ],
      steps: [
        _landPreparation,
        CropTimelineStep(
          id: 'seed_inoculation',
          title: 'Seed inoculation and treatment',
          activityType: 'Seed treatment',
          startDay: -2,
          dueDay: 0,
          endDay: 1,
          recommendation:
              'Treat seed and inoculate with the correct rhizobium immediately before planting where recommended.',
          matchTerms: ['inoculat', 'seed treatment', 'treat seed', 'rhizobium'],
        ),
        _planting,
        _gapFilling,
        _firstWeeding,
        _pestScouting.copyWith(startDay: 35, dueDay: 55, endDay: 90),
        _harvest,
        _dryingStorage,
      ],
    ),
    'groundnut': _CropTimelineDefinition(
      displayName: 'Groundnut',
      aliases: ['groundnut', 'peanut'],
      defaultDurationDays: 126,
      sourceLabel: 'Groundnut cropping guide guidance',
      sourceUrls: [
        'https://oar.icrisat.org/10832/',
        'https://agri.bot/crop-calendar/groundnut',
      ],
      steps: [
        _landPreparation,
        _planting,
        _gapFilling,
        _firstWeeding,
        CropTimelineStep(
          id: 'pegging_nutrition',
          title: 'Pegging nutrition and earthing',
          activityType: 'Fertilizing',
          startDay: 35,
          dueDay: 45,
          endDay: 55,
          recommendation:
              'Review pegging stage nutrition and earth up where recommended for the field.',
          matchTerms: ['fertiliz', 'gypsum', 'earthing', 'ridging'],
        ),
        _pestScouting.copyWith(startDay: 45, dueDay: 65, endDay: 95),
        _harvest,
        _dryingStorage,
      ],
    ),
    'tobacco': _CropTimelineDefinition(
      displayName: 'Tobacco',
      aliases: ['tobacco'],
      defaultDurationDays: 140,
      sourceLabel: 'General tobacco production guidance',
      sourceUrls: _generalSources,
      steps: [
        CropTimelineStep(
          id: 'nursery',
          title: 'Nursery management',
          activityType: 'Nursery',
          startDay: -60,
          dueDay: -45,
          endDay: -7,
          recommendation:
              'Prepare and manage a clean nursery so strong seedlings are ready for transplanting.',
          matchTerms: ['nursery', 'seedbed', 'seed bed'],
        ),
        CropTimelineStep(
          id: 'ridging',
          title: 'Land preparation and ridging',
          activityType: 'Land preparation',
          startDay: -21,
          dueDay: -14,
          endDay: -1,
          recommendation:
              'Prepare ridges and drainage before transplanting seedlings.',
          matchTerms: ['land preparation', 'ridge', 'ridging', 'plough'],
        ),
        CropTimelineStep(
          id: 'transplanting',
          title: 'Transplanting',
          activityType: 'Planting',
          startDay: 0,
          dueDay: 0,
          endDay: 7,
          recommendation:
              'Transplant healthy seedlings into moist ridges and water if needed.',
          matchTerms: ['transplant', 'planting'],
        ),
        _gapFilling.copyWith(startDay: 7, dueDay: 10, endDay: 18),
        CropTimelineStep(
          id: 'weeding_banking',
          title: 'Weeding and banking',
          activityType: 'Weeding',
          startDay: 21,
          dueDay: 30,
          endDay: 45,
          recommendation:
              'Weed and bank soil around plants before strong competition sets in.',
          matchTerms: ['weeding', 'banking', 'earthing'],
        ),
        CropTimelineStep(
          id: 'topping_suckering',
          title: 'Topping and suckering',
          activityType: 'Crop management',
          startDay: 60,
          dueDay: 75,
          endDay: 95,
          recommendation:
              'Top plants and control suckers at the correct stage for leaf quality.',
          matchTerms: ['topping', 'suckering', 'sucker'],
        ),
        CropTimelineStep(
          id: 'curing',
          title: 'Harvesting and curing',
          activityType: 'Harvesting',
          startDay: 90,
          dueDay: 115,
          endDay: 150,
          recommendation:
              'Harvest mature leaves in order and cure carefully to protect grade and value.',
          matchTerms: ['harvest', 'curing', 'cure'],
        ),
        CropTimelineStep(
          id: 'grading_storage',
          title: 'Grading and storage',
          activityType: 'Storage',
          startDay: 120,
          dueDay: 140,
          endDay: 170,
          recommendation:
              'Grade, bale, and store tobacco in dry conditions with supporting evidence.',
          matchTerms: ['grading', 'storage', 'bale'],
        ),
      ],
    ),
    'sorghum': _CropTimelineDefinition(
      displayName: 'Sorghum',
      aliases: ['sorghum'],
      defaultDurationDays: 120,
      sourceLabel: 'General cereal production guidance',
      sourceUrls: _generalSources,
      steps: _cerealSteps,
    ),
    'millet': _CropTimelineDefinition(
      displayName: 'Millet',
      aliases: ['millet'],
      defaultDurationDays: 100,
      sourceLabel: 'General cereal production guidance',
      sourceUrls: _generalSources,
      steps: _cerealSteps,
    ),
    'sunflower': _CropTimelineDefinition(
      displayName: 'Sunflower',
      aliases: ['sunflower'],
      defaultDurationDays: 110,
      sourceLabel: 'General oilseed production guidance',
      sourceUrls: _generalSources,
      steps: [
        _landPreparation,
        _planting,
        _gapFilling,
        _firstWeeding,
        _pestScouting.copyWith(startDay: 28, dueDay: 45, endDay: 85),
        _harvest,
        _dryingStorage,
      ],
    ),
    'cassava': _CropTimelineDefinition(
      displayName: 'Cassava',
      aliases: ['cassava', 'manioc'],
      defaultDurationDays: 330,
      sourceLabel: 'FAO/IITA cassava agronomy guidance',
      sourceUrls: [
        'https://www.fao.org/4/y1177e/y1177e04.htm',
        'https://agris.fao.org/search/en/providers/123818/records/67236f43b605bda15e0b0e4b',
      ],
      steps: [
        _landPreparation,
        CropTimelineStep(
          id: 'stake_preparation',
          title: 'Prepare healthy stakes',
          activityType: 'Planting',
          startDay: -7,
          dueDay: -3,
          endDay: 0,
          recommendation:
              'Use healthy mature cassava stems and avoid dried or diseased planting material.',
          matchTerms: ['stake', 'cutting', 'planting'],
        ),
        _planting,
        _gapFilling.copyWith(startDay: 14, dueDay: 21, endDay: 30),
        _firstWeeding.copyWith(startDay: 30, dueDay: 45, endDay: 60),
        CropTimelineStep(
          id: 'second_weeding',
          title: 'Second weeding',
          activityType: 'Weeding',
          startDay: 60,
          dueDay: 75,
          endDay: 90,
          recommendation:
              'Keep cassava clean during the first 3-4 months while canopy cover is still developing.',
          matchTerms: ['weeding'],
        ),
        CropTimelineStep(
          id: 'third_weeding',
          title: 'Third weeding if needed',
          activityType: 'Weeding',
          startDay: 90,
          dueDay: 105,
          endDay: 120,
          recommendation:
              'Scout for late weed pressure and weed again if the canopy has not closed.',
          matchTerms: ['weeding'],
        ),
        _harvest,
        _dryingStorage,
      ],
    ),
    'sweet_potato': _CropTimelineDefinition(
      displayName: 'Sweet Potato',
      aliases: ['sweet potato', 'sweetpotato'],
      defaultDurationDays: 120,
      sourceLabel: 'Root and tuber crop guidance',
      sourceUrls: _generalSources,
      steps: [
        _landPreparation,
        CropTimelineStep(
          id: 'vine_selection',
          title: 'Vine selection and planting',
          activityType: 'Planting',
          startDay: 0,
          dueDay: 0,
          endDay: 7,
          recommendation:
              'Use healthy vines or slips and plant into moist ridges or mounds.',
          matchTerms: ['vine', 'slip', 'planting'],
        ),
        _gapFilling.copyWith(startDay: 7, dueDay: 14, endDay: 21),
        _firstWeeding.copyWith(startDay: 21, dueDay: 30, endDay: 45),
        _pestScouting.copyWith(startDay: 35, dueDay: 55, endDay: 90),
        _harvest,
        _dryingStorage,
      ],
    ),
    'bean': _CropTimelineDefinition(
      displayName: 'Beans',
      aliases: ['bean', 'beans', 'common bean'],
      defaultDurationDays: 90,
      sourceLabel: 'General legume extension guidance',
      sourceUrls: _generalSources,
      steps: [
        _landPreparation,
        _planting,
        _gapFilling,
        _firstWeeding,
        _pestScouting.copyWith(startDay: 28, dueDay: 40, endDay: 70),
        _harvest,
        _dryingStorage,
      ],
    ),
    'cowpea': _CropTimelineDefinition(
      displayName: 'Cowpea',
      aliases: ['cowpea', 'cow pea'],
      defaultDurationDays: 85,
      sourceLabel: 'General legume extension guidance',
      sourceUrls: _generalSources,
      steps: _legumeSteps,
    ),
    'pigeon_pea': _CropTimelineDefinition(
      displayName: 'Pigeon Pea',
      aliases: ['pigeon pea', 'pigeonpea'],
      defaultDurationDays: 180,
      sourceLabel: 'General legume extension guidance',
      sourceUrls: _generalSources,
      steps: _legumeSteps,
    ),
    'cotton': _CropTimelineDefinition(
      displayName: 'Cotton',
      aliases: ['cotton'],
      defaultDurationDays: 160,
      sourceLabel: 'General cotton production guidance',
      sourceUrls: _generalSources,
      steps: [
        _landPreparation,
        _planting,
        CropTimelineStep(
          id: 'thinning_gap_fill',
          title: 'Thinning and gap filling',
          activityType: 'Field inspection',
          startDay: 10,
          dueDay: 14,
          endDay: 24,
          recommendation:
              'Thin to the desired stand and fill gaps while seedlings are still young.',
          matchTerms: ['thinning', 'gap', 'replant'],
        ),
        _firstWeeding.copyWith(startDay: 21, dueDay: 30, endDay: 45),
        CropTimelineStep(
          id: 'pest_scout_spray',
          title: 'Pest scouting and spraying',
          activityType: 'Spraying',
          startDay: 35,
          dueDay: 55,
          endDay: 130,
          recommendation:
              'Scout for bollworms and sucking pests; spray only when thresholds and label guidance support it.',
          matchTerms: ['pest', 'scout', 'spray', 'bollworm'],
        ),
        CropTimelineStep(
          id: 'picking',
          title: 'Picking',
          activityType: 'Harvesting',
          startDay: 120,
          dueDay: 145,
          endDay: 180,
          recommendation:
              'Pick open bolls in rounds and keep cotton clean and dry.',
          matchTerms: ['picking', 'harvest'],
        ),
        _dryingStorage,
      ],
    ),
    'sugarcane': _CropTimelineDefinition(
      displayName: 'Sugarcane',
      aliases: ['sugarcane', 'sugar cane'],
      defaultDurationDays: 365,
      sourceLabel: 'General sugarcane production guidance',
      sourceUrls: _generalSources,
      steps: [
        CropTimelineStep(
          id: 'furrowing',
          title: 'Land preparation and furrowing',
          activityType: 'Land preparation',
          startDay: -30,
          dueDay: -14,
          endDay: -1,
          recommendation:
              'Prepare land and furrows with drainage and irrigation access in mind.',
          matchTerms: ['land preparation', 'furrow', 'furrowing', 'ridge'],
        ),
        CropTimelineStep(
          id: 'plant_setts',
          title: 'Planting setts',
          activityType: 'Planting',
          startDay: 0,
          dueDay: 0,
          endDay: 10,
          recommendation:
              'Plant healthy cane setts at recommended spacing and cover properly.',
          matchTerms: ['sett', 'setts', 'planting'],
        ),
        _gapFilling.copyWith(startDay: 21, dueDay: 30, endDay: 45),
        _firstWeeding.copyWith(startDay: 30, dueDay: 45, endDay: 75),
        CropTimelineStep(
          id: 'fertilizer_irrigation',
          title: 'Fertilizer and irrigation management',
          activityType: 'Fertilizing',
          startDay: 45,
          dueDay: 75,
          endDay: 180,
          recommendation:
              'Manage fertilizer, moisture, and weeds through the main vegetative growth period.',
          matchTerms: ['fertiliz', 'irrigation', 'watering'],
        ),
        CropTimelineStep(
          id: 'cutting_loading',
          title: 'Cutting and loading',
          activityType: 'Harvesting',
          startDay: 330,
          dueDay: 365,
          endDay: 420,
          recommendation:
              'Cut mature cane and load promptly to protect sucrose recovery.',
          matchTerms: ['cutting', 'loading', 'harvest'],
        ),
        CropTimelineStep(
          id: 'ratoon_residue',
          title: 'Ratoon and residue management',
          activityType: 'Crop management',
          startDay: 365,
          dueDay: 380,
          endDay: 430,
          recommendation:
              'Manage trash, stool health, and ratoon regrowth after cutting.',
          matchTerms: ['ratoon', 'residue', 'trash'],
        ),
      ],
    ),
    'banana': _CropTimelineDefinition(
      displayName: 'Banana',
      aliases: ['banana'],
      defaultDurationDays: 365,
      sourceLabel: 'General banana production guidance',
      sourceUrls: _generalSources,
      steps: [
        CropTimelineStep(
          id: 'pits',
          title: 'Land preparation and pits',
          activityType: 'Land preparation',
          startDay: -21,
          dueDay: -14,
          endDay: -1,
          recommendation:
              'Prepare pits with organic matter and drainage before planting.',
          matchTerms: ['pit', 'land preparation', 'manure'],
        ),
        _planting,
        CropTimelineStep(
          id: 'mulching_irrigation',
          title: 'Mulching and irrigation',
          activityType: 'Irrigation',
          startDay: 14,
          dueDay: 30,
          endDay: 120,
          recommendation:
              'Maintain mulch and soil moisture during establishment.',
          matchTerms: ['mulch', 'irrigation', 'watering'],
        ),
        CropTimelineStep(
          id: 'desuckering_sanitation',
          title: 'Desuckering and sanitation',
          activityType: 'Crop management',
          startDay: 60,
          dueDay: 90,
          endDay: 240,
          recommendation:
              'Remove excess suckers and keep the mat clean to reduce disease pressure.',
          matchTerms: ['desucker', 'sucker', 'sanitation', 'pruning'],
        ),
        CropTimelineStep(
          id: 'feeding',
          title: 'Feeding and nutrition',
          activityType: 'Fertilizing',
          startDay: 90,
          dueDay: 120,
          endDay: 270,
          recommendation:
              'Feed plants according to field recommendations and crop vigor.',
          matchTerms: ['feeding', 'fertiliz', 'manure'],
        ),
        CropTimelineStep(
          id: 'bunch_care',
          title: 'Propping and bunch care',
          activityType: 'Crop management',
          startDay: 210,
          dueDay: 260,
          endDay: 330,
          recommendation:
              'Prop heavy plants and protect bunches where needed.',
          matchTerms: ['propping', 'bunch', 'bagging'],
        ),
        _harvest,
        _dryingStorage,
      ],
    ),
    'tomato': _CropTimelineDefinition(
      displayName: 'Tomato',
      aliases: ['tomato'],
      defaultDurationDays: 90,
      sourceLabel: 'Vegetable crop calendar guidance',
      sourceUrls: ['https://agri.bot/crop-calendar/tomato'],
      steps: [
        _landPreparation,
        CropTimelineStep(
          id: 'transplant',
          title: 'Transplant seedlings',
          activityType: 'Planting',
          startDay: 0,
          dueDay: 0,
          endDay: 7,
          recommendation:
              'Transplant healthy seedlings and water immediately after establishment.',
          matchTerms: ['planting', 'transplant'],
        ),
        _firstWeeding.copyWith(startDay: 14, dueDay: 21, endDay: 30),
        CropTimelineStep(
          id: 'flowering_feed',
          title: 'Flowering nutrition check',
          activityType: 'Fertilizing',
          startDay: 28,
          dueDay: 35,
          endDay: 45,
          recommendation:
              'Review crop nutrition at flowering and fruit set; split fertilizer where recommended.',
          matchTerms: ['fertiliz', 'top dress', 'manure'],
        ),
        _pestScouting.copyWith(startDay: 28, dueDay: 45, endDay: 80),
        _harvest,
        _dryingStorage,
      ],
    ),
    'potato': _CropTimelineDefinition(
      displayName: 'Potato',
      aliases: ['potato', 'irish potato'],
      defaultDurationDays: 110,
      sourceLabel: 'Potato extension guidance',
      sourceUrls: ['https://www.uidaho.edu/extension/publications/bul-1114'],
      steps: [
        _landPreparation,
        _planting,
        _gapFilling,
        CropTimelineStep(
          id: 'hilling',
          title: 'Hilling and weed control',
          activityType: 'Weeding',
          startDay: 21,
          dueDay: 30,
          endDay: 45,
          recommendation:
              'Hill soil around plants and control weeds before tuber bulking.',
          matchTerms: ['hilling', 'earthing', 'weeding', 'ridging'],
        ),
        _pestScouting.copyWith(startDay: 35, dueDay: 50, endDay: 90),
        _harvest,
        _dryingStorage,
      ],
    ),
    'onion': _CropTimelineDefinition(
      displayName: 'Onion',
      aliases: ['onion'],
      defaultDurationDays: 120,
      sourceLabel: 'Onion extension guidance',
      sourceUrls: [
        'https://extension.psu.edu/onion-production',
        'https://ask.ifas.ufl.edu/publication/CV299',
      ],
      steps: [
        _landPreparation,
        _planting,
        _firstWeeding.copyWith(startDay: 14, dueDay: 21, endDay: 35),
        _pestScouting.copyWith(startDay: 35, dueDay: 55, endDay: 95),
        _harvest,
        CropTimelineStep(
          id: 'curing_storage',
          title: 'Curing and storage',
          activityType: 'Storage',
          startDay: 120,
          dueDay: 127,
          endDay: 148,
          recommendation:
              'Cure bulbs properly before storage and keep storage cool and dry.',
          matchTerms: ['storage', 'curing', 'drying'],
        ),
      ],
    ),
    'cabbage': _CropTimelineDefinition(
      displayName: 'Cabbage',
      aliases: ['cabbage'],
      defaultDurationDays: 90,
      sourceLabel: 'Cabbage extension guidance',
      sourceUrls: [
        'https://stem.plantsforhumanhealth.ncsu.edu/school-gardens/crop-guides/crop-guide-cabbage/',
        'https://extension.umd.edu/resource/growing-cabbage-home-garden',
      ],
      steps: [
        _landPreparation,
        CropTimelineStep(
          id: 'transplant',
          title: 'Transplant seedlings',
          activityType: 'Planting',
          startDay: 0,
          dueDay: 0,
          endDay: 7,
          recommendation:
              'Transplant healthy seedlings and irrigate to reduce transplant stress.',
          matchTerms: ['planting', 'transplant'],
        ),
        _firstWeeding.copyWith(startDay: 14, dueDay: 21, endDay: 30),
        CropTimelineStep(
          id: 'side_dress',
          title: 'Side dressing',
          activityType: 'Fertilizing',
          startDay: 21,
          dueDay: 28,
          endDay: 40,
          recommendation:
              'Side-dress around three weeks after transplanting if the crop needs nitrogen.',
          matchTerms: ['fertiliz', 'side dress', 'top dress', 'manure'],
        ),
        _pestScouting.copyWith(startDay: 21, dueDay: 35, endDay: 75),
        _harvest,
        _dryingStorage,
      ],
    ),
  };

  static final _genericDefinition = _CropTimelineDefinition(
    displayName: 'Crop',
    aliases: [],
    defaultDurationDays: 120,
    sourceLabel: 'General crop production guidance',
    sourceUrls: _generalSources,
    steps: [
      _landPreparation,
      _planting,
      _gapFilling,
      _firstWeeding,
      _pestScouting,
      _harvest,
      _dryingStorage,
    ],
  );

  static const _cerealSteps = [
    _landPreparation,
    _planting,
    _gapFilling,
    CropTimelineStep(
      id: 'first_weeding_thinning',
      title: 'First weeding and thinning',
      activityType: 'Weeding',
      startDay: 14,
      dueDay: 21,
      endDay: 32,
      recommendation:
          'Thin weak stands and remove early weed competition while the crop is establishing.',
      matchTerms: ['weeding', 'thinning', 'weed'],
    ),
    _pestScouting,
    CropTimelineStep(
      id: 'top_dressing',
      title: 'Top dressing',
      activityType: 'Fertilizing',
      startDay: 28,
      dueDay: 40,
      endDay: 55,
      recommendation:
          'Apply top dressing during rapid vegetative growth if recommended for the field.',
      matchTerms: ['fertiliz', 'top dress', 'manure'],
    ),
    _harvest,
    _dryingStorage,
  ];

  static const _legumeSteps = [
    _landPreparation,
    CropTimelineStep(
      id: 'seed_treatment',
      title: 'Seed treatment or inoculation',
      activityType: 'Seed treatment',
      startDay: -2,
      dueDay: 0,
      endDay: 1,
      recommendation:
          'Treat seed and inoculate where recommended before planting into moist soil.',
      matchTerms: ['seed treatment', 'inoculat', 'rhizobium', 'treat seed'],
    ),
    _planting,
    _gapFilling,
    _firstWeeding,
    _pestScouting,
    _harvest,
    _dryingStorage,
  ];

  static const _landPreparation = CropTimelineStep(
    id: 'land_preparation',
    title: 'Land preparation',
    activityType: 'Land preparation',
    startDay: -21,
    dueDay: -14,
    endDay: -1,
    recommendation:
        'Prepare the field, remove weeds, and confirm drainage before planting.',
    matchTerms: ['land preparation', 'plough', 'plow', 'till', 'ridge'],
  );

  static const _planting = CropTimelineStep(
    id: 'planting',
    title: 'Planting',
    activityType: 'Planting',
    startDay: 0,
    dueDay: 0,
    endDay: 7,
    recommendation:
        'Plant using the recommended spacing, seed rate, and moisture conditions.',
    matchTerms: ['planting', 'sowing', 'seed', 'transplant'],
  );

  static const _gapFilling = CropTimelineStep(
    id: 'gap_filling',
    title: 'Emergence and gap filling',
    activityType: 'Field inspection',
    startDay: 7,
    dueDay: 10,
    endDay: 14,
    recommendation:
        'Check emergence and replant gaps early while the crop can still catch up.',
    matchTerms: ['gap', 'inspection', 'replant', 'emergence'],
  );

  static const _firstWeeding = CropTimelineStep(
    id: 'first_weeding',
    title: 'First weeding',
    activityType: 'Weeding',
    startDay: 14,
    dueDay: 21,
    endDay: 30,
    recommendation:
        'Remove weeds early to reduce competition for nutrients, water, and light.',
    matchTerms: ['weeding', 'weed'],
  );

  static const _pestScouting = CropTimelineStep(
    id: 'pest_scouting',
    title: 'Pest and disease scouting',
    activityType: 'Spraying',
    startDay: 30,
    dueDay: 45,
    endDay: 80,
    recommendation:
        'Scout regularly and only spray when field observations or thresholds justify it.',
    matchTerms: ['spray', 'scout', 'pest', 'disease', 'ipm'],
  );

  static const _harvest = CropTimelineStep(
    id: 'harvest',
    title: 'Harvest',
    activityType: 'Harvesting',
    startDay: 100,
    dueDay: 120,
    endDay: 134,
    recommendation:
        'Harvest at maturity and record yield evidence as soon as possible.',
    matchTerms: ['harvest', 'yield'],
  );

  static const _dryingStorage = CropTimelineStep(
    id: 'drying_storage',
    title: 'Drying and storage',
    activityType: 'Storage',
    startDay: 120,
    dueDay: 123,
    endDay: 141,
    recommendation:
        'Dry, grade, and store produce safely; attach photos or warehouse evidence.',
    matchTerms: ['storage', 'store', 'drying', 'dry', 'grading'],
  );
}

class _CropTimelineDefinition {
  final String displayName;
  final List<String> aliases;
  final int defaultDurationDays;
  final String sourceLabel;
  final List<String> sourceUrls;
  final List<CropTimelineStep> steps;

  const _CropTimelineDefinition({
    required this.displayName,
    required this.aliases,
    required this.defaultDurationDays,
    required this.sourceLabel,
    required this.sourceUrls,
    required this.steps,
  });
}
