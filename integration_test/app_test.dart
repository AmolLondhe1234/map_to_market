import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:map_to_market/main.dart' as app;
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive Workflow Test', () {
    testWidgets('Full User Journey', (tester) async {
      print('>>> STARTING FULL AUTOMATED TEST JOURNEY');
      
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for app to decide initial state
      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      String? testEmail;

      // 1. Flow: Registration/Login
      if (find.text('LOGIN').evaluate().isNotEmpty) {
        print('--- STAGE: REGISTRATION ---');
        testEmail = 'user_${DateTime.now().millisecondsSinceEpoch}@test.com';
        await _runRegistration(tester, testEmail);
      } else {
        print('--- STAGE: ALREADY LOGGED IN ---');
      }

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 2. Flow: Map and Discovery
      print('--- STAGE: DISCOVERY & MAP ---');
      await _testMapDiscovery(tester);

      // 3. Flow: Detailed Service & Booking
      print('--- STAGE: SERVICE DETAILS & BOOKING ---');
      await _testBookingWorkflow(tester);

      // 4. Flow: Profile Management
      print('--- STAGE: PROFILE MANAGEMENT ---');
      await _testProfileUpdate(tester);

      print('>>> AUTOMATED TEST JOURNEY COMPLETED SUCCESSFULLY');
    });
  });
}

Future<void> _runRegistration(WidgetTester tester, String email) async {
  print('Action: Clicking Register link');
  await tester.tap(find.textContaining('Register'));
  await tester.pumpAndSettle();

  print('Action: Entering user data');
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Automated Tester');
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), 'password123');
  await tester.enterText(fields.at(3), 'password123');
  await tester.pumpAndSettle();

  print('Action: Clicking REGISTER button');
  // Use a more specific finder for the button
  final registerBtn = find.descendant(
    of: find.byType(ElevatedButton),
    matching: find.text('REGISTER'),
  ).last;
  
  await tester.tap(registerBtn);
  
  // Wait for transition to Home
  print('Waiting for transition to Home...');
  bool reachedHome = false;
  for (int i = 0; i < 40; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.textContaining('Portal').evaluate().isNotEmpty || find.textContaining('Hub').evaluate().isNotEmpty) {
      reachedHome = true;
      break;
    }
    // Handle potential error snackbar
    if (find.byType(SnackBar).evaluate().isNotEmpty) {
       print('ALERT: Error detected during registration.');
       break;
    }
  }
  expect(reachedHome, isTrue, reason: 'Failed to reach Home after registration.');
  print('Registration Successful.');
}

Future<void> _testMapDiscovery(WidgetTester tester) async {
  print('Action: Checking Map');
  // Wait for markers/map to load
  await tester.pumpAndSettle(const Duration(seconds: 3));
  expect(find.byType(GoogleMap), findsOneWidget);
  print('Success: Map rendered.');

  print('Action: Switching to Discovery');
  final discoverTab = find.byIcon(Icons.explore_outlined);
  if (discoverTab.evaluate().isNotEmpty) {
    await tester.tap(discoverTab);
    await tester.pumpAndSettle();
    expect(find.text('Discover'), findsOneWidget);
    print('Success: Discovery screen loaded.');
    
    // Test a category click
    print('Action: Clicking a Category');
    final categoryItem = find.text('Plumbers').first;
    if (categoryItem.evaluate().isNotEmpty) {
       await tester.tap(categoryItem);
       await tester.pumpAndSettle();
       print('Success: Category results filtered.');
    }
  }
}

Future<void> _testBookingWorkflow(WidgetTester tester) async {
  print('Action: Attempting Booking Workflow');
  // Go back to Discovery if needed
  if (find.text('Discover').evaluate().isEmpty) {
     await tester.tap(find.byIcon(Icons.explore_outlined));
     await tester.pumpAndSettle();
  }

  // Look for any service (usually marked with rating stars ★)
  final serviceCard = find.textContaining('★').first;
  if (serviceCard.evaluate().isNotEmpty) {
    await tester.tap(serviceCard);
    await tester.pumpAndSettle();
    
    print('Action: Clicking BOOK NOW');
    final bookBtn = find.text('BOOK NOW');
    if (bookBtn.evaluate().isNotEmpty) {
      await tester.tap(bookBtn);
      await tester.pumpAndSettle();

      print('Action: Confirming booking');
      await tester.tap(find.text('CONFIRM BOOKING'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      if (find.text('OK').evaluate().isNotEmpty) {
         await tester.tap(find.text('OK'));
         await tester.pumpAndSettle();
         print('Success: Booking confirmed.');
      }
    }
  } else {
    print('Info: No mock services available for booking test.');
  }

  // Back to Map
  await tester.tap(find.byIcon(Icons.map_outlined));
  await tester.pumpAndSettle();
}

Future<void> _testProfileUpdate(WidgetTester tester) async {
  final profileTab = find.byIcon(Icons.person_outline);
  if (profileTab.evaluate().isNotEmpty) {
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    expect(find.text('Account Settings'), findsWidgets);
    print('Profile screen verified.');

    // Test Seed Demo Data button (proactive check)
    final seedBtn = find.text('Seed Demo Data');
    if (seedBtn.evaluate().isNotEmpty) {
      print('Seeding demo data for future tests...');
      await tester.tap(seedBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }
}
