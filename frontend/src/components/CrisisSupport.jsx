import React, { useState, useEffect } from 'react';
import './CrisisSupport.css';

const CrisisSupport = ({ scores }) => {
  const [isLocked, setIsLocked] = useState(true);
  const [pin, setPin] = useState('');
  const [storedPin, setStoredPin] = useState('');
  const [showAlert, setShowAlert] = useState(false);

  // Check if user is in potential crisis (high heat or rage)
  useEffect(() => {
    if (scores && (scores.heat > 0.7 || scores.rage > 0.7)) {
      setShowAlert(true);
    } else {
      setShowAlert(false);
    }
  }, [scores]);

  // Load stored PIN from localStorage
  useEffect(() => {
    const savedPin = localStorage.getItem('cognitwin_crisis_pin');
    if (savedPin) {
      setStoredPin(savedPin);
    } else {
      // Set default PIN on first load
      localStorage.setItem('cognitwin_crisis_pin', '0000');
      setStoredPin('0000');
    }
  }, []);

  const handleUnlock = () => {
    if (pin === storedPin) {
      setIsLocked(false);
      setPin('');
    } else {
      alert('Incorrect PIN. Default PIN is 0000');
      setPin('');
    }
  };

  const handleSetNewPin = () => {
    const newPin = prompt('Enter new 4-digit PIN:');
    if (newPin && /^\d{4}$/.test(newPin)) {
      localStorage.setItem('cognitwin_crisis_pin', newPin);
      setStoredPin(newPin);
      alert('PIN updated successfully');
    } else {
      alert('Invalid PIN. Must be 4 digits.');
    }
  };

  if (isLocked) {
    return (
      <div className="crisis-support locked">
        <div className="lock-screen">
          <h2>🔒 Crisis Support Resources</h2>
          <p>This section contains crisis hotlines and support contacts.</p>
          {showAlert && (
            <div className="crisis-alert">
              ⚠️ High stress detected. Consider accessing support resources.
            </div>
          )}
          <div className="pin-entry">
            <label htmlFor="pin-input">Enter PIN to access:</label>
            <input
              id="pin-input"
              type="password"
              maxLength="4"
              value={pin}
              onChange={(e) => setPin(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleUnlock()}
              placeholder="0000"
            />
            <button onClick={handleUnlock} className="btn btn-primary">
              Unlock
            </button>
          </div>
          <p className="pin-hint">Default PIN: 0000</p>
        </div>
      </div>
    );
  }

  return (
    <div className="crisis-support">
      <div className="crisis-header">
        <h2>🆘 Crisis Support Resources</h2>
        <button onClick={() => setIsLocked(true)} className="btn btn-secondary">
          🔒 Lock
        </button>
      </div>

      {showAlert && (
        <div className="crisis-alert">
          <strong>⚠️ High Stress Level Detected</strong>
          <p>Your typing patterns indicate elevated stress. Consider reaching out for support.</p>
        </div>
      )}

      <div className="hotlines-section">
        <h3>24/7 Crisis Hotlines</h3>
        <div className="hotline-grid">
          <div className="hotline-card">
            <h4>🇺🇸 National Suicide Prevention Lifeline</h4>
            <a href="tel:988" className="hotline-number">988</a>
            <p>24/7, free and confidential support</p>
            <a href="https://988lifeline.org/" target="_blank" rel="noopener noreferrer" className="hotline-link">
              Visit Website
            </a>
          </div>

          <div className="hotline-card">
            <h4>💬 Crisis Text Line</h4>
            <a href="sms:741741" className="hotline-number">Text HOME to 741741</a>
            <p>24/7 text support for crisis situations</p>
            <a href="https://www.crisistextline.org/" target="_blank" rel="noopener noreferrer" className="hotline-link">
              Visit Website
            </a>
          </div>

          <div className="hotline-card">
            <h4>🌍 International Association for Suicide Prevention</h4>
            <p className="hotline-number">Find Your Country</p>
            <p>Global directory of crisis centers</p>
            <a href="https://www.iasp.info/resources/Crisis_Centres/" target="_blank" rel="noopener noreferrer" className="hotline-link">
              Find Hotline
            </a>
          </div>

          <div className="hotline-card">
            <h4>🏳️‍🌈 The Trevor Project</h4>
            <a href="tel:1-866-488-7386" className="hotline-number">1-866-488-7386</a>
            <p>LGBTQ+ youth crisis support</p>
            <a href="https://www.thetrevorproject.org/" target="_blank" rel="noopener noreferrer" className="hotline-link">
              Visit Website
            </a>
          </div>

          <div className="hotline-card">
            <h4>🎖️ Veterans Crisis Line</h4>
            <a href="tel:988" className="hotline-number">988 then Press 1</a>
            <p>Support for veterans and families</p>
            <a href="https://www.veteranscrisisline.net/" target="_blank" rel="noopener noreferrer" className="hotline-link">
              Visit Website
            </a>
          </div>

          <div className="hotline-card">
            <h4>👥 SAMHSA National Helpline</h4>
            <a href="tel:1-800-662-4357" className="hotline-number">1-800-662-HELP</a>
            <p>Mental health & substance abuse</p>
            <a href="https://www.samhsa.gov/find-help/national-helpline" target="_blank" rel="noopener noreferrer" className="hotline-link">
              Visit Website
            </a>
          </div>
        </div>
      </div>

      <div className="personal-contacts">
        <h3>Personal Support Contacts</h3>
        <p className="info-text">
          Add your personal emergency contacts here. These are stored locally in your browser.
        </p>
        <button className="btn btn-secondary">Manage Contacts (Coming Soon)</button>
      </div>

      <div className="settings-section">
        <h3>Settings</h3>
        <button onClick={handleSetNewPin} className="btn btn-secondary">
          Change PIN
        </button>
      </div>

      <div className="disclaimer">
        <p>
          <strong>Disclaimer:</strong> CogniTwin is not a substitute for professional mental health care.
          If you're in crisis, please contact emergency services (911 in the US) or one of the hotlines above.
        </p>
      </div>
    </div>
  );
};

export default CrisisSupport;
