import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/model_fridge.dart';

class FridgeView extends StatefulWidget {
  //llave para hacer ref
  const FridgeView({super.key});

  @override
  State<FridgeView> createState() => _FridgeViewState(); //privado para asegurarnos que las otras vitas no tengan acceso.
}

class _FridgeViewState extends State<FridgeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ModelFridge>>(
        future: DatabaseHelper.instance.readGoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              //constante porque este child nunca va a cambiar o ser modificado.
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final fridgeList = snapshot
                .data!; // ! al final pk le debemos de decir a dart que siemrpe va a recibir un dato

            return ListView.separated(
              itemBuilder: (context, index) {
                final actualFridgeItem = fridgeList[index];

                //pintamos la tarjeta
                return Row(
                  key: ValueKey(actualFridgeItem.id),
                  children: [
                    Image.asset(
                      actualFridgeItem.productImage ??
                          'assets/imgs/noImage.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 12),
                    //columna nombre y cantidad
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //nombre del producto
                        Text(actualFridgeItem.productName ?? 'no name'),
                        //fecha de caducidad del producto
                        Text('Cantidad: ${actualFridgeItem.quantity}'),
                      ],
                    ),
                    //columna boton delete y fecha caducidad
                    const Spacer(), //empujamos el resto de elementos hacia los lados
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end, // lo movemos al final
                      children: [
                        IconButton(
                          onPressed: () async {
                            await DatabaseHelper.instance.deleteProduct(
                              actualFridgeItem.id!,
                            );

                            //una vez modificamos un item del widget, llamamos a setstate
                            setState(() {});
                          },
                          icon: const Icon(Icons.delete),
                        ),
                        //fecha de caducidad del producto
                        Text(
                          'CAD: ${actualFridgeItem.expirationDate.toIso8601String()}',
                        ),
                      ],
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: fridgeList.length,
            );
          } else {
            return const Center(child: Text('Error al cargar el producto'));
          }
        },
      ),
    );
  }
}
