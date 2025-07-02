class SettingsService {
  static Future<bool> saveSettings(Map<String, String> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
  
  static Future<Map<String, String>> getSettings() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'nome': 'Clínica Bella Vista',
      'email': 'contato@bellavista.com',
      'pixKey': '05359566493',
    };
  }
}