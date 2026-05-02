import 'package:flutter/material.dart';

class ExpedicaoPage extends StatelessWidget {
  const ExpedicaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expedição")),
      body: const Center(
        child: Text("🚚 Tela de Expedição"),
      ),
    );
  }
}
