import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/model_products.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'dart:io' show Platform;
import '../models/model_fridge.dart';

class ProductsView extends StatefulWidget {
  //Llave para hacer ref
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState(); //Privado para asegurarnos que las otras vitas no tengan acceso.
}

class _ProductsViewState extends State<ProductsView> {
  //Variable global para nuestra fuente
  final TextStyle retroStyle = GoogleFonts.pixelifySans(
    textStyle: TextStyle(color: Colors.white, fontSize: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text('PRODUCTOS', style: retroStyle.copyWith(fontSize: 19)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<ModelProducts>>(
          //Leemos todos los productos registrados hasta la fecha.
          future: DatabaseHelper.instance.readProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                //Constante porque este child nunca va a cambiar o ser modificado.
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              // ! Al final pk le debemos de decir a dart que siemrpe va a recibir un dato
              final productsList = snapshot.data!;

              return ListView.separated(
                padding: EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final actualProduct = productsList[index];

                  //Pintamos la tarjeta
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Row(
                      key: ValueKey(actualProduct.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          actualProduct.image ?? 'assets/imgs/noImage.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/icons/notFound.png');
                          },
                        ),
                        const SizedBox(width: 12),

                        //Columna nombre y cantidad
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Nombre del producto
                              Text(
                                actualProduct.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: retroStyle.copyWith(
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        //Columna boton delete y fecha caducidad
                        GestureDetector(
                          // Lo movemos al final
                          onTap: () async {
                            if (!Platform.isWindows) {
                              ModelFridge? fridgeProduct = await DatabaseHelper
                                  .instance
                                  .readFridgeProductByProductId(
                                    actualProduct.id!,
                                  );
                              if (fridgeProduct != null &&
                                  fridgeProduct.id != null) {
                                //0 dias
                                await notifications.cancel(
                                  id: (fridgeProduct.id! * 10),
                                );

                                //1 dia
                                await notifications.cancel(
                                  id: (fridgeProduct.id! * 10) + 1,
                                );
                                //3 dias
                                await notifications.cancel(
                                  id: (fridgeProduct.id! * 10) + 3,
                                );

                                //7 dias
                                await notifications.cancel(
                                  id: (fridgeProduct.id! * 10) + 7,
                                );
                              }
                            }

                            //Si borramos un producto de la base de datos local, se borra tambien de la nevera
                            await DatabaseHelper.instance
                                .deleteFullFridgeProduct(actualProduct.id!);

                            //Borramos las notificaiones programadas
                            //Tenemos que multiplicarlo *10 pk no buscan el id del producto, busca el de la notificaion (idProducto * 10)

                            await DatabaseHelper.instance.deleteProduct(
                              actualProduct.id!,
                            );
                            //Si nos salimos de la app, se cancela el proceso.
                            if (!mounted) return;
                            //Una vez modificamos un item del widget, llamamos a setstate
                            setState(() {});
                          },
                          //El icono (dart ya tiene iconos nativos)
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Image.asset(
                              'assets/icons/basura.png',
                              fit: BoxFit.contain,
                              width: 24,
                              height: 24,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: productsList.length,
              );
            } else {
              return const Center(child: Text('Error al cargar los productos'));
            }
          },
        ),
      ),
    );
  }
}
