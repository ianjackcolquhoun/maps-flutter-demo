/// Cart model representing a golf cart in the system
class Cart {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const Cart({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Mock cart data for demo - 3 carts around Cincinnati
  static List<Cart> getMockCarts() {
    return [
      const Cart(
        id: 'CART-001',
        name: 'Findlay Market Cart',
        latitude: 39.1116,
        longitude: -84.5158,
      ),
      const Cart(
        id: 'CART-002',
        name: 'Fountain Square Cart',
        latitude: 39.1020,
        longitude: -84.5120,
      ),
      const Cart(
        id: 'CART-003',
        name: 'Washington Park Cart',
        latitude: 39.1088,
        longitude: -84.5180,
      ),
    ];
  }
}
