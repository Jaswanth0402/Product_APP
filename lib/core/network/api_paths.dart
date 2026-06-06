abstract final class ApiPaths {
  static const String products = '/products';
  static const String addProduct = '/products/add';
  static String product(int id) => '/products/$id';
  static String updateProduct(int id) => '/products/$id';
  static String deleteProduct(int id) => '/products/$id';
  static const String searchProducts = '/products/search';
}
