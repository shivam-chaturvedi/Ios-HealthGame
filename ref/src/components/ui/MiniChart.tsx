import { Area, AreaChart, ResponsiveContainer } from 'recharts';
import { getAnxietyLevel } from '@/types/anxiety';

interface MiniChartProps {
  data: { time: Date; score: number }[];
  height?: number;
  currentScore?: number;
}

export function MiniChart({ data, height = 60, currentScore }: MiniChartProps) {
  const level = currentScore ? getAnxietyLevel(currentScore) : 'moderate';
  
  const getGradientId = () => {
    switch (level) {
      case 'low': return 'colorLow';
      case 'moderate': return 'colorModerate';
      case 'high': return 'colorHigh';
      case 'very-high': return 'colorVeryHigh';
    }
  };
  
  const getStrokeColor = () => {
    switch (level) {
      case 'low': return '#10B981';
      case 'moderate': return '#F59E0B';
      case 'high': return '#F97316';
      case 'very-high': return '#EF4444';
    }
  };

  return (
    <div style={{ height }} className="w-full">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={data} margin={{ top: 0, right: 0, left: 0, bottom: 0 }}>
          <defs>
            <linearGradient id="colorLow" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#10B981" stopOpacity={0.3} />
              <stop offset="95%" stopColor="#10B981" stopOpacity={0} />
            </linearGradient>
            <linearGradient id="colorModerate" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#F59E0B" stopOpacity={0.3} />
              <stop offset="95%" stopColor="#F59E0B" stopOpacity={0} />
            </linearGradient>
            <linearGradient id="colorHigh" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#F97316" stopOpacity={0.3} />
              <stop offset="95%" stopColor="#F97316" stopOpacity={0} />
            </linearGradient>
            <linearGradient id="colorVeryHigh" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#EF4444" stopOpacity={0.3} />
              <stop offset="95%" stopColor="#EF4444" stopOpacity={0} />
            </linearGradient>
          </defs>
          <Area
            type="monotone"
            dataKey="score"
            stroke={getStrokeColor()}
            strokeWidth={2}
            fillOpacity={1}
            fill={`url(#${getGradientId()})`}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
