
import React from 'react';
import { UserRole, AppView } from '../types';

interface SubscriptionViewProps {
  onNavigate: (view: AppView) => void;
  userRole: UserRole | null;
}

const SubscriptionView: React.FC<SubscriptionViewProps> = ({ onNavigate, userRole }) => {
  const isJunior = userRole === UserRole.JUNIOR_LAWYER;

  return (
    <div className="p-8 pb-32 h-screen overflow-y-auto bg-[#fdfaf5]">
      <h1 className="text-2xl font-bold mb-2">Subscription</h1>
      <p className="text-gray-400 text-sm mb-8">Choose a plan that fits your career stage.</p>

      {isJunior && (
        <div className="bg-green-50 border border-green-200 p-6 rounded-[32px] mb-8 flex items-start gap-4">
           <div className="bg-green-500 p-2 rounded-full text-white">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"/><path d="m9 12 2 2 4-4"/></svg>
           </div>
           <div>
              <h3 className="font-bold text-green-900">Junior Lawyer Status</h3>
              <p className="text-sm text-green-700 leading-snug">You are currently in your <span className="font-bold">free 6-month trial</span>. 45 days remaining.</p>
           </div>
        </div>
      )}

      <div className="space-y-6">
        {/* Free Plan */}
        <div className={`p-6 rounded-[40px] border-2 transition-all ${isJunior ? 'border-amber-700 bg-white shadow-xl scale-[1.02]' : 'border-gray-100 bg-white'}`}>
           <div className="flex justify-between items-center mb-4">
              <h4 className="font-bold text-gray-900 text-lg">Free Trial</h4>
              <span className="bg-gray-100 text-gray-600 px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest">Junior</span>
           </div>
           <p className="text-3xl font-bold mb-6">$0 <span className="text-sm font-normal text-gray-400">/6 months</span></p>
           <ul className="space-y-3 mb-8">
              <li className="flex items-center gap-2 text-sm text-gray-500">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Apply to 5 gigs/day
              </li>
              <li className="flex items-center gap-2 text-sm text-gray-500">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Basic Profile Visibility
              </li>
           </ul>
           <button className={`w-full py-4 rounded-full font-bold transition-all ${isJunior ? 'bg-amber-700 text-white' : 'bg-gray-100 text-gray-400 cursor-not-allowed'}`}>
             {isJunior ? 'Active Plan' : 'Not Eligible'}
           </button>
        </div>

        {/* Pro Plan */}
        <div className={`p-6 rounded-[40px] border-2 transition-all ${!isJunior ? 'border-amber-700 bg-white shadow-xl scale-[1.02]' : 'border-gray-100 bg-white'}`}>
           <div className="flex justify-between items-center mb-4">
              <h4 className="font-bold text-gray-900 text-lg">Senior Pro</h4>
              <span className="bg-black text-white px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest">Popular</span>
           </div>
           <p className="text-3xl font-bold mb-6">$49 <span className="text-sm font-normal text-gray-400">/monthly</span></p>
           <ul className="space-y-3 mb-8">
              <li className="flex items-center gap-2 text-sm text-gray-500">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Unlimited applications
              </li>
              <li className="flex items-center gap-2 text-sm text-gray-500">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Premium profile verification
              </li>
              <li className="flex items-center gap-2 text-sm text-gray-500">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Direct Client Messaging
              </li>
           </ul>
           <button className={`w-full py-4 rounded-full font-bold transition-all ${!isJunior ? 'bg-amber-700 text-white' : 'bg-black text-white hover:bg-gray-800'}`}>
             {!isJunior ? 'Active Plan' : 'Upgrade Now'}
           </button>
        </div>
      </div>
    </div>
  );
};

export default SubscriptionView;
