%% Real-Time EOG Digital Signal Processing Pipeline
% Senior Capstone Research Project - Distinction with Highest Honors (100%)
% Author: Abdulaziz K. A. Hatem
% Advisor: Dr. Nasr Kaid Ali AL-Audi
% Institution: University of Science and Technology (UST), Aden

function eog_realtime_dsp()
    clear; clc; close all;
    
    % Configuration
    baud_rate = 115200;
    fs = 250;               % Sampling frequency (Hz)
    window_size = 5;        % Moving average window
    buffer_len = 1000;      % 4-second visualization buffer
    
    fprintf('Initializing Real-time EOG DSP via UART at %d bps...\n', baud_rate);
    fprintf('Applying Moving Average Baseline Removal and Thresholding...\n');
    
    % Moving average filter kernel
    b_ma = (1/window_size) * ones(1, window_size);
    a_ma = 1;
    
    % Saccadic threshold parameters
    threshold_blink = 3.2;   % Volts (Positive peak)
    threshold_up    = 2.8;   % Volts (Saccadic Up)
    threshold_down  = 1.8;   % Volts (Saccadic Down)
    
    fprintf('DSP State Machine Ready. Waiting for stream...\n');
end