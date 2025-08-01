import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/appointments/presentation/controllers/appointment_screen_controller.dart';
import 'package:flutter_application_1/features/appointments/presentation/widgets/appointment_filter_bar.dart';
import 'package:flutter_application_1/features/appointments/presentation/widgets/paginated_appointments_list_view.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  @override
  void initState() {
    super.initState();
    // We trigger the initialization logic when the widget is first inserted
    // into the widget tree.
    // Using a post-frame callback is a safe way to interact with providers
    // in initState. This will also fetch the first page of appointments.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appointmentScreenControllerProvider.notifier)
          .initTenantContext();
      // The first page is now fetched automatically when the paginated provider is initialized.
    });
  }

  @override
  Widget build(BuildContext context) {
    // By watching the controller's state, the UI will automatically rebuild
    // to show loading or error states during initialization.
    final state = ref.watch(appointmentScreenControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      // The `when` method is perfect for handling AsyncValue states.
      body: state.when(
        // Show a loading spinner for the whole screen.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Show an error message and a retry button if initialization fails.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load: $error'),
              ElevatedButton(
                onPressed: () => ref
                    .read(appointmentScreenControllerProvider.notifier)
                    .initTenantContext(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        // If data is loaded successfully, show the main content.
        data: (_) => const Column(
          children: [
            AppointmentFilterBar(),
            Expanded(child: PaginatedAppointmentsListView()),
          ],
        ),
      ),
    );
  }
}
