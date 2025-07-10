const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Book title is required'],
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  author: {
    type: String,
    required: [true, 'Author name is required'],
    trim: true,
    maxlength: [50, 'Author name cannot exceed 50 characters']
  },
  publishYear: {
    type: Number,
    required: [true, 'Publish year is required'],
    min: [1000, 'Publish year must be at least 1000'],
    max: [new Date().getFullYear() + 1, 'Publish year cannot be in the future']
  },
  description: {
    type: String,
    required: [true, 'Book description is required'],
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Index for better query performance
bookSchema.index({ title: 1, author: 1 });

// Virtual for book summary
bookSchema.virtual('summary').get(function() {
  return this.description.length > 100 
    ? this.description.substring(0, 100) + '...' 
    : this.description;
});

module.exports = mongoose.model('Book', bookSchema); 