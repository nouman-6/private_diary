# Private Diary

A biometric-locked personal diary app built with Flutter. Your thoughts, completely private — secured by your fingerprint or Face ID.

> Built in public in 2 weeks as an open-source side project.

---

##  Screenshots

| Home | Write | Stats | Settings |
|------|-------|-------|----------|
<img width="1080" height="2400" alt="1" src="https://github.com/user-attachments/assets/aebb52e6-1bc3-4eaf-b95e-68ded6e11667" />

| ![Home](assets/screenshots/home.png) | ![Write](assets/screenshots/write.png) | ![Stats](assets/screenshots/stats.png) | ![Settings](assets/screenshots/settings.png) |

---

##  Features

- 🔐 Biometric lock (fingerprint / Face ID)
- 🔑 4-digit PIN fallback
- 📝 Write, edit, and delete diary entries
- 😊 Mood tracker with 5 moods
- 📊 Mood stats with pie chart
- 🔥 Writing streak counter
- 🔍 Search entries by keyword
- 🌙 Light / dark mode with persistence
- 💾 100% local storage — no cloud, no account

---

## 🛠️ Tech Stack

- Flutter
- Provider (state management)
- Hive (local database)
- local_auth (biometric authentication)
- flutter_secure_storage (PIN storage)
- fl_chart (mood chart)

---

## 🚀 Getting Started

1. Clone the repo
```bash
   git clone https://github.com/yourusername/private_diary.git
   cd private_diary
```

2. Install dependencies
```bash
   flutter pub get
```

3. Run the app
```bash
   flutter run
```

> **Note:** Biometric auth requires a real device with fingerprint or Face ID enrolled. Make sure `minSdkVersion` is set to 23 in `android/app/build.gradle`.

---

## 📁 Project Structure
