"""
EOG-Based Virtual Keyboard & State Machine Classifier
Senior Capstone Project - Distinction with Highest Honors (100%)
Author: Abdulaziz K. A. Hatem
Institution: University of Science and Technology, Aden
"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

class EOGVirtualKeyboard:
    def __init__(self, char_matrix=None):
        if char_matrix is None:
            # 4x6 Virtual Keyboard Grid
            self.grid = [
                ['A', 'B', 'C', 'D', 'E', 'F'],
                ['G', 'H', 'I', 'J', 'K', 'L'],
                ['M', 'N', 'O', 'P', 'Q', 'R'],
                ['S', 'T', 'U', 'V', 'W', 'Space']
            ]
        else:
            self.grid = char_matrix
        self.row = 0
        self.col = 0
        self.typed_text = []
        
    def process_command(self, action):
        """
        Actions:
        - 'UP': Move row up
        - 'DOWN': Move row down / advance
        - 'BLINK_DOUBLE': Select current character
        """
        if action == 'DOWN':
            self.row = (self.row + 1) % len(self.grid)
        elif action == 'UP':
            self.col = (self.col + 1) % len(self.grid[0])
        elif action == 'BLINK_DOUBLE':
            selected_char = self.grid[self.row][self.col]
            self.typed_text.append(selected_char)
            return selected_char
        return None

def simulate_capstone_trials():
    """Simulates typing session evaluating typing speed (CPM) and accuracy."""
    np.random.seed(101)
    target_sentence = "BIOMEDICAL"
    cpm_benchmark = 16.0 # Characters per minute evaluated in senior trials
    directional_accuracy = 0.92 # 92% evaluated directional accuracy
    
    # Generate trial metrics
    n_trials = 20
    cpm_samples = np.random.normal(cpm_benchmark, 1.2, n_trials)
    acc_samples = np.random.normal(directional_accuracy * 100, 2.5, n_trials)
    
    df = pd.DataFrame({
        'trial_id': range(1, n_trials + 1),
        'typing_speed_cpm': cpm_samples,
        'directional_accuracy_pct': acc_samples
    })
    
    os.makedirs('data', exist_ok=True)
    df.to_csv('data/hci_trial_data.csv', index=False)
    
    # Plotting Performance Summary
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Plot 1: Typing Speed
    ax1.boxplot(cpm_samples, patch_artist=True, boxprops=dict(facecolor='#3498db', color='#2980b9'))
    ax1.axhline(cpm_benchmark, color='#e74c3c', linestyle='--', label=f'Mean Target ({cpm_benchmark:.1f} CPM)')
    ax1.set_title('A. Virtual Keyboard Typing Speed (Chars / Min)', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Speed (Characters per minute)', fontsize=11)
    ax1.set_xticklabels(['Subject Evaluation Trials'])
    ax1.grid(True, linestyle=':', alpha=0.6)
    ax1.legend()
    
    # Plot 2: Directional Control Accuracy
    ax2.boxplot(acc_samples, patch_artist=True, boxprops=dict(facecolor='#2ecc71', color='#27ae60'))
    ax2.axhline(directional_accuracy * 100, color='#e74c3c', linestyle='--', label=f'Mean Accuracy ({directional_accuracy*100:.0f}%)')
    ax2.set_title('B. Wheelchair Directional Control Accuracy (%)', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Accuracy (%)', fontsize=11)
    ax2.set_xticklabels(['Subject Navigation Trials'])
    ax2.grid(True, linestyle=':', alpha=0.6)
    ax2.legend()
    
    plt.tight_layout()
    os.makedirs('results', exist_ok=True)
    plt.savefig('results/virtual_keyboard_performance.png', dpi=300)
    print("Simulated trials logged to data/hci_trial_data.csv and results/virtual_keyboard_performance.png")

if __name__ == '__main__':
    simulate_capstone_trials()