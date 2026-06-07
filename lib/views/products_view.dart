import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/model_products.dart';

class ProductsView extends StatefulWidget {
  //llave para hacer ref
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState(); //privado para asegurarnos que las otras vitas no tengan acceso.
}

class _ProductsViewState extends State<ProductsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ModelProducts>>(
        //leemos todos los productos registrados hasta la fecha.
        future: DatabaseHelper.instance.readProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              //constante porque este child nunca va a cambiar o ser modificado.
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            // ! al final pk le debemos de decir a dart que siemrpe va a recibir un dato
            final productsList = snapshot.data!;

            return ListView.separated(
              itemBuilder: (context, index) {
                final actualProduct = productsList[index];

                //pintamos la tarjeta
                return Row(
                  key: ValueKey(actualProduct.id),
                  children: [
                    Image.network(
                      actualProduct.image ?? 'assets/imgs/noImage.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 12),
                    //columna nombre y cantidad
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //nombre del producto
                          Text(actualProduct.name),
                        ],
                      ),
                    ),

                    //columna boton delete y fecha caducidad
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end, // lo movemos al final
                      children: [
                        IconButton(
                          onPressed: () async {
                            //Si borramos un producto de la base de datos local, se borra tambien de la nevera
                            await DatabaseHelper.instance
                                .deleteFullFridgeProduct(actualProduct.id!);

                            await DatabaseHelper.instance.deleteProduct(
                              actualProduct.id!,
                            );
                            //si nos salimos de la app, se cancela el proceso.
                            if (!mounted) return;
                            //una vez modificamos un item del widget, llamamos a setstate
                            setState(() {});
                          },
                          //el icono (dart ya tiene iconos nativos)
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ],
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
    );
  }
}
