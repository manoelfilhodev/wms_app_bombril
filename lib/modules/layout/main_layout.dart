import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final String? usuario; // nome do usuário (opcional)

  const MainLayout({
    super.key,
    required this.title,
    required this.child,
    this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF435ebe); // Azul padrão Mazer

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            if (usuario != null)
              Text(
                "👋 Bem-vindo, $usuario",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF435ebe)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "📦 Systex WMS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(context, Icons.dashboard, "Dashboard", "/dashboard", primaryColor),
                  _drawerItem(context, Icons.local_shipping, "Recebimento", "/recebimento", primaryColor),
                  _drawerItem(context, Icons.inventory, "Armazenagem", "/armazenagem", primaryColor),
                  _drawerItem(context, Icons.list_alt, "Separação", "/separacao", primaryColor),
                  _drawerItem(context, Icons.local_mall, "Expedição", "/expedicao", primaryColor),
                  _drawerItem(context, Icons.assignment, "Inventário", "/inventario", primaryColor),
                  _drawerItem(context, Icons.people, "Usuários", "/usuarios", primaryColor),
                  _drawerItem(context, Icons.settings, "Configurações", "/config", primaryColor),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Sair"),
              onTap: () {
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
            Container(
              height: 40,
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, size: 14, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    "Versão 1.0.0  •  Desenvolvido por: Systex SI",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem(
      BuildContext context, IconData icon, String label, String route, Color primaryColor) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(label),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
