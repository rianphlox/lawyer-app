
export enum UserRole {
  JUNIOR_LAWYER = 'JUNIOR_LAWYER',
  SENIOR_LAWYER = 'SENIOR_LAWYER',
  CLIENT = 'CLIENT'
}

export interface Lawyer {
  id: string;
  name: string;
  specialty: string;
  location: string;
  rating: number;
  casesWon: number;
  pricePerHour: number;
  experienceYears: number;
  imageUrl: string;
  about: string;
}

export interface Gig {
  id: string;
  title: string;
  description: string;
  budget: number;
  clientName: string;
  type: string;
  status: 'open' | 'closed';
  postedAt: string;
}

export interface Message {
  id: string;
  senderId: string;
  text: string;
  timestamp: string;
  senderName: string;
}

export interface Application {
  id: string;
  gigId: string;
  lawyerId: string;
  status: 'pending' | 'accepted' | 'rejected';
  appliedAt: string;
}

export type AppView = 
  | 'landing' 
  | 'onboarding' 
  | 'auth' 
  | 'home' 
  | 'details' 
  | 'profile' 
  | 'post-gig' 
  | 'subscription' 
  | 'messages' 
  | 'earnings'
  | 'applications'
  | 'verification'
  | 'ai-chat'
  | 'settings'
  | 'legal';
