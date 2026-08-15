import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/farmio_card.dart';
import '../../shared/widgets/glass_panel.dart';
import 'mobile_operations_repository.dart';

enum MobileFunctionKind {
  inventory,
  livestock,
  equipment,
  notifications,
  traceability,
  funders,
  creditScore,
  weather,
  aiInsights,
  documents,
  compliance,
  team,
  seasons,
  fieldMap,
  reportBuilder,
  graphCatalog,
  mobileApi,
  settings,
}

class MobileFunctionDetailScreen extends StatefulWidget {
  final MobileFunctionKind kind;

  const MobileFunctionDetailScreen({super.key, required this.kind});

  @override
  State<MobileFunctionDetailScreen> createState() =>
      _MobileFunctionDetailScreenState();
}

class _MobileFunctionDetailScreenState
    extends State<MobileFunctionDetailScreen> {
  late Future<_FunctionPayload> _future;
  final _operations = MobileOperationsRepository();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(widget.kind);
    return Scaffold(
      backgroundColor: FarmioColors.background,
      appBar: AppBar(
        title: Text(spec.title,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          if (widget.kind == MobileFunctionKind.notifications)
            IconButton(
              tooltip: 'Mark all read',
              icon: const Icon(Icons.done_all_rounded),
              onPressed: _markNotificationsRead,
            ),
        ],
      ),
      body: FrostedScaffoldBackground(
        child: FutureBuilder<_FunctionPayload>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: _messageFor(snapshot.error),
              onRetry: () => setState(() => _future = _load()),
            );
          }

          final payload = snapshot.data ?? _FunctionPayload.empty();
          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _load()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              children: [
                _HeaderCard(spec: spec),
                const SizedBox(height: 14),
                if (payload.metrics.isNotEmpty)
                  _MetricGrid(metrics: payload.metrics),
                if (payload.metrics.isNotEmpty) const SizedBox(height: 14),
                if (_actionsFor(widget.kind).isNotEmpty)
                  _ActionGrid(actions: _actionsFor(widget.kind)),
                if (_actionsFor(widget.kind).isNotEmpty)
                  const SizedBox(height: 14),
                ...payload.sections.map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _DataSection(section: section),
                    )),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  Future<void> _markNotificationsRead() async {
    await ApiClient.post('/mobile/notifications', {'markAllRead': true});
    if (!mounted) return;
    setState(() => _future = _load());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications marked as read.')),
    );
  }

  Future<_FunctionPayload> _load() async {
    switch (widget.kind) {
      case MobileFunctionKind.inventory:
        final inventory = await ApiClient.get('/mobile/inventory');
        final sales = await ApiClient.get('/mobile/inventory/sales');
        return _inventoryPayload(
          inventory.data,
          sales.data,
        );
      case MobileFunctionKind.livestock:
        final response = await ApiClient.get('/mobile/livestock');
        return _livestockPayload(response.data);
      case MobileFunctionKind.equipment:
        final response = await ApiClient.get('/mobile/equipment');
        return _equipmentPayload(response.data);
      case MobileFunctionKind.notifications:
        final response = await ApiClient.get('/mobile/notifications');
        return _notificationsPayload(response.data);
      case MobileFunctionKind.traceability:
        final response = await ApiClient.get('/mobile/traceability');
        return _traceabilityPayload(response.data);
      case MobileFunctionKind.funders:
        final response = await ApiClient.get('/mobile/funder-dashboard');
        return _funderPayload(
          response.data,
          creditMode: false,
        );
      case MobileFunctionKind.creditScore:
        return _optional(
          () async {
            final response = await _operations.getCreditReadiness();
            return _creditReadinessPayload(response);
          },
          _creditReadinessPayload(const {}),
        );
      case MobileFunctionKind.weather:
        return _optional(
          () async {
            final response = await _operations.getWeather();
            return _weatherPayload(response);
          },
          _weatherPayload(),
        );
      case MobileFunctionKind.aiInsights:
        final dashboard = await ApiClient.get('/mobile/dashboard');
        final reports = await ApiClient.get('/mobile/reports');
        return _aiPayload(
          _map(dashboard.data),
          _map(reports.data),
        );
      case MobileFunctionKind.documents:
        return _optional(
          () async {
            final response = await ApiClient.get('/mobile/documents');
            return _documentsPayload(response.data);
          },
          _documentsPayload(const []),
        );
      case MobileFunctionKind.compliance:
        return _optional(
          () async {
            final response = await _operations.getCompliance();
            return _compliancePayload(response);
          },
          _compliancePayload(const {}),
        );
      case MobileFunctionKind.team:
        return _optional(
          () async {
            final response = await _operations.getTeam();
            return _teamPayload(response);
          },
          _teamPayload(const []),
        );
      case MobileFunctionKind.seasons:
        return _optional(
          () async {
            final seasons = await _operations.getSeasons();
            Object? compare;
            try {
              compare = await _operations.compareSeasons();
            } catch (_) {
              compare = null;
            }
            return _seasonsPayload(seasons, compare);
          },
          _seasonsPayload(const {}),
        );
      case MobileFunctionKind.fieldMap:
        return _optional(
          () async {
            final response = await _operations.getFieldMap();
            return _fieldMapPayload(response);
          },
          _fieldMapPayload(const []),
        );
      case MobileFunctionKind.reportBuilder:
        return _optional(
          () async {
            final response = await ApiClient.get('/mobile/report-builder');
            return _reportBuilderPayload(response.data);
          },
          _reportBuilderPayload(const {}),
        );
      case MobileFunctionKind.graphCatalog:
        return _optional(
          () async {
            final response = await _operations.getGraphCatalog();
            return _graphCatalogPayload(response);
          },
          _graphCatalogPayload(const {}),
        );
      case MobileFunctionKind.mobileApi:
        return _mobileApiPayload();
      case MobileFunctionKind.settings:
        return _optional(
          () async {
            final profile = await ApiClient.get('/mobile/profile');
            Object? farmContext;
            try {
              farmContext = (await ApiClient.get('/mobile/farm-context')).data;
            } catch (_) {
              farmContext = null;
            }
            return _settingsPayload(profile.data, farmContext);
          },
          _settingsPayload(const {}),
        );
    }
  }

  Future<_FunctionPayload> _optional(
    Future<_FunctionPayload> Function() load,
    _FunctionPayload fallback,
  ) async {
    try {
      return await load();
    } on DioException catch (error) {
      final apiError = error.error;
      if (apiError is ApiError &&
          (apiError.statusCode == 404 || apiError.type == ApiErrorType.network)) {
        return fallback;
      }
      rethrow;
    }
  }
}

class _FunctionSpec {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _FunctionSpec({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

_FunctionSpec _specFor(MobileFunctionKind kind) {
  switch (kind) {
    case MobileFunctionKind.inventory:
      return const _FunctionSpec(
        title: 'Inventory',
        description: 'Stock, low-stock alerts, inventory value and sales.',
        icon: Icons.inventory_2_outlined,
        color: FarmioColors.info,
      );
    case MobileFunctionKind.livestock:
      return const _FunctionSpec(
        title: 'Livestock',
        description: 'Animal register, recent health, production and costs.',
        icon: Icons.pets_outlined,
        color: FarmioColors.success,
      );
    case MobileFunctionKind.equipment:
      return const _FunctionSpec(
        title: 'Equipment',
        description: 'Machinery register, fuel and service cost records.',
        icon: Icons.precision_manufacturing_outlined,
        color: FarmioColors.warning,
      );
    case MobileFunctionKind.notifications:
      return const _FunctionSpec(
        title: 'Notifications',
        description: 'Alerts from farm records, tasks and readiness checks.',
        icon: Icons.notifications_outlined,
        color: FarmioColors.purple,
      );
    case MobileFunctionKind.traceability:
      return const _FunctionSpec(
        title: 'Traceability',
        description: 'Buyer-ready crop lots and missing evidence checks.',
        icon: Icons.qr_code_2_outlined,
        color: FarmioColors.primary,
      );
    case MobileFunctionKind.funders:
      return const _FunctionSpec(
        title: 'Funder Dashboard',
        description: 'Portfolio readiness, completeness and risk overview.',
        icon: Icons.account_balance_outlined,
        color: FarmioColors.info,
      );
    case MobileFunctionKind.creditScore:
      return const _FunctionSpec(
        title: 'Credit Score',
        description: 'Farm record readiness for lender review.',
        icon: Icons.credit_score_outlined,
        color: FarmioColors.primary,
      );
    case MobileFunctionKind.weather:
      return const _FunctionSpec(
        title: 'Weather',
        description: 'Field planning advisory. Forecast API can be connected later.',
        icon: Icons.wb_cloudy_outlined,
        color: FarmioColors.info,
      );
    case MobileFunctionKind.aiInsights:
      return const _FunctionSpec(
        title: 'AI Insights',
        description: 'Rule-based operating insights from dashboard and reports.',
        icon: Icons.auto_awesome_outlined,
        color: FarmioColors.purple,
      );
    case MobileFunctionKind.documents:
      return const _FunctionSpec(
        title: 'Documents',
        description: 'Receipts, photos, certificates, contracts and evidence files.',
        icon: Icons.folder_copy_outlined,
        color: FarmioColors.primary,
      );
    case MobileFunctionKind.compliance:
      return const _FunctionSpec(
        title: 'Compliance',
        description: 'Audit, buyer, insurance and evidence readiness checks.',
        icon: Icons.verified_user_outlined,
        color: FarmioColors.success,
      );
    case MobileFunctionKind.team:
      return const _FunctionSpec(
        title: 'Team and Permissions',
        description: 'Team members, payroll roles and permission readiness.',
        icon: Icons.groups_outlined,
        color: FarmioColors.info,
      );
    case MobileFunctionKind.seasons:
      return const _FunctionSpec(
        title: 'Seasons',
        description: 'Season comparison, archived seasons and performance trends.',
        icon: Icons.timeline_outlined,
        color: FarmioColors.primary,
      );
    case MobileFunctionKind.fieldMap:
      return const _FunctionSpec(
        title: 'Field GPS and Map',
        description: 'Boundaries, zones, markers and field location coverage.',
        icon: Icons.map_outlined,
        color: FarmioColors.info,
      );
    case MobileFunctionKind.reportBuilder:
      return const _FunctionSpec(
        title: 'Report Builder',
        description: 'Select report sections, filters and export-ready outputs.',
        icon: Icons.post_add_outlined,
        color: FarmioColors.purple,
      );
    case MobileFunctionKind.graphCatalog:
      return const _FunctionSpec(
        title: 'Graph Catalog',
        description: 'Available dashboard, report, export and map visualizations.',
        icon: Icons.analytics_outlined,
        color: FarmioColors.info,
      );
    case MobileFunctionKind.mobileApi:
      return const _FunctionSpec(
        title: 'Mobile API Coverage',
        description: 'Dashboard, farm, finance, reports, documents and sync endpoint map.',
        icon: Icons.api_outlined,
        color: FarmioColors.primary,
      );
    case MobileFunctionKind.settings:
      return const _FunctionSpec(
        title: 'Settings',
        description: 'Farm switching, profile, password and subscription settings.',
        icon: Icons.settings_outlined,
        color: FarmioColors.slate500,
      );
  }
}

class _FunctionPayload {
  final List<_Metric> metrics;
  final List<_SectionData> sections;

  const _FunctionPayload({required this.metrics, required this.sections});

  factory _FunctionPayload.empty() =>
      const _FunctionPayload(metrics: [], sections: []);
}

class _Metric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Metric(this.label, this.value, this.icon, this.color);
}

class _SectionData {
  final String title;
  final List<Map<String, String>> rows;
  final String emptyText;

  const _SectionData({
    required this.title,
    required this.rows,
    this.emptyText = 'No records found.',
  });
}

class _FunctionAction {
  final String label;
  final IconData icon;
  final String route;

  const _FunctionAction(this.label, this.icon, this.route);
}

List<_FunctionAction> _actionsFor(MobileFunctionKind kind) {
  switch (kind) {
    case MobileFunctionKind.inventory:
      return const [
        _FunctionAction('Open finance', Icons.account_balance_wallet_outlined, '/finance'),
        _FunctionAction('View reports', Icons.bar_chart_outlined, '/reports'),
      ];
    case MobileFunctionKind.livestock:
      return const [
        _FunctionAction('Log activity', Icons.assignment_outlined, '/activities'),
        _FunctionAction('View reports', Icons.bar_chart_outlined, '/reports'),
      ];
    case MobileFunctionKind.equipment:
      return const [
        _FunctionAction('Add overhead', Icons.receipt_long_outlined, '/finance'),
        _FunctionAction('Cost reports', Icons.query_stats_outlined, '/reports'),
      ];
    case MobileFunctionKind.notifications:
      return const [
        _FunctionAction('Activities', Icons.assignment_outlined, '/activities'),
        _FunctionAction('Crop timelines', Icons.timeline_outlined, '/crops'),
      ];
    case MobileFunctionKind.traceability:
    case MobileFunctionKind.compliance:
      return const [
        _FunctionAction('Record packs', Icons.file_present_outlined, '/records'),
        _FunctionAction('Documents', Icons.folder_copy_outlined, '/documents'),
      ];
    case MobileFunctionKind.funders:
    case MobileFunctionKind.creditScore:
      return const [
        _FunctionAction('Record packs', Icons.file_present_outlined, '/records'),
        _FunctionAction('Reports', Icons.bar_chart_outlined, '/reports'),
      ];
    case MobileFunctionKind.weather:
      return const [
        _FunctionAction('Calendar', Icons.calendar_month_outlined, '/crops'),
        _FunctionAction('Log activity', Icons.add_task_outlined, '/activities'),
      ];
    case MobileFunctionKind.aiInsights:
      return const [
        _FunctionAction('Dashboard', Icons.dashboard_outlined, '/dashboard'),
        _FunctionAction('Reports', Icons.bar_chart_outlined, '/reports'),
      ];
    case MobileFunctionKind.documents:
      return const [
        _FunctionAction('Record packs', Icons.file_present_outlined, '/records'),
        _FunctionAction('Traceability', Icons.qr_code_2_outlined, '/traceability'),
      ];
    case MobileFunctionKind.team:
      return const [
        _FunctionAction('Employees', Icons.people_alt_outlined, '/employees'),
        _FunctionAction('Settings', Icons.settings_outlined, '/settings'),
      ];
    case MobileFunctionKind.seasons:
      return const [
        _FunctionAction('Crops', Icons.grass_outlined, '/crops'),
        _FunctionAction('Reports', Icons.bar_chart_outlined, '/reports'),
      ];
    case MobileFunctionKind.fieldMap:
      return const [
        _FunctionAction('Fields', Icons.map_outlined, '/fields'),
        _FunctionAction('Crops', Icons.grass_outlined, '/crops'),
      ];
    case MobileFunctionKind.reportBuilder:
      return const [
        _FunctionAction('Reports', Icons.bar_chart_outlined, '/reports'),
        _FunctionAction('Record packs', Icons.file_present_outlined, '/records'),
      ];
    case MobileFunctionKind.graphCatalog:
      return const [
        _FunctionAction('Reports', Icons.bar_chart_outlined, '/reports'),
        _FunctionAction('Field map', Icons.map_outlined, '/field-map'),
      ];
    case MobileFunctionKind.mobileApi:
      return const [
        _FunctionAction('Sync queue', Icons.sync_outlined, '/dashboard'),
        _FunctionAction('Functions', Icons.apps_outlined, '/functions'),
      ];
    case MobileFunctionKind.settings:
      return const [
        _FunctionAction('Profile', Icons.person_outline, '/profile'),
        _FunctionAction('Subscription', Icons.workspace_premium_outlined, '/subscriptions'),
      ];
  }
}

_FunctionPayload _inventoryPayload(
  Object? inventoryData,
  Object? salesData,
) {
  final inventory = _map(inventoryData);
  final salesMap = _map(salesData);
  final items = inventoryData is List
      ? _list(inventoryData)
      : _list(inventory['items'] ?? inventory['inventory'] ?? inventory['data']);
  final sales = salesData is List
      ? _list(salesData)
      : _list(salesMap['sales'] ?? salesMap['items'] ?? salesMap['data']);
  final lowStock = items.where((item) => item['lowStock'] == true).toList();
  final stockValue = items.fold<double>(0, (sum, item) {
    final quantity = _num(item['quantity']);
    final cost = _num(item['acquisitionUnitCost']);
    return sum + quantity * cost;
  });
  final revenue = sales.fold<double>(
      0, (sum, sale) => sum + _num(sale['totalAmount']));
  return _FunctionPayload(metrics: [
    _Metric('Items', '${items.length}', Icons.inventory_2_outlined,
        FarmioColors.info),
    _Metric('Low stock',
        '${lowStock.length}',
        Icons.warning_amber_rounded, FarmioColors.warning),
    _Metric('Stock value', Fmt.mwk(stockValue),
        Icons.account_balance_wallet_outlined, FarmioColors.success),
    _Metric('Sales', Fmt.mwk(revenue), Icons.trending_up_rounded,
        FarmioColors.primary),
  ], sections: [
    _SectionData(
      title: 'Stock',
      rows: items.map((item) => {
            'name': '${item['name'] ?? 'Item'}',
            'detail':
                '${_num(item['quantity'])} ${item['unit'] ?? ''} - ${item['category'] ?? 'inventory'}',
            'meta': '${item['cropName'] ?? item['season'] ?? ''}',
            'value': Fmt.mwk(_num(item['quantity']) *
                _num(item['acquisitionUnitCost'])),
          }).toList(),
    ),
    const _SectionData(title: 'Inventory operations', rows: [
      {
        'name': 'Inventory item detail',
        'detail': 'GET /api/mobile/inventory/[id]',
        'meta': 'Load one stock item with full details',
        'value': 'GET',
      },
      {
        'name': 'Inventory item update',
        'detail': 'PATCH/DELETE /api/mobile/inventory/[id]',
        'meta': 'Edit or remove stock items',
        'value': 'Manage',
      },
      {
        'name': 'Inventory sale update',
        'detail': 'PATCH/DELETE /api/mobile/inventory/sales/[id]',
        'meta': 'Correct or remove inventory sale records',
        'value': 'Manage',
      },
    ]),
    _SectionData(
      title: 'Low-stock alerts',
      rows: lowStock.map((item) => {
            'name': '${item['name'] ?? 'Item'}',
            'detail':
                '${_num(item['quantity'])} ${item['unit'] ?? ''} remaining',
            'meta': '${item['category'] ?? 'inventory'}',
            'value': 'Restock',
          }).toList(),
      emptyText: 'No low-stock items returned.',
    ),
    _SectionData(
      title: 'Sales',
      rows: sales.map((sale) => {
            'name': '${_nested(sale, 'inventoryItem', 'name') ?? 'Inventory sale'}',
            'detail':
                '${_num(sale['quantitySold'])} ${sale['unit'] ?? ''} - ${sale['buyerName'] ?? 'Buyer not set'}',
            'meta': _dateText(sale['saleDate']),
            'value': Fmt.mwk(_num(sale['totalAmount'])),
          }).toList(),
    ),
    const _SectionData(title: 'Native inventory workflow', rows: [
      {
        'name': 'Stock capture',
        'detail': 'Inventory purchases and harvest stock are managed in the mobile inventory flow.',
        'meta': 'Online submit or offline queue when unavailable',
        'value': 'Native',
      },
      {
        'name': 'Sale correction',
        'detail': 'Existing inventory sales can be edited or deleted through the item endpoint.',
        'meta': 'Uses selected sale id',
        'value': 'Native',
      },
    ]),
  ]);
}

_FunctionPayload _livestockPayload(Object? data) {
  final map = _map(data);
  final types = _list(map['types'] ?? map['livestockTypes']);
  final animals =
      data is List ? _list(data) : _list(map['animals'] ?? map['livestock']);
  final healthRows = <Map<String, String>>[];
  final productionRows = <Map<String, String>>[];
  final weightRows = <Map<String, String>>[];
  final expenseRows = <Map<String, String>>[];
  final saleRows = <Map<String, String>>[];
  for (final animal in animals) {
    final animalName =
        '${animal['name'] ?? animal['tag'] ?? _nested(animal, 'livestockType', 'name') ?? 'Animal'}';
    healthRows.addAll(_list(animal['healthRecords']).map((item) => {
          'name': '${item['type'] ?? item['treatment'] ?? 'Health record'}',
          'detail': animalName,
          'meta': _dateText(item['date'] ?? item['recordedAt']),
          'value': '${item['status'] ?? ''}',
        }));
    productionRows.addAll(_list(animal['productions']).map((item) => {
          'name': '${item['type'] ?? 'Production'}',
          'detail': animalName,
          'meta': _dateText(item['date'] ?? item['recordedAt']),
          'value': '${item['quantity'] ?? ''} ${item['unit'] ?? ''}',
        }));
    weightRows.addAll(_list(animal['weights']).map((item) => {
          'name': animalName,
          'detail': '${item['notes'] ?? 'Weight record'}',
          'meta': _dateText(item['date'] ?? item['recordedAt']),
          'value': '${item['weight'] ?? item['value'] ?? ''} kg',
        }));
    expenseRows.addAll(_list(animal['expenses']).map((item) => {
          'name': '${item['description'] ?? item['category'] ?? 'Expense'}',
          'detail': animalName,
          'meta': _dateText(item['date'] ?? item['recordedAt']),
          'value': Fmt.mwk(_num(item['amount'])),
        }));
    saleRows.addAll(_list(animal['sales']).map((item) => {
          'name': '${item['buyerName'] ?? 'Livestock sale'}',
          'detail': animalName,
          'meta': _dateText(item['date'] ?? item['saleDate']),
          'value': Fmt.mwk(_num(item['amount'] ?? item['totalAmount'])),
        }));
  }
  final healthCount = animals.fold<int>(
      0, (sum, animal) => sum + _list(animal['healthRecords']).length);
  final productionCount = animals.fold<int>(
      0, (sum, animal) => sum + _list(animal['productions']).length);
  final expense = animals.fold<double>(
      0,
      (sum, animal) =>
          sum +
          _list(animal['expenses'])
              .fold<double>(0, (s, item) => s + _num(item['amount'])));
  return _FunctionPayload(metrics: [
    _Metric('Animals', '${animals.length}', Icons.pets_outlined,
        FarmioColors.success),
    _Metric('Types', '${types.length}', Icons.category_outlined,
        FarmioColors.info),
    _Metric('Health', '$healthCount', Icons.medical_services_outlined,
        FarmioColors.warning),
    _Metric('Expenses', Fmt.mwk(expense), Icons.trending_down_rounded,
        FarmioColors.danger),
  ], sections: [
    _SectionData(
      title: 'Animal register',
      rows: animals.map((animal) => {
            'name':
                '${animal['name'] ?? animal['tag'] ?? _nested(animal, 'livestockType', 'name') ?? 'Animal'}',
            'detail':
                '${_nested(animal, 'livestockType', 'name') ?? 'Livestock'} - ${animal['sex'] ?? 'Unknown'}',
            'meta': '${animal['breed'] ?? animal['group'] ?? ''}',
            'value': _num(animal['weight']) > 0
                ? '${_num(animal['weight'])} kg'
                : '',
          }).toList(),
    ),
    const _SectionData(title: 'Animal operations', rows: [
      {
        'name': 'Animal detail',
        'detail': 'GET /api/mobile/livestock/[id]',
        'meta': 'Load one animal with its full record set',
        'value': 'GET',
      },
      {
        'name': 'Animal update',
        'detail': 'PATCH /api/mobile/livestock/[id]',
        'meta': 'Edit animal profile, status and details',
        'value': 'PATCH',
      },
      {
        'name': 'Animal delete',
        'detail': 'DELETE /api/mobile/livestock/[id]',
        'meta': 'Remove animal records when permitted',
        'value': 'DELETE',
      },
    ]),
    _SectionData(
      title: 'Health records',
      rows: healthRows,
      emptyText: 'No health records returned yet.',
    ),
    _SectionData(
      title: 'Production records',
      rows: productionRows,
      emptyText: 'No production records returned yet.',
    ),
    _SectionData(
      title: 'Weight records',
      rows: weightRows,
      emptyText: 'No weight records returned yet.',
    ),
    _SectionData(
      title: 'Livestock expenses',
      rows: expenseRows,
      emptyText: 'No livestock expenses returned yet.',
    ),
    _SectionData(
      title: 'Livestock sales',
      rows: saleRows,
      emptyText: 'No livestock sales returned yet.',
    ),
    const _SectionData(title: 'Native livestock workflow', rows: [
      {
        'name': 'Animal profile',
        'detail': 'Open an animal to review health, production, weight, expenses and sales together.',
        'meta': 'GET/PATCH/DELETE /api/mobile/livestock/[id]',
        'value': 'Native',
      },
      {
        'name': 'Record capture',
        'detail': 'Health, production, expense, weight and sale records use /api/mobile/livestock/records.',
        'meta': 'Queueable create operation',
        'value': 'Offline',
      },
    ]),
  ]);
}

_FunctionPayload _equipmentPayload(Object? data) {
  final map = _map(data);
  final equipment = data is List
      ? _list(data)
      : _list(map['equipment'] ?? map['items'] ?? map['data']);
  final costs = _list(map['costs'] ?? map['records'] ?? map['serviceLogs']);
  final totalCost =
      costs.fold<double>(0, (sum, item) => sum + _num(item['amount']));
  return _FunctionPayload(metrics: [
    _Metric('Equipment', '${equipment.length}',
        Icons.precision_manufacturing_outlined, FarmioColors.primary),
    _Metric('Cost records', '${costs.length}', Icons.receipt_long_outlined,
        FarmioColors.warning),
    _Metric('Machinery cost', Fmt.mwk(totalCost),
        Icons.account_balance_wallet_outlined, FarmioColors.danger),
  ], sections: [
    _SectionData(
      title: 'Equipment register',
      rows: equipment.map((item) => {
            'name': '${item['name'] ?? 'Equipment'}',
            'detail': '${_num(item['quantity'])} ${item['unit'] ?? 'unit'}',
            'meta': '${item['notes'] ?? ''}',
            'value': '',
          }).toList(),
    ),
    _SectionData(
      title: 'Fuel and service costs',
      rows: costs.map((item) => {
            'name': '${item['description'] ?? item['category'] ?? 'Cost'}',
            'detail': '${item['category'] ?? 'Machinery'}',
            'meta': _dateText(item['date']),
            'value': Fmt.mwk(_num(item['amount'])),
          }).toList(),
    ),
    const _SectionData(title: 'Equipment operations', rows: [
      {
        'name': 'Equipment register',
        'detail': 'Create and review machinery, implements, pumps, tools and power units.',
        'meta': 'GET/POST /api/mobile/equipment',
        'value': 'Native',
      },
      {
        'name': 'Fuel and service logs',
        'detail': 'Record machinery running costs for report allocation and cost summaries.',
        'meta': 'Linked to finance and overhead reports',
        'value': 'Costing',
      },
    ]),
  ]);
}

_FunctionPayload _notificationsPayload(Object? data) {
  final map = _map(data);
  final notifications = data is List
      ? _list(data)
      : _list(map['notifications'] ?? map['alerts'] ?? map['items']);
  final unread = _num(map['unread'] ??
          notifications.where((item) => item['isRead'] != true).length)
      .toInt();
  return _FunctionPayload(metrics: [
    _Metric('Unread', '$unread', Icons.notifications_active_outlined,
        FarmioColors.warning),
    _Metric('Total', '${notifications.length}', Icons.notifications_outlined,
        FarmioColors.info),
  ], sections: [
    _SectionData(
      title: 'Alerts',
      rows: notifications.map((item) => {
            'name': '${item['title'] ?? item['type'] ?? 'Notification'}',
            'detail': '${item['message'] ?? item['body'] ?? ''}',
            'meta': _dateText(item['createdAt']),
            'value': item['isRead'] == true ? 'Read' : 'New',
          }).toList(),
      emptyText: 'No notifications yet.',
    ),
    const _SectionData(title: 'Alert behavior', rows: [
      {
        'name': 'Recommended activity detail',
        'detail': 'Tapping an alert should show the recommendation, due window, crop and evidence needed.',
        'meta': 'It should not open the activity form directly',
        'value': 'Detail',
      },
      {
        'name': 'Unread state',
        'detail': 'The notification count and read state come from /api/mobile/notifications.',
        'meta': 'Mark-all-read is available from the header action',
        'value': 'Native',
      },
    ]),
  ]);
}

_FunctionPayload _traceabilityPayload(Object? data) {
  final map = _map(data);
  final lots = data is List
      ? _list(data)
      : _list(map['lots'] ?? map['traceabilityLots'] ?? map['items']);
  final ready =
      lots.where((lot) => _nested(lot, 'checklist', 'buyerReady') == true).length;
  return _FunctionPayload(metrics: [
    _Metric('Lots', '${lots.length}', Icons.qr_code_2_outlined,
        FarmioColors.primary),
    _Metric('Buyer-ready', '$ready', Icons.verified_outlined,
        FarmioColors.success),
    _Metric('Need evidence', '${lots.length - ready}',
        Icons.fact_check_outlined, FarmioColors.warning),
  ], sections: [
    _SectionData(
      title: 'Crop lots',
      rows: lots.map((lot) => {
            'name': '${lot['lotId'] ?? lot['cropName'] ?? 'Lot'}',
            'detail':
                '${lot['cropName'] ?? ''} - ${lot['fieldName'] ?? ''} - ${lot['season'] ?? ''}',
            'meta':
                'Activities ${lot['activityCount'] ?? 0}, harvests ${lot['harvestCount'] ?? 0}, sales ${lot['saleCount'] ?? 0}',
            'value': _nested(lot, 'checklist', 'buyerReady') == true
                ? 'Ready'
                : 'Missing',
          }).toList(),
    ),
    const _SectionData(title: 'Traceability export detail', rows: [
      {
        'name': 'Buyer-ready summary',
        'detail': 'Lot detail includes activity, spray, harvest, sale and missing evidence counts.',
        'meta': 'GET /api/mobile/traceability',
        'value': 'Native',
      },
      {
        'name': 'Evidence pack link',
        'detail': 'Traceability feeds buyer records, audit files and compliance packs.',
        'meta': 'Use Documents and Records for supporting files',
        'value': 'Export',
      },
    ]),
  ]);
}

_FunctionPayload _creditReadinessPayload(Object? data) {
  final map = _map(data);
  final checklist = _list(map['checklist']);
  final factors = _list(map['factors']);
  final score = _num(map['score'] ?? map['readinessScore']).round();
  return _FunctionPayload(metrics: [
    _Metric('Score', score > 0 ? '$score%' : 'Review',
        Icons.credit_score_outlined, FarmioColors.primary),
    _Metric('Checklist', '${checklist.length}', Icons.fact_check_outlined,
        FarmioColors.info),
    _Metric('Risk', '${map['risk'] ?? map['riskLevel'] ?? 'Unknown'}',
        Icons.warning_amber_outlined, FarmioColors.warning),
  ], sections: [
    _SectionData(
      title: 'Readiness checklist',
      rows: checklist.map((item) => {
            'name': '${item['title'] ?? item['name'] ?? 'Requirement'}',
            'detail': '${item['description'] ?? item['message'] ?? ''}',
            'meta': '${item['category'] ?? 'credit readiness'}',
            'value': item['complete'] == true ? 'Done' : 'Missing',
          }).toList(),
      emptyText: 'No credit readiness checklist returned yet.',
    ),
    _SectionData(
      title: 'Scoring factors',
      rows: factors.map((item) => {
            'name': '${item['title'] ?? item['name'] ?? 'Factor'}',
            'detail': '${item['description'] ?? item['message'] ?? ''}',
            'meta': '${item['weight'] ?? ''}',
            'value': '${item['score'] ?? item['status'] ?? ''}',
          }).toList(),
      emptyText: 'No scoring factors returned yet.',
    ),
  ]);
}

_FunctionPayload _funderPayload(
  Object? data, {
  required bool creditMode,
}) {
  final map = _map(data);
  final totals = _map(map['totals']);
  final portfolio = data is List
      ? _list(data)
      : _list(map['portfolio'] ?? map['farms'] ?? map['items']);
  final average = _num(totals['averageCompleteness']).round();
  return _FunctionPayload(metrics: [
    _Metric(creditMode ? 'Readiness' : 'Avg readiness', '$average%',
        Icons.credit_score_outlined, FarmioColors.primary),
    _Metric('Farms', '${totals['farms'] ?? portfolio.length}',
        Icons.account_balance_outlined, FarmioColors.info),
    _Metric('High risk', '${totals['highRisk'] ?? 0}',
        Icons.warning_amber_rounded, FarmioColors.danger),
  ], sections: [
    _SectionData(
      title: creditMode ? 'Credit readiness' : 'Portfolio farms',
      rows: portfolio.map((farm) => {
            'name': '${farm['name'] ?? 'Farm'}',
            'detail':
                '${farm['fields'] ?? 0} fields - ${farm['crops'] ?? 0} crops - ${farm['documents'] ?? 0} docs',
            'meta': 'Completeness ${farm['recordCompleteness'] ?? 0}%',
            'value': '${farm['risk'] ?? 'Unknown'}',
          }).toList(),
    ),
    const _SectionData(title: 'Funder review signals', rows: [
      {
        'name': 'Record completeness',
        'detail': 'Uses fields, crops, activities, sales, yields, payroll and documents.',
        'meta': 'Portfolio and single-farm review',
        'value': 'Score',
      },
      {
        'name': 'Credit readiness',
        'detail': 'Credit screen shows detailed readiness checklist for lender review.',
        'meta': 'GET /api/mobile/credit-readiness',
        'value': 'Linked',
      },
    ]),
  ]);
}

_FunctionPayload _weatherPayload([Object? data]) {
  final map = _map(data);
  final forecast = _list(map['forecast']);
  final advice = _list(map['advice']);
  return _FunctionPayload(metrics: [
    _Metric('Forecast', forecast.isEmpty ? 'Manual' : '${forecast.length} days',
        Icons.cloud_queue_outlined, FarmioColors.info),
    _Metric('Advice', advice.isEmpty ? 'Manual' : '${advice.length}',
        Icons.tips_and_updates_outlined, FarmioColors.warning),
    _Metric('Planning', 'Active', Icons.event_available_outlined,
        FarmioColors.success),
  ], sections: [
    _SectionData(
      title: 'Forecast',
      rows: forecast.map((item) => {
            'name': _dateText(item['date']) == ''
                ? '${item['day'] ?? 'Forecast'}'
                : _dateText(item['date']),
            'detail':
                '${item['summary'] ?? item['condition'] ?? 'Weather condition'}',
            'meta':
                'Rain ${item['rainChance'] ?? item['precipitationChance'] ?? '-'} / Wind ${item['wind'] ?? '-'}',
            'value': '${item['temperature'] ?? item['temp'] ?? ''}',
          }).toList(),
      emptyText: 'No weather provider response yet.',
    ),
    _SectionData(title: 'Field advice', rows: advice.isEmpty ? const [
      {
        'name': 'Check local forecast',
        'detail':
            'Use this page for weather-aware planning once a forecast provider is configured.',
        'meta': 'Recommended before spraying, planting and harvesting',
        'value': 'Open',
      },
      {
        'name': 'Spray caution',
        'detail':
            'Avoid spraying when rain or strong wind is likely within the label interval.',
        'meta': 'Operational guidance',
        'value': 'Advisory',
      },
    ] : advice.map((item) => {
          'name': '${item['title'] ?? item['type'] ?? 'Weather advice'}',
          'detail': '${item['message'] ?? item['body'] ?? ''}',
          'meta': '${item['priority'] ?? ''}',
          'value': '${item['status'] ?? 'Advisory'}',
        }).toList()),
  ]);
}

_FunctionPayload _aiPayload(
  Map<String, dynamic> dashboard,
  Map<String, dynamic> reports,
) {
  final net = _num(dashboard['net']);
  final expense = _num(dashboard['expense']);
  final income = _num(dashboard['income']);
  final cropRows = _list(reports['cropReport']);
  final topCostCrop = cropRows.isEmpty ? null : cropRows.first;
  return _FunctionPayload(metrics: [
    _Metric('Net', Fmt.mwk(net), Icons.account_balance_wallet_outlined,
        net >= 0 ? FarmioColors.success : FarmioColors.danger),
    _Metric('Expenses', Fmt.mwk(expense), Icons.trending_down_rounded,
        FarmioColors.danger),
    _Metric('Income', Fmt.mwk(income), Icons.trending_up_rounded,
        FarmioColors.success),
  ], sections: [
    _SectionData(title: 'Operating insights', rows: [
      {
        'name': net >= 0 ? 'Positive farm position' : 'Negative farm position',
        'detail': net >= 0
            ? 'Income is covering recorded costs for the selected period.'
            : 'Recorded costs are higher than income. Review expenses and missing sales.',
        'meta': 'Dashboard summary',
        'value': net >= 0 ? 'Good' : 'Risk',
      },
      {
        'name': 'Highest cost crop',
        'detail': topCostCrop == null
            ? 'No crop cost rows returned yet.'
            : '${topCostCrop['cropName']} has the highest recorded cost.',
        'meta': 'Report analysis',
        'value':
            topCostCrop == null ? '' : Fmt.mwk(_num(topCostCrop['totalCost'])),
      },
    ]),
  ]);
}

_FunctionPayload _documentsPayload(Object? data) {
  final map = _map(data);
  final documents = data is List ? _list(data) : _list(map['documents']);
  final categories = <String, int>{};
  for (final item in documents) {
    final category = '${item['category'] ?? 'other'}';
    categories[category] = (categories[category] ?? 0) + 1;
  }
  return _FunctionPayload(metrics: [
    _Metric('Documents', '${documents.length}', Icons.folder_copy_outlined,
        FarmioColors.primary),
    _Metric('Categories', '${categories.length}', Icons.category_outlined,
        FarmioColors.info),
    _Metric('Evidence', '${documents.where((item) => item['url'] != null || item['fileUrl'] != null).length}',
        Icons.verified_outlined, FarmioColors.success),
  ], sections: [
    _SectionData(
      title: 'Attached evidence',
      rows: documents.map((item) => {
            'name': '${item['title'] ?? item['name'] ?? 'Document'}',
            'detail': '${item['category'] ?? 'other'}',
            'meta': _dateText(item['createdAt'] ?? item['date']),
            'value': '${item['status'] ?? ''}',
          }).toList(),
      emptyText: 'No evidence files returned yet.',
    ),
    _SectionData(
      title: 'Category summary',
      rows: categories.entries.map((entry) => {
            'name': entry.key,
            'detail': 'Evidence category',
            'meta': '',
            'value': '${entry.value}',
          }).toList(),
    ),
    const _SectionData(title: 'Upload categories', rows: [
      {
        'name': 'Receipt and field photo',
        'detail': 'Evidence for expenses, inputs, activities, field state and crop condition.',
        'meta': 'receipt / field_photo',
        'value': 'Upload',
      },
      {
        'name': 'Vet, certificate and insurance',
        'detail': 'Evidence for livestock, compliance, quality and insurance review.',
        'meta': 'vet_record / certificate / insurance_evidence',
        'value': 'Upload',
      },
      {
        'name': 'Buyer, loan and other',
        'detail': 'Contracts, lender documents and manually linked supporting files.',
        'meta': 'buyer_contract / loan_document / other',
        'value': 'Upload',
      },
    ]),
  ]);
}

_FunctionPayload _compliancePayload(Object? data) {
  final map = _map(data);
  final lots = _list(map['lots'] ?? map['traceabilityLots']);
  final checks = _list(map['checks'] ?? map['checklist']);
  final missing = lots.fold<int>(
    0,
    (sum, lot) => sum + _list(_nested(lot, 'checklist', 'missingEvidence')).length,
  );
  final ready = lots
      .where((lot) => _nested(lot, 'checklist', 'buyerReady') == true)
      .length;
  return _FunctionPayload(metrics: [
    _Metric('Lots checked', '${lots.length}', Icons.fact_check_outlined,
        FarmioColors.primary),
    _Metric('Buyer-ready', '$ready', Icons.verified_outlined,
        FarmioColors.success),
    _Metric('Missing items', '$missing', Icons.warning_amber_outlined,
        FarmioColors.warning),
  ], sections: [
    _SectionData(
      title: 'Compliance checks',
      rows: checks.map((item) => {
            'name': '${item['title'] ?? item['name'] ?? 'Check'}',
            'detail': '${item['description'] ?? item['message'] ?? ''}',
            'meta': '${item['category'] ?? 'compliance'}',
            'value': item['complete'] == true ? 'Done' : 'Missing',
          }).toList(),
      emptyText: 'No compliance checklist returned yet.',
    ),
    _SectionData(
      title: 'Compliance checklist',
      rows: lots.map((lot) => {
            'name': '${lot['lotId'] ?? lot['cropName'] ?? 'Crop lot'}',
            'detail':
                '${lot['cropName'] ?? ''} / ${lot['fieldName'] ?? ''} / ${lot['season'] ?? ''}',
            'meta':
                'Activities ${lot['activityCount'] ?? 0}, sprays ${lot['sprayRecordCount'] ?? 0}, harvests ${lot['harvestCount'] ?? 0}',
            'value': _nested(lot, 'checklist', 'buyerReady') == true
                ? 'Ready'
                : 'Review',
          }).toList(),
    ),
    const _SectionData(title: 'Compliance outputs', rows: [
      {
        'name': 'Audit readiness',
        'detail': 'Checks whether activity, finance, document and harvest evidence is sufficient.',
        'meta': 'GET /api/mobile/compliance',
        'value': 'Review',
      },
      {
        'name': 'Record pack handoff',
        'detail': 'Missing evidence should be added through Documents before export.',
        'meta': 'Feeds Records and Traceability',
        'value': 'Export',
      },
    ]),
  ]);
}

_FunctionPayload _teamPayload(Object? data) {
  final map = _map(data);
  final employees = data is List
      ? _list(data)
      : _list(map['members'] ?? map['team'] ?? map['employees']);
  final active = employees.where((item) {
    final status = '${item['status'] ?? 'active'}'.toLowerCase();
    return !status.contains('archived') && !status.contains('inactive');
  }).length;
  return _FunctionPayload(metrics: [
    _Metric('Team', '${employees.length}', Icons.groups_outlined,
        FarmioColors.info),
    _Metric('Active', '$active', Icons.person_add_alt_outlined,
        FarmioColors.success),
    _Metric('Payroll', '${employees.where((item) => _num(item['payRate']) > 0).length}',
        Icons.payments_outlined, FarmioColors.warning),
  ], sections: [
    _SectionData(
      title: 'Team members and workers',
      rows: employees.map((item) => {
            'name': '${item['name'] ?? 'Worker'}',
            'detail': '${item['role'] ?? item['jobTitle'] ?? 'Team member'}',
            'meta': '${item['phone'] ?? item['email'] ?? ''}',
            'value': _num(item['payRate']) > 0 ? Fmt.mwk(_num(item['payRate'])) : '',
          }).toList(),
    ),
    const _SectionData(title: 'Team operations', rows: [
      {
        'name': 'Create member',
        'detail': 'POST /api/mobile/team',
        'meta': 'Invite or add a team member with role permissions',
        'value': 'POST',
      },
      {
        'name': 'Update permissions',
        'detail': 'POST /api/mobile/team',
        'meta': 'Backend may accept role or permission payload updates',
        'value': 'POST',
      },
    ]),
  ]);
}

_FunctionPayload _seasonsPayload(Object? data, [Object? compareData]) {
  final map = _map(data);
  final compare = _map(compareData);
  final seasons = data is List
      ? _list(data)
      : _list(map['seasons'] ?? map['seasonReport']);
  final comparisons = _list(compare['rows'] ?? compare['comparison']);
  final profitable = seasons.where((item) => _num(item['net']) >= 0).length;
  return _FunctionPayload(metrics: [
    _Metric('Seasons', '${seasons.length}', Icons.timeline_outlined,
        FarmioColors.primary),
    _Metric('Profitable', '$profitable', Icons.trending_up_rounded,
        FarmioColors.success),
    _Metric('Archived included', 'Yes', Icons.archive_outlined,
        FarmioColors.info),
  ], sections: [
    _SectionData(
      title: 'Season comparison',
      rows: seasons.isEmpty ? const [
        {
          'name': 'Select current season',
          'detail': 'Choose the season currently being reviewed.',
          'meta': 'Includes active and archived seasons when returned by reports.',
          'value': 'Step 1',
        },
        {
          'name': 'Select comparison season',
          'detail': 'Compare area, cost, revenue, yield and profit.',
          'meta': 'Previous season or custom season.',
          'value': 'Step 2',
        },
      ] : seasons.map((item) => {
            'name': '${item['season'] ?? 'Season'}',
            'detail':
                'Income ${Fmt.mwk(_num(item['income']))} / costs ${Fmt.mwk(_num(item['totalCost'] ?? item['cost']))}',
            'meta': 'Crops ${_list(item['crops']).length}, fields ${_list(item['fields']).length}',
            'value': Fmt.mwk(_num(item['net'])),
          }).toList(),
    ),
    _SectionData(
      title: 'Compare response',
      rows: comparisons.map((item) => {
            'name': '${item['metric'] ?? item['name'] ?? 'Metric'}',
            'detail': '${item['current'] ?? item['currentSeason'] ?? ''}',
            'meta': '${item['previous'] ?? item['comparisonSeason'] ?? ''}',
            'value': '${item['change'] ?? item['trend'] ?? ''}',
          }).toList(),
      emptyText: 'No /mobile/seasons/compare rows returned yet.',
    ),
    const _SectionData(title: 'Comparison metrics', rows: [
      {
        'name': 'Production',
        'detail': 'Area, harvested quantity and yield per hectare.',
        'meta': 'Season compare',
        'value': 'Track',
      },
      {
        'name': 'Financials',
        'detail': 'Revenue, activity cost, overhead, net profit and cost per hectare.',
        'meta': 'Season compare',
        'value': 'Track',
      },
      {
        'name': 'Trend',
        'detail': 'Improving, declining or stable based on net and yield movement.',
        'meta': 'Season compare',
        'value': 'Badge',
      },
    ]),
  ]);
}

_FunctionPayload _fieldMapPayload(Object? data) {
  final map = _map(data);
  final fields = data is List ? _list(data) : _list(map['fields']);
  final zones = _list(map['zones']);
  final markers = _list(map['markers']);
  final mapped = fields.where((item) =>
      item['boundary'] != null ||
      item['coordinates'] != null ||
      item['latitude'] != null).length;
  return _FunctionPayload(metrics: [
    _Metric('Fields', '${fields.length}', Icons.map_outlined,
        FarmioColors.primary),
    _Metric('Mapped', '$mapped', Icons.gps_fixed_outlined,
        FarmioColors.success),
    _Metric('Needs GPS', '${fields.length - mapped}', Icons.add_location_alt_outlined,
        FarmioColors.warning),
    _Metric('Zones', '${zones.length}', Icons.grid_on_outlined,
        FarmioColors.primary),
    _Metric('Markers', '${markers.length}', Icons.location_on_outlined,
        FarmioColors.success),
  ], sections: [
    _SectionData(
      title: 'Boundary and marker readiness',
      rows: fields.map((item) => {
            'name': '${item['name'] ?? 'Field'}',
            'detail':
                '${item['area'] ?? item['size'] ?? 'Area not set'} ${item['areaUnit'] ?? 'ha'}',
            'meta': '${item['soilType'] ?? item['location'] ?? ''}',
            'value': item['boundary'] != null || item['coordinates'] != null
                ? 'Mapped'
                : 'Add GPS',
          }).toList(),
    ),
    _SectionData(
      title: 'Field zones',
      rows: zones.map((item) => {
            'name': '${item['name'] ?? item['zoneName'] ?? 'Zone'}',
            'detail': '${item['type'] ?? item['zoneType'] ?? 'field zone'}',
            'meta': '${item['fieldName'] ?? item['fieldId'] ?? ''}',
            'value': '${item['area'] ?? item['size'] ?? ''}',
          }).toList(),
      emptyText: 'No zones returned yet.',
    ),
    _SectionData(
      title: 'Field markers',
      rows: markers.map((item) => {
            'name': '${item['name'] ?? item['title'] ?? 'Marker'}',
            'detail': '${item['type'] ?? item['markerType'] ?? 'marker'}',
            'meta': '${item['fieldName'] ?? item['fieldId'] ?? ''}',
            'value': '${item['status'] ?? ''}',
          }).toList(),
      emptyText: 'No markers returned yet.',
    ),
    const _SectionData(title: 'Map editing endpoints', rows: [
      {
        'name': 'Boundary',
        'detail': 'GET/POST/DELETE /api/mobile/fields/[id]/boundary',
        'meta': 'Field GPS boundary management',
        'value': 'Edit',
      },
      {
        'name': 'Zones',
        'detail': 'GET/POST /api/mobile/fields/[id]/zones',
        'meta': 'Create and list field zones',
        'value': 'Create',
      },
      {
        'name': 'Zone update/delete',
        'detail': 'PATCH/DELETE /api/mobile/fields/[id]/zones/[zoneId]',
        'meta': 'Update or remove a zone',
        'value': 'Manage',
      },
      {
        'name': 'Markers',
        'detail': 'GET/POST /api/mobile/markers and PATCH/DELETE /api/mobile/markers/[id]',
        'meta': 'Point-of-interest marker management',
        'value': 'Manage',
      },
    ]),
    const _SectionData(title: 'Supported zone types', rows: [
      {
        'name': 'Crop zones',
        'detail': 'Divide a field by crop or variety blocks.',
        'meta': 'Useful for mixed cropping and staged harvests',
        'value': 'Zone',
      },
      {
        'name': 'Soil and drainage zones',
        'detail': 'Mark poor soil, wet areas, erosion, drainage or irrigation sections.',
        'meta': 'Useful for input planning',
        'value': 'Zone',
      },
      {
        'name': 'Infrastructure zones',
        'detail': 'Sheds, roads, gates, irrigation lines and storage areas.',
        'meta': 'Useful for farm layout records',
        'value': 'Zone',
      },
    ]),
    const _SectionData(title: 'Supported marker types', rows: [
      {
        'name': 'Water and access',
        'detail': 'Boreholes, taps, roads, gates and crossings.',
        'meta': 'Point marker',
        'value': 'Marker',
      },
      {
        'name': 'Buildings and storage',
        'detail': 'Sheds, barns, stores, curing areas and packing points.',
        'meta': 'Point marker',
        'value': 'Marker',
      },
      {
        'name': 'Natural points',
        'detail': 'Trees, slopes, erosion points and landmarks.',
        'meta': 'Point marker',
        'value': 'Marker',
      },
    ]),
  ]);
}

_FunctionPayload _reportBuilderPayload(Object? data) {
  final map = _map(data);
  final reports = _list(map['reports']);
  final available = reports.isNotEmpty
      ? reports.map((item) => {
            'name': '${item['title'] ?? item['name'] ?? 'Report'}',
            'detail': '${item['description'] ?? 'Custom report section'}',
            'meta': '${item['category'] ?? 'report'}',
            'value': '${item['format'] ?? 'PDF'}',
          }).toList()
      : _defaultReportRows();
  return _FunctionPayload(metrics: [
    _Metric('Report sections', '${available.length}', Icons.post_add_outlined,
        FarmioColors.purple),
    _Metric('PDF export', 'Ready', Icons.picture_as_pdf_outlined,
        FarmioColors.danger),
    _Metric('Filters', 'Date/crop/season/field', Icons.tune_outlined,
        FarmioColors.primary),
  ], sections: [
    _SectionData(title: 'Selectable reports', rows: available),
    const _SectionData(title: 'Graph catalog', rows: [
      {
        'name': 'Cashflow by month',
        'detail': 'Monthly income, expenses and net cashflow bar chart.',
        'meta': 'Dashboard and report export',
        'value': 'Chart',
      },
      {
        'name': 'Yield and cost trends',
        'detail': 'Yield per hectare, cost per hectare and cost per kg line charts.',
        'meta': 'Season and crop performance',
        'value': 'Chart',
      },
      {
        'name': 'Revenue vs expenses',
        'detail': 'Season grouped bars with expense breakdown by input, labour, other and overhead.',
        'meta': 'Financial reports',
        'value': 'Chart',
      },
      {
        'name': 'Map views',
        'detail': 'Farm map, field boundary map, zone map and marker map.',
        'meta': 'Field map module',
        'value': 'Map',
      },
    ]),
    const _SectionData(title: 'Export requirements', rows: [
      {
        'name': 'PDF export',
        'detail': 'Portrait layout with AgriVault branding, farm name, generated date and filters.',
        'meta': 'Charts and tables',
        'value': 'Required',
      },
      {
        'name': 'CSV export',
        'detail': 'Custom report rows exported using selected columns and filters.',
        'meta': 'Custom report builder',
        'value': 'Optional',
      },
      {
        'name': 'Mobile export',
        'detail': 'User selects reports and filters before export.',
        'meta': 'Date, crop, season, field and archive filters',
        'value': 'Ready',
      },
    ]),
    const _SectionData(title: 'Mobile export filters', rows: [
      {
        'name': 'Period',
        'detail': 'Today, this week, this month, last 365 days, custom range or season.',
        'meta': 'Default: this year / last 365 days',
        'value': 'Required',
      },
      {
        'name': 'Farm context',
        'detail': 'Crop, field, season, active or archived status.',
        'meta': 'Applies before export',
        'value': 'Required',
      },
      {
        'name': 'Sections',
        'detail': 'Select one or many report sections before creating the export.',
        'meta': 'PDF-first, CSV optional',
        'value': 'Native',
      },
    ]),
  ]);
}

/// Maps a graph-catalog entry's `key` (or, failing that, its title) to the
/// screen in this app where that visualization actually lives — the catalog
/// itself is a manifest, not a chart renderer.
const _graphCatalogRoutes = {
  'cashflowbymonth': '/reports',
  'yieldperhabyseason': '/reports',
  'costperhabyseason': '/reports',
  'costofproductionperhectare': '/reports',
  'costperkgproduced': '/reports',
  'revenuevsexpensesbyseason': '/seasons',
  'expensebreakdownbyseason': '/reports',
  'fieldmap': '/field-map',
  'seasoncomparison': '/seasons',
  'seasoncomparisontable': '/seasons',
  'cropperformance': '/reports',
  'cropperformancetrends': '/reports',
  'fieldboundarymap': '/field-map',
  'zonemap': '/field-map',
  'markermap': '/field-map',
};

String? _graphCatalogRouteFor(String key, String title) {
  final normalizedKey = key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  if (_graphCatalogRoutes.containsKey(normalizedKey)) {
    return _graphCatalogRoutes[normalizedKey];
  }
  final normalizedTitle =
      title.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  return _graphCatalogRoutes[normalizedTitle];
}

_FunctionPayload _graphCatalogPayload(Object? data) {
  final map = _map(data);
  final graphs = data is List
      ? _list(data)
      : _list(map['graphs'] ?? map['items'] ?? map['catalog']);
  final effective = graphs.isEmpty ? _defaultGraphRows() : graphs.map((item) {
        final title = '${item['title'] ?? item['name'] ?? 'Graph'}';
        final route =
            _graphCatalogRouteFor('${item['key'] ?? ''}', title);
        return {
          'name': title,
          'detail':
              '${item['description'] ?? item['type'] ?? 'Visualization'}',
          'meta': '${item['section'] ?? item['category'] ?? 'report'}',
          'value': '${item['status'] ?? item['format'] ?? 'Chart'}',
          if (route != null) 'route': route,
        };
      }).toList();
  final mapCount = effective.where((item) =>
      (item['value'] ?? '').toLowerCase().contains('map') ||
      (item['name'] ?? '').toLowerCase().contains('map')).length;
  return _FunctionPayload(metrics: [
    _Metric('Graphs', '${effective.length}', Icons.analytics_outlined,
        FarmioColors.info),
    _Metric('Charts', '${effective.length - mapCount}', Icons.bar_chart_outlined,
        FarmioColors.primary),
    _Metric('Maps', '$mapCount', Icons.map_outlined, FarmioColors.success),
  ], sections: [
    _SectionData(title: 'Available visualizations', rows: effective),
    const _SectionData(title: 'Graph endpoint', rows: [
      {
        'name': 'Graph catalog',
        'detail': 'GET /api/mobile/graph-catalog',
        'meta': 'Returns report, dashboard, export and map visualizations',
        'value': 'GET',
      },
    ]),
  ]);
}

_FunctionPayload _mobileApiPayload() {
  final endpoints = [
    '/api/mobile/dashboard',
    '/api/mobile/farm-context',
    '/api/mobile/fields',
    '/api/mobile/field-map',
    '/api/mobile/fields/[id]/boundary',
    '/api/mobile/fields/[id]/zones',
    '/api/mobile/fields/[id]/zones/[zoneId]',
    '/api/mobile/markers',
    '/api/mobile/markers/[id]',
    '/api/mobile/crop_types',
    '/api/mobile/crops',
    '/api/mobile/activities',
    '/api/mobile/yields',
    '/api/mobile/finance',
    '/api/mobile/overhead',
    '/api/mobile/inventory',
    '/api/mobile/inventory/[id]',
    '/api/mobile/inventory/sales',
    '/api/mobile/inventory/sales/[id]',
    '/api/mobile/equipment',
    '/api/mobile/livestock',
    '/api/mobile/livestock/[id]',
    '/api/mobile/livestock/records',
    '/api/mobile/seasons',
    '/api/mobile/seasons/compare',
    '/api/mobile/weather',
    '/api/mobile/credit-readiness',
    '/api/mobile/compliance',
    '/api/mobile/team',
    '/api/mobile/reports',
    '/api/mobile/report-builder',
    '/api/mobile/graph-catalog',
    '/api/mobile/traceability',
    '/api/mobile/funder-dashboard',
    '/api/mobile/documents',
    '/api/mobile/notifications',
    '/api/mobile/sync',
  ];
  return _FunctionPayload(metrics: [
    _Metric('Endpoints', '${endpoints.length}', Icons.api_outlined,
        FarmioColors.primary),
    _Metric('Auth', 'Bearer JWT', Icons.lock_outline, FarmioColors.success),
    _Metric('Offline queue', 'Enabled', Icons.sync_outlined,
        FarmioColors.info),
  ], sections: [
    _SectionData(
      title: 'Mobile API routes',
      rows: endpoints.map((endpoint) => {
            'name': endpoint,
            'detail': 'Authenticated mobile API route',
            'meta': endpoint == '/api/mobile/sync' ? 'Offline sync' : 'REST',
            'value': 'Mobile',
          }).toList(),
    ),
  ]);
}

List<Map<String, String>> _defaultGraphRows() {
  const rows = [
    ['Cashflow by month', 'Monthly income, expenses and net cashflow.', 'Financials', 'Chart'],
    ['Yield per hectare by season', 'Yield per hectare changes across seasons.', 'Yields', 'Chart'],
    ['Cost of production per hectare', 'Production cost per hectare over time.', 'Analytics', 'Chart'],
    ['Cost per kg produced', 'Cost efficiency of production over time.', 'Analytics', 'Chart'],
    ['Revenue vs expenses by season', 'Season revenue compared with expenses.', 'Financials', 'Chart'],
    ['Expense breakdown by season', 'Input, labour, other cost and overhead components.', 'Overhead', 'Chart'],
    ['Farm map', 'Fields, boundaries, zones and markers.', 'Maps', 'Map'],
    ['Field boundary map', 'GPS boundary for one field.', 'Maps', 'Map'],
    ['Zone map', 'Internal field zones.', 'Maps', 'Map'],
    ['Marker map', 'Farm points of interest.', 'Maps', 'Map'],
    ['Season comparison table', 'Two-season metric comparison.', 'Seasons', 'Table'],
    ['Crop trend badges', 'Improving, declining and stable labels.', 'Analytics', 'Badge'],
  ];
  return rows.map((row) {
    final route = _graphCatalogRouteFor('', row[0]);
    return {
      'name': row[0],
      'detail': row[1],
      'meta': row[2],
      'value': row[3],
      if (route != null) 'route': route,
    };
  }).toList();
}

_FunctionPayload _settingsPayload(Object? data, [Object? contextData]) {
  final map = _map(data);
  final context = _map(contextData);
  final user = _map(map['user']);
  final farm = _map(context['activeFarm']).isNotEmpty
      ? _map(context['activeFarm'])
      : _map(map['farm']);
  final subscription = _map(map['subscription']);
  final farms = _list(context['farms']);
  return _FunctionPayload(metrics: [
    _Metric('User', '${user['name'] ?? 'Profile'}', Icons.person_outline,
        FarmioColors.primary),
    _Metric('Farm', '${farm['name'] ?? 'Farm'}', Icons.home_work_outlined,
        FarmioColors.success),
    _Metric('Tier', '${subscription['tier'] ?? subscription['name'] ?? 'Plan'}',
        Icons.workspace_premium_outlined, FarmioColors.warning),
  ], sections: [
    _SectionData(title: 'Account settings', rows: [
      {
        'name': 'Farm switching',
        'detail': farms.isEmpty
            ? 'Use the profile area to view active farm context.'
            : 'Select from farms returned by the farm-context endpoint.',
        'meta': '${farm['location'] ?? ''}',
        'value': farms.isEmpty ? 'Ready' : '${farms.length} farms',
      },
      {
        'name': 'Password management',
        'detail': 'Handled by the account/profile API flow.',
        'meta': '${user['email'] ?? ''}',
        'value': 'Secure',
      },
      {
        'name': 'Subscription',
        'detail': 'Tier and write limits are read from login/profile.',
        'meta': '${subscription['status'] ?? ''}',
        'value': '${subscription['tier'] ?? subscription['name'] ?? ''}',
      },
    ]),
    _SectionData(
      title: 'Accessible farms',
      rows: farms.map((item) => {
            'name': '${item['name'] ?? 'Farm'}',
            'detail': '${item['location'] ?? item['role'] ?? ''}',
            'meta': item['id'] == farm['id'] ? 'Current farm' : '',
            'value': item['id'] == farm['id'] ? 'Active' : 'Switch',
          }).toList(),
      emptyText: 'No additional farms returned yet.',
    ),
    const _SectionData(title: 'Farm switching operations', rows: [
      {
        'name': 'Load farm context',
        'detail': 'GET /api/mobile/farm-context returns active farm and accessible farms.',
        'meta': 'Used by the switcher',
        'value': 'GET',
      },
      {
        'name': 'Switch farm',
        'detail': 'POST /api/mobile/farm-context refreshes the JWT for the selected farm.',
        'meta': 'Replace stored token after success',
        'value': 'POST',
      },
      {
        'name': 'Logout security',
        'detail': 'Clears secure storage token, profile, farm context and subscription state.',
        'meta': 'flutter_secure_storage',
        'value': 'Secure',
      },
    ]),
  ]);
}

List<Map<String, String>> _defaultReportRows() {
  const names = [
    'Farm summary',
    'Crop records',
    'Finance transactions',
    'Cashflow by month',
    'Yield records',
    'Crop profitability',
    'Field profitability',
    'Input efficiency',
    'Livestock profitability',
    'Overhead allocation',
    'Break-even',
    'Crop performance',
    'Yield trends',
    'Season comparison',
    'Traceability',
    'Funder dashboard',
    'Credit readiness',
    'Custom report builder',
    'Record pack export',
    'Mobile report export',
  ];
  return names.map((name) => {
        'name': name,
        'detail': 'Selectable PDF export section',
        'meta': 'Uses filters before export',
        'value': 'PDF',
      }).toList();
}

class _HeaderCard extends StatelessWidget {
  final _FunctionSpec spec;

  const _HeaderCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 20,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          FarmioColors.slate800.withValues(alpha: 0.94),
          spec.color.withValues(alpha: 0.64),
        ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: spec.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(spec.icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              spec.description,
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<_Metric> metrics;

  const _MetricGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 68,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return FarmioCard(
          padding: const EdgeInsets.all(12),
          radius: 16,
          child: Row(
            children: [
              Icon(metric.icon, color: metric.color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(metric.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: metric.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        )),
                    Text(metric.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: FarmioColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final List<_FunctionAction> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 52,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return FarmioCard(
          padding: EdgeInsets.zero,
          radius: 16,
          onTap: () => context.push(action.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(action.icon, color: FarmioColors.primary, size: 21),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FarmioColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: FarmioColors.textMuted, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DataSection extends StatelessWidget {
  final _SectionData section;

  const _DataSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return FarmioCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: const TextStyle(
                color: FarmioColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              )),
          const SizedBox(height: 10),
          if (section.rows.isEmpty)
            Text(section.emptyText,
                style: const TextStyle(color: FarmioColors.textMuted))
          else
            ...section.rows.map((row) => _DataRow(row: row)),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final Map<String, String> row;

  const _DataRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final route = row['route'];
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FarmioColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  )),
              if ((row['detail'] ?? '').isNotEmpty)
                Text(row['detail']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: FarmioColors.textSecond)),
              if ((row['meta'] ?? '').isNotEmpty)
                Text(row['meta']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: FarmioColors.textMuted,
                      fontSize: 12,
                    )),
            ],
          ),
        ),
        if ((row['value'] ?? '').isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(row['value']!,
              style: const TextStyle(
                color: FarmioColors.textPrimary,
                fontWeight: FontWeight.w900,
              )),
        ],
        if (route != null) ...[
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: FarmioColors.textMuted),
        ],
      ],
    );

    if (route == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: content,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: FarmioColors.danger, size: 42),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: FarmioColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is List) {
    return value.whereType<Map>().map((item) {
      return <String, dynamic>{
        for (final entry in item.entries) '${entry.key}': entry.value,
      };
    }).toList();
  }
  return const [];
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries) '${entry.key}': entry.value,
    };
  }
  return const {};
}

double _num(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

Object? _nested(Map<String, dynamic> map, String parent, String child) {
  final value = map[parent];
  if (value is Map) return value[child];
  return null;
}

String _dateText(Object? value) {
  if (value == null) return '';
  final parsed = DateTime.tryParse('$value');
  return parsed == null ? '' : Fmt.date(parsed);
}

String _messageFor(Object? error) {
  if (error is DioException && error.error is ApiError) {
    final apiError = error.error as ApiError;
    return apiError.statusCode == null
        ? apiError.message
        : '${apiError.message} (${apiError.statusCode})';
  }
  if (error is DioException) {
    return error.message ?? 'Request failed';
  }
  return '${error ?? 'Request failed'}';
}
