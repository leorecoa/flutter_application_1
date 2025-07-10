import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('📝 Tentando registro com: ${_emailController.text}');
      
      final response = await _apiService.post('/auth/register', {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      });
      
      print('📡 Resposta da API: $response');
      
      if (response['success'] == true) {
        final user = User.fromJson(response['user']);
        await _apiService.setAuthToken(response['token'], user);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conta criada com sucesso! Bem-vindo, ${user.name}!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/dashboard');
        }
      } else {
        throw Exception(response['message'] ?? 'Erro no registro');
      }
    } catch (e) {
      print('❌ Erro no registro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              const Text(
                'Criar sua conta no AGENDEMAIS',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                autofillHints: const [AutofillHints.name],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Nome obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('email_field_register'),
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email obrigatório';
                  if (!value!.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('password_field_register'),
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Senha obrigatória';
                  if (value!.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Criar Conta'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Já tem conta? Faça login'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}