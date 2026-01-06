# Deploying RunLift to GitHub 🚀

This guide walkthroughs the process of hosting your code on GitHub, creating a professional repository, and publishing your first release with the APK.

## 1. Initializing the Repository

If you haven't already, initialize git and push to a new GitHub repository:

```bash
# Initialize git
git init

# Add all files
git add .

# Commit changes
git commit -m "feat: initial production-ready release"

# Link to GitHub (Replace with your repo URL)
git remote add origin https://github.com/yourusername/runlift.git

# Push to main
git branch -M main
git push -u origin main
```

## 2. Creating a "Perfect" GitHub Release

GitHub Releases are the best way to distribute your APK to users before you go to the Play Store.

1. Go to your repository on GitHub.
2. On the right sidebar, click **"Create a new release"** (or click the "Releases" header and then "Draft a new release").
3. **Choose a tag**: Type `v1.0.0` and click "Create new tag".
4. **Release Title**: `RunLift v1.0.0 (Production Release)`
5. **Description**: Use the following template for a professional look:

```markdown
## 📝 Release Notes
We are proud to announce the first production-ready release of **RunLift**. This version includes the complete 28-day training protocol, editorial Bento-style UI, and natural voice coaching.

### ✨ What's New
- **Advanced Interval Engine**: Scientifically backed 28-day progression.
- **Sensory Mastery**: Natural voice coach and heavy haptic feedback transitions.
- **Editorial UI**: Bento-grid stats HUD and glassmorphism design system.
- **Robust Persistence**: Progress is saved even if the app crashes or closes.

### 🛠 Technical Improvements
- Zero analyzer issues.
- Optimized Google/Neural TTS voice selection.
- Refined story sharing with glow icons.

### 📦 Installation
Download the `app-release.apk` below and install it on your Android device.
```

## 3. Uploading the APK

1. In the **"Attach binaries"** section at the bottom of the release page, drag and drop your generated APK.
2. You can find your APK at: `build/app/outputs/flutter-apk/app-release.apk`
3. Click **"Publish release"**.

## 4. GitHub Actions (Optional: Auto-Build)

To have GitHub automatically build your APK every time you push code, create a file at `.github/workflows/build.yml`:

```yaml
name: Flutter Build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter build apk --release
```

---
**RunLift Deployment Guide - v1.0**
