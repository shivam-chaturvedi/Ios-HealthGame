import { cn } from '@/lib/utils';
import { getAnxietyLevel, getAnxietyColor } from '@/types/anxiety';

interface AnxietyScoreRingProps {
  score: number;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  showLabel?: boolean;
  animated?: boolean;
}

const sizeClasses = {
  sm: 'w-16 h-16',
  md: 'w-24 h-24',
  lg: 'w-32 h-32',
  xl: 'w-44 h-44',
};

const strokeWidths = {
  sm: 4,
  md: 6,
  lg: 8,
  xl: 10,
};

const fontSizes = {
  sm: 'text-lg',
  md: 'text-2xl',
  lg: 'text-4xl',
  xl: 'text-5xl',
};

export function AnxietyScoreRing({ 
  score, 
  size = 'lg', 
  showLabel = true,
  animated = true 
}: AnxietyScoreRingProps) {
  const level = getAnxietyLevel(score);
  const colorClass = getAnxietyColor(level);
  
  const radius = 45;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - (score / 100) * circumference;
  
  const getGradientColors = () => {
    switch (level) {
      case 'low':
        return { start: '#34D399', end: '#10B981' };
      case 'moderate':
        return { start: '#FBBF24', end: '#F59E0B' };
      case 'high':
        return { start: '#FB923C', end: '#F97316' };
      case 'very-high':
        return { start: '#F87171', end: '#EF4444' };
    }
  };
  
  const colors = getGradientColors();
  
  return (
    <div className={cn('relative flex items-center justify-center', sizeClasses[size])}>
      <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
        <defs>
          <linearGradient id={`gradient-${score}`} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor={colors.start} />
            <stop offset="100%" stopColor={colors.end} />
          </linearGradient>
        </defs>
        
        {/* Background circle */}
        <circle
          cx="50"
          cy="50"
          r={radius}
          fill="none"
          stroke="currentColor"
          strokeWidth={strokeWidths[size]}
          className="text-muted/30"
        />
        
        {/* Progress circle */}
        <circle
          cx="50"
          cy="50"
          r={radius}
          fill="none"
          stroke={`url(#gradient-${score})`}
          strokeWidth={strokeWidths[size]}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={animated ? strokeDashoffset : circumference}
          className={cn(
            'transition-all duration-1000 ease-out',
            animated && 'animate-[score-fill_1s_ease-out_forwards]'
          )}
          style={{
            '--score-offset': strokeDashoffset,
          } as React.CSSProperties}
        />
        
        {/* Glow effect */}
        <circle
          cx="50"
          cy="50"
          r={radius}
          fill="none"
          stroke={`url(#gradient-${score})`}
          strokeWidth={strokeWidths[size] + 4}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          className="opacity-20 blur-sm"
        />
      </svg>
      
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className={cn('font-bold', fontSizes[size], colorClass)}>
          {score}
        </span>
        {showLabel && (
          <span className="text-xs text-muted-foreground capitalize mt-1">
            {level.replace('-', ' ')}
          </span>
        )}
      </div>
    </div>
  );
}
