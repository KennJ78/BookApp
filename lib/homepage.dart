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
  final String? image;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publishYear,
    required this.description,
    this.image,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      author: json['author'],
      publishYear: json['publishYear'] ?? 0,
      description: json['description'],
      image: json['image'],
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
  List<Book> filteredBooks = [];
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
    
    // Add listener to search controller
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredBooks = List.from(books);
      } else {
        filteredBooks = books.where((book) {
          return book.title.toLowerCase().contains(query) ||
                 book.author.toLowerCase().contains(query) ||
                 book.description.toLowerCase().contains(query) ||
                 book.publishYear.toString().contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.195.238:3003/api/books'));
      if (response.statusCode == 200) {
        final List<dynamic> booksJson = json.decode(response.body);
        final List<Book> fetchedBooks = booksJson.map((json) => Book.fromJson(json)).toList();
        
        // Remove duplicates based on book ID
        final Map<String, Book> uniqueBooks = {};
        for (Book book in fetchedBooks) {
          uniqueBooks[book.id] = book;
        }
        
        setState(() {
          books = uniqueBooks.values.toList();
          filteredBooks = List.from(books); // Initialize filteredBooks with all books
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
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  Future<void> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.195.238:3003/api/books'),
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
          // Check if book already exists before adding
          bool bookExists = books.any((existingBook) => existingBook.id == newBook.id);
          if (!bookExists) {
            books.add(newBook);
            // Update filtered books if not currently searching or if the new book matches the search
            if (!isSearching || _searchController.text.isEmpty) {
              filteredBooks.add(newBook);
            } else {
              _filterBooks(); // Re-filter to include the new book if it matches
            }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Book added successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      } else if (response.statusCode == 409) {
        // Handle duplicate book
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Book already exists'),
            backgroundColor: const Color(0xFFFFA500),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${responseData['message'] ?? response.body}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding book: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://192.168.195.238:3003/api/books/$id'));
      if (response.statusCode == 200) {
        setState(() {
          books.removeWhere((book) => book.id == id);
          filteredBooks.removeWhere((book) => book.id == id); // Also remove from filtered list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Book deleted successfully'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting book: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          
          // Main Content
          SafeArea(
          child: Column(
            children: [
                // Hero Header
              Container(
                  margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                      // Profile Avatar
                    Container(
                        width: 60,
                        height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                        ),
                          borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                          Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                      
                      // Welcome Text
                      Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text(
                              'Welcome back!',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8B8BB8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                          Text(
                              'Your Digital Library',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.0,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
                      // Stats Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E3F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${filteredBooks.length}',
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Search Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search books by title, author, or description...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8B8BB8),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        isSearching ? Icons.search : Icons.search_outlined,
                        color: isSearching ? const Color(0xFF6366F1) : const Color(0xFF8B8BB8),
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterBooks();
                              },
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: Color(0xFF8B8BB8),
                                size: 24,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF1E1E3F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: isSearching 
                              ? const Color(0xFF6366F1).withOpacity(0.5)
                              : const Color(0xFF6366F1).withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 3,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                  ),
                ),
                
                // Content Area
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E3F),
                          borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF6366F1),
                              ),
                            )
                          : filteredBooks.isEmpty
                              ? _buildEmptyState()
                              : _buildBookList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 12),
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
              // Add the book to the list immediately
              setState(() {
                bool bookExists = books.any((existingBook) => existingBook.id == result.id);
                if (!bookExists) {
                  books.add(result);
                  // Update filtered books if not currently searching or if the new book matches the search
                  if (!isSearching || _searchController.text.isEmpty) {
                    filteredBooks.add(result);
                  } else {
                    _filterBooks(); // Re-filter to include the new book if it matches
                  }
                }
              });
            }
          },
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded, size: 28),
          label: const Text(
            'Add Book',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.auto_stories_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              isSearching ? 'No Books Found' : 'Start Your Collection',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearching 
                ? 'Try adjusting your search terms or browse all your books'
                : 'Add your first book to begin building your digital library',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF8B8BB8),
                height: 1.6,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _filterBooks();
                },
                icon: const Icon(Icons.clear_rounded, size: 20),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                  foregroundColor: const Color(0xFF6366F1),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookList() {
    return Column(
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isSearching ? 'Search Results' : 'Your Books',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              if (isSearching) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredBooks.length} found',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Book Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine grid layout based on screen width
              double screenWidth = constraints.maxWidth;
              int crossAxisCount;
              double childAspectRatio;
              double crossAxisSpacing;
              double mainAxisSpacing;
              double cardWidth;
              double cardHeight;
              
              if (screenWidth > 1200) {
                // Large laptop/desktop
                crossAxisCount = 4;
                cardWidth = 300;
                cardHeight = 420;
                crossAxisSpacing = 20;
                mainAxisSpacing = 20;
              } else if (screenWidth > 800) {
                // Medium laptop/tablet
                crossAxisCount = 3;
                cardWidth = 260;
                cardHeight = 380;
                crossAxisSpacing = 18;
                mainAxisSpacing = 18;
              } else if (screenWidth > 600) {
                // Small laptop/tablet
                crossAxisCount = 2;
                cardWidth = 220;
                cardHeight = 360;
                crossAxisSpacing = 16;
                mainAxisSpacing = 16;
              } else {
                // Mobile
                crossAxisCount = 2;
                cardWidth = 180;
                cardHeight = 320;
                crossAxisSpacing = 16;
                mainAxisSpacing = 16;
              }
              
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: cardWidth / cardHeight,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return _buildBookCard(book, index, screenWidth, cardWidth, cardHeight);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book, int index, double screenWidth, double cardWidth, double cardHeight) {
    // Adjust card styling based on screen size
    double padding = screenWidth > 800 ? 14.0 : 16.0; // Increased padding for much larger fonts
    double iconSize = screenWidth > 800 ? 16.0 : 20.0;
    double titleFontSize = screenWidth > 800 ? 18.0 : 16.0; // Much larger font for laptops
    double authorFontSize = screenWidth > 800 ? 16.0 : 14.0; // Much larger font for laptops
    double yearFontSize = screenWidth > 800 ? 14.0 : 12.0; // Much larger font for laptops
    double deleteIconSize = screenWidth > 800 ? 14.0 : 18.0;
    double descriptionFontSize = screenWidth > 800 ? 15.0 : 13.0; // Much larger font for laptops
    
    return GestureDetector(
      onTap: () => _showBookDetails(book),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2A4F),
              const Color(0xFF1E1E3F),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Book Cover Image - Large and prominent
              if (book.image != null) ...[
                Container(
                  width: double.infinity,
                  height: screenWidth > 800 ? 180 : 140, // Increased height for laptops
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth > 800 ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth > 800 ? 12 : 16),
                    child: Image.memory(
                      base64Decode(book.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF2A2A4F),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: Color(0xFF8B8BB8),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                // Placeholder for books without images
                Container(
                  width: double.infinity,
                  height: screenWidth > 800 ? 140 : 100, // Increased height for laptops
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(screenWidth > 800 ? 12 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: screenWidth > 800 ? 48 : 40, // Larger icon for laptops
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Book Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Year Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: screenWidth > 800 ? 1.4 : 1.2, // Increased line height for larger fonts
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 800 ? 6 : 8, // Increased padding for larger font
                            vertical: screenWidth > 800 ? 4 : 4, // Increased padding for larger font
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(screenWidth > 800 ? 6 : 8), // Increased radius for larger font
                          ),
                          child: Text(
                            '${book.publishYear}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: yearFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: screenWidth > 800 ? 6 : 6), // Increased spacing for larger fonts
                    
                    // Author
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: authorFontSize,
                        color: const Color(0xFF8B8BB8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: screenWidth > 800 ? 8 : 8), // Increased spacing for larger fonts
                    
                    // Description
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth > 800 ? 8 : 8), // Increased padding for larger fonts
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E3F).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(screenWidth > 800 ? 8 : 8), // Increased radius for larger fonts
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            book.description,
                            style: TextStyle(
                              fontSize: descriptionFontSize,
                              color: const Color(0xFFB8B8D1),
                              height: screenWidth > 800 ? 1.5 : 1.2, // Increased line height for larger fonts
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenWidth > 800 ? 4 : 8), // Reduced spacing for laptops
                    
                    // Delete Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showDeleteDialog(book),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth > 800 ? 6 : 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(screenWidth > 800 ? 8 : 10),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: const Color(0xFFEF4444),
                            size: deleteIconSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookDetails(Book book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E3F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B8BB8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Book Info
              Row(
                children: [
                  // Book Cover or Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: book.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              base64Decode(book.image!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.auto_stories_rounded,
                                  color: Colors.white,
                                  size: 32,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.auto_stories_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${book.author}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8B8BB8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Year Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Published ${book.publishYear}',
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 200,
                    maxHeight: 400,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A4F),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      book.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFB8B8D1),
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E3F),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Color(0xFFEF4444),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Book',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8B8BB8),
                    height: 1.5,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF8B8BB8),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
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

// Custom Background Painter
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw some subtle background elements
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      100,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      80,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 