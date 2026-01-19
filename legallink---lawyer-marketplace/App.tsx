
import React, { useState } from 'react';
import { AppView, Lawyer, UserRole } from './types';
import LandingView from './views/LandingView';
import HomeView from './views/HomeView';
import DetailsView from './views/DetailsView';
import ProfileView from './views/ProfileView';
import PostGigView from './views/PostGigView';
import SubscriptionView from './views/SubscriptionView';
import OnboardingView from './views/OnboardingView';
import AuthView from './views/AuthView';
import MessagesView from './views/MessagesView';
import EarningsView from './views/EarningsView';
import ApplicationsView from './views/ApplicationsView';
import VerificationView from './views/VerificationView';
import AIChatView from './views/AIChatView';
import SettingsView from './views/SettingsView';
import LegalView from './views/LegalView';

const App: React.FC = () => {
  const [currentView, setCurrentView] = useState<AppView>('landing');
  const [selectedLawyer, setSelectedLawyer] = useState<Lawyer | null>(null);
  const [userRole, setUserRole] = useState<UserRole | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [yearsExperience, setYearsExperience] = useState(2);

  const navigateTo = (view: AppView) => {
    setCurrentView(view);
  };

  const handleStart = () => navigateTo('onboarding');

  const handleAuthSuccess = (role: UserRole) => {
    setUserRole(role);
    setIsAuthenticated(true);
    if (role !== UserRole.CLIENT) {
      navigateTo('verification');
    } else {
      navigateTo('home');
    }
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setUserRole(null);
    navigateTo('landing');
  };

  const showNav = isAuthenticated && !['landing', 'onboarding', 'auth', 'details', 'verification', 'ai-chat', 'settings', 'legal'].includes(currentView);

  return (
    <div className="flex justify-center min-h-screen bg-[#0a0a0a] overflow-hidden font-['Plus_Jakarta_Sans']">
      <div className="w-full max-w-[430px] bg-[#fdfaf5] relative overflow-hidden shadow-[0_0_100px_rgba(0,0,0,0.5)] min-h-screen flex flex-col">
        
        <main className="flex-1 relative overflow-hidden">
          {currentView === 'landing' && <LandingView onStart={handleStart} />}
          {currentView === 'onboarding' && <OnboardingView onComplete={() => navigateTo('auth')} />}
          {currentView === 'auth' && <AuthView onAuthSuccess={handleAuthSuccess} />}
          {currentView === 'verification' && <VerificationView onComplete={() => navigateTo('home')} />}
          {currentView === 'ai-chat' && <AIChatView onBack={() => navigateTo('home')} />}
          
          {currentView === 'home' && (
            <HomeView 
              userRole={userRole}
              onSelectLawyer={(l) => { setSelectedLawyer(l); navigateTo('details'); }} 
              onNavigate={navigateTo}
            />
          )}

          {currentView === 'details' && selectedLawyer && (
            <DetailsView 
              lawyer={selectedLawyer} 
              onBack={() => navigateTo('home')} 
            />
          )}

          {currentView === 'profile' && (
            <ProfileView 
              onNavigate={navigateTo} 
              yearsExperience={yearsExperience}
              setYearsExperience={setYearsExperience}
              onLogout={handleLogout}
            />
          )}

          {currentView === 'post-gig' && <PostGigView onNavigate={navigateTo} />}
          {currentView === 'subscription' && <SubscriptionView onNavigate={navigateTo} userRole={userRole} />}
          {currentView === 'messages' && <MessagesView onNavigate={navigateTo} />}
          {currentView === 'earnings' && <EarningsView onNavigate={navigateTo} />}
          {currentView === 'applications' && <ApplicationsView onNavigate={navigateTo} />}
          {currentView === 'settings' && <SettingsView onBack={() => navigateTo('profile')} onLogout={handleLogout} />}
          {currentView === 'legal' && <LegalView onBack={() => navigateTo('settings')} />}
        </main>

        {/* AI Concierge FAB */}
        {isAuthenticated && currentView !== 'ai-chat' && (
          <button 
            onClick={() => navigateTo('ai-chat')}
            className="absolute bottom-28 right-6 w-14 h-14 bg-amber-700 text-white rounded-2xl shadow-2xl flex items-center justify-center z-[60] active:scale-90 transition-transform hover:bg-amber-800"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/></svg>
          </button>
        )}

        {showNav && (
          <nav className="absolute bottom-8 left-1/2 -translate-x-1/2 w-[88%] bg-black/95 backdrop-blur-2xl rounded-[32px] px-2 py-2 flex justify-between items-center text-white z-50 shadow-2xl border border-white/10">
            <button onClick={() => navigateTo('home')} className={`flex-1 py-3 transition-all flex flex-col items-center gap-1 ${currentView === 'home' ? 'text-amber-500' : 'opacity-40'}`}>
              <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
              <span className="text-[8px] font-bold uppercase">Home</span>
            </button>
            <button onClick={() => navigateTo(userRole === UserRole.CLIENT ? 'post-gig' : 'earnings')} className={`flex-1 py-3 transition-all flex flex-col items-center gap-1 ${['post-gig', 'earnings'].includes(currentView) ? 'text-amber-500' : 'opacity-40'}`}>
              {userRole === UserRole.CLIENT ? (
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="12" cy="12" r="10"/><path d="M12 8v8"/><path d="M8 12h8"/></svg>
              ) : (
                <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><rect width="20" height="14" x="2" y="5" rx="2"/><line x1="2" x2="22" y1="10" y2="10"/></svg>
              )}
              <span className="text-[8px] font-bold uppercase">{userRole === UserRole.CLIENT ? 'Post' : 'Earnings'}</span>
            </button>
            <button onClick={() => navigateTo('messages')} className={`flex-1 py-3 transition-all flex flex-col items-center gap-1 ${currentView === 'messages' ? 'text-amber-500' : 'opacity-40'}`}>
              <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
              <span className="text-[8px] font-bold uppercase">Chat</span>
            </button>
            <button onClick={() => navigateTo('profile')} className={`flex-1 py-3 transition-all flex flex-col items-center gap-1 ${currentView === 'profile' ? 'text-amber-500' : 'opacity-40'}`}>
              <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="10" r="3"/><path d="M7 20.662V19a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1.662"/></svg>
              <span className="text-[8px] font-bold uppercase">Me</span>
            </button>
          </nav>
        )}
      </div>
    </div>
  );
};

export default App;
