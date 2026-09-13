function hideSubChars(subObjs, l, secIdx)
%HIDESUBCHARS Hides sub-characters and restores main sector label.
set(subObjs, 'Visible', 'off'); 
set(l(secIdx), 'Visible', 'on'); 
end
