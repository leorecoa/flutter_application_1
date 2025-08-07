import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/multi_tenant/tenant_context.dart';
import '../../../core/multi_tenant/tenant_repository.dart';
import '../../../core/errors/error_handling_mixin.dart';
import '../../../core/models/tenant_model.dart';

/// Tela para seleção de tenant
class SelectTenantScreen extends ConsumerStatefulWidget {
  const SelectTenantScreen({super.key});

  @override
  ConsumerState<SelectTenantScreen> createState() => _SelectTenantScreenState();
}

class _SelectTenantScreenState extends ConsumerState<SelectTenantScreen>
    with ErrorHandlingMixin {
  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(userTenantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Selecione sua Empresa')),
      body: tenantsAsync.when(
        data: (tenants) {
          if (tenants.isEmpty) {
            return const _EmptyTenantsList();
          }
          return _TenantsList(tenants: tenants);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar empresas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userTenantsProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTenantDialog(),
        tooltip: 'Criar Nova Empresa',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTenantDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateTenantDialog(),
    );
  }
}

/// Widget para exibir a lista de tenants
class _TenantsList extends ConsumerWidget {
  final List<Tenant> tenants;

  const _TenantsList({required this.tenants});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tenants.length,
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                tenant.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(tenant.name),
            subtitle: Text('Plano: ${tenant.plan}'),
            trailing: tenant.isActive
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
            onTap: () {
              // Seleciona o tenant e navega para o dashboard
              ref.read(tenantContextProvider.notifier).setTenant(tenant);
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
          ),
        );
      },
    );
  }
}

/// Widget exibido quando não há tenants disponíveis
class _EmptyTenantsList extends StatelessWidget {
  const _EmptyTenantsList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nenhuma empresa encontrada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Crie uma nova empresa para começar',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const _CreateTenantDialog(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Criar Empresa'),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para criar um novo tenant
class _CreateTenantDialog extends ConsumerStatefulWidget {
  const _CreateTenantDialog();

  @override
  ConsumerState<_CreateTenantDialog> createState() =>
      _CreateTenantDialogState();
}

class _CreateTenantDialogState extends ConsumerState<_CreateTenantDialog>
    with ErrorHandlingMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedPlan = 'basic';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Nova Empresa'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Empresa',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.trim().length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPlan,
              decoration: const InputDecoration(
                labelText: 'Plano',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'basic', child: Text('Básico')),
                DropdownMenuItem(value: 'pro', child: Text('Profissional')),
                DropdownMenuItem(
                  value: 'enterprise',
                  child: Text('Empresarial'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPlan = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _createTenant, child: const Text('Criar')),
      ],
    );
  }

  void _createTenant() {
    if (_formKey.currentState?.validate() ?? false) {
      handleAsyncOperation(() async {
        final repository = ref.read(tenantRepositoryProvider);
        final newTenant = Tenant(
          id: '', // ID será gerado pelo backend
          name: _nameController.text.trim(),
          plan: _selectedPlan,
          createdAt: DateTime.now(),
          isActive: true,
        );

        final createdTenant = await repository.createTenant(newTenant);

        if (!mounted) return;

        // Seleciona o tenant recém-criado
        ref.read(tenantContextProvider.notifier).setTenant(createdTenant);

        // Fecha o diálogo e navega para o dashboard
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/dashboard');

        // Invalida o provider para recarregar a lista
        ref.invalidate(userTenantsProvider);
      }, successMessage: 'Empresa criada com sucesso!');
    }
  }
}
