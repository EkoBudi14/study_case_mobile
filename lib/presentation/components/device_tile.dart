import 'package:flutter/material.dart';

import '../../common/rssi_helper.dart';
import '../../data/sources/model/bleDeviceModel.dart';

class DeviceTile extends StatelessWidget {
  final BleDeviceModel device;
  final VoidCallback onTap;

  const DeviceTile({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = RssiHelper.color(device.rssi);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.bluetooth, color: color),
        ),
        title: Text(
          device.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.id, style: TextStyle(fontSize: 12)),
            SizedBox(height: 2),
            Text(
              '${RssiHelper.label(device.rssi)} • ${RssiHelper.rangeText(device.rssi)}',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${device.rssi} dBm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '~${RssiHelper.metersText(device.rssi)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
