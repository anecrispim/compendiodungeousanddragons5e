import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyMonsterScreen extends StatefulWidget {
  @override
  _MyMonsterScreenState createState() => _MyMonsterScreenState();
}

class _MyMonsterScreenState extends State<MyMonsterScreen> {
  List<dynamic> monsters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMonsters();
  }

  /// Função para buscar os monstros do serviço PHP
  Future<void> fetchMonsters() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/list_monsters.php'));

      if (response.statusCode == 200) {
        setState(() {
          monsters = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load monsters');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Função para criar um monstro usando o serviço PHP
  Future<void> createMonster(Map<String, dynamic> newMonster) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/post_monster.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newMonster),
      );

      if (response.statusCode == 201) {
        // Monstro criado com sucesso, atualiza a lista
        fetchMonsters();
      } else {
        throw Exception('Failed to create monster');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Mostra um diálogo para o usuário criar um novo monstro
  void showCreateMonsterDialog() {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();
    final typeController = TextEditingController();
    final alignmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Criar Monstro'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: sizeController,
                  decoration: InputDecoration(labelText: 'Tamanho'),
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Tipo'),
                ),
                TextField(
                  controller: alignmentController,
                  decoration: InputDecoration(labelText: 'Alinhamento'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final newMonster = {
                  'name': nameController.text,
                  'size': sizeController.text,
                  'type': typeController.text,
                  'alignment': alignmentController.text,
                  'actions': [], // Por enquanto, sem ações
                };

                createMonster(newMonster);
                Navigator.of(context).pop();
              },
              child: Text('Criar'),
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
        title: Text('Meus Monstros'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : monsters.isEmpty
              ? Center(
                  child: Text('Nenhum monstro encontrado.'),
                )
              : ListView.builder(
                  itemCount: monsters.length,
                  itemBuilder: (context, index) {
                    final monster = monsters[index];
                    return ListTile(
                      title: Text(monster['name']),
                      subtitle: Text('${monster['type']} - ${monster['size']}'),
                      trailing: Text(monster['alignment']),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateMonsterDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
