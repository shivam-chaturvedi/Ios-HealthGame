import { cn } from '@/lib/utils';
import { ReactNode } from 'react';

interface GlassCardProps {
  children: ReactNode;
  className?: string;
  elevated?: boolean;
  onClick?: () => void;
}

export function GlassCard({ children, className, elevated = false, onClick }: GlassCardProps) {
  return (
    <div
      className={cn(
        elevated ? 'glass-card-elevated' : 'glass-card',
        'p-5 transition-all duration-300',
        onClick && 'cursor-pointer hover:scale-[1.02] active:scale-[0.98]',
        className
      )}
      onClick={onClick}
    >
      {children}
    </div>
  );
}

interface GlassCardHeaderProps {
  title: string;
  subtitle?: string;
  icon?: ReactNode;
  action?: ReactNode;
}

export function GlassCardHeader({ title, subtitle, icon, action }: GlassCardHeaderProps) {
  return (
    <div className="flex items-center justify-between mb-4">
      <div className="flex items-center gap-3">
        {icon && (
          <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
            {icon}
          </div>
        )}
        <div>
          <h3 className="font-semibold text-foreground">{title}</h3>
          {subtitle && <p className="text-sm text-muted-foreground">{subtitle}</p>}
        </div>
      </div>
      {action}
    </div>
  );
}
