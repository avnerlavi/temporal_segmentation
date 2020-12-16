function maintainFitToWindow()
set(0,'showHiddenHandles','on');
fig_handle = gcf;  
fig_handle.findobj; % to view all the linked objects with the vision.VideoPlayer
ftw = fig_handle.findobj('TooltipString', 'Maintain fit to window');   % this will search the object in the figure which has the respective 'TooltipString' parameter.
ftw.ClickedCallback();  % execute the callback linked with this object
end
