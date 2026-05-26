import 'package:foodie_scan/models/model_products.dart';

import '../services/api_service.dart';

import '../services/database_helper.dart';

class ProductController {
  Future<ModelProducts?> processBarcode(String barcode) async {
    //llama a DatabaseHelper e intenta leer el producto (comprobar si esta registrado en local).
    ModelProducts? obtainedProduct = await DatabaseHelper.instance
        .readProductByBarcode(barcode);
    if (obtainedProduct == null) {
      try {
        //busca el producto en la api externa.
        var apiProductReq = await ApiService.getProduct(barcode);

        ModelProducts apiObtainedProduct = ModelProducts(
          //se ponen los '?' porque los parametros pueden ser nulos y en caso de serlo (??)
          // tenemo que escribir una alternativa
          code: apiProductReq?.barcode ?? barcode,
          name: apiProductReq?.productName ?? 'no name',
          image: apiProductReq?.imageFrontSmallUrl ?? 'imagen por defecto',
          categoryId: null,
        );
        //insertamos el producto en la base de datos local.
        await DatabaseHelper.instance.insertProducts(apiObtainedProduct);

        return apiObtainedProduct;
      } catch (er) {
        print('error: $er');
        return null;
      }
      //en caso de que NO sea null (de que existe en la bbdd local).
    } else {
      return obtainedProduct;
    }
  }
}
