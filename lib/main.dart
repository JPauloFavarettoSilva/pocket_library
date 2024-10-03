import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';  
import 'package:http/http.dart' as http;
import 'package:pocket_library/Models/Livros.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LivrosScreen(),
    );
  }
}

class LivrosScreen extends StatefulWidget {
  @override
  _LivrosScreenState createState() => _LivrosScreenState();
}

class _LivrosScreenState extends State<LivrosScreen> {
  List<Livro> livros = [];
  List<Livro> livrosFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLivros(); 
  }


  Future<void> fetchLivros() async {
    final response = await http.get(Uri.parse('https://localhost:7026/api/books'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        livros = data.map((json) => Livro.fromJson(json)).toList();
        livrosFiltrados = livros;
      });
    } else {
      throw Exception('Erro ao carregar os livros');
    }
  }

  Future<void> deletarLivro(String id) async {
  final response = await http.delete(Uri.parse('https://localhost:7026/api/books/$id'));

  if (response.statusCode == 200) {
    fetchLivros(); 
  } else {
    print('Erro ao deletar o livro: ${response.statusCode} - ${response.body}');
    throw Exception('Erro ao deletar o livro');
  }
}

 Future<void> adicionarLivro(Livro novoLivro, BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('https://localhost:7026/api/books'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': novoLivro.nome,
        'ano': novoLivro.ano,
        'autor': novoLivro.autor,
        'editora': novoLivro.editora,
        'ilustrador': novoLivro.ilustrador,
        'paginas': novoLivro.paginas,
      }),
    );

    // Verifica se a requisição foi bem-sucedida
    if (response.statusCode == 200) {
      fetchLivros(); // Atualiza a lista após adicionar o livro
      Navigator.of(context).pop(); // Fecha o diálogo após adicionar
    } 
    // Verifica se houve um erro 400
    else if (response.statusCode == 400) {
      final errorMessage = response.body; // Mensagem de erro enviada pela API

      // Exibe a mensagem de erro na Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } 
    // Lida com outros códigos de status
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar o livro: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } 
  // Captura exceções ao enviar a requisição
  catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exceção ao adicionar o livro: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}




  void filterLivros(String query) {
    List<Livro> livrosFiltradosLocal = livros.where((livro) {
      return livro.nome.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      livrosFiltrados = livrosFiltradosLocal;
    });
  }

  void openAddLivroDialog(BuildContext context) {
  final nomeController = TextEditingController();
  final anoController = TextEditingController();
  final autorController = TextEditingController();
  final editoraController = TextEditingController();
  final ilustradorController = TextEditingController();
  final paginasController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Adicionar Livro'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: anoController,
                decoration: InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly, 
                ],
              ),
              TextField(
                controller: autorController,
                decoration: InputDecoration(labelText: 'Autor'),
              ),
              TextField(
                controller: editoraController,
                decoration: InputDecoration(labelText: 'Editora'),
              ),
              TextField(
                controller: ilustradorController,
                decoration: InputDecoration(labelText: 'Ilustrador'),
              ),
              TextField(
                controller: paginasController,
                decoration: InputDecoration(labelText: 'Páginas'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly, 
                ],
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
          ElevatedButton(
            onPressed: () {
              final novoLivro = Livro(
                id: "0",
                nome: nomeController.text,
                ano: int.parse(anoController.text),
                autor: autorController.text,
                editora: editoraController.text,
                ilustrador: ilustradorController.text,
                paginas: int.parse(paginasController.text),
              );
              
              adicionarLivro(novoLivro, context); 
            },
            child: Text('Adicionar'),
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
        title: Text('Livros'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar livro',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                filterLivros(query);  
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: livrosFiltrados.length,
              itemBuilder: (context, index) {
                final livro = livrosFiltrados[index];
                return ListTile(
                  title: Text(livro.nome),
                  subtitle: Text('Autor: ${livro.autor}, Ano: ${livro.ano}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await deletarLivro(livro.id); 
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openAddLivroDialog(context); 
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
