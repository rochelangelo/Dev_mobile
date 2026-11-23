import 'dart:math';
import 'dart:io';

abstract interface class VerificadorDisponibilidade {
  bool get disponivel;
  bool emprestar();
  void devolver();
}

abstract class Livro {
  final String cod;
  String _titulo;
  final String? autor;

  Livro(this.cod, String titulo, {this.autor}) : _titulo = titulo.trim();

  String get titulo => _titulo;

  set titulo(String novoTitulo) {
    final titulo_limpo = novoTitulo.trim();
    if (titulo_limpo.isNotEmpty) {
      _titulo = titulo_limpo;
    }
  }

  String get autorExibido => autor ?? 'Autor desconhecido';

  String descricao();
}

extension ReferenciaLivro on Livro {
  String get referencia => '[$cod]  $_titulo - $autorExibido';
}

class LivroFisico extends Livro implements VerificadorDisponibilidade {
  final int numeroPaginas;
  bool _disponivel = true;

  LivroFisico(super.cod, super.titulo, this.numeroPaginas, {super.autor});

  @override
  bool get disponivel => _disponivel;

  @override
  bool emprestar() {
    if (!_disponivel) {
      return false;
    }
    return true;
  }

  @override
  void devolver() {
    _disponivel = true;
  }

  @override
  String descricao() =>
      'Livro fisico[$cod] "$titulo" | Autor: $autorExibido | Numero de Paginas: $numeroPaginas | Disponivel: ${disponivel ? 'Sim' : 'Nao'}';
}

class LivroDigital extends Livro {
  final double tamanhoArquivo;

  LivroDigital(super.cod, super.titulo, this.tamanhoArquivo, {super.autor});

  @override
  String descricao() =>
      'Livro digital[$cod] "$titulo" | Autor: $autorExibido | Tamanho do arquivo: ${tamanhoArquivo.toStringAsFixed(2)} MB';
}

void exibirLivrosRecomendados(List<Livro> livros, {int quantidade = 5}) {
  final disponiveis = livros
      .where(
        (livro) =>
            livro is LivroDigital || (livro is LivroFisico && livro.disponivel),
      )
      .toList();

  disponiveis.shuffle(Random());

  disponiveis
      .take(quantidade)
      .toList()
      .asMap()
      .entries
      .forEach((e) => print('${e.key + 1}. ${e.value.referencia}'));
}

void exibirMenu() {
  print("\n\nAções para a biblioteca:");
  print("1. Listar todos os livros");
  print("2. Listar livros físicos disponíveis");
  print("3. Listar livros digitais");
  print("4. Emprestar livro físico");
  print("5. Devolução de livro");
  print("6. Demonstração da alteração de título de livro");
  print("7. Demonstração das ações de empréstimo e devolução de livro");
  print("8. Sair");
  stdout.write("Escolha uma opção: ");
}

void menuOpcoes(int opcao, List<Livro> catalogo) {
  switch (opcao) {
    case 1:
      print(".......BIBLIOTECA - DAM.......");
      print("....Todos os Nossos Livros....");
      for (final l in catalogo) {
        print(l.descricao());
      }
    case 2:
      print(".......BIBLIOTECA - DAM.......");
      print("...Todos os Livros Fisicos....");
      for (final l in catalogo.whereType<LivroFisico>().where(
        (l) => l.disponivel,
      )) {
        print(l.descricao());
      }
    case 3:
      print(".......BIBLIOTECA - DAM.......");
      print("...Todos os Livros Digitais...");
      for (final l in catalogo.whereType<LivroDigital>()) {
        print(l.descricao());
      }
    case 4:
      print(".......BIBLIOTECA - DAM.......");
      print("......Emprestar Um Livro......");
      stdout.write("Código do livro: ");
      final codigo = stdin.readLineSync()?.trim() ?? '';
      final livro = catalogo
          .whereType<LivroFisico>()
          .where((l) => l.cod == codigo)
          .firstOrNull;
      if (livro == null) {
        print("Livro não encontrado.");
      } else {
        print(
          livro.emprestar() ? "Empréstimo realizado." : "Livro já emprestado.",
        );
      }
    case 5:
      print(".......BIBLIOTECA - DAM.......");
      print("........Devolver Um Livro.......");
      stdout.write("Código do livro: ");
      final codigo = stdin.readLineSync()?.trim() ?? '';
      final livro = catalogo
          .whereType<LivroFisico>()
          .where((l) => l.cod == codigo)
          .firstOrNull;
      if (livro == null) {
        print("Livro não encontrado.");
      } else {
        livro.devolver();
        print("Devolução registrada.");
      }
    case 6:
      catalogo.shuffle(Random());
      print("...................BIBLIOTECA - DAM...................");
      print("........Demonstrar Alteração de Título de Livro.......");
      print(catalogo[0].descricao());
      print("Alterando título do livro para '   Memórias Póstumas   '");
      catalogo[0].titulo = '   Memórias Póstumas   ';
      print('Após entrada válida (com espaços): "${catalogo[0].titulo}"');
      print("Alterando título do livro para '    ' (em branco)");
      catalogo[0].titulo = '    ';
      print('Após entrada em branco: "${catalogo[0].titulo}"');
    case 7:
      print("....................BIBLIOTECA - DAM.....................");
      print("........Demonstrar Emprestimo e Devolução de Livro.......");

      final fisico = catalogo.whereType<LivroFisico>().firstWhere(
        (l) => l.disponivel,
      );
      print(fisico.descricao());
      print('Disponivel Atualmente? ${fisico.disponivel ? "sim" : "não"}');

      print(
        'Primeiro empréstimo aceito? ${fisico.emprestar() ? "sim" : "não"}',
      );
      print(
        'Disponível após empréstimo? ${fisico.disponivel ? "disponivel" : "não disponivel"}',
      );

      print('Segundo empréstimo aceito? ${fisico.emprestar() ? "sim" : "não"}');

      fisico.devolver();
      print(
        'Disponível após devolução? ${fisico.disponivel ? "disponivel" : "não disponivel"}',
      );

      fisico.devolver();
      print(
        'Disponível após nova devolução? ${fisico.disponivel ? "disponivel" : "não disponivel"}',
      );

    case 8:
      print("Encerrando...");
    default:
      print("Opção inválida.");
  }
}

void main() {
  final List<Livro> minhaBiblioteca = [
    LivroFisico('F001', 'Dom Casmurro', 256, autor: 'Machado de Assis'),
    LivroFisico('F002', 'Livro Antigo Sem Autor', 120),
    LivroFisico(
      'F003',
      'Memórias Póstumas de Brás Cubas',
      224,
      autor: 'Machado de Assis',
    ),
    LivroFisico('F004', 'O Cortiço', 288, autor: 'Aluísio Azevedo'),
    LivroFisico(
      'F005',
      'Grande Sertão: Veredas',
      624,
      autor: 'João Guimarães Rosa',
    ),
    LivroFisico('F006', 'Vidas Secas', 176, autor: 'Graciliano Ramos'),
    LivroFisico('F007', 'Capitães da Areia', 280, autor: 'Jorge Amado'),
    LivroFisico('F008', 'A Hora da Estrela', 88, autor: 'Clarice Lispector'),
    LivroFisico('F009', 'O Alienista', 96, autor: 'Machado de Assis'),
    LivroFisico('F010', 'Iracema', 144),
    LivroFisico('F011', 'Coletânea de Contos Populares', 190),
    LivroFisico('F012', 'Quincas Borba', 272, autor: 'Machado de Assis'),
    LivroDigital('D001', 'Clean Code', 4.5, autor: 'Robert C. Martin'),
    LivroDigital('D002', 'Manual de Dart', 2.3),
    LivroDigital('D003', 'Design Patterns', 6.8, autor: 'Erich Gamma'),
    LivroDigital('D004', 'Refactoring', 5.2),
    LivroDigital('D005', 'The Pragmatic Programmer', 3.9, autor: 'Andrew Hunt'),
    LivroDigital('D006', 'Introdução ao Flutter', 7.1, autor: 'Equipe Flutter'),
    LivroDigital('D007', 'Estruturas de Dados', 4.0),
    LivroDigital('D008', 'Guia Rápido de Git', 1.2),
    LivroDigital(
      'D009',
      'Algoritmos: Teoria e Prática',
      9.4,
      autor: 'Thomas Cormen',
    ),
    LivroDigital(
      'D010',
      'Programação Orientada a Objetos',
      3.3,
      autor: 'Bertrand Meyer',
    ),
  ];

  print(".......BIBLIOTECA - DAM.......");
  print("Titulos recomendados para leitura:");
  exibirLivrosRecomendados(minhaBiblioteca);
  int opcao;
  do {
    exibirMenu();
    opcao = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
    menuOpcoes(opcao, minhaBiblioteca);
  } while (opcao != 8);
}
