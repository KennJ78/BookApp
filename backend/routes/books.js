const express = require('express');
const Book = require('../models/Book');
const router = express.Router();

// GET all books
router.get('/', async (req, res) => {
  try {
    const books = await Book.find().sort({ createdAt: -1 });
    res.json(books);
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({ 
      message: 'Error fetching books',
      error: error.message 
    });
  }
});

// GET a specific book by ID
router.get('/:id', async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }
    res.json(book);
  } catch (error) {
    console.error('Error fetching book:', error);
    res.status(500).json({ 
      message: 'Error fetching book',
      error: error.message 
    });
  }
});

// POST a new book
router.post('/', async (req, res) => {
  try {
    const { title, author, publishYear, description } = req.body;
    
    // Validation
    if (!title || !author || !publishYear || !description) {
      return res.status(400).json({ 
        message: 'Title, author, publish year, and description are required' 
      });
    }

    const newBook = new Book({
      title,
      author,
      publishYear: parseInt(publishYear),
      description
    });

    const savedBook = await newBook.save();
    res.status(201).json(savedBook);
  } catch (error) {
    console.error('Error creating book:', error);
    if (error.name === 'ValidationError') {
      return res.status(400).json({ 
        message: 'Validation error',
        errors: Object.values(error.errors).map(err => err.message)
      });
    }
    res.status(500).json({ 
      message: 'Error creating book',
      error: error.message 
    });
  }
});

// PUT update a book
router.put('/:id', async (req, res) => {
  try {
    const { title, author, publishYear, description } = req.body;
    
    // Validation
    if (!title || !author || !publishYear || !description) {
      return res.status(400).json({ 
        message: 'Title, author, publish year, and description are required' 
      });
    }

    const updatedBook = await Book.findByIdAndUpdate(
      req.params.id,
      {
        title,
        author,
        publishYear: parseInt(publishYear),
        description,
        updatedAt: Date.now()
      },
      { new: true, runValidators: true }
    );

    if (!updatedBook) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json(updatedBook);
  } catch (error) {
    console.error('Error updating book:', error);
    if (error.name === 'ValidationError') {
      return res.status(400).json({ 
        message: 'Validation error',
        errors: Object.values(error.errors).map(err => err.message)
      });
    }
    res.status(500).json({ 
      message: 'Error updating book',
      error: error.message 
    });
  }
});

// DELETE a book
router.delete('/:id', async (req, res) => {
  try {
    const deletedBook = await Book.findByIdAndDelete(req.params.id);
    
    if (!deletedBook) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json({ 
      message: 'Book deleted successfully',
      deletedBook 
    });
  } catch (error) {
    console.error('Error deleting book:', error);
    res.status(500).json({ 
      message: 'Error deleting book',
      error: error.message 
    });
  }
});

// GET books by search
router.get('/search/:query', async (req, res) => {
  try {
    const query = req.params.query;
    const books = await Book.find({
      $or: [
        { title: { $regex: query, $options: 'i' } },
        { author: { $regex: query, $options: 'i' } },
        { publishYear: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } }
      ]
    }).sort({ createdAt: -1 });
    
    res.json(books);
  } catch (error) {
    console.error('Error searching books:', error);
    res.status(500).json({ 
      message: 'Error searching books',
      error: error.message 
    });
  }
});

module.exports = router; 