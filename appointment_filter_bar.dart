import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/appointments/presentation/providers/appointment_providers.dart';

class AppointmentFilterBar extends ConsumerStatefulWidget {
  const AppointmentFilterBar({super.key});

  @override
  ConsumerState<AppointmentFilterBar> createState() =>
      _AppointmentFilterBarState();
}

class _AppointmentFilterBarState extends ConsumerState<AppointmentFilterBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search by Client Name',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            final currentFilters = ref.read(appointmentFilterProvider);
            ref.read(appointmentFilterProvider.notifier).state = {
              ...currentFilters,
              'clientName': value,
            };
          });
        },
      ),
    );
  }
}
