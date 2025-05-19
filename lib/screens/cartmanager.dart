class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  void addToCart(Map<String, dynamic> car) {
    _cartItems.add(car);
  }

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void clearCart() {
    _cartItems.clear();
  }
}
