import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Necesario para que reconozca CameraController
import 'package:foodie_scan/models/model_products.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';
import '../controllers/product_controller.dart';
import '../views/form_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;

class ScannerView extends StatefulWidget {
  //llave para hacer ref
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  //Fuente pixelart
  final TextStyle retroStyle = GoogleFonts.pixelifySans(
    textStyle: TextStyle(color: Colors.white, fontSize: 16),
  );

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
    if (!Platform.isWindows) {
      _getCamera();
    }
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
      body: Platform.isWindows
          //En caso de que el SO sea Windowss y no un movil.
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'WINDOWS: CÁMARA DESACTIVADA',
                      style: retroStyle.copyWith(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: manualBarcode,
                      style: retroStyle,
                      decoration: InputDecoration(
                        hintText: 'Introduce el código de barras...',
                        hintStyle: retroStyle.copyWith(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () async {
                        if (manualBarcode.text.isNotEmpty) {
                          ModelProducts? resProcessBarcode;
                          try {
                            //Intentamos llamar a la API o a la base de datos local.
                            resProcessBarcode = await ProductController()
                                .processBarcode(manualBarcode.text);

                            //En caso de que de error:
                          } catch (error) {
                            if (!mounted) {
                              return;
                            }

                            //Limpiamos las notificaiones activas si las hay.
                            ScaffoldMessenger.of(context).clearSnackBars();

                            //En caso de error de conexion
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Text(
                                    'Error de conexion, vuelvalo a intentar mas tarde',
                                    style: retroStyle,
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                            );

                            //Metemos delay entre notificaiones
                            await Future.delayed(const Duration(seconds: 3));
                          }

                          //Si no hay un error de conexion pero el codigo de barras es null (que no existe) salta un error en rojo.
                          if (resProcessBarcode == null) {
                            if (!mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Text(
                                    'El producto es incorrecto o no se encuentra en la base de datos.',
                                    style: retroStyle,
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
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
                              builder: (context) =>
                                  FormView(scannedProduct: resProcessBarcode!),
                            ),
                          );
                        }
                      },
                      child: Text('BUSCAR PRODUCTO', style: retroStyle),
                    ),
                  ],
                ),
              ),
            )
          //MOVILES
          : (controller == null || !controller!.value.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                //Area de la camara
                Expanded(child: CameraPreview(controller!)),

                //Contenedor para la introduccion manual
                Container(
                  color: Color(0xFF1E1E2C),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: TextField(
                            controller: manualBarcode,
                            onChanged: (String value) {
                              setState(() {});
                            },
                            style: retroStyle,
                            decoration: InputDecoration(
                              hintText: 'CÓDIGO DE BARRAS',
                              hintStyle: retroStyle,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
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

                                if (!mounted) return;
                                ModelProducts? resProcessBarcode;
                                try {
                                  resProcessBarcode = await ProductController()
                                      .processBarcode(manualBarcode.text);
                                } catch (error) {
                                  if (!mounted) {
                                    return;
                                  }
                                  //Limpiamos las notificaiones activas si las hay.
                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();

                                  //En caso de error de conexion
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        child: Text(
                                          'Error de conexion, vuelvalo a intentar mas tarde',
                                          style: retroStyle,
                                        ),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                  );
                                  copiedBarcode = null;

                                  //Metemos delay entre notificaiones.
                                  await Future.delayed(
                                    const Duration(seconds: 3),
                                  );
                                  isFrameCaptured = false;
                                  return;
                                }
                                //Si no hay un error de conexion pero el codigo de barras es null (que no existe) salta un error en rojo.
                                if (resProcessBarcode == null) {
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        child: Text(
                                          'El producto es incorrecto o no se encuentra en la base de datos.',
                                          style: retroStyle,
                                        ),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                  );
                                  manualBarcode.clear();
                                  return;
                                }

                                //En caso de que SI exista el codigo de barras:
                                manualBarcode.clear();
                                if (!mounted) {
                                  return;
                                }

                                CameraController? copyController = controller;
                                setState(() {
                                  controller = null;
                                });
                                await copyController?.dispose();

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormView(
                                      scannedProduct: resProcessBarcode!,
                                    ),
                                  ),
                                );
                                _getCamera();
                              },
                        icon: Image.asset(
                          'assets/icons/tick.png',
                          fit: BoxFit.contain,
                          width: 40,
                          height: 40,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  //Funcion para conseguir la camra del dispositivo e implementar la loica de el escaner de codigo de barras.
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

        //Logica del escaneo de codigo de barras.
        controller?.startImageStream((CameraImage img) async {
          if (isFrameCaptured == true) {
            return;
          }
          isFrameCaptured = true;

          try {
            final finalImg = _processImg(img);

            if (finalImg == null) return;

            final List<Barcode> barcodesList = await barcodeScanner
                .processImage(finalImg);
            //Si hay codigos de barras
            if (barcodesList.isNotEmpty) {
              final String readBarcode =
                  barcodesList.first.rawValue ??
                  'No se encontro el codigo de barras';

              //Si el codigo escaneado dio error, para que no haga spam la notificacion de error, creamos un flag.
              if (readBarcode == copiedBarcode) {
                return;
              }
              copiedBarcode = readBarcode;
              //Cortamos la captura de frames
              //Le pasamos al controlador el codigo de barras obtenido para que lo procese.
              ModelProducts? resProcessBarcode;
              //En caso de que haya un error de conexion, hacemos un try catch para capturar el error.
              try {
                resProcessBarcode = await ProductController().processBarcode(
                  readBarcode,
                );
              } catch (error) {
                if (!mounted) return;
                //Para que no se pongan encimas unas de otras, ponemos clear.
                ScaffoldMessenger.of(context).clearSnackBars();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        'Error de conexion, vuelvalo a intentar mas tarde',
                        style: retroStyle,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
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
                  SnackBar(
                    content: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        'El producto es incorrecto o no se encuentra en la base de datos.',
                        style: retroStyle,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                );

                return;
              }
              copiedBarcode = null;

              await controller?.stopImageStream();
              if (!mounted) return;
              //Introducimos el formulario al Usuario
              //Si obtenemos los datos del producto y nos encontramos en la app (que no la hemos cerrado)

              //Creamos una copia de controller
              CameraController? copyController = controller;
              setState(() {
                controller = null;
              });
              await copyController?.dispose();

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FormView(scannedProduct: resProcessBarcode!),
                ),
              );
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

  //Funcion para procesar los frames de la camara y extraer la informacion.
  InputImage? _processImg(CameraImage img) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img.planes) {
      //Juntamos todos los planes dentro del writebuffer
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    //Reconstruimos los bytes
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
