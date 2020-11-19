function [] = writeVideoToFile(videoToWrite, fileName, fileDir)

if fileDir(end) ~= '\'
    fileDir = [fileDir, '\'];
end
if strcmp(fileName(end-4:end), '.avi') == false
    fileName = [fileName, '.avi'];
end
filePath = [fileDir, fileName];
aviobj = VideoWriter(filePath);
aviobj.Quality = 80;
open(aviobj);
for i =1:size(videoToWrite,3)
    writeVideo(aviobj, videoToWrite(:,:,i));
end
close(aviobj);

end

