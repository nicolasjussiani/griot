// lib/home_screen.dart
import 'package:flutter/material.dart';

// Classe para representar um post no feed
class Post {
  final String userName;
  final String userAvatarUrl;
  final String imageUrl;
  final String caption;
  final int likes;
  final int comments;

  Post({
    required this.userName,
    required this.userAvatarUrl,
    required this.imageUrl,
    required this.caption,
    this.likes = 0,
    this.comments = 0,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Para controlar o item selecionado na barra de navegação inferior

  // Lista de posts de exemplo
  final List<Post> _posts = [
    Post(
      userName: 'Luna_a_Golden',
      userAvatarUrl: 'https://placehold.co/50x50/FFD700/FFFFFF?text=L', // Placeholder para avatar
      imageUrl: 'https://placehold.co/600x400/87CEEB/FFFFFF?text=Pet+Photo+1', // Placeholder para imagem
      caption: 'Dia de sol perfeito para brincar no parque! ☀️ #goldenretriever #vidapet',
      likes: 123,
      comments: 15,
    ),
    Post(
      userName: 'Max_o_Pug',
      userAvatarUrl: 'https://placehold.co/50x50/A9A9A9/FFFFFF?text=M', // Placeholder para avatar
      imageUrl: 'https://placehold.co/600x400/FFB6C1/FFFFFF?text=Pet+Photo+2', // Placeholder para imagem
      caption: 'Soneca da tarde é lei por aqui. 😴 #puglife #dogsofinstagram',
      likes: 88,
      comments: 8,
    ),
    Post(
      userName: 'Mia_a_Gatinha',
      userAvatarUrl: 'https://placehold.co/50x50/9370DB/FFFFFF?text=M', // Placeholder para avatar
      imageUrl: 'https://placehold.co/600x400/ADD8E6/FFFFFF?text=Pet+Photo+3', // Placeholder para imagem
      caption: 'Conquistando o mundo, um arranhador por vez. 😼 #catlover #gatosfofos',
      likes: 201,
      comments: 22,
    ),
    Post(
      userName: 'Bolinha_o_Hamster',
      userAvatarUrl: 'https://placehold.co/50x50/F08080/FFFFFF?text=B', // Placeholder para avatar
      imageUrl: 'https://placehold.co/600x400/DDA0DD/FFFFFF?text=Pet+Photo+4', // Placeholder para imagem
      caption: 'Hora do lanche! 🐹🥕 #hamster #roedor',
      likes: 45,
      comments: 5,
    ),
    Post(
      userName: 'Zeus_o_Labrador',
      userAvatarUrl: 'https://placehold.co/50x50/3CB371/FFFFFF?text=Z', // Placeholder para avatar
      imageUrl: 'https://placehold.co/600x400/FFDEAD/FFFFFF?text=Pet+Photo+5', // Placeholder para imagem
      caption: 'Aquele olhar de quem quer mais um passeio. 👀 #labrador #doglife',
      likes: 150,
      comments: 18,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Aqui você pode adicionar a lógica para navegar para diferentes telas
    // com base no índice selecionado.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegação para o índice: $index')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Griot', // Nome do seu aplicativo
          style: TextStyle(
            fontFamily: 'Billabong', // Use uma fonte que lembre o Instagram, se tiver
            fontSize: 32,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // Alinha o título à esquerda
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Adicionar novo post!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ver atividades!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrir Direct!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            elevation: 0, // Remove a elevação do card para um visual mais plano
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho do Post (Avatar e Nome de Usuário)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(post.userAvatarUrl),
                        backgroundColor: Colors.grey[200], // Fallback color
                      ),
                      const SizedBox(width: 10),
                      Text(
                        post.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opções para ${post.userName}')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Imagem do Post
                Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width, // Imagem quadrada
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      height: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
                // Botões de Ação (Curtir, Comentar, Compartilhar, Salvar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Curtiu o post de ${post.userName}')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Comentar no post de ${post.userName}')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Compartilhar post de ${post.userName}')),
                          );
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Salvar post de ${post.userName}')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Contagem de Curtidas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '${post.likes} curtidas',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                // Legenda do Post
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: '${post.userName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                ),
                // Ver todos os comentários
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ver todos os ${post.comments} comentários')),
                      );
                    },
                    child: Text(
                      'Ver todos os ${post.comments} comentários',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Garante que todos os itens são visíveis
        backgroundColor: Colors.white,
      ),
    );
  }
}
