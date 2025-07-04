import 'package:flutter/material.dart';
import '../../../core/config/multi_region_config.dart';
import '../../../core/services/api_service.dart';

/// Tela para seleção de região
class RegionSelectorScreen extends StatefulWidget {
  const RegionSelectorScreen({super.key});

  @override
  State<RegionSelectorScreen> createState() => _RegionSelectorScreenState();
}

class _RegionSelectorScreenState extends State<RegionSelectorScreen> {
  final ApiService _apiService = ApiService();
  String _selectedRegion = MultiRegionConfig.defaultRegion;
  Map<String, bool> _regionsHealth = {};
  Map<String, int> _regionsLatency = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentRegion();
    _checkRegionsHealth();
  }
  
  Future<void> _loadCurrentRegion() async {
    final region = await MultiRegionConfig.getPreferredRegion();
    setState(() {
      _selectedRegion = region;
    });
  }
  
  Future<void> _checkRegionsHealth() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Verifica a saúde de todas as regiões
      final healthResults = await MultiRegionConfig.checkRegionsHealth();
      
      // Mede a latência das regiões saudáveis
      final latencies = <String, int>{};
      
      for (final region in healthResults.keys) {
        if (healthResults[region] == true) {
          try {
            final endpoint = MultiRegionConfig.apiEndpoints[region];
            if (endpoint == null) continue;
            
            final start = DateTime.now();
            await _apiService.get('/health');
            final end = DateTime.now();
            
            latencies[region] = end.difference(start).inMilliseconds;
          } catch (e) {
            // Ignora erros ao medir latência
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _regionsHealth = healthResults;
          _regionsLatency = latencies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar regiões: $e')),
        );
      }
    }
  }
  
  Future<void> _changeRegion(String region) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _apiService.changeRegion(region);
      
      setState(() {
        _selectedRegion = region;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Região alterada para ${MultiRegionConfig.regions[region]}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar região: $e')),
        );
      }
    }
  }
  
  Future<void> _useOptimalRegion() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final optimalRegion = await MultiRegionConfig.findLowestLatencyRegion();
      await _changeRegion(optimalRegion);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao encontrar região ideal: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Região'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkRegionsHealth,
            tooltip: 'Atualizar status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione a região mais próxima de você para obter melhor desempenho.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _useOptimalRegion,
                    icon: const Icon(Icons.speed),
                    label: const Text('Usar Região Ideal'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Regiões Disponíveis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...MultiRegionConfig.regions.entries.map((entry) {
                    final region = entry.key;
                    final name = entry.value;
                    final isHealthy = _regionsHealth[region] ?? false;
                    final latency = _regionsLatency[region];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text(
                          latency != null
                              ? 'Latência: ${latency}ms'
                              : isHealthy
                                  ? 'Disponível'
                                  : 'Indisponível',
                        ),
                        leading: Icon(
                          isHealthy ? Icons.check_circle : Icons.error,
                          color: isHealthy ? Colors.green : Colors.red,
                        ),
                        trailing: Radio<String>(
                          value: region,
                          groupValue: _selectedRegion,
                          onChanged: isHealthy
                              ? (value) {
                                  if (value != null) {
                                    _changeRegion(value);
                                  }
                                }
                              : null,
                        ),
                        enabled: isHealthy,
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text(
                    'Nota: A alteração de região pode afetar temporariamente o desempenho do aplicativo.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}