import React from 'react';
import './TextInput.css';

const TextInput = ({ value, onChange, onKeyDown, onKeyUp, placeholder }) => {
  return (
    <div className="text-input-container">
      <label htmlFor="typing-area">Type here to analyze your cognitive state:</label>
      <textarea
        id="typing-area"
        className="text-input"
        value={value}
        onChange={onChange}
        onKeyDown={onKeyDown}
        onKeyUp={onKeyUp}
        placeholder={placeholder}
        rows={10}
      />
      <div className="input-info">
        <span className="char-count">{value.length} characters</span>
        <span className="privacy-note">🔒 Privacy-first: Only derived features are analyzed</span>
      </div>
    </div>
  );
};

export default TextInput;
