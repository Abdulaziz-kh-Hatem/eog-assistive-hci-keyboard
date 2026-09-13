/*
 * EOG-Driven Wheelchair Control Firmware with Ultrasonic Collision Avoidance
 * Senior Capstone Project - Distinction with Highest Honors (100%)
 * Lead Hardware & DSP Research Engineer: Abdulaziz K. A. Hatem
 * Department of Biomedical Engineering, UST Aden
 */

const int TRIG_PIN = 9;
const int ECHO_PIN = 10;
const int MOTOR_LEFT_F = 5;
const int MOTOR_LEFT_R = 6;
const int MOTOR_RIGHT_F = 7;
const int MOTOR_RIGHT_R = 8;

const float MIN_SAFE_DISTANCE_CM = 25.0;

void setup() {
    Serial.begin(115200);
    pinMode(TRIG_PIN, OUTPUT);
    pinMode(ECHO_PIN, INPUT);
    pinMode(MOTOR_LEFT_F, OUTPUT);
    pinMode(MOTOR_LEFT_R, OUTPUT);
    pinMode(MOTOR_RIGHT_F, OUTPUT);
    pinMode(MOTOR_RIGHT_R, OUTPUT);
    stopMotors();
}

float getObstacleDistance() {
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(2);
    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);
    long duration = pulseIn(ECHO_PIN, HIGH, 30000);
    if (duration == 0) return 999.0;
    return duration * 0.0343 / 2.0;
}

void moveForward() {
    analogWrite(MOTOR_LEFT_F, 180);
    analogWrite(MOTOR_RIGHT_F, 180);
    digitalWrite(MOTOR_LEFT_R, LOW);
    digitalWrite(MOTOR_RIGHT_R, LOW);
}

void turnLeft() {
    analogWrite(MOTOR_LEFT_F, 0);
    analogWrite(MOTOR_RIGHT_F, 150);
}

void turnRight() {
    analogWrite(MOTOR_LEFT_F, 150);
    analogWrite(MOTOR_RIGHT_F, 0);
}

void stopMotors() {
    digitalWrite(MOTOR_LEFT_F, LOW);
    digitalWrite(MOTOR_LEFT_R, LOW);
    digitalWrite(MOTOR_RIGHT_F, LOW);
    digitalWrite(MOTOR_RIGHT_R, LOW);
}

void loop() {
    float dist = getObstacleDistance();
    if (dist < MIN_SAFE_DISTANCE_CM) {
        stopMotors(); // Safety emergency override
        Serial.println("ALERT: Obstacle detected within safety perimeter! Halt.");
        return;
    }

    if (Serial.available() > 0) {
        char cmd = Serial.read();
        switch (cmd) {
            case 'F': moveForward(); break;
            case 'L': turnLeft(); break;
            case 'R': turnRight(); break;
            case 'S': stopMotors(); break;
        }
    }
}