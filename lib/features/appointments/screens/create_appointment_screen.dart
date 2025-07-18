import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/client_model.dart';
import '../../../core/models/service_model.dart';
import '../../../features/clients/services/clients_service.dart';
import '../../../features/services/services/services_service.dart';
import '../services/appointments_service_v2.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final Appointment? appointment;
  const CreateAppointmentScreen({super.key, this.appointment});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _appointmentsServiceV2 = AppointmentsServiceV2();
  final _clientsService = ClientsService();
  final _servicesService = ServicesService();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  List<Client> _clients = [];
  List<Service> _services = [];
  
  Client? _selectedClient;
  Service? _selectedService;

  bool get isEditing => widget.appointment != null;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    if (isEditing) {
      _clientNameController.text = widget.appointment!.clientName;
      _clientPhoneController.text = widget.appointment!.clientPhone;
      _serviceController.text = widget.appointment!.service;
      _priceController.text = widget.appointment!.price.toString();
      _notesController.text = widget.appointment!.notes ?? '';
      _selectedDate = widget.appointment!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.appointment!.dateTime);
    }
  }
  
  Future<void> _loadData() async {
    try {
      final clientsFuture = _clientsService.getClientsList();
      final servicesFuture = _servicesService.getServicesList();
      
      final results = await Future.wait([clientsFuture, servicesFuture]);
      
      setState(() {
        _clients = results[0] as List<Client>;
        _services = results[1] as List<Service>;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Agendamento' : 'Novo Agendamento'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAppointment,
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('SALVAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoadingData
        ? const Center(child: CircularProgressIndicator())
        : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seleção de cliente
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Novo'),
                          onPressed: () => context.push('/clients'),
                        ),
                      ],
                    ),
                  ),
                  if (_clients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhum cliente cadastrado'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<Client>(
                        decoration: const InputDecoration(
                          labelText: 'Selecione um cliente',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedClient,
                        items: _clients.map((client) {
                          return DropdownMenuItem<Client>(
                            value: client,
                            child: Text('${client.name} (${client.phone})'),
                          );
                        }).toList(),
                        onChanged: (client) {
                          setState(() {
                            _selectedClient = client;
                            if (client != null) {
                              _clientNameController.text = client.name;
                              _clientPhoneController.text = client.phone;
                            }
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Cliente',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: _clientPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Seleção de serviço
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Serviço', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Novo'),
                          onPressed: () => context.push('/services'),
                        ),
                      ],
                    ),
                  ),
                  if (_services.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhum serviço cadastrado'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<Service>(
                        decoration: const InputDecoration(
                          labelText: 'Selecione um serviço',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedService,
                        items: _services.map((service) {
                          return DropdownMenuItem<Service>(
                            value: service,
                            child: Text('${service.name} - R\$ ${service.price.toStringAsFixed(2)}'),
                          );
                        }).toList(),
                        onChanged: (service) {
                          setState(() {
                            _selectedService = service;
                            if (service != null) {
                              _serviceController.text = service.name;
                              _priceController.text = service.price.toString();
                            }
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _serviceController,
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        prefixIcon: Icon(Icons.build),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
            const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço (R\$)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty == true ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Data e Horário
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Data e Horário', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Data'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    onTap: _selectDate,
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Horário'),
                    subtitle: Text(_selectedTime.format(context)),
                    onTap: _selectTime,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Observações
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Observações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (isEditing) {
        // Atualizar agendamento existente
        final appointmentData = {
          'clientName': _clientNameController.text,
          'clientPhone': _clientPhoneController.text,
          'service': _serviceController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'appointmentDateTime': appointmentDateTime.toIso8601String(),
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
        };
        
        await _appointmentsServiceV2.updateAppointment(
          widget.appointment!.id,
          appointmentData,
        );
      } else {
        // Criar novo agendamento
        await _appointmentsServiceV2.createAppointmentModel(
          professionalId: 'PROF#default',
          serviceId: _selectedService?.id ?? 'SERV#${_serviceController.text.toLowerCase()}',
          appointmentDateTime: appointmentDateTime,
          clientName: _clientNameController.text,
          clientPhone: _clientPhoneController.text,
          service: _serviceController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          clientId: _selectedClient?.id,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Agendamento atualizado com sucesso!' : 'Agendamento criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar agendamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _serviceController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}