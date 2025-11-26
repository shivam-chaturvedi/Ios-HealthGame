// ==================== DATA MODELS ====================

export interface PhysioData {
  hr: number; // Heart rate (BPM)
  hrv: number; // Heart rate variability (ms)
  rr: number; // Respiratory rate (breaths/min)
  eda: number; // Electrodermal activity (peaks/min)
  temp: number; // Skin temperature (°C)
  motion: number; // Motion intensity (0-100)
  timestamp: Date;
}

export interface SleepData {
  sleepTime: string; // HH:MM
  wakeTime: string; // HH:MM
  duration: number; // hours
  efficiency: number; // percentage
  debt: number; // hours
  bedtimeShift: number; // minutes from usual
}

export interface StimulantData {
  caffeineAfter2pm: number; // mg
  nicotine: boolean;
  alcoholAfter8pm: number; // units
}

export interface ActivityData {
  steps: number;
  workoutMinutes: number;
  isOverExercise: boolean;
}

export interface ContextData {
  hasExam: boolean;
  hasDeadline: boolean;
  workloadHours: number;
  stressSlider: number; // 0-100
}

export interface SelfCareData {
  meditationMinutes: number;
  journalingMinutes: number;
  breathingMinutes: number;
  gratitudeMinutes: number;
}

export interface MenstrualData {
  phase: 'follicular' | 'ovulation' | 'luteal' | 'menstrual' | 'none';
  dayOfCycle: number;
}

export interface ScreenData {
  postElevenPmMinutes: number;
  totalDaytimeHours: number;
}

export interface DietData {
  mealsSkipped: number;
  sugaryFoods: boolean;
  waterGlasses: number;
}

export interface LifestyleData {
  sleep: SleepData;
  stimulants: StimulantData;
  activity: ActivityData;
  context: ContextData;
  selfCare: SelfCareData;
  menstrual: MenstrualData;
  screen: ScreenData;
  diet: DietData;
}

export interface CheckinData {
  gad2Score: number; // 0-6
  mood: number; // 0-4
  anxietyMoments: AnxietyMoment[];
  lastUpdated: Date;
}

export interface AnxietyMoment {
  id: string;
  timestamp: Date;
  notes?: string;
  intensity: number; // 1-5
}

export interface AnxietyScore {
  aps: number; // Acute Physiology Score (0-100)
  lrs: number; // Lifestyle Risk Score (0-100)
  cs: number; // Check-in Score (0-100)
  stateEstimate: number; // S = α*APS + (1-α)*LRS
  finalScore: number; // AS (1-100)
  confidence: 'high' | 'medium' | 'low';
  timestamp: Date;
  contributors: Contributor[];
}

export interface Contributor {
  name: string;
  category: 'physiology' | 'lifestyle' | 'checkin';
  impact: number; // percentage contribution
  trend: 'up' | 'down' | 'stable';
}

export interface Baseline {
  hr: { mean: number; sd: number };
  hrv: { mean: number; sd: number };
  rr: { mean: number; sd: number };
  eda: { mean: number; sd: number };
  temp: { mean: number; sd: number };
  lastUpdated: Date;
  isCalibrated: boolean;
  calibrationDay: number;
}

export interface Intervention {
  id: string;
  type: 'breathing' | 'grounding' | 'walk' | 'journal' | 'music';
  name: string;
  description: string;
  duration: number; // minutes
  icon: string;
  effectiveness?: number; // user rating 1-5
}

export interface WeeklyInsight {
  weekStart: Date;
  weekEnd: Date;
  averageScore: number;
  peakTimes: string[];
  topLifestyleContributors: { name: string; impact: number }[];
  topPhysioContributors: { name: string; impact: number }[];
  effectiveInterventions: { name: string; rating: number }[];
  scoreHistory: { date: Date; score: number }[];
}

export interface UserSettings {
  primaryConcern: 'stress' | 'panic' | 'anxiety';
  notificationFrequency: 'low' | 'medium' | 'high';
  aiPersonalization: boolean;
  dataExport: boolean;
}

// ==================== LIFESTYLE WEIGHTS ====================
export const LIFESTYLE_WEIGHTS = {
  sleep: 0.30,
  stimulants: 0.20,
  activity: 0.10,
  context: 0.15,
  selfCare: 0.05,
  menstrual: 0.05,
  screen: 0.10,
  diet: 0.05,
} as const;

// ==================== PHYSIOLOGY WEIGHTS ====================
export const PHYSIOLOGY_WEIGHTS = {
  hr: 0.20,
  hrv: 0.20,
  rr: 0.15,
  eda: 0.20,
  temp: 0.10,
  motion: 0.15,
} as const;

export type AnxietyLevel = 'low' | 'moderate' | 'high' | 'very-high';

export function getAnxietyLevel(score: number): AnxietyLevel {
  if (score <= 30) return 'low';
  if (score <= 50) return 'moderate';
  if (score <= 70) return 'high';
  return 'very-high';
}

export function getAnxietyColor(level: AnxietyLevel): string {
  switch (level) {
    case 'low': return 'text-anxiety-low';
    case 'moderate': return 'text-anxiety-moderate';
    case 'high': return 'text-anxiety-high';
    case 'very-high': return 'text-anxiety-very-high';
  }
}

export function getAnxietyBgColor(level: AnxietyLevel): string {
  switch (level) {
    case 'low': return 'bg-anxiety-low';
    case 'moderate': return 'bg-anxiety-moderate';
    case 'high': return 'bg-anxiety-high';
    case 'very-high': return 'bg-anxiety-very-high';
  }
}
