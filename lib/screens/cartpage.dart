import 'package:carmarketplace/screens/cartmanager.dart';
import 'package:flutter/material.dart';


class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartItems = CartManager().cartItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Image.network(
                    item['imageUrl'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['name'] ?? ''),
                  subtitle: Text(
                      '${item['priceType'] == 'buy' ? 'Buy' : 'Rent'} Price: \$${item['selectedPrice']}'),
                  trailing: Text('Qty: ${item['quantity']}'),
                );
              },
            ),
    );
  }
}
