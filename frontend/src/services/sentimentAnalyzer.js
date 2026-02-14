/**
 * Simple sentiment analysis using word lists
 * Returns score from -1 (negative) to 1 (positive)
 */

const positiveWords = [
  'good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic', 'happy',
  'love', 'best', 'perfect', 'awesome', 'brilliant', 'enjoy', 'success',
  'beautiful', 'excited', 'grateful', 'pleased', 'delighted', 'positive'
];

const negativeWords = [
  'bad', 'terrible', 'awful', 'horrible', 'worst', 'hate', 'angry', 'sad',
  'poor', 'difficult', 'problem', 'issue', 'error', 'fail', 'failed',
  'frustrated', 'confused', 'worried', 'stress', 'negative', 'wrong'
];

export const analyzeSentiment = (text) => {
  if (!text || text.trim().length === 0) {
    return 0; // Neutral
  }
  
  const words = text.toLowerCase().split(/\s+/);
  let positiveCount = 0;
  let negativeCount = 0;
  
  words.forEach(word => {
    if (positiveWords.includes(word)) {
      positiveCount++;
    }
    if (negativeWords.includes(word)) {
      negativeCount++;
    }
  });
  
  const totalSentimentWords = positiveCount + negativeCount;
  
  if (totalSentimentWords === 0) {
    return 0; // Neutral
  }
  
  // Calculate sentiment score
  const score = (positiveCount - negativeCount) / totalSentimentWords;
  
  // Normalize to -1 to 1
  return Math.max(-1, Math.min(1, score));
};

export const countWords = (text) => {
  if (!text || text.trim().length === 0) {
    return 0;
  }
  return text.trim().split(/\s+/).length;
};
