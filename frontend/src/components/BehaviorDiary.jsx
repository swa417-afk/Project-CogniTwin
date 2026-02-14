import React, { useState, useEffect } from 'react';
import './BehaviorDiary.css';

const BehaviorDiary = ({ sessionId, scores }) => {
  const [entries, setEntries] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [moodRating, setMoodRating] = useState(3);
  const [moodNotes, setMoodNotes] = useState('');
  const [isCrisis, setIsCrisis] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';

  useEffect(() => {
    loadEntries();
  }, [sessionId]);

  const loadEntries = async () => {
    try {
      const response = await fetch(`${apiUrl}/api/diary/entries/${sessionId}`);
      if (response.ok) {
        const data = await response.json();
        setEntries(data);
      }
    } catch (error) {
      console.error('Failed to load diary entries:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      const response = await fetch(`${apiUrl}/api/diary/entry`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          session_id: sessionId,
          mood_rating: moodRating,
          mood_notes: moodNotes,
          is_crisis: isCrisis,
        }),
      });

      if (response.ok) {
        const newEntry = await response.json();
        setEntries([newEntry, ...entries]);
        setMoodRating(3);
        setMoodNotes('');
        setIsCrisis(false);
        setShowForm(false);
      } else {
        const error = await response.json();
        alert(error.detail || 'Failed to save diary entry');
      }
    } catch (error) {
      console.error('Failed to save diary entry:', error);
      alert('Failed to save diary entry. Make sure to analyze your typing first.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async (entryId) => {
    if (!confirm('Are you sure you want to delete this entry?')) {
      return;
    }

    try {
      const response = await fetch(`${apiUrl}/api/diary/entry/${entryId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setEntries(entries.filter(entry => entry.id !== entryId));
      }
    } catch (error) {
      console.error('Failed to delete entry:', error);
    }
  };

  const getMoodEmoji = (rating) => {
    const emojis = ['😢', '😟', '😐', '🙂', '😊'];
    return emojis[rating - 1] || '😐';
  };

  const formatDate = (timestamp) => {
    return new Date(timestamp).toLocaleString();
  };

  return (
    <div className="behavior-diary">
      <div className="diary-header">
        <h2>📔 Behavior Diary</h2>
        <button
          onClick={() => setShowForm(!showForm)}
          className="btn btn-primary"
        >
          {showForm ? 'Cancel' : '+ New Entry'}
        </button>
      </div>

      <p className="diary-description">
        Track your mood alongside cognitive metrics. Snapshots are taken automatically with each entry.
      </p>

      {showForm && (
        <div className="diary-form">
          <h3>New Diary Entry</h3>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="mood-rating">
                How are you feeling? {getMoodEmoji(moodRating)}
              </label>
              <div className="mood-slider">
                <input
                  id="mood-rating"
                  type="range"
                  min="1"
                  max="5"
                  value={moodRating}
                  onChange={(e) => setMoodRating(parseInt(e.target.value))}
                />
                <div className="mood-labels">
                  <span>😢 Very Bad</span>
                  <span>😊 Very Good</span>
                </div>
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="mood-notes">Notes (optional):</label>
              <textarea
                id="mood-notes"
                value={moodNotes}
                onChange={(e) => setMoodNotes(e.target.value)}
                placeholder="What's on your mind? How are you feeling?"
                rows={4}
              />
            </div>

            <div className="form-group">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={isCrisis}
                  onChange={(e) => setIsCrisis(e.target.checked)}
                />
                Mark as crisis entry
              </label>
            </div>

            <div className="form-actions">
              <button type="submit" className="btn btn-primary" disabled={isLoading}>
                {isLoading ? 'Saving...' : 'Save Entry'}
              </button>
              <button
                type="button"
                onClick={() => setShowForm(false)}
                className="btn btn-secondary"
              >
                Cancel
              </button>
            </div>
          </form>

          {scores && (
            <div className="current-metrics">
              <h4>Current Cognitive Snapshot:</h4>
              <div className="metric-badges">
                <span className="badge">Load: {Math.round(scores.cognitive_load * 100)}%</span>
                <span className="badge">Mood: {Math.round(scores.mood_drift * 100)}%</span>
                <span className="badge">Stability: {Math.round(scores.decision_stability * 100)}%</span>
                <span className="badge">Risk: {Math.round(scores.risk_volatility * 100)}%</span>
                <span className="badge">Heat: {Math.round(scores.heat * 100)}%</span>
                <span className="badge">Rage: {Math.round(scores.rage * 100)}%</span>
              </div>
            </div>
          )}
        </div>
      )}

      <div className="diary-entries">
        <h3>Previous Entries ({entries.length})</h3>
        {entries.length === 0 ? (
          <div className="no-entries">
            <p>No diary entries yet. Create your first entry above!</p>
          </div>
        ) : (
          <div className="entries-list">
            {entries.map((entry) => (
              <div
                key={entry.id}
                className={`diary-entry ${entry.is_crisis ? 'crisis-entry' : ''}`}
              >
                <div className="entry-header">
                  <div className="entry-mood">
                    <span className="mood-emoji">{getMoodEmoji(entry.mood_rating)}</span>
                    <span className="mood-text">Mood: {entry.mood_rating}/5</span>
                  </div>
                  <div className="entry-meta">
                    <span className="entry-date">{formatDate(entry.timestamp)}</span>
                    {entry.is_crisis && <span className="crisis-badge">⚠️ Crisis</span>}
                  </div>
                </div>

                {entry.mood_notes && (
                  <div className="entry-notes">
                    <p>{entry.mood_notes}</p>
                  </div>
                )}

                <div className="entry-metrics">
                  <h4>Cognitive Snapshot:</h4>
                  <div className="metric-grid">
                    <div className="metric-item">
                      <span className="metric-label">Cognitive Load</span>
                      <span className="metric-value">{Math.round(entry.cognitive_load * 100)}%</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Mood Drift</span>
                      <span className="metric-value">{Math.round(entry.mood_drift * 100)}%</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Decision Stability</span>
                      <span className="metric-value">{Math.round(entry.decision_stability * 100)}%</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Risk Volatility</span>
                      <span className="metric-value">{Math.round(entry.risk_volatility * 100)}%</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Heat</span>
                      <span className="metric-value">{Math.round(entry.heat * 100)}%</span>
                    </div>
                    <div className="metric-item">
                      <span className="metric-label">Rage</span>
                      <span className="metric-value">{Math.round(entry.rage * 100)}%</span>
                    </div>
                  </div>
                </div>

                <div className="entry-actions">
                  <button
                    onClick={() => handleDelete(entry.id)}
                    className="btn-delete"
                  >
                    🗑️ Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default BehaviorDiary;
