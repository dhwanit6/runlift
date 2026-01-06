/// Complete 28-day training program data.
// ignore_for_file: prefer_const_constructors

library;
/// 
/// This file contains the full training program for the "Couch to 5K in 28 days"
/// program, including all workouts, exercises, warmups, and cooldowns.

import '../domain/models/training_program.dart';

// ============================================================================
// WARMUP & COOLDOWN ROUTINES
// ============================================================================

/// Standard pre-run dynamic warmup (5 minutes)
const preRunWarmup = WarmupCooldown(
  name: 'Dynamic Warmup',
  isWarmup: true,
  estimatedDuration: Duration(minutes: 5),
  exercises: [
    Exercise(
      name: 'Leg Swings', 
      reps: 10, 
      perSide: 'each leg',
      description: 'Stand next to a wall for balance. Swing one leg forward and backward like a pendulum. Keep your upper body still. This loosens up your hips before running.',
    ),
    Exercise(
      name: 'Walking Lunges', 
      reps: 5, 
      perSide: 'each leg',
      description: 'Take a big step forward. Lower your back knee until it almost touches the ground. Perform a walking motion. Keep your chest up tall.',
    ),
    Exercise(
      name: 'High Knees', 
      duration: Duration(seconds: 20),
      description: 'Run in place, lifting your knees as high as possible towards your chest. Pump your arms. It wakes up your nervous system.',
    ),
    Exercise(
      name: 'Butt Kicks', 
      duration: Duration(seconds: 20),
      description: 'Jog in place, kicking your heels back to touch your glutes. This stretches your quads and activates your hamstrings.',
    ),
    Exercise(
      name: 'Arm Circles', 
      duration: Duration(seconds: 15),
      description: 'Hold arms straight out to sides. Make big circles forward, then backward. Loosens up shoulders for better running posture.',
    ),
    Exercise(
      name: 'Light Jog', 
      duration: Duration(seconds: 60),
      description: 'Very slow, easy jogging. Just to get the heart rate up slightly before the main workout.',
    ),
  ],
);

/// Standard post-run static stretching (5-7 minutes)
const postRunCooldown = WarmupCooldown(
  name: 'Static Stretching',
  isWarmup: false,
  estimatedDuration: Duration(minutes: 6),
  exercises: [
    Exercise(
      name: 'Quad Stretch', 
      holdTime: Duration(seconds: 30), 
      perSide: 'each leg',
      description: 'Stand on one leg. Pull your other heel towards your butt. Keep knees together. Push hips forward slightly to feel a stretch in the front thigh.',
    ),
    Exercise(
      name: 'Hamstring Stretch', 
      holdTime: Duration(seconds: 30), 
      perSide: 'each leg',
      description: 'Place one heel on the ground in front of you, leg straight. Bend the back knee and lean forward from your hips. Keep your back straight.',
    ),
    Exercise(
      name: 'Calf Stretch', 
      holdTime: Duration(seconds: 30), 
      perSide: 'each leg',
      description: 'Push against a wall with one foot back, heel on the ground. Lean forward until you feel a pull in the back of your lower leg.',
    ),
    Exercise(
      name: 'Hip Flexor Stretch', 
      holdTime: Duration(seconds: 30), 
      perSide: 'each leg',
      description: 'Kneel on one knee (lunge position). Push your hips forward while keeping your chest up. You should feel it in the front of the hip of the kneeling leg.',
    ),
    Exercise(
      name: 'IT Band Stretch', 
      holdTime: Duration(seconds: 30), 
      perSide: 'each side',
      description: 'Cross one leg behind the other. Lean to the side of the back leg. Push your hips out to the side to feel a stretch along the outer thigh.',
    ),
    Exercise(
      name: "Child's Pose", 
      holdTime: Duration(seconds: 30),
      description: 'Kneel on the floor. Sit back on your heels. Reach arms forward on the ground. Rest forehead on the floor. Great for back release.',
    ),
  ],
);

// ============================================================================
// STRENGTH WORKOUTS
// ============================================================================

/// Core & Glute Activation (Week 1)
const coreGluteWorkout = Workout(
  id: 'strength-core-glute-1',
  name: 'Core & Glute Activation',
  description: 'Building the foundation for injury-free running',
  type: WorkoutType.strength,
  estimatedDuration: Duration(minutes: 20),
  targetRpe: 4,
  circuitRounds: 2,
  restBetweenRounds: Duration(seconds: 60),
  exercises: [
    Exercise(
      name: 'Glute Bridges', 
      reps: 15, 
      description: 'Lie on back, knees bent, feet flat. Lift hips until your body makes a straight line. Squeeze glutes hard at the top for 2 seconds. Lower slowly.',
    ),
    Exercise(
      name: 'Dead Bug', 
      reps: 10, 
      perSide: 'each side',
      description: 'Lie on back, arms and legs up in air. Lower opposite arm and leg towards floor slowly. Keep your lower back pressed into the floor.',
    ),
    Exercise(
      name: 'Bird Dog', 
      reps: 10, 
      perSide: 'each side',
      description: 'On hands and knees. Extend opposite arm and leg straight out. Keep back flat like a table. Don\'t let hips rotate.',
    ),
    Exercise(
      name: 'Plank', 
      duration: Duration(seconds: 30),
      description: 'Hold a push-up position on your elbows. Keep body in a straight line from head to heels. Squeeze glutes and core tight. Don\'t let hips sag.',
    ),
    Exercise(
      name: 'Clamshells', 
      reps: 15, 
      perSide: 'each side',
      description: 'Lie on side, legs bent at 45 degrees. Keep feet touching. Lift top knee like a clam opening. Keep hips stacked, don\'t roll back.',
    ),
  ],
);

/// Upper Body + Core (Week 2)
const upperBodyCoreWorkout = Workout(
  id: 'strength-upper-core',
  name: 'Upper Body + Core',
  description: 'Arm swing power and core stability',
  type: WorkoutType.strength,
  estimatedDuration: Duration(minutes: 25),
  targetRpe: 4,
  circuitRounds: 3,
  restBetweenRounds: Duration(seconds: 45),
  exercises: [
    Exercise(
      name: 'Push-ups', 
      reps: 10, 
      description: 'Hands shoulder-width apart. Lower chest to floor. Keep body straight. Use knees if needed to maintain good form.',
    ),
    Exercise(
      name: 'Superman Hold', 
      duration: Duration(seconds: 20),
      description: 'Lie on stomach. Lift arms and legs off the ground simultaneously. Squeeze your lower back and glutes. Fly like Superman.',
    ),
    Exercise(
      name: 'Mountain Climbers', 
      reps: 20, 
      description: 'Push-up position. Drive one knee to chest, then switch quickly. Keep hips low. Like running in a plank position.',
    ),
    Exercise(
      name: 'Arm Circles', 
      reps: 15, 
      perSide: 'each direction',
      description: 'Stand tall. large, controlled circles with your arms. 15 forward, 15 backward.',
    ),
    Exercise(
      name: 'Side Plank', 
      duration: Duration(seconds: 20), 
      perSide: 'each side',
      description: 'Lie on side, elbow under shoulder. Lift hips off ground. Create straight line from head to feet. Hold.',
    ),
  ],
);

/// Lower Body Focus (Week 2)
const lowerBodyWorkout = Workout(
  id: 'strength-lower-body',
  name: 'Lower Body Power',
  description: 'Build stronger legs for faster running',
  type: WorkoutType.strength,
  estimatedDuration: Duration(minutes: 25),
  targetRpe: 5,
  circuitRounds: 3,
  restBetweenRounds: Duration(seconds: 60),
  exercises: [
    Exercise(
      name: 'Bodyweight Squats', 
      reps: 15,
      description: 'Feet shoulder-width. Sit back like sitting in a chair. Keep chest up. Go down until thighs are parallel to floor. Stand back up.',
    ),
    Exercise(
      name: 'Reverse Lunges', 
      reps: 10, 
      perSide: 'each leg',
      description: 'Stand tall. Step one foot way back. Drop back knee towards ground. Keep front knee behind toe. Push back up to standing.',
    ),
    Exercise(
      name: 'Calf Raises', 
      reps: 20,
      description: 'Stand on edge of a step or flat ground. Lift heels as high as possible. Lower slowly. Balance with a wall if needed.',
    ),
    Exercise(
      name: 'Single Leg Glute Bridges', 
      reps: 10, 
      perSide: 'each leg',
      description: 'Lie on back, one knee bent, other leg straight in air. Lift hips using the planted foot. Squeeze glute at top.',
    ),
    Exercise(
      name: 'Wall Sit', 
      duration: Duration(seconds: 30),
      description: 'Lean back against a wall. Slide down until knees are at 90 degrees. Hold. Don\'t rest hands on knees!',
    ),
  ],
);

/// Core Power Circuit (Week 3)
const corePowerWorkout = Workout(
  id: 'strength-core-power',
  name: 'Core Power Circuit',
  description: 'Advanced core work for the final push',
  type: WorkoutType.strength,
  estimatedDuration: Duration(minutes: 20),
  targetRpe: 5,
  circuitRounds: 3,
  restBetweenRounds: Duration(seconds: 45),
  exercises: [
    Exercise(
      name: 'Plank to Push-up', 
      reps: 8,
      description: 'Start in elbow plank. Push up onto hand, then other hand to reach push-up position. Lower back down to elbows. Repeat.',
    ),
    Exercise(
      name: 'Russian Twists', 
      reps: 20, 
      description: 'Sit on floor, knees bent, feet slightly off ground. Lean back engaging core. Twist torso side to side touching floor.',
    ),
    Exercise(
      name: 'Leg Raises', 
      reps: 12,
      description: 'Lie on back, hands under hips. Lift straight legs up to 90 degrees. Lower slowly without touching floor. Keep lower back pressed down.',
    ),
    Exercise(
      name: 'Bicycle Crunches', 
      reps: 20, 
      description: 'Lie on back. Bring opposite elbow to opposite knee while extending other leg. Pedal legs like a bicycle.',
    ),
    Exercise(
      name: 'Dead Bug Hold', 
      duration: Duration(seconds: 30),
      description: 'Lie on back, arms and legs up (bug position). Press lower back into floor hard. Hold this position statically.',
    ),
  ],
);

/// Full Body Strength (Week 3)
const fullBodyWorkout = Workout(
  id: 'strength-full-body',
  name: 'Full Body Strength',
  description: 'Complete runner\'s strength session',
  type: WorkoutType.strength,
  estimatedDuration: Duration(minutes: 25),
  targetRpe: 5,
  circuitRounds: 3,
  restBetweenRounds: Duration(seconds: 60),
  exercises: [
    Exercise(
      name: 'Squat to Press', 
      reps: 12, 
      description: 'Hold weights (or water bottles) at shoulders. Squat down. As you stand up, press weights overhead explosively.',
    ),
    Exercise(
      name: 'Walking Lunges', 
      reps: 10, 
      perSide: 'each leg',
      description: 'Take big steps forward, dropping back knee. Walk continuously. Focus on balance and control.',
    ),
    Exercise(
      name: 'Push-ups', 
      reps: 12,
      description: 'Classic push-ups. Keep core tight. Chest to floor. Modifications: Incline push-ups (hands on bench) or knee push-ups.',
    ),
    Exercise(
      name: 'Glute Bridges', 
      reps: 15,
      description: 'Lie on back, lift hips. This time try without resting on floor between reps. Keep the tension.',
    ),
    Exercise(
      name: 'Plank', 
      duration: Duration(seconds: 45),
      description: 'Standard elbow plank. 45 seconds is a challenge. Breathe steadily. Do not hold your breath.',
    ),
  ],
);

// ============================================================================
// RECOVERY WORKOUTS
// ============================================================================

/// Dynamic Mobility Flow (Week 1)
const mobilityFlowWorkout = Workout(
  id: 'recovery-mobility-flow',
  name: 'Dynamic Mobility Flow',
  description: 'Open up tight spots and improve range of motion',
  type: WorkoutType.recovery,
  estimatedDuration: Duration(minutes: 15),
  targetRpe: 2,
  exercises: [
    Exercise(
      name: 'Cat-Cow Stretch', 
      reps: 10,
      description: 'Hands and knees. Arch back like an angry cat (head down). Then drop belly and look up (cow). Move slowly with your breath.',
    ),
    Exercise(
      name: 'Thread the Needle', 
      reps: 8, 
      perSide: 'each side',
      description: 'Hands and knees. Reach one arm underneath your body and rest shoulder on floor. Feel twist in upper back.',
    ),
    Exercise(
      name: 'Hip Circles', 
      reps: 10, 
      perSide: 'each direction',
      description: 'Hands and knees. Lift one knee and make big circles with your hip. Imagine drawing a circle with your knee cap.',
    ),
    Exercise(
      name: "World's Greatest Stretch", 
      reps: 5, 
      perSide: 'each side',
      description: 'Step into a deep lunge. Put opposite hand on floor. Reach other arm to sky. Twist torso. Complex but amazing for hips and back.',
    ),
    Exercise(
      name: 'Ankle Circles', 
      reps: 10, 
      perSide: 'each direction',
      description: 'Sit or stand. Rotate ankle in big circles. Full range of motion. Critical for runners.',
    ),
    Exercise(
      name: 'Neck Rolls', 
      reps: 5, 
      perSide: 'each direction',
      description: 'Gently roll head in circles. Ear to shoulder, chin to chest. Do not force it. Keep shoulders down.',
    ),
  ],
);

/// Full Body Stretch + Foam Roll (Week 2)
const fullStretchWorkout = Workout(
  id: 'recovery-full-stretch',
  name: 'Full Body Stretch',
  description: 'Deep stretching for recovery and flexibility',
  type: WorkoutType.recovery,
  estimatedDuration: Duration(minutes: 20),
  targetRpe: 2,
  exercises: [
    Exercise(
      name: 'Standing Forward Fold', 
      holdTime: Duration(seconds: 45),
      description: 'Stand tall. Hinge at hips to fold forward. Let head hang heavy. Can bend knees slightly. Feel release in lower back and hamstrings.',
    ),
    Exercise(
      name: 'Pigeon Pose', 
      holdTime: Duration(seconds: 60), 
      perSide: 'each side',
      description: 'One leg forward, knee bent on ground. Back leg straight back. Fold over front leg. Deep hip stretch. Breathe into the tightness.',
    ),
    Exercise(
      name: 'Seated Hamstring Stretch', 
      holdTime: Duration(seconds: 45), 
      perSide: 'each leg',
      description: 'Sit on floor, one leg straight, one bent. Reach for toes of straight leg. Keep back straight-ish. Don\'t just hunch.',
    ),
    Exercise(
      name: 'Supine Twist', 
      holdTime: Duration(seconds: 45), 
      perSide: 'each side',
      description: 'Lie on back. Hug one knee, then pull it across body to the floor. Keep opposite shoulder on ground. Spinal twist.',
    ),
    Exercise(
      name: 'Figure Four Stretch', 
      holdTime: Duration(seconds: 45), 
      perSide: 'each side',
      description: 'Lie on back. Cross ankle over opposite knee. Pull the bottom leg towards you. Deep glute stretch.',
    ),
    Exercise(
      name: 'Foam Roll Quads', 
      duration: Duration(seconds: 60),
      description: 'Lie fast down on foam roller (under thighs). Roll back and forth from hip to knee. It will hurt good.',
    ),
    Exercise(
      name: 'Foam Roll IT Band', 
      duration: Duration(seconds: 60), 
      perSide: 'each side',
      description: 'Lie on side with roller under outer thigh. Roll from hip to knee. Support weight with arms.',
    ),
  ],
);

/// Yoga Flow + Hip Openers (Week 3)
const yogaFlowWorkout = Workout(
  id: 'recovery-yoga-flow',
  name: 'Yoga Flow + Hip Openers',
  description: 'Yoga-inspired movement for runners',
  type: WorkoutType.recovery,
  estimatedDuration: Duration(minutes: 25),
  targetRpe: 3,
  exercises: [
    Exercise(
      name: 'Sun Salutation A', 
      reps: 3,
      description: 'Mountain pose -> Forward fold -> Plank -> Lower down -> Up dog -> Down dog -> Step forward -> Rise up. Repeat flow.',
    ),
    Exercise(
      name: 'Warrior I', 
      holdTime: Duration(seconds: 30), 
      perSide: 'each side',
      description: 'High lunge position. Back heel down at 45 degrees. Hips forward. Arms reaching straight up. Strong legs.',
    ),
    Exercise(
      name: 'Warrior II', 
      holdTime: Duration(seconds: 30), 
      perSide: 'each side',
      description: 'Wide stance. Front knee bent 90 degrees. Arms out to sides horizonally. Gaze over front hand. Open hips.',
    ),
    Exercise(
      name: 'Low Lunge', 
      holdTime: Duration(seconds: 45), 
      perSide: 'each side',
      description: 'Knee down lunge. Push hips forward. Lift chest. Sink into the hip stretch.',
    ),
    Exercise(
      name: 'Lizard Pose', 
      holdTime: Duration(seconds: 45), 
      perSide: 'each side',
      description: 'From low lunge, bring both hands to the inside of front foot. Lower onto elbows if flexible enough. Deep hip opener.',
    ),
    Exercise(
      name: 'Happy Baby', 
      holdTime: Duration(seconds: 60),
      description: 'Lie on back. Grab outsides of feet. Pull knees towards armpits. Rock gently side to side.',
    ),
    Exercise(
      name: 'Savasana', 
      duration: Duration(minutes: 2),
      description: 'Corpse pose. Lie flat on back. Palms up. Eyes closed. Relax every muscle. Do nothing.',
    ),
  ],
);

/// Light Mobility (Week 4 - Pre-race)
const lightMobilityWorkout = Workout(
  id: 'recovery-light-mobility',
  name: 'Light Mobility',
  description: 'Gentle movement to stay loose before race day',
  type: WorkoutType.recovery,
  estimatedDuration: Duration(minutes: 15),
  targetRpe: 2,
  exercises: [
    Exercise(
      name: 'Gentle Leg Swings', 
      reps: 10, 
      perSide: 'each leg',
      description: 'Small range of motion. Just loosening up the hip joint. Don\'t force it.',
    ),
    Exercise(
      name: 'Hip Circles', 
      reps: 8, 
      perSide: 'each direction',
      description: 'Standing hands on hips. Rotate hips in circle like hula hooping.',
    ),
    Exercise(
      name: 'Ankle Rolls', 
      reps: 10, 
      perSide: 'each direction',
      description: 'Rotate ankles to ensure they are mobile for the run.',
    ),
    Exercise(
      name: 'Standing Quad Stretch', 
      holdTime: Duration(seconds: 20), 
      perSide: 'each leg',
      description: 'Pull heel to butt. Keep knees together. Gentle stretch.',
    ),
    Exercise(
      name: 'Calf Stretch', 
      holdTime: Duration(seconds: 20), 
      perSide: 'each leg',
      description: 'Heel down, toe up against wall or curb. Lean in slightly.',
    ),
  ],
);

// ============================================================================
// WALK WORKOUTS
// ============================================================================

/// Easy Walk + Stretching (Recovery day walk)
const easyWalkWorkout = Workout(
  id: 'walk-easy',
  name: 'Easy Walk + Stretching',
  description: 'Light movement to promote blood flow and recovery',
  type: WorkoutType.walk,
  estimatedDuration: Duration(minutes: 25),
  estimatedDistanceKm: 2.0,
  targetRpe: 2,
);

/// Brisk Walk (Week 3 active recovery)
const briskWalkWorkout = Workout(
  id: 'walk-brisk',
  name: 'Brisk Walk + Stretch',
  description: 'Moderate pace walk with stretching',
  type: WorkoutType.walk,
  estimatedDuration: Duration(minutes: 30),
  estimatedDistanceKm: 3.0,
  targetRpe: 3,
);

/// Victory Walk (Post-5K celebration)
const victoryWalkWorkout = Workout(
  id: 'walk-victory',
  name: 'Victory Walk',
  description: 'Celebrate your achievement with a gentle walk',
  type: WorkoutType.walk,
  estimatedDuration: Duration(minutes: 20),
  estimatedDistanceKm: 2.0,
  targetRpe: 2,
);

// ============================================================================
// REST DAY
// ============================================================================

const restDayWorkout = Workout(
  id: 'rest-complete',
  name: 'Complete Rest',
  description: 'Your body builds strength during rest. Enjoy the day off!',
  type: WorkoutType.rest,
  estimatedDuration: Duration.zero,
  targetRpe: 0,
);

// ============================================================================
// RUN WORKOUTS - WEEK 1
// ============================================================================

/// Week 1 Day 1: Run 1min, Walk 2min × 8
final week1Day1Run = Workout(
  id: 'run-w1d1',
  name: 'First Steps',
  description: 'Your running journey begins today',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 24),
  estimatedDistanceKm: 2.5,
  targetRpe: 5,
  intervalRepeats: 8,
  intervals: [
    RunInterval.run(1, 'Easy jog pace'),
    RunInterval.walk(2, 'Comfortable walk'),
  ],
);

/// Week 1 Day 3: Run 2min, Walk 2min × 6
final week1Day3Run = Workout(
  id: 'run-w1d3',
  name: 'Building Rhythm',
  description: 'Slightly longer runs, same great progress',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 24),
  estimatedDistanceKm: 2.8,
  targetRpe: 5,
  intervalRepeats: 6,
  intervals: [
    RunInterval.run(2, 'Find your rhythm'),
    RunInterval.walk(2, 'Active recovery'),
  ],
);

/// Week 1 Day 5: Run 2min, Walk 1min × 7
final week1Day5Run = Workout(
  id: 'run-w1d5',
  name: 'First Week Finish',
  description: 'Shorter walks, you\'re getting stronger',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 21),
  estimatedDistanceKm: 3.0,
  targetRpe: 6,
  intervalRepeats: 7,
  intervals: [
    RunInterval.run(2, 'Steady pace'),
    RunInterval.walk(1, 'Quick recovery'),
  ],
);

// ============================================================================
// RUN WORKOUTS - WEEK 2
// ============================================================================

/// Week 2 Day 1: Run 3min, Walk 1min × 6
final week2Day1Run = Workout(
  id: 'run-w2d1',
  name: 'Endurance Builder',
  description: 'Longer runs start here',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 24),
  estimatedDistanceKm: 3.5,
  targetRpe: 6,
  intervalRepeats: 6,
  intervals: [
    RunInterval.run(3, 'Settle into the run'),
    RunInterval.walk(1, 'Brief recovery'),
  ],
);

/// Week 2 Day 3: Run 4min, Walk 1min × 5
final week2Day3Run = Workout(
  id: 'run-w2d3',
  name: 'Four Minute Miles',
  description: 'You can run for four minutes now!',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 25),
  estimatedDistanceKm: 4.0,
  targetRpe: 6,
  intervalRepeats: 5,
  intervals: [
    RunInterval.run(4, 'Conversational pace'),
    RunInterval.walk(1, 'Stay moving'),
  ],
);

/// Week 2 Day 5: Run 5min, Walk 1min × 4
final week2Day5Run = Workout(
  id: 'run-w2d5',
  name: 'Five and Thrive',
  description: 'Half a 5K is now possible in one go',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 24),
  estimatedDistanceKm: 4.0,
  targetRpe: 7,
  intervalRepeats: 4,
  intervals: [
    RunInterval.run(5, 'Strong and steady'),
    RunInterval.walk(1, 'You earned this'),
  ],
);

// ============================================================================
// RUN WORKOUTS - WEEK 3 (The Mental Hurdle)
// ============================================================================

/// Week 3 Day 1: 8 min continuous + 2min walk + 8min
final week3Day1Run = Workout(
  id: 'run-w3d1',
  name: 'Double Eight',
  description: 'Two 8-minute runs - you\'re almost there',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 20),
  estimatedDistanceKm: 3.5,
  targetRpe: 6,
  intervalRepeats: 1,
  intervals: [
    RunInterval.run(8, 'First big block'),
    RunInterval.walk(2, 'Catch your breath'),
    RunInterval.run(8, 'Finish strong'),
  ],
);

/// Week 3 Day 3: 12 min continuous
final week3Day3Run = Workout(
  id: 'run-w3d3',
  name: '12 Minute Mile',
  description: 'Your first long continuous run',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 12),
  estimatedDistanceKm: 2.0,
  targetRpe: 7,
  intervalRepeats: 1,
  intervals: [
    RunInterval.run(12, 'No walking - you can do this'),
  ],
);

/// Week 3 Day 5: 15 min continuous
final week3Day5Run = Workout(
  id: 'run-w3d5',
  name: 'Fifteen',
  description: 'You ARE a runner now',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 15),
  estimatedDistanceKm: 2.5,
  targetRpe: 7,
  intervalRepeats: 1,
  intervals: [
    RunInterval.run(15, 'Embrace the runner\'s high'),
  ],
);

// ============================================================================
// RUN WORKOUTS - WEEK 4 (The 5K Push)
// ============================================================================

/// Week 4 Day 1: 20 min easy continuous
final week4Day1Run = Workout(
  id: 'run-w4d1',
  name: 'Twenty',
  description: 'Easy 20 - don\'t push too hard before race day',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 20),
  estimatedDistanceKm: 3.5,
  targetRpe: 6,
  intervalRepeats: 1,
  intervals: [
    RunInterval.run(20, 'Easy effort, save your legs'),
  ],
);

/// Week 4 Day 3: 25 min with negative split
final week4Day3Run = Workout(
  id: 'run-w4d3',
  name: 'Negative Split',
  description: 'Start slow, finish fast - race day practice',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 25),
  estimatedDistanceKm: 4.5,
  targetRpe: 7,
  intervalRepeats: 1,
  intervals: [
    RunInterval.run(12, 'First half: Comfortable'),
    RunInterval.run(13, 'Second half: Pick it up!'),
  ],
);

/// Week 4 Day 5: THE 5K TEST
final week4Day5_5K = Workout(
  id: 'run-5k-test',
  name: '5K TEST DAY!',
  description: '28 days of work. 5 kilometers of proof. Let\'s go!',
  type: WorkoutType.run,
  estimatedDuration: const Duration(minutes: 35),
  estimatedDistanceKm: 5.0,
  targetRpe: 8,
  intervalRepeats: 1,
  intervals: [
    RunInterval.run(35, 'YOUR 5K - Run the whole thing!'),
  ],
);

// ============================================================================
// COMPLETE 28-DAY PROGRAM
// ============================================================================

/// The complete Couch to 5K in 28 days training program
TrainingProgram getFullTrainingProgram() {
  return TrainingProgram(
    id: 'couch-to-5k-28',
    name: 'Couch to 5K',
    description: 'Zero to runner in 28 days',
    totalDays: 28,
    weeks: [
      // WEEK 1: ACCLIMATIZATION
      TrainingWeek(
        weekNumber: 1,
        name: 'ACCLIMATIZATION',
        focus: 'Build Habit, Not Fitness',
        totalDistanceKm: 8.5,
        mentalInsight: 'This week is about showing up. The runs will feel challenging, but that\'s normal. Focus on consistency, not performance.',
        days: [
          TrainingDay(
            dayNumber: 1, weekNumber: 1, dayOfWeek: 1,
            workout: week1Day1Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'Day 1 is where runners are made. You\'ve already done the hardest part - you showed up.',
            motivationAfter: 'You did it! Day 1 complete. You\'re not trying to become a runner. You ARE a runner now.',
          ),
          TrainingDay(
            dayNumber: 2, weekNumber: 1, dayOfWeek: 2,
            workout: mobilityFlowWorkout,
            motivationBefore: 'Mobility work unlocks your potential. Every stretch makes tomorrow\'s run easier.',
            motivationAfter: 'Great recovery work. Your muscles are thanking you.',
          ),
          TrainingDay(
            dayNumber: 3, weekNumber: 1, dayOfWeek: 3,
            workout: week1Day3Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'Day 3 is where runners become consistent. Two down, one to become unstoppable.',
            motivationAfter: 'Three days in. You\'re building something powerful here.',
          ),
          TrainingDay(
            dayNumber: 4, weekNumber: 1, dayOfWeek: 4,
            workout: coreGluteWorkout,
            motivationBefore: 'Strong glutes = strong runner. This session prevents 60% of running injuries.',
            motivationAfter: 'Core activated. You\'re building the engine that powers your runs.',
            injuryNote: 'Mild muscle soreness is normal and means you\'re getting stronger.',
          ),
          TrainingDay(
            dayNumber: 5, weekNumber: 1, dayOfWeek: 5,
            workout: week1Day5Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'Last run of the week! Shorter walks mean you\'re already getting faster.',
            motivationAfter: 'Week 1 running: COMPLETE. You just did what most people never will.',
          ),
          TrainingDay(
            dayNumber: 6, weekNumber: 1, dayOfWeek: 6,
            workout: easyWalkWorkout,
            motivationBefore: 'Active recovery keeps the blood flowing. Easy movement, big benefits.',
            motivationAfter: 'Recovery done right. Tomorrow is full rest - you\'ve earned it.',
          ),
          TrainingDay(
            dayNumber: 7, weekNumber: 1, dayOfWeek: 7,
            workout: restDayWorkout,
            motivationBefore: 'Rest is when your body gets stronger. Enjoy this day off completely.',
            motivationAfter: 'Week 1 complete! You showed up every single day. That\'s elite mentality.',
          ),
        ],
      ),

      // WEEK 2: BUILDING ENDURANCE
      TrainingWeek(
        weekNumber: 2,
        name: 'BUILDING ENDURANCE',
        focus: 'Extend Run Intervals',
        totalDistanceKm: 11.5,
        mentalInsight: 'Your body is adapting. The runs get longer, but your capacity is growing faster than you realize. Trust the process.',
        days: [
          TrainingDay(
            dayNumber: 8, weekNumber: 2, dayOfWeek: 1,
            workout: week2Day1Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'Week 2 begins. 3-minute runs start here. You\'ve got the base - now we build.',
            motivationAfter: 'First 3-minute intervals done! Your endurance is growing.',
            injuryNote: 'Days 8-14 are the adaptation phase. Mild shin tightness or quad soreness is normal.',
          ),
          TrainingDay(
            dayNumber: 9, weekNumber: 2, dayOfWeek: 2,
            workout: upperBodyCoreWorkout,
            motivationBefore: 'Upper body and core make your running more efficient. Strong arms = faster finish.',
            motivationAfter: 'Strength building. You\'re becoming a more complete athlete.',
          ),
          TrainingDay(
            dayNumber: 10, weekNumber: 2, dayOfWeek: 3,
            workout: week2Day3Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'This is the hardest mental day of the program. Every runner goes through this. Push through today.',
            motivationAfter: 'You just conquered the toughest mental day. It gets easier from here. Seriously.',
            injuryNote: 'If you feel heavy or tired, that\'s completely normal. Your body is in deep adaptation.',
          ),
          TrainingDay(
            dayNumber: 11, weekNumber: 2, dayOfWeek: 4,
            workout: fullStretchWorkout,
            motivationBefore: 'Deep stretching today. Your muscles are working hard - this is your reward.',
            motivationAfter: 'Flexibility improved. Tomorrow you\'ll feel the difference.',
          ),
          TrainingDay(
            dayNumber: 12, weekNumber: 2, dayOfWeek: 5,
            workout: week2Day5Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: '5-minute runs! You can now run half a 5K distance in one interval.',
            motivationAfter: 'Week 2 running: DONE. Look how far you\'ve come in just 12 days!',
          ),
          TrainingDay(
            dayNumber: 13, weekNumber: 2, dayOfWeek: 6,
            workout: lowerBodyWorkout,
            motivationBefore: 'Strong legs finish races. This workout builds the power you need.',
            motivationAfter: 'Lower body power: Activated. You\'re ready for Week 3.',
          ),
          TrainingDay(
            dayNumber: 14, weekNumber: 2, dayOfWeek: 7,
            workout: restDayWorkout,
            motivationBefore: 'Halfway through the program! Rest up - Week 3 is the mental breakthrough week.',
            motivationAfter: '2 weeks complete. You\'re ahead of 90% of people who ever say "I want to run."',
          ),
        ],
      ),

      // WEEK 3: THE MENTAL HURDLE
      TrainingWeek(
        weekNumber: 3,
        name: 'THE MENTAL HURDLE',
        focus: 'Continuous Running',
        totalDistanceKm: 9.0,
        mentalInsight: 'This is where intervals become continuous running. The mental shift is harder than the physical. You WILL doubt yourself. That\'s the sign you\'re growing.',
        days: [
          TrainingDay(
            dayNumber: 15, weekNumber: 3, dayOfWeek: 1,
            workout: week3Day1Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'Two 8-minute runs today. This is the bridge to continuous running. You\'ve got this.',
            motivationAfter: '16 minutes of running today! You just proved you can run longer than you thought.',
          ),
          TrainingDay(
            dayNumber: 16, weekNumber: 3, dayOfWeek: 2,
            workout: corePowerWorkout,
            motivationBefore: 'Core power for the final push. Strong core = better endurance.',
            motivationAfter: 'Core is firing. Two weeks to 5K!',
          ),
          TrainingDay(
            dayNumber: 17, weekNumber: 3, dayOfWeek: 3,
            workout: week3Day3Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: '12 minutes. No walking. You CAN do this. Don\'t stop when you feel doubt - that\'s exactly when you push through.',
            motivationAfter: '12 MINUTES STRAIGHT! You just did what felt impossible a week ago.',
          ),
          TrainingDay(
            dayNumber: 18, weekNumber: 3, dayOfWeek: 4,
            workout: yogaFlowWorkout,
            motivationBefore: 'Yoga flow for runners. This session fixes the tightness that sneaks up on you.',
            motivationAfter: 'Hips open, body loose. Recovery is your secret weapon.',
          ),
          TrainingDay(
            dayNumber: 19, weekNumber: 3, dayOfWeek: 5,
            workout: week3Day5Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: '15 minutes continuous. After this, you\'re a runner. Not trying to be one. You ARE one.',
            motivationAfter: 'FIFTEEN MINUTES! Week 3 running: CONQUERED. You broke through the wall.',
          ),
          TrainingDay(
            dayNumber: 20, weekNumber: 3, dayOfWeek: 6,
            workout: briskWalkWorkout,
            motivationBefore: 'Brisk walk to keep moving. Stay loose for the final week.',
            motivationAfter: 'One week to 5K. Let that sink in.',
          ),
          TrainingDay(
            dayNumber: 21, weekNumber: 3, dayOfWeek: 7,
            workout: restDayWorkout,
            motivationBefore: '7 days to your 5K. Rest completely. You\'re in the final stretch.',
            motivationAfter: 'Week 3 complete. Your 5K is coming. You\'re ready.',
          ),
        ],
      ),

      // WEEK 4: THE 5K PUSH
      TrainingWeek(
        weekNumber: 4,
        name: 'THE 5K PUSH',
        focus: 'Race Readiness',
        totalDistanceKm: 13.0,
        mentalInsight: 'This week is about confidence, not fitness. Your body is ready. Now we prepare your mind. Taper the intensity, sharpen the focus.',
        days: [
          TrainingDay(
            dayNumber: 22, weekNumber: 4, dayOfWeek: 1,
            workout: week4Day1Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: '20 minutes easy. Don\'t push hard - save your legs for race day.',
            motivationAfter: '20 minutes continuous. Remember when 1 minute felt hard? Look at you now.',
          ),
          TrainingDay(
            dayNumber: 23, weekNumber: 4, dayOfWeek: 2,
            workout: lightMobilityWorkout,
            motivationBefore: 'Light mobility only. Stay loose, don\'t strain.',
            motivationAfter: 'Nice and easy. 3 days to your 5K.',
          ),
          TrainingDay(
            dayNumber: 24, weekNumber: 4, dayOfWeek: 3,
            workout: week4Day3Run,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'Negative split: Start slow, finish fast. This is your race day dress rehearsal.',
            motivationAfter: 'Race strategy: Practiced. You know how to pace yourself now.',
          ),
          TrainingDay(
            dayNumber: 25, weekNumber: 4, dayOfWeek: 4,
            workout: restDayWorkout,
            motivationBefore: 'Pre-race rest. Complete rest today. Hydrate well. Sleep well.',
            motivationAfter: 'Tomorrow is 5K day. Everything you\'ve done has led to this.',
          ),
          TrainingDay(
            dayNumber: 26, weekNumber: 4, dayOfWeek: 5,
            workout: week4Day5_5K,
            warmup: preRunWarmup,
            cooldown: postRunCooldown,
            motivationBefore: 'This is it. 28 days of work. 5 kilometers of proof. Whatever happens, you gave it everything. Now RUN.',
            motivationAfter: 'YOU DID IT! 5 KILOMETERS! From couch to finish line. YOU ARE A RUNNER. LEGENDARY!',
          ),
          TrainingDay(
            dayNumber: 27, weekNumber: 4, dayOfWeek: 6,
            workout: victoryWalkWorkout,
            motivationBefore: 'Victory walk. Celebrate what you achieved. You earned this.',
            motivationAfter: 'A gentle walk for a champion. Enjoy this feeling.',
          ),
          TrainingDay(
            dayNumber: 28, weekNumber: 4, dayOfWeek: 7,
            workout: restDayWorkout,
            motivationBefore: 'Final rest day. Reflect on your journey. You did something extraordinary.',
            motivationAfter: 'The program is complete. But your journey as a runner? It\'s just beginning.',
          ),
        ],
      ),
    ],
  );
}
