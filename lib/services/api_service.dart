import 'package:openfoodfacts/openfoodfacts.dart';

class ApiService {
  static Future<Product?> getProduct(String barcode) async {
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'FoodieScan');

    //se pone el signo de interrogacion pk cabe la posibildiad que el producto no este registrado.

    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.SPANISH,
      fields: [
        ProductField.NAME,
        ProductField.BARCODE,
        ProductField.IMAGE_FRONT_SMALL_URL,
      ],
      version: ProductQueryVersion.v3,
    );

    //obtenemos el producto segun nuestra configuracion.
    try {
      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        configuration,
      );

      if (result.status == ProductResultV3.statusSuccess) {
        return result.product;
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Fallo por parte de la api externa');
    }
  }
}
