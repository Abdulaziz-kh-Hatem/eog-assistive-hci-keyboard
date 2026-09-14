# Eye-Controlled Wheelchair and Arabic Keyboard System

![Status](https://img.shields.io/badge/Project-Completed-success) 
![Evaluation](https://img.shields.io/badge/Grade-Distinction-blue)

> **Notice:** The source code (MATLAB and Arduino) for this project is currently hidden because we are waiting to publish our academic paper. The code will be available once the paper is published.

Welcome to our graduation project! We are a team of Biomedical Engineering undergraduate students from the University of Science and Technology in Aden, Yemen.

We built this system because there are not enough assistive technologies for Arab patients, especially those who are paralyzed or have ALS (Locked-in Syndrome). Our goal was to create a cheap and practical system that lets patients type in Arabic and move a wheelchair using only their eye movements.

## What Does This System Do?
Our project uses Electrooculography (EOG) — the electrical signals made when you move your eyes — to control two things:
1. **An Arabic Virtual Keyboard:** A computer program that lets patients type Arabic words by looking at different sections on the screen and blinking to choose a letter. We reached an average typing speed of 16 characters per minute.
2. **A Smart Wheelchair Prototype:** The user can drive the wheelchair (forward, backward, left, right) with their eyes. We also added ultrasonic sensors so the wheelchair stops automatically if it gets too close to a wall.

---

## How It Works

The system has two main parts: reading the eye signal to the computer, and sending movement commands to the wheelchair.

1. **Reading the Signal:** We built an electronic circuit using an AD620 amplifier to read the very small EOG signals from stickers (electrodes) on the patient's face.
2. **Sending to Computer:** An Arduino reads these amplified signals and sends them through a USB cable to a laptop.
3. **Signal Processing:** A MATLAB program on the laptop cleans the signal (removes noise) and detects if the user looked up, down, left, right, or blinked.
4. **Moving the Wheelchair:** If the user is in "Wheelchair Mode", MATLAB sends the movement command using Bluetooth to a second Arduino on our 3D-printed wheelchair.

---

## Hardware Circuit Design

We built the circuit on a breadboard using standard components like the AD620 and TL072 op-amps. Here is how the circuit works:

- **Amplifier:** AD620 amplifies the signal by 6 times.
- **Filters:** A High-pass filter (0.8 Hz) removes slow drifting voltages, and a Low-pass filter (30 Hz) removes noise from facial muscles.
- **Notch Filter:** A Twin-T filter exactly at 50 Hz removes noise from the room's electrical power lines.
- **Final Stage:** We amplify the signal again (up to 100 times) so the Arduino can read it easily between 0 and 5 Volts.

![Circuit Schematic](results/eog_circuit_schematic.png)
*Figure 1: Circuit diagram of our EOG hardware.*

---

## The Interfaces

### 1. Arabic Virtual Keyboard
We designed this for Arab users. Instead of learning difficult blink codes, the screen highlights different groups of Arabic letters. The user blinks hard to select the highlighted group.

![Virtual Keyboard](results/virtual_keyboard_main_interface.png)
*Figure 2: The Arabic virtual keyboard screen.*

### 2. 3D-Printed Wheelchair Prototype
We 3D-printed a small wheelchair and added motors (L298N driver) and distance sensors (HC-SR04). If the sensors see a wall within 40 cm, the motors stop immediately to keep the patient safe, even if they are trying to move forward.

![Wheelchair Prototype](results/3d_printed_wheelchair_prototype.jpeg)
*Figure 3: Our 3D-printed wheelchair with sensors.*

---

## Testing and Results

We tested the system on 5 healthy student volunteers. Here is what we found:
- **Wheelchair Driving:** In 100 tests, the wheelchair moved in the correct direction 94% of the time. It takes the computer about 143 milliseconds to understand the eye movement, and the motors take another 70 milliseconds to move (total delay is about 213 ms).
- **Typing Speed:** Users typed a 28-letter Arabic phrase. On average, they typed 16 characters per minute. One of our team members practiced a lot and reached 18 characters per minute.
- **Note:** We only tested on healthy students so far. Testing on real paralyzed patients is our next step for the future.

### Video Demonstration

You can watch videos showing how the system works:
- **Typing Demo (YouTube):** [Watch a user type "أهلا وسهلا" (10 letters) in 40 seconds (15 chars/min)](https://youtu.be/_7P_xF_lJTU?si=B2MbOErdmBXGmws5)
- **Local Video:** [Download / Watch System Demo (24 MB)](results/eog_demo_video.mp4)
