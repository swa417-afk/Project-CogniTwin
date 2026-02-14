import { useState, useEffect, useRef } from 'react';

/**
 * Hook for capturing keystroke timing and behavior
 * Privacy-first: computes derived features only, never stores raw keystrokes
 */
export const useKeystrokeCapture = () => {
  const [metrics, setMetrics] = useState({
    dwellTimes: [],
    flightTimes: [],
    pauses: [],
    backspaceCount: 0,
    totalKeystrokes: 0,
    textLength: 0,
    lastKeystrokeTime: null,
  });
  
  const keyDownTimes = useRef({});
  const lastKeyUpTime = useRef(null);
  
  const handleKeyDown = (e) => {
    const now = Date.now();
    const key = e.key;
    
    // Don't track modifier keys
    if (['Shift', 'Control', 'Alt', 'Meta'].includes(key)) {
      return;
    }
    
    // Record key down time
    if (!keyDownTimes.current[key]) {
      keyDownTimes.current[key] = now;
    }
    
    // Count backspaces for error rate
    if (key === 'Backspace' || key === 'Delete') {
      setMetrics(prev => ({
        ...prev,
        backspaceCount: prev.backspaceCount + 1,
        totalKeystrokes: prev.totalKeystrokes + 1,
      }));
    } else {
      setMetrics(prev => ({
        ...prev,
        totalKeystrokes: prev.totalKeystrokes + 1,
      }));
    }
  };
  
  const handleKeyUp = (e) => {
    const now = Date.now();
    const key = e.key;
    
    // Don't track modifier keys
    if (['Shift', 'Control', 'Alt', 'Meta'].includes(key)) {
      return;
    }
    
    // Calculate dwell time (key press duration)
    if (keyDownTimes.current[key]) {
      const dwellTime = now - keyDownTimes.current[key];
      delete keyDownTimes.current[key];
      
      setMetrics(prev => ({
        ...prev,
        dwellTimes: [...prev.dwellTimes, dwellTime],
      }));
    }
    
    // Calculate flight time (time between keystrokes)
    if (lastKeyUpTime.current) {
      const flightTime = now - lastKeyUpTime.current;
      
      // Track pauses (>2 seconds)
      if (flightTime > 2000) {
        setMetrics(prev => ({
          ...prev,
          pauses: [...prev.pauses, flightTime],
          flightTimes: [...prev.flightTimes, flightTime],
        }));
      } else {
        setMetrics(prev => ({
          ...prev,
          flightTimes: [...prev.flightTimes, flightTime],
        }));
      }
    }
    
    lastKeyUpTime.current = now;
    setMetrics(prev => ({ ...prev, lastKeystrokeTime: now }));
  };
  
  const updateTextLength = (length) => {
    setMetrics(prev => ({ ...prev, textLength: length }));
  };
  
  const resetMetrics = () => {
    setMetrics({
      dwellTimes: [],
      flightTimes: [],
      pauses: [],
      backspaceCount: 0,
      totalKeystrokes: 0,
      textLength: 0,
      lastKeystrokeTime: null,
    });
    keyDownTimes.current = {};
    lastKeyUpTime.current = null;
  };
  
  const getAggregatedMetrics = () => {
    const { dwellTimes, flightTimes, pauses, backspaceCount, totalKeystrokes, textLength } = metrics;
    
    const avgDwellTime = dwellTimes.length > 0
      ? dwellTimes.reduce((a, b) => a + b, 0) / dwellTimes.length
      : 100;
    
    const avgFlightTime = flightTimes.length > 0
      ? flightTimes.reduce((a, b) => a + b, 0) / flightTimes.length
      : 150;
    
    const avgPauseDuration = pauses.length > 0
      ? pauses.reduce((a, b) => a + b, 0) / pauses.length
      : 0;
    
    const errorRate = totalKeystrokes > 0
      ? Math.min(backspaceCount / totalKeystrokes, 1)
      : 0;
    
    // Correction rate: ratio of corrections to text produced
    // (accounts for correcting vs just deleting)
    const correctionRate = textLength > 0
      ? Math.min(backspaceCount / (textLength + backspaceCount), 1)
      : 0;
    
    return {
      avg_dwell_time: avgDwellTime,
      avg_flight_time: avgFlightTime,
      pause_count: pauses.length,
      avg_pause_duration: avgPauseDuration,
      error_rate: errorRate,
      correction_rate: correctionRate,
      text_length: textLength,
    };
  };
  
  return {
    handleKeyDown,
    handleKeyUp,
    updateTextLength,
    resetMetrics,
    getAggregatedMetrics,
    metrics,
  };
};
