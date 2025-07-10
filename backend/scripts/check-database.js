const mongoose = require('mongoose');
const Book = require('../models/Book');

// Load environment variables
require('dotenv').config({ path: './config.env' });

async function checkDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bookapp');
    console.log('✅ Connected to MongoDB');

    // Get all books
    const books = await Book.find().sort({ createdAt: -1 });
    
    console.log('\n📚 Books in Database:');
    console.log('=====================');
    
    if (books.length === 0) {
      console.log('No books found in database.');
    } else {
      books.forEach((book, index) => {
        console.log(`\n${index + 1}. ${book.title}`);
        console.log(`   Author: ${book.author}`);
        console.log(`   Publish Year: ${book.publishYear}`);
        console.log(`   Description: ${book.description.substring(0, 50)}...`);
        console.log(`   Created: ${book.createdAt.toLocaleDateString()}`);
        console.log(`   ID: ${book._id}`);
      });
    }

    // Check database statistics
    const stats = await Book.collection.stats();
    console.log('\n📊 Database Statistics:');
    console.log('======================');
    console.log(`Total Books: ${stats.count}`);
    console.log(`Database Size: ${(stats.size / 1024).toFixed(2)} KB`);
    console.log(`Average Document Size: ${(stats.avgObjSize / 1024).toFixed(2)} KB`);

    // Check for books with publish year
    const booksWithYear = await Book.find({ publishYear: { $exists: true, $ne: null } });
    console.log(`\nBooks with Publish Year: ${booksWithYear.length}`);

    // Check for books without publish year
    const booksWithoutYear = await Book.find({ 
      $or: [
        { publishYear: { $exists: false } },
        { publishYear: null }
      ]
    });
    console.log(`Books without Publish Year: ${booksWithoutYear.length}`);

    console.log('\n🔍 MongoDB Compass Instructions:');
    console.log('================================');
    console.log('1. Open MongoDB Compass');
    console.log('2. Connect to: mongodb://localhost:27017');
    console.log('3. Navigate to "bookapp" database');
    console.log('4. Click on "books" collection');
    console.log('5. You will see all books with their publishYear field');
    console.log('6. Use the filter: { "publishYear": { $exists: true } } to see books with year');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.connection.close();
    console.log('\n👋 Database connection closed');
  }
}

// Run the check
checkDatabase(); 