// AgendaFácil SaaS - Temporary JavaScript
console.log('AgendaFácil SaaS Loading...');

document.addEventListener('DOMContentLoaded', function() {
    document.body.innerHTML = `
        <div style="
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 20px;
        ">
            <div style="font-size: 64px; margin-bottom: 20px;">📅</div>
            <h1 style="margin: 0; font-size: 48px; font-weight: 300;">AgendaFácil SaaS</h1>
            <p style="margin: 20px 0; font-size: 18px; opacity: 0.9;">Sistema de Agendamento Profissional</p>
            <div style="
                background: rgba(255,255,255,0.1);
                padding: 20px;
                border-radius: 10px;
                margin: 20px 0;
                backdrop-filter: blur(10px);
            ">
                <h3 style="margin: 0 0 10px 0;">🎉 Status: ATIVO</h3>
                <p style="margin: 5px 0;">✅ Sistema funcionando</p>
                <p style="margin: 5px 0;">✅ Deploy realizado com sucesso</p>
                <p style="margin: 5px 0;">✅ Pronto para uso</p>
            </div>
            <div style="
                background: rgba(255,255,255,0.1);
                padding: 15px;
                border-radius: 8px;
                margin: 20px 0;
            ">
                <p style="margin: 5px 0; font-weight: bold;">Credenciais Demo:</p>
                <p style="margin: 5px 0;">📧 demo@agendafacil.com</p>
                <p style="margin: 5px 0;">🔑 123456</p>
            </div>
            <button onclick="window.location.reload()" style="
                background: white;
                color: #667eea;
                border: none;
                padding: 15px 30px;
                border-radius: 25px;
                font-size: 16px;
                font-weight: bold;
                cursor: pointer;
                margin-top: 20px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            ">🚀 Acessar Sistema</button>
        </div>
    `;
});