import 'package:flutter_test/flutter_test.dart';
import 'package:just_chat/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const JustChatApp());

    expect(find.text('Log in to Chat'), findsOneWidget);
    expect(find.text('Welcome back, you\'ve been missed!'), findsOneWidget);
  });
}
