# EOG Assistive HCI: Smart Wheelchair & Arabic Virtual Keyboard

![Project Status](https://img.shields.io/badge/Status-Completed-success) 
![Evaluation](https://img.shields.io/badge/Grade-Distinction_with_Highest_Honors-blue)

## Project Summary

Patients suffering from advanced neuromuscular disorders such as Amyotrophic Lateral Sclerosis (ALS), severe cerebral palsy, or brainstem stroke frequently experience quadriplegia while retaining voluntary oculomotor control. However, native Arabic assistive communication systems remain severely underdeveloped, isolating affected individuals in the Arab region.

For our senior capstone graduation project, our student team designed, fabricated, and experimentally validated an end-to-end assistive Human-Computer Interface (HCI) driven by Electrooculography (EOG) biopotentials. The system addresses the critical gap in localized assistive tech by unifying mobility and communication. The system enables users to:
1. **Compose and type Arabic text** via a native on-screen virtual optical keyboard at an average throughput of **16.0 characters per minute (CPM)**.
2. **Navigate a 3D-printed prototype smart wheelchair** (forward, reverse, turn left, turn right, emergency stop) with an average navigation accuracy of **94.0%** and a response latency of **143 ms**, backed by an autonomous ultrasonic collision avoidance safety layer.

---

## Hardware Analog Front-End (AFE) Architecture

The analog conditioning subsystem uses an AD620 instrumentation amplifier and TL072 low-noise JFET-input dual operational amplifiers powered by a symmetric dual-polarity supply (+-9V):

```text
[ Periorbital Ag/AgCl Electrodes ]
                 |
[ Stage 1: AD620 Pre-Amplifier ] -> Differential Gain G1 = 6x (Rg = 10 kOhm, CMRR > 100 dB)
                 |
[ Stage 2: Active Bandpass Filtering ] -> Sallen-Key HPF (0.8 Hz) + Sallen-Key LPF (30 Hz)
                 |
[ Stage 3: Twin-T 50 Hz Notch ] -> Rejects 50 Hz mains interference, Gain G2 = 10x
                 |
[ Stage 4: Variable Post-Amp & Level Shifter ] -> Gain G3 = 10x to 100x + 2.5V DC offset
                 |
[ ATmega328P 10-Bit ADC Input (0 to 5V span) ]
```

### Circuit Schematic & Calculations
- **Total Dynamic System Gain ($A_{\text{total}}$):** 600x to 6000x. This elevates raw microvolt biopotentials (100 uV to 600 uV) into a measurable 0.6V to 3.6V signal centered around a +2.5V DC baseline.
- **High-Pass Cutoff:** 0.88 Hz (removes baseline wander and skin half-cell DC potential).
- **Low-Pass Cutoff:** 29.5 Hz (attenuates facial EMG interference).
- **Notch Filter:** Twin-T topology tuned to 50.0 Hz.

![Circuit Schematic](results/eog_circuit_schematic.png)
*Figure 1: Complete circuit schematic of the multi-stage EOG analog front-end.*

---

## Digital Signal Processing & System Control (MATLAB & Arduino)

The system relies exclusively on MATLAB for signal processing and GUI rendering, and Arduino (C/C++) for physical hardware execution:
- Data digitized at 250 Hz is streamed via UART (or HC-05 Bluetooth) from the ATmega328P to MATLAB.
- **MATLAB DSP:** A dual-threshold state machine detects voluntary saccades and blinks while ignoring involuntary micro-movements. Blink duration discrimination separates single involuntary blinks from deliberate command blinks.
- **Arduino Firmware:** Executes physical movement commands for the 3D-printed wheelchair prototype.

![MATLAB Thresholds](results/processed_eog_matlab_thresholds.png)
*Figure 2: Real-time processed EOG signal showing peak detection thresholds for upward gaze, downward gaze, and voluntary blinks.*

---

## User Interfaces & Dual Operating Modes

### 1. Arabic Virtual Optical Speller
Designed specifically for the Arab user, this interface allows patients to select letters in an Arabic on-screen matrix without requiring them to memorize complex Morse pulse sequences. Gaze shifts rotate through sectors, while voluntary blinks confirm selection.

![Virtual Keyboard](results/virtual_keyboard_main_interface.png)
*Figure 3: Main user interface of the virtual optical speller.*

### 2. 3D-Printed Prototype Wheelchair Driving Mode
Provides directional control via eye movements. If an obstacle is detected within 40 cm (front) or 30 cm (rear) by the HC-SR04 ultrasonic sensors, the Arduino firmware immediately halts the L298N motor drivers, ensuring patient safety.

![Wheelchair Mode](results/wheelchair_mode_user_interface.png)
*Figure 4: Wheelchair navigation command interface.*

---

## Experimental Testing with Healthy Volunteers (N = 5)

Quantitative evaluation was conducted with 5 healthy participants:

### 1. Wheelchair Navigation Mode (100 Total Trials)
| Subject ID | Total Trials | Successful | Failed | Accuracy (%) | Mean Latency (ms) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Overall Mean | 100 | 94 | 6 | 94.0% | 143.0 ± 10.0 |

### 2. Virtual Optical Speller Mode
*Target Phrase: "الذكاء الاصطناعي مجال واعد للمستقبل" (28 characters)*
| Subject ID | Sector Accuracy (%) | Completion Time (s) | Typing Speed (CPM) | Speller Accuracy (%) |
| :--- | :---: | :---: | :---: | :---: |
| Overall Mean | 92.2% | 105.8 s | 16.0 CPM | 89.0% |

*Note: System accuracy and selection speed scale directly with operator experience, as evidenced by Subject 3 achieving 18.0 CPM following extended pre-test acclimatization.*

---

## Experimental Setup

![Experimental Setup](results/experimental_test_setup.jpg)
*Figure 5: Physical experimental test setup during subject evaluation.*

---

## Engineering Observations

1. **Electrode Impedance:** Preparing the skin with 70% alcohol and using fresh Ag/AgCl electrodes was essential to prevent DC saturation at the AD620 output.
2. **Motor Switching Decoupling:** The L298N motor driver drew inductive current surges that perturbed the analog front-end ground. Resolved by using separate battery banks for logic/AFE and motor power.
3. **Fatigue Mitigation:** Test subjects experienced mild eye strain after 15 to 20 minutes of continuous typing. A brief 2-minute pause between sessions prevented blink threshold degradation.

---

## Repository Contents

```text
eog-assistive-hci-keyboard/
├── README.md                          
├── matlab/
│   ├── main_bci_system.m              # MATLAB main execution script
│   ├── config.m                       # System configuration and variables
│   └── utils/                         # MATLAB UI helper functions
├── firmware/
│   └── wheelchair_controller.ino      # ATmega328P firmware (Wheelchair/Sensors)
└── results/                           # Schematics and UI screenshots
```

---

## Academic Team
- **Lead Hardware & DSP Engineer:** Abdulaziz K. A. Hatem
- **Team Members:** Ahmed M.A.S. AlKadhi, Mohammed A A. Qasem, Khaled A.M. Farhan
- **Senior Thesis Advisor:** Dr. Nasr Kaid Ali AL-Audi
- **Institution:** Department of Biomedical Engineering, University of Science and Technology, Aden, Yemen
