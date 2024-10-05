import 'package:ex5/main.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class SegundaTela extends StatefulWidget {
  //const SegundaTela({super.key});
  var dados;
  // o antigo construtor era const SegundaTela({super.key}) perceba que foi alterado para receber o valor
  SegundaTela({super.key, required this.dados});

  @override
  State<SegundaTela> createState() => _SegundaTelaState();
}

class _SegundaTelaState extends State<SegundaTela> {
  // records será alimentado ao ser chamado o Widget

  // preciso definir o construtor desse widget onde ele recebe a variavel
  //_SegundaTelaState({key key, @required this.int}) : super(key: key);
  //const _SegundaTelaState({super.key, required this.todo});

  int resultado = 0;
  var conteudoInicial;
  int qtdeReg = 0;
  Map<String, int> idade = Map();

  TextEditingController contTit = TextEditingController();
  TextEditingController contDes = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    conteudoInicial = widget.dados;
    //conteudo = conteudo['Ocorrencia'];
    print(conteudoInicial);
    // print(conteudo[0]);
    conteudoInicial.forEach((e) => qtdeReg++);
    // contTexto.text = conteudo.toString();
  }

  // a função deve receber o parâmetro context
  void telaAnterior(BuildContext context) {
    int val = 0;
    Navigator.pop(
      context,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: qtdeReg,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.file(File(conteudoInicial[index].foto),
                      width: 100, height: 400, fit: BoxFit.cover),
                  title: Text('Título: ${conteudoInicial[index].titulo}'),
                  subtitle:
                      Text('Descrição: ${conteudoInicial[index].descricao}'),
                  isThreeLine: true,
                );
              },
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                // perceba que é necessário colocar a função dentro de uma função anônima no evento onPressed
                telaAnterior(context);
              },
              child: const Text('Voltar'),
            ),
          )
        ],
      ),
    );
  }
}
