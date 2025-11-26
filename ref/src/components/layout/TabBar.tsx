import { cn } from '@/lib/utils';
import { 
  Home, 
  Activity, 
  Heart, 
  ClipboardCheck, 
  Sparkles,
  BarChart3,
  Settings
} from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';

interface TabItem {
  icon: React.ElementType;
  label: string;
  path: string;
}

const tabs: TabItem[] = [
  { icon: Home, label: 'Home', path: '/' },
  { icon: Activity, label: 'Physio', path: '/physiology' },
  { icon: Heart, label: 'Lifestyle', path: '/lifestyle' },
  { icon: ClipboardCheck, label: 'Check-in', path: '/checkin' },
  { icon: Sparkles, label: 'Help', path: '/interventions' },
];

export function TabBar() {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <nav className="tab-bar">
      <div className="flex items-center justify-around px-2 py-1">
        {tabs.map((tab) => {
          const isActive = location.pathname === tab.path;
          const Icon = tab.icon;
          
          return (
            <button
              key={tab.path}
              onClick={() => navigate(tab.path)}
              className={cn(
                'tab-item flex-1',
                isActive ? 'active' : ''
              )}
            >
              <div className={cn(
                'w-8 h-8 rounded-xl flex items-center justify-center transition-all duration-200',
                isActive ? 'bg-primary/15 scale-110' : 'bg-transparent'
              )}>
                <Icon className={cn(
                  'w-5 h-5 transition-all duration-200',
                  isActive ? 'text-primary' : 'text-muted-foreground'
                )} />
              </div>
              <span className={cn(
                'text-[10px] font-medium transition-colors duration-200',
                isActive ? 'text-primary' : 'text-muted-foreground'
              )}>
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
