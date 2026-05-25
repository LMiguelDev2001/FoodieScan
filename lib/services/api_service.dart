import 'package:openfoodfacts/openfoodfacts.dart';

class ApiService {
  static Future<Product?> getProduct(String barcode) async {
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'FoodieScan');

    //se pone el signo de interrogacion pk cabe la posibildiad que el producto no este registrado.
    Future<String> barcodeReciever(String barcode) async {
      return barcode;
    }

    Future<String> Function(String barcode) barcode = barcodeReciever;

    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode as String,
      language: OpenFoodFactsLanguage.SPANISH,
      fields: [
        ProductField.NAME,
        ProductField.BARCODE,
        ProductField.IMAGE_FRONT_SMALL_URL,
      ],
      version: ProductQueryVersion.v3,
    );

    //obtenemos el producto segun nuestra configuracion.
    final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
      configuration,
    );

    if (result.status == ProductResultV3.statusSuccess) {
      //RECUERDA QUITAR LOS PRINTSSSSSSSS
      print('funciona');
      print(result.product?.productName);
      print(result.product?.imageFrontSmallUrl);
      return result.product;
    } else {
      throw Exception(
        'el producto con el codigo de barras: $barcode no ha sido encontrado',
      );
    }
  }
}

void main() async {
  String barcode = '123';
  await ApiService.getProduct(barcode);
}
