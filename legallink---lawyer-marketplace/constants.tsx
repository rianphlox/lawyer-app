
import { Lawyer, Gig, Message, Application } from './types';

export const MOCK_LAWYERS: Lawyer[] = [
  {
    id: 'l1',
    name: 'Tush Yamlash',
    specialty: 'Crime Lawyer',
    location: 'New York City',
    rating: 4.9,
    casesWon: 320,
    pricePerHour: 250,
    experienceYears: 12,
    imageUrl: 'assets/lawyer-tush.jpg',
    about: 'Tush Yamlash is a highly skilled criminal defense lawyer known for her strong courtroom presence and strategic approach. With over a decade of experience in criminal law, she has successfully represented clients in complex cases.'
  },
  {
    id: 'l2',
    name: 'Robert Adler',
    specialty: 'Family Lawyer',
    location: 'Chicago, IL',
    rating: 4.8,
    casesWon: 410,
    pricePerHour: 180,
    experienceYears: 15,
    imageUrl: 'assets/lawyer-robert.jpg',
    about: 'Robert specializes in high-stakes family law disputes, focusing on mediation and positive resolution for all parties involved.'
  },
  {
    id: 'l3',
    name: 'Sarah Chen',
    specialty: 'Corporate Lawyer',
    location: 'San Francisco, CA',
    rating: 5.0,
    casesWon: 150,
    pricePerHour: 350,
    experienceYears: 8,
    imageUrl: 'assets/lawyer-sarah.jpg',
    about: 'Sarah provides top-tier corporate legal advice for tech startups and Fortune 500 companies alike.'
  }
];

export const MOCK_GIGS: Gig[] = [
  {
    id: 'g1',
    title: 'Intellectual Property Dispute',
    description: 'Need assistance with a copyright infringement case involving software source code.',
    budget: 5000,
    clientName: 'TechNova Solutions',
    type: 'Corporate',
    status: 'open',
    postedAt: '2 hours ago'
  },
  {
    id: 'g2',
    title: 'DUI Defense Case',
    description: 'Looking for a junior lawyer to handle initial court appearances for a simple DUI charge.',
    budget: 1200,
    clientName: 'John Doe',
    type: 'Crime',
    status: 'open',
    postedAt: '5 hours ago'
  },
  {
    id: 'g3',
    title: 'Real Estate Contract Review',
    description: 'Reviewing a purchase agreement for a commercial property in Manhattan.',
    budget: 2500,
    clientName: 'Skyline Props',
    type: 'Property',
    status: 'open',
    postedAt: '1 day ago'
  }
];

export const MOCK_MESSAGES: Message[] = [
  {
    id: 'm1',
    senderId: 'l1',
    senderName: 'Tush Yamlash',
    text: 'Hello, I have reviewed your case documents.',
    timestamp: '10:30 AM'
  },
  {
    id: 'm2',
    senderId: 'client',
    senderName: 'John Doe',
    text: 'Great! When can we schedule a call?',
    timestamp: '11:00 AM'
  }
];

export const MOCK_APPLICATIONS: Application[] = [
  {
    id: 'a1',
    gigId: 'g1',
    lawyerId: 'l1',
    status: 'pending',
    appliedAt: 'Oct 12, 2023'
  },
  {
    id: 'a2',
    gigId: 'g2',
    lawyerId: 'l1',
    status: 'accepted',
    appliedAt: 'Oct 10, 2023'
  }
];

export const SPECIALTIES = ['Crime Lawyers', 'Family Lawyers', 'Business', 'Immigration', 'Property'];
