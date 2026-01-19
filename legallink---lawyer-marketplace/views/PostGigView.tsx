
import React, { useState } from 'react';
import { AppView } from '../types';
import { getCaseRecommendations } from '../geminiService';
import { saveGigToFirestore } from '../firebaseService';

interface PostGigViewProps {
  onNavigate: (view: AppView) => void;
}

const PostGigView: React.FC<PostGigViewProps> = ({ onNavigate }) => {
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [aiSuggestion, setAiSuggestion] = useState<{specialty: string, urgency: string} | null>(null);

  const handleAnalyze = async () => {
    if (!description) return;
    setLoading(true);
    const suggestion = await getCaseRecommendations(description);
    setAiSuggestion(suggestion);
    setLoading(false);
  };

  const handlePublish = async () => {
    setPublishing(true);
    await saveGigToFirestore({ description, specialty: aiSuggestion?.specialty });
    setPublishing(false);
    onNavigate('home');
  };

  return (
    <div className="p-8 pb-32 h-screen overflow-y-auto no-scrollbar bg-[#fdfaf5]">
      <div className="flex justify-between items-center mb-8 pt-6">
         <h1 className="text-2xl font-bold text-gray-900">Post a New Case</h1>
         <div className="w-10 h-10 bg-amber-100 rounded-2xl flex items-center justify-center">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#b45309" strokeWidth="2.5"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
         </div>
      </div>
      
      <div className="space-y-6">
        <div>
          <label className="block text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2">Case Title</label>
          <input 
            type="text" 
            placeholder="e.g. Property Dispute in Brooklyn"
            className="w-full p-4 rounded-3xl border border-gray-100 focus:outline-none focus:ring-2 focus:ring-amber-700 bg-white shadow-sm"
          />
        </div>

        <div>
          <label className="block text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2">Detailed Description</label>
          <textarea 
            rows={5}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Tell us what happened. Our Gemini AI will help match you with the right specialty."
            className="w-full p-6 rounded-[32px] border border-gray-100 focus:outline-none focus:ring-2 focus:ring-amber-700 bg-white shadow-sm resize-none"
          />
        </div>

        <button 
          onClick={handleAnalyze}
          disabled={loading || !description}
          className="w-full bg-amber-50 text-amber-800 py-4 rounded-[32px] font-bold flex items-center justify-center gap-2 hover:bg-amber-100 transition-colors disabled:opacity-50 border border-amber-100"
        >
          {loading ? (
             <div className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 bg-amber-700 rounded-full animate-bounce"></span>
                <span className="w-1.5 h-1.5 bg-amber-700 rounded-full animate-bounce [animation-delay:0.2s]"></span>
                <span className="w-1.5 h-1.5 bg-amber-700 rounded-full animate-bounce [animation-delay:0.4s]"></span>
             </div>
          ) : (
            <>
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/></svg>
              AI Matchmaker
            </>
          )}
        </button>

        {aiSuggestion && (
          <div className="bg-white p-6 rounded-[40px] shadow-sm border border-amber-100 flex items-center gap-4 animate-in fade-in slide-in-from-bottom-2">
            <div className="bg-amber-100 p-4 rounded-full">
               <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#b45309" strokeWidth="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            </div>
            <div>
              <p className="text-[10px] font-bold text-amber-700 uppercase tracking-widest">Gemini Suggestion</p>
              <h4 className="font-bold text-gray-900 text-lg">{aiSuggestion.specialty}</h4>
              <p className="text-xs text-gray-500">Urgency: <span className="text-red-500 font-bold">{aiSuggestion.urgency}</span></p>
            </div>
          </div>
        )}

        <div className="pt-4">
          <label className="block text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2">Estimated Budget ($)</label>
          <input 
            type="number" 
            placeholder="5000"
            className="w-full p-4 rounded-3xl border border-gray-100 focus:outline-none focus:ring-2 focus:ring-amber-700 bg-white shadow-sm"
          />
        </div>

        <button 
          onClick={handlePublish}
          disabled={publishing}
          className="w-full bg-black text-white py-5 rounded-full font-bold shadow-xl active:scale-95 transition-transform flex items-center justify-center gap-3"
        >
          {publishing ? 'Publishing to Firestore...' : 'Publish Gig'}
          {!publishing && <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/></svg>}
        </button>
      </div>
    </div>
  );
};

export default PostGigView;
