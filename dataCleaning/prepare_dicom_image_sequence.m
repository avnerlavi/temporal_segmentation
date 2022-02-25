dir_in = 'F:\Matlab\docs\temporal_segmentation\resources\material+from_ynon_19_1_22\raw_data\obesity_1';
listing = dir(dir_in);
video = [];
save_dir = 'F:\Matlab\docs\temporal_segmentation\resources\material+from_ynon_19_1_22\edited\obesity_1';
if(~isempty(save_dir))
    mkdir(save_dir);
end
ignore_stills = false;
for i = 1:length(listing)
    if(listing(i).isdir == false && size(listing(i).name,2)>4 && strcmp(listing(i).name(end-3:end),'.dcm') == true)
        underscore_idx = find(listing(i).name == '_',1,'last');
        file_idx = listing(i).name(underscore_idx+1:end-4) ;
        if(strcmp(file_idx,'OB'))
            continue;
        end
        file_idx = str2double(file_idx);
        file = dicomread([listing(i).folder,'\',listing(i).name]);
        listing(i).data = file;
        if(length(size(file))==3)
            if(ignore_stills == false)
                img = rgb2gray(file);
                label_mat = bwlabel(img~=0);
                roi_idx = label_mat(end/2,end/2);
                if(roi_idx~=0)
                    obj_mask = (label_mat == roi_idx);
                    bbox(1) = find(any(obj_mask,1),1,'first');
                    bbox(3) = find(any(obj_mask,1),1,'last');
                    bbox(3) = bbox(3) - bbox(1);
                    bbox(2) = find(any(obj_mask,2),1,'first');
                    bbox(4) = find(any(obj_mask,2),1,'last');
                    bbox(4) = bbox(4) - bbox(2);
                else
                    imshow(img);
                    hold on;
                    for row = 1 : 50 : size(img,1)
                        line([1, size(img,2)], [row, row], 'Color', 'g');
                    end
                    for col = 1 : 50 : size(img,2)
                        line([col, col], [1, size(img,1)], 'Color', 'g');
                    end
                    hold off
                    bbox = getrect();
                end
                hold on
                imshow(img)
                rectangle('Position',bbox,'EdgeColor','r')
                hold off
                drawnow();
                pause(1)
                if(bbox(3)~=0 && bbox(4)~=0)
                    img = img(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
                    imwrite(img,[save_dir,'\',listing(i).name(1:end-4),'.png'])
                end
            end
        elseif(length(size(file))==4)
            video = mean(file,3); % rgb2gray
            first_frame = file(:,:,1);
            label_mat = bwlabel(first_frame~=0);
            roi_idx = label_mat(end/2,end/2);
            if(roi_idx~=0)
                obj_mask = (label_mat == roi_idx);
                bbox(1) = find(any(obj_mask,1),1,'first');
                bbox(3) = find(any(obj_mask,1),1,'last');
                bbox(3) = bbox(3) - bbox(1);
                bbox(2) = find(any(obj_mask,2),1,'first');
                bbox(4) = find(any(obj_mask,2),1,'last');
                bbox(4) = bbox(4) - bbox(2);
            else
                imshow(first_frame);
                hold on;
                for row = 1 : 50 : size(first_frame,1)
                    line([1, size(first_frame,2)], [row, row], 'Color', 'g');
                end
                for col = 1 : 50 : size(first_frame,2)
                    line([col, col], [1, size(first_frame,1)], 'Color', 'g');
                end
                hold off
                bbox = getrect();
            end
            if(bbox(3)~=0 && bbox(4)~=0)
                video = video(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
                video = double(video)/255;
                writeVideoToFile(video, listing(i).name(1:end-4), save_dir);
            end
            
        end
        
    end
end


