import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'presentation/pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
  runApp(const JustChatApp());
}

class JustChatApp extends StatelessWidget {
  const JustChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Injection.authBloc,
      child: MaterialApp(
        title: 'Just Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A8FFF),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
