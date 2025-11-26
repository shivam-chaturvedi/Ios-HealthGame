import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { GlassCard } from '@/components/ui/GlassCard';
import { 
  Heart, 
  Activity, 
  Brain,
  Shield,
  ChevronRight,
  Check,
  Sparkles
} from 'lucide-react';
import { cn } from '@/lib/utils';

type Step = 'welcome' | 'purpose' | 'calibration' | 'permissions' | 'concern' | 'complete';

export default function Onboarding() {
  const navigate = useNavigate();
  const [step, setStep] = useState<Step>('welcome');
  const [selectedConcern, setSelectedConcern] = useState<string | null>(null);
  const [permissions, setPermissions] = useState({
    health: false,
    motion: false,
    notifications: false,
  });

  const nextStep = () => {
    const steps: Step[] = ['welcome', 'purpose', 'calibration', 'permissions', 'concern', 'complete'];
    const currentIndex = steps.indexOf(step);
    if (currentIndex < steps.length - 1) {
      setStep(steps[currentIndex + 1]);
    }
  };

  const complete = () => {
    localStorage.setItem('onboarding_complete', 'true');
    navigate('/');
  };

  const renderStep = () => {
    switch (step) {
      case 'welcome':
        return (
          <div className="flex flex-col items-center text-center animate-fade-up">
            <div className="w-24 h-24 rounded-3xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center mb-8 animate-float">
              <Brain className="w-12 h-12 text-primary-foreground" />
            </div>
            <h1 className="text-3xl font-bold mb-3">Anxiety Calculator</h1>
            <p className="text-muted-foreground mb-8 max-w-xs">
              Your personal wellness companion for understanding and managing anxiety in real-time.
            </p>
            <button onClick={nextStep} className="ios-button-primary w-full max-w-xs">
              Get Started
            </button>
          </div>
        );

      case 'purpose':
        return (
          <div className="animate-fade-up">
            <h2 className="text-2xl font-bold mb-2 text-center">How It Works</h2>
            <p className="text-muted-foreground text-center mb-8">
              We combine multiple signals to understand your anxiety levels
            </p>
            
            <div className="space-y-4 mb-8">
              <GlassCard className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-red-500/10 flex items-center justify-center flex-shrink-0">
                  <Heart className="w-6 h-6 text-red-500" />
                </div>
                <div>
                  <p className="font-semibold">Physiological Tracking</p>
                  <p className="text-sm text-muted-foreground">
                    Heart rate, HRV, breathing, and more from your wearable
                  </p>
                </div>
              </GlassCard>
              
              <GlassCard className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-blue-500/10 flex items-center justify-center flex-shrink-0">
                  <Activity className="w-6 h-6 text-blue-500" />
                </div>
                <div>
                  <p className="font-semibold">Lifestyle Factors</p>
                  <p className="text-sm text-muted-foreground">
                    Sleep, caffeine, screen time, and daily habits
                  </p>
                </div>
              </GlassCard>
              
              <GlassCard className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center flex-shrink-0">
                  <Brain className="w-6 h-6 text-purple-500" />
                </div>
                <div>
                  <p className="font-semibold">Quick Check-ins</p>
                  <p className="text-sm text-muted-foreground">
                    Brief questionnaires to anchor your score
                  </p>
                </div>
              </GlassCard>
            </div>
            
            <button onClick={nextStep} className="ios-button-primary w-full">
              Continue
            </button>
          </div>
        );

      case 'calibration':
        return (
          <div className="animate-fade-up">
            <div className="w-20 h-20 rounded-2xl bg-primary/10 flex items-center justify-center mx-auto mb-6">
              <Sparkles className="w-10 h-10 text-primary" />
            </div>
            <h2 className="text-2xl font-bold mb-2 text-center">Calibration Phase</h2>
            <p className="text-muted-foreground text-center mb-8">
              For the first 3 days, we'll learn your unique patterns
            </p>
            
            <GlassCard className="mb-8">
              <div className="space-y-4">
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check className="w-4 h-4 text-primary" />
                  </div>
                  <p className="text-sm">Passively collect baseline data</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check className="w-4 h-4 text-primary" />
                  </div>
                  <p className="text-sm">Identify your rest patterns</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check className="w-4 h-4 text-primary" />
                  </div>
                  <p className="text-sm">Create personalized baselines</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check className="w-4 h-4 text-primary" />
                  </div>
                  <p className="text-sm">No alerts during this period</p>
                </div>
              </div>
            </GlassCard>
            
            <button onClick={nextStep} className="ios-button-primary w-full">
              I Understand
            </button>
          </div>
        );

      case 'permissions':
        return (
          <div className="animate-fade-up">
            <div className="w-20 h-20 rounded-2xl bg-green-500/10 flex items-center justify-center mx-auto mb-6">
              <Shield className="w-10 h-10 text-green-500" />
            </div>
            <h2 className="text-2xl font-bold mb-2 text-center">Permissions</h2>
            <p className="text-muted-foreground text-center mb-8">
              We need a few permissions to help you best
            </p>
            
            <div className="space-y-3 mb-8">
              {[
                { key: 'health', label: 'Health Data', desc: 'Access heart rate, HRV from your watch' },
                { key: 'motion', label: 'Motion & Fitness', desc: 'Track steps and activity levels' },
                { key: 'notifications', label: 'Notifications', desc: 'Send timely interventions' },
              ].map((perm) => (
                <GlassCard
                  key={perm.key}
                  className={cn(
                    'cursor-pointer transition-all',
                    permissions[perm.key as keyof typeof permissions] && 'ring-2 ring-primary'
                  )}
                  onClick={() => setPermissions(prev => ({ ...prev, [perm.key]: !prev[perm.key as keyof typeof permissions] }))}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-semibold text-sm">{perm.label}</p>
                      <p className="text-xs text-muted-foreground">{perm.desc}</p>
                    </div>
                    <div className={cn(
                      'w-6 h-6 rounded-full flex items-center justify-center transition-colors',
                      permissions[perm.key as keyof typeof permissions]
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-muted'
                    )}>
                      {permissions[perm.key as keyof typeof permissions] && <Check className="w-4 h-4" />}
                    </div>
                  </div>
                </GlassCard>
              ))}
            </div>
            
            <button onClick={nextStep} className="ios-button-primary w-full">
              Continue
            </button>
            <button onClick={nextStep} className="w-full text-sm text-muted-foreground mt-3 py-2">
              Skip for now
            </button>
          </div>
        );

      case 'concern':
        return (
          <div className="animate-fade-up">
            <h2 className="text-2xl font-bold mb-2 text-center">Primary Concern</h2>
            <p className="text-muted-foreground text-center mb-8">
              What brings you here today?
            </p>
            
            <div className="space-y-3 mb-8">
              {[
                { key: 'anxiety', label: 'General Anxiety', desc: 'Persistent worry and nervousness' },
                { key: 'stress', label: 'Stress', desc: 'Overwhelm from work or life demands' },
                { key: 'panic', label: 'Panic', desc: 'Sudden episodes of intense fear' },
              ].map((concern) => (
                <GlassCard
                  key={concern.key}
                  className={cn(
                    'cursor-pointer transition-all',
                    selectedConcern === concern.key && 'ring-2 ring-primary'
                  )}
                  onClick={() => setSelectedConcern(concern.key)}
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-semibold text-sm">{concern.label}</p>
                      <p className="text-xs text-muted-foreground">{concern.desc}</p>
                    </div>
                    <div className={cn(
                      'w-6 h-6 rounded-full flex items-center justify-center transition-colors',
                      selectedConcern === concern.key
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-muted'
                    )}>
                      {selectedConcern === concern.key && <Check className="w-4 h-4" />}
                    </div>
                  </div>
                </GlassCard>
              ))}
            </div>
            
            <button 
              onClick={nextStep} 
              className={cn(
                'ios-button-primary w-full',
                !selectedConcern && 'opacity-50'
              )}
              disabled={!selectedConcern}
            >
              Continue
            </button>
          </div>
        );

      case 'complete':
        return (
          <div className="flex flex-col items-center text-center animate-fade-up">
            <div className="w-24 h-24 rounded-full bg-success/20 flex items-center justify-center mb-8">
              <Check className="w-12 h-12 text-success" />
            </div>
            <h2 className="text-2xl font-bold mb-3">You're All Set!</h2>
            <p className="text-muted-foreground mb-8 max-w-xs">
              Your 3-day calibration starts now. We'll notify you when your personalized baselines are ready.
            </p>
            <button onClick={complete} className="ios-button-primary w-full max-w-xs">
              Start Tracking
            </button>
          </div>
        );
    }
  };

  const getProgress = () => {
    const steps: Step[] = ['welcome', 'purpose', 'calibration', 'permissions', 'concern', 'complete'];
    return ((steps.indexOf(step) + 1) / steps.length) * 100;
  };

  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Progress Bar */}
      {step !== 'welcome' && (
        <div className="fixed top-0 left-0 right-0 h-1 bg-muted z-50">
          <div 
            className="h-full bg-primary transition-all duration-300"
            style={{ width: `${getProgress()}%` }}
          />
        </div>
      )}
      
      <div className="flex-1 flex items-center justify-center p-6">
        <div className="w-full max-w-sm">
          {renderStep()}
        </div>
      </div>
    </div>
  );
}
