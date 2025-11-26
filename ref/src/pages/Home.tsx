import { useState } from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/layout/PageHeader';
import { GlassCard, GlassCardHeader } from '@/components/ui/GlassCard';
import { AnxietyScoreRing } from '@/components/ui/AnxietyScoreRing';
import { ConfidenceBadge } from '@/components/ui/ConfidenceBadge';
import { MiniChart } from '@/components/ui/MiniChart';
import { mockAnxietyScore, mockTrendData } from '@/data/mockData';
import { 
  TrendingUp, 
  TrendingDown, 
  Minus, 
  AlertCircle,
  Sparkles,
  Moon,
  Coffee,
  Monitor,
  Calendar,
  BarChart3,
  ChevronRight
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useNavigate } from 'react-router-dom';

const contributorIcons: Record<string, React.ElementType> = {
  sleep: Moon,
  stimulants: Coffee,
  screen: Monitor,
  context: Calendar,
  HR: TrendingUp,
  HRV: TrendingDown,
};

export default function Home() {
  const navigate = useNavigate();
  const [score] = useState(mockAnxietyScore);
  const [trendData] = useState(mockTrendData);

  const getTrendIcon = (trend: 'up' | 'down' | 'stable') => {
    switch (trend) {
      case 'up': return TrendingUp;
      case 'down': return TrendingDown;
      default: return Minus;
    }
  };

  return (
    <AppLayout>
      <PageHeader 
        title="Anxiety Calculator" 
        subtitle="Your real-time wellness score"
        showSettings
      />
      
      <div className="px-4 space-y-4 animate-fade-up">
        {/* Main Score Card */}
        <GlassCard elevated className="text-center py-8">
          <div className="flex flex-col items-center">
            <ConfidenceBadge confidence={score.confidence} />
            
            <div className="my-6">
              <AnxietyScoreRing score={score.finalScore} size="xl" />
            </div>
            
            <p className="text-muted-foreground text-sm mb-4">
              Last updated: Just now
            </p>
            
            {/* Trend Mini Chart */}
            <div className="w-full px-4">
              <p className="text-xs text-muted-foreground mb-2 text-left">Last 12 hours</p>
              <MiniChart data={trendData} height={50} currentScore={score.finalScore} />
            </div>
          </div>
        </GlassCard>

        {/* Panic Button */}
        <button 
          onClick={() => navigate('/interventions')}
          className="w-full ios-button-primary flex items-center justify-center gap-2 py-4 animate-fade-up stagger-1"
        >
          <Sparkles className="w-5 h-5" />
          <span>Need Help Now?</span>
        </button>

        {/* Top Contributors */}
        <GlassCard className="animate-fade-up stagger-2">
          <GlassCardHeader 
            title="Top Contributors Today"
            icon={<AlertCircle className="w-5 h-5" />}
          />
          
          <div className="space-y-3">
            {score.contributors.slice(0, 4).map((contributor, index) => {
              const Icon = contributorIcons[contributor.name] || AlertCircle;
              const TrendIcon = getTrendIcon(contributor.trend);
              
              return (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 rounded-xl bg-muted/30 hover:bg-muted/50 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className={cn(
                      'w-9 h-9 rounded-lg flex items-center justify-center',
                      contributor.category === 'physiology' 
                        ? 'bg-primary/10 text-primary' 
                        : 'bg-secondary/10 text-secondary'
                    )}>
                      <Icon className="w-4 h-4" />
                    </div>
                    <div>
                      <p className="font-medium text-sm capitalize">{contributor.name}</p>
                      <p className="text-xs text-muted-foreground capitalize">
                        {contributor.category}
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <span className={cn(
                      'text-sm font-semibold',
                      contributor.impact > 10 ? 'text-destructive' : 'text-warning'
                    )}>
                      +{contributor.impact}%
                    </span>
                    <TrendIcon className={cn(
                      'w-4 h-4',
                      contributor.trend === 'up' ? 'text-destructive' : 
                      contributor.trend === 'down' ? 'text-success' : 'text-muted-foreground'
                    )} />
                  </div>
                </div>
              );
            })}
          </div>
        </GlassCard>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-3 animate-fade-up stagger-3">
          <GlassCard 
            className="cursor-pointer hover:scale-[1.02] active:scale-[0.98] transition-transform"
            onClick={() => navigate('/insights')}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                  <BarChart3 className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <p className="font-semibold text-sm">Insights</p>
                  <p className="text-xs text-muted-foreground">Weekly report</p>
                </div>
              </div>
              <ChevronRight className="w-4 h-4 text-muted-foreground" />
            </div>
          </GlassCard>
          
          <GlassCard 
            className="cursor-pointer hover:scale-[1.02] active:scale-[0.98] transition-transform"
            onClick={() => navigate('/checkin')}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-secondary/10 flex items-center justify-center">
                  <AlertCircle className="w-5 h-5 text-secondary" />
                </div>
                <div>
                  <p className="font-semibold text-sm">Check-in</p>
                  <p className="text-xs text-muted-foreground">Quick update</p>
                </div>
              </div>
              <ChevronRight className="w-4 h-4 text-muted-foreground" />
            </div>
          </GlassCard>
        </div>

        {/* Score Breakdown */}
        <GlassCard className="animate-fade-up stagger-4">
          <GlassCardHeader title="Score Breakdown" />
          
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <div className="text-2xl font-bold text-primary">{Math.round(score.aps)}</div>
              <p className="text-xs text-muted-foreground mt-1">Physiology</p>
            </div>
            <div>
              <div className="text-2xl font-bold text-secondary">{Math.round(score.lrs)}</div>
              <p className="text-xs text-muted-foreground mt-1">Lifestyle</p>
            </div>
            <div>
              <div className="text-2xl font-bold text-warning">{Math.round(score.cs)}</div>
              <p className="text-xs text-muted-foreground mt-1">Check-in</p>
            </div>
          </div>
        </GlassCard>
      </div>
    </AppLayout>
  );
}
