function [] = archiveResults()

[status, message] = movefile('..\results\', ['..\results-', datestr(now,'dd-mm-yyyy-HH_MM')]);
if status == 0
    message = ['folder renaming unsuccessful, ', message];
    disp(message);
end
mkdir('..\results');
end

