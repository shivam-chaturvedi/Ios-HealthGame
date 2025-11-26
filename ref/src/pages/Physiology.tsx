import { useState } from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/layout/PageHeader';
import { GlassCard, GlassCardHeader } from '@/components/ui/GlassCard';
import { mockPhysioData, mockBaseline, mockPhysioHistory } from '@/data/mockData';
import { 
  Heart, 
  Activity, 
  Wind, 
  Droplets, 
  Thermometer, 
  Move,
  Circle,
  TrendingUp,
  TrendingDown,
  Minus
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { Area, AreaChart, ResponsiveContainer, XAxis, YAxis, Tooltip } from 'recharts';

interface SignalCardProps {
  icon: React.ElementType;
  label: string;
  value: string;
  unit: string;
  baseline: string;
  trend: 'up' | 'down' | 'stable';
  status: 'normal' | 'elevated' | 'low';
  color: string;
}

function SignalCard({ icon: Icon, label, value, unit, baseline, trend, status, color }: SignalCardProps) {
  const TrendIcon = trend === 'up' ? TrendingUp : trend === 'down' ? TrendingDown : Minus;
  
  const statusColors = {
    normal: 'text-success',
    elevated: 'text-warning',
    low: 'text-primary',
  };

  return (
    <GlassCard className="animate-fade-up">
      <div className="flex items-start justify-between mb-3">
        <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center', color)}>
          <Icon className="w-5 h-5" />
        </div>
        <div className="flex items-center gap-1">
          <Circle className={cn('w-2 h-2 fill-current', statusColors[status])} />
          <span className={cn('text-xs font-medium capitalize', statusColors[status])}>
            {status}
          </span>
        </div>
      </div>
      
      <div className="mb-2">
        <span className="text-2xl font-bold">{value}</span>
        <span className="text-sm text-muted-foreground ml-1">{unit}</span>
      </div>
      
      <p className="text-sm font-medium text-foreground mb-1">{label}</p>
      
      <div className="flex items-center justify-between text-xs text-muted-foreground">
        <span>Baseline: {baseline}</span>
        <TrendIcon className={cn(
          'w-3.5 h-3.5',
          trend === 'up' ? 'text-destructive' :
          trend === 'down' ? 'text-success' : 'text-muted-foreground'
        )} />
      </div>
    </GlassCard>
  );
}

export default function Physiology() {
  const [physio] = useState(mockPhysioData);
  const [baseline] = useState(mockBaseline);
  const [history] = useState(mockPhysioHistory);
  const [selectedSignal, setSelectedSignal] = useState<'hr' | 'hrv' | 'rr' | 'eda'>('hr');

  const signalColors = {
    hr: '#EF4444',
    hrv: '#10B981',
    rr: '#3B82F6',
    eda: '#F59E0B',
  };

  const getStatus = (current: number, mean: number, sd: number, inverse = false): 'normal' | 'elevated' | 'low' => {
    const z = (current - mean) / sd;
    if (inverse) {
      if (z < -1.5) return 'elevated';
      if (z > 1.5) return 'low';
    } else {
      if (z > 1.5) return 'elevated';
      if (z < -1.5) return 'low';
    }
    return 'normal';
  };

  const getTrend = (current: number, mean: number): 'up' | 'down' | 'stable' => {
    const diff = current - mean;
    if (diff > mean * 0.1) return 'up';
    if (diff < -mean * 0.1) return 'down';
    return 'stable';
  };

  const signals: SignalCardProps[] = [
    {
      icon: Heart,
      label: 'Heart Rate',
      value: physio.hr.toFixed(0),
      unit: 'BPM',
      baseline: `${baseline.hr.mean.toFixed(0)} ± ${baseline.hr.sd.toFixed(0)}`,
      trend: getTrend(physio.hr, baseline.hr.mean),
      status: getStatus(physio.hr, baseline.hr.mean, baseline.hr.sd),
      color: 'bg-red-500/10 text-red-500',
    },
    {
      icon: Activity,
      label: 'Heart Rate Variability',
      value: physio.hrv.toFixed(0),
      unit: 'ms',
      baseline: `${baseline.hrv.mean.toFixed(0)} ± ${baseline.hrv.sd.toFixed(0)}`,
      trend: getTrend(physio.hrv, baseline.hrv.mean),
      status: getStatus(physio.hrv, baseline.hrv.mean, baseline.hrv.sd, true),
      color: 'bg-emerald-500/10 text-emerald-500',
    },
    {
      icon: Wind,
      label: 'Respiratory Rate',
      value: physio.rr.toFixed(0),
      unit: 'br/min',
      baseline: `${baseline.rr.mean.toFixed(0)} ± ${baseline.rr.sd.toFixed(0)}`,
      trend: getTrend(physio.rr, baseline.rr.mean),
      status: getStatus(physio.rr, baseline.rr.mean, baseline.rr.sd),
      color: 'bg-blue-500/10 text-blue-500',
    },
    {
      icon: Droplets,
      label: 'Electrodermal Activity',
      value: physio.eda.toFixed(1),
      unit: 'peaks/min',
      baseline: `${baseline.eda.mean.toFixed(1)} ± ${baseline.eda.sd.toFixed(1)}`,
      trend: getTrend(physio.eda, baseline.eda.mean),
      status: getStatus(physio.eda, baseline.eda.mean, baseline.eda.sd),
      color: 'bg-amber-500/10 text-amber-500',
    },
    {
      icon: Thermometer,
      label: 'Skin Temperature',
      value: physio.temp.toFixed(1),
      unit: '°C',
      baseline: `${baseline.temp.mean.toFixed(1)} ± ${baseline.temp.sd.toFixed(1)}`,
      trend: getTrend(physio.temp, baseline.temp.mean),
      status: getStatus(physio.temp, baseline.temp.mean, baseline.temp.sd, true),
      color: 'bg-purple-500/10 text-purple-500',
    },
    {
      icon: Move,
      label: 'Motion / Fidgeting',
      value: physio.motion.toFixed(0),
      unit: '%',
      baseline: '< 20',
      trend: physio.motion > 30 ? 'up' : 'stable',
      status: physio.motion > 40 ? 'elevated' : 'normal',
      color: 'bg-cyan-500/10 text-cyan-500',
    },
  ];

  return (
    <AppLayout>
      <PageHeader 
        title="Physiology" 
        subtitle="Real-time biometrics"
      />
      
      <div className="px-4 space-y-4">
        {/* Status Banner */}
        <GlassCard className="animate-fade-up">
          <div className="flex items-center gap-3">
            <div className="w-3 h-3 rounded-full bg-success animate-pulse" />
            <div>
              <p className="font-semibold text-sm">At Rest</p>
              <p className="text-xs text-muted-foreground">Sensors active • Good signal quality</p>
            </div>
          </div>
        </GlassCard>

        {/* Live Chart */}
        <GlassCard elevated className="animate-fade-up stagger-1">
          <GlassCardHeader title="Live Signal" subtitle="Last 30 minutes" />
          
          <div className="flex gap-2 mb-4">
            {(['hr', 'hrv', 'rr', 'eda'] as const).map((signal) => (
              <button
                key={signal}
                onClick={() => setSelectedSignal(signal)}
                className={cn(
                  'px-3 py-1.5 rounded-lg text-xs font-medium transition-all',
                  selectedSignal === signal
                    ? 'bg-primary text-primary-foreground'
                    : 'bg-muted/50 text-muted-foreground hover:bg-muted'
                )}
              >
                {signal.toUpperCase()}
              </button>
            ))}
          </div>
          
          <div className="h-40">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={history} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id={`gradient-${selectedSignal}`} x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor={signalColors[selectedSignal]} stopOpacity={0.3} />
                    <stop offset="95%" stopColor={signalColors[selectedSignal]} stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis 
                  dataKey="time" 
                  tick={false}
                  axisLine={false}
                />
                <YAxis 
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
                  labelFormatter={() => ''}
                  formatter={(value: number) => [value.toFixed(1), selectedSignal.toUpperCase()]}
                />
                <Area
                  type="monotone"
                  dataKey={selectedSignal}
                  stroke={signalColors[selectedSignal]}
                  strokeWidth={2}
                  fillOpacity={1}
                  fill={`url(#gradient-${selectedSignal})`}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </GlassCard>

        {/* Signal Cards Grid */}
        <div className="grid grid-cols-2 gap-3">
          {signals.map((signal, index) => (
            <div key={signal.label} className={`stagger-${index + 2}`}>
              <SignalCard {...signal} />
            </div>
          ))}
        </div>

        {/* Calibration Info */}
        <GlassCard className="animate-fade-up">
          <GlassCardHeader 
            title="Calibration Status" 
            subtitle={baseline.isCalibrated ? 'Complete' : `Day ${baseline.calibrationDay}/3`}
          />
          <div className="h-2 bg-muted rounded-full overflow-hidden">
            <div 
              className="h-full bg-primary rounded-full transition-all duration-500"
              style={{ width: baseline.isCalibrated ? '100%' : `${(baseline.calibrationDay / 3) * 100}%` }}
            />
          </div>
          <p className="text-xs text-muted-foreground mt-2">
            {baseline.isCalibrated 
              ? 'Your personalized baselines are ready. They update automatically.'
              : 'Collecting baseline data. Stay rested for accurate calibration.'}
          </p>
        </GlassCard>
      </div>
    </AppLayout>
  );
}
