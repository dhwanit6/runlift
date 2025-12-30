# 🎬 Lottie Animation Download Guide

## Browser Issue - Manual Download Required

I encountered an error with automated browser access. Please follow these steps to download free Lottie animations:

---

## Quick Download Links (LottieFiles)

Visit these direct search URLs and download the **FREE** Lottie JSON files:

### Core Exercises

1. **Plank**
   - URL: https://lottiefiles.com/search?q=plank%20exercise&category=animations
   - Search: "plank exercise fitness"
   - Look for: Simple side-view plank hold
   - Save as: `assets/animations/exercises/plank.json`

2. **Squats**
   - URL: https://lottiefiles.com/search?q=squat%20exercise&category=animations
   - Search: "squat fitness"
   - Look for: Full squat up/down motion
   - Save as: `assets/animations/exercises/squats.json`

3. **Lunges**
   - URL: https://lottiefiles.com/search?q=lunge%20exercise&category=animations
   - Search: "lunge workout"
   - Look for: Forward lunge motion
   - Save as: `assets/animations/exercises/lunges.json`

4. **Push-ups**
   - URL: https://lottiefiles.com/search?q=push%20up&category=animations
   - Search: "push up exercise"
   - Look for: Side view push-up
   - Save as: `assets/animations/exercises/push_ups.json`

5. **Glute Bridge**
   - URL: https://lottiefiles.com/search?q=glute%20bridge&category=animations
   - Search: "bridge exercise hip thrust"
   - Look for: Hip raise motion
   - Save as: `assets/animations/exercises/glute_bridge.json`

### Warmup Movements

6. **High Knees**
   - URL: https://lottiefiles.com/search?q=high%20knees&category=animations
   - Search: "high knees running"
   - Save as: `assets/animations/warmup/high_knees.json`

7. **Butt Kicks**
   - URL: https://lottiefiles.com/search?q=butt%20kicks&category=animations  
   - Search: "heel kicks running"
   - Save as: `assets/animations/warmup/butt_kicks.json`

### Stretching

8. **Quad Stretch**
   - URL: https://lottiefiles.com/search?q=quad%20stretch&category=animations
   - Search: "leg stretch standing"
   - Save as: `assets/animations/stretching/quad_stretch.json`

9. **Hamstring Stretch**
   - URL: https://lottiefiles.com/search?q=hamstring%20stretch&category=animations
   - Search: "hamstring toe touch"
   - Save as: `assets/animations/stretching/hamstring_stretch.json`

---

## How to Download from LottieFiles

### Step 1: Find Animation
1. Click one of the URLs above
2. Browse the results
3. Click on an animation you like
4. **Check it says "Free" license** (not "Pro")

### Step 2: Download JSON
On the animation page:
1. Click the **"Download"** button (top right)
2. Select **"Lottie JSON"** format
3. File will download as `.json`

### Step 3: Save to Correct Folder
Move/rename the downloaded JSON to the correct path:
```
D:\running app\runlift\assets\animations\exercises\plank.json
D:\running app\runlift\assets\animations\exercises\squats.json
... etc
```

---

## Alternative: Quick Starter Pack

If you want to skip manual downloads for now, I can:

**Option 1:** Create simple placeholder animations (basic shapes)
**Option 2:** Use icon-only mode (animations optional, already works)
**Option 3:** Proceed to Phase 2 (Firebase) and add animations later

---

## Verification

After downloading, check that files exist:
```powershell
Get-ChildItem -Recurse "D:\running app\runlift\assets\animations"
```

Should show `.json` files in each folder.

---

## Next Step

Once you've downloaded at least 5-10 animations:
1. Let me know
2. I'll update `training_data.dart` to map exercises to animation paths
3. Then we proceed to Phase 2 (Firebase)

**Or skip downloads and proceed to Phase 2 now** (animations can be added anytime later).
