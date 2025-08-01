import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/appointment_model.dart';
import '../application/appointment_providers.dart';
import '../utils/appointment_status_utils.dart';

/// Widget de barra de filtros para agendamentos
class AppointmentFilterBar extends ConsumerWidget {
  final TextEditingController searchController;

  const AppointmentFilterBar({super.key, required this.searchController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.watch(appointmentFiltersProvider);
    final currentStatus = currentFilters['status'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Filtro de Status
            _buildStatusFilter(context, ref, currentFilters, currentStatus),
            const SizedBox(width: 8),

            // Filtro de Data
            _buildDateFilter(context, ref, currentFilters),
            const SizedBox(width: 8),

            // Botão para limpar filtros
            if (currentFilters.isNotEmpty || searchController.text.isNotEmpty)
              _buildClearFiltersButton(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> currentFilters,
    String? currentStatus,
  ) {
    return PopupMenuButton<String?>(
      onSelected: (status) {
        final newFilters = Map<String, dynamic>.from(currentFilters);
        if (status == null) {
          newFilters.remove('status');
        } else {
          newFilters['status'] = status;
        }
        ref.read(appointmentFiltersProvider.notifier).state = newFilters;
      },
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('Todos os Status')),
        ...AppointmentStatus.values.map(
          (s) => PopupMenuItem(
            value: s.name,
            child: Text(AppointmentStatusUtils.getStatusText(s)),
          ),
        ),
      ],
      child: Chip(
        avatar: const Icon(Icons.filter_list, size: 16),
        label: Text(
          currentStatus != null
              ? AppointmentStatusUtils.getStatusText(
                  AppointmentStatus.values.byName(currentStatus),
                )
              : 'Status',
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
    );
  }

  Widget _buildDateFilter(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> currentFilters,
  ) {
    if (currentFilters.containsKey('date')) {
      return InputChip(
        label: Text(
          'Data: ${DateFormat('dd/MM/yyyy').format(currentFilters['date'])}',
        ),
        onDeleted: () {
          final newFilters = Map<String, dynamic>.from(currentFilters);
          newFilters.remove('date');
          ref.read(appointmentFiltersProvider.notifier).state = newFilters;
        },
      );
    } else {
      return ActionChip(
        avatar: const Icon(Icons.calendar_today, size: 16),
        label: const Text('Selecionar Data'),
        onPressed: () => _selectDate(context, ref, currentFilters),
      );
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> currentFilters,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      final newFilters = Map<String, dynamic>.from(currentFilters);
      newFilters['date'] = selectedDate;
      ref.read(appointmentFiltersProvider.notifier).state = newFilters;
    }
  }

  Widget _buildClearFiltersButton(WidgetRef ref) {
    return TextButton.icon(
      icon: const Icon(Icons.clear_all),
      label: const Text('Limpar Filtros'),
      onPressed: () {
        ref.read(appointmentFiltersProvider.notifier).state = {};
        searchController.clear();
        ref.read(searchTermProvider.notifier).state = '';
      },
    );
  }
}
