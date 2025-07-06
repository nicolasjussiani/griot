// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa o pacote Firebase Core
import 'firebase_options.dart'; // Importa o arquivo de opções do Firebase (gerado automaticamente)
import 'login_screen.dart'; // Importa a sua tela de login

void main() async { // Marque main como async para usar await
  WidgetsFlutterBinding.ensureInitialized(); // Garante que os bindings do Flutter estejam inicializados

  // Inicializa o Firebase antes de rodar o aplicativo
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Griot - Sua Rede Social Pet', // Dê um título para sua aplicação
      theme: ThemeData(
        // Tema básico da aplicação
        primarySwatch: Colors.deepPurple, // Cor primária (afeta AppBar, etc.)
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // Recomendado para novos projetos Flutter
      ),
      debugShowCheckedModeBanner: false, // Remove o banner "Debug" no canto superior direito

      // Define a tela inicial da sua aplicação
      home: const LoginScreen(),

      // (Opcional) Definindo rotas nomeadas para navegação:
      // Se você planeja ter várias telas e quer uma forma mais organizada de navegar,
      // você pode definir rotas nomeadas.
      // routes: {
      //   '/': (context) => const LoginScreen(), // Rota inicial
      //   '/home': (context) => const HomeScreen(), // Exemplo de rota para a home
      //   // '/profile': (context) => const ProfileScreen(),
      //   // ... outras rotas
      // },
      // Se usar rotas nomeadas, 'home' seria substituído por initialRoute: '/'
      // e você não usaria 'home' diretamente, mas sim Navigator.pushNamed(context, '/home').
    );
  }
}