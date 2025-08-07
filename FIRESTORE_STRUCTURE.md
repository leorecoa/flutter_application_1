# Estrutura de Coleções do Firestore - AgendeMais

Este documento descreve a estrutura de dados multi-tenant utilizada no Cloud Firestore para o projeto AgendeMais. A estrutura foi projetada para garantir isolamento de dados, segurança e escalabilidade.

## Visão Geral

A estratégia principal é aninhar todos os dados específicos de uma empresa (tenant) dentro do documento correspondente a essa empresa. Isso simplifica as regras de segurança e as consultas.

---

### 1. Coleção `users` (Nível Raiz)

Armazena informações globais de cada usuário, independentemente das empresas às quais ele pertence.

**Caminho:** `/users/{userId}`

```json
{
  "uid": "firebase_auth_user_id",
  "name": "Nome do Usuário",
  "email": "usuario@email.com",
  "phoneNumber": "+5511999998888",
  "profilePictureUrl": "url_da_imagem",
  "createdAt": "timestamp",
  "tenants": {
    "tenantId_A": "owner", // Papel do usuário na empresa A
    "tenantId_B": "staff"   // Papel do usuário na empresa B
  }
}
```
- **`tenants`**: Um mapa crucial que associa IDs de empresas (tenants) ao papel (`role`) do usuário naquela empresa. É a chave para as nossas regras de segurança.

---

### 2. Coleção `tenants` (Nível Raiz)

Contém um documento para cada empresa (tenant) cadastrada no sistema.

**Caminho:** `/tenants/{tenantId}`

```json
{
  "name": "Nome da Empresa",
  "ownerId": "userId_do_dono",
  "plan": "premium", // Ex: 'free', 'basic', 'premium'
  "createdAt": "timestamp",
  "features": {
    "maxUsers": 10,
    "maxClients": 500
  }
}
```

#### Subcoleções do Tenant

Todo dado específico de um tenant é armazenado em subcoleções dentro do seu documento.

- **/tenants/{tenantId}/appointments/{appointmentId}**: Agendamentos da empresa.
- **/tenants/{tenantId}/clients/{clientId}**: Clientes da empresa.
- **/tenants/{tenantId}/services/{serviceId}**: Serviços oferecidos pela empresa.
- **/tenants/{tenantId}/staff/{userId}**: Mapeamento de usuários (staff) com permissões específicas para esta empresa.

Essa estrutura garante que, para acessar os agendamentos da "Empresa A", a consulta será sempre `db.collection('tenants').doc('tenantId_A').collection('appointments')`, tornando o isolamento de dados inerente ao design.