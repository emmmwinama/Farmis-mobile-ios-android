import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/shared/widgets/agri_vault_shell.dart';

void main() {
  test('Today is the default for unmatched/root locations', () {
    expect(tabIndexForLocation('/dashboard'), 0);
    expect(tabIndexForLocation('/profile'), 0);
    expect(tabIndexForLocation('/documents'), 0);
    expect(tabIndexForLocation('/import'), 0);
    expect(tabIndexForLocation('/notifications'), 0);
  });

  test('Capture tab covers /capture', () {
    expect(tabIndexForLocation('/capture'), 1);
  });

  test('Farm tab covers fields/crops/activities/field-map/livestock/equipment/employees', () {
    for (final route in [
      '/farm', '/fields', '/field-map', '/crops', '/activities',
      '/livestock', '/livestock-detail', '/equipment', '/employees',
    ]) {
      expect(tabIndexForLocation(route), 2, reason: route);
    }
  });

  test('Money tab covers finance/inventory/credit-score', () {
    for (final route in ['/money', '/finance', '/inventory', '/credit-score']) {
      expect(tabIndexForLocation(route), 3, reason: route);
    }
  });

  test('Reports tab covers reports/records/traceability/compliance/report-builder/weather/seasons/templates', () {
    for (final route in [
      '/reports', '/records', '/traceability', '/compliance',
      '/report-builder', '/weather', '/seasons', '/templates',
    ]) {
      expect(tabIndexForLocation(route), 4, reason: route);
    }
  });

  test('sub-routes resolve via their parent prefix', () {
    expect(tabIndexForLocation('/fields/some-id'), 2);
    expect(tabIndexForLocation('/reports/detail'), 4);
  });
}
