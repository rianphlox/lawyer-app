
import React, { useState } from 'react';
import { Lawyer } from '../types';
import { generateProposal } from '../geminiService';

interface DetailsViewProps {
  lawyer: Lawyer;
  onBack: () => void;
}

const DetailsView: React.FC<DetailsViewProps> = ({ lawyer, onBack }) => {
  const [proposal, setProposal] = useState<string | null>(null);
  const [loadingProposal, setLoadingProposal] = useState(false);

  const handleDraftAI = async () => {
    setLoadingProposal(true);
    const result = await generateProposal(
      lawyer.name, 
      lawyer.about, 
      "Generic Property Dispute", // Mock context for demo
      "Client is looking for a specialist to handle a copyright infringement case involving architectural plans."
    );
    setProposal(result || "Error generating proposal.");
    setLoadingProposal(false);
  };

  return (
    <div className="relative h-screen bg-[#fdfaf5] overflow-y-auto no-scrollbar pb-32 animate-in slide-in-from-bottom-5 duration-300">
      {/* Top Header Navigation */}
      <div className="absolute top-6 left-6 right-6 flex justify-between items-center z-10">
        <button onClick={onBack} className="bg-white/80 backdrop-blur p-3 rounded-full shadow-sm hover:bg-white transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <button className="bg-white/80 backdrop-blur p-3 rounded-full shadow-sm hover:bg-white transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg>
        </button>
      </div>

      {/* Hero Profile Image */}
      <div className="relative h-[60%] w-full">
        <img src={lawyer.imageUrl} alt={lawyer.name} className="w-full h-full object-cover object-center" />
        <div className="absolute inset-0 bg-gradient-to-t from-[#fdfaf5] via-transparent to-transparent"></div>
        
        <div className="absolute bottom-16 left-6 pr-6">
           <span className="bg-amber-700 text-white text-[10px] font-bold px-3 py-1 rounded-full uppercase tracking-widest mb-2 inline-block">Verified Professional</span>
           <h1 className="text-3xl font-bold text-gray-900 leading-tight mb-1">{lawyer.name}</h1>
           <p className="text-gray-600 font-medium">{lawyer.specialty}</p>
        </div>
      </div>

      {/* Content Section */}
      <div className="relative -mt-10 bg-[#fdfaf5] rounded-t-[48px] p-8">
        
        <div className="bg-white rounded-[32px] p-5 shadow-sm border border-gray-100 flex justify-between items-center mb-8">
          <div>
            <h3 className="font-bold text-gray-900 text-xl">${lawyer.pricePerHour} <span className="text-sm font-normal text-gray-400">/hour</span></h3>
          </div>
          <div className="flex gap-2">
            <button className="bg-gray-100 p-3 rounded-full text-gray-600">
               <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            </button>
            <button className="bg-black p-3 rounded-full text-white">
               <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            </button>
          </div>
        </div>

        {/* AI Proposal Section */}
        <section className="mb-8">
           <div className="flex justify-between items-center mb-4">
              <h4 className="font-bold text-gray-900">AI Proposal Draft</h4>
              <button 
                onClick={handleDraftAI}
                disabled={loadingProposal}
                className="text-xs font-bold text-amber-700 bg-amber-50 px-4 py-2 rounded-full hover:bg-amber-100 transition-colors disabled:opacity-50"
              >
                {loadingProposal ? 'Drafting...' : 'Generate with Gemini'}
              </button>
           </div>
           
           {proposal && (
             <div className="bg-white p-6 rounded-[32px] border border-amber-100 shadow-sm animate-in fade-in zoom-in-95">
                <p className="text-sm text-gray-600 leading-relaxed italic">"{proposal}"</p>
                <button className="mt-4 w-full border border-gray-100 text-gray-400 text-xs font-bold py-2 rounded-xl">Copy Proposal</button>
             </div>
           )}
        </section>

        <section className="mb-8">
           <h4 className="font-bold text-gray-900 mb-2">About Lawyer</h4>
           <p className="text-sm text-gray-400 leading-relaxed">{lawyer.about}</p>
        </section>

        <button className="w-full bg-black text-white py-5 px-8 rounded-full flex items-center justify-between transition-transform active:scale-95 shadow-xl">
          <span className="text-lg font-semibold tracking-wide">Book Appointment</span>
          <div className="flex gap-1 opacity-60">
            <span>&rsaquo;</span><span>&rsaquo;</span><span>&rsaquo;</span>
          </div>
        </button>
      </div>
    </div>
  );
};

export default DetailsView;
