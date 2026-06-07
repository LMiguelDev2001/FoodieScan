import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Necesario para que reconozca CameraController
import 'package:foodie_scan/models/model_products.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';
import '../controllers/product_controller.dart';
import '../views/form_view.dart';

class ScannerView extends StatefulWidget {
  //llave para hacer ref
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  //variables globales
  CameraController? controller;
  final barcodeScanner = BarcodeScanner();
  bool isFrameCaptured = false;
  String? copiedBarcode;

  //Para introducir el coddigo de barras manual
  final TextEditingController manualBarcode = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCamera();
  }

  @override
  void dispose() {
    manualBarcode.dispose();
    controller?.dispose();
    barcodeScanner.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //debemos hacer una copia ya que dar por seguridad, al ser controller una variable global, no deja usar sus funciones.
    //creamos una copia y asi si podemos usa dispose.
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
      //si es null
      body: (controller == null || !controller!.value.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: CameraPreview(controller!)),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey[900],
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: manualBarcode,
                          onChanged: (String value) {
                            setState(() {});
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Codigo de barras',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: (manualBarcode.text.isEmpty)
                            ? null
                            : () async {
                                //Le quitamos el foco a la caja de texto y vaciamos su contenido:
                                FocusScope.of(context).unfocus();

                                final resProcessBarcode =
                                    await ProductController().processBarcode(
                                      manualBarcode.text,
                                    );
                                if (!mounted) return;

                                if (resProcessBarcode == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'El producto es incorrecto o no se encuentra en la base de datos, vuelve a intentarlo',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  manualBarcode.clear();
                                  return;
                                }
                                manualBarcode.clear();
                                if (!mounted) {
                                  return;
                                }
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormView(
                                      productoEscaneado: resProcessBarcode,
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(
                          Icons.check,
                          color: Colors.greenAccent,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  //funcion para conseguir la camra del dispositivo.
  Future<void> _getCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        return;
      } else {
        //no estamos usando una funcion del objeto, estamos reasignando su valor y dart permite hacer esto. Por eso usamos la variable original.
        controller = CameraController(
          cameras[0],
          ResolutionPreset.max,
          imageFormatGroup: ImageFormatGroup.nv21,
        );
        await controller!.initialize();

        if (!mounted) return;
        setState(() {});

        //logica del escaneo de codigo de barras
        controller?.startImageStream((CameraImage img) async {
          if (isFrameCaptured == true) {
            return;
          }
          isFrameCaptured = true;

          try {
            final finalImg = processImg(img);

            if (finalImg == null) return;

            final List<Barcode> barcodesList = await barcodeScanner
                .processImage(finalImg);
            //si hay codigos de barras
            if (barcodesList.isNotEmpty) {
              final String readBarcode =
                  barcodesList.first.rawValue ??
                  'No se encontro el codigo de barras';

              //Si el codigo escaneado dio error, para que no haga spam la notificacion de error, creamos un flag.
              if (readBarcode == copiedBarcode) {
                return;
              }
              copiedBarcode = readBarcode;
              //cortamos la captura de frames
              //le pasamos al controlador el codigo de barras obtenido para que lo procese.
              ModelProducts? resProcessBarcode;
              //En caso de que haya un error de conexion, hacemos un try catch para capturar el error.
              try {
                resProcessBarcode = await ProductController().processBarcode(
                  readBarcode,
                );
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error de conexion, intentalo mas tarde'),
                    backgroundColor: Colors.orange,
                  ),
                );
                copiedBarcode = null;
                await Future.delayed(const Duration(seconds: 3));
                isFrameCaptured = false;
                return;
              }
              if (!mounted) return;
              if (resProcessBarcode == null) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El producto es incorrecto o no se encuentra en la base de datos.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );

                return;
              }
              copiedBarcode = null;

              await controller?.stopImageStream();
              if (!mounted) return;
              //Introducimos el formulario al Usuario
              //si obtenemos los datos del producto y nos encontramos en la app (que no la hemos cerrado)

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FormView(productoEscaneado: resProcessBarcode!),
                ),
              );
              //Creamos una copia de controller
              CameraController? copyController = controller;
              setState(() {
                controller = null;
              });
              await copyController?.dispose();
              _getCamera();
            }
          } catch (er) {
            print("Error: $er");
          } finally {
            isFrameCaptured = false;
          }
        });
      }
    } catch (er) {
      print("Error: $er");
    }
  }

  InputImage? processImg(CameraImage img) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img.planes) {
      //juntamos todos los planes dentro del writebuffer
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    //reconstruimos los bytes
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
}
