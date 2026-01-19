
import React from 'react';

interface LandingViewProps {
  onStart: () => void;
}

const LandingView: React.FC<LandingViewProps> = ({ onStart }) => {
  return (
    <div className="relative h-screen w-full bg-[#fdfaf5] overflow-hidden">
      {/* Hero Image from Assets */}
      <div className="absolute inset-0">
        <img 
          src="assets/landing-hero.jpg" 
          alt="LegalLink Hero"
          className="h-[75%] w-full object-cover object-center"
          onError={(e) => {
            // Fallback for preview environments
            (e.target as HTMLImageElement).src = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=800';
          }}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-[#fdfaf5] via-transparent to-transparent"></div>
      </div>

      <div className="absolute bottom-0 left-0 right-0 p-8 flex flex-col items-center">
        <h1 className="text-4xl font-bold text-gray-900 leading-tight mb-8">
          Discover the <br /> 
          <span className="text-amber-700">Right Lawyer</span> <br /> 
          for You
        </h1>

        <button 
          onClick={onStart}
          className="group relative w-full bg-black text-white py-5 px-8 rounded-full flex items-center justify-between transition-transform active:scale-95 shadow-xl"
        >
          <div className="flex items-center gap-4">
            <div className="bg-white/20 p-2 rounded-full">
               <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M2 16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2H4c-1.1 0-2 .9-2 2v8Z"/><path d="M12 18v4"/><path d="M8 22h8"/><path d="m9 6 3-3 3 3"/></svg>
            </div>
            <span className="text-lg font-semibold tracking-wide">Get started</span>
          </div>
          <div className="flex gap-1 opacity-60">
            <span>&rsaquo;</span>
            <span>&rsaquo;</span>
            <span>&rsaquo;</span>
          </div>
        </button>
      </div>
    </div>
  );
};

export default LandingView;
