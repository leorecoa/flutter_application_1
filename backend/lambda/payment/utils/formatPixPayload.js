function formatPixPayload(data) {
    return {
        nome: (data.nome || data.name || 'Cliente').substring(0, 25).toUpperCase(),
        valor: parseFloat(data.valor || data.amount) || 0,
        cpf: (data.cpf || '').replace(/\D/g, ''),
        email: data.email || '',
        tenantId: data.tenantId || 'default',
        description: data.description || 'Pagamento AgendaFácil'
    };
}

function validatePixData(data) {
    const errors = [];
    
    if (!data.nome || data.nome.length < 2) {
        errors.push('Nome é obrigatório e deve ter pelo menos 2 caracteres');
    }
    
    if (!data.valor || data.valor <= 0) {
        errors.push('Valor deve ser maior que zero');
    }
    
    if (data.valor > 99999.99) {
        errors.push('Valor não pode ser maior que R$ 99.999,99');
    }
    
    if (data.email && !isValidEmail(data.email)) {
        errors.push('Email inválido');
    }
    
    return errors;
}

function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

module.exports = { 
    formatPixPayload, 
    validatePixData 
};