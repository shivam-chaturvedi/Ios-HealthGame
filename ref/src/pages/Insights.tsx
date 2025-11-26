import { useState } from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/layout/PageHeader';
import { GlassCard, GlassCardHeader } from '@/components/ui/GlassCard';
import { mockWeeklyInsight } from '@/data/mockData';
import { 
  BarChart3, 
  TrendingUp, 
  TrendingDown,
  Clock,
  Star,
  AlertCircle,
  Heart,
  Activity
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { format } from 'date-fns';
import { 
  Area, 
  AreaChart, 
  ResponsiveContainer, 
  XAxis, 
  YAxis, 
  Tooltip,
  Bar,
  BarChart,
  Cell
} from 'recharts';

export default function Insights() {
  const [insight] = useState(mockWeeklyInsight);

  const chartData = insight.scoreHistory.map((item) => ({
    date: format(item.date, 'EEE'),
    score: Math.round(item.score),
  }));

  const getScoreColor = (score: number) => {
    if (score <= 30) return '#10B981';
    if (score <= 50) return '#F59E0B';
    if (score <= 70) return '#F97316';
    return '#EF4444';
  };

  return (
    <AppLayout>
      <PageHeader 
        title="Weekly Insights" 
        subtitle={`${format(insight.weekStart, 'MMM d')} - ${format(insight.weekEnd, 'MMM d')}`}
        showBack
      />
      
      <div className="px-4 space-y-4">
        {/* Summary Card */}
        <GlassCard elevated className="animate-fade-up">
          <div className="flex items-center justify-between mb-6">
            <div>
              <p className="text-sm text-muted-foreground">Average Score</p>
              <p className="text-4xl font-bold" style={{ color: getScoreColor(insight.averageScore) }}>
                {Math.round(insight.averageScore)}
              </p>
            </div>
            <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center">
              <BarChart3 className="w-8 h-8 text-primary" />
            </div>
          </div>
          
          <div className="h-40">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorScore" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis 
                  dataKey="date" 
                  tick={{ fontSize: 10, fill: 'hsl(var(--muted-foreground))' }}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis 
                  domain={[0, 100]}
                  tick={{ fontSize: 10, fill: 'hsl(var(--muted-foreground))' }}
                  axisLine={false}
                  tickLine={false}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'hsl(var(--card))',
                    border: '1px solid hsl(var(--border))',
                    borderRadius: '0.75rem',
                    fontSize: '12px',
                  }}
                  formatter={(value: number) => [value, 'Anxiety Score']}
                />
                <Area
                  type="monotone"
                  dataKey="score"
                  stroke="hsl(var(--primary))"
                  strokeWidth={2}
                  fillOpacity={1}
                  fill="url(#colorScore)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </GlassCard>

        {/* Peak Times */}
        <GlassCard className="animate-fade-up stagger-1">
          <GlassCardHeader 
            title="Peak Anxiety Times" 
            icon={<Clock className="w-5 h-5" />}
          />
          <div className="flex flex-wrap gap-2">
            {insight.peakTimes.map((time, index) => (
              <div
                key={index}
                className="px-3 py-2 rounded-lg bg-destructive/10 text-destructive text-sm font-medium"
              >
                {time}
              </div>
            ))}
          </div>
          <p className="text-xs text-muted-foreground mt-3">
            These are times when your anxiety tends to be highest.
          </p>
        </GlassCard>

        {/* Top Lifestyle Contributors */}
        <GlassCard className="animate-fade-up stagger-2">
          <GlassCardHeader 
            title="Lifestyle Impact" 
            subtitle="What's affecting you most"
            icon={<AlertCircle className="w-5 h-5" />}
          />
          <div className="space-y-3">
            {insight.topLifestyleContributors.map((item, index) => (
              <div key={index} className="flex items-center gap-3">
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <p className="text-sm font-medium">{item.name}</p>
                    <span className="text-sm font-semibold text-destructive">+{item.impact}%</span>
                  </div>
                  <div className="h-2 bg-muted rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-destructive/60 rounded-full transition-all duration-500"
                      style={{ width: `${item.impact * 5}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </GlassCard>

        {/* Top Physio Contributors */}
        <GlassCard className="animate-fade-up stagger-3">
          <GlassCardHeader 
            title="Body Signals" 
            subtitle="Physiological patterns"
            icon={<Activity className="w-5 h-5" />}
          />
          <div className="space-y-3">
            {insight.topPhysioContributors.map((item, index) => (
              <div key={index} className="flex items-center gap-3">
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <p className="text-sm font-medium">{item.name}</p>
                    <span className="text-sm font-semibold text-warning">+{item.impact}%</span>
                  </div>
                  <div className="h-2 bg-muted rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-warning/60 rounded-full transition-all duration-500"
                      style={{ width: `${item.impact * 5}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </GlassCard>

        {/* Effective Interventions */}
        <GlassCard className="animate-fade-up stagger-4">
          <GlassCardHeader 
            title="Most Effective Exercises" 
            subtitle="Based on your feedback"
            icon={<Star className="w-5 h-5" />}
          />
          <div className="space-y-3">
            {insight.effectiveInterventions.map((item, index) => (
              <div
                key={index}
                className="flex items-center justify-between p-3 rounded-xl bg-success/10"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-success/20 flex items-center justify-center text-success font-bold">
                    {index + 1}
                  </div>
                  <p className="font-medium text-sm">{item.name}</p>
                </div>
                <div className="flex items-center gap-1 text-success">
                  <Star className="w-4 h-4 fill-current" />
                  <span className="font-semibold text-sm">{item.rating.toFixed(1)}</span>
                </div>
              </div>
            ))}
          </div>
        </GlassCard>

        {/* Recommendations */}
        <GlassCard elevated className="animate-fade-up stagger-5">
          <GlassCardHeader 
            title="Personalized Tips" 
            icon={<Heart className="w-5 h-5" />}
          />
          <div className="space-y-3">
            <div className="p-3 rounded-xl bg-muted/30">
              <p className="text-sm">
                <span className="font-semibold">Screen time tip:</span> Try putting your phone away 30 minutes earlier each night this week.
              </p>
            </div>
            <div className="p-3 rounded-xl bg-muted/30">
              <p className="text-sm">
                <span className="font-semibold">Sleep suggestion:</span> Aim for 7.5+ hours tonight. Your best days had 8+ hours of sleep.
              </p>
            </div>
            <div className="p-3 rounded-xl bg-muted/30">
              <p className="text-sm">
                <span className="font-semibold">Exercise:</span> Box breathing helped you most. Try it during your 3PM peak time.
              </p>
            </div>
          </div>
        </GlassCard>
      </div>
    </AppLayout>
  );
}
