import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/sources/model/bleDeviceModel.dart';
import '../../components/device_tile.dart';
import '../historyScreen/historyPage.dart';
import '../trackerScreen/trackerPage.dart';
import 'blocScanner/scanner_bloc.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  static const _rssiOptions = <int, String>{
    -100: 'Semua sinyal',
    -70: '≥ -70 dBm',
    -80: '≥ -80 dBm',
    -90: '≥ -90 dBm',
  };

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ScannerBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Proximity Tracker'),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            icon: Icon(Icons.history),
            onPressed: () {
              // History doesn't need BLE, so stop scanning to save battery.
              bloc.add(ScannerStopPressed());
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => HistoryPage()));
            },
          ),
        ],
      ),
      body: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          final s = state is ScannerUpdated ? state : null;
          final devices = s?.visibleDevices ?? <BleDeviceModel>[];
          final totalFound = s?.devices.length ?? 0;
          final isScanning = s?.isScanning ?? false;
          final bluetoothOff = s != null && s.bluetoothKnown && !s.bluetoothOn;
          final error = s?.errorMessage;
          final minRssi = s?.minRssi ?? -100;

          return Column(
            children: [
              if (bluetoothOff)
                _banner('Bluetooth mati. Aktifkan untuk memindai.', Colors.red),
              if (error != null) _banner(error, Colors.orange),
              _searchAndFilter(bloc, minRssi),
              _statusRow(totalFound, isScanning),
              Expanded(child: _deviceList(context, devices, isScanning)),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            height: 50,
            child: BlocBuilder<ScannerBloc, ScannerState>(
              builder: (context, state) {
                final isScanning = state is ScannerUpdated
                    ? state.isScanning
                    : false;
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isScanning ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(isScanning ? Icons.stop : Icons.play_arrow),
                  label: Text(isScanning ? 'Stop' : 'Start'),
                  onPressed: () => bloc.add(
                    isScanning ? ScannerStopPressed() : ScannerStartPressed(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _banner(String text, Color color) {
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _searchAndFilter(ScannerBloc bloc, int minRssi) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          _SearchField(bloc: bloc),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, size: 20),
              SizedBox(width: 8),
              Text('Sinyal minimum:'),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: minRssi,
                  items: _rssiOptions.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) bloc.add(ScannerMinRssiChanged(v));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusRow(int count, bool isScanning) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text('Ditemukan $count perangkat'),
          Spacer(),
          if (isScanning)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _deviceList(
    BuildContext context,
    List<BleDeviceModel> devices,
    bool isScanning,
  ) {
    if (devices.isEmpty) {
      return Center(
        child: Text(
          isScanning
              ? 'Memindai perangkat di sekitar...'
              : 'Tekan Start untuk memindai perangkat BLE.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return DeviceTile(
          device: device,
          onTap: () {
            // Picking a device stops the dashboard scan; the detail screen
            // takes over scanning for that one device.
            context.read<ScannerBloc>().add(ScannerStopPressed());
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TrackerPage(device: device)),
            );
          },
        );
      },
    );
  }
}

class _SearchField extends StatefulWidget {
  final ScannerBloc bloc;
  const _SearchField({required this.bloc});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) widget.bloc.add(ScannerStopPressed());
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      onChanged: (state) => widget.bloc.add(ScannerSearchChanged(state)),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Cari nama atau MAC address',
        border: OutlineInputBorder(),
        isDense: true,
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.clear),
              tooltip: 'Hapus',
              onPressed: () {
                _controller.clear();
                widget.bloc.add(ScannerSearchChanged(''));
              },
            );
          },
        ),
      ),
    );
  }
}
