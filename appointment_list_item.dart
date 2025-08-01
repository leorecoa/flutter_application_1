import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/features/appointments/presentation/controllers/appointment_screen_controller.dart';

class AppointmentListItem extends ConsumerWidget {
  const AppointmentListItem({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the controller's state to show SnackBars or Dialogs for success/error.
    // This is the recommended way to handle side-effects in response to state changes,
    // as it doesn't run on every rebuild, only when the state value changes.
    ref.listen<AsyncValue<void>>(appointmentScreenControllerProvider, (
      previous,
      next,
    ) {
      // We can show a loading dialog when the state becomes AsyncLoading.
      if (next is AsyncLoading) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }
      // If we were loading and the new state is NOT loading, we pop the dialog.
      if (previous is AsyncLoading && next is! AsyncLoading) {
        Navigator.of(context).pop();
      }
      // If the new state is an error, we show a SnackBar.
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // If the new state is data (success) and we came from a loading state, show success.
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ação concluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    // Watch the state to rebuild the widget, for example, to disable the button.
    final state = ref.watch(appointmentScreenControllerProvider);
    final isLoading = state is AsyncLoading;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(appointment.clientName),
        subtitle: Text(
          '${appointment.serviceName} - ${appointment.dateTime.toLocal()}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          // Disable the button if an operation is already in progress to prevent double taps.
          onPressed: isLoading
              ? null
              : () {
                  // Call the controller method to delete the appointment.
                  // The ref.listen above will handle showing the loading/success/error UI.
                  ref
                      .read(appointmentScreenControllerProvider.notifier)
                      .deleteAppointment(appointment);
                },
        ),
      ),
    );
  }
}
