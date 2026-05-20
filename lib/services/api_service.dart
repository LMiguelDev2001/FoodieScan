import 'package:openfoodfacts/openfoodfacts.dart';

class ApiService {
  Future<Product?> getProduct() async {
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'FoodieScan');

    //se pone el signo de interrogacion pk cabe la posibildiad que el producto no este registrado.
    var barcode = '8480000171320';

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
  ApiService miApi = ApiService();
  await miApi.getProduct();
}
