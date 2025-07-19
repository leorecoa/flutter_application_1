/// Constantes de strings para evitar hardcoding
class AppStrings {
  // Títulos de telas
  static const String appTitle = 'AGENDEMAIS';
  static const String dashboardTitle = 'Dashboard';
  static const String appointmentsTitle = 'Agendamentos';
  static const String clientsTitle = 'Clientes';
  static const String servicesTitle = 'Serviços';
  static const String settingsTitle = 'Configurações';
  static const String notificationsTitle = 'Notificações';
  static const String profileTitle = 'Perfil';
  
  // Mensagens de erro
  static const String errorGeneric = 'Ocorreu um erro. Tente novamente.';
  static const String errorConnection = 'Erro de conexão. Verifique sua internet.';
  static const String errorAuthentication = 'Erro de autenticação. Faça login novamente.';
  static const String errorLoading = 'Erro ao carregar dados.';
  static const String errorSaving = 'Erro ao salvar dados.';
  static const String errorDeleting = 'Erro ao excluir dados.';
  
  // Mensagens de sucesso
  static const String successSaving = 'Dados salvos com sucesso!';
  static const String successDeleting = 'Dados excluídos com sucesso!';
  static const String successAppointment = 'Agendamento realizado com sucesso!';
  static const String successPayment = 'Pagamento realizado com sucesso!';
  
  // Botões
  static const String buttonSave = 'Salvar';
  static const String buttonCancel = 'Cancelar';
  static const String buttonDelete = 'Excluir';
  static const String buttonEdit = 'Editar';
  static const String buttonConfirm = 'Confirmar';
  static const String buttonAdd = 'Adicionar';
  static const String buttonSearch = 'Buscar';
  static const String buttonFilter = 'Filtrar';
  static const String buttonClear = 'Limpar';
  
  // Status de agendamento
  static const String statusScheduled = 'Agendado';
  static const String statusConfirmed = 'Confirmado';
  static const String statusCompleted = 'Concluído';
  static const String statusCancelled = 'Cancelado';
  
  // Formulários
  static const String formName = 'Nome';
  static const String formEmail = 'E-mail';
  static const String formPhone = 'Telefone';
  static const String formAddress = 'Endereço';
  static const String formCity = 'Cidade';
  static const String formState = 'Estado';
  static const String formZipCode = 'CEP';
  static const String formDate = 'Data';
  static const String formTime = 'Hora';
  static const String formService = 'Serviço';
  static const String formPrice = 'Preço';
  static const String formNotes = 'Observações';
  static const String formPassword = 'Senha';
  static const String formConfirmPassword = 'Confirmar Senha';
  
  // Validações
  static const String validationRequired = 'Campo obrigatório';
  static const String validationEmail = 'E-mail inválido';
  static const String validationPhone = 'Telefone inválido';
  static const String validationPassword = 'Senha deve ter pelo menos 8 caracteres';
  static const String validationPasswordMatch = 'Senhas não conferem';
  static const String validationCPF = 'CPF inválido';
  static const String validationCNPJ = 'CNPJ inválido';
  static const String validationZipCode = 'CEP inválido';
  
  // Filtros
  static const String filterAll = 'Todos';
  static const String filterToday = 'Hoje';
  static const String filterWeek = 'Esta Semana';
  static const String filterMonth = 'Este Mês';
  static const String filterCustom = 'Personalizado';
  
  // Notificações
  static const String notificationAppointment = 'Novo agendamento';
  static const String notificationPayment = 'Novo pagamento';
  static const String notificationReminder = 'Lembrete de agendamento';
  static const String notificationCancellation = 'Agendamento cancelado';
  
  // Dashboard
  static const String dashboardRevenue = 'Receita';
  static const String dashboardAppointments = 'Agendamentos';
  static const String dashboardClients = 'Clientes';
  static const String dashboardServices = 'Serviços';
  static const String dashboardToday = 'Hoje';
  static const String dashboardWeek = 'Semana';
  static const String dashboardMonth = 'Mês';
  static const String dashboardYear = 'Ano';
  
  // Mensagens vazias
  static const String emptyAppointments = 'Nenhum agendamento encontrado';
  static const String emptyClients = 'Nenhum cliente encontrado';
  static const String emptyServices = 'Nenhum serviço encontrado';
  static const String emptyNotifications = 'Nenhuma notificação encontrada';
  static const String emptySearch = 'Nenhum resultado encontrado';
  
  // Configurações
  static const String settingsTheme = 'Tema';
  static const String settingsLanguage = 'Idioma';
  static const String settingsNotifications = 'Notificações';
  static const String settingsAccount = 'Conta';
  static const String settingsPrivacy = 'Privacidade';
  static const String settingsHelp = 'Ajuda';
  static const String settingsAbout = 'Sobre';
  static const String settingsLogout = 'Sair';
  
  // Temas
  static const String themeLight = 'Claro';
  static const String themeDark = 'Escuro';
  static const String themeSystem = 'Sistema';
  
  // Idiomas
  static const String languagePortuguese = 'Português';
  static const String languageEnglish = 'Inglês';
  static const String languageSpanish = 'Espanhol';
}