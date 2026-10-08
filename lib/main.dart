import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// This imports the EXISTING FlutterFire-generated file. Never replace it.
import 'firebase_options.dart';
import 'core/app_settings.dart';
import 'theme/evently_theme.dart';
import 'services/auth_service.dart';
import 'screens/auth_screens.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_shell.dart';
import 'widgets/evently_brand.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  Object? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    firebaseError = error;
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  runApp(EventlyApp(firebaseError: firebaseError));
}

class EventlyApp extends StatelessWidget {
  const EventlyApp({super.key, this.firebaseError});
  final Object? firebaseError;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppSettings.instance,
    builder: (context, child) => MaterialApp(
      title: 'Evently',
      debugShowCheckedModeBanner: false,
      theme: EventlyTheme.light,
      darkTheme: EventlyTheme.dark,
      themeMode: AppSettings.instance.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: firebaseError == null
          ? const _EntryGate()
          : _FirebaseFailure(error: firebaseError!),
    ),
  );
}

class _FirebaseFailure extends StatelessWidget {
  const _FirebaseFailure({required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const EventlyBrand(size: 31),
        const SizedBox(height: 24),
        const Icon(Icons.cloud_off_outlined, size: 50),
        const SizedBox(height: 10),
        const Text('Unable to start Firebase', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        SelectableText(error.toString(), textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11)),
      ]),
    )),
  );
}

class _EntryGate extends StatefulWidget {
  const _EntryGate();
  @override
  State<_EntryGate> createState() => _EntryGateState();
}

class _EntryGateState extends State<_EntryGate> {
  bool showingSplash = true;
  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onSettingsChanged);
    Future<void>.delayed(const Duration(milliseconds: 1050)).then((_) {
      if (mounted) setState(() => showingSplash = false);
    });
  }
  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showingSplash) return const SplashScreen();
    if (!AppSettings.instance.onboardingCompleted) {
      return const OnboardingScreen();
    }
    return StreamBuilder<User?>(
      stream: AuthService.instance.changes,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Scaffold(body: Center(
          child: Text('Authentication unavailable: ${snapshot.error}'),
        ));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data == null ? const AuthScreen() : const HomeShell();
      },
    );
  }
}
