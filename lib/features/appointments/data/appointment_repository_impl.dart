import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/features/appointments/domain/appointment_repository.dart';

/// Implementação do [IAppointmentRepository] usando o Cloud Firestore.
class AppointmentRepositoryImpl implements IAppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepositoryImpl(this._firestore);

  /// Retorna a referência para a subcoleção de agendamentos de um tenant específico.
  CollectionReference<Appointment> _appointmentsRef(String tenantId) {
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('appointments')
        .withConverter<Appointment>(
          fromFirestore: (snapshot, _) => Appointment.fromFirestore(snapshot),
          toFirestore: (appointment, _) => appointment.toFirestore(),
        );
  }

  @override
  Future<void> addAppointment(
      {required String tenantId, required Appointment appointment}) async {
    try {
      await _appointmentsRef(tenantId).add(appointment);
    } catch (e) {
      throw DataException('Erro ao adicionar agendamento: $e');
    }
  }

  @override
  Future<void> deleteAppointment(
      {required String tenantId, required String appointmentId}) async {
    try {
      await _appointmentsRef(tenantId).doc(appointmentId).delete();
    } catch (e) {
      throw DataException('Erro ao deletar agendamento: $e');
    }
  }

  @override
  Future<List<Appointment>> getAppointments({required String tenantId}) async {
    // Implementação de exemplo. Adicionar filtros, paginação, etc.
    final snapshot = await _appointmentsRef(tenantId).orderBy('date').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> updateAppointment(
      {required String tenantId, required Appointment appointment}) async {
    try {
      await _appointmentsRef(tenantId)
          .doc(appointment.id)
          .update(appointment.toFirestore());
    } catch (e) {
      throw DataException('Erro ao atualizar agendamento: $e');
    }
  }
}
