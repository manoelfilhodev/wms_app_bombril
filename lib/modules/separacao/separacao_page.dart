import 'package:flutter/material.dart';

class SeparacaoPage extends StatelessWidget {
  const SeparacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Separação")),
      body: const Center(
        child: Text("📑 Tela de Separação"),
      ),
    );
  }
}
