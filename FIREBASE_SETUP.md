# 🔥 Firebase Setup Guide for RunLift

## Step 1: Create Firebase Project (5 minutes)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Sign in with your Google account

2. **Create New Project**
   - Click "Add project"
   - Project name: `runlift-prod` (or your preference)
   - Enable Google Analytics: **Optional** (recommended for tracking)
   - Click "Create project"

---

## Step 2: Add Android App (5 minutes)

1. **In Firebase Console**
   - Click on your project
   - Click the **Android icon** to add Android app

2. **Android Package Name**
   - Enter: `com.runlift.runlift`
   - (This MUST match the package in `android/app/build.gradle.kts`)

3. **App Nickname (Optional)**
   - Enter: `RunLift Android`

4. **Debug Signing Certificate (Optional, skip for now)**
   - Leave blank for development

5. **Download google-services.json**
   - Click "Download google-services.json"
   - **SAVE THIS FILE** - we'll place it in the project

6. **Continue through the setup wizard**
   - Click "Next" through the remaining steps
   - Click "Continue to console"

---

## Step 3: Enable Authentication (3 minutes)

1. **In Firebase Console**, go to **"Authentication"** (left sidebar)
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable these providers:

### Email/Password Authentication
- Click "Email/Password"
- Toggle **"Enable"**
- Click "Save"

### Google Sign-In (Recommended)
- Click "Google"
- Toggle **"Enable"**
- Support email: Enter your email
- Click "Save"

---

## Step 4: Enable Firestore (Optional, for cloud sync) (3 minutes)

1. In Firebase Console, go to **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll add rules later)
4. Select location: Choose closest to your users (e.g., `asia-south1` for India)
5. Click "Enable"

---

## Step 5: Place google-services.json (1 minute)

**CRITICAL STEP:**

Move the downloaded `google-services.json` file to:
```
D:\running app\runlift\android\app\google-services.json
```

**Verify path is correct:**
```powershell
Test-Path "D:\running app\runlift\android\app\google-services.json"
```
Should return `True`

---

## Step 6: Run FlutterFire Configure (2 minutes)

**This generates the `firebase_options.dart` file with your actual credentials.**

### Install FlutterFire CLI (if not already installed)
```powershell
flutter pub global acivate flutterfire_clit
```

### Configure Firebase
```powershell
cd "D:\running app\runlift"
flutterfire configure
```

**Follow the prompts:**
1. Select your Firebase project (`runlift-prod`)
2. Select platforms: **Android** (press space to select, enter to confirm)
3. It will update `lib/firebase_options.dart` automatically

---

## Step 7: Verify Configuration

After running `flutterfire configure`, check:

1. **firebase_options.dart updated?**
   ```powershell
   Get-Content "lib\firebase_options.dart" | Select-String "YOUR_API_KEY"
   ```
   Should return **nothing** (no "YOUR_API_KEY" placeholders)

2. **google-services.json in place?**
   ```powershell
   Test-Path "android\app\google-services.json"
   ```
   Should return `True`

---

## Common Issues

### Issue: "FlutterFire command not found"
**Solution:**
```powershell
# Add Flutter global packages to PATH
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
flutterfire configure
```

### Issue: "No Firebase project selected"
**Solution:**
- Make sure you're logged into the correct Google account
- Run: `firebase login` (install Firebase CLI if needed)

### Issue: "google-services.json not found during build"
**Solution:**
- Check file is in `android/app/` (not `android/`)
- File must be named exactly `google-services.json`

---

## Security Note

**Add to `.gitignore`:**
```
# Firebase
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

(Already added in our project)

---

## Next Steps

Once you've completed all steps above, **let me know** and I'll:
1. Uncomment Firebase initialization in `main.dart`
2. Implement auth screens (email/password + Google Sign-In)
3. Add auth state management
4. Test the authentication flow

---

## Quick Checklist

- [ ] Created Firebase project
- [ ] Added Android app with package `com.runlift.runlift`
- [ ] Downloaded google-services.json
- [ ] Enabled Email/Password auth
- [ ] Enabled Google Sign-In
- [ ] Placed google-services.json in `android/app/`
- [ ] Ran `flutterfire configure`
- [ ] Verified firebase_options.dart has real credentials

**Once complete, type "FIREBASE READY" and I'll proceed with code implementation.**
