import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/appointment_model.dart';
import '../services/appointments_service_v2.dart';
import 'appointment_details_screen.dart';

/// Widget que carrega os detalhes do agendamento a partir do ID
class AppointmentDetailsLoader extends ConsumerStatefulWidget {
  final String appointmentId;
  
  const AppointmentDetailsLoader({
    super.key,
    required this.appointmentId,
  });

  @override
  ConsumerState<AppointmentDetailsLoader> createState() => _AppointmentDetailsLoaderState();
}

class _AppointmentDetailsLoaderState extends ConsumerState<AppointmentDetailsLoader> {
  final _appointmentsService = AppointmentsServiceV2();
  bool _isLoading = true;
  Appointment? _appointment;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }
  
  Future<void> _loadAppointment() async {
    try {
      setState(() => _isLoading = true);
      
      // Buscar o agendamento pelo ID
      final response = await _appointmentsService.getAppointmentById(widget.appointmentId);
      
      if (response['success'] == true && response['data'] != null) {
        final appointmentData = response['data'];
        final appointment = Appointment.fromDynamoJson(appointmentData);
        
        if (mounted) {
          setState(() {
            _appointment = appointment;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Agendamento não encontrado';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar agendamento: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null || _appointment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error ?? 'Agendamento não encontrado'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/appointments'),
                child: const Text('Voltar para Agendamentos'),
              ),
            ],
          ),
        ),
      );
    }
    
    return AppointmentDetailsScreen(appointment: _appointment!);
  }
}