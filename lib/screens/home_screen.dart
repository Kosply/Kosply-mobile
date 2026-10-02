import 'package:flutter/material.dart';

import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Kosply Home'), elevation: 0),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Put your search bar, banners, and product grid here!
              Row(
                children: [
                  Expanded(
                    child: ProductCard(
                      title: 'Sepatu',
                      price: 'Rp.400.000',
                      location: 'Dekat gedung a',
                      imagePath: 'assets/images/lamp.jpg',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ProductCard(
                      title: 'Rice Cooker',
                      price: 'Rp.400.000',
                      location: 'Dekat gedung a',
                      imagePath: 'assets/images/lamp.jpg',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
