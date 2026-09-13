# Integrated EOG-Based Human-Computer Interface for Virtual Keyboard & Wheelchair Control

[![Thesis Grade](https://img.shields.io/badge/Capstone%20Thesis-100%25%20Distinction-gold.svg)]()
[![Lead Engineer](https://img.shields.io/badge/Role-Lead%20Hardware%20%26%20DSP-blue.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![MATLAB](https://img.shields.io/badge/MATLAB-DSP%20System%20Toolbox-orange.svg)]()

> **Senior Capstone Research Project**  
> Department of Biomedical Engineering, Faculty of Engineering and Computing  
> University of Science and Technology (UST), Aden, Yemen  
> **Lead Hardware & DSP Research Engineer:** Abdulaziz K. A. Hatem  
> **Capstone Advisor:** Dr. Nasr Kaid Ali AL-Audi (Head of Biomedical Engineering Dept.)  
> **Evaluation:** **100% (Distinction with Highest Honors)**

---

## 1. Executive Summary & Clinical Context

Patients suffering from advanced neuromuscular conditions such as **Amyotrophic Lateral Sclerosis (ALS)**, brainstem stroke, or severe cerebral palsy frequently enter a state of quadriplegia or Locked-in Syndrome (LIS). While somatic motor function is severely impaired, oculomotor control (voluntary eye blinks and saccadic eye movements) often remains preserved.

This senior capstone project developed and experimentally validated an end-to-end assistive neuro-technology platform consisting of:
1. A **4-stage discrete Analog Front-End (AFE)** that conditions microvolt ocular biopotentials.
2. A **real-time Digital Signal Processing (DSP)** pipeline developed in MATLAB and ported to Python for baseline drift removal and saccadic event classification.
3. A **Virtual Typing Keyboard** facilitating communication at **16 characters per minute**.
4. An **autonomous wheelchair navigation controller** with embedded ultrasonic obstacle detection, achieving **92% directional control accuracy**.

---

## 2. Quantitative Experimental Benchmarks

In formal subject evaluation trials across healthy volunteers and calibration runs, the system demonstrated high reliability and fast response latency:

| Parameter / Benchmark | Evaluated Result | Engineering Significance |
| :--- | :---: | :--- |
| **Blink Biopotential SNR** | **32.13 dB** | Distinct, unambiguous binary threshold triggering. |
| **Upward Gaze SNR** | **31.50 dB** | High-fidelity vertical saccade detection. |
| **Downward Gaze SNR** | **27.75 dB** | Effective discrimination from involuntary micro-saccades. |
| **Virtual Typing Speed** | **16 chars/min** | Practical conversational text entry rate for motor-impaired individuals. |
| **Wheelchair Directional Accuracy** | **92.0%** | Reliable navigation through experimental obstacle corridors. |
| **Collision Avoidance Latency** | **< 40 ms** | Ultrasonic sensor override prevents forward motion if obstacle < 25 cm. |

### Performance Boxplots:
![Virtual Keyboard Performance](results/virtual_keyboard_performance.png)
*Figure 1: (A) Distribution of text entry speed across evaluation trials; (B) Wheelchair navigation command accuracy under real-time ocular control.*

---

## 3. Engineering Architecture

```
                       [Ocular Dipole Potential]
                                   │
                                   ▼
        ┌─────────────────────────────────────────────────────┐
        │                 4-Stage Hardware AFE                │
        │ • Stage 1: AD620 Instrumentation Amp (G = 495)      │
        │ • Stage 2: Active 2nd-Order HPF (1.6 Hz, LM741)     │
        │ • Stage 3: Active 2nd-Order LPF (16.0 Hz, LM741)    │
        │ • Stage 4: Post-Amplifier & Level Shifter (G=40.4)  │
        │           Total Gain: ≈ 20,000x (0-5V Output)       │
        └──────────────────────────┬──────────────────────────┘
                                   │
                                   ▼
        ┌─────────────────────────────────────────────────────┐
        │            Microcontroller & Acquisition            │
        │ • ATmega328P 10-bit ADC (Fs = 250 Hz)               │
        │ • Serial UART Transmission @ 115,200 bps            │
        └──────────────────────────┬──────────────────────────┘
                                   │
                   ┌───────────────┴───────────────┐
                   ▼                               ▼
       ┌────────────────────────┐      ┌────────────────────────┐
       │   MATLAB / Python DSP  │      │  Firmware Robotic Hub  │
       │ • Baseline Wander Rej. │      │ • Ultrasonic Sensor    │
       │ • Dynamic Peak Thresh. │      │ • Dual H-Bridge Motor  │
       │ • Virtual Typing GUI   │      │ • Emergency Override   │
       └────────────────────────┘      └────────────────────────┘
```

---

## 4. Repository Structure

```text
eog-assistive-hci-keyboard/
├── README.md                          # Comprehensive project documentation
├── LICENSE                            # MIT License
├── requirements.txt                   # Python requirements
├── environment.yml                    # Conda environment
├── matlab/
│   └── eog_realtime_dsp.m             # MATLAB DSP System Toolbox implementation
├── python/
│   └── virtual_keyboard_engine.py     # Python state-machine classifier & simulator
├── firmware/
│   └── wheelchair_controller.ino      # C/C++ firmware with obstacle avoidance
├── data/
│   └── hci_trial_data.csv             # Experimental subject trial data
└── results/
    └── virtual_keyboard_performance.png # Benchmark visualizations
```

---

## 5. How to Run the Python Pipeline

```bash
# 1. Clone repository
git clone https://github.com/Abdulaziz-kh-Hatem/eog-assistive-hci-keyboard.git
cd eog-assistive-hci-keyboard

# 2. Install requirements
pip install -r requirements.txt

# 3. Execute virtual keyboard trial simulator
python python/virtual_keyboard_engine.py
```

---

## 6. Academic Team & Acknowledgments
- **Project Lead & Hardware/DSP Engineer:** Abdulaziz K. A. Hatem
- **Team Members:** Ahmed M.A.S. AlKadhi, Mohammed A A. Qasem, Khaled A.M. Farhan
- **Senior Thesis Advisor:** Dr. Nasr Kaid Ali AL-Audi
- **Institution:** Department of Biomedical Engineering, University of Science and Technology, Aden.