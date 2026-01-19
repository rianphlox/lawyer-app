
import React, { useState } from 'react';
import { uploadVerificationDoc } from '../firebaseService';

interface VerificationViewProps {
  onComplete: () => void;
}

const VerificationView: React.FC<VerificationViewProps> = ({ onComplete }) => {
  const [step, setStep] = useState(1);
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);

  const handleUpload = async () => {
    setUploading(true);
    // Simulate upload progress
    const interval = setInterval(() => {
      setProgress(prev => {
        if (prev >= 90) {
          clearInterval(interval);
          return 95;
        }
        return prev + 10;
      });
    }, 200);

    // Call our simulated Firebase service
    await uploadVerificationDoc(new File([], "license.pdf"), "user_123");
    
    clearInterval(interval);
    setProgress(100);
    
    setTimeout(() => {
      setUploading(false);
      setProgress(0);
      if (step < 2) {
        setStep(2);
      } else {
        onComplete();
      }
    }, 500);
  };

  return (
    <div className="h-full bg-white p-8 pt-20 flex flex-col animate-in fade-in duration-500">
      <div className="flex-1">
        <div className="flex justify-between items-center mb-2">
          <h1 className="text-3xl font-bold text-gray-900">Professional Verification</h1>
          <span className="text-xs font-bold text-amber-700 bg-amber-50 px-3 py-1 rounded-full uppercase">Step {step}/2</span>
        </div>
        <p className="text-gray-400 mb-10">LegalLink requires secure identity verification via Firebase Storage.</p>
        
        <div className="space-y-6">
          <h3 className="font-bold text-lg text-gray-800">
            {step === 1 ? 'Upload Bar License' : 'Upload Government ID'}
          </h3>
          
          <div 
            onClick={!uploading ? handleUpload : undefined}
            className={`border-2 border-dashed rounded-[40px] p-12 flex flex-col items-center justify-center transition-all cursor-pointer group ${
              uploading ? 'border-amber-500 bg-amber-50/30' : 'border-gray-200 bg-gray-50 hover:bg-amber-50 hover:border-amber-200'
            }`}
          >
            {uploading ? (
              <div className="w-full flex flex-col items-center">
                <div className="relative w-20 h-20 mb-4">
                  <svg className="w-full h-full" viewBox="0 0 36 36">
                    <path className="text-gray-200" strokeWidth="3" stroke="currentColor" fill="none" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
                    <path className="text-amber-700 transition-all duration-300" strokeWidth="3" strokeDasharray={`${progress}, 100`} strokeLinecap="round" stroke="currentColor" fill="none" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
                  </svg>
                  <div className="absolute inset-0 flex items-center justify-center text-xs font-bold text-amber-900">{progress}%</div>
                </div>
                <p className="font-bold text-amber-900">Uploading to Storage...</p>
              </div>
            ) : (
              <>
                <div className="w-20 h-20 bg-white rounded-3xl flex items-center justify-center shadow-sm mb-6 group-hover:scale-110 transition-transform">
                  {step === 1 ? (
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#b45309" strokeWidth="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" x2="12" y1="3" y2="15"/></svg>
                  ) : (
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#b45309" strokeWidth="2"><rect width="18" height="12" x="3" y="6" rx="2"/><circle cx="9" cy="12" r="2"/><path d="M15 12h2"/></svg>
                  )}
                </div>
                <p className="font-bold text-gray-900">Click to Select File</p>
                <p className="text-[10px] text-gray-400 mt-2 uppercase tracking-widest font-bold">PDF, PNG, JPG (Max 10MB)</p>
              </>
            )}
          </div>
          
          <div className="flex items-center gap-3 p-4 bg-blue-50 rounded-2xl border border-blue-100">
             <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1e40af" strokeWidth="2"><circle cx="12" cy="12" r="10"/><line x1="12" x2="12" y1="16" y2="12"/><line x1="12" x2="12.01" y1="8" y2="8"/></svg>
             <p className="text-xs text-blue-800 leading-tight">Your data is encrypted end-to-end and stored in a secure private bucket.</p>
          </div>
        </div>
      </div>

      <div className="pb-8">
        <button 
          onClick={handleUpload}
          disabled={uploading}
          className="w-full bg-black text-white py-5 rounded-full font-bold flex items-center justify-center shadow-xl active:scale-95 transition-all disabled:opacity-50"
        >
          {uploading ? 'Processing Document...' : 'Verify and Continue'}
        </button>
      </div>
    </div>
  );
};

export default VerificationView;
