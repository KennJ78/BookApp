# Book App with MongoDB Backend

A Flutter application for managing a book collection with a Node.js backend connected to MongoDB.

## Features

- View list of books from MongoDB database
- Add new books with validation
- Delete books with confirmation
- Modern Material Design UI with animations
- RESTful API backend with MongoDB
- Real-time data persistence

## Project Structure

```
bookapp/
├── lib/
│   ├── main.dart          # Main Flutter app entry point
│   ├── homepage.dart      # Home page with book list
│   └── addbookpage.dart   # Add book form page
├── backend/
│   ├── index.js           # Main server file
│   ├── package.json       # Backend dependencies
│   ├── config.env         # Environment configuration
│   ├── config/
│   │   └── database.js    # MongoDB connection
│   ├── models/
│   │   └── Book.js        # Mongoose Book model
│   └── routes/
│       └── books.js       # Book API routes
└── README.md
```

## Prerequisites

- Flutter SDK
- Node.js (v14 or higher)
- MongoDB (local installation or MongoDB Atlas)
- MongoDB Compass (for database visualization)

## Setup Instructions

### 1. MongoDB Setup

#### Option A: Local MongoDB
1. Install MongoDB Community Server
2. Start MongoDB service
3. Open MongoDB Compass
4. Connect to: `mongodb://localhost:27017`

#### Option B: MongoDB Atlas
1. Create a free MongoDB Atlas account
2. Create a new cluster
3. Get your connection string
4. Update `backend/config.env` with your Atlas URI

### 2. Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Update the MongoDB connection in `config.env`:
   ```
   MONGODB_URI=mongodb://localhost:27017/bookapp
   ```

4. Start the server:
   ```bash
   npm start
   ```
   
   Or for development with auto-restart:
   ```bash
   npm run dev
   ```

The backend will run on `http://localhost:3000`

### 3. Flutter App Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Update the IP address in the Flutter app:
   - Open `lib/homepage.dart` and `lib/addbookpage.dart`
   - Replace `192.168.195.238` with your computer's IP address
   - Or use `10.0.2.2` for Android emulator

3. Run the Flutter app:
   ```bash
   flutter run
   ```

## API Endpoints

- `GET /api/books` - Get all books
- `GET /api/books/:id` - Get a specific book
- `POST /api/books` - Add a new book
- `PUT /api/books/:id` - Update a book
- `DELETE /api/books/:id` - Delete a book
- `GET /api/books/search/:query` - Search books
- `GET /health` - Health check

## Database Schema

```javascript
{
  _id: ObjectId,
  title: String (required, max 100 chars),
  author: String (required, max 50 chars),
  description: String (required, max 500 chars),
  createdAt: Date,
  updatedAt: Date
}
```

## MongoDB Compass Connection

1. Open MongoDB Compass
2. Click "New Connection"
3. Enter connection string: `mongodb://localhost:27017`
4. Click "Connect"
5. Navigate to the `bookapp` database
6. View the `books` collection

## Testing the App

1. **Start MongoDB** (if using local installation)
2. **Start the backend**: `cd backend && npm start`
3. **Run Flutter app**: `flutter run`
4. **Add books** through the app
5. **View in MongoDB Compass** to see the data

## Troubleshooting

### Connection Issues
- Ensure MongoDB is running
- Check the connection string in `config.env`
- Verify the IP address in Flutter app matches your computer

### Flutter Network Issues
- Use `10.0.2.2` for Android emulator
- Use your computer's IP address for physical devices
- Ensure both devices are on the same network

### MongoDB Compass Issues
- Verify MongoDB service is running
- Check if the port 27017 is accessible
- Try connecting with `mongodb://127.0.0.1:27017`

## Features

- **Real-time Data**: All changes are immediately saved to MongoDB
- **Data Validation**: Server-side validation for all book data
- **Error Handling**: Comprehensive error handling and user feedback
- **Search Functionality**: Search books by title, author, or description
- **Responsive Design**: Works on mobile and web platforms
