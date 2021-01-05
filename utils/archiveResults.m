function [] = archiveResults()
root = getenv('TemporalSegmentation');
[status, message] = movefile([root,'\results\'], [root,'\results-', datestr(now,'dd-mm-yyyy-HH_MM')]);
if status == 0
    message = ['folder renaming unsuccessful, ', message];
    disp(message);
end
mkdir([root,'\results']);
end

