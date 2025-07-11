import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addbookpage.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final int publishYear;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publishYear,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      author: json['author'],
      publishYear: json['publishYear'] ?? 0,
      description: json['description'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Book> books = [];
  bool isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    fetchBooks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.195.238:3000/api/books'));
      if (response.statusCode == 200) {
        final List<dynamic> booksJson = json.decode(response.body);
        setState(() {
          books = booksJson.map((json) => Book.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading books: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.195.238:3000/api/books'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': book.title,
          'author': book.author,
          'publishYear': book.publishYear,
          'description': book.description,
        }),
      );

      if (response.statusCode == 201) {
        final newBook = Book.fromJson(json.decode(response.body));
        setState(() {
          books.add(newBook);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Book added successfully!'),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding book: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://192.168.195.238:3000/api/books/$id'));
      if (response.statusCode == 200) {
        setState(() {
          books.removeWhere((book) => book.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Book deleted successfully'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting book: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000),
              Color(0xFF1A1A1A),
              Color(0xFF2D2D2D),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar with Glassmorphism
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Book Collection',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Discover and manage your favorite books',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content with Animation
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : books.isEmpty
                              ? _buildEmptyState()
                              : _buildBookList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const AddBookPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
            if (result != null) {
              await addBook(result);
            }
          },
          backgroundColor: const Color(0xFF333333),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 28),
          label: const Text(
            'Add Book',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'No books yet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start building your collection\nby adding your first book with title, author, publish year, and description!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          child: Row(
            children: [
              const Text(
                'Your Books',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '${books.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                margin: const EdgeInsets.only(bottom: 20),
                child: _buildBookCard(book, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book, int index) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D2D2D),
              const Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                                 Stack(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(15),
                       decoration: BoxDecoration(
                         gradient: const LinearGradient(
                           colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
                         ),
                         borderRadius: BorderRadius.circular(15),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.3),
                             blurRadius: 10,
                             offset: const Offset(0, 5),
                           ),
                         ],
                       ),
                       child: const Icon(
                         Icons.auto_stories,
                         color: Colors.white,
                         size: 28,
                       ),
                     ),
                     Positioned(
                       top: -5,
                       right: -5,
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(10),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.3),
                               blurRadius: 4,
                               offset: const Offset(0, 2),
                             ),
                           ],
                         ),
                         child: Text(
                           '${book.publishYear}',
                           style: const TextStyle(
                             fontSize: 10,
                             fontWeight: FontWeight.bold,
                             color: Color(0xFF333333),
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                                             Text(
                         'by ${book.author}',
                         style: const TextStyle(
                           fontSize: 15,
                           color: Colors.white70,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(8),
                           border: Border.all(
                             color: Colors.white.withOpacity(0.2),
                           ),
                         ),
                         child: Text(
                           'Published: ${book.publishYear}',
                           style: const TextStyle(
                             fontSize: 12,
                             color: Colors.white70,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showDeleteDialog(book),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                book.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Book',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.white70),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteBook(book.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Book deleted successfully'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 