import 'package:flutter/material.dart';

class TrackProductPage extends StatelessWidget {
  const TrackProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFF1C1F2E),
  elevation: 0,
  surfaceTintColor: Colors.transparent,

  leading: Padding(
    padding: const EdgeInsets.only(left: 12),
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF3A3D4E),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    ),
  ),

  titleSpacing: 8,
  title: const Text(
    'Lacak Donasi Saya',
    style: TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  ),

  

  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(
      height: 1,
      color: const Color(0xFF2A2D3E),
    ),
  ),
),
      body: const SizedBox.expand(),
    );
  }
}
