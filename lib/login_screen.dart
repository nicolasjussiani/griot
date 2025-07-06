// lib/login_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Você precisará criar este arquivo para a tela principal
import 'package:google_sign_in/google_sign_in.dart'; // Importa o pacote Google Sign-In
import 'package:firebase_auth/firebase_auth.dart'; // Importa o pacote Firebase Auth
import 'package:firebase_core/firebase_core.dart'; // Importa para inicialização do Firebase

// 1. Define a classe LoginScreen como um StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Construtor padrão para Widgets

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// 2. Define a classe _LoginScreenState, que gerencia o estado e a UI da tela de login
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instâncias do GoogleSignIn e FirebaseAuth
  // Correção 1: Inicialize GoogleSignIn (geralmente o construtor padrão funciona para versões recentes)
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // A inicialização do Firebase é melhor feita no main.dart de forma assíncrona
    // mas para este exemplo, garantimos que é chamado.
    // Em um app real, use: WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(); no main().
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    // É uma boa prática inicializar o Firebase de forma assíncrona.
    // Se já estiver inicializado, esta chamada não fará nada prejudicial.
    await Firebase.initializeApp();
  }


  // Método para lidar com o login tradicional (e-mail/senha)
  void _handleLogin() async { // Marcar como async para usar await com Firebase Auth
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog('Erro de Login', 'Por favor, preencha todos os campos.');
      return;
    }

    try {
      // Tenta fazer login com e-mail e senha usando Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Se o login for bem-sucedido, userCredential.user não será nulo
      if (userCredential.user != null) {
        _emailController.clear();
        _passwordController.clear();

        _showAlertDialog('Login Bem-Sucedido!', 'Bem-vindo, ${userCredential.user!.email}!', () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocorreu um erro ao fazer login.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Nenhum usuário encontrado para esse e-mail.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta fornecida para esse usuário.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O formato do e-mail é inválido.';
      }
      // Você pode adicionar mais tratamentos de erro específicos aqui
      // e.g. e.message para uma mensagem mais genérica do Firebase
      _showAlertDialog('Erro de Login', e.message ?? errorMessage);
    } catch (e) {
      _showAlertDialog('Erro de Login', 'Ocorreu um erro desconhecido. Tente novamente.');
      print('Erro de Login (Tradicional): $e');
    }
  }


  // Método para lidar com o login do Google
  Future<void> _handleGoogleSignIn() async {
    try {
      // 1. Inicia o fluxo de login do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); // Erro 2 aqui se _googleSignIn não estiver correto

      if (googleUser == null) {
        // O usuário cancelou o login do Google
        _showAlertDialog('Login Cancelado', 'Você cancelou o login com o Google.');
        return;
      }

      // 2. Obtém as credenciais de autenticação do Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Cria uma credencial do Firebase com as credenciais do Google
      // Correção 3: accessToken e idToken devem estar disponíveis diretamente
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Deve funcionar
        idToken: googleAuth.idToken,          // Deve funcionar
      );

      // 4. Entra no Firebase usando a credencial do Google
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _showAlertDialog('Login Google Bem-Sucedido!', 'Bem-vindo, ${user.displayName ?? user.email}!', () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      // Erros específicos do Firebase Auth
      _showAlertDialog('Erro de Autenticação Firebase', e.message ?? 'Ocorreu um erro ao autenticar com o Google.');
      print('FirebaseAuthException durante Google Sign-In: ${e.code} - ${e.message}');
    } catch (e) {
      // Outros erros (ex: problemas de rede, configuração)
      _showAlertDialog('Erro de Login Google', 'Não foi possível fazer login com o Google. Verifique sua conexão ou tente novamente.');
      print('Erro de Google Sign-In: $e');
    }
  }

  void _showAlertDialog(String title, String message, [VoidCallback? onOkPressed]) {
    // ... (seu código _showAlertDialog permanece o mesmo)
    showDialog(
      context: context,
      barrierDismissible: false, // Impede que o diálogo seja fechado ao tocar fora
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.deepPurple)), // Usa uma cor de destaque
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                if (onOkPressed != null) {
                  onOkPressed(); // Executa o callback se ele existir
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (seu código build permanece o mesmo)
    final Size screenSize = MediaQuery.of(context).size;
    String textoaleatorio = 'Entre para se conectar com seus amigos peludos';
    DateTime dataatual = DateTime.now();
    String imagem = "https://s1.1zoom.me/b5050/841/Portugal_Houses_Lisbon_Night_539691_1920x1080.jpg";
    if (dataatual.hour >= 19) {
      textoaleatorio = 'Tá em uma festa e ficou no tédio né....';
      imagem = 'https://s1.1zoom.me/b5050/841/Portugal_Houses_Lisbon_Night_539691_1920x1080.jpg';
    } else {
      textoaleatorio = 'Entre para se conectar com seus amigos peludos';
      imagem = 'https://s1.1zoom.me/b5050/841/Portugal_Houses_Lisbon_Night_539691_1920x1080.jpg';
    }


    return Scaffold(
      body: Stack(
        children: [
          // Imagem de Fundo (substitua pelo seu URL ou asset)
          Positioned.fill(
            child: Image.network(
              imagem, // Placeholder
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.pets, size: 100, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          // Sobreposição Escura para melhor legibilidade do texto
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55), // Ajusta a opacidade conforme necessário
            ),
          ),
          // Conteúdo do Formulário de Login
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Para esticar o botão
                children: <Widget>[
                  // Título
                  Text(
                    'Bem-vindo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenSize.width * 0.09,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 10.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  // Subtítulo
                  Text(
                    textoaleatorio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenSize.width * 0.045,
                      color: Colors.white70, // Um pouco mais suave
                      shadows: const [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 5.0,
                          color: Color.fromARGB(100, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),

                  // Campo de Entrada de E-mail
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'E-mail',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  // Campo de Entrada de Senha
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Senha',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: screenSize.height * 0.035),

                  // Botão de Login (E-mail/Senha)
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61), // Cor vibrante do botão
                      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.4),
                    ),
                    child: Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  // Divisor ou texto "OU"
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OU',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: screenSize.width * 0.035),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ),

                  // Botão de Login com Google
                  ElevatedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/2048px-Google_%22G%22_logo.svg.png', // Ícone do Google
                      height: screenSize.width * 0.06,
                      width: screenSize.width * 0.06,
                    ),
                    label: Text(
                      'Entrar com Google',
                      style: TextStyle(
                        color: Colors.black87, // Cor do texto para o botão do Google
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Fundo branco para o botão do Google
                      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.4),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  // Botão Teste (Adicionado)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Cor para o botão de teste
                      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.4),
                    ),
                    child: Text(
                      'Botão Teste (Pular Login)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02), // Espaçamento após o novo botão

                  // Link Esqueceu a Senha
                  TextButton(
                    onPressed: () {
                      _showAlertDialog('Esqueceu a Senha?', 'Esta funcionalidade será implementada em breve.');
                    },
                    child: Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: screenSize.width * 0.038,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),

                  // Link Cadastre-se
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem uma conta? ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: screenSize.width * 0.038,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Aqui você pode navegar para uma tela de cadastro
                          _showAlertDialog('Cadastre-se', 'Redirecionando para a tela de cadastro...');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Cadastre-se',
                          style: TextStyle(
                            color: Colors.white, // Cor de destaque
                            fontSize: screenSize.width * 0.038,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar campos de texto estilizados
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // ... (seu código _buildTextField permanece o mesmo)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25), // Opacidade levemente aumentada
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.85)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Ajuste de padding
        ),
      ),
    );
  }
}
