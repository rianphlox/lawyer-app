
import React, { useState } from 'react';

interface OnboardingViewProps {
  onComplete: () => void;
}

const steps = [
  {
    title: "The Smart Way to Hire Legal Pros",
    desc: "AI-powered matching finds the perfect specialist for your unique case in seconds.",
    img: "assets/onboard-step1.jpg"
  },
  {
    title: "Gig Marketplace for Modern Lawyers",
    desc: "Browse high-value cases, manage your applications, and grow your practice on your terms.",
    img: "assets/onboard-step2.jpg"
  },
  {
    title: "Tiered Excellence",
    desc: "From Junior advocates to Senior partners, our marketplace caters to all levels of professional legal service.",
    img: "assets/onboard-step3.jpg"
  }
];

const OnboardingView: React.FC<OnboardingViewProps> = ({ onComplete }) => {
  const [currentStep, setCurrentStep] = useState(0);

  const next = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      onComplete();
    }
  };

  return (
    <div className="h-full bg-white flex flex-col p-8 pt-20 animate-in fade-in duration-500">
      <div className="flex-1">
        <div className="w-full h-80 rounded-[48px] overflow-hidden mb-12 shadow-2xl rotate-2 bg-gray-100">
          <img 
            src={steps[currentStep].img} 
            className="w-full h-full object-cover" 
            alt="Onboarding" 
            onError={(e) => {
              const fallback = [
                'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&q=80&w=400',
                'https://images.unsplash.com/photo-1505664194779-8beaceb93744?auto=format&fit=crop&q=80&w=400',
                'https://images.unsplash.com/photo-1593115057322-e94b77572f20?auto=format&fit=crop&q=80&w=400'
              ];
              (e.target as HTMLImageElement).src = fallback[currentStep];
            }}
          />
        </div>
        <h1 className="text-3xl font-bold text-gray-900 mb-4 leading-tight">{steps[currentStep].title}</h1>
        <p className="text-gray-400 leading-relaxed text-lg">{steps[currentStep].desc}</p>
      </div>

      <div className="pb-8">
        <div className="flex gap-2 mb-10">
          {steps.map((_, i) => (
            <div key={i} className={`h-1.5 rounded-full transition-all duration-300 ${i === currentStep ? 'w-12 bg-amber-700' : 'w-4 bg-gray-200'}`}></div>
          ))}
        </div>
        <button 
          onClick={next}
          className="w-full bg-black text-white py-5 rounded-full font-bold flex items-center justify-between px-8 shadow-xl active:scale-95 transition-all"
        >
          <span>{currentStep === steps.length - 1 ? 'Get Started' : 'Next'}</span>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
        </button>
      </div>
    </div>
  );
};

export default OnboardingView;
