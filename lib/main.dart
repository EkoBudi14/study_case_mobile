import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection.dart' as di;
import 'presentation/pages/scannerScreen/blocScanner/scanner_bloc.dart';
import 'presentation/pages/scannerScreen/scannerPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => di.locator<ScannerBloc>())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BLE Proximity Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: _AppLifecycleWatcher(child: ScannerPage()),
      ),
    );
  }
}

class _AppLifecycleWatcher extends StatefulWidget {
  final Widget child;
  const _AppLifecycleWatcher({required this.child});

  @override
  State<_AppLifecycleWatcher> createState() => _AppLifecycleWatcherState();
}

class _AppLifecycleWatcherState extends State<_AppLifecycleWatcher>
    with WidgetsBindingObserver {
  bool _wasScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<ScannerBloc>();
    final current = bloc.state;
    final isScanning = current is ScannerUpdated && current.isScanning;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (isScanning) {
        _wasScanning = true;
        bloc.add(ScannerStopPressed());
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasScanning) {
        _wasScanning = false;
        bloc.add(ScannerStartPressed());
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
