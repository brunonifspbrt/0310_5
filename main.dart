// para lidar com arquivos
import 'dart:io';
import 'dart:async';
import 'package:ex5/foto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ex5/registros.dart';
import 'package:path/path.dart';
// requer flutter pub add sqflite path (funciona somente em Android, Ios)
import 'package:sqflite/sqflite.dart';
//in main.dart write this:
// requer flutter pub add sqflite_common_ffi caso queira testar em Windows
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// requer flutter pub add path_provider
import 'package:path_provider/path_provider.dart';
// requer flutter pub add shared_preferences
//import 'package:shared_preferences/shared_preferences.dart';
// requer flutter pub add camera path_provider path
import 'package:camera/camera.dart';

// outras configurações
// 1- Como o SQLFLite só funciona em mobile, abra o Android Studio e o emumlador Android
// 2- No Flutter, configure pra enviar o projeto para o emulador android
// 3- No terminal coloque flutter run e veja as mensagens de erro
// 4- Caso dê erro, vá no android\app\build.grade altere a linha 25 (mais ou menos) onde tem compileSdkVersion flutter.compileSdkVersion para compileSdkVersion 34,
// ficará como abaixo
// android {
//     namespace "com.example.ex3"
//     //compileSdkVersion flutter.compileSdkVersion
//     compileSdkVersion 34
// 5- Aplique no terminal o flutter run ou flutter build apk
// 6- Pelo explorer, encontre o arquivo .apk e envie para o emulador Android (do Android Studio) ARRASTANDO o apk
// 7- Execute o apk pelo emulador Android e teste, seja feliz

void main() async {
  // ao usar mais de uma tela é necessário trocar, na primeira tela que irá utilizar o navigator,
  // a chamada do runapp
  // é necessário chamar como abaixo: informando o MaterialApp e depois chamando o MainApp
  //runApp(const MainApp());
  runApp(MaterialApp(home: MainApp()));
}

class Ocorrencia {
  final int id;
  final String titulo;
  final String descricao;
  final String foto;

  Ocorrencia({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.foto,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'foto': foto,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Ocorrencia{id: $id, titulo: $titulo, descricao: $descricao, foto: $foto}';
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var conteudo = '';
  var msg = '';
  var msgT = '';
  var msgD = '';
  var msgF = '';
  var fotoCapturada = '';
  var operacaoOK = 0; // 0 - não, 1 - Sim

  //TextEditingController tfCep = TextEditingController();
  TextEditingController contTitulo = TextEditingController();
  TextEditingController contDescricao = TextEditingController();
  TextEditingController contFoto = TextEditingController();

  // declaro variável e informo que vou instanciar no futuro (late)
  late final database;
  late final firstCamera;

  @override
  void initState() {
    super.initState();
    carregaBD();
    // carregaCam();
    limpaCampos();
  }

  void carregaBD() async {
    WidgetsFlutterBinding.ensureInitialized();
    // verifica se plataforma é Desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // inicializa o sqflite ffi
      sqfliteFfiInit(); // Inicializa o FFI
      databaseFactory = databaseFactoryFfi; // Define o databaseFactory para FFI
    }

    // databaseFactory = databaseFactoryFfi;
    // final database = openDatabase(

    // caso exista o banco ele carrega, caso não o método OnCreate será ativado
    database = openDatabase(
      join(await getDatabasesPath(), 'ocorrencias.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE ocorrencias(id INTEGER PRIMARY KEY, titulo TEXT, descricao TEXT,foto TEXT)',
        );
      },
      version: 1,
    );
  }

  void carregaCam() async {
    // lista de cameras
    // final listaDeCameras = await availableCameras();
    // // pega a primeira camera disponível
    // firstCamera = listaDeCameras.first;
  }

  Future<void> insereOcorrencia(Ocorrencia item) async {
    operacaoOK = 0;
    final db = await database;

    await db.insert(
      'ocorrencias',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    operacaoOK = 1;
  }

  Future<List<Ocorrencia>> ocorrencias() async {
    final db = await database;

    final List<Map<String, Object?>> mapasOcorrencias =
        await db.query('ocorrencias');

    return [
      for (final {
            'id': id as int,
            'titulo': titulo as String,
            'descricao': descricao as String,
            'foto': foto as String,
          } in mapasOcorrencias)
        Ocorrencia(id: id, titulo: titulo, descricao: descricao, foto: foto),
    ];
  }

  Future<void> atualizaOcorrencia(Ocorrencia item) async {
    final db = await database;

    await db.update(
      'ocorrencias',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> apagaOcorrencia(int id) async {
    final db = await database;

    await db.delete(
      'ocorrencias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void limpaCampos() {
    contTitulo.clear();
    contDescricao.clear();
    contFoto.clear();
  }

  void limpa() async {
    final db = await database;
    await db.rawDelete("DELETE FROM ocorrencias");
    print("Tabela ocorrencias limpa com sucesso");
    limpaCampos();
  }

  void salva() async {
    int resultado = 1;
    int? idade = 0;
    msgT = '';
    msgD = '';
    msgF = '';
    final db = await database;

    // teste de preenchimento até fogo funcionar
    if (contTitulo.text.length < 1) {
      resultado = 0;
      msgT = "Informe um título válido";
    }

    if (resultado != 0) {
      if (contDescricao.text.length < 1) {
        resultado = 0;
        msgD = "Informe uma descrição válida";
      }
    }

    if (resultado != 0) {
      if (contFoto.text.length < 1) {
        resultado = 0;
        msgF = "Clique no botão 'Tirar foto' para tirar uma foto válida";
      }
    }

    setState(() {
      // forço atualizar variável aqui
      msgT = msgT;
      msgD = msgD;
      msgF = msgF;
    });

    // exibo no console só pra ver
    // print(contTitulo.text);
    // print(contDescricao.text);
    // print(contFoto.text);

    if (resultado != 0) {
      // obtem última ID no banco
      var maxID = await db
          .rawQuery('SELECT max(coalesce(ID,0)) as ID FROM ocorrencias');
      // print("Max ID:  $maxID");
      // primeira posição do vetor
      maxID = maxID[0];
      // acessar objeto
      maxID = maxID['ID'];
      // caso nulo converte pra zero
      maxID = (maxID == null) ? 0 : maxID;
      //print("Max ID sem nulo:  $maxID");
      // incrementa ID
      maxID = maxID + 1;

      // cria classe para salvar dados
      var novoItem = Ocorrencia(
          id: maxID,
          titulo: contTitulo.text,
          descricao: contDescricao.text,
          // foto: '${maxID.toString()}.jpg',
          foto: contFoto.text);

      // insere registro

      await insereOcorrencia(novoItem);
      // imprime registros
      print(await ocorrencias());
      if (operacaoOK == 1) {
        limpaCampos();
      }
    }
  }

  void exibeDados(BuildContext context) async {
    // uso o navigator para mudar de página pelo push. Ao chamar o segundo widget informo no parâmetro numX (do segundo Widget) o valor que desejo
    // para usar await o async deve estar declarado na função telaSubtracao

    // var dados = "Dados da ocorrência: \n";
    // obtem lista de registros do bd
    List<Ocorrencia> registros = await ocorrencias();

    // faz itearção para criar string com a informação
    // registros.forEach((e) => {
    //       dados = dados +
    //           "ID: ${e.id}, Título: ${e.titulo}, Descrição: ${e.descricao}, Foto: ${e.foto}\n"
    //     });
    // print("Opa");
    // print(dados);
    // envia dados para a tela de exibição de registros
    //var teste = new Map();

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SegundaTela(
            // passa lista como parâmetro
            dados: registros,
          ),
        ));
  }

  void capturaFoto(BuildContext context) async {
    fotoCapturada = "";
    var caminho = "";

    // await availableCameras().then(
    //   (value) => caminho = Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => JanelaTiraFoto(cameras: value))),
    // );

    final listaDeCameras = await availableCameras();
    caminho = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => JanelaTiraFoto(cameras: listaDeCameras)));
    setState(() {
      fotoCapturada = caminho.toString();
      contFoto.text = fotoCapturada;
    });
    print(fotoCapturada);
    // debugPrint('CONTEÚDO DO DEBUG:');
    // debugPrint(caminho);

    // await availableCameras().then(
    //   (value) => caminho = Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => JanelaTiraFoto(cameras: listaDeCameras))),
    // );

    // // abre tela para tirar foto
    // caminho = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => JanelaTiraFoto(
    //         // Cria a janela passando a camera que ela vai usar
    //         camera: firstCamera,
    //       ),
    //     ));
    // // após fechar a janela atualiza variável fotoCapturada e campo de foto
    // setState(() {
    //   fotoCapturada = caminho;
    //   contFoto.text = fotoCapturada.toString();
    // });
    // print(fotoCapturada);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contTitulo,
                  decoration:
                      InputDecoration(labelText: 'Titulo:', helperText: msgT),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contDescricao,
                  decoration: InputDecoration(
                      labelText: 'Descricao:', helperText: msgD),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contFoto,
                  readOnly: true,
                  decoration:
                      InputDecoration(labelText: 'Foto:', helperText: msgF),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        capturaFoto(context);
                      },
                      child: const Text('Tirar foto')),
                  ElevatedButton(onPressed: salva, child: const Text('Salva')),
                  ElevatedButton(
                      onPressed: limpa, child: const Text('Limpar BD')),
                  ElevatedButton(
                      onPressed: () {
                        exibeDados(context);
                      },
                      child: const Text('Ver dados')),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Text('Resultado: $msg'),
            ],
          ),
        ),
      ),
    );
  }
}
