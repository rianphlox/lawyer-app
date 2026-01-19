
import React, { useState } from 'react';
import { UserRole } from '../types';

interface AuthViewProps {
  onAuthSuccess: (role: UserRole) => void;
}

const AuthView: React.FC<AuthViewProps> = ({ onAuthSuccess }) => {
  const [isLogin, setIsLogin] = useState(true);

  return (
    <div className="h-full bg-[#fdfaf5] p-8 pt-20 overflow-y-auto no-scrollbar">
      <div className="mb-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-2">{isLogin ? 'Welcome Back' : 'Create Account'}</h1>
        <p className="text-gray-400">Join the elite network of legal professionals.</p>
      </div>

      <div className="space-y-6">
        <div className="space-y-4">
          <input type="email" placeholder="Email Address" className="w-full p-4 rounded-3xl border border-gray-100 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-amber-700 transition-all" />
          <input type="password" placeholder="Password" className="w-full p-4 rounded-3xl border border-gray-100 bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-amber-700 transition-all" />
        </div>

        {!isLogin && (
           <div className="grid grid-cols-2 gap-4">
              <button 
                onClick={() => onAuthSuccess(UserRole.JUNIOR_LAWYER)}
                className="p-6 rounded-[32px] border border-gray-100 bg-white flex flex-col items-center gap-3 hover:border-amber-700 transition-all group shadow-sm"
              >
                <div className="p-3 rounded-full bg-gray-50 group-hover:bg-amber-100 transition-colors">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-gray-600 group-hover:text-amber-700"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                </div>
                <span className="text-xs font-bold text-gray-500 uppercase tracking-widest">I'm a Lawyer</span>
              </button>
              <button 
                onClick={() => onAuthSuccess(UserRole.CLIENT)}
                className="p-6 rounded-[32px] border border-gray-100 bg-white flex flex-col items-center gap-3 hover:border-amber-700 transition-all group shadow-sm"
              >
                <div className="p-3 rounded-full bg-gray-50 group-hover:bg-amber-100 transition-colors">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-gray-600 group-hover:text-amber-700"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </div>
                <span className="text-xs font-bold text-gray-500 uppercase tracking-widest">I'm a Client</span>
              </button>
           </div>
        )}

        {isLogin ? (
          <button 
            onClick={() => onAuthSuccess(UserRole.JUNIOR_LAWYER)}
            className="w-full bg-black text-white py-5 rounded-full font-bold shadow-xl active:scale-95 transition-all"
          >
            Login
          </button>
        ) : (
          <p className="text-center text-xs text-gray-400 px-8">By signing up, you agree to our Terms of Service and Privacy Policy.</p>
        )}

        <div className="text-center">
          <button onClick={() => setIsLogin(!isLogin)} className="text-sm font-bold text-amber-700">
            {isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In"}
          </button>
        </div>

        <div className="pt-10 flex items-center gap-4">
          <div className="h-px bg-gray-200 flex-1"></div>
          <span className="text-xs font-bold text-gray-400 uppercase tracking-widest">Or continue with</span>
          <div className="h-px bg-gray-200 flex-1"></div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <button className="flex items-center justify-center gap-2 p-4 rounded-3xl bg-white border border-gray-100 shadow-sm font-medium">
             <img src="assets/google-logo.png" className="w-5 h-5" alt="google" onError={(e) => (e.target as HTMLImageElement).src = 'https://www.google.com/favicon.ico'} /> Google
          </button>
          <button className="flex items-center justify-center gap-2 p-4 rounded-3xl bg-white border border-gray-100 shadow-sm font-medium">
             <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="black"><path d="M12.152 6.896c-.948 0-2.415-1.078-3.96-1.04-2.04.027-3.91 1.183-4.961 3.014-2.117 3.675-.546 9.103 1.519 12.09 1.013 1.454 2.208 3.09 3.792 3.039 1.52-.065 2.09-.987 3.935-.987 1.831 0 2.35.987 3.96.948 1.637-.026 2.676-1.48 3.676-2.948 1.156-1.688 1.636-3.325 1.662-3.415-.039-.013-3.182-1.221-3.22-4.857-.026-3.04 2.48-4.494 2.597-4.559-1.429-2.09-3.623-2.324-4.39-2.376-2-.156-3.675 1.09-4.61 1.09zM15.53 3.83c.843-1.012 1.4-2.427 1.245-3.83-1.207.052-2.662.805-3.532 1.818-.78.896-1.454 2.338-1.273 3.714 1.338.104 2.715-.688 3.559-1.702z"/></svg> Apple
          </button>
        </div>
      </div>
    </div>
  );
};

export default AuthView;
