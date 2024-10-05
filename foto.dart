import 'dart:async';
import 'dart:io';
import 'package:ex5/fotopreview.dart';
import 'package:ex5/main.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// permite tirar a foto usando a camera fornecida
class JanelaTiraFoto extends StatefulWidget {
  const JanelaTiraFoto({
    super.key,
    required this.cameras,
  });

  // final CameraDescription camera;
  final List<CameraDescription>? cameras;

  @override
  JanelaTiraFotoState createState() => JanelaTiraFotoState();
}

class JanelaTiraFotoState extends State<JanelaTiraFoto> {
  late CameraController _cameraController;
  bool cameraTraseiraAtual = true;

  late Future<void> _initializeControllerFuture;
  late var fotoFinal;

  @override
  void initState() {
    super.initState();
    // por padrão há 2 itens: 0 - câmera traseira, 1 - câmera frontal. Aqui é a traseira
    initCamera(widget.cameras![0]);

    // // cria o controlador da camera
    // _controller = CameraController(
    //   // pega a camera
    //   widget.camera,
    //   // define a resolução
    //   ResolutionPreset.medium,
    // );

    // // inicializa o controlador da camera
    // _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // libera os recursos da camera
    _cameraController.dispose();
    super.dispose();
  }

  Future initCamera(CameraDescription cameraDescription) async {
    // carrega descripção da câmera + resolução
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      // XFile é uma abstração da classe File
      XFile picture = await _cameraController.takePicture();
      // após pegar o arquivo mostra no preview como ficou a foto tirada
      await Navigator.push(
          context,
          MaterialPageRoute(
              // aqui passo o Xfile como parâmetro
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
      // volta pra tela anterior e preenche texto com caminho onde o arquivo Xfile está salvo
      Navigator.pop(context, picture.path);
    } on CameraException catch (e) {
      debugPrint('Erro ao tirar foto: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Tire a foto')),
        body: SafeArea(
          child: Stack(children: [
            // só será exibido o preview da câmera depois de autorizar o acesso a câmera
            (_cameraController.value.isInitialized)
                ? CameraPreview(_cameraController)
                : Container(
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator())),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.20,
                  decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      color: Colors.black),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 30,
                          // se camera traseira está selecionada altera o tipo de ícone
                          icon: Icon(
                              cameraTraseiraAtual
                                  ? Icons.switch_camera
                                  : Icons.switch_camera_outlined,
                              color: Colors.white),
                          onPressed: () {
                            setState(() =>
                                cameraTraseiraAtual = !cameraTraseiraAtual);
                            initCamera(
                                widget.cameras![cameraTraseiraAtual ? 0 : 1]);
                          },
                        )),
                        Expanded(
                            child: IconButton(
                          onPressed: takePicture,
                          iconSize: 50,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.circle, color: Colors.white),
                        )),
                        const Spacer(),
                      ]),
                )),
          ]),
        ));
  }
}
