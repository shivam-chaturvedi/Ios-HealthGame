import { useState } from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/layout/PageHeader';
import { GlassCard, GlassCardHeader } from '@/components/ui/GlassCard';
import { mockInterventions, mockAnxietyScore } from '@/data/mockData';
import { AnxietyScoreRing } from '@/components/ui/AnxietyScoreRing';
import { 
  Wind, 
  Square, 
  Hand, 
  Footprints, 
  PenLine, 
  Music,
  Play,
  Star,
  Clock,
  ChevronRight,
  X,
  Pause
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { Intervention } from '@/types/anxiety';

const iconMap: Record<string, React.ElementType> = {
  Wind,
  Square,
  Hand,
  Footprints,
  PenLine,
  Music,
};

export default function Interventions() {
  const [score] = useState(mockAnxietyScore);
  const [interventions] = useState(mockInterventions);
  const [activeIntervention, setActiveIntervention] = useState<Intervention | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [breathPhase, setBreathPhase] = useState<'inhale' | 'hold' | 'exhale'>('inhale');
  const [timer, setTimer] = useState(0);

  const startIntervention = (intervention: Intervention) => {
    setActiveIntervention(intervention);
    setIsPlaying(true);
    setTimer(intervention.duration * 60);
    
    if (intervention.type === 'breathing') {
      // Start breath cycle
      const cycle = () => {
        setBreathPhase('inhale');
        setTimeout(() => setBreathPhase('hold'), 4000);
        setTimeout(() => setBreathPhase('exhale'), 11000);
      };
      cycle();
      const interval = setInterval(cycle, 19000);
      return () => clearInterval(interval);
    }
  };

  const stopIntervention = () => {
    setActiveIntervention(null);
    setIsPlaying(false);
    setBreathPhase('inhale');
    setTimer(0);
  };

  const getRecommendation = () => {
    if (score.finalScore >= 70) {
      return 'Your anxiety is high. Try a calming exercise now.';
    } else if (score.finalScore >= 50) {
      return 'Moderate anxiety detected. A quick intervention could help.';
    }
    return 'You\'re doing well! These exercises help maintain calm.';
  };

  const getTopContributor = () => {
    if (score.contributors.length === 0) return null;
    return score.contributors[0];
  };

  const topContributor = getTopContributor();

  return (
    <AppLayout>
      <PageHeader 
        title="Interventions" 
        subtitle="Calm your nervous system"
      />
      
      <div className="px-4 space-y-4">
        {/* Current State Card */}
        <GlassCard elevated className="animate-fade-up">
          <div className="flex items-center gap-4">
            <AnxietyScoreRing score={score.finalScore} size="md" showLabel={false} />
            <div className="flex-1">
              <p className="text-sm font-medium mb-1">{getRecommendation()}</p>
              {topContributor && (
                <p className="text-xs text-muted-foreground">
                  Main factor: <span className="capitalize">{topContributor.name}</span>
                </p>
              )}
            </div>
          </div>
        </GlassCard>

        {/* Active Intervention Modal */}
        {activeIntervention && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-background/80 backdrop-blur-xl animate-fade-in">
            <GlassCard elevated className="w-full max-w-sm text-center animate-scale-up">
              <button
                onClick={stopIntervention}
                className="absolute top-4 right-4 w-10 h-10 rounded-full bg-muted/50 flex items-center justify-center"
              >
                <X className="w-5 h-5" />
              </button>
              
              <div className="py-8">
                <h2 className="text-xl font-bold mb-2">{activeIntervention.name}</h2>
                <p className="text-sm text-muted-foreground mb-8">
                  {activeIntervention.description}
                </p>
                
                {activeIntervention.type === 'breathing' && (
                  <div className="mb-8">
                    <div className={cn(
                      'w-32 h-32 mx-auto rounded-full flex items-center justify-center transition-all duration-[4000ms]',
                      breathPhase === 'inhale' && 'scale-125 bg-primary/20',
                      breathPhase === 'hold' && 'scale-125 bg-primary/30',
                      breathPhase === 'exhale' && 'scale-100 bg-primary/10'
                    )}>
                      <div className={cn(
                        'w-24 h-24 rounded-full flex items-center justify-center transition-all duration-[4000ms]',
                        breathPhase === 'inhale' && 'scale-110 bg-primary/30',
                        breathPhase === 'hold' && 'scale-110 bg-primary/40',
                        breathPhase === 'exhale' && 'scale-100 bg-primary/20'
                      )}>
                        <span className="text-lg font-semibold text-primary capitalize">
                          {breathPhase}
                        </span>
                      </div>
                    </div>
                    
                    <p className="text-sm text-muted-foreground mt-4">
                      {breathPhase === 'inhale' && 'Breathe in slowly...'}
                      {breathPhase === 'hold' && 'Hold your breath...'}
                      {breathPhase === 'exhale' && 'Breathe out slowly...'}
                    </p>
                  </div>
                )}
                
                {activeIntervention.type === 'grounding' && (
                  <div className="mb-8 space-y-4">
                    <div className="p-4 rounded-xl bg-muted/30">
                      <p className="text-lg font-medium mb-2">5 things you see</p>
                      <p className="text-sm text-muted-foreground">Look around and notice 5 things</p>
                    </div>
                    <div className="p-4 rounded-xl bg-muted/30">
                      <p className="text-lg font-medium mb-2">4 things you hear</p>
                      <p className="text-sm text-muted-foreground">Listen for 4 different sounds</p>
                    </div>
                    <div className="p-4 rounded-xl bg-muted/30">
                      <p className="text-lg font-medium mb-2">3 things you touch</p>
                      <p className="text-sm text-muted-foreground">Feel 3 textures nearby</p>
                    </div>
                  </div>
                )}
                
                <div className="flex items-center justify-center gap-4">
                  <button
                    onClick={() => setIsPlaying(!isPlaying)}
                    className="w-16 h-16 rounded-full bg-primary flex items-center justify-center text-primary-foreground"
                  >
                    {isPlaying ? <Pause className="w-8 h-8" /> : <Play className="w-8 h-8 ml-1" />}
                  </button>
                </div>
                
                <p className="text-sm text-muted-foreground mt-4">
                  {Math.floor(timer / 60)}:{(timer % 60).toString().padStart(2, '0')} remaining
                </p>
              </div>
            </GlassCard>
          </div>
        )}

        {/* Quick Actions */}
        <div className="animate-fade-up stagger-1">
          <p className="section-header">Quick Relief</p>
          <div className="grid grid-cols-2 gap-3">
            {interventions.slice(0, 2).map((intervention) => {
              const Icon = iconMap[intervention.icon] || Wind;
              return (
                <GlassCard
                  key={intervention.id}
                  className="cursor-pointer"
                  onClick={() => startIntervention(intervention)}
                >
                  <div className="flex flex-col items-center text-center py-2">
                    <div className="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center mb-3">
                      <Icon className="w-6 h-6 text-primary" />
                    </div>
                    <p className="font-semibold text-sm">{intervention.name}</p>
                    <p className="text-xs text-muted-foreground mt-1">
                      {intervention.duration} min
                    </p>
                  </div>
                </GlassCard>
              );
            })}
          </div>
        </div>

        {/* All Interventions */}
        <div className="animate-fade-up stagger-2">
          <p className="section-header">All Exercises</p>
          <div className="space-y-3">
            {interventions.map((intervention) => {
              const Icon = iconMap[intervention.icon] || Wind;
              return (
                <GlassCard
                  key={intervention.id}
                  className="cursor-pointer"
                  onClick={() => startIntervention(intervention)}
                >
                  <div className="flex items-center gap-4">
                    <div className={cn(
                      'w-12 h-12 rounded-xl flex items-center justify-center',
                      intervention.type === 'breathing' && 'bg-blue-500/10 text-blue-500',
                      intervention.type === 'grounding' && 'bg-green-500/10 text-green-500',
                      intervention.type === 'walk' && 'bg-amber-500/10 text-amber-500',
                      intervention.type === 'journal' && 'bg-purple-500/10 text-purple-500',
                      intervention.type === 'music' && 'bg-pink-500/10 text-pink-500'
                    )}>
                      <Icon className="w-6 h-6" />
                    </div>
                    
                    <div className="flex-1">
                      <p className="font-semibold text-sm">{intervention.name}</p>
                      <p className="text-xs text-muted-foreground line-clamp-1">
                        {intervention.description}
                      </p>
                    </div>
                    
                    <div className="flex items-center gap-3">
                      <div className="flex items-center gap-1 text-xs text-muted-foreground">
                        <Clock className="w-3 h-3" />
                        <span>{intervention.duration}m</span>
                      </div>
                      {intervention.effectiveness && (
                        <div className="flex items-center gap-1 text-xs text-warning">
                          <Star className="w-3 h-3 fill-current" />
                          <span>{intervention.effectiveness.toFixed(1)}</span>
                        </div>
                      )}
                      <ChevronRight className="w-4 h-4 text-muted-foreground" />
                    </div>
                  </div>
                </GlassCard>
              );
            })}
          </div>
        </div>

        {/* Tip Card */}
        <GlassCard className="animate-fade-up stagger-3">
          <div className="flex gap-3">
            <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center flex-shrink-0">
              <Star className="w-5 h-5 text-primary" />
            </div>
            <div>
              <p className="font-semibold text-sm mb-1">Pro Tip</p>
              <p className="text-xs text-muted-foreground">
                Regular practice of breathing exercises can reduce baseline anxiety by up to 40% over time.
              </p>
            </div>
          </div>
        </GlassCard>
      </div>
    </AppLayout>
  );
}
