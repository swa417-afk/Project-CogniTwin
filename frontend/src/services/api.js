import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const analyzeTyping = async (data) => {
  const response = await api.post('/api/cognitive/analyze', data);
  return response.data;
};

export const getSessionMetrics = async (sessionId, limit = 50) => {
  const response = await api.get(`/api/cognitive/metrics/${sessionId}`, {
    params: { limit }
  });
  return response.data;
};

export const getLatestMetric = async (sessionId) => {
  const response = await api.get(`/api/cognitive/latest/${sessionId}`);
  return response.data;
};

export default api;
