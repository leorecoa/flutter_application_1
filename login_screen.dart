import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/auth/application/auth_providers.dart';
import 'package:flutter_application_1/features/auth/presentation/state/login_state.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Ouve as mudanças de estado para efeitos colaterais (navegação, snackbar)
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (message) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        success: () {
          // Navega para a home ou dashboard após o login bem-sucedido
          // TODO: Substituir '/' pela rota correta do dashboard/home
          context.go('/');
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login - AgendaFácil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo.png', height: 80),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Por favor, insira um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Consumer(
                    builder: (context, ref, child) {
                      final loginState = ref.watch(loginControllerProvider);

                      // Mostra o indicador de progresso se o estado for 'loading'
                      if (loginState is _Loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            ref.read(loginControllerProvider.notifier).signIn(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                          }
                        },
                        child: const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // TODO: Implementar navegação para a tela de redefinição de senha
                    },
                    child: const Text('Esqueceu a senha?'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.go('/signup');
                    },
                    child: const Text('Não tem uma conta? Crie uma agora'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
