import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/rssi_helper.dart';
import '../../../data/sources/model/bleDeviceModel.dart';
import '../../../injection.dart' as di;
import '../../components/radar_view.dart';
import 'blocTracker/tracker_bloc.dart';

class TrackerPage extends StatelessWidget {
  final BleDeviceModel device;

  const TrackerPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<TrackerBloc>()
        ..add(
          TrackerStarted(
            deviceId: device.id,
            name: device.name,
            initialRssi: device.rssi,
          ),
        ),
      child: BlocBuilder<TrackerBloc, TrackerState>(
        builder: (context, state) {
          final update = state is TrackerUpdate ? state : null;
          final name = update != null && update.name.isNotEmpty
              ? update.name
              : device.name;
          final rssi = update?.rssi ?? device.rssi;
          final secondsAgo = update?.secondsAgo ?? 0;

          final color = RssiHelper.color(rssi);
          final inRange = RssiHelper.categoryOf(rssi) != SignalCategory.lost;

          return Scaffold(
            appBar: AppBar(title: Text(name)),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  RadarView(rssi: rssi, connected: inRange),
                  SizedBox(height: 16),
                  Text(
                    RssiHelper.label(rssi),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Perkiraan jarak: ${RssiHelper.rangeText(rssi)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      _metric('RSSI', '$rssi dBm', color),
                      _metric('Estimasi', RssiHelper.metersText(rssi), color),
                      _metric(
                        'Status',
                        inRange ? 'Dalam jangkauan' : 'Di luar jangkauan',
                        inRange ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        _infoRow('Nama', name),
                        Divider(height: 1),
                        _infoRow('ID (MAC/UUID)', device.id),
                        Divider(height: 1),
                        _infoRow('Terakhir update', '$secondsAgo detik lalu'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
