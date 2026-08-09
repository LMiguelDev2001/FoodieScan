import 'package:flutter/material.dart';
import 'package:foodie_scan/models/model_categories.dart';
import 'package:foodie_scan/models/model_fridge.dart';
import '../models/model_products.dart';
import '../services/database_helper.dart';
import '../main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../views/datescanner_view.dart';
import 'dart:io' show Platform;

class FormView extends StatefulWidget {
  //Variable global para almacenar los datos del producto escaneado recibido a traves de la constante FromView.
  final ModelProducts scannedProduct;

  const FormView({super.key, required this.scannedProduct});

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  //variables globales
  int quantity = 1;
  //La fecha es el unico campo en el que el usuraio "escribira" datos manualmente.
  //Es por ello que es el unico campo en el que empleamos "TextEditingController".
  final TextEditingController dateController = TextEditingController();
  int? selectedCategory;

  @override
  void initState() {
    super.initState();
    //Si el producto escaneado ya se encuentra en el historico, adjuntamos su categoria a selectedCategory.
    selectedCategory = widget.scannedProduct.categoryId;
  }

  @override
  void dispose() {
    //Cuando cambiamos de vista, textcontroller no se destruye, se queda en la memoria ne el limbo.
    //Tenemos que indicarle esplicitamente a nuestra vista que elimine controller.
    dateController.dispose();
    super.dispose();
  }

  //Funcion para que aparezca un pop un de calendario y poder selecionar manualmente una fecha de caducidad.
  Future<void> _seleccionarFecha() async {
    DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    //si la fecha se ha seleccionado y guardado correctamente:
    if (fechaElegida != null) {
      setState(() {
        dateController.text = fechaElegida.toIso8601String().split('T')[0];
      });
    }
  }

  //Fuente pixelart
  final TextStyle retroStyle = GoogleFonts.pixelifySans(
    textStyle: TextStyle(color: Colors.white, fontSize: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text(
          'REGISTRAR ALIMENTO',
          style: GoogleFonts.pixelifySans(
            textStyle: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, //Quitamos la flecha de volver por defecto
        centerTitle: true,
      ),
      //Metemos todo dentro de un SafeArea y asi no se solapa con la barra de navegacion inferior.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //IMG DEL PRODUCTO
              Center(
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  //Si existe una imagen, iniciamos Image.network. Si no existe iniciamos Image.asset para insertar la imagen guardada en local
                  child: widget.scannedProduct.image != null
                      ? Image.network(
                          widget.scannedProduct.image ??
                              'assets/icons/notFound.png', //Por seguridad.
                          width: 105,
                          height: 105,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/icons/notFound.png');
                          },
                        )
                      : Image.asset(
                          'assets/icons/notFound.png',
                          width: 105,
                          height: 105,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 24),

              //PRODUCTO
              Text('PRODUCTO:', style: retroStyle),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(widget.scannedProduct.name, style: retroStyle),
              ),
              const SizedBox(height: 20),

              //FECHA DE CADUCIDAD
              Text('FECHA CADUCIDAD:', style: retroStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: _seleccionarFecha,
                        controller: dateController,
                        style: retroStyle,
                        decoration: InputDecoration(
                          hintText: 'YYYY-MM-DD',
                          hintStyle: retroStyle,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!Platform.isWindows)
                    IconButton(
                      onPressed: () async {
                        final scannedDate = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DateScannerView(),
                          ),
                        );
                        if (!mounted) {
                          return;
                        }
                        //Si el escaner consiguio escanear la fecha:
                        if (scannedDate != null) {
                          setState(() {
                            dateController.text = scannedDate;
                          });
                        }
                      },
                      icon: Image.asset(
                        'assets/icons/camara.png',
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              //CATEGORÍA
              Text('CATEGORÍA:', style: retroStyle),
              const SizedBox(height: 8),
              FutureBuilder<List<ModelCategories>>(
                future: DatabaseHelper.instance.readCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    final categoryList = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: selectedCategory,
                      dropdownColor: Colors.grey[900],
                      style: retroStyle,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[900],

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        prefixIcon: Image.asset(
                          'assets/icons/categorias.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                      items: categoryList.map((ModelCategories category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),

                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        }
                      },
                    );
                  } else {
                    //En caso de que se produzca algun error, volvemos a la pantalla de la camara y lanzamos un mensaje de error.
                    Navigator.pop(context);
                    return const Center(
                      child: Text('Error al leer la base de datos'),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              //CANTIDAD
              Text('CANTIDAD:', style: retroStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '$quantity UNIDAD${quantity > 1 ? 'ES' : ''}',
                        style: retroStyle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  //Botón Menos
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  //Botón Más
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              //BOTONES DE CANCELAR Y GUARDAR
              Row(
                children: [
                  //CANCELAR
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,

                          side: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      onPressed: () {
                        // Volvemos atrás sin guardar nada
                        Navigator.pop(context);
                      },
                      child: Text('CANCELAR', style: retroStyle),
                    ),
                  ),
                  //Bloque entre medias para separar
                  const SizedBox(width: 16),

                  //GUARDAR
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      //Si el usuario no ha seleccionado una categoria o fecha de caducidad el boton guardar esta bloqueado.
                      onPressed:
                          (selectedCategory == null ||
                              dateController.text.isEmpty)
                          ? null //Que sea null quiere decir desactivado
                          : () async {
                              int productId;
                              //si el producto proviene de la api:
                              if (widget.scannedProduct.id == null) {
                                //Lo instertamos en la base de datos local y guardamos el id.
                                productId = await insertProductData(
                                  widget.scannedProduct,
                                );
                              } else {
                                productId = widget.scannedProduct.id!;
                              }

                              //Actualizamos la categoria de producto.
                              await updateProductCategory(
                                productId,
                                selectedCategory,
                              );

                              //Actualizmos el objeto nevera con los nuevos datos.
                              ModelFridge fridgeProduct = ModelFridge(
                                productId: productId,
                                quantity: quantity,
                                expirationDate: DateTime.parse(
                                  dateController.text,
                                ),
                              );

                              final int fridgeId = await insertFridgeData(
                                fridgeProduct,
                              );

                              //Comprobamos que no sencontramos en andorid y no windows
                              if (!Platform.isWindows) {
                                await expirationDateNotification(
                                  fridgeId,
                                  widget.scannedProduct.name,
                                  fridgeProduct.expirationDate,
                                );
                              }

                              //Si el usuario se sale de la app, se retorna.
                              if (!mounted) return;
                              //Volvemos a la cámara
                              Navigator.pop(context);
                            },
                      child: Text('GUARDAR', style: retroStyle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<int> insertProductData(ModelProducts product) async {
  return DatabaseHelper.instance.insertProducts(product);
}

Future<void> updateProductCategory(productId, category) async {
  await DatabaseHelper.instance.updateCategory(category, productId);
}

Future<int> insertFridgeData(ModelFridge fridgeProduct) async {
  return await DatabaseHelper.instance.insertGoods(fridgeProduct);
}
