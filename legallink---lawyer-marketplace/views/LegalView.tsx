
import React from 'react';

interface LegalViewProps {
  onBack: () => void;
}

const LegalView: React.FC<LegalViewProps> = ({ onBack }) => {
  return (
    <div className="h-full bg-white flex flex-col p-6 animate-in slide-in-from-right-10 duration-300 overflow-y-auto">
      <header className="flex items-center gap-4 mb-10 pt-6">
        <button onClick={onBack} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 className="text-2xl font-bold text-gray-900">Legal Documents</h1>
      </header>

      <article className="prose prose-sm text-gray-500 space-y-6">
        <section>
          <h2 className="text-lg font-bold text-gray-900">1. Privacy Policy</h2>
          <p>LegalLink respects your privacy. We collect data necessary for lawyer verification and gig matching. Your documents are encrypted and stored in secure AWS regions.</p>
        </section>
        <section>
          <h2 className="text-lg font-bold text-gray-900">2. Terms of Service</h2>
          <p>By using LegalLink, you agree that you are either a verified legal professional or a legitimate client. Fraudulent behavior will result in immediate permanent suspension.</p>
        </section>
        <section>
          <h2 className="text-lg font-bold text-gray-900">3. Data Retention</h2>
          <p>In accordance with the GDPR and App Store policies, you may request full deletion of your data at any time via the Settings menu.</p>
        </section>
      </article>
    </div>
  );
};

export default LegalView;
