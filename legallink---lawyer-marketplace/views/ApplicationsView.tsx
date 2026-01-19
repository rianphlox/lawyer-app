
import React, { useState } from 'react';
import { AppView } from '../types';
import { MOCK_APPLICATIONS, MOCK_GIGS } from '../constants';

interface ApplicationsViewProps {
  onNavigate: (view: AppView) => void;
}

const ApplicationsView: React.FC<ApplicationsViewProps> = ({ onNavigate }) => {
  const [activeTab, setActiveTab] = useState<'pending' | 'accepted' | 'rejected'>('pending');

  const filteredApps = MOCK_APPLICATIONS.filter(app => app.status === activeTab);

  return (
    <div className="h-full bg-[#fdfaf5] p-6 pb-32 overflow-y-auto no-scrollbar">
      <header className="mb-8 pt-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Applications</h1>
        <p className="text-gray-400 text-sm">Monitor your case opportunities.</p>
      </header>

      {/* Tabs */}
      <div className="flex bg-gray-100 p-1.5 rounded-full mb-8">
        {(['pending', 'accepted', 'rejected'] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`flex-1 py-3 rounded-full text-xs font-bold uppercase tracking-widest transition-all ${
              activeTab === tab ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-400'
            }`}
          >
            {tab}
          </button>
        ))}
      </div>

      {/* List */}
      <div className="space-y-4">
        {filteredApps.length > 0 ? (
          filteredApps.map((app) => {
            const gig = MOCK_GIGS.find(g => g.id === app.gigId);
            return (
              <div key={app.id} className="bg-white p-6 rounded-[32px] border border-gray-100 shadow-sm animate-in slide-in-from-bottom-2">
                <div className="flex justify-between items-start mb-4">
                  <h4 className="font-bold text-gray-900 text-lg leading-tight">{gig?.title}</h4>
                  <span className={`text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full ${
                    app.status === 'accepted' ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'
                  }`}>
                    {app.status}
                  </span>
                </div>
                <p className="text-xs text-gray-400 mb-6 flex items-center gap-2">
                   <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                   Applied on {app.appliedAt}
                </p>
                <div className="flex justify-between items-center">
                  <div className="flex -space-x-2">
                    {[1, 2, 3].map(i => (
                      <div key={i} className="w-8 h-8 rounded-full border-2 border-white bg-gray-200 overflow-hidden">
                        <img src={`https://i.pravatar.cc/50?u=${i}`} alt="user" />
                      </div>
                    ))}
                    <div className="w-8 h-8 rounded-full border-2 border-white bg-gray-100 flex items-center justify-center text-[8px] font-bold text-gray-400">+12</div>
                  </div>
                  <button className="text-sm font-bold text-amber-700 px-4 py-2 hover:bg-amber-50 rounded-full transition-colors">
                    View Case
                  </button>
                </div>
              </div>
            );
          })
        ) : (
          <div className="text-center py-20">
            <div className="bg-gray-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6">
               <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#d1d5db" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M16 16s-1.5-2-4-2-4 2-4 2"/><line x1="9" x2="9.01" y1="9" y2="9"/><line x1="15" x2="15.01" y1="9" y2="9"/></svg>
            </div>
            <p className="text-gray-400 font-medium">No applications found in this category.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default ApplicationsView;
