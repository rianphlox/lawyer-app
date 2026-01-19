
import { GoogleGenAI, Type } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

export const getCaseRecommendations = async (caseDescription: string) => {
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `You are a legal assistant bot. Based on this case description: "${caseDescription}", suggest the best legal specialty needed. 
      Return only a JSON object with "specialty" (string) and "urgency" (string - Low, Medium, High).`,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            specialty: { type: Type.STRING },
            urgency: { type: Type.STRING }
          },
          required: ["specialty", "urgency"]
        }
      }
    });
    return JSON.parse(response.text || '{}');
  } catch (error) {
    console.error("Gemini Error:", error);
    return { specialty: "General Practice", urgency: "Medium" };
  }
};

export const generateProposal = async (lawyerName: string, lawyerAbout: string, gigTitle: string, gigDesc: string) => {
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `You are Adv. ${lawyerName}. Write a professional and persuasive legal proposal for the following case: "${gigTitle}: ${gigDesc}". 
      Your background: ${lawyerAbout}. Keep it under 150 words. Focus on why you are the best fit.`,
    });
    return response.text;
  } catch (error) {
    return "I am highly interested in this case and believe my expertise aligns perfectly with your requirements. Let's discuss further.";
  }
};

export const askLegalAssistant = async (query: string) => {
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `You are a helpful legal assistant concierge for an app called LegalLink. Answer this user query concisely: "${query}". 
      Disclaimer: You provide general info, not formal legal advice.`,
    });
    return response.text;
  } catch (error) {
    return "I'm sorry, I couldn't process that. Please contact support.";
  }
};
