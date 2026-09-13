function highlightInnerSector(innerW, innerL, activeIdx, cOn, maxItems)
%HIGHLIGHTINNERSECTOR Highlights the currently active character in the spell interface.
%
% Inputs:
%   innerW    - Inner patch objects for characters.
%   innerL    - Inner text objects for characters.
%   activeIdx - Index of the currently active character.
%   cOn       - RGB triplet for the highlight color.
%   maxItems  - Total number of items in the current sector.

baseColors = [0.10, 0.15, 0.35; 0.10, 0.25, 0.20; 0.30, 0.12, 0.30; 0.28, 0.18, 0.08; 0.08, 0.20, 0.35; 0.35, 0.10, 0.10];
for k = 1:maxItems
    if ~strcmp(get(innerW(k), 'Visible'), 'on')
        continue; 
    end
    
    if k == activeIdx
        set(innerW(k), 'FaceColor', cOn, 'EdgeColor', 'w', 'LineWidth', 3); 
        set(innerL(k), 'Color', [0 0 0], 'FontSize', 26);
    else
        if k == maxItems
            set(innerW(k), 'FaceColor', [0.35, 0.05, 0.05], 'EdgeColor', [0.5 0.5 0.7], 'LineWidth', 2.5); 
            set(innerL(k), 'Color', [1.0, 0.45, 0.45], 'FontSize', 20);
        else
            faceC = baseColors(mod(k-1, size(baseColors,1)) + 1, :); 
            set(innerW(k), 'FaceColor', faceC, 'EdgeColor', [0.5 0.5 0.7], 'LineWidth', 2.5); 
            set(innerL(k), 'Color', [0.85 0.85 0.85], 'FontSize', 22); 
        end
    end
end
end
