const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

/**
 * Gatilho executado sempre que um novo usuário é criado no Firebase Auth.
 * Cria um documento correspondente na coleção 'users' do Firestore.
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
    functions.logger.info(`Novo usuário criado: ${user.uid}, Email: ${user.email}`);

    const newUserDoc = {
        uid: user.uid,
        email: user.email,
        name: user.displayName || "Usuário",
        phoneNumber: user.phoneNumber || null,
        profilePictureUrl: user.photoURL || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        tenants: {}, // O mapa de tenants começa vazio.
    };

    try {
        await db.collection("users").doc(user.uid).set(newUserDoc);
        functions.logger.info(`Documento criado para o usuário ${user.uid} no Firestore.`);
    } catch (error) {
        functions.logger.error(`Erro ao criar documento para o usuário ${user.uid}:`, error);
    }
});

/**
 * Função agendada para ser executada a cada 15 minutos.
 * Busca por agendamentos que precisam de lembretes e envia notificações via FCM.
 */
exports.scheduledReminders = functions.pubsub.schedule("every 15 minutes").onRun(async (context) => {
    functions.logger.info("Executando verificação de lembretes de agendamento.");

    const now = admin.firestore.Timestamp.now();
    // Exemplo: Enviar lembrete para agendamentos que ocorrerão nas próximas 24 horas.
    const reminderWindowStart = now;
    const reminderWindowEnd = new admin.firestore.Timestamp(now.seconds + 24 * 60 * 60, now.nanoseconds);

    // 1. Busca todos os tenants
    const tenantsSnapshot = await db.collection("tenants").get();

    for (const tenantDoc of tenantsSnapshot.docs) {
        // 2. Para cada tenant, busca os agendamentos na janela de tempo
        const appointmentsSnapshot = await tenantDoc.ref.collection("appointments")
            .where("date", ">=", reminderWindowStart)
            .where("date", "<=", reminderWindowEnd)
            .where("reminderSent", "==", false) // Evita enviar lembretes duplicados
            .get();

        for (const appointmentDoc of appointmentsSnapshot.docs) {
            const appointment = appointmentDoc.data();
            // 3. TODO: Buscar o FCM token do cliente/usuário associado ao agendamento.
            // 4. TODO: Montar e enviar a notificação via admin.messaging().send().
            // 5. TODO: Atualizar o campo 'reminderSent' para true no documento do agendamento.
            functions.logger.info(`Lembrete a ser enviado para o agendamento ${appointmentDoc.id} do tenant ${tenantDoc.id}`);
        }
    }

    return null;
});