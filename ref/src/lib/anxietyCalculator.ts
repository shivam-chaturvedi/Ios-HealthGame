import {
  PhysioData,
  LifestyleData,
  CheckinData,
  AnxietyScore,
  Baseline,
  Contributor,
  LIFESTYLE_WEIGHTS,
  PHYSIOLOGY_WEIGHTS,
} from '@/types/anxiety';

// ==================== CHECK-IN SCORE (CS) ====================
export function calculateCheckinScore(checkin: CheckinData): number {
  const gadScaled = (checkin.gad2Score / 6) * 100;
  const moodScaled = (checkin.mood / 4) * 100;
  
  // Return the most recently updated score (for simplicity, using GAD if both available)
  if (checkin.gad2Score > 0) return gadScaled;
  return moodScaled;
}

// ==================== CHECK-IN DECAY WEIGHT ====================
export function calculateCheckinWeight(lastCheckinTime: Date): number {
  const hoursSinceCheckin = (Date.now() - lastCheckinTime.getTime()) / (1000 * 60 * 60);
  const halfLife = 8; // hours
  return Math.exp(-hoursSinceCheckin / halfLife);
}

// ==================== LIFESTYLE RISK MAPPINGS ====================
function calculateSleepRisk(sleep: LifestyleData['sleep']): number {
  let risk = 0;
  
  // Sleep debt mapping
  if (sleep.debt <= 0) risk = 20;
  else if (sleep.debt <= 1) risk = 40;
  else if (sleep.debt <= 2) risk = 60;
  else if (sleep.debt <= 3) risk = 80;
  else risk = 95;
  
  // Efficiency penalty
  if (sleep.efficiency < 80) risk += 10;
  
  // Bedtime shift penalty
  if (sleep.bedtimeShift > 90) risk += 5;
  
  return Math.min(100, risk);
}

function calculateStimulantRisk(stimulants: LifestyleData['stimulants']): number {
  let risk = 0;
  
  // Caffeine after 2pm
  if (stimulants.caffeineAfter2pm <= 0) risk = 20;
  else if (stimulants.caffeineAfter2pm <= 100) risk = 40;
  else if (stimulants.caffeineAfter2pm <= 200) risk = 65;
  else risk = 85;
  
  // Nicotine
  if (stimulants.nicotine) risk = Math.max(risk, 80);
  
  // Alcohol after 8pm
  risk += stimulants.alcoholAfter8pm * 10;
  
  return Math.min(100, Math.max(0, risk));
}

function calculateActivityRisk(activity: LifestyleData['activity']): number {
  let risk = 50; // baseline
  
  const totalMinutes = activity.workoutMinutes;
  
  if (totalMinutes <= 10) risk += 10; // sedentary
  else if (totalMinutes >= 20 && totalMinutes <= 30) risk -= 5;
  else if (totalMinutes >= 45 && totalMinutes <= 60) risk -= 15;
  
  if (activity.isOverExercise || totalMinutes > 120) risk += 5;
  
  return Math.min(100, Math.max(0, risk));
}

function calculateContextRisk(context: LifestyleData['context']): number {
  let risk = context.stressSlider;
  
  if (context.hasExam || context.hasDeadline) risk = Math.max(risk, 85);
  if (context.workloadHours > 8) risk += 10;
  
  return Math.min(100, risk);
}

function calculateSelfCareRisk(selfCare: LifestyleData['selfCare']): number {
  const totalMinutes = 
    selfCare.meditationMinutes + 
    selfCare.journalingMinutes + 
    selfCare.breathingMinutes + 
    selfCare.gratitudeMinutes;
  
  let risk = 50;
  
  if (totalMinutes === 0) risk += 5;
  else if (totalMinutes >= 10 && totalMinutes < 20) risk -= 5;
  else if (totalMinutes >= 20 && totalMinutes < 30) risk -= 10;
  else if (totalMinutes >= 30) risk -= 15;
  
  return Math.min(100, Math.max(0, risk));
}

function calculateMenstrualRisk(menstrual: LifestyleData['menstrual']): number {
  if (menstrual.phase === 'none') return 50;
  if (menstrual.phase === 'luteal') return 65;
  if (menstrual.phase === 'menstrual') return 55;
  return 45; // follicular/ovulation
}

function calculateScreenRisk(screen: LifestyleData['screen']): number {
  let risk = 20;
  
  // Post-11pm usage
  if (screen.postElevenPmMinutes >= 90) risk = 85;
  else if (screen.postElevenPmMinutes >= 60) risk = 70;
  else if (screen.postElevenPmMinutes >= 30) risk = 50;
  
  // Daytime excess
  if (screen.totalDaytimeHours > 6) {
    risk += (screen.totalDaytimeHours - 6) * 5;
  }
  
  return Math.min(100, risk);
}

function calculateDietRisk(diet: LifestyleData['diet']): number {
  let risk = 30;
  
  risk += diet.mealsSkipped * 15;
  if (diet.sugaryFoods) risk += 10;
  
  if (diet.waterGlasses < 5) risk += 15;
  else if (diet.waterGlasses >= 8) risk -= 5;
  
  return Math.min(100, Math.max(0, risk));
}

// ==================== LIFESTYLE RISK SCORE (LRS) ====================
export function calculateLifestyleRiskScore(lifestyle: LifestyleData): { score: number; breakdown: Record<string, number> } {
  const breakdown = {
    sleep: calculateSleepRisk(lifestyle.sleep),
    stimulants: calculateStimulantRisk(lifestyle.stimulants),
    activity: calculateActivityRisk(lifestyle.activity),
    context: calculateContextRisk(lifestyle.context),
    selfCare: calculateSelfCareRisk(lifestyle.selfCare),
    menstrual: calculateMenstrualRisk(lifestyle.menstrual),
    screen: calculateScreenRisk(lifestyle.screen),
    diet: calculateDietRisk(lifestyle.diet),
  };
  
  const score = 
    LIFESTYLE_WEIGHTS.sleep * breakdown.sleep +
    LIFESTYLE_WEIGHTS.stimulants * breakdown.stimulants +
    LIFESTYLE_WEIGHTS.activity * breakdown.activity +
    LIFESTYLE_WEIGHTS.context * breakdown.context +
    LIFESTYLE_WEIGHTS.selfCare * breakdown.selfCare +
    LIFESTYLE_WEIGHTS.menstrual * breakdown.menstrual +
    LIFESTYLE_WEIGHTS.screen * breakdown.screen +
    LIFESTYLE_WEIGHTS.diet * breakdown.diet;
  
  return { score, breakdown };
}

// ==================== PHYSIOLOGY RISK MAPPINGS ====================
function calculateZScore(value: number, mean: number, sd: number): number {
  if (sd === 0) return 0;
  return (value - mean) / sd;
}

function mapZScoreToRisk(z: number, inverse: boolean = false): number {
  const absZ = inverse ? -z : z;
  
  if (absZ <= 0) return 30 + absZ * 10; // below baseline = protective
  if (absZ <= 1) return 50;
  if (absZ <= 1.5) return 70;
  if (absZ <= 2) return 85;
  if (absZ <= 3) return 95;
  return 100;
}

// ==================== ACUTE PHYSIOLOGY SCORE (APS) ====================
export function calculatePhysiologyScore(
  physio: PhysioData,
  baseline: Baseline,
  isExercising: boolean = false
): { score: number; breakdown: Record<string, number> } {
  if (isExercising || !baseline.isCalibrated) {
    return { score: 50, breakdown: { hr: 50, hrv: 50, rr: 50, eda: 50, temp: 50, motion: 50 } };
  }
  
  const hrZ = calculateZScore(physio.hr, baseline.hr.mean, baseline.hr.sd);
  const hrvZ = calculateZScore(physio.hrv, baseline.hrv.mean, baseline.hrv.sd);
  const rrZ = calculateZScore(physio.rr, baseline.rr.mean, baseline.rr.sd);
  const edaZ = calculateZScore(physio.eda, baseline.eda.mean, baseline.eda.sd);
  const tempZ = calculateZScore(physio.temp, baseline.temp.mean, baseline.temp.sd);
  
  const breakdown = {
    hr: mapZScoreToRisk(hrZ),
    hrv: mapZScoreToRisk(hrvZ, true), // inverse - lower HRV = higher risk
    rr: Math.min(100, 50 + (physio.rr - 12) * 6.25), // baseline ~12 breaths/min
    eda: Math.min(100, 50 + physio.eda * 15), // peaks/min mapping
    temp: mapZScoreToRisk(tempZ, true), // cooling = higher risk
    motion: physio.motion > 20 ? 60 + (physio.motion - 20) * 0.5 : 40, // fidgeting detection
  };
  
  const score = 
    PHYSIOLOGY_WEIGHTS.hr * breakdown.hr +
    PHYSIOLOGY_WEIGHTS.hrv * breakdown.hrv +
    PHYSIOLOGY_WEIGHTS.rr * breakdown.rr +
    PHYSIOLOGY_WEIGHTS.eda * breakdown.eda +
    PHYSIOLOGY_WEIGHTS.temp * breakdown.temp +
    PHYSIOLOGY_WEIGHTS.motion * breakdown.motion;
  
  return { score, breakdown };
}

// ==================== STATE ESTIMATE (S) ====================
export function calculateStateEstimate(
  aps: number,
  lrs: number,
  isResting: boolean,
  signalQuality: 'good' | 'poor'
): number {
  let alpha = 0.5; // default weight of physiology
  
  if (!isResting) alpha = 0;
  if (signalQuality === 'poor') alpha = 0;
  
  return alpha * aps + (1 - alpha) * lrs;
}

// ==================== FINAL ANXIETY SCORE (AS) ====================
export function calculateFinalAnxietyScore(
  cs: number,
  stateEstimate: number,
  checkinWeight: number
): number {
  const score = checkinWeight * cs + (1 - checkinWeight) * stateEstimate;
  return Math.round(Math.min(100, Math.max(1, score)));
}

// ==================== CONFIDENCE CALCULATION ====================
export function calculateConfidence(
  baseline: Baseline,
  signalQuality: 'good' | 'poor',
  checkinAge: number // hours since last checkin
): 'high' | 'medium' | 'low' {
  if (!baseline.isCalibrated) return 'low';
  if (signalQuality === 'poor') return 'low';
  if (checkinAge > 24) return 'medium';
  if (checkinAge > 48) return 'low';
  return 'high';
}

// ==================== TOP CONTRIBUTORS ====================
export function calculateTopContributors(
  physioBreakdown: Record<string, number>,
  lifestyleBreakdown: Record<string, number>
): Contributor[] {
  const contributors: Contributor[] = [];
  
  // Add physiology contributors
  Object.entries(physioBreakdown).forEach(([name, value]) => {
    if (value > 60) {
      contributors.push({
        name: name.toUpperCase(),
        category: 'physiology',
        impact: Math.round((value - 50) * PHYSIOLOGY_WEIGHTS[name as keyof typeof PHYSIOLOGY_WEIGHTS] * 2),
        trend: value > 70 ? 'up' : 'stable',
      });
    }
  });
  
  // Add lifestyle contributors
  Object.entries(lifestyleBreakdown).forEach(([name, value]) => {
    if (value > 60) {
      contributors.push({
        name,
        category: 'lifestyle',
        impact: Math.round((value - 50) * LIFESTYLE_WEIGHTS[name as keyof typeof LIFESTYLE_WEIGHTS] * 2),
        trend: value > 70 ? 'up' : 'stable',
      });
    }
  });
  
  return contributors.sort((a, b) => b.impact - a.impact).slice(0, 5);
}

// ==================== FULL CALCULATION ====================
export function calculateAnxietyScore(
  physio: PhysioData,
  lifestyle: LifestyleData,
  checkin: CheckinData,
  baseline: Baseline,
  isResting: boolean = true,
  isExercising: boolean = false,
  signalQuality: 'good' | 'poor' = 'good'
): AnxietyScore {
  const cs = calculateCheckinScore(checkin);
  const checkinWeight = calculateCheckinWeight(checkin.lastUpdated);
  
  const { score: lrs, breakdown: lifestyleBreakdown } = calculateLifestyleRiskScore(lifestyle);
  const { score: aps, breakdown: physioBreakdown } = calculatePhysiologyScore(physio, baseline, isExercising);
  
  const stateEstimate = calculateStateEstimate(aps, lrs, isResting, signalQuality);
  const finalScore = calculateFinalAnxietyScore(cs, stateEstimate, checkinWeight);
  
  const hoursSinceCheckin = (Date.now() - checkin.lastUpdated.getTime()) / (1000 * 60 * 60);
  const confidence = calculateConfidence(baseline, signalQuality, hoursSinceCheckin);
  
  const contributors = calculateTopContributors(physioBreakdown, lifestyleBreakdown);
  
  return {
    aps,
    lrs,
    cs,
    stateEstimate,
    finalScore,
    confidence,
    timestamp: new Date(),
    contributors,
  };
}

// ==================== BASELINE UPDATE (Exponential Moving Average) ====================
export function updateBaseline(
  currentBaseline: Baseline,
  newData: PhysioData,
  halfLifeDays: number = 14
): Baseline {
  const lambda = Math.log(2) / halfLifeDays;
  const alpha = 1 - Math.exp(-lambda);
  
  const updateStat = (current: { mean: number; sd: number }, newValue: number) => {
    const newMean = alpha * newValue + (1 - alpha) * current.mean;
    const newVariance = alpha * Math.pow(newValue - newMean, 2) + (1 - alpha) * Math.pow(current.sd, 2);
    return { mean: newMean, sd: Math.sqrt(newVariance) };
  };
  
  return {
    hr: updateStat(currentBaseline.hr, newData.hr),
    hrv: updateStat(currentBaseline.hrv, newData.hrv),
    rr: updateStat(currentBaseline.rr, newData.rr),
    eda: updateStat(currentBaseline.eda, newData.eda),
    temp: updateStat(currentBaseline.temp, newData.temp),
    lastUpdated: new Date(),
    isCalibrated: currentBaseline.calibrationDay >= 3,
    calibrationDay: currentBaseline.calibrationDay,
  };
}
