import { ReactNode } from 'react';
import { TabBar } from './TabBar';

interface AppLayoutProps {
  children: ReactNode;
  hideTabBar?: boolean;
}

export function AppLayout({ children, hideTabBar = false }: AppLayoutProps) {
  return (
    <div className="min-h-screen bg-background pb-24">
      <main className="max-w-lg mx-auto">
        {children}
      </main>
      {!hideTabBar && <TabBar />}
    </div>
  );
}
