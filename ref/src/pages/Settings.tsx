import { useState } from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/layout/PageHeader';
import { GlassCard, GlassCardHeader } from '@/components/ui/GlassCard';
import { 
  User, 
  Bell, 
  Watch, 
  Download,
  Sparkles,
  ChevronRight,
  Shield,
  HelpCircle,
  LogOut,
  Moon,
  Sun
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

interface SettingItemProps {
  icon: React.ElementType;
  label: string;
  description?: string;
  action?: React.ReactNode;
  onClick?: () => void;
  color?: string;
}

function SettingItem({ icon: Icon, label, description, action, onClick, color = 'bg-primary/10 text-primary' }: SettingItemProps) {
  return (
    <button
      onClick={onClick}
      className="w-full flex items-center gap-4 p-4 rounded-xl bg-card/50 hover:bg-card/80 transition-colors text-left"
    >
      <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center', color)}>
        <Icon className="w-5 h-5" />
      </div>
      <div className="flex-1">
        <p className="font-medium text-sm">{label}</p>
        {description && <p className="text-xs text-muted-foreground">{description}</p>}
      </div>
      {action || <ChevronRight className="w-5 h-5 text-muted-foreground" />}
    </button>
  );
}

export default function Settings() {
  const [aiEnabled, setAiEnabled] = useState(true);
  const [notifications, setNotifications] = useState('medium');
  const [primaryConcern, setPrimaryConcern] = useState('anxiety');

  const handleExport = () => {
    toast.success('Data export started. Check your email.');
  };

  return (
    <AppLayout>
      <PageHeader 
        title="Settings" 
        subtitle="Customize your experience"
        showBack
      />
      
      <div className="px-4 space-y-4">
        {/* Profile */}
        <GlassCard className="animate-fade-up">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-primary-foreground text-2xl font-bold">
              AC
            </div>
            <div className="flex-1">
              <p className="font-semibold">Anxiety Calculator</p>
              <p className="text-sm text-muted-foreground">V1 Demo Mode</p>
            </div>
            <ChevronRight className="w-5 h-5 text-muted-foreground" />
          </div>
        </GlassCard>

        {/* Primary Concern */}
        <div className="animate-fade-up stagger-1">
          <p className="section-header">Primary Concern</p>
          <GlassCard>
            <div className="flex gap-2">
              {['stress', 'anxiety', 'panic'].map((concern) => (
                <button
                  key={concern}
                  onClick={() => setPrimaryConcern(concern)}
                  className={cn(
                    'flex-1 py-3 rounded-xl text-sm font-medium transition-all capitalize',
                    primaryConcern === concern
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-muted/50 text-muted-foreground hover:bg-muted'
                  )}
                >
                  {concern}
                </button>
              ))}
            </div>
          </GlassCard>
        </div>

        {/* Notifications */}
        <div className="animate-fade-up stagger-2">
          <p className="section-header">Notifications</p>
          <GlassCard>
            <GlassCardHeader 
              title="Alert Frequency" 
              icon={<Bell className="w-5 h-5" />}
            />
            <div className="flex gap-2">
              {['low', 'medium', 'high'].map((freq) => (
                <button
                  key={freq}
                  onClick={() => setNotifications(freq)}
                  className={cn(
                    'flex-1 py-3 rounded-xl text-sm font-medium transition-all capitalize',
                    notifications === freq
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-muted/50 text-muted-foreground hover:bg-muted'
                  )}
                >
                  {freq}
                </button>
              ))}
            </div>
            <p className="text-xs text-muted-foreground mt-3">
              {notifications === 'low' && 'Only urgent alerts when anxiety is very high.'}
              {notifications === 'medium' && 'Balance of helpful nudges and important alerts.'}
              {notifications === 'high' && 'Proactive suggestions and real-time guidance.'}
            </p>
          </GlassCard>
        </div>

        {/* AI Personalization */}
        <div className="animate-fade-up stagger-3">
          <p className="section-header">AI Features</p>
          <GlassCard>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-secondary/10 flex items-center justify-center">
                  <Sparkles className="w-5 h-5 text-secondary" />
                </div>
                <div>
                  <p className="font-medium text-sm">Personalized Weights</p>
                  <p className="text-xs text-muted-foreground">AI adapts to your patterns</p>
                </div>
              </div>
              <button
                onClick={() => setAiEnabled(!aiEnabled)}
                className={cn(
                  'w-14 h-8 rounded-full p-1 transition-all duration-200',
                  aiEnabled ? 'bg-primary' : 'bg-muted'
                )}
              >
                <div className={cn(
                  'w-6 h-6 rounded-full bg-white transition-transform duration-200',
                  aiEnabled ? 'translate-x-6' : 'translate-x-0'
                )} />
              </button>
            </div>
            
            {aiEnabled && (
              <div className="mt-4 p-3 rounded-xl bg-muted/30">
                <p className="text-xs text-muted-foreground">
                  The app learns which factors affect you most and adjusts weight accordingly. 
                  Based on your feedback, sleep currently has 35% weight (vs default 30%).
                </p>
              </div>
            )}
          </GlassCard>
        </div>

        {/* Other Settings */}
        <div className="animate-fade-up stagger-4">
          <p className="section-header">More</p>
          <div className="space-y-2">
            <SettingItem
              icon={Watch}
              label="Connected Devices"
              description="Apple Watch connected"
              color="bg-cyan-500/10 text-cyan-500"
            />
            <SettingItem
              icon={Download}
              label="Export Data"
              description="Download your history"
              onClick={handleExport}
              color="bg-green-500/10 text-green-500"
            />
            <SettingItem
              icon={Shield}
              label="Privacy & Security"
              description="Manage your data"
              color="bg-purple-500/10 text-purple-500"
            />
            <SettingItem
              icon={HelpCircle}
              label="Help & Support"
              description="FAQs and contact"
              color="bg-amber-500/10 text-amber-500"
            />
          </div>
        </div>

        {/* Version Info */}
        <GlassCard className="animate-fade-up stagger-5">
          <div className="text-center py-4">
            <p className="text-sm font-medium">Anxiety Calculator</p>
            <p className="text-xs text-muted-foreground">Version 1.0.0 (Demo)</p>
            <p className="text-xs text-muted-foreground mt-2">
              © 2024 Wellness Labs
            </p>
          </div>
        </GlassCard>
      </div>
    </AppLayout>
  );
}
