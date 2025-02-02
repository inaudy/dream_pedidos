import 'package:dream_pedidos/presentation/blocs/refill_history_bloc/refill_history_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_pedidos/data/models/refill_history_item.dart';
import 'package:intl/intl.dart';

class RefillHistoryPage extends StatelessWidget {
  const RefillHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<RefillHistoryBloc>().add(LoadRefillHistoryEvent());
    return Scaffold(
      body: BlocBuilder<RefillHistoryBloc, RefillHistoryState>(
        builder: (context, state) {
          if (state is RefillHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RefillHistoryError) {
            return Center(child: Text(state.message));
          } else if (state is RefillHistoryLoaded) {
            return _buildHistoryList(context, state.historyItems);
          }
          return const Center(child: Text('No hay historial disponible.'));
        },
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context, List<RefillHistoryItem> historyItems) {
    if (historyItems.isEmpty) {
      return const Center(child: Text('No hay historial de reposición.'));
    }

    return ListView.builder(
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final history = historyItems[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: Text(
              NumberFormat('#.#').format(history.refillQuantity),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            title: Text(history.itemName,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(history.refillDate)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () {
                context
                    .read<RefillHistoryBloc>()
                    .add(RevertRefillEvent(history.id));
              },
            ),
          ),
        );
      },
    );
  }
}
