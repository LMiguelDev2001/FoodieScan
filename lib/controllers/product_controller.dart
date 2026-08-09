import 'package:foodie_scan/models/model_products.dart';

import '../services/api_service.dart';

import '../services/database_helper.dart';

class ProductController {
  Future<ModelProducts?> processBarcode(String barcode) async {
    //Llama a DatabaseHelper e intenta leer el producto (comprobar si esta registrado en local).
    ModelProducts? obtainedProduct = await DatabaseHelper.instance
        .readProductByBarcode(barcode);
    if (obtainedProduct == null) {
      try {
        print('lo esta buscando en la api');
        //Busca el producto en la api externa.
        var apiProductReq = await ApiService.getProduct(barcode);
        if (apiProductReq == null) {
          return null;
        }

        ModelProducts apiObtainedProduct = ModelProducts(
          //se ponen los '?' porque los parametros pueden ser nulos y en caso de serlo (??)
          // tenemo que escribir una alternativa
          code: apiProductReq?.barcode ?? barcode,
          name: apiProductReq?.productName ?? 'no name',
          image: apiProductReq?.imageFrontSmallUrl ?? 'imagen por defecto',
          categoryId: null,
        );
        //Insertamos el producto en la base de datos local.
        //await DatabaseHelper.instance.insertProducts(apiObtainedProduct);
        //Le pasamos el producto obtenido a FormView

        return apiObtainedProduct;
      } catch (error) {
        throw Exception("Error de conexcion: $error");
      }
      //En caso de que NO sea null (de que existe en la bbdd local).
    } else {
      //Le pasamos el producto obtenido a FormView

      return obtainedProduct;
    }
  }
}
