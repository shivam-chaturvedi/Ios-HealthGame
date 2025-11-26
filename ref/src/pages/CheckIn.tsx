import { useState } from 'react';
import { AppLayout } from '@/components/layout/AppLayout';
import { PageHeader } from '@/components/layout/PageHeader';
import { GlassCard, GlassCardHeader } from '@/components/ui/GlassCard';
import { mockCheckinData } from '@/data/mockData';
import { 
  ClipboardCheck, 
  Smile, 
  Frown, 
  Meh,
  AlertTriangle,
  Clock,
  Plus,
  Check,
  X
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { format } from 'date-fns';
import { toast } from 'sonner';

const GAD2_QUESTIONS = [
  {
    id: 1,
    text: 'Over the last 2 weeks, how often have you been feeling nervous, anxious, or on edge?',
  },
  {
    id: 2,
    text: 'Over the last 2 weeks, how often have you been unable to stop or control worrying?',
  },
];

const GAD2_OPTIONS = [
  { value: 0, label: 'Not at all' },
  { value: 1, label: 'Several days' },
  { value: 2, label: 'More than half the days' },
  { value: 3, label: 'Nearly every day' },
];

const MOOD_OPTIONS = [
  { value: 0, label: 'Calm', icon: Smile, color: 'bg-success/20 text-success border-success/30' },
  { value: 1, label: 'Mild', icon: Smile, color: 'bg-primary/20 text-primary border-primary/30' },
  { value: 2, label: 'Moderate', icon: Meh, color: 'bg-warning/20 text-warning border-warning/30' },
  { value: 3, label: 'Anxious', icon: Frown, color: 'bg-destructive/20 text-destructive border-destructive/30' },
  { value: 4, label: 'Very Anxious', icon: AlertTriangle, color: 'bg-destructive/20 text-destructive border-destructive/30' },
];

export default function CheckIn() {
  const [checkin, setCheckin] = useState(mockCheckinData);
  const [gadAnswers, setGadAnswers] = useState<{ [key: number]: number }>({});
  const [selectedMood, setSelectedMood] = useState<number | null>(null);
  const [showMomentForm, setShowMomentForm] = useState(false);
  const [momentNote, setMomentNote] = useState('');
  const [momentIntensity, setMomentIntensity] = useState(3);

  const handleGadAnswer = (questionId: number, value: number) => {
    setGadAnswers(prev => ({ ...prev, [questionId]: value }));
  };

  const submitGad2 = () => {
    const score = Object.values(gadAnswers).reduce((a, b) => a + b, 0);
    setCheckin(prev => ({
      ...prev,
      gad2Score: score,
      lastUpdated: new Date(),
    }));
    toast.success(`GAD-2 submitted. Score: ${score}/6`);
  };

  const submitMood = (value: number) => {
    setSelectedMood(value);
    setCheckin(prev => ({
      ...prev,
      mood: value,
      lastUpdated: new Date(),
    }));
    toast.success('Mood recorded');
  };

  const addAnxietyMoment = () => {
    const newMoment = {
      id: Date.now().toString(),
      timestamp: new Date(),
      notes: momentNote,
      intensity: momentIntensity,
    };
    setCheckin(prev => ({
      ...prev,
      anxietyMoments: [newMoment, ...prev.anxietyMoments],
      lastUpdated: new Date(),
    }));
    setShowMomentForm(false);
    setMomentNote('');
    setMomentIntensity(3);
    toast.success('Anxiety moment logged');
  };

  const gadComplete = Object.keys(gadAnswers).length === 2;

  return (
    <AppLayout>
      <PageHeader 
        title="Check-in" 
        subtitle="Anchor your score"
      />
      
      <div className="px-4 space-y-4">
        {/* Last Check-in */}
        <GlassCard className="animate-fade-up">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
              <Clock className="w-5 h-5 text-primary" />
            </div>
            <div>
              <p className="text-sm font-medium">Last check-in</p>
              <p className="text-xs text-muted-foreground">
                {format(checkin.lastUpdated, 'MMM d, h:mm a')}
              </p>
            </div>
          </div>
        </GlassCard>

        {/* GAD-2 Questionnaire */}
        <GlassCard elevated className="animate-fade-up stagger-1">
          <GlassCardHeader 
            title="GAD-2 Quick Check" 
            subtitle="2 questions · takes 30 seconds"
            icon={<ClipboardCheck className="w-5 h-5" />}
          />
          
          <div className="space-y-6">
            {GAD2_QUESTIONS.map((question) => (
              <div key={question.id}>
                <p className="text-sm font-medium mb-3">{question.text}</p>
                <div className="grid grid-cols-2 gap-2">
                  {GAD2_OPTIONS.map((option) => (
                    <button
                      key={option.value}
                      onClick={() => handleGadAnswer(question.id, option.value)}
                      className={cn(
                        'p-3 rounded-xl text-sm font-medium transition-all text-left',
                        gadAnswers[question.id] === option.value
                          ? 'bg-primary text-primary-foreground'
                          : 'bg-muted/50 text-foreground hover:bg-muted'
                      )}
                    >
                      {option.label}
                    </button>
                  ))}
                </div>
              </div>
            ))}
            
            <button
              onClick={submitGad2}
              disabled={!gadComplete}
              className={cn(
                'w-full ios-button-primary',
                !gadComplete && 'opacity-50 cursor-not-allowed'
              )}
            >
              Submit GAD-2
            </button>
          </div>
        </GlassCard>

        {/* Mood Slider */}
        <GlassCard elevated className="animate-fade-up stagger-2">
          <GlassCardHeader 
            title="Quick Mood Check" 
            subtitle="How are you feeling right now?"
          />
          
          <div className="grid grid-cols-5 gap-2">
            {MOOD_OPTIONS.map((option) => {
              const Icon = option.icon;
              return (
                <button
                  key={option.value}
                  onClick={() => submitMood(option.value)}
                  className={cn(
                    'flex flex-col items-center gap-2 p-3 rounded-xl border-2 transition-all',
                    selectedMood === option.value
                      ? option.color
                      : 'border-transparent bg-muted/30 hover:bg-muted/50'
                  )}
                >
                  <Icon className="w-6 h-6" />
                  <span className="text-xs font-medium">{option.label}</span>
                </button>
              );
            })}
          </div>
        </GlassCard>

        {/* Anxiety Moments */}
        <GlassCard elevated className="animate-fade-up stagger-3">
          <GlassCardHeader 
            title="Anxiety Moments" 
            subtitle="Mark when you feel anxious"
            action={
              <button
                onClick={() => setShowMomentForm(!showMomentForm)}
                className="w-8 h-8 rounded-lg bg-primary/10 flex items-center justify-center text-primary"
              >
                {showMomentForm ? <X className="w-4 h-4" /> : <Plus className="w-4 h-4" />}
              </button>
            }
          />
          
          {showMomentForm && (
            <div className="mb-4 p-4 rounded-xl bg-muted/30 space-y-4 animate-scale-up">
              <div>
                <label className="text-sm font-medium mb-2 block">Intensity (1-5)</label>
                <div className="flex gap-2">
                  {[1, 2, 3, 4, 5].map((i) => (
                    <button
                      key={i}
                      onClick={() => setMomentIntensity(i)}
                      className={cn(
                        'flex-1 py-2 rounded-lg text-sm font-medium transition-all',
                        momentIntensity === i
                          ? 'bg-primary text-primary-foreground'
                          : 'bg-muted text-muted-foreground'
                      )}
                    >
                      {i}
                    </button>
                  ))}
                </div>
              </div>
              
              <div>
                <label className="text-sm font-medium mb-2 block">Notes (optional)</label>
                <textarea
                  value={momentNote}
                  onChange={(e) => setMomentNote(e.target.value)}
                  placeholder="What triggered this?"
                  className="ios-input resize-none h-20"
                />
              </div>
              
              <button onClick={addAnxietyMoment} className="w-full ios-button-primary">
                Log Moment
              </button>
            </div>
          )}
          
          <div className="space-y-2">
            {checkin.anxietyMoments.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center py-4">
                No moments logged today
              </p>
            ) : (
              checkin.anxietyMoments.map((moment) => (
                <div
                  key={moment.id}
                  className="flex items-start gap-3 p-3 rounded-xl bg-muted/30"
                >
                  <div className={cn(
                    'w-8 h-8 rounded-lg flex items-center justify-center text-sm font-bold',
                    moment.intensity >= 4 ? 'bg-destructive/20 text-destructive' :
                    moment.intensity >= 3 ? 'bg-warning/20 text-warning' :
                    'bg-primary/20 text-primary'
                  )}>
                    {moment.intensity}
                  </div>
                  <div className="flex-1">
                    <p className="text-xs text-muted-foreground">
                      {format(moment.timestamp, 'h:mm a')}
                    </p>
                    {moment.notes && (
                      <p className="text-sm mt-1">{moment.notes}</p>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </GlassCard>

        {/* Current Scores */}
        <GlassCard className="animate-fade-up stagger-4">
          <GlassCardHeader title="Current Check-in Scores" />
          <div className="grid grid-cols-2 gap-4">
            <div className="text-center p-3 rounded-xl bg-muted/30">
              <p className="text-2xl font-bold text-primary">{checkin.gad2Score}/6</p>
              <p className="text-xs text-muted-foreground mt-1">GAD-2 Score</p>
            </div>
            <div className="text-center p-3 rounded-xl bg-muted/30">
              <p className="text-2xl font-bold text-secondary">{checkin.mood}/4</p>
              <p className="text-xs text-muted-foreground mt-1">Mood Level</p>
            </div>
          </div>
        </GlassCard>
      </div>
    </AppLayout>
  );
}
