# RUNLIFT 🏃‍♂️⚡

> **Precision training for the modern athlete. 28 Days. Zero Fluff.**

RunLift is a high-performance hybrid athlete training application designed to take users from the couch to a 5K finish line in exactly 28 days. It combines an editorial "Bento-style" UI with a robust interval training engine, natural voice coaching, and granular haptic feedback.

---

## 🏛 Architecture & Design Philosophy

The application follows a **Provider-Service-Model** pattern, leveraging **Riverpod 2.4** for high-fidelity state management.

### Technical Stack
- **Framework**: Flutter 3.x (Production Grade)
- **State Management**: `flutter_riverpod` (AsyncNotifier & ViewModels)
- **Navigation**: `go_router` (Typed Routing)
- **Engine**: Custom Workout Engine with multi-set expansion logic.
- **Sensory**: `flutter_tts` for voice coaching & custom `HapticService`.
- **Mapping**: `flutter_map` with OpenStreetMap (Sovereign, API-free).
- **Backend**: Supabase/Firebase for authentication and telemetry.

### Design Language
- **Editorial Bento HUD**: High data density with clean, italicized typography.
- **Atmospheric Backgrounds**: Dynamic, glassmorphism-heavy cards.
- **Sensory Interaction**: Heavy haptic impacts on transitions and natural voice cues.

---

## 🔥 Key Features

### 📅 The 28-Day Protocol
A scientifically progression-based program alternating between running intervals, strength sessions (Gym/Other), and active recovery.
- **Dynamic Progression**: Swipes between days to reveal upcoming sessions.
- **Automatic Logging**: Persistent memory of completed workouts using `SharedPreferences`.

### 🎙 AI Voice Coach
A premium coaching experience that guides you through every step.
- **Interval Cues**: "Time to run for 3 minutes... focus on your form."
- **Status Updates**: Halfway markers and 3-2-1 transition countdowns.
- **Tactile Transitions**: Haptic "Heavy Impact" cues when shifting from walk to run.

### 📸 Pro Story Sharing
Branded workout summaries designed for high-impact social media sharing.
- **Glow Icons**: high-fidelity branding that works on any background.
- **Stats Card**: Dynamic capture of distance, duration, and route.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Java 17+

### Development
```bash
# Clone the repository
git clone https://github.com/yourusername/runlift.git

# Install dependencies  
flutter pub get

# Generate icons (if needed)
flutter pub run flutter_launcher_icons

# Run project
flutter run
```

### Build & Release
```bash
# Generate Release APK
flutter build apk --release
```

---

## 🛠 Project Structure

```bash
lib/
├── core/           # Design System (Theme, Colors), Router, Constants
├── data/           # Services (Voice, Haptics, Location) & State Providers
├── domain/         # Immutable Models (Workouts, Intervals)
├── features/       # Modular Feature Sets:
│   ├── home/       # Today Screen, Bento HUDs
│   ├── workout/    # Active Workout Screen, Summary, Mapping
│   ├── program/    # Weekly Calendar, Progression
│   └── profile/    # Personal Stats, Biometrics
└── shared/         # Premium Widgets (GlassCard, AtmosphericBackground)
```

---

## 🔮 Roadmap (v2.0)
- [ ] **Smart Pace Guidance**: Adjusting coaching based on real-time GPS speed.
- [ ] **WearOS Integration**: Companion watch app for phone-free running.
- [ ] **Offline Maps**: Native MBTiles support for remote trail runs.

---

## 📄 License
MIT License - Copyright (c) 2026 RunLift Team
