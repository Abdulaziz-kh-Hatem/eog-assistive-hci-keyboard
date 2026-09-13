function updateSectorVisuals(w, l, idx, cOn, cOff)
%UPDATESECTORVISUALS Highlights the active sector in the virtual keyboard.
%
% Inputs:
%   w    - Patch graphics objects for the sectors.
%   l    - Text graphics objects for the sector labels.
%   idx  - Index of the sector to highlight.
%   cOn  - RGB triplet for the active sector color.
%   cOff - RGB triplet for the inactive sector color.

set(w, 'FaceColor', cOff, 'EdgeColor', [0.3 0.3 0.3]);
set(l, 'Visible', 'on', 'Color', 'w', 'FontSize', 18);
set(w(idx), 'FaceColor', cOn, 'EdgeColor', 'w');
set(l(idx), 'Color', 'k', 'FontSize', 22);
end
