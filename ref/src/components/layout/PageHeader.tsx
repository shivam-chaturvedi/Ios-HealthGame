import { cn } from '@/lib/utils';
import { ChevronLeft, Settings } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  showBack?: boolean;
  showSettings?: boolean;
  rightAction?: React.ReactNode;
  className?: string;
}

export function PageHeader({ 
  title, 
  subtitle, 
  showBack = false, 
  showSettings = false,
  rightAction,
  className 
}: PageHeaderProps) {
  const navigate = useNavigate();

  return (
    <header className={cn('sticky top-0 z-40 pt-safe', className)}>
      <div className="glass-card rounded-none border-t-0 border-x-0 px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            {showBack && (
              <button
                onClick={() => navigate(-1)}
                className="w-10 h-10 -ml-2 flex items-center justify-center rounded-xl hover:bg-muted/50 transition-colors"
              >
                <ChevronLeft className="w-6 h-6 text-primary" />
              </button>
            )}
            <div>
              <h1 className="text-xl font-bold text-foreground">{title}</h1>
              {subtitle && (
                <p className="text-sm text-muted-foreground">{subtitle}</p>
              )}
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            {rightAction}
            {showSettings && (
              <button
                onClick={() => navigate('/settings')}
                className="w-10 h-10 flex items-center justify-center rounded-xl hover:bg-muted/50 transition-colors"
              >
                <Settings className="w-5 h-5 text-muted-foreground" />
              </button>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
