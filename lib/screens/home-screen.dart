import 'package:flutter/material.dart';
import 'package:mobile_shopping_list_app/contants/routes.dart';
import 'package:mobile_shopping_list_app/screens/shopping-list-screen.dart';
import 'package:mobile_shopping_list_app/widgets/primary-button.dart';
import '../services/auth-service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _progressIndicator();
          }

          if (snapshot.hasData) {
            return const ShoppingListScreen();
          }

          return Scaffold(
            body: Column(
              children: [
                Expanded(flex: 4, child: _HomeTopSection()),
                Expanded(flex: 6, child: _HomeBottomSection()),
              ],
            ),
          );
        });
  }

  Widget _progressIndicator() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _HomeTopSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/shopping-list-note.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(206, 83, 83, 0.8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Listify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeBottomSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color.fromRGBO(50, 50, 50, 1),
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo a',
                style: TextStyle(
                  color: Color.fromRGBO(130, 127, 127, 1),
                  fontSize: 32,
                ),
              ),
              Text(
                'Listify!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sua lista de compras digital.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Column(
            children: [
              PrimaryButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.login),
                  text: 'Entrar',
                  icon: const Icon(Icons.login)),
              const SizedBox(height: 16),
              PrimaryButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.register),
                  text: 'Registrar',
                  icon: const Icon(Icons.person_add)),
            ],
          ),
        ],
      ),
    );
  }
}