function SorfResponse = CalcSorfResponse(AlgParams,InputImg,CenSize,TypeOfCenFltr,TypeOfSrndFltr,TypeOfOperation)

% size of receptive field
FieldSize = AlgParams.FieldSizeFactor*CenSize;

% decay coefficient of surround mask
SrndDecayCoef = AlgParams.SrndDecayCoefFactor*CenSize;

% decay coefficient of center mask
CenDecayCoef = AlgParams.CenDecayCoefFactor*CenSize;

% calculate center and surround masks
CenterMask = CalcFieldMask(CenSize,CenDecayCoef,0,TypeOfCenFltr);
SurroundMask = CalcFieldMask(FieldSize,SrndDecayCoef,CenSize,TypeOfSrndFltr);

% calculate SORF response
% check if the image is colored
if AlgParams.ColorImageFlag % color image 
    % initialize SorfResponse parameter
    SorfResponse = zeros(size(InputImg,1),size(InputImg,2), 16);
    
    % RGB layers of the image
    R = double(InputImg(:,:,1));
    G = double(InputImg(:,:,2));
    B= double(InputImg(:,:,3));
    
    %caculate SORF response for color image
    % filter color planes with center filter
    RCen = imfilter(R,CenterMask ,'symmetric','same'); % red filtered by center filter
    GCen = imfilter(G,CenterMask ,'symmetric','same'); % green filtered by center filter
    BCen = imfilter(B,CenterMask ,'symmetric','same') ; % blue filtered by center filter
    CCen = imfilter((G+B)/2,CenterMask ,'symmetric','same'); % cyan (green+blue) filtered by center filter
    MCen = imfilter((B+R)/2,CenterMask ,'symmetric','same'); % magenta (blue+red) filtered by center filter
    YCen = imfilter((R+G)/2,CenterMask ,'symmetric','same'); % yello (red+green) filtered by center filter
    
    % filter color planes with surround filter
    RSrnd = imfilter(R,SurroundMask ,'symmetric','same'); % red filtered by surround filter
    GSrnd = imfilter(G,SurroundMask ,'symmetric','same'); % green filtered by surround filter
    BSrnd = imfilter(B,SurroundMask ,'symmetric','same') ; % blue filtered by surround filter
    CSrnd = imfilter((G+B)/2,SurroundMask ,'symmetric','same'); % cyan (green+blue) filtered by surround filter
    MSrnd = imfilter((B+R)/2,SurroundMask ,'symmetric','same'); % magenta (blue+red) filtered by surround filter
    YSrnd = imfilter((R+G)/2,SurroundMask ,'symmetric','same'); % yello (red+green) filtered by surround filter

    % update SorfResponse parameter
    % center-surround responses
    SorfResponse(:,:,1) = RCen-GSrnd; % opponent colors:  red in center area, green in surround area
    SorfResponse(:,:,2) = GCen-RSrnd; % opponent colors:  green in the center area - red in the surround area
    SorfResponse(:,:,3) = YCen-BSrnd; % complementary colors: yellow in center area - blue in surround area
    SorfResponse(:,:,4) = BCen-YSrnd; % complementary colors: blue in center area - yellow in surround area
    SorfResponse(:,:,5) = RCen-CSrnd; % complementary colors: red in center area - cyan in surround area
    SorfResponse(:,:,6) = CCen-RSrnd; % complementary colors: cyan in center area - red in surround area
    SorfResponse(:,:,7) = MCen-GSrnd; % complementary colors: magenta in center area - green in surround area
    SorfResponse(:,:,8) = GCen-MSrnd; % complementary colors: green in center area - magenta in surround area
    
    % center-center responses
    SorfResponse(:,:,9) =   RCen-GCen; % opponent colors:  red in center area, green in center area
    SorfResponse(:,:,10) = GCen-RCen; % opponent colors:  green in the center area - red in the center area
    SorfResponse(:,:,11) = YCen-BCen; % complementary colors: yellow in center area - blue in center area
    SorfResponse(:,:,12) = BCen-YCen; % complementary colors: blue in center area - yellow in center area
    SorfResponse(:,:,13) = RCen-CCen; % complementary colors: red in center area - cyan in center area
    SorfResponse(:,:,14) = CCen-RCen; % complementary colors: cyan in center area - red in center area
    SorfResponse(:,:,15) = MCen-GCen; % complementary colors: magenta in center area - green in center area
    SorfResponse(:,:,16) = GCen-MCen; % complementary colors: green in center area - magenta in center area
        
    % adapt response
%     for RespInd = 1:size(SorfResponse,3)
%         % put 0 instead of positive response
%         Temp = SorfResponse(:,:,RespInd);
%         Temp(Temp>0) = 0;
%         SorfResponse(:,:,RespInd) = Temp;
%         
%         % normalize response to [0 1] range 
%         SorfResponse(:,:,RespInd) = SorfResponse(:,:,RespInd)/max(max(SorfResponse(:,:,RespInd)));
%     end    
else % gray image     
    % the lumanance of a gray image is the image itself
    LumImg = double(InputImg(:,:,1));
    
    % caculate SORF of relative response on luminance image
    if strcmp(TypeOfOperation,'SORF') % SORF response
        % center response
        CenResponse = imfilter(LumImg,CenterMask,'symmetric','same');
        
        % surround response
        SrndResponse = imfilter(LumImg,SurroundMask,'symmetric','same');
        
        % center response minus surround response
        SorfResponse = CenResponse-SrndResponse; 
    elseif strcmp(TypeOfOperation,'relative') % Relative response (center divided by surround)
        % center response
        CenResponse = imfilter(LumImg,CenterMask,'symmetric','same');
        
        % surround response
        SrndResponse = imfilter(LumImg,SurroundMask,'symmetric','same');
        %SrndResponse(SrndResponse<=1e-3) = 0;
        
        % put zero in places surrounded by zero
        CenResponse(SrndResponse == 0) = 0;
                
        % replace zeros with a small number, to avoid division in zero
        SrndResponse(SrndResponse == 0) = 1e-1;
        
        % center response divided by surround response
        SorfResponse = CenResponse./SrndResponse;
    else % error
        errordlg('Wrong type of operation','Function "CalcSorfResponse"');
    end
    
    % normalize response to [0 1] range
    %SorfResponse = SorfResponse/max(SorfResponse(:));
end % if AlgParams.ColorImageFlag  

end % function SorfResponse = CalcSorfResponse(AlgParams,InputImg,CenSize,TypeOfCenFltr,TypeOfSrndFltr,TypeOfOperation)