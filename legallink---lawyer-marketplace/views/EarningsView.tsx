
import React from 'react';
import { AppView } from '../types';

interface EarningsViewProps {
  onNavigate: (view: AppView) => void;
}

const EarningsView: React.FC<EarningsViewProps> = ({ onNavigate }) => {
  return (
    <div className="h-full bg-[#fdfaf5] p-6 pb-32 overflow-y-auto no-scrollbar">
      <header className="mb-8 pt-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Earnings</h1>
        <p className="text-gray-400 text-sm">Track your financial growth.</p>
      </header>

      {/* Wallet Card */}
      <div className="bg-black rounded-[48px] p-8 text-white mb-8 shadow-2xl relative overflow-hidden">
        <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"></div>
        <div className="relative z-10">
          <p className="text-white/60 text-xs font-bold uppercase tracking-widest mb-2">Available Balance</p>
          <h2 className="text-4xl font-bold mb-10">$8,240.50</h2>
          
          <div className="flex gap-4">
            <button className="flex-1 bg-amber-700 py-4 rounded-full font-bold shadow-lg shadow-amber-900/40 active:scale-95 transition-all">
              Withdraw
            </button>
            <button className="p-4 bg-white/20 rounded-full hover:bg-white/30 transition-colors">
               <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12V7H5a2 2 0 0 1 0-4h14v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-5"/><path d="M18 12a2 2 0 0 0 0 4h4v-4Z"/></svg>
            </button>
          </div>
        </div>
      </div>

      {/* Stats Breakdown */}
      <div className="grid grid-cols-2 gap-4 mb-8">
        <div className="bg-white p-6 rounded-[32px] border border-gray-100 shadow-sm">
           <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">This Month</p>
           <p className="text-xl font-bold text-gray-900">+$2,150</p>
           <p className="text-[10px] text-green-500 font-bold mt-1">+12% vs last month</p>
        </div>
        <div className="bg-white p-6 rounded-[32px] border border-gray-100 shadow-sm">
           <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">Total Cases</p>
           <p className="text-xl font-bold text-gray-900">42</p>
           <p className="text-[10px] text-gray-400 font-medium mt-1">Completion rate 98%</p>
        </div>
      </div>

      {/* Transaction History */}
      <section>
        <h3 className="text-lg font-bold text-gray-900 mb-6">Recent Transactions</h3>
        <div className="space-y-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="flex items-center justify-between p-4 bg-white rounded-3xl border border-gray-50 shadow-sm">
              <div className="flex items-center gap-4">
                <div className={`p-3 rounded-full ${i % 2 === 0 ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}`}>
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                    {i % 2 === 0 ? <path d="m16 4 3 3-3 3M5 20l-3-3 3-3M2 17h12M22 7H10"/> : <path d="m12 19-7-7 7-7M5 12h14"/>}
                  </svg>
                </div>
                <div>
                  <h4 className="font-bold text-gray-900 text-sm">{i % 2 === 0 ? 'Client Payment' : 'Case Milestone'}</h4>
                  <p className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">Oct {10 + i}, 2023</p>
                </div>
              </div>
              <span className={`font-bold ${i % 2 === 0 ? 'text-green-600' : 'text-gray-900'}`}>
                {i % 2 === 0 ? '+$1,200.00' : '+$450.00'}
              </span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default EarningsView;
