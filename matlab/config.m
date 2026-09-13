% CONFIG Configuration parameters for the BCI Wheelchair & Speller System.
% Defines serial ports, thresholds, and scanning speeds.

%% Connectivity Configuration
arduinoPort = 'COM7';
baudRate = 115200;
bluetoothDeviceAddress = "002411010D19";

%% Timing and Scanning Speeds
SCAN_SPEED_SECTORS = 1.2;
SCAN_SPEED_CHARS = 1.2;
TIME_FIRST_CHAR_WAIT = 1.0;

%% Visual Configuration
CHAR_SPACING = 0.33; 
FONT_SIZE_NORMAL = 45; 
FONT_SIZE_ACTIVE = 60;

%% Signal Thresholds and Blink Logic
SILENT_LATCH_VOLTAGE = 80.0; 
EXECUTE_THRESHOLD = 80.0; 
RESET_THRESHOLD = -50.0;
gazeDurationThresholdMs = 915.0; 
strongBlinkMaxDurationSeconds = 1.5;
blinkSequenceTimeoutSeconds = 1.0; 
reentryPauseSeconds = 0.8; 
postSelectionDelaySeconds = 2.0;

%% Keyboard Mapping (Arabic Alphabet)
sectorMap = cell(1, 6);
sectorMap{1} = {'ا', 'ل', 'م', 'ي', 'و'}; 
sectorMap{2} = {'ن', 'ر', 'ب', 'ت', 'هـ'};
sectorMap{3} = {'ع', 'ك', 'د', 'س', 'ق'}; 
sectorMap{4} = {'ج', 'ف', 'ص', 'خ', 'ح'};
sectorMap{5} = {'ش', 'ز', 'ض', 'ط'};        
sectorMap{6} = {'ذ', 'ث', 'غ', 'ظ'};

%% Filter Parameters
targetTotalAmplification = 300.0; 
amplificationFactor = 25.0; 
secondaryAmplificationFactor = targetTotalAmplification / amplificationFactor;
f0 = 50; 
bw = 2; 
order = 10; 

%% System Display Colors
C_BG = [0 0 0]; 
C_NEON = [0, 0.85, 1]; 
C_DIM = [0.15 0.15 0.15]; 
