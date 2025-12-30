# Exercise Animation Assets

## Overview
This document explains how to source and add Lottie animations for exercise demonstrations.

## Directory Structure
```
assets/animations/
├── exercises/         # Strength training exercises
├── warmup/           # Warmup movements
└── stretching/       # Stretching exercises
```

## Sourcing Free Lottie Animations

### 1. LottieFiles.com (Recommended)
**URL:** https://lottiefiles.com/search?q=fitness&category=animations

**Best Collections:**
- Search "fitness workout" - General exercises
- Search "yoga stretch" - Stretching movements
- Search "running warmup" - Dynamic warmups

**License:** Most are free for commercial use (check individual licenses)

**How to Download:**
1. Find animation
2. Click "Download"  
3. Select "Lottie JSON"
4. Save to appropriate `assets/animations/` folder

### 2. IconScout Lottie
**URL:** https://iconscout.com/lotties/fitness

**Pros:**
- High quality
- Consistent style
- Commercial licenses clear

**Cons:**
- Many are paid ($2-5 each)
- Free tier: 3-5 downloads/day

### 3. Create Your Own

**Tools:**
- **Adobe After Effects** + Bodymovin plugin
- **Figma** + LottieFiles plugin
- **Rive** (alternative to Lottie)

**Time:** 1-2 hours per animation (if experienced)

---

## Animation Mapping

Below is the complete mapping of exercises to animation file paths.

### Strength Exercises

| Exercise Name | Animation Path | Source |
|---------------|----------------|--------|
| Glute Bridges | `assets/animations/exercises/glute_bridge.json` | LottieFiles |
| Dead Bug | `assets/animations/exercises/dead_bug.json` | LottieFiles |
| Bird Dog | `assets/animations/exercises/bird_dog.json` | LottieFiles |
| Plank | `assets/animations/exercises/plank.json` | LottieFiles |
| Clamshells | `assets/animations/exercises/clamshells.json` | LottieFiles |
| Push-ups | `assets/animations/exercises/push_ups.json` | LottieFiles |
| Superman Hold | `assets/animations/exercises/superman.json` | LottieFiles |
| Mountain Climbers | `assets/animations/exercises/mountain_climbers.json` | LottieFiles |
| Side Plank | `assets/animations/exercises/side_plank.json` | LottieFiles |
| Bodyweight Squats | `assets/animations/exercises/squats.json` | LottieFiles |
| Reverse Lunges | `assets/animations/exercises/lunges.json` | LottieFiles |
| Calf Raises | `assets/animations/exercises/calf_raises.json` | LottieFiles |
| Leg Raises | `assets/animations/exercises/leg_raises.json` | LottieFiles |
| Russian Twists | `assets/animations/exercises/russian_twists.json` | LottieFiles |
| Bicycle Crunches | `assets/animations/exercises/bicycle_crunches.json` | LottieFiles |

### Warmup Movements

| Exercise Name | Animation Path | Source |
|---------------|----------------|--------|
| Leg Swings | `assets/animations/warmup/leg_swings.json` | LottieFiles |
| Walking Lunges | `assets/animations/warmup/walking_lunges.json` | LottieFiles |
| High Knees | `assets/animations/warmup/high_knees.json` | LottieFiles |
| Butt Kicks | `assets/animations/warmup/butt_kicks.json` | LottieFiles |
| Arm Circles | `assets/animations/warmup/arm_circles.json` | LottieFiles |

### Stretching

| Exercise Name | Animation Path | Source |
|---------------|----------------|--------|
| Quad Stretch | `assets/animations/stretching/quad_stretch.json` | LottieFiles |
| Hamstring Stretch | `assets/animations/stretching/hamstring_stretch.json` | LottieFiles |
| Calf Stretch | `assets/animations/stretching/calf_stretch.json` | LottieFiles |
| Hip Flexor Stretch | `assets/animations/stretching/hip_flexor.json` | LottieFiles |
| IT Band Stretch | `assets/animations/stretching/it_band.json` | LottieFiles |
| Child's Pose | `assets/animations/stretching/childs_pose.json` | LottieFiles |

---

## Placeholder Strategy

**Until animations are downloaded:**
- Widget shows fallback icon based on exercise name
- Description text displays
- App functions normally without animations

**To add animations:**
1. Download JSON files from LottieFiles
2. Rename to match paths above
3. Place in correct `assets/animations/` folder
4. Re-run app (hot reload works!)

---

## Specific Search Terms (LottieFiles)

Copy these into LottieFiles search:

```
glute bridge animation
dead bug exercise animation
bird dog exercise animation
plank hold animation
clamshell exercise animation
push up animation
superman hold animation
mountain climber animation
side plank animation
squat exercise animation
lunge animation
calf raise animation
leg raise animation
russian twist animation
bicycle crunch animation
leg swing warmup animation
high knees animation
butt kick animation
quad stretch animation
hamstring stretch animation
hip flexor stretch animation
child pose yoga animation
```

---

## License Considerations

**LottieFiles License Types:**
1. **Free License:** Can use in commercial apps (most common)
2. **Pro License:** Requires attribution or paid upgrade
3. **Custom:** Check individual animation license

**Recommended Filter:** 
- On LottieFiles, use "Free" filter
- Check license: "Free to use" or "CC0"

---

## Alternative: Placeholder Animations

If sourcing is too time-consuming, we can use:

**Option 1:** Icon-only (current fallback)
- Already implemented
- No external dependencies
- Functional but less engaging

**Option 2:** GIF library
- Convert Lottie to GIF
- Larger file sizes
- Works offline

**Option 3:** Video URLs
- YouTube embeds
- Requires internet
- Not recommended for UX

---

## File Size Considerations

- Average Lottie file: 50-200 KB
- Total for 25 animations: ~2-4 MB
- APK increase: Minimal (<5%)

**Optimization:**
- Use Lottie optimizer tools if needed
- Remove unnecessary animation layers
- Max duration: 5-10 seconds (loop)

---

## Testing Checklist

After adding animations:
- [ ] All animations load without error
- [ ] Play/pause controls work
- [ ] Animations loop smoothly
- [ ] Fallback icons work if file missing
- [ ] Performance is 60fps on mid-range devices
- [ ] Assets are included in build

---

## Next Steps

1. Create `assets/animations/exercises/` folder
2. Create `assets/animations/warmup/` folder
3. Create `assets/animations/stretching/` folder
4. Download animations from LottieFiles
5. Update `training_data.dart` with animation paths (next step in implementation)

---

> [!NOTE]
> Animations are **optional**. The app works fully without them using fallback icons. Add them incrementally as time permits.
