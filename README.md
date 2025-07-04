<img src="screenshots/icon.png" width="100" alt="ClipNote Logo"/>

# ClipNote

**Your AI-Powered Note-Taking App Built with Flutter + Firebase + Gemini**  
*Inspired by Google Keep • Designed for Smart Productivity*

---

## 📌 Overview

**ClipNote** is a smart, personalized note-taking app built using **Flutter**, **Firebase**, **Gemini API**, and **OpenWeatherMap API**. It combines a modern UI with powerful features like AI-generated summaries, personalized planning, task extraction, and live weather — making it a complete productivity assistant.

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
├── model/
│   └── myNoteModel.dart
│
├── services/
│   ├── auth.dart
│   ├── db.dart
│   ├── firestore_db.dart
│   ├── ai_service.dart
│   ├── smart_daily_service.dart
│   ├── account_switcher.dart
│   └── loginInfo.dart
│
├── views/
│   ├── home.dart
│   ├── createNoteView.dart
│   ├── editNoteView.dart
│   ├── noteView.dart
│   ├── archieveView.dart
│   ├── backgroundSwitcher.dart
│   ├── SideMenuBar.dart
│   ├── settingsView.dart
│   ├── smart_daily_note_page.dart
│   └── searchPage.dart
│
└── main.dart
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

