<h1 align="center">📚 Book Tracker</h1>

<p align="center">
  A beautiful and feature-rich Flutter application that helps you track your reading journey, set reading goals, and manage your personal book library with an elegant UI.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-%23FFCA28.svg?style=for-the-badge&logo=Firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Platform-Android|iOS|Web-blueviolet?style=for-the-badge"/>
</p>

<hr/>

<h2>📝 Description</h2>
<p>
  The <strong>Book Tracker</strong> is a comprehensive reading companion developed using <strong>Flutter</strong>. It is designed to help book lovers track their reading journey, set and achieve reading goals, and maintain a personal digital library that showcases their literary achievements.
</p>

<p>
  This project combines a <strong>beautiful UI</strong> with <strong>practical functionality</strong> — providing an intuitive interface for managing books, tracking reading progress, and visualizing your reading achievements. The app uses Firebase for authentication and cloud storage, ensuring your reading data is secure and accessible across devices.
</p>

<p>
  With features like reading goals tracking, detailed statistics, and personalized reading history, Book Tracker helps you understand your reading habits and motivates you to read more. The app's seamless design makes adding books, updating progress, and monitoring goals a delightful experience.
</p>

<p>
  <strong>Book Tracker</strong> is perfect for:
</p>
<ul>
  <li>📖 Avid readers looking to organize their reading life</li>
  <li>🎯 Goal-oriented individuals who want to track reading targets</li>
  <li>📊 Data enthusiasts interested in analyzing their reading habits</li>
  <li>📱 Anyone who wants to keep their books organized in a digital format</li>
  <li>🏆 Readers who are motivated by achievements and progress tracking</li>
</ul>

<p>
  Whether you're a casual reader trying to build a habit or a bookworm managing hundreds of books, Book Tracker adapts to your needs with its flexible and user-friendly interface.
</p>

<p><strong>Built With:</strong> Flutter • Dart • Firebase Authentication • Cloud Firestore • SQLite • Provider • Shared Preferences • Material UI • Custom Animations • Responsive Design</p>

<h2>✨ Key Features</h2>
<ul>
  <li>📖 <strong>Book Management</strong>: Add, edit, and delete books in your personal library with customizable details</li>
  <li>📊 <strong>Reading Progress Tracking</strong>: Keep track of your current page, completion percentage, and reading speed</li>
  <li>🎯 <strong>Reading Goals</strong>: Set and track custom reading goals (books, pages, or minutes) with deadline tracking</li>
  <li>🏆 <strong>Reading Achievements</strong>: Visualize and celebrate your reading accomplishments with beautiful progress charts</li>
  <li>🌓 <strong>Dark/Light Mode</strong>: Choose your preferred theme for comfortable reading in any lighting conditions</li>
  <li>🔐 <strong>User Authentication</strong>: Secure sign-up and login with email/password or Google integration</li>
  <li>📄 <strong>PDF Import</strong>: Import PDF books directly into your library for easy access</li>
  <li>☁️ <strong>Data Backup</strong>: Cloud backup and sync of your reading data across multiple devices</li>
  <li>📈 <strong>Reading Statistics</strong>: View detailed analytics about your reading habits, pace, and preferences</li>
  <li>🔍 <strong>Search & Filter</strong>: Easily find books by title, author, genre, or reading status</li>
  <li>📅 <strong>Reading Scheduling</strong>: Plan your reading sessions with smart notifications</li>
  <li>📒 <strong>Reading Notes</strong>: Add personal notes and highlights to remember important parts of books</li>
</ul>

<h2>🚀 Getting Started</h2>
<p>Follow these simple steps to set up and run the project locally:</p>

<ol>
  <li><strong>📥 Clone the repository</strong></li>
  <pre><code>git clone https://github.com/Tamanna5/book-tracker.git</code></pre>

  <li><strong>📂 Navigate into the project directory</strong></li>
  <pre><code>cd book-tracker</code></pre>

  <li><strong>📦 Get all the Flutter dependencies</strong></li>
  <pre><code>flutter pub get</code></pre>

  <li><strong>🔥 Set up Firebase</strong></li>
  <ul>
    <li>Create a new Firebase project in the Firebase Console</li>
    <li>Enable Authentication (Email/Password and Google Sign-in)</li>
    <li>Set up Cloud Firestore database with appropriate security rules</li>
    <li>Download and add the <code>google-services.json</code> (Android) and <code>GoogleService-Info.plist</code> (iOS) files to their respective directories</li>
    <li>Update Firebase configuration in the app if needed</li>
  </ul>

  <li><strong>▶️ Run the app on your emulator or connected device</strong></li>
  <pre><code>flutter run</code></pre>
</ol>

<p>✨ That's it! You're now ready to start tracking your reading journey with Book Tracker!</p>

<h2>🧩 Project Structure</h2>

```
lib/
├── main.dart                  # App entry point
├── models/                    # Data models for books, goals, etc.
├── providers/                 # State management with Provider
├── screens/                   # UI screens (home, details, settings, etc.)
├── services/                  # Backend services (Firebase, database)
├── themes/                    # App themes and styling
├── utils/                     # Utility functions and helpers
└── widgets/                   # Reusable UI components
```

<h2>💡 Use Cases</h2>
<ul>
  <li>📚 <strong>Manage Your Library</strong>: Keep a comprehensive digital catalog of all your books</li>
  <li>🏁 <strong>Set Reading Goals</strong>: Challenge yourself with monthly, yearly, or custom reading targets</li>
  <li>📈 <strong>Track Reading Progress</strong>: Monitor how far you've read and how quickly you're progressing</li>
  <li>📅 <strong>Reading Schedule</strong>: Plan your reading sessions to meet your goals efficiently</li>
  <li>🧠 <strong>Reading Insights</strong>: Gain valuable insights about your reading habits and preferences</li>
  <li>📣 <strong>Share Achievements</strong>: Celebrate and share your reading milestones with friends</li>
</ul>

<h2>📸 Screenshots</h2>
<p align="center">
  <table>
    <tr>
      <td><img src="assets/screenshots/home.png" width=250 alt="Home Screen"/></td>
      <td><img src="assets/screenshots/library.png" width=250 alt="Library Screen"/></td>
      <td><img src="assets/screenshots/profile.png" width=250 alt="Profile Screen"/></td>
    </tr>
    <tr>
      <td><img src="assets/screenshots/goals.png" width=250 alt="Goals Screen"/></td>
      <td><img src="assets/screenshots/book_details.png" width=250 alt="Book Details Screen"/></td>
      <td><img src="assets/screenshots/settings.png" width=250 alt="Settings Screen"/></td>
    </tr>
  </table>
</p>

<h2>🔒 Privacy Policy</h2>
<p>
  Book Tracker respects user privacy and only collects necessary data for providing its services. The app stores reading data locally on your device by default, with optional cloud backup if you choose to create an account. Your reading habits and personal library remain private and secure. For more details, check the Privacy Policy screen in the app.
</p>

<h2>🤝 Personal Project Statement</h2>
<p>
  Book Tracker was developed as a personal project during my academic coursework in mobile application development. It represents my skills in Flutter development, UI/UX design, and full-stack integration with Firebase. The project showcases my ability to create a functional, aesthetically pleasing mobile application that solves a real-world need.
</p>

<p>
  This application was solely developed by me (Tamanna Kalariya) and demonstrates my programming abilities and understanding of mobile application architecture. I welcome feedback and suggestions for improvements to enhance the app's functionality and user experience. Feel free to reach out directly if you have ideas or questions about the implementation.
</p>

<h2>📄 License</h2>
<p>This project is licensed under the MIT License - see the LICENSE file for details.</p>

<h2>👩‍💻 Author</h2>
<p>
  Developed with ❤️ by <a href="https://github.com/Tamanna5">Tamanna Kalariya</a>
</p>
