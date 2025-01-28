import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String serverUrl = 'http://localhost:8080/translate.php';

  static Future<String> translateText(String text) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {
          'text': text,
          'source': 'en',
          'target': 'pt',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['translatedText'] ?? text;
        } else {
          return 'Erro ao traduzir: ${data['message']}';
        }
      } else {
        throw Exception('Erro ao se conectar ao servidor: ${response.statusCode}');
      }
    } catch (e) {
      return 'Erro: $e';
    }
  }

  /// Função para traduzir a lista de ações
  static Future<List<Map<String, dynamic>>> translateActions(
      List<dynamic> actions) async {
    return await Future.wait(actions.map((action) async {
      return {
        'name': await translateText(action['name']),
        'desc': await translateText(action['desc']),
      };
    }));
  }
}
