import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/debouncer.dart';
import '../application/appointment_providers.dart';

/// Widget de barra de pesquisa para agendamentos
class AppointmentSearchBar extends ConsumerStatefulWidget {
  const AppointmentSearchBar({super.key});

  @override
  ConsumerState<AppointmentSearchBar> createState() =>
      _AppointmentSearchBarState();
}

class _AppointmentSearchBarState extends ConsumerState<AppointmentSearchBar> {
  final _searchController = TextEditingController();
  final _debounce = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar agendamentos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce.run(() {
      ref.read(searchTermProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchTermProvider.notifier).state = '';
  }
}
