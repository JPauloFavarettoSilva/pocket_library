class Livro {
  String id;
  String nome;
  int ano;
  String autor;
  String editora;
  String ilustrador;
  int paginas;


  Livro({
    required this.id,
    required this.nome,
    required this.ano,
    required this.autor,
    required this.editora,
    required this.ilustrador,
    required this.paginas,
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json["id"],
      nome: json['nome'],
      ano: json['ano'],
      autor: json['autor'],
      editora: json['editora'],
      ilustrador: json['ilustrador'],
      paginas: json['paginas'],
    );
  }
}
