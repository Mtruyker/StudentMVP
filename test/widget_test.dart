import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:studentlk/main.dart';
import 'package:studentlk/store/app_store.dart';

void main() {
  testWidgets('student can open the MVP cabinet', (tester) async {
    await initializeDateFormatting('ru');
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStore.demo(),
        child: const StudentCabinetApp(),
      ),
    );

    expect(find.text('Личный кабинет студента'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.text('НАТТ'), findsOneWidget);
    expect(find.textContaining('Здравствуйте'), findsOneWidget);
    expect(find.text('Расписание'), findsWidgets);
  });
}
