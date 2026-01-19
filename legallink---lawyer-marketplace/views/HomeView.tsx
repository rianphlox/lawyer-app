
import React, { useState, useMemo } from 'react';
import { Lawyer, UserRole, AppView, Gig } from '../types';
import { MOCK_LAWYERS, SPECIALTIES, MOCK_GIGS } from '../constants';

interface HomeViewProps {
  onSelectLawyer: (lawyer: Lawyer) => void;
  onNavigate: (view: AppView) => void;
  userRole: UserRole | null;
}

const HomeView: React.FC<HomeViewProps> = ({ onSelectLawyer, onNavigate, userRole }) => {
  const [activeSpecialty, setActiveSpecialty] = useState(SPECIALTIES[0]);
  const [searchQuery, setSearchQuery] = useState('');
  const isLawyer = userRole === UserRole.JUNIOR_LAWYER || userRole === UserRole.SENIOR_LAWYER;

  const filteredItems = useMemo(() => {
    if (isLawyer) {
      return MOCK_GIGS.filter(g => 
        (searchQuery === '' || g.title.toLowerCase().includes(searchQuery.toLowerCase()))
      );
    } else {
      return MOCK_LAWYERS.filter(l => 
        (searchQuery === '' || l.name.toLowerCase().includes(searchQuery.toLowerCase()))
      );
    }
  }, [isLawyer, searchQuery]);

  return (
    <div className="p-6 pb-32 h-full overflow-y-auto no-scrollbar bg-[#fdfaf5]">
      <header className="flex justify-between items-center mb-8 pt-6">
        <div>
          <p className="text-gray-400 text-sm">Welcome back</p>
          <h2 className="text-xl font-bold text-gray-900">
            {isLawyer ? 'Adv. Sanzi Malhotra' : 'John Doe (TechNova)'}
          </h2>
        </div>
        <div className="relative">
          <button className="bg-white p-3 rounded-full shadow-sm border border-gray-100 text-gray-900 active:scale-90 transition-all">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>
          </button>
          <span className="absolute top-1 right-1 w-3.5 h-3.5 bg-red-500 border-2 border-white rounded-full"></span>
        </div>
      </header>

      <section className="mb-8">
        <div className="flex flex-col gap-6 mb-6">
          <h1 className="text-3xl font-bold text-gray-900 leading-tight">
            {isLawyer ? 'Find your next \n high-value case' : 'Find your \n trusted lawyers'}
          </h1>
          
          <div className="relative flex items-center">
            <input 
              type="text" 
              placeholder={isLawyer ? "Search by case title..." : "Search by lawyer name..."}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-white border border-gray-200 rounded-[28px] pl-14 pr-6 py-4 shadow-sm focus:outline-none focus:ring-2 focus:ring-amber-700 transition-all"
            />
            <div className="absolute left-6 text-gray-400">
               <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
          </div>
        </div>
        
        {isLawyer && (
          <div className="grid grid-cols-2 gap-4 mb-4">
             <div onClick={() => onNavigate('earnings')} className="bg-white p-4 rounded-[32px] border border-gray-100 shadow-sm active:scale-95 transition-transform cursor-pointer group">
                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1 group-hover:text-amber-700 transition-colors">Total Earnings</p>
                <p className="text-xl font-bold text-gray-900">$12,450</p>
             </div>
             <div onClick={() => onNavigate('applications')} className="bg-white p-4 rounded-[32px] border border-gray-100 shadow-sm active:scale-95 transition-transform cursor-pointer group">
                <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1 group-hover:text-amber-700 transition-colors">Active Apps</p>
                <p className="text-xl font-bold text-amber-700">8</p>
             </div>
          </div>
        )}
      </section>

      <section className="flex gap-3 overflow-x-auto no-scrollbar mb-8 -mx-6 px-6">
        {SPECIALTIES.map((spec) => (
          <button
            key={spec}
            onClick={() => setActiveSpecialty(spec)}
            className={`px-6 py-3.5 rounded-full whitespace-nowrap text-sm font-semibold transition-all ${
              activeSpecialty === spec 
              ? 'bg-amber-700 text-white shadow-xl translate-y-[-2px]' 
              : 'bg-white text-gray-500 border border-gray-100 shadow-sm'
            }`}
          >
            {spec}
          </button>
        ))}
      </section>

      <section>
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-xl font-bold text-gray-900">{isLawyer ? 'Recommended Gigs' : 'Top Rated Lawyers'}</h3>
          <button className="text-sm font-bold text-amber-700">See all</button>
        </div>

        <div className="space-y-4">
          {isLawyer ? (
            filteredItems.map((gig: any) => (
              <div 
                key={gig.id} 
                className="bg-white rounded-[40px] p-6 shadow-sm border border-gray-100 hover:border-amber-200 transition-all cursor-pointer group relative overflow-hidden"
              >
                <div className="absolute top-0 right-0 w-24 h-24 bg-amber-50 rounded-bl-[100px] -z-0 opacity-40 group-hover:scale-150 transition-transform"></div>
                <div className="relative z-10">
                  <div className="flex justify-between items-start mb-4">
                    <span className="bg-amber-100 text-amber-800 text-[10px] font-bold uppercase tracking-widest px-3 py-1 rounded-full">
                      {gig.type}
                    </span>
                    <span className="text-xs text-gray-400 font-medium">{gig.postedAt}</span>
                  </div>
                  <h4 className="text-xl font-bold text-gray-900 mb-2 leading-tight">{gig.title}</h4>
                  <p className="text-sm text-gray-400 mb-6 line-clamp-2 leading-relaxed">
                    {gig.description}
                  </p>
                  <div className="flex justify-between items-center border-t border-gray-50 pt-4">
                    <div className="flex flex-col">
                      <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Budget</span>
                      <span className="text-lg font-bold text-gray-900">${gig.budget}</span>
                    </div>
                    <button className="bg-black text-white px-6 py-3 rounded-full text-sm font-bold shadow-lg active:scale-95 transition-all">
                      Apply Now
                    </button>
                  </div>
                </div>
              </div>
            ))
          ) : (
            filteredItems.map((lawyer: any) => (
              <div 
                key={lawyer.id} 
                onClick={() => onSelectLawyer(lawyer)}
                className="bg-white rounded-[40px] p-2 pr-4 shadow-sm border border-gray-100 flex gap-4 items-center relative active:scale-98 transition-all cursor-pointer group"
              >
                <div className="w-28 h-28 rounded-[32px] overflow-hidden flex-shrink-0">
                  <img src={lawyer.imageUrl} alt={lawyer.name} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                </div>
                <div className="flex-1 py-2">
                  <div className="flex justify-between items-start">
                    <h4 className="font-bold text-gray-900 text-lg leading-tight">{lawyer.name}</h4>
                    <div className="flex items-center gap-1">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="#fbbf24" stroke="none"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                      <span className="text-xs font-bold text-gray-600">({lawyer.rating})</span>
                    </div>
                  </div>
                  <p className="text-xs text-gray-400 mb-3 flex items-center gap-1">
                     <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
                    {lawyer.location}
                  </p>
                  <div className="bg-gray-100 rounded-full px-4 py-2 inline-block">
                    <p className="text-[10px] font-bold text-gray-500 uppercase tracking-widest">Case won {lawyer.casesWon}+</p>
                  </div>
                </div>
              </div>
            ))
          )}
          {filteredItems.length === 0 && (
             <div className="text-center py-20 bg-white rounded-[40px] border border-dashed border-gray-200">
               <p className="text-gray-400">No matches found for "{searchQuery}"</p>
             </div>
          )}
        </div>
      </section>
    </div>
  );
};

export default HomeView;
