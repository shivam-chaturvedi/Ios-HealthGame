import {
  PhysioData,
  LifestyleData,
  CheckinData,
  Baseline,
  Intervention,
  WeeklyInsight,
  AnxietyScore,
} from '@/types/anxiety';

// ==================== MOCK PHYSIOLOGICAL DATA ====================
export const mockPhysioData: PhysioData = {
  hr: 72,
  hrv: 45,
  rr: 14,
  eda: 1.2,
  temp: 33.5,
  motion: 15,
  timestamp: new Date(),
};

// ==================== MOCK BASELINE ====================
export const mockBaseline: Baseline = {
  hr: { mean: 68, sd: 8 },
  hrv: { mean: 50, sd: 12 },
  rr: { mean: 12, sd: 2 },
  eda: { mean: 0.5, sd: 0.3 },
  temp: { mean: 34, sd: 0.5 },
  lastUpdated: new Date(),
  isCalibrated: true,
  calibrationDay: 4,
};

// ==================== MOCK LIFESTYLE DATA ====================
export const mockLifestyleData: LifestyleData = {
  sleep: {
    sleepTime: '23:30',
    wakeTime: '07:00',
    duration: 7.5,
    efficiency: 85,
    debt: 1.5,
    bedtimeShift: 30,
  },
  stimulants: {
    caffeineAfter2pm: 100,
    nicotine: false,
    alcoholAfter8pm: 0,
  },
  activity: {
    steps: 6500,
    workoutMinutes: 30,
    isOverExercise: false,
  },
  context: {
    hasExam: false,
    hasDeadline: true,
    workloadHours: 6,
    stressSlider: 55,
  },
  selfCare: {
    meditationMinutes: 10,
    journalingMinutes: 5,
    breathingMinutes: 5,
    gratitudeMinutes: 0,
  },
  menstrual: {
    phase: 'none',
    dayOfCycle: 0,
  },
  screen: {
    postElevenPmMinutes: 45,
    totalDaytimeHours: 5,
  },
  diet: {
    mealsSkipped: 0,
    sugaryFoods: true,
    waterGlasses: 6,
  },
};

// ==================== MOCK CHECK-IN DATA ====================
export const mockCheckinData: CheckinData = {
  gad2Score: 3,
  mood: 2,
  anxietyMoments: [
    {
      id: '1',
      timestamp: new Date(Date.now() - 3600000),
      notes: 'Presentation stress',
      intensity: 3,
    },
  ],
  lastUpdated: new Date(Date.now() - 7200000), // 2 hours ago
};

// ==================== MOCK ANXIETY SCORE ====================
export const mockAnxietyScore: AnxietyScore = {
  aps: 58,
  lrs: 52,
  cs: 50,
  stateEstimate: 55,
  finalScore: 47,
  confidence: 'high',
  timestamp: new Date(),
  contributors: [
    { name: 'sleep', category: 'lifestyle', impact: 18, trend: 'up' },
    { name: 'HR', category: 'physiology', impact: 12, trend: 'stable' },
    { name: 'screen', category: 'lifestyle', impact: 10, trend: 'up' },
    { name: 'context', category: 'lifestyle', impact: 8, trend: 'stable' },
  ],
};

// ==================== MOCK INTERVENTIONS ====================
export const mockInterventions: Intervention[] = [
  {
    id: '1',
    type: 'breathing',
    name: '4-7-8 Breathing',
    description: 'Inhale for 4 seconds, hold for 7, exhale for 8. Activates your parasympathetic nervous system.',
    duration: 5,
    icon: 'Wind',
    effectiveness: 4.2,
  },
  {
    id: '2',
    type: 'breathing',
    name: 'Box Breathing',
    description: 'Inhale, hold, exhale, hold — each for 4 seconds. Navy SEALs use this technique.',
    duration: 4,
    icon: 'Square',
    effectiveness: 4.5,
  },
  {
    id: '3',
    type: 'grounding',
    name: '5-4-3-2-1 Grounding',
    description: 'Notice 5 things you see, 4 you hear, 3 you touch, 2 you smell, 1 you taste.',
    duration: 3,
    icon: 'Hand',
    effectiveness: 4.0,
  },
  {
    id: '4',
    type: 'walk',
    name: 'Short Walk',
    description: 'A brief 5-minute walk can reset your nervous system and clear your mind.',
    duration: 5,
    icon: 'Footprints',
    effectiveness: 4.3,
  },
  {
    id: '5',
    type: 'journal',
    name: 'Anxiety Dump',
    description: 'Write down everything on your mind for 3 minutes without stopping.',
    duration: 3,
    icon: 'PenLine',
    effectiveness: 3.8,
  },
  {
    id: '6',
    type: 'music',
    name: 'Calming Soundscape',
    description: 'Listen to nature sounds or binaural beats to lower your heart rate.',
    duration: 10,
    icon: 'Music',
    effectiveness: 3.9,
  },
];

// ==================== MOCK WEEKLY INSIGHT ====================
export const mockWeeklyInsight: WeeklyInsight = {
  weekStart: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
  weekEnd: new Date(),
  averageScore: 42,
  peakTimes: ['9:00 AM', '3:00 PM', '11:00 PM'],
  topLifestyleContributors: [
    { name: 'Screen use after 11pm', impact: 15 },
    { name: 'Sleep debt', impact: 12 },
    { name: 'Caffeine intake', impact: 8 },
  ],
  topPhysioContributors: [
    { name: 'Elevated heart rate', impact: 10 },
    { name: 'Low HRV', impact: 8 },
  ],
  effectiveInterventions: [
    { name: 'Box Breathing', rating: 4.5 },
    { name: 'Short Walk', rating: 4.3 },
    { name: '4-7-8 Breathing', rating: 4.2 },
  ],
  scoreHistory: Array.from({ length: 7 }, (_, i) => ({
    date: new Date(Date.now() - (6 - i) * 24 * 60 * 60 * 1000),
    score: 35 + Math.random() * 30,
  })),
};

// ==================== MOCK TREND DATA (12 hours) ====================
export const mockTrendData = Array.from({ length: 24 }, (_, i) => ({
  time: new Date(Date.now() - (23 - i) * 30 * 60 * 1000),
  score: 30 + Math.sin(i / 4) * 15 + Math.random() * 10,
}));

// ==================== MOCK PHYSIO HISTORY (for charts) ====================
export const mockPhysioHistory = Array.from({ length: 30 }, (_, i) => ({
  time: new Date(Date.now() - (29 - i) * 60 * 1000),
  hr: 65 + Math.sin(i / 5) * 8 + Math.random() * 5,
  hrv: 45 + Math.cos(i / 5) * 10 + Math.random() * 5,
  rr: 12 + Math.sin(i / 8) * 2 + Math.random() * 1,
  eda: 0.5 + Math.sin(i / 6) * 0.3 + Math.random() * 0.2,
  temp: 33.5 + Math.cos(i / 10) * 0.3,
  motion: 10 + Math.random() * 20,
}));
