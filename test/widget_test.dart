import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/main.dart';

void main() {
  testWidgets('App shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
