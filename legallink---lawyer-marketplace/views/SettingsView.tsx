
import React from 'react';
import { AppView } from '../types';

interface SettingsViewProps {
  onBack: () => void;
  onLogout: () => void;
}

const SettingsView: React.FC<SettingsViewProps> = ({ onBack, onLogout }) => {
  return (
    <div className="h-full bg-white flex flex-col p-6 animate-in slide-in-from-right-10 duration-300">
      <header className="flex items-center gap-4 mb-10 pt-6">
        <button onClick={onBack} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
      </header>

      <div className="flex-1 space-y-8">
        <section>
          <h3 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4">Privacy & Legal</h3>
          <div className="bg-gray-50 rounded-[32px] overflow-hidden">
            <button className="w-full p-5 text-left flex justify-between items-center border-b border-gray-100 hover:bg-gray-100 transition-all">
              <span className="font-medium text-gray-700">Privacy Policy</span>
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-gray-400"><path d="m9 18 6-6-6-6"/></svg>
            </button>
            <button className="w-full p-5 text-left flex justify-between items-center hover:bg-gray-100 transition-all">
              <span className="font-medium text-gray-700">Terms of Service</span>
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-gray-400"><path d="m9 18 6-6-6-6"/></svg>
            </button>
          </div>
        </section>

        <section>
          <h3 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4">Security</h3>
          <div className="bg-gray-50 rounded-[32px] overflow-hidden">
            <div className="w-full p-5 flex justify-between items-center border-b border-gray-100">
              <span className="font-medium text-gray-700">Enable Biometrics</span>
              <div className="w-12 h-6 bg-amber-700 rounded-full relative">
                <div className="absolute right-1 top-1 w-4 h-4 bg-white rounded-full"></div>
              </div>
            </div>
            <button className="w-full p-5 text-left flex justify-between items-center hover:bg-gray-100 transition-all">
              <span className="font-medium text-gray-700">Change Password</span>
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-gray-400"><path d="m9 18 6-6-6-6"/></svg>
            </button>
          </div>
        </section>

        <section className="pt-10">
          <button 
            onClick={() => {
              if (window.confirm("Are you absolutely sure? This will permanently delete your legal data and account from our servers as required by app store policies.")) {
                onLogout();
              }
            }}
            className="w-full p-5 rounded-[32px] bg-red-50 text-red-600 font-bold border border-red-100 hover:bg-red-100 transition-all flex items-center justify-center gap-2"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/><line x1="10" x2="10" y1="11" y2="17"/><line x1="14" x2="14" y1="11" y2="17"/></svg>
            Delete Account Permanently
          </button>
        </section>
      </div>

      <p className="text-center text-[10px] text-gray-400 font-bold uppercase tracking-widest pb-10">LegalLink v1.0.0 (Release Build)</p>
    </div>
  );
};

export default SettingsView;
