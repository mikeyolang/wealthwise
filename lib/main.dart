import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wealthwise/core/app_theme.dart';
import 'package:wealthwise/core/app_router.dart';
import 'package:wealthwise/services/notification_service.dart';
import 'package:wealthwise/services/sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize Firebase in background isolate
    await Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await SyncService().syncAll(user.uid);
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  await NotificationService.initialize();
  
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1", 
    "syncTask", 
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(const ProviderScope(child: WealthwiseApp()));
}

class WealthwiseApp extends StatelessWidget {
  const WealthwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wealthwise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
