import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../core/theme/segments/business_segment.dart';
import '../models/white_label_config.dart';
import '../services/white_label_service.dart';

class WhiteLabelConfigScreen extends StatefulWidget {
  final String tenantId;

  const WhiteLabelConfigScreen({
    required this.tenantId,
    super.key,
  });

  @override
  State<WhiteLabelConfigScreen> createState() => _WhiteLabelConfigScreenState();
}

class _WhiteLabelConfigScreenState extends State<WhiteLabelConfigScreen> {
  bool _isLoading = true;
  late WhiteLabelConfig _config;
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _welcomeTextController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _supportPhoneController = TextEditingController();

  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.blueAccent;
  BusinessSegment _selectedSegment = BusinessSegment.generic;
  double _borderRadius = 8.0;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _logoUrlController.dispose();
    _welcomeTextController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final config = await WhiteLabelService.getConfig(widget.tenantId);

      setState(() {
        _config = config;
        _companyNameController.text = config.companyName;
        _logoUrlController.text = config.logoUrl ?? '';
        _welcomeTextController.text = config.welcomeText ?? '';
        _supportEmailController.text = config.supportEmail ?? '';
        _supportPhoneController.text = config.supportPhone ?? '';
        _primaryColor = config.primaryColor;
        _secondaryColor =
            config.secondaryColor ?? config.segment.secondaryColor;
        _selectedSegment = config.segment;
        _borderRadius = config.borderRadius ?? config.segment.borderRadius;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar configurações: $e')),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedConfig = _config.copyWith(
        companyName: _companyNameController.text,
        logoUrl:
            _logoUrlController.text.isEmpty ? null : _logoUrlController.text,
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        segment: _selectedSegment,
        borderRadius: _borderRadius,
        welcomeText: _welcomeTextController.text.isEmpty
            ? null
            : _welcomeTextController.text,
        supportEmail: _supportEmailController.text.isEmpty
            ? null
            : _supportEmailController.text,
        supportPhone: _supportPhoneController.text.isEmpty
            ? null
            : _supportPhoneController.text,
      );

      await WhiteLabelService.updateConfig(widget.tenantId, updatedConfig);

      setState(() {
        _config = updatedConfig;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas com sucesso')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar configurações: $e')),
        );
      }
    }
  }

  void _showColorPicker(Color initialColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor = initialColor;

        return AlertDialog(
          title: const Text('Selecione uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.of(context).pop();
              },
              child: const Text('Selecionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de White Label'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personalize a aparência do seu aplicativo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Informações básicas
                    const Text(
                      'Informações Básicas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Empresa',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o nome da empresa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _logoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL do Logotipo',
                        border: OutlineInputBorder(),
                        hintText: 'https://exemplo.com/logo.png',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _welcomeTextController,
                      decoration: const InputDecoration(
                        labelText: 'Texto de Boas-vindas',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Segmento de negócio
                    const Text(
                      'Segmento de Negócio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<BusinessSegment>(
                      value: _selectedSegment,
                      decoration: const InputDecoration(
                        labelText: 'Segmento',
                        border: OutlineInputBorder(),
                      ),
                      items: BusinessSegment.values.map((segment) {
                        return DropdownMenuItem(
                          value: segment,
                          child: Text(segment.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSegment = value;
                            // Atualiza as cores e o raio de borda com base no segmento
                            if (_primaryColor == _config.primaryColor) {
                              _primaryColor = value.primaryColor;
                            }
                            if (_secondaryColor == _config.secondaryColor) {
                              _secondaryColor = value.secondaryColor;
                            }
                            if (_borderRadius == _config.borderRadius) {
                              _borderRadius = value.borderRadius;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Cores
                    const Text(
                      'Cores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Cor Primária'),
                            subtitle: const Text('Cor principal da marca'),
                            trailing: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            onTap: () {
                              _showColorPicker(_primaryColor, (color) {
                                setState(() {
                                  _primaryColor = color;
                                });
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Cor Secundária'),
                            subtitle: const Text('Cor de destaque'),
                            trailing: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _secondaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            onTap: () {
                              _showColorPicker(_secondaryColor, (color) {
                                setState(() {
                                  _secondaryColor = color;
                                });
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Raio de borda
                    const Text(
                      'Raio de Borda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _borderRadius,
                      max: 32,
                      divisions: 32,
                      label: _borderRadius.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _borderRadius = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Informações de contato
                    const Text(
                      'Informações de Contato',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _supportEmailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail de Suporte',
                        border: OutlineInputBorder(),
                        hintText: 'suporte@exemplo.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _supportPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone de Suporte',
                        border: OutlineInputBorder(),
                        hintText: '(00) 00000-0000',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),

                    // Botão de salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveConfig,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Salvar Configurações'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _loadConfig,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Restaurar Configurações'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
