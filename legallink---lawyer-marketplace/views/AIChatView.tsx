
import React, { useState, useRef, useEffect } from 'react';
import { askLegalAssistant } from '../geminiService';

interface AIChatViewProps {
  onBack: () => void;
}

const AIChatView: React.FC<AIChatViewProps> = ({ onBack }) => {
  const [messages, setMessages] = useState<{ role: 'user' | 'bot', text: string }[]>([
    { role: 'bot', text: 'Hello! I am your LegalLink assistant. How can I help you today? I can explain legal terms, app features, or general legal processes.' }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    scrollRef.current?.scrollTo(0, scrollRef.current.scrollHeight);
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim() || loading) return;
    const userMsg = input;
    setInput('');
    setMessages(prev => [...prev, { role: 'user', text: userMsg }]);
    setLoading(true);

    const botResp = await askLegalAssistant(userMsg);
    setMessages(prev => [...prev, { role: 'bot', text: botResp || "I'm having trouble thinking. Try again later." }]);
    setLoading(false);
  };

  return (
    <div className="h-full bg-white flex flex-col animate-in slide-in-from-right-10 duration-300">
      <header className="p-6 border-b border-gray-100 flex items-center gap-4 bg-[#fdfaf5]">
        <button onClick={onBack} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div>
          <h2 className="font-bold text-gray-900">LegalLink AI</h2>
          <div className="flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 bg-green-500 rounded-full animate-pulse"></span>
            <span className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">Always Online</span>
          </div>
        </div>
      </header>

      <div ref={scrollRef} className="flex-1 overflow-y-auto p-6 space-y-4 no-scrollbar">
        {messages.map((m, i) => (
          <div key={i} className={`flex ${m.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-[85%] p-4 rounded-[24px] ${
              m.role === 'user' 
              ? 'bg-amber-700 text-white rounded-tr-none' 
              : 'bg-gray-100 text-gray-800 rounded-tl-none shadow-sm border border-gray-50'
            }`}>
              <p className="text-sm leading-relaxed">{m.text}</p>
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start">
            <div className="bg-gray-100 p-4 rounded-[24px] rounded-tl-none flex gap-1 items-center">
              <span className="w-1.5 h-1.5 bg-gray-300 rounded-full animate-bounce"></span>
              <span className="w-1.5 h-1.5 bg-gray-300 rounded-full animate-bounce [animation-delay:0.2s]"></span>
              <span className="w-1.5 h-1.5 bg-gray-300 rounded-full animate-bounce [animation-delay:0.4s]"></span>
            </div>
          </div>
        )}
      </div>

      <div className="p-6 bg-[#fdfaf5] border-t border-gray-100">
        <div className="flex gap-2">
          <input 
            type="text" 
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            placeholder="Type your question..."
            className="flex-1 bg-white border border-gray-200 rounded-full px-6 py-4 focus:outline-none focus:ring-2 focus:ring-amber-700 shadow-sm"
          />
          <button 
            onClick={handleSend}
            disabled={loading}
            className="w-14 h-14 bg-black text-white rounded-full flex items-center justify-center shadow-lg active:scale-90 transition-transform disabled:opacity-50"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="m5 12 14-7-7 14-2-7-7-2Z"/></svg>
          </button>
        </div>
        <p className="text-[10px] text-gray-400 mt-4 text-center">AI generated responses. Not a substitute for legal advice.</p>
      </div>
    </div>
  );
};

export default AIChatView;
