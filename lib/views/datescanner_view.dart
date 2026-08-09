import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

class DateScannerView extends StatefulWidget {
  const DateScannerView({super.key});

  @override
  State<DateScannerView> createState() => _DateScannerViewState();
}

class _DateScannerViewState extends State<DateScannerView>
    with WidgetsBindingObserver {
  //Fuente pixelart
  final TextStyle retroStyle = GoogleFonts.pixelifySans(
    textStyle: const TextStyle(color: Colors.white, fontSize: 16),
  );

  //Variables globales
  CameraController? controller;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool isFrameCaptured = false;

  @override
  void initState() {
    super.initState();
    _getCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Debemos hacer una copia ya que dar por seguridad, al ser controller una variable global, no deja usar sus funciones.
    //Creamos una copia y asi si podemos usa dispose.
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _getCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: SafeArea(
        child: (controller == null || !controller!.value.isInitialized)
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    //Area de la camara
                    child: Stack(children: [CameraPreview(controller!)]),
                  ),

                  //Boton de cancelar
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Color(0xFF1E1E2C),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      onPressed: () {
                        if (!mounted) {
                          return;
                        }

                        Navigator.pop(context);
                      },
                      child: Text('CANCELAR ESCÁNER', style: retroStyle),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _getCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        return;
      } else {
        //No estamos usando una funcion del objeto, estamos reasignando su valor y dart permite hacer esto. Por eso usamos la variable original.
        controller = CameraController(
          cameras[0],
          ResolutionPreset.max,
          imageFormatGroup: ImageFormatGroup.nv21,
        );
        await controller!.initialize();

        if (!mounted) return;
        setState(() {});

        //Logica del escaneo de las fechas
        controller?.startImageStream((CameraImage img) async {
          if (isFrameCaptured == true) {
            return;
          }
          isFrameCaptured = true;

          try {
            final finalImg = processImg(img);

            if (finalImg == null) return;

            final RecognizedText recognizedText = await textRecognizer
                .processImage(finalImg);

            //Extraemos todo el texto que la cámara ha visto en este fotograma
            String scannedText = recognizedText.text;

            //Si ha conseguido escanear la fecha con exito:
            if (scannedText.isNotEmpty) {
              final String? date = _extractDate(scannedText);

              if (date != null) {
                if (!mounted) {
                  return;
                }
                await controller?.stopImageStream();
                Navigator.pop(context, date);
              }
            }
          } catch (error) {
            print("$error");
          } finally {
            isFrameCaptured = false;
          }
        });
      }
    } catch (er) {
      print("Error cámara: $er");
    }
  }

  //Funcion para procesar los frames de la camara y extraer la informacion.
  InputImage? processImg(CameraImage img) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imgSize = Size(img.width.toDouble(), img.height.toDouble());
    final imgRotation = InputImageRotationValue.fromRawValue(
      controller!.description.sensorOrientation,
    );
    if (imgRotation == null) return null;

    final imgFormat = InputImageFormatValue.fromRawValue(img.format.raw);
    if (imgFormat == null) return null;

    final inputImageData = InputImageMetadata(
      size: imgSize,
      rotation: imgRotation,
      format: imgFormat,
      bytesPerRow: img.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  String? _extractDate(String date) {
    //Expresion irregular y logica de la fecha en formato completo
    final RegExp irregularExpressionFullDate = RegExp(
      r'\b(\d{2})[\/\-\.](\d{2})[\/\-\.](\d{2,4})\b',
    );

    final matchFullDate = irregularExpressionFullDate.firstMatch(date);

    if (matchFullDate != null) {
      String day = matchFullDate.group(1)!;
      String month = matchFullDate.group(2)!;
      String year = matchFullDate.group(3)!;

      //En caso de que el formato de año sea de dos digitos como "26"
      if (year.length == 2) {
        year = '20$year';
      }

      return '$year-$month-$day';
    }

    //Expresion irregular y logica de la fecha en formato Mes y año

    final RegExp irregularExpressionMonthYear = RegExp(
      r'\b(\d{2})[\/\-\.](\d{4})\b',
    );
    final matchDateMonthYear = irregularExpressionMonthYear.firstMatch(date);

    if (matchDateMonthYear != null) {
      String month = matchDateMonthYear.group(1)!;
      String year = matchDateMonthYear.group(2)!;

      return '$year-$month-01';
    }

    //Expresion irregular y logica de la fecha en formato año
    final RegExp irregularExpressionYear = RegExp(r'\b(202[6-9]|203[0-5])\b');
    final matchDateYear = irregularExpressionYear.firstMatch(date);

    if (matchDateYear != null) {
      String year = matchDateYear.group(1)!;

      return '$year-01-01';
    }
    //En principio nunca deberia ser null si el codigo entra a esta funcion.
    //Se pone el return por si acaso.
    return null;
  }
}
