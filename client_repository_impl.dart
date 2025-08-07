import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';
import 'package:flutter_application_1/core/models/client_model.dart';
import 'package:flutter_application_1/features/clients/domain/client_repository.dart';

class ClientRepositoryImpl implements IClientRepository {
  final FirebaseFirestore _firestore;

  ClientRepositoryImpl(this._firestore);

  CollectionReference<Client> _clientsRef(String tenantId) {
    return _firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('clients')
        .withConverter<Client>(
          fromFirestore: (snapshot, _) => Client.fromFirestore(snapshot),
          toFirestore: (client, _) => client.toFirestore(),
        );
  }

  @override
  Future<void> addClient({
    required String tenantId,
    required Client client,
  }) async {
    try {
      await _clientsRef(tenantId).add(client);
    } catch (e) {
      throw DataException('Erro ao adicionar cliente: $e');
    }
  }

  // ... Implementar os outros métodos (getClients, updateClient, deleteClient) seguindo o mesmo padrão ...

  @override
  Future<List<Client>> getClients({required String tenantId}) async {
    final snapshot = await _clientsRef(tenantId).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ... (implementações de update e delete omitidas por brevidade)
}
