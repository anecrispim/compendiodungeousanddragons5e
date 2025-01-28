import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'MonsterDetailScreen.dart';

class MonsterListScreen extends StatefulWidget {
  @override
  _MonsterListScreenState createState() => _MonsterListScreenState();
}

class _MonsterListScreenState extends State<MonsterListScreen> {
  List<dynamic> monsters = [];
  List<dynamic> filteredMonsters = [];
  Map<String, String> monsterImages = {}; // Cache para imagens dos monstros
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMonsters();
  }

  Future<void> fetchMonsters() async {
    try {
      final response = await http.get(Uri.parse("https://www.dnd5eapi.co/api/monsters"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          monsters = data['results'];
          filteredMonsters = monsters; // Inicialmente, a lista filtrada é igual à lista completa
          isLoading = false;
        });

        // Inicia o carregamento das imagens
        for (var monster in monsters) {
          fetchMonsterImage(monster['url']);
        }
      } else {
        throw Exception("Failed to load monsters");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMonsterImage(String url) async {
    try {
      final response = await http.get(Uri.parse("https://www.dnd5eapi.co$url"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['image'] != null) {
          setState(() {
            monsterImages[url] = "https://www.dnd5eapi.co${data['image']}"; // Armazena a imagem no cache
          });
        }
      }
    } catch (e) {
      print("Error fetching image for $url: $e");
    }
  }

  /// Atualiza a lista filtrada com base no texto digitado
  void filterMonsters(String query) {
    final results = monsters.where((monster) {
      final name = monster['name'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery);
    }).toList();

    setState(() {
      filteredMonsters = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Monstros'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Campo de busca
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar Monstros',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (query) {
                      filterMonsters(query); // Atualiza a lista com base na busca
                    },
                  ),
                ),
                // Grade de monstros
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Número de colunas
                        crossAxisSpacing: 8.0, // Espaço horizontal entre os itens
                        mainAxisSpacing: 8.0, // Espaço vertical entre os itens
                        childAspectRatio: 3 / 4, // Proporção do aspecto dos itens
                      ),
                      itemCount: filteredMonsters.length,
                      itemBuilder: (context, index) {
                        final monster = filteredMonsters[index];
                        final monsterImage = monsterImages[monster['url']];

                        return GestureDetector(
                          onTap: () {
                            // Navega para a tela de detalhes do monstro
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MonsterDetailScreen(
                                  url: monster['url'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Exibe a imagem do monstro, se disponível
                                Expanded(
                                  child: monsterImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16.0),
                                          ),
                                          child: Image.network(
                                            monsterImage,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Text(
                                              'Carregando...',
                                              style: TextStyle(color: Colors.grey[700]),
                                            ),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    monster['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
