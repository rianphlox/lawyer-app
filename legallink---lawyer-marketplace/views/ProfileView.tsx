
import React from 'react';
import { AppView } from '../types';

interface ProfileViewProps {
  onNavigate: (view: AppView) => void;
  yearsExperience: number;
  setYearsExperience: (val: number) => void;
  onLogout: () => void;
}

const ProfileView: React.FC<ProfileViewProps> = ({ onNavigate, yearsExperience, setYearsExperience, onLogout }) => {
  return (
    <div className="p-8 pb-32 h-full overflow-y-auto no-scrollbar bg-[#fdfaf5]">
      <header className="mb-8 pt-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">My Profile</h1>
      </header>

      <div className="flex flex-col items-center mb-10">
        <div className="relative group">
          <div className="w-32 h-32 rounded-[40px] border-4 border-amber-700/20 p-1 mb-4 bg-gray-50">
            <img 
              src="assets/my-profile.jpg" 
              className="w-full h-full object-cover rounded-[36px]" 
              alt="Profile"
              onError={(e) => (e.target as HTMLImageElement).src = 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=400'}
            />
          </div>
          <button className="absolute bottom-6 right-0 bg-black text-white p-2 rounded-full border-2 border-white shadow-xl hover:scale-110 transition-all">
             <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/></svg>
          </button>
        </div>
        <h2 className="text-2xl font-bold text-gray-900">Sanzi Malhotra</h2>
        <p className="text-amber-700 font-bold text-xs uppercase tracking-[0.2em] mt-1">Senior Advocate</p>
      </div>

      <div className="space-y-8">
        <section>
          <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
             <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 11h.01"/><path d="M18 11h.01"/><path d="M6 11h.01"/><path d="M10 16h4"/><path d="M8 6h8a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z"/></svg>
             Verification Info
          </h3>
          <div className="space-y-4">
             <div className="bg-white p-5 rounded-[32px] border border-gray-100 shadow-sm flex justify-between items-center">
                <div>
                  <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">Bar License Number</p>
                  <p className="font-bold text-gray-900">NY-BAR-88291-LLP</p>
                </div>
                <div className="bg-green-100 text-green-700 p-2 rounded-full">
                   <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
             </div>
             
             <div className="bg-white p-6 rounded-[32px] border border-gray-100 shadow-sm">
                <div className="flex justify-between items-center mb-4">
                  <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Experience Level</p>
                  <span className="bg-amber-100 text-amber-800 px-3 py-1 rounded-full text-xs font-bold">{yearsExperience} Years</span>
                </div>
                <input 
                  type="range" 
                  min="0" 
                  max="30" 
                  value={yearsExperience} 
                  onChange={(e) => setYearsExperience(parseInt(e.target.value))}
                  className="w-full h-2 bg-gray-100 rounded-lg appearance-none cursor-pointer accent-amber-700"
                />
                <p className="text-[10px] text-gray-400 mt-4 italic">Adjusting this updates your subscription tier eligibility.</p>
             </div>
          </div>
        </section>

        <section>
          <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
             <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1Z"/></svg>
             Account Control
          </h3>
          <div className="bg-white rounded-[40px] overflow-hidden border border-gray-100 shadow-sm">
             <button onClick={() => onNavigate('subscription')} className="w-full p-5 text-left flex justify-between items-center border-b border-gray-50 hover:bg-gray-50 transition-colors">
                <span className="font-semibold text-gray-700">Manage Subscription</span>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-gray-400"><path d="m9 18 6-6-6-6"/></svg>
             </button>
             <button onClick={() => onNavigate('settings')} className="w-full p-5 text-left flex justify-between items-center border-b border-gray-50 hover:bg-gray-50 transition-colors">
                <span className="font-semibold text-gray-700">App Settings & Security</span>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-gray-400"><path d="m9 18 6-6-6-6"/></svg>
             </button>
             <button onClick={onLogout} className="w-full p-5 text-left flex justify-between items-center text-red-500 hover:bg-red-50 transition-colors">
                <span className="font-bold">Sign Out</span>
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" x2="9" y1="12" y2="12"/></svg>
             </button>
          </div>
        </section>
      </div>
    </div>
  );
};

export default ProfileView;
