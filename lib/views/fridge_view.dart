import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/model_fridge.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'dart:io' show Platform;

class FridgeView extends StatefulWidget {
  //llave para hacer ref
  const FridgeView({super.key});

  @override
  State<FridgeView> createState() => _FridgeViewState(); //privado para asegurarnos que las otras vitas no tengan acceso.
}

class _FridgeViewState extends State<FridgeView> {
  //Variable global para nuestra fuente
  final TextStyle retroStyle = GoogleFonts.pixelifySans(
    textStyle: TextStyle(color: Colors.white, fontSize: 16),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text('MI INVENTARIO', style: retroStyle.copyWith(fontSize: 19)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<ModelFridge>>(
          future: DatabaseHelper.instance.readGoods(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                //Constante porque este child nunca va a cambiar o ser modificado.
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              final fridgeList = snapshot
                  .data!; // ! Al final pk le debemos de decir a dart que siemrpe va a recibir un dato

              return ListView.separated(
                padding: EdgeInsets.all(12),

                itemBuilder: (context, index) {
                  final actualFridgeItem = fridgeList[index];

                  //Pintamos la tarjeta
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Row(
                      key: ValueKey(actualFridgeItem.id),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          actualFridgeItem.productImage ??
                              'assets/imgs/noImage.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/icons/notFound.png');
                          },
                        ),
                        const SizedBox(width: 12),

                        //Datos del producto
                        //Columna nombre y cantidad
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              //Nombre del producto
                              Text(
                                actualFridgeItem.productName ?? 'no name',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: retroStyle.copyWith(
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 4),

                              //Fecha de caducidad del producto
                              Text(
                                'Cantidad: ${actualFridgeItem.quantity}',
                                style: retroStyle,
                              ),
                              const SizedBox(height: 4),

                              Text(
                                'CAD: ${actualFridgeItem.expirationDate.toIso8601String().split('T')[0]}',
                                style: retroStyle.copyWith(
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        //Columna boton borrar
                        //Empujamos el resto de elementos hacia los lados
                        GestureDetector(
                          //Lo movemos al final
                          onTap: () async {
                            int deletedRows = await DatabaseHelper.instance
                                .deleteIndividualFridgeProduct(
                                  actualFridgeItem.id!,
                                );
                            //Una vez modificamos un item del widget, llamamos a setstate
                            setState(() {});

                            //Tenemos que multiplicarlo *10 pk no buscan el id del producto, busca el de la notificaion (idProducto * 10)
                            if (!Platform.isWindows && deletedRows == 1) {
                              //0 dias
                              await notifications.cancel(
                                id: (actualFridgeItem.id! * 10),
                              );

                              //1 dia
                              await notifications.cancel(
                                id: (actualFridgeItem.id! * 10) + 1,
                              );
                              //3 dias
                              await notifications.cancel(
                                id: (actualFridgeItem.id! * 10) + 3,
                              );

                              //7 dias
                              await notifications.cancel(
                                id: (actualFridgeItem.id! * 10) + 7,
                              );
                            }
                          },
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
                itemCount: fridgeList.length,
              );
            } else {
              return const Center(child: Text('Error al cargar el producto'));
            }
          },
        ),
      ),
    );
  }
}
