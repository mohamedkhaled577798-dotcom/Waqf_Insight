// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:waqf_insight/app.dart';
import 'package:waqf_insight/core/di/injection_container.dart';
import 'package:waqf_insight/core/network/network_info.dart';

void main() {
  setUp(() async {
    // Avoid re-registering if tests run in same process
    if (!sl.isRegistered<NetworkInfo>()) {
      await initDependencies();
    }
  });

  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that the title of the divan is displayed.
    expect(find.text('ديوان الوقف السني العراقي'), findsOneWidget);
  });
}
