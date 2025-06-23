# Roadmap MVP - SaaS AgendaFácil (30 dias)

## 🎯 Objetivo do MVP
Criar uma versão funcional do SaaS de agendamento em 30 dias, focando nas funcionalidades essenciais para validação do produto no mercado.

## 📅 Cronograma Detalhado

### **Semana 1 (Dias 1-7): Fundação e Autenticação**

#### Dia 1-2: Setup do Projeto
- [x] Configurar projeto Flutter
- [x] Estruturar arquitetura de pastas
- [x] Configurar dependências essenciais
- [x] Setup do ambiente de desenvolvimento

#### Dia 3-4: Sistema de Autenticação
- [ ] Implementar telas de login/registro
- [ ] Configurar AWS Cognito ou Firebase Auth
- [ ] Implementar providers de autenticação
- [ ] Testes de login/logout

#### Dia 5-7: Infraestrutura Backend
- [ ] Configurar DynamoDB/Firestore
- [ ] Criar Lambda functions básicas (CRUD)
- [ ] Configurar API Gateway
- [ ] Implementar middleware de autenticação

**Entregáveis Semana 1:**
- ✅ Usuários podem se cadastrar e fazer login
- ✅ Backend básico funcionando
- ✅ Estrutura do banco de dados criada

---

### **Semana 2 (Dias 8-14): Core Features**

#### Dia 8-9: Gestão de Serviços
- [ ] Tela de cadastro de serviços
- [ ] CRUD de serviços (nome, preço, duração)
- [ ] Validações e tratamento de erros
- [ ] Persistência no banco de dados

#### Dia 10-11: Sistema de Agendamento
- [ ] Tela de agendamentos
- [ ] Calendário de disponibilidade
- [ ] Lógica de horários disponíveis
- [ ] CRUD de agendamentos

#### Dia 12-14: Dashboard Básico
- [ ] Tela principal do profissional
- [ ] Resumo de agendamentos do dia
- [ ] Lista de próximos agendamentos
- [ ] Estatísticas básicas (total de agendamentos, receita)

**Entregáveis Semana 2:**
- ✅ Profissionais podem cadastrar serviços
- ✅ Sistema de agendamento funcional
- ✅ Dashboard com informações básicas

---

### **Semana 3 (Dias 15-21): Área Pública e Pagamentos**

#### Dia 15-16: Link Público de Agendamento
- [ ] Tela pública para clientes
- [ ] Seleção de serviços disponíveis
- [ ] Escolha de data e horário
- [ ] Formulário de dados do cliente

#### Dia 17-18: Sistema de Pagamentos
- [ ] Integração com Stripe ou Mercado Pago
- [ ] Opção de pagamento PIX
- [ ] Opção de pagamento presencial
- [ ] Confirmação de pagamento

#### Dia 19-21: Gestão de Clientes
- [ ] Lista de clientes
- [ ] Histórico de agendamentos por cliente
- [ ] Dados de contato dos clientes
- [ ] Busca e filtros

**Entregáveis Semana 3:**
- ✅ Link público funcional para agendamentos
- ✅ Sistema de pagamentos integrado
- ✅ Gestão básica de clientes

---

### **Semana 4 (Dias 22-28): Integrações e Polimento**

#### Dia 22-23: Integração WhatsApp
- [ ] Configurar API do WhatsApp (Z-API)
- [ ] Mensagens de confirmação automáticas
- [ ] Templates de mensagens
- [ ] Testes de envio

#### Dia 24-25: Sistema de Planos
- [ ] Definir limitações por plano
- [ ] Implementar controle de uso
- [ ] Tela de upgrade de plano
- [ ] Integração com pagamentos recorrentes

#### Dia 26-28: Testes e Deploy
- [ ] Testes de integração
- [ ] Correção de bugs críticos
- [ ] Deploy em produção (AWS/Firebase)
- [ ] Configuração de domínio

**Entregáveis Semana 4:**
- ✅ WhatsApp integrado e funcionando
- ✅ Sistema de planos implementado
- ✅ Aplicação em produção

---

### **Dias 29-30: Validação e Ajustes**
- [ ] Testes com usuários reais
- [ ] Coleta de feedback
- [ ] Ajustes críticos
- [ ] Documentação final

## 🎯 Funcionalidades do MVP

### ✅ Funcionalidades Incluídas
1. **Autenticação**
   - Cadastro e login de profissionais
   - Recuperação de senha

2. **Gestão de Serviços**
   - Cadastrar serviços (nome, preço, duração)
   - Editar e excluir serviços

3. **Sistema de Agendamento**
   - Definir horários de funcionamento
   - Visualizar agenda do dia/semana
   - Confirmar/cancelar agendamentos

4. **Link Público**
   - Link personalizado para cada profissional
   - Interface para clientes agendarem

5. **Pagamentos Básicos**
   - PIX via Mercado Pago
   - Pagamento presencial

6. **WhatsApp Básico**
   - Confirmação de agendamento
   - Lembrete 1 dia antes

7. **Dashboard Simples**
   - Agendamentos do dia
   - Receita do mês
   - Total de clientes

### ❌ Funcionalidades Pós-MVP
1. **Recursos Avançados**
   - Relatórios detalhados
   - Analytics avançados
   - Múltiplos profissionais por conta

2. **Integrações Avançadas**
   - Google Calendar
   - Múltiplas formas de pagamento
   - WhatsApp Business API oficial

3. **Recursos Premium**
   - Personalização de marca
   - API para terceiros
   - Backup automático

## 🛠️ Stack Tecnológica MVP

### Frontend
- **Flutter Web**: Interface principal
- **Provider**: Gerenciamento de estado
- **Go Router**: Navegação
- **Material Design 3**: UI/UX

### Backend
- **AWS Lambda**: Lógica de negócio
- **DynamoDB**: Banco de dados NoSQL
- **API Gateway**: Endpoints REST
- **SQS**: Filas para WhatsApp

### Integrações
- **Z-API**: WhatsApp (mais barato para MVP)
- **Mercado Pago**: Pagamentos PIX
- **AWS SES**: E-mails transacionais

## 📊 Métricas de Sucesso MVP

### Métricas Técnicas
- [ ] Tempo de resposta < 2s
- [ ] Uptime > 99%
- [ ] Zero bugs críticos
- [ ] 100% das funcionalidades testadas

### Métricas de Negócio
- [ ] 10 profissionais cadastrados
- [ ] 100 agendamentos realizados
- [ ] 90% de satisfação dos usuários
- [ ] 5 conversões para plano pago

## 🚀 Plano de Lançamento

### Pré-Lançamento (Dia 25-28)
- [ ] Testes com 3-5 profissionais beta
- [ ] Correção de bugs reportados
- [ ] Ajustes de UX baseados no feedback

### Lançamento Soft (Dia 29)
- [ ] Disponibilizar para 20 profissionais
- [ ] Monitorar métricas em tempo real
- [ ] Suporte ativo via WhatsApp

### Lançamento Público (Dia 30)
- [ ] Abrir cadastros para todos
- [ ] Campanha de marketing digital
- [ ] Coleta ativa de feedback

## 💰 Modelo de Monetização MVP

### Plano Gratuito
- 5 agendamentos/mês
- 1 serviço cadastrado
- WhatsApp manual

### Plano Básico (R$ 19,90/mês)
- 50 agendamentos/mês
- Serviços ilimitados
- WhatsApp automático
- Suporte por e-mail

### Plano Profissional (R$ 39,90/mês)
- Agendamentos ilimitados
- Relatórios básicos
- Link personalizado
- Suporte prioritário

## 🔄 Próximos Passos Pós-MVP

### Mês 2: Otimização
- Melhorar performance
- Adicionar relatórios
- Integrar Google Calendar
- Sistema de avaliações

### Mês 3: Expansão
- App mobile nativo
- Múltiplos profissionais
- API para terceiros
- Programa de afiliados

### Mês 4-6: Escala
- Integrações avançadas
- IA para otimização de agenda
- Marketplace de profissionais
- Expansão internacional