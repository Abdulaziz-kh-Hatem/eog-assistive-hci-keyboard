function activateInsideView(subObjs, w, l, innerW, innerL, secIdx, map, cBg, cOn, ~, ~, ~)
%ACTIVATEINSIDEVIEW Renders the detailed character selection view for a sector.
%
% Inputs:
%   subObjs - Graphics objects for sub-characters.
%   w       - Main sector patch objects.
%   l       - Main sector text objects.
%   innerW  - Inner patch objects for individual characters.
%   innerL  - Inner text objects for individual characters.
%   secIdx  - Index of the currently active main sector.
%   map     - Cell array mapping sectors to characters.
%   cBg     - RGB triplet for the background color.
%   cOn     - RGB triplet for the active highlight color.

set(w, 'FaceColor', cBg, 'EdgeColor', 'none'); 
set(l, 'Visible', 'off');

chars = map{secIdx}; 
n = length(chars); 
totalItems = n + 1;

baseColors = [0.10, 0.15, 0.35; 0.10, 0.25, 0.20; 0.30, 0.12, 0.30; 0.28, 0.18, 0.08; 0.08, 0.20, 0.35; 0.35, 0.10, 0.10];
angleStep = 360 / totalItems; 
startAngle = 90;

for k = 1:totalItems
    a1 = deg2rad(startAngle - (k-1)*angleStep); 
    a2 = deg2rad(startAngle - k*angleStep); 
    theta = linspace(a1, a2, 60);
    
    if k <= n
        faceC = baseColors(mod(k-1, size(baseColors,1)) + 1, :); 
    else
        faceC = [0.35, 0.05, 0.05]; 
    end
    
    set(innerW(k), 'XData', [0, cos(theta), 0], 'YData', [0, sin(theta), 0], 'FaceColor', faceC, 'EdgeColor', [0.5 0.5 0.7], 'LineWidth', 2.5, 'Visible', 'on', 'FaceAlpha', 0.9);
        
    midAngle = (a1 + a2) / 2; 
    textR = 0.62;
    
    if k <= n
        labelStr = chars{k}; 
        lblColor = [0.85 0.85 0.85]; 
        lblSize = 22; 
    else
        labelStr = 'DELETE'; 
        lblColor = [1.0, 0.45, 0.45]; 
        lblSize = 20; 
    end
    
    set(innerL(k), 'Position', [textR * cos(midAngle), textR * sin(midAngle), 0], 'String', labelStr, 'Color', lblColor, 'FontSize', lblSize, 'FontWeight', 'bold', 'Visible', 'on');
end

for k = totalItems+1 : length(innerW)
    set(innerW(k), 'Visible', 'off'); 
    set(innerL(k), 'Visible', 'off'); 
end

set(innerW(1), 'FaceColor', cOn, 'EdgeColor', 'w', 'LineWidth', 3); 
set(innerL(1), 'Color', [0 0 0], 'FontSize', 26);
end
