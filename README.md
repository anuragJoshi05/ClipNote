<img src="screenshots/icon.png" width="100" alt="ClipNote Logo"/>

# ClipNote

**Your AI-Powered Note-Taking App Built with Flutter + Firebase + Gemini**  
*Inspired by Google Keep • Designed for Smart Productivity*

---

## 📌 Overview

**ClipNote** is a smart, AI-powered note-taking app built with **Flutter**, **Firebase**, **Gemini API**, and **OpenWeatherMap API**. It blends a sleek, modern UI with intelligent features like AI-generated summaries, a dynamic **AI Dashboard** for personalized planning and task extraction, and real-time weather — making it a complete productivity companion.

---

## 📲 Download APK

🎉 **ClipNote v1.0 – First Public Release**  
📱 [**Download APK (20MB)**](https://github.com/anuragJoshi05/clipnote/releases/download/v1.0.0/clipnote.apk)  
✅ Optimized for modern Android (64-bit ARM) – no setup required  
🚀 Just download, install, and start using ClipNote instantly.

---

## 🚀 Key Features

| Feature             | Description                                      |
|---------------------|--------------------------------------------------|
| 🔐 Google Sign-In      | Firebase Auth for secure login                   |
| 🏡 Home UI             | Staggered & Linear views like Google Keep        |
| ✍️ Create/Edit Notes   | Real-time Firestore sync                         |
| 🎨 Custom Backgrounds  | Themed note cards                                |
| 🧠 AI Summary          | One-tap summaries using Gemini API               |
| 🌦️ Weather Access      | Live weather via OpenWeatherMap API                  |
| 📅 AI Planner          | Suggests daily plans from your notes             |
| 📋 Smart Daily Note    | Bundles tasks + weather + plan into one note     |
| 🧭 Sidebar + Gestures  | Navigation drawer and AI dashboard shortcuts     |

---

## 📸 App Walkthrough

### 🔐 Login Screen  
Google Sign-In with Firebase Auth and elegant background.

<img src="screenshots/1.jpg" width="250"/>

---

### 🏡 Home Screen – Staggered and Linear View  
Toggle between Pinterest-style staggered and simple vertical layout.

<img src="screenshots/2.jpg" width="250"/> <img src="screenshots/3.jpg" width="250"/>

---

### 📂 Sidebar Navigation & AI Dashboard  
Easily access Archive, Settings and Gemini-powered AI Dashboard.

<img src="screenshots/4.jpg" width="250"/> <img src="screenshots/15.jpg" width="250"/> <img src="screenshots/16.jpg" width="250"/>

---

### ✍️ Creating, Viewing & Editing Notes  
Write, edit, view and update notes — all synced in real-time to Firestore.

<img src="screenshots/5.jpg" width="250"/> <img src="screenshots/6.jpg" width="250"/>  
<img src="screenshots/7.jpg" width="250"/> <img src="screenshots/8.jpg" width="250"/> <img src="screenshots/9.jpg" width="250"/>

---

### 🧠 AI Summary Generation  
Use Gemini API to instantly summarize any note, stored back in Firestore.

<img src="screenshots/10.jpg" width="250"/> <img src="screenshots/11.jpg" width="250"/>  
<img src="screenshots/12.jpg" width="250"/> <img src="screenshots/13.jpg" width="250"/>

---

### 🎨 Background Customization  
Choose custom backgrounds for any note (similar to Google Keep).

<img src="screenshots/14.jpg" width="250"/>

---

### ✅ AI Task Analyzer & Smart Plan  
Gemini scans all notes to extract to-dos + generate a smart daily action plan.

<img src="screenshots/17.jpg" width="250"/> <img src="screenshots/18.jpg" width="250"/>

---

### 📝 Smart Daily Note Generator  
Automatically creates a new note with tasks, motivation, plan, and weather.

<img src="screenshots/19.jpg" width="250"/> <img src="screenshots/20.jpg" width="250"/>  
<img src="screenshots/21.jpg" width="250"/> <img src="screenshots/22.jpg" width="250"/>  
<img src="screenshots/23.jpg" width="250"/> <img src="screenshots/24.jpg" width="250"/>

---

### 🔐 Firebase Auth & 🔎 Firestore Storage View  
How ClipNote handles sign-in and how each note is stored as key:value pairs.

<img src="screenshots/25.png" width="500"/> <img src="screenshots/26.png" width="500"/>

---

## 🧰 Tech Stack

| Layer         | Tools                                      |
|---------------|---------------------------------------------|
| Language      | Dart                                        |
| Framework     | Flutter                                     |
| Auth          | Firebase Auth (Google Sign-In)              |
| Database      | Firestore                                   |
| AI Services   | Gemini API (Summaries, Plans, Tasks)        |
| Weather       | OpenWeatherMap API                          |
| Location      | Geolocator                                  |
| UI/UX         | Staggered Grid, Floating Buttons, Gestures  |

---

## 📁 Project Structure

```bash
lib/
│
├── model/                        # Data models used across the app
│   └── myNoteModel.dart          # Note model with fields and structure
│
├── services/                     # Backend and utility logic
│   ├── auth.dart                 # Firebase Auth integration
│   ├── db.dart                   # Local DB helpers (e.g., SQLite)
│   ├── firestore_db.dart         # Firestore CRUD and syncing
│   ├── ai_service.dart           # AI summary and Gemini API logic
│   ├── smart_daily_service.dart  # Generates smart daily notes using AI, tasks, weather
│   ├── account_switcher.dart     # Logic for switching accounts and resetting state
│   └── loginInfo.dart            # Stores current login session info
│
├── views/                        # UI Screens
│   ├── home.dart                 # Main notes dashboard (Keep-style)
│   ├── createNoteView.dart       # New note creation screen
│   ├── editNoteView.dart         # Editing existing notes
│   ├── noteView.dart             # Full note view with options
│   ├── archieveView.dart         # Archived notes display
│   ├── backgroundSwitcher.dart   # Choose note background
│   ├── SideMenuBar.dart          # Sidebar with navigation and settings
│   ├── settingsView.dart         # App preferences and options
│   ├── smart_dailynote_page.dart # Smart AI-powered daily planner
│   └── searchPage.dart           # Search functionality across notes
│
└── main.dart                     # Entry point, Firebase setup, routing
```

## 💻 Run Locally

```bash
git clone https://github.com/yourusername/clipnote.git
cd clipnote
flutter pub get
flutter run
```

```text
Make sure you’ve:
- Connected Firebase with your app using google-services.json
- Added your Gemini API key (for AI features)
- Added your OpenWeatherMap API key (for weather integration)
```

---

## 🙋‍♂️ About Me

```text
Hi! I’m Anurag Joshi – passionate about problem solving

📎 LinkedIn: https://www.linkedin.com/in/anuragjoshi05/
📧 Email: anurag88787@email.com
```

