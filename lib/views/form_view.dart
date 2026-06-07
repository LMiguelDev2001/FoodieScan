import 'package:flutter/material.dart';
import 'package:foodie_scan/models/model_categories.dart';
import 'package:foodie_scan/models/model_fridge.dart';
import '../models/model_products.dart';
import '../services/database_helper.dart';
import '../main.dart';

class FormView extends StatefulWidget {
  //Variable global para almacenar los datos del producto escaneado recibido a traves de la constante FromView.
  final ModelProducts productoEscaneado;

  const FormView({super.key, required this.productoEscaneado});

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  //variables globales
  int cantidad = 1;
  //La fecha es el unico campo en el que el usuraio "escribira" datos manualmente.
  //Es por ello que es el unico campo en el que empleamos "TextEditingController".
  final TextEditingController fechaController = TextEditingController();
  int? selectedCategory;

  @override
  void dispose() {
    //Cuando cambiamos de vista, textcontroller no se destruye, se queda en la memoria ne el limbo.
    //Tenemos que indicarle esplicitamente a nuestra vista que elimine controller.
    fechaController.dispose();
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
        fechaController.text = fechaElegida.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text(
          'REGISTRAR ALIMENTO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, //quitamos la flecha de volver por defecto
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //IMG DEL PRODUCTO
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent, width: 2),
                ),
                //Si existe una imagen, iniciamos Image.network. Si no existe iniciamos Image.asset para insertar la imagen guardada en local
                child: widget.productoEscaneado.image != null
                    ? Image.network(
                        widget.productoEscaneado.image ??
                            'assets/imgs/noImage.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.fastfood,
                              size: 100,
                              color: Colors.white,
                            ),
                      )
                    : Image.asset(
                        'assets/imgs/noImage.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 24),

            //PRODUCTO
            const Text(
              'PRODUCTO:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.productoEscaneado.name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            //FECHA DE CADUCIDAD
            const Text(
              'FECHA CADUCIDAD:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: _seleccionarFecha,
                    //Hacemos que el usuario no pueda escribir. De esta forma solo puede acceder a la opcion del calendario.
                    controller: fechaController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'DD/MM/AAAA',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    //OCR LOGIC
                    print("Abrir cámara para escanear fecha");
                  },
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.greenAccent,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //CATEGORÍA
            const Text(
              'CATEGORÍA:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                    initialValue: selectedCategory,
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.local_drink,
                        color: Colors.white,
                      ),
                    ),
                    items: categoryList.map((ModelCategories category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
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
                  //en caso de que se produzca algun error, volvemos a la pantalla de la camara y lanzamos un mensaje de error.
                  Navigator.pop(context);
                  return const Center(
                    child: Text('Error al guardar el formulario'),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            //CANTIDAD
            const Text(
              'CANTIDAD:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$cantidad UNIDAD${cantidad > 1 ? 'ES' : ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                //Botón Menos
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      if (cantidad > 1) {
                        setState(() {
                          cantidad--;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                //Botón Más
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        cantidad++;
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Volvemos atrás sin guardar nada
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                //caja entre medias para separar
                const SizedBox(width: 16),

                //GUARDAR
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    //Si el usuario no ha seleccionado una categoria o fecha de caducidad el boton guardar esta bloqueado.
                    onPressed:
                        (selectedCategory == null ||
                            fechaController.text.isEmpty)
                        ? null
                        : () async {
                            //si el producto proviene de la api:
                            if (widget.productoEscaneado.id == null) {
                              //Lo instertamos en la base de datos local.
                              final productId = await insertProductData(
                                widget.productoEscaneado,
                              );
                              //Actualizamos la categoria de producto.
                              //Una vez el producto esta registrado, ya deberia existir widget.productoEscaneado.id.

                              await updateProductCategory(
                                productId,
                                selectedCategory,
                              );

                              //Lo insertamos en nuestro inventario
                              ModelFridge fridgeProduct = ModelFridge(
                                productId: productId,
                                quantity: cantidad,
                                expirationDate: DateTime.parse(
                                  fechaController.text,
                                ),
                              );

                              await insertFridgeData(fridgeProduct);
                              //Si el producto proviene de la base de datos local:
                            } else if (widget.productoEscaneado.id != null) {
                              ModelFridge fridgeProduct = ModelFridge(
                                productId: widget.productoEscaneado.id!,
                                quantity: cantidad,
                                expirationDate: DateTime.parse(
                                  fechaController.text,
                                ),
                              );

                              await insertFridgeData(fridgeProduct);
                            }
                            //Si el usuario se sale de la app, se retorna.
                            if (!mounted) return;
                            //Volvemos a la cámara
                            Navigator.pop(context);
                          },
                    child: const Text(
                      'GUARDAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

Future<void> insertFridgeData(ModelFridge fridgeProduct) async {
  await DatabaseHelper.instance.insertGoods(fridgeProduct);
}
