function formatPixPayload(data) {
    return {
        nome: data.nome || 'Cliente',
        valor: parseFloat(data.valor) || 0,
        cpf: data.cpf?.replace(/\D/g, '') || '',
        email: data.email || '',
        tenantId: data.tenantId || 'default'
    };
}

module.exports = { formatPixPayload };