
import React, { useState } from 'react';
import { AppView, Message } from '../types';
import { MOCK_MESSAGES } from '../constants';

interface MessagesViewProps {
  onNavigate: (view: AppView) => void;
}

const MessagesView: React.FC<MessagesViewProps> = ({ onNavigate }) => {
  const [selectedChat, setSelectedChat] = useState<string | null>(null);

  return (
    <div className="h-full bg-[#fdfaf5] flex flex-col p-6 pb-32 overflow-hidden">
      <header className="mb-8 pt-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Messages</h1>
        <p className="text-gray-400">Manage your active conversations.</p>
      </header>

      {/* Chat List */}
      <div className="flex-1 overflow-y-auto no-scrollbar space-y-4">
        {[1, 2, 3].map((i) => (
          <div 
            key={i}
            className="bg-white p-4 rounded-[32px] border border-gray-100 shadow-sm flex gap-4 items-center active:scale-98 transition-all cursor-pointer relative"
          >
            <div className="w-16 h-16 rounded-full overflow-hidden flex-shrink-0 relative bg-gray-50">
               <img 
                src={`assets/avatar-${i}.jpg`} 
                className="w-full h-full object-cover" 
                alt="User" 
                onError={(e) => (e.target as HTMLImageElement).src = `https://i.pravatar.cc/150?u=${i}`}
               />
               <div className="absolute bottom-0 right-0 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></div>
            </div>
            <div className="flex-1">
              <div className="flex justify-between items-center mb-1">
                <h4 className="font-bold text-gray-900">{i === 1 ? 'TechNova Solutions' : i === 2 ? 'Skyline Props' : 'Robert Adler'}</h4>
                <span className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">10:30 AM</span>
              </div>
              <p className="text-sm text-gray-400 line-clamp-1 leading-relaxed">
                {i === 1 ? "Hello, let's proceed with the contract drafting..." : "Can we discuss the budget for this property case?"}
              </p>
            </div>
            {i === 1 && (
               <div className="absolute top-4 right-4 bg-amber-700 text-white w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold">2</div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default MessagesView;
