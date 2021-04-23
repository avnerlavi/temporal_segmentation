function [] = writeVideoToFile(videoToWrite, fileName, fileDir)

if fileDir(end) ~= '\'
    fileDir = [fileDir, '\'];
end
if strcmp(fileName(end-3:end), '.avi') == false
    fileName = [fileName, '.avi'];
end
mkdir(fileDir);

filePath = [fileDir, fileName];
aviobj = VideoWriter(filePath);
aviobj.Quality = 80;
open(aviobj);
videoSize = size(videoToWrite);
if (length(videoSize)) == 3
    for i =1:size(videoToWrite, 3)
        writeVideo(aviobj, videoToWrite(:,:,i));
    end    
elseif (length(videoSize)) == 4
    for i =1:size(videoToWrite, 4)
        writeVideo(aviobj, videoToWrite(:,:,:,i));
    end    
end

close(aviobj);

end

