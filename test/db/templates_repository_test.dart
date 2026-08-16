import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/features/templates/templates_repository.dart';

void main() {
  test('getTemplates returns the bundled seasonal templates', () async {
    final templates = await TemplatesRepository().getTemplates();

    expect(templates, hasLength(3));
    expect(templates.map((t) => t.id),
        containsAll(['maize-main-season', 'soya-commercial', 'groundnut-quality']));
    expect(templates.first.activities, isNotEmpty);
    expect(templates.first.payroll, isNotEmpty);
    expect(templates.first.sales, isNotEmpty);
  });
}
