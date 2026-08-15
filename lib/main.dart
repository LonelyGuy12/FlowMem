import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/dashboard_provider.dart';

void main() {
  runApp(const FlowMemApp());
}

class FlowMemApp extends StatelessWidget {
  const FlowMemApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Vercel AMOLED Color Scheme
    const vercelBlack = Color(0xFF000000);
    const vercelGray = Color(0xFF1A1A1A);
    const vercelBorder = Color(0xFF2A2A2A);
    const vercelAccent = Color(0xFF0070F3);
    const vercelSuccess = Color(0xFF0DBC79);
    const vercelError = Color(0xFFE00);
    const vercelWarning = Color(0xFFF5A623);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'FlowMem',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: vercelBlack,
          primaryColor: vercelAccent,
          colorScheme: const ColorScheme.dark(
            background: vercelBlack,
            surface: vercelGray,
            primary: vercelAccent,
            secondary: vercelSuccess,
            error: vercelError,
            onBackground: Colors.white,
            onSurface: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
            displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          cardTheme: CardThemeData(
            color: vercelGray,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: vercelBorder, width: 1),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: vercelBlack,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          dividerTheme: const DividerThemeData(
            color: vercelBorder,
            thickness: 1,
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
