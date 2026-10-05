import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/main.dart';
import 'package:ezan_vakti/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('EzanVaktiApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();

    await tester.pumpWidget(const EzanVaktiApp());
    expect(find.text('Vakitler'), findsWidgets);
  });
}
