import 'package:flutter/material.dart';

import '../widgets/product_card.dart';
import '../widgets/searchbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Put your search bar, banners, and product grid here!
              KosplySearchbar(),
              SizedBox(height: 30),
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
