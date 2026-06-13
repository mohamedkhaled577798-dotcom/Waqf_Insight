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
    await tester.pumpWidget(const App());

    expect(find.text('ديوان الوقف السني العراقي'), findsOneWidget);
    expect(find.text('هيئة إدارة واستثمار أموال الوقف السني'), findsOneWidget);

    // Advance past splash minimum duration so pending timers complete.
    await tester.pump(const Duration(seconds: 5));
  });
}
