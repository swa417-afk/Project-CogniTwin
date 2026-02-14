import React, { useState, useEffect } from 'react';
import TextInput from './components/TextInput';
import Dashboard from './components/Dashboard';
import CrisisSupport from './components/CrisisSupport';
import BehaviorDiary from './components/BehaviorDiary';
import { useKeystrokeCapture } from './hooks/useKeystrokeCapture';
import { analyzeSentiment, countWords } from './services/sentimentAnalyzer';
import { analyzeTyping } from './services/api';
import './App.css';

function App() {
  const [text, setText] = useState('');
  const [sessionId] = useState(() => `session-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`);
  const [scores, setScores] = useState(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [error, setError] = useState(null);
  const [activeTab, setActiveTab] = useState('analysis'); // analysis, crisis, diary
  
  const {
    handleKeyDown,
    handleKeyUp,
    updateTextLength,
    getAggregatedMetrics,
    resetMetrics,
  } = useKeystrokeCapture();
  
  useEffect(() => {
    updateTextLength(text.length);
  }, [text, updateTextLength]);
  
  // Auto-analyze every 5 seconds if there's text
  useEffect(() => {
    if (text.trim().length === 0) {
      return;
    }
    
    const interval = setInterval(() => {
      analyzeText();
    }, 5000);
    
    return () => clearInterval(interval);
  }, [text]);
  
  const analyzeText = async () => {
    if (text.trim().length === 0) {
      return;
    }
    
    setIsAnalyzing(true);
    setError(null);
    
    try {
      const aggregated = getAggregatedMetrics();
      const sentiment = analyzeSentiment(text);
      const wordCount = countWords(text);
      
      const data = {
        session_id: sessionId,
        ...aggregated,
        sentiment_score: sentiment,
        word_count: wordCount,
      };
      
      const response = await analyzeTyping(data);
      setScores(response.scores);
    } catch (err) {
      console.error('Analysis error:', err);
      setError('Failed to analyze. Please check if the backend is running.');
    } finally {
      setIsAnalyzing(false);
    }
  };
  
  const handleTextChange = (e) => {
    setText(e.target.value);
  };
  
  const handleClear = () => {
    setText('');
    setScores(null);
    resetMetrics();
    setError(null);
  };
  
  return (
    <div className="app">
      <header className="app-header">
        <h1>🧠 CogniTwin</h1>
        <p className="tagline">Real-time Cognitive Digital Twin</p>
        <p className="subtitle">
          Model your mental state from typing behavior - Privacy-first & Explainable
        </p>
      </header>
      
      <nav className="app-nav">
        <button
          className={`nav-tab ${activeTab === 'analysis' ? 'active' : ''}`}
          onClick={() => setActiveTab('analysis')}
        >
          📊 Analysis
        </button>
        <button
          className={`nav-tab ${activeTab === 'diary' ? 'active' : ''}`}
          onClick={() => setActiveTab('diary')}
        >
          📔 Diary
        </button>
        <button
          className={`nav-tab ${activeTab === 'crisis' ? 'active' : ''}`}
          onClick={() => setActiveTab('crisis')}
        >
          🆘 Crisis Support
        </button>
      </nav>
      
      <main className="app-main">
        <div className="container">
          {activeTab === 'analysis' && (
            <>
              <TextInput
                value={text}
                onChange={handleTextChange}
                onKeyDown={handleKeyDown}
                onKeyUp={handleKeyUp}
                placeholder="Start typing to analyze your cognitive state in real-time..."
              />
              
              <div className="action-bar">
                <button
                  className="btn btn-primary"
                  onClick={analyzeText}
                  disabled={text.trim().length === 0 || isAnalyzing}
                >
                  {isAnalyzing ? 'Analyzing...' : 'Analyze Now'}
                </button>
                <button
                  className="btn btn-secondary"
                  onClick={handleClear}
                  disabled={text.length === 0}
                >
                  Clear
                </button>
              </div>
              
              {error && (
                <div className="error-message">
                  ⚠️ {error}
                </div>
              )}
              
              <Dashboard scores={scores} isAnalyzing={isAnalyzing} />
            </>
          )}
          
          {activeTab === 'diary' && (
            <BehaviorDiary sessionId={sessionId} scores={scores} />
          )}
          
          {activeTab === 'crisis' && (
            <CrisisSupport scores={scores} />
          )}
        </div>
      </main>
      
      <footer className="app-footer">
        <p>
          CogniTwin captures keystroke timing, error rate, text sentiment, and pause intervals
          to compute six cognitive metrics: cognitive load, mood drift, decision stability, risk volatility, heat, and rage.
        </p>
        <p className="privacy-note">
          🔒 Privacy-first: No raw keystrokes or text are ever stored. Only derived metrics are saved.
        </p>
      </footer>
    </div>
  );
}

export default App;
