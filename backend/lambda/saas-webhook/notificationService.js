const AWS = require('aws-sdk');
const sns = new AWS.SNS();
const ses = new AWS.SES();

class NotificationService {
    
    static async sendPaymentConfirmation(empresaId, amount, transactionId) {
        try {
            // Email via SES
            await this.sendEmailNotification(empresaId, amount, transactionId);
            
            // WhatsApp via SNS (futuro)
            // await this.sendWhatsAppNotification(empresaId, amount);
            
            console.log(`Notificações enviadas para empresa ${empresaId}`);
        } catch (error) {
            console.error('Erro ao enviar notificações:', error);
        }
    }
    
    static async sendEmailNotification(empresaId, amount, transactionId) {
        const params = {
            Source: 'noreply@agendafacil.com',
            Destination: {
                ToAddresses: ['admin@agendafacil.com'] // Substituir por email da empresa
            },
            Message: {
                Subject: {
                    Data: '✅ Pagamento PIX Confirmado - AgendaFácil SaaS'
                },
                Body: {
                    Html: {
                        Data: `
                            <h2>🎉 Pagamento Confirmado!</h2>
                            <p><strong>Empresa:</strong> ${empresaId}</p>
                            <p><strong>Valor:</strong> R$ ${amount.toFixed(2)}</p>
                            <p><strong>Transação:</strong> ${transactionId}</p>
                            <p><strong>Data:</strong> ${new Date().toLocaleString('pt-BR')}</p>
                            <hr>
                            <p>Sua mensalidade foi processada com sucesso!</p>
                            <p><small>AgendaFácil SaaS - Sistema de Gestão</small></p>
                        `
                    }
                }
            }
        };
        
        return ses.sendEmail(params).promise();
    }
    
    static async sendOverdueNotification(empresaId, amount, daysOverdue) {
        const params = {
            Source: 'cobranca@agendafacil.com',
            Destination: {
                ToAddresses: ['admin@agendafacil.com'] // Substituir por email da empresa
            },
            Message: {
                Subject: {
                    Data: '⚠️ Mensalidade em Atraso - AgendaFácil SaaS'
                },
                Body: {
                    Html: {
                        Data: `
                            <h2>⚠️ Mensalidade em Atraso</h2>
                            <p><strong>Empresa:</strong> ${empresaId}</p>
                            <p><strong>Valor:</strong> R$ ${amount.toFixed(2)}</p>
                            <p><strong>Dias em atraso:</strong> ${daysOverdue}</p>
                            <hr>
                            <p>Regularize sua situação para manter o acesso ao sistema.</p>
                            <p><a href="https://agendafacil.com/pagamento">Pagar Agora</a></p>
                        `
                    }
                }
            }
        };
        
        return ses.sendEmail(params).promise();
    }
    
    // Futuro: WhatsApp via API externa
    static async sendWhatsAppNotification(empresaId, amount) {
        // Integração com API do WhatsApp Business
        // Exemplo: Twilio, ChatAPI, etc.
        console.log(`WhatsApp para ${empresaId}: Pagamento R$ ${amount} confirmado`);
    }
}

module.exports = NotificationService;