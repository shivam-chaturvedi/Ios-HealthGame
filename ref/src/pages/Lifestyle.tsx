import { useState } from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/layout/PageHeader';
import { GlassCard, GlassCardHeader } from '@/components/ui/GlassCard';
import { mockLifestyleData } from '@/data/mockData';
import { 
  Moon, 
  Coffee, 
  Footprints, 
  Calendar,
  Sparkles,
  Heart,
  Monitor,
  Utensils,
  ChevronRight,
  Clock,
  Plus,
  Minus
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { LIFESTYLE_WEIGHTS } from '@/types/anxiety';

type LifestyleCategory = 'sleep' | 'stimulants' | 'activity' | 'context' | 'selfCare' | 'menstrual' | 'screen' | 'diet';

interface CategoryCardProps {
  icon: React.ElementType;
  label: string;
  description: string;
  weight: number;
  color: string;
  isSelected: boolean;
  onClick: () => void;
}

function CategoryCard({ icon: Icon, label, description, weight, color, isSelected, onClick }: CategoryCardProps) {
  return (
    <GlassCard 
      className={cn(
        'cursor-pointer transition-all duration-200',
        isSelected && 'ring-2 ring-primary'
      )}
      onClick={onClick}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center', color)}>
            <Icon className="w-5 h-5" />
          </div>
          <div>
            <p className="font-semibold text-sm">{label}</p>
            <p className="text-xs text-muted-foreground">{description}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs text-muted-foreground">{(weight * 100).toFixed(0)}%</span>
          <ChevronRight className="w-4 h-4 text-muted-foreground" />
        </div>
      </div>
    </GlassCard>
  );
}

export default function Lifestyle() {
  const [lifestyle, setLifestyle] = useState(mockLifestyleData);
  const [selectedCategory, setSelectedCategory] = useState<LifestyleCategory | null>(null);

  const categories: { key: LifestyleCategory; icon: React.ElementType; label: string; description: string; color: string }[] = [
    { key: 'sleep', icon: Moon, label: 'Sleep', description: `${lifestyle.sleep.duration}h · ${lifestyle.sleep.debt}h debt`, color: 'bg-indigo-500/10 text-indigo-500' },
    { key: 'stimulants', icon: Coffee, label: 'Stimulants', description: `${lifestyle.stimulants.caffeineAfter2pm}mg caffeine`, color: 'bg-amber-500/10 text-amber-500' },
    { key: 'activity', icon: Footprints, label: 'Activity', description: `${lifestyle.activity.steps} steps · ${lifestyle.activity.workoutMinutes}min`, color: 'bg-green-500/10 text-green-500' },
    { key: 'context', icon: Calendar, label: 'Context', description: lifestyle.context.hasDeadline ? 'Deadline today' : 'No major events', color: 'bg-red-500/10 text-red-500' },
    { key: 'selfCare', icon: Sparkles, label: 'Self-Care', description: `${lifestyle.selfCare.meditationMinutes + lifestyle.selfCare.breathingMinutes}min today`, color: 'bg-pink-500/10 text-pink-500' },
    { key: 'menstrual', icon: Heart, label: 'Cycle', description: lifestyle.menstrual.phase === 'none' ? 'Not tracking' : `${lifestyle.menstrual.phase} phase`, color: 'bg-rose-500/10 text-rose-500' },
    { key: 'screen', icon: Monitor, label: 'Screen Time', description: `${lifestyle.screen.totalDaytimeHours}h today`, color: 'bg-blue-500/10 text-blue-500' },
    { key: 'diet', icon: Utensils, label: 'Diet & Hydration', description: `${lifestyle.diet.waterGlasses} glasses water`, color: 'bg-cyan-500/10 text-cyan-500' },
  ];

  const renderCategoryDetail = () => {
    if (!selectedCategory) return null;

    switch (selectedCategory) {
      case 'sleep':
        return (
          <GlassCard elevated className="animate-scale-up">
            <GlassCardHeader title="Sleep Tracking" icon={<Moon className="w-5 h-5" />} />
            
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div className="p-3 rounded-xl bg-muted/30">
                  <p className="text-xs text-muted-foreground mb-1">Sleep Time</p>
                  <p className="text-lg font-semibold">{lifestyle.sleep.sleepTime}</p>
                </div>
                <div className="p-3 rounded-xl bg-muted/30">
                  <p className="text-xs text-muted-foreground mb-1">Wake Time</p>
                  <p className="text-lg font-semibold">{lifestyle.sleep.wakeTime}</p>
                </div>
              </div>
              
              <div className="p-3 rounded-xl bg-muted/30">
                <div className="flex justify-between mb-2">
                  <p className="text-sm font-medium">Sleep Efficiency</p>
                  <p className="text-sm font-semibold">{lifestyle.sleep.efficiency}%</p>
                </div>
                <div className="h-2 bg-muted rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-primary rounded-full"
                    style={{ width: `${lifestyle.sleep.efficiency}%` }}
                  />
                </div>
              </div>
              
              <div className="flex items-center justify-between p-3 rounded-xl bg-destructive/10">
                <div>
                  <p className="text-sm font-medium text-destructive">Sleep Debt</p>
                  <p className="text-xs text-muted-foreground">Accumulative deficit</p>
                </div>
                <p className="text-2xl font-bold text-destructive">{lifestyle.sleep.debt}h</p>
              </div>
            </div>
          </GlassCard>
        );

      case 'stimulants':
        return (
          <GlassCard elevated className="animate-scale-up">
            <GlassCardHeader title="Stimulants" icon={<Coffee className="w-5 h-5" />} />
            
            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-muted/30">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-sm font-medium">Caffeine after 2PM</p>
                  <div className="flex items-center gap-2">
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        stimulants: { ...prev.stimulants, caffeineAfter2pm: Math.max(0, prev.stimulants.caffeineAfter2pm - 50) }
                      }))}
                    >
                      <Minus className="w-4 h-4" />
                    </button>
                    <span className="w-16 text-center font-semibold">{lifestyle.stimulants.caffeineAfter2pm}mg</span>
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        stimulants: { ...prev.stimulants, caffeineAfter2pm: prev.stimulants.caffeineAfter2pm + 50 }
                      }))}
                    >
                      <Plus className="w-4 h-4" />
                    </button>
                  </div>
                </div>
                <p className="text-xs text-muted-foreground">~1 cup coffee = 100mg</p>
              </div>
              
              <div className="flex items-center justify-between p-4 rounded-xl bg-muted/30">
                <p className="text-sm font-medium">Nicotine today</p>
                <button 
                  className={cn(
                    'px-4 py-2 rounded-lg text-sm font-medium transition-all',
                    lifestyle.stimulants.nicotine 
                      ? 'bg-destructive text-destructive-foreground' 
                      : 'bg-muted text-muted-foreground'
                  )}
                  onClick={() => setLifestyle(prev => ({
                    ...prev,
                    stimulants: { ...prev.stimulants, nicotine: !prev.stimulants.nicotine }
                  }))}
                >
                  {lifestyle.stimulants.nicotine ? 'Yes' : 'No'}
                </button>
              </div>
              
              <div className="p-4 rounded-xl bg-muted/30">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-sm font-medium">Alcohol after 8PM</p>
                  <div className="flex items-center gap-2">
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        stimulants: { ...prev.stimulants, alcoholAfter8pm: Math.max(0, prev.stimulants.alcoholAfter8pm - 1) }
                      }))}
                    >
                      <Minus className="w-4 h-4" />
                    </button>
                    <span className="w-12 text-center font-semibold">{lifestyle.stimulants.alcoholAfter8pm}</span>
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        stimulants: { ...prev.stimulants, alcoholAfter8pm: prev.stimulants.alcoholAfter8pm + 1 }
                      }))}
                    >
                      <Plus className="w-4 h-4" />
                    </button>
                  </div>
                </div>
                <p className="text-xs text-muted-foreground">Units</p>
              </div>
            </div>
          </GlassCard>
        );

      case 'diet':
        return (
          <GlassCard elevated className="animate-scale-up">
            <GlassCardHeader title="Diet & Hydration" icon={<Utensils className="w-5 h-5" />} />
            
            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-muted/30">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-sm font-medium">Water Intake</p>
                  <div className="flex items-center gap-2">
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        diet: { ...prev.diet, waterGlasses: Math.max(0, prev.diet.waterGlasses - 1) }
                      }))}
                    >
                      <Minus className="w-4 h-4" />
                    </button>
                    <span className="w-12 text-center font-semibold">{lifestyle.diet.waterGlasses}</span>
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        diet: { ...prev.diet, waterGlasses: prev.diet.waterGlasses + 1 }
                      }))}
                    >
                      <Plus className="w-4 h-4" />
                    </button>
                  </div>
                </div>
                <p className="text-xs text-muted-foreground">Glasses (250ml each)</p>
              </div>
              
              <div className="p-4 rounded-xl bg-muted/30">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-sm font-medium">Meals Skipped</p>
                  <div className="flex items-center gap-2">
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        diet: { ...prev.diet, mealsSkipped: Math.max(0, prev.diet.mealsSkipped - 1) }
                      }))}
                    >
                      <Minus className="w-4 h-4" />
                    </button>
                    <span className="w-12 text-center font-semibold">{lifestyle.diet.mealsSkipped}</span>
                    <button 
                      className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center"
                      onClick={() => setLifestyle(prev => ({
                        ...prev,
                        diet: { ...prev.diet, mealsSkipped: Math.min(3, prev.diet.mealsSkipped + 1) }
                      }))}
                    >
                      <Plus className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
              
              <div className="flex items-center justify-between p-4 rounded-xl bg-muted/30">
                <p className="text-sm font-medium">Sugary foods today</p>
                <button 
                  className={cn(
                    'px-4 py-2 rounded-lg text-sm font-medium transition-all',
                    lifestyle.diet.sugaryFoods 
                      ? 'bg-warning text-warning-foreground' 
                      : 'bg-muted text-muted-foreground'
                  )}
                  onClick={() => setLifestyle(prev => ({
                    ...prev,
                    diet: { ...prev.diet, sugaryFoods: !prev.diet.sugaryFoods }
                  }))}
                >
                  {lifestyle.diet.sugaryFoods ? 'Yes' : 'No'}
                </button>
              </div>
            </div>
          </GlassCard>
        );

      default:
        return (
          <GlassCard elevated className="animate-scale-up">
            <div className="text-center py-8">
              <p className="text-muted-foreground">Detail view for {selectedCategory}</p>
              <p className="text-sm text-muted-foreground mt-2">Coming soon</p>
            </div>
          </GlassCard>
        );
    }
  };

  return (
    <AppLayout>
      <PageHeader 
        title="Lifestyle" 
        subtitle="Track daily habits"
      />
      
      <div className="px-4 space-y-4">
        {/* Category Cards */}
        <div className="space-y-3">
          {categories.map((cat, index) => (
            <div key={cat.key} className={`animate-fade-up stagger-${Math.min(index + 1, 5)}`}>
              <CategoryCard
                icon={cat.icon}
                label={cat.label}
                description={cat.description}
                weight={LIFESTYLE_WEIGHTS[cat.key]}
                color={cat.color}
                isSelected={selectedCategory === cat.key}
                onClick={() => setSelectedCategory(selectedCategory === cat.key ? null : cat.key)}
              />
            </div>
          ))}
        </div>

        {/* Selected Category Detail */}
        {selectedCategory && renderCategoryDetail()}
      </div>
    </AppLayout>
  );
}
