import { cn } from '@/lib/utils';
import { Shield, ShieldAlert, ShieldCheck } from 'lucide-react';

interface ConfidenceBadgeProps {
  confidence: 'high' | 'medium' | 'low';
  showLabel?: boolean;
}

export function ConfidenceBadge({ confidence, showLabel = true }: ConfidenceBadgeProps) {
  const config = {
    high: {
      icon: ShieldCheck,
      label: 'High Confidence',
      className: 'bg-success/10 text-success border-success/20',
    },
    medium: {
      icon: Shield,
      label: 'Medium Confidence',
      className: 'bg-warning/10 text-warning border-warning/20',
    },
    low: {
      icon: ShieldAlert,
      label: 'Low Confidence',
      className: 'bg-destructive/10 text-destructive border-destructive/20',
    },
  };

  const { icon: Icon, label, className } = config[confidence];

  return (
    <div
      className={cn(
        'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border',
        className
      )}
    >
      <Icon className="w-3.5 h-3.5" />
      {showLabel && <span>{label}</span>}
    </div>
  );
}
