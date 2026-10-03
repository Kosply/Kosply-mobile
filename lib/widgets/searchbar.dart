import 'package:flutter/material.dart';

class KosplySearchbar extends StatelessWidget {
  const KosplySearchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Cari meja belajar, kipas, rice cooker...',
      hintStyle: WidgetStateProperty.all(const TextStyle(color: Colors.grey)),
      leading: const Icon(
        Icons.search,
        color: Color(0xFF9333EA),
      ), // Search magnifier icon
      trailing: [
        IconButton(
          icon: const Icon(Icons.mic_none_outlined, color: Color(0xFF9333EA)),
          onPressed: () {},
        ),
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: const BoxDecoration(
            color: Color(0xFFEDE9FE), // Light purple circular button background
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF9333EA),
            ), // Filter / Tune icon
            onPressed: () {},
          ),
        ),
      ],
      elevation: WidgetStateProperty.all(
        0,
      ), // Keeps it flat without heavy shadow
      backgroundColor: WidgetStateProperty.all(Colors.white),
      side: WidgetStateProperty.all(
        const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 1.0,
        ), // Outer pill border
      ),
      shape: WidgetStateProperty.all(
        const StadiumBorder(), // Gives it that fully rounded pill capsule shape
      ),
    );
  }
}
