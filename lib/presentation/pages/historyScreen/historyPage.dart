import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../common/rssi_helper.dart';
import '../../../injection.dart' as di;
import 'blocHistory/history_bloc.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.locator<HistoryBloc>()..add(HistoryLoadData()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Riwayat Perangkat'),
          actions: [
            BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                final hasData =
                    state is HistoryLoaded && state.devices.isNotEmpty;
                return IconButton(
                  tooltip: 'Hapus semua',
                  icon: Icon(Icons.delete_outline),
                  onPressed: hasData ? () => _confirmClear(context) : null,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) => _body(state),
        ),
      ),
    );
  }

  Widget _body(HistoryState state) {
    if (state is HistoryLoading || state is HistoryInitial) {
      return Center(child: CircularProgressIndicator());
    }
    if (state is HistoryError) {
      return Center(
        child: Text(
          'Gagal memuat riwayat: ${state.message}',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final devices = state is HistoryLoaded ? state.devices : [];
    if (devices.isEmpty) {
      return Center(
        child: Text(
          'Belum ada riwayat perangkat.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final formatter = DateFormat('dd MMM yyyy, HH:mm:ss');

    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (_, _) => Divider(height: 1),
      itemBuilder: (context, index) {
        final d = devices[index];
        return ListTile(
          leading: Icon(Icons.bluetooth, color: RssiHelper.color(d.rssi)),
          title: Text(d.name),
          subtitle: Text('${d.id}\nTerakhir: ${formatter.format(d.lastSeen)}'),
          isThreeLine: true,
          trailing: Text('${d.rssi} dBm'),
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bloc = context.read<HistoryBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Riwayat'),
        content: Text('Hapus semua riwayat perangkat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(HistoryClearData());
  }
}
