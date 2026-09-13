%% BCI Smart Wheelchair & Virtual Keyboard System
% This script runs the real-time EOG acquisition and classification pipeline
% to control a wheelchair and a virtual speller interface.

clear; close all; clc;
addpath('utils');

%% 1. Initialization and Configuration
fprintf('Starting BCI Wheelchair & Speller System... \n');
config; % Load parameters from config.m

% Initialize Bluetooth connection to wheelchair
b_dev = []; 
bt_ok = false;
fprintf('Connecting to Bluetooth Wheelchair (%s)...\n', bluetoothDeviceAddress);
try
    b_dev = bluetooth(bluetoothDeviceAddress, 1);
    fopen(b_dev);
    bt_ok = true;
    fprintf('>> Bluetooth connection SUCCESSFUL.\n');
catch
    fprintf(2, '>> Bluetooth connection FAILED. System continuing without wheelchair connection.\n');
end

% Initialize Serial connection for signal acquisition
s = [];
try
    fprintf('Connecting to Serial Port %s (Signal Acquisition)...\n', arduinoPort);
    existing_port = serialportfind('Port', arduinoPort);
    if ~isempty(existing_port)
        delete(existing_port); 
        pause(1.5); 
    end
    s = serialport(arduinoPort, baudRate); 
    configureTerminator(s, "LF");
    fprintf('>> Serial connection successful.\n');
catch exception
    fprintf(2, 'Error: %s\n', exception.message); 
    return; 
end

%% 2. Signal Processing Setup
fprintf('Flushing Buffer...\n'); 
flush(s); 
measuredFs = 250; 
fprintf('>> Fs Locked to: %d Hz.\n', measuredFs);

% Filter design (Notch filter for powerline interference)
nyquist = measuredFs / 2;
[b_notch, a_notch] = butter(order/2, [(f0 - bw/2)/nyquist, (f0 + bw/2)/nyquist], 'stop');

% Time vector and sample threshold conversions
scrollWidth = 2000; 
timeVector = (0:scrollWidth-1) / measuredFs;
samples_Gaze = round(measuredFs * (gazeDurationThresholdMs / 1000.0));
samples_BlinkMax = round(measuredFs * strongBlinkMaxDurationSeconds);
samples_Timeout = round(measuredFs * blinkSequenceTimeoutSeconds);
samples_Reentry = round(measuredFs * reentryPauseSeconds);
samples_FirstWait = round(measuredFs * TIME_FIRST_CHAR_WAIT);
samples_ScanSec = round(measuredFs * SCAN_SPEED_SECTORS);
samples_ScanChar = round(measuredFs * SCAN_SPEED_CHARS);

%% 3. User Interface Construction
hFig = figure('Name', 'BCI Smart Wheelchair & Speller', 'NumberTitle', 'off', ...
    'Color', C_BG, 'Units', 'normalized', 'Position', [0 0 1 1], 'MenuBar', 'none');

% Signal Visualization Axes
axSig = axes('Parent', hFig, 'Units', 'normalized', 'Position', [0.05, 0.80, 0.85, 0.15], ...
    'Color', [0.05 0.05 0.05], 'XColor', 'w', 'YColor', 'w', 'XLim', [0 timeVector(end)], 'YLim', [-100 100]);
hold(axSig, 'on'); grid(axSig, 'on');
hLine = plot(axSig, timeVector, NaN(1, scrollWidth), 'Color', C_NEON, 'LineWidth', 2);
yline(axSig, EXECUTE_THRESHOLD, '-.r', 'LineWidth', 1.5); 
yline(axSig, RESET_THRESHOLD, '-.c', 'LineWidth', 1.5);

% Wheelchair Control Panel
pnlWheel = uipanel('Parent', hFig, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.6], ...
    'BackgroundColor', C_BG, 'BorderType', 'none', 'Visible', 'on');
uicontrol('Parent', pnlWheel, 'Style', 'text', 'String', 'WHEELCHAIR', 'Units', 'normalized', ...
    'Position', [0.1 0.5 0.8 0.2], 'BackgroundColor', C_BG, 'ForegroundColor', C_NEON, 'FontSize', 50, 'FontWeight', 'bold');
txtWheelSt = uicontrol('Parent', pnlWheel, 'Style', 'text', 'String', 'STANDBY', 'Units', 'normalized', ...
    'Position', [0.1 0.3 0.8 0.15], 'BackgroundColor', C_BG, 'ForegroundColor', 'w', 'FontSize', 24);

% Virtual Keyboard Panel
pnlSpell = uipanel('Parent', hFig, 'Units', 'normalized', 'Position', [0.05 0.02 0.9 0.75], ...
    'BackgroundColor', C_BG, 'BorderType', 'none', 'Visible', 'off');
txtOut = uicontrol('Parent', pnlSpell, 'Style', 'edit', 'Units', 'normalized', 'Position', [0.1 0.9 0.8 0.1], ...
    'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'w', 'FontSize', 30, 'String', '', 'Enable', 'inactive', 'FontWeight', 'bold');
axCirc = axes('Parent', pnlSpell, 'Units', 'normalized', 'Position', [0 0 1 0.88], ...
    'Color', C_BG, 'XColor', 'none', 'YColor', 'none', 'XLim', [-1.1 1.1], 'YLim', [-1.1 1.1]);
axis(axCirc, 'equal'); hold(axCirc, 'on');

% Main Sectors Construction
NUM_SECTORS = 6; 
wedges = gobjects(1, NUM_SECTORS); 
lbls = gobjects(1, NUM_SECTORS); 
angles = linspace(90, -270, NUM_SECTORS + 1);
for i=1:NUM_SECTORS
    th = linspace(deg2rad(angles(i)), deg2rad(angles(i+1)), 50);
    wedges(i) = patch(axCirc, [0,cos(th),0], [0,sin(th),0], C_DIM, 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 2);
    lbls(i) = text(axCirc, 0.65*cos((deg2rad(angles(i))+deg2rad(angles(i+1)))/2), ...
        0.65*sin((deg2rad(angles(i))+deg2rad(angles(i+1)))/2), strjoin(sectorMap{i},' '), ...
        'Color', 'w', 'FontSize', 18, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

% Inner Character Sectors Construction
MAX_INNER_ITEMS = 6; 
innerWedges = gobjects(1, MAX_INNER_ITEMS); 
innerLbls = gobjects(1, MAX_INNER_ITEMS); 
subCharObjs = gobjects(1, MAX_INNER_ITEMS);
for k = 1:MAX_INNER_ITEMS
    innerWedges(k) = patch(axCirc, NaN, NaN, [0.1 0.1 0.25], 'EdgeColor', [0.4 0.4 0.6], 'LineWidth', 2, 'Visible', 'off');
    innerLbls(k)   = text(axCirc, 0, 0, '', 'Color', 'w', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Visible', 'off');
    subCharObjs(k) = text(axCirc, 0, 0, '', 'Visible', 'off');
end
txtSpSt = text(axCirc, 0, -1.1, 'READY', 'Color', C_NEON, 'FontSize', 16, 'HorizontalAlignment', 'center');

%% 4. Real-Time Processing Loop
voltageDataToPlot = NaN(1, scrollWidth); 
rawBufferSmooth = NaN(1, 3); 
dcBuffer = NaN(1, 150);
maFilterBuffer = NaN(1, 7); 
zi_main = zeros(max(length(b_notch), length(a_notch)) - 1, 1);

mode = 'WHEEL'; 
wheelState = 'STOP'; 
spellState = 'SECTOR'; 
currSec = 1; 
currChar = 1; 
sectorHistory = [];
latchedSec = 1; 
latchedChar = 1; 
tempLatchedSec = 1; 
tempLatchedChar = 1; 
isSignalRising = false;
count = 0; 
timerScan = 0; 
timerPause = 0; 
blinkState = 0; 
startCross = 0; 
blinkCount = 0; 
lastBlinkEnd = 0; 
prevVal = 0;

updateSectorVisuals(wedges, lbls, 1, C_NEON, C_DIM);
flush(s);

while ishandle(hFig)
    if s.NumBytesAvailable > 0
        try
            lineStr = readline(s); 
            valRaw = str2double(lineStr); 
            if isnan(valRaw), continue; end
            count = count + 1;

            % 4.1 Signal Preprocessing Pipeline
            voltageRaw = valRaw * (5.0 / 1023.0);
            rawBufferSmooth = [rawBufferSmooth(2:end), voltageRaw]; 
            vToProc = mean(rawBufferSmooth,'omitnan');
            
            dcBuffer = [dcBuffer(2:end), vToProc]; 
            vDC = mean(dcBuffer,'omitnan');

            voltageFinal = NaN;
            if ~isnan(vDC)
                vAC = vToProc - vDC;
                [vAC, zi_main] = filter(b_notch, a_notch, vAC, zi_main);
                vAmp = vAC * amplificationFactor;
                maFilterBuffer = [maFilterBuffer(2:end), vAmp]; 
                vMA = mean(maFilterBuffer,'omitnan');
                voltageFinal = vMA * secondaryAmplificationFactor;
            end

            % Update UI Plot
            if ~isnan(voltageFinal)
                voltageDataToPlot = [voltageDataToPlot(2:end), voltageFinal];
                if mod(count, 5) == 0
                    set(hLine, 'YData', voltageDataToPlot); 
                end
            end

            % 4.2 Blink Detection State Machine
            detectType = 0;
            if ~isnan(voltageFinal) && ~isnan(prevVal)
                if voltageFinal > SILENT_LATCH_VOLTAGE && ~isSignalRising
                    tempLatchedSec = currSec; 
                    tempLatchedChar = currChar; 
                    isSignalRising = true;
                end
                if blinkState == 0 && prevVal < EXECUTE_THRESHOLD && voltageFinal >= EXECUTE_THRESHOLD
                    blinkState = 1; 
                    startCross = count; 
                    latchedSec = tempLatchedSec; 
                    latchedChar = tempLatchedChar;
                elseif blinkState == 1
                    if voltageFinal <= RESET_THRESHOLD
                        dur = count - startCross; 
                        blinkState = 0;
                        if dur < samples_Gaze
                            detectType = 1; 
                        else
                            detectType = 2; 
                        end
                    elseif (count - startCross) > samples_BlinkMax
                        blinkState = 0; 
                    end
                end
                if voltageFinal < RESET_THRESHOLD
                    isSignalRising = false; 
                end
            end
            prevVal = voltageFinal;

            % 4.3 Control & Navigation Logic
            if count > timerPause
                if strcmp(mode, 'SPELL')
                    limit = samples_ScanSec; 
                    if strcmp(spellState, 'CHAR')
                        limit = samples_ScanChar; 
                    end
                    
                    if (count - timerScan) > limit
                        if strcmp(spellState, 'SECTOR')
                            currSec = mod(currSec, NUM_SECTORS) + 1; 
                            updateSectorVisuals(wedges, lbls, currSec, C_NEON, C_DIM);
                        else
                            chars = sectorMap{currSec}; 
                            totalItems = length(chars) + 1;
                            currChar = mod(currChar, totalItems) + 1;
                            highlightInnerSector(innerWedges, innerLbls, currChar, C_NEON, totalItems);
                        end
                        timerScan = count;
                    end
                end

                if detectType == 1
                    if (count - lastBlinkEnd) > samples_Timeout
                        blinkCount = 1; 
                    else
                        blinkCount = blinkCount + 1; 
                    end
                    lastBlinkEnd = count; 
                    strSt = sprintf('BLINKS: %d', blinkCount);
                    
                    if strcmp(mode,'WHEEL')
                        set(txtWheelSt,'String',strSt); 
                    else
                        set(txtSpSt,'String',strSt); 
                    end
                elseif detectType == 2
                    blinkCount = 0;
                    if strcmp(mode, 'SPELL')
                        if strcmp(spellState, 'CHAR')
                            spellState = 'SECTOR'; 
                            hideInnerSectors(innerWedges, innerLbls); 
                            hideSubChars(subCharObjs, lbls, currSec); 
                            updateSectorVisuals(wedges, lbls, currSec, C_NEON, C_DIM);
                            timerPause = count + samples_Reentry; 
                            timerScan = timerPause;
                        else
                            txt = char(get(txtOut, 'String')); 
                            if ~isempty(txt)
                                set(txtOut, 'String', txt(1:end-1)); 
                            end
                            set(txtSpSt, 'String', 'BACKSPACE'); 
                            if ~isempty(sectorHistory)
                                sectorHistory(end) = []; 
                            end
                        end
                    end
                end

                % Command Execution based on Blink Count
                if (blinkCount > 0) && ((count - lastBlinkEnd) > samples_Timeout)
                    cmd = blinkCount; 
                    blinkCount = 0;

                    if cmd >= 4
                        set(txtOut, 'String', ''); 
                        sectorHistory = []; 
                        
                        if strcmp(mode, 'WHEEL')
                            wheelState = 'STOP';
                            if bt_ok
                                fprintf(b_dev, '2'); 
                            end 
                            mode = 'SPELL'; 
                            set(pnlWheel, 'Visible','off'); 
                            set(pnlSpell, 'Visible','on');
                            spellState='SECTOR'; 
                            currSec=1; 
                            updateSectorVisuals(wedges, lbls, 1, C_NEON, C_DIM);
                        else
                            mode = 'WHEEL'; 
                            set(pnlSpell, 'Visible','off'); 
                            set(pnlWheel, 'Visible','on');
                            hideInnerSectors(innerWedges, innerLbls); 
                            hideSubChars(subCharObjs, lbls, currSec);
                        end
                        
                    elseif strcmp(mode, 'WHEEL')
                        if cmd == 1
                            if strcmp(wheelState, 'STOP') || strcmp(wheelState, 'BACKWARD')
                                wheelState = 'FORWARD';
                                if bt_ok, fprintf(b_dev, '1'); end
                                set(txtWheelSt, 'String', 'FORWARD');
                            elseif strcmp(wheelState, 'FORWARD')
                                wheelState = 'ROTATING';
                                if bt_ok, fprintf(b_dev, '4'); end
                                set(txtWheelSt, 'String', 'ROTATING');
                            elseif strcmp(wheelState, 'ROTATING')
                                wheelState = 'FORWARD';
                                if bt_ok, fprintf(b_dev, '1'); end
                                set(txtWheelSt, 'String', 'FORWARD');
                            end
                            
                        elseif cmd == 2
                            if strcmp(wheelState, 'STOP')
                                wheelState = 'ROTATING';
                                if bt_ok, fprintf(b_dev, '4'); end
                                set(txtWheelSt, 'String', 'ROTATING');
                            else
                                wheelState = 'STOP';
                                if bt_ok, fprintf(b_dev, '2'); end
                                set(txtWheelSt, 'String', 'STOP');
                            end
                            
                        elseif cmd == 3
                            wheelState = 'BACKWARD';
                            if bt_ok, fprintf(b_dev, '3'); end
                            set(txtWheelSt, 'String', 'BACKWARD');
                        end
                    
                    elseif strcmp(mode, 'SPELL')
                        if cmd == 1
                            if strcmp(spellState, 'SECTOR')
                                targetSec = latchedSec; 
                                sectorHistory = [sectorHistory, targetSec];
                                spellState = 'CHAR'; 
                                currChar = 1; 
                                currSec = targetSec; 
                                activateInsideView(subCharObjs, wedges, lbls, innerWedges, innerLbls, currSec, sectorMap, C_BG, C_NEON, CHAR_SPACING, FONT_SIZE_NORMAL, FONT_SIZE_ACTIVE);
                                timerScan = count + samples_FirstWait;
                            else
                                targetIdx = latchedChar; 
                                chars = sectorMap{currSec};
                                if targetIdx > length(chars)
                                    txt = char(get(txtOut, 'String')); 
                                    if ~isempty(txt)
                                        set(txtOut, 'String', txt(1:end-1)); 
                                    end
                                    set(txtSpSt, 'String', 'BACKSPACE'); 
                                    timerPause = count + samples_Reentry; 
                                    timerScan = timerPause;
                                else
                                    charToWrite = chars{targetIdx};
                                    txt = get(txtOut, 'String'); 
                                    set(txtOut, 'String', [txt charToWrite]);
                                    spellState = 'SECTOR'; 
                                    hideInnerSectors(innerWedges, innerLbls); 
                                    hideSubChars(subCharObjs, lbls, currSec); 
                                    updateSectorVisuals(wedges, lbls, currSec, C_NEON, C_DIM);
                                    latchedSec = 0; 
                                    set(txtSpSt, 'String', ['SELECTED: ' charToWrite]); 
                                    timerPause = count + samples_Reentry; 
                                    timerScan = timerPause + round(measuredFs * 0.5);
                                end
                            end
                        elseif cmd == 2
                            if strcmp(spellState, 'SECTOR')
                                txt = char(get(txtOut, 'String'));
                                if ~isempty(txt)
                                    set(txtOut, 'String', txt(1:end-1)); 
                                    if ~isempty(sectorHistory)
                                        lastGroup = sectorHistory(end); 
                                        sectorHistory(end) = []; 
                                        sectorHistory = [sectorHistory, lastGroup];
                                        currSec = lastGroup; 
                                        spellState = 'CHAR'; 
                                        currChar = 1;
                                        activateInsideView(subCharObjs, wedges, lbls, innerWedges, innerLbls, currSec, sectorMap, C_BG, C_NEON, CHAR_SPACING, FONT_SIZE_NORMAL, FONT_SIZE_ACTIVE);
                                        timerScan = count + samples_FirstWait; 
                                        set(txtSpSt, 'String', 'SMART CORRECTION');
                                    end
                                end
                            else
                                txt = get(txtOut, 'String'); 
                                set(txtOut, 'String', [txt ' ']); 
                            end
                        elseif cmd == 3
                            if strcmp(spellState, 'CHAR')
                                spellState = 'SECTOR'; 
                                hideInnerSectors(innerWedges, innerLbls); 
                                hideSubChars(subCharObjs, lbls, currSec); 
                                updateSectorVisuals(wedges, lbls, currSec, C_NEON, C_DIM);
                                set(txtSpSt, 'String', 'EXIT GROUP'); 
                                timerPause = count + samples_Reentry; 
                                timerScan = timerPause;
                            else
                                set(txtOut, 'String', ''); 
                                sectorHistory = []; 
                                set(txtSpSt, 'String', 'CLEAR ALL'); 
                            end
                        end
                    end
                end
            end
            drawnow limitrate;
        catch
            continue; 
        end
    end
end

