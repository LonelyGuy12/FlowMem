import 'package:flutter/material.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'FlowMem',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.deepPurple,
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurpleAccent,
            secondary: Colors.pinkAccent,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
