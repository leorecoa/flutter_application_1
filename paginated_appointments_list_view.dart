import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:flutter_application_1/features/appointments/presentation/widgets/appointment_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginatedAppointmentsListView extends ConsumerStatefulWidget {
  const PaginatedAppointmentsListView({super.key});

  @override
  ConsumerState<PaginatedAppointmentsListView> createState() =>
      _PaginatedAppointmentsListViewState();
}

class _PaginatedAppointmentsListViewState
    extends ConsumerState<PaginatedAppointmentsListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Fetch the next page when the user is 200 pixels from the bottom.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedAppointmentsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedAppointmentsProvider);

    // Handle initial loading and error for the whole list
    if (state.appointments.isEmpty) {
      if (state.fetchState is AsyncLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.fetchState is AsyncError) {
        return Center(child: Text('Error: ${state.fetchState.asError!.error}'));
      }
    }

    // 1. Wrap the ListView with RefreshIndicator.
    return RefreshIndicator(
      // 2. The onRefresh callback must return a Future. We call fetchFirstPage,
      // which handles resetting the state and fetching the new data.
      onRefresh: () =>
          ref.read(paginatedAppointmentsProvider.notifier).fetchFirstPage(),
      child: ListView.builder(
        // 3. Ensure the list is always scrollable to allow pull-to-refresh
        // even when the list content is smaller than the screen.
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: state.appointments.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.appointments.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final appointment = state.appointments[index];
          return AppointmentListItem(appointment: appointment);
        },
      ),
    );
  }
}
