import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/TranslationService.dart';

class MonsterDetailScreen extends StatefulWidget {
  final String url;

  MonsterDetailScreen({required this.url});

  @override
  _MonsterDetailScreenState createState() => _MonsterDetailScreenState();
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  Map<String, dynamic>? monster;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMonsterDetails();
  }

  Future<void> fetchMonsterDetails() async {
    try {
      final response =
          await http.get(Uri.parse("https://www.dnd5eapi.co${widget.url}"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String monsterName =
            await TranslationService.translateText(data['name']);
        final String monsterSize =
            await TranslationService.translateText(data['size']);
        final String monsterType =
            await TranslationService.translateText(data['type']);
        final String monsterAlignment =
            await TranslationService.translateText(data['alignment']);
        final translatedActions =
            await TranslationService.translateActions(data['actions']);

        setState(() {
          monster = data;
          monster!['name'] = monsterName;
          monster!['size'] = monsterSize;
          monster!['type'] = monsterType;
          monster!['alignment'] = monsterAlignment;
          monster!['actions'] = translatedActions;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load monster details");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(monster?['name'] ?? 'Detalhes do Monstro'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : monster != null
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      // Exibição da imagem do monstro
                      monster!['image'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(16.0)),
                              child: Image.network(
                                "https://www.dnd5eapi.co${monster!['image']}",
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 250,
                              color: Colors.grey[300],
                              child: Center(
                                child: Text(
                                  'Imagem não disponível',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700]),
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monster!['name'],
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text("Tamanho: ${monster!['size']}"),
                            Text("Tipo: ${monster!['type']}"),
                            Text("Alinhamento: ${monster!['alignment']}"),
                            SizedBox(height: 16),
                            Text(
                              "Descrição",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text("XP: ${monster!['xp'] ?? 'Desconhecido'}"),
                            SizedBox(height: 16),
                            if (monster!['actions'] != null) ...[
                              Text(
                                "Ações",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              ...monster!['actions'].map<Widget>((action) {
                                return ListTile(
                                  title: Text(action['name']),
                                  subtitle: Text(action['desc']),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(child: Text("Erro ao carregar detalhes do monstro")),
    );
  }
}
