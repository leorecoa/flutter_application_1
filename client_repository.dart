import 'package:flutter_application_1/core/models/client_model.dart';

abstract class IClientRepository {
  Future<List<Client>> getClients({required String tenantId});
  Future<void> addClient({required String tenantId, required Client client});
  Future<void> updateClient({required String tenantId, required Client client});
  Future<void> deleteClient({
    required String tenantId,
    required String clientId,
  });
}
