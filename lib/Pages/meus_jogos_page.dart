import 'dart:convert';
import 'usuario_logado.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://localhost:5255/api';

class MeusJogosPage extends StatefulWidget {
  const MeusJogosPage({super.key});

  @override
  State<MeusJogosPage> createState() => _MeusJogosPageState();
}

class _MeusJogosPageState extends State<MeusJogosPage> {
  List<dynamic> jogos = [];
  List<dynamic> jogosFiltrados = [];
  bool isLoading = true;

  // Filtros
  String buscaTitulo = '';
  double? precoMin;
  double? precoMax;

  @override
  void initState() {
    super.initState();
    carregarJogos();
  }

  Future<void> carregarJogos() async {
    try {
      final url = Uri.parse('$apiUrl/jogos/usuario/${UsuarioLogado.id}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          jogos = jsonDecode(response.body);
          jogosFiltrados = List.from(jogos);
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar jogos');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void aplicarFiltros() {
    setState(() {
      jogosFiltrados = jogos.where((jogo) {
        final titulo = (jogo['titulo'] ?? '').toString().toLowerCase();
        final preco = (jogo['preco'] ?? 0).toDouble();

        final filtroTitulo = titulo.contains(buscaTitulo.toLowerCase());
        final filtroPrecoMin = precoMin == null || preco >= precoMin!;
        final filtroPrecoMax = precoMax == null || preco <= precoMax!;

        return filtroTitulo && filtroPrecoMin && filtroPrecoMax;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Jogos à Venda'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Filtros
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Busca por título
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Buscar por nome',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          buscaTitulo = value;
                          aplicarFiltros();
                        },
                      ),
                      const SizedBox(height: 8),

                      // Filtro por preço
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Preço mín',
                                prefixIcon: Icon(Icons.price_check),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                precoMin = double.tryParse(value);
                                aplicarFiltros();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Preço máx',
                                prefixIcon: Icon(Icons.price_check),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                precoMax = double.tryParse(value);
                                aplicarFiltros();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 🃏 Lista de jogos
                Expanded(
                  child: jogosFiltrados.isEmpty
                      ? const Center(child: Text('Nenhum jogo encontrado'))
                      : ListView.builder(
                          itemCount: jogosFiltrados.length,
                          itemBuilder: (context, index) {
                            final jogo = jogosFiltrados[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.blueGrey.shade50,
                                child: Row(
                                  children: [
                                    // 📷 Imagem
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        jogo['imagemUrl'] ?? '',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // 📄 Detalhes
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              jogo['titulo'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              jogo['descricao'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(height: 8),

                                            // Estado e Preço
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.blue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    jogo['estado'] ?? 'Usado',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                Text(
                                                  'R\$ ${jogo['preco'].toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ],
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
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cadastro-jogo')
              .then((_) => carregarJogos());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
