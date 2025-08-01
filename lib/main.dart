import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/widgets/auth_wrapper.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/appointments/screens/appointment_form_screen.dart';
import 'features/appointments/providers/appointment_provider.dart';
import 'domain/entities/appointment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

/// Widget principal do aplicativo
class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AGENDEMAIS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(child: HomeScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Tela principal do aplicativo (após autenticação)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final appointmentState = ref.watch(appointmentProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AGENDEMAIS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(appointmentProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 100,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bem-vindo ao AGENDEMAIS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Olá, ${user?.name ?? "Usuário"}!',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Estatísticas rápidas
              if (appointmentState.appointments.isNotEmpty) ...[
                const Text(
                  'Resumo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Hoje',
                        ref
                            .read(appointmentProvider.notifier)
                            .getTodayAppointments
                            .length
                            .toString(),
                        Icons.today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Esta Semana',
                        ref
                            .read(appointmentProvider.notifier)
                            .getThisWeekAppointments
                            .length
                            .toString(),
                        Icons.calendar_view_week,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pendentes',
                        ref
                            .read(appointmentProvider.notifier)
                            .getPendingAppointments
                            .length
                            .toString(),
                        Icons.schedule,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        appointmentState.appointments.length.toString(),
                        Icons.list,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // Botões de ação
              const Text(
                'Ações',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AppointmentFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo Agendamento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  // Aqui você pode adicionar navegação para a lista de agendamentos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lista de agendamentos em desenvolvimento'),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Ver Todos os Agendamentos'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  // Aqui você pode adicionar navegação para o calendário
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calendário em desenvolvimento'),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Ver Calendário'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // Lista de agendamentos recentes
              if (appointmentState.appointments.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'Agendamentos Recentes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...appointmentState.appointments
                    .take(5)
                    .map(
                      (appointment) =>
                          _buildAppointmentCard(appointment, context, ref),
                    )
                    .toList(),
              ],

              if (appointmentState.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (appointmentState.error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    appointmentState.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    Appointment appointment,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.status),
          child: Icon(_getStatusIcon(appointment.status), color: Colors.white),
        ),
        title: Text(appointment.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.serviceName),
            Text(
              '${appointment.dateTime.day.toString().padLeft(2, '0')}/${appointment.dateTime.month.toString().padLeft(2, '0')} às ${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Text(
          'R\$ ${appointment.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AppointmentFormScreen(appointment: appointment),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.done;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.noShow:
        return Icons.person_off;
    }
  }
}
