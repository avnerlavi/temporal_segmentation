function [varargout,MultiResSorfRespBmode] = SorfProcessing(AlgParams,TypeOfImg,TypeOfCenFltr,TypeOfSrndFltr,TypeOfOperation,varargin)

% The algorithm is based on the paper "Brightness contrast?contrast
% induction model predicts assimilation and inverted assimilation effects",
% by Y. Barken, H. Spitzer and S. Einav, 2008.

% Input parameters:
%     AlgParams - algorithm parameters
%    TypeOfImg - 'gray', 'color', 'both'
%    TypeOfCenFltr - 'avarage', 'gaussian'
%    TypeOfSrndFltr - 'avarage', 'gaussian'
%    TypeOfOperation - 'SORF', 'relative'
%                                             'SORF' -           center response minus surround response
%                                             'relative' - center divided by surround
%    varargin - first parameter: input color or gray image, that will be used instead of
%                             the Elasto or B-mode images in AlgParams
%                           second parameter: ceter sizes that are different from default center sizes
%
% Output parameters:
%    [MultiResSorfRespElasto]
%    or
%    [MultiResSorfRespElasto MultiResSorfRespBmode]
%    or
%    [MultiResSorfRespElasto MultiResSorfRespBmode LocalContrast]
%    or
%    [MultiResSorfRespElasto MultiResSorfRespBmode LocalContrast RemoteContrast]

%% SORF parameters
LocalSize = AlgParams.LocalSize;% size of local area (squer area of sizeXsize pixels)
LocalDecayCoef = AlgParams.LocalDecayCoef; % decay coefficient of filter mask in local area
RemoteSize = AlgParams.RemoteSize;% size of Remote area (squer area of sizeXsize pixels)
RemoteDecayCoef = AlgParams.RemoteDecayCoef; % decay coefficient of filter mask in Remote area

% exponent mask for local contrast calculation
LocalExponent= CalcFieldMask(LocalSize,LocalDecayCoef,0,TypeOfCenFltr);

% exponent mask for remote contrast calculation
RemoteExponent = CalcFieldMask(RemoteSize,RemoteDecayCoef,LocalSize,TypeOfCenFltr);

% images height and width (B-mode and elasto images have the same sizes)
ImgHeight = size(AlgParams.InputImg,1);
ImgWidth = size(AlgParams.InputImg,2);

% %% calculate SORF responses of different resulotions and local contrast parameter for Elasto image
% if (strcmp(TypeOfImg,'color') || strcmp(TypeOfImg,'both'))
%     % set color flag to color
%     AlgParams.ColorImageFlag = 1;
%     
%     % set InputImg parameter
%     InputImg = AlgParams.InputImgElasto;
%     
%     % center sizes
%     CenSizes = AlgParams.CenSizes.Elasto;
%     
%     % number of resolutions
%     NumOfResolElasto = length(CenSizes);
%     
%     % initialize parameters for SORF responses for different resolutions
%     SorfResponsesElasto = zeros(ImgHeight,ImgWidth,16,NumOfResolElasto);
%     
%     % loop over all rsolutions for elasto image
%     for ResolInd = 1:NumOfResolElasto
%         % size of center region
%         CenSize = CenSizes(ResolInd);
%         
%         % SORF response for current resolution
%         SorfResponseElasto = CalcSorfResponse(AlgParams,InputImg,CenSize,TypeOfCenFltr,TypeOfSrndFltr);
%         
%         % update SORF responses parameter
%         SorfResponsesElasto(:,:,:,ResolInd) = SorfResponseElasto;
%         
%         % tests
%         if AlgParams.ShowElastoRes
%             % plot results for the current resolution
%             %PlotElasto(InputImg,SorfResponseElasto,num2str(CenSize));
%         end % if AlgParams.FlagShowSorfRes
%     end % for ResolInd = 1:NumOfResolElasto
%     
%     % combine SORF responses from all the resolutions for elasto image
%     %MultiResSorfRespElasto = mean(abs(SorfResponsesElasto).^AlgParams.MultiResPowerElasto,4);
%     PowerElasto = AlgParams.MultiResPowerElasto;
%     
%     % loop over responses of different color planes
%     MultiResSorfRespElasto = zeros(size(SorfResponsesElasto));
%     MultiResSorfRespElasto = MultiResSorfRespElasto(:,:,:,1);
%     for Ind = 1:size(SorfResponsesElasto,3)
%         Responses = SorfResponsesElasto(:,:,Ind,:);
%         Responses = shiftdim(shiftdim(shiftdim(Responses,2)),1);
%         MultiResSorfRespElasto(:,:,Ind) = CombineRes(Responses,NumOfResolElasto,PowerElasto);
%     end
%     
%     % normalize response to [0 1] range
%     %     for RespInd = 1:size(MultiResSorfRespElasto,3)
%     %         MultiResSorfRespElasto(:,:,RespInd) = MultiResSorfRespElasto(:,:,RespInd)/...
%     %             max(max(MultiResSorfRespElasto(:,:,RespInd)));
%     %     end
%     
%     % test
%     if AlgParams.ShowElastoRes
%         % plot multi resolution result
%         PlotElasto(InputImg,SorfResponseElasto,'Multi');
%     end % if AlgParams.FlagShowSorfRes
% end % if (strcmp(TypeOfImg,'color') | strcmp(TypeOfImg,'both'))

%% calculate SORF responses of different resulotions and local contrast parameter for B-mode image
if (strcmp(TypeOfImg,'gray') || strcmp(TypeOfImg,'both'))
    % set color flag to gray
    AlgParams.ColorImageFlag = 0;
    
    % set parameters
    switch size(varargin,2)
        case 0 % default image is used (B-mode image)
            InputImg = AlgParams.InputImg;
            CenSizes = AlgParams.CenSizes.Im;
            OriginalImg = AlgParams.InputImg;
            InputTitle = '';
        case 1 % inputed image is used (enhanced B-mode)
            InputImg = varargin{1};
            CenSizes = AlgParams.CenSizes.Im;
            OriginalImg = AlgParams.InputImg;
            InputTitle = '';
%         case 2 % inputed image is used (intensity of Elasto image)
%             InputImg = varargin{1};
%             CenSizes = varargin{2};
%             OriginalImg = AlgParams.InputImgElasto;
%             InputTitle = '';    
%         case 3 % inputed image is used (intensity of Elasto image)
%             InputImg = varargin{1};
%             CenSizes = varargin{2};
%             OriginalImg = AlgParams.InputImgElasto;
%             InputTitle = varargin{3};
    end % switch size(varargin,2)
    
    % number of resolutions
    NumOfResolBmode = length(CenSizes);
    
    % initialize parameters for SORF responses for different resolutions
    SorfResponsesBmode = zeros(ImgHeight,ImgWidth,NumOfResolBmode);
    
    % initialize matrix for local contrast parameter
    LocalContrast = zeros(ImgHeight,ImgWidth);
    
    % initialize matrix for remote contrast parameter
    RemoteContrast = zeros(ImgHeight,ImgWidth);
    
    % loop over all rsolutions for B-mode image
    for ResolInd = 1:NumOfResolBmode
        CenSize = CenSizes(ResolInd);
        
        % SORF response for current resolution
        SorfResponseBmode = CalcSorfResponse(AlgParams,InputImg,CenSize,TypeOfCenFltr,TypeOfSrndFltr,TypeOfOperation);
        
        % update SORF responses parameter
        SorfResponsesBmode(:,:,ResolInd) = SorfResponseBmode;
        
        % calculate contrast for current resolution
        CurrentContrast = imfilter(abs(SorfResponseBmode).^2,LocalExponent,'symmetric','same')./ ...
            imfilter(abs(SorfResponseBmode).^1,LocalExponent,'symmetric','same');
        
        % update local contrast parameter
        LocalContrast = LocalContrast + CurrentContrast;
    end %for ResolInd = 1:NumOfResolBmode
    
    % normalize LocalContrast to the range [0 1]
    %LocalContrast = LocalContrast/max(LocalContrast(:));
    
    % tests
    if AlgParams.ShowBmodeRes
        figure;
        NCol = 4;
        NRow = ceil((NumOfResolBmode+2)/NCol);
        ax(1) = subplot(NRow,NCol,1); imagesc(OriginalImg); title('Original image');
        ax(2) = subplot(NRow,NCol,2); imagesc(InputImg); title(['Input image' InputTitle]);
        for ResolInd = 1:NumOfResolBmode
            Resp = SorfResponsesBmode(:,:,ResolInd);
            ax(ResolInd+2) = subplot(NRow,NCol,ResolInd+2); imagesc(Resp); %imshow(Resp,[]);
            title(['Cen res=' num2str(CenSizes(ResolInd)) ' pixs']);
        end
        linkaxes(ax);

        figure;
        NCol = 4;
        NRow = ceil((NumOfResolBmode+2)/NCol);
        ax1(1) = subplot(NRow,NCol,1); imagesc(OriginalImg); title('Original image');
        ax1(2) = subplot(NRow,NCol,2); imagesc(InputImg); title(['Input image' InputTitle]);
        for ResolInd = 1:NumOfResolBmode
            Resp = SorfResponsesBmode(:,:,ResolInd);
            %ax1(ResolInd+2) = subplot(NRow,NCol,ResolInd+2); imagesc(Resp<0);
            ax1(ResolInd+2) = subplot(NRow,NCol,ResolInd+2); imagesc(OriginalImg);
            hold on; contour(Resp<0,[0.5 0.5],'b'); hold off;
            title(['Cen resol=' num2str(CenSizes(ResolInd)) ' pixs']);
        end
        linkaxes(ax1);
        colormap gray
    end % if AlgParams.ShowBmodeRes
    
    % combine SORF responses from all the resolutions for B-mode image
    PowerBmode = AlgParams.MultiResPowerBmode;
    cost=AlgParams.Cost;
    MultiResSorfRespBmode = CombineRes(SorfResponsesBmode,NumOfResolBmode,PowerBmode,cost);
    
    if 0 % AlgParams.ShowBmodeRes
        figure;
        ax2(1) = subplot(1,2,1); imagesc(OriginalImg); title('Original image');
        hold on; contour(MultiResSorfRespBmode<0,[0.5 0.5],'b'); hold off;
        %hold on; contour(MultiResSorfRespBmode,[0 0],'b'); hold off;
        ax2(2) = subplot(1,2,2); imagesc(MultiResSorfRespBmode); title(['Multi-SORF with sign' InputTitle]);
        linkaxes(ax2);
    end
    
    % calculate remote contrast if needed
    if (strcmp(TypeOfImg,'gray') && (nargout == 3)) || (strcmp(TypeOfImg,'both') && (nargout == 4))
        RemoteContrast = imfilter(abs(LocalContrast).^2,RemoteExponent,'symmetric','same')./ ...
            imfilter(abs(LocalContrast).^1,RemoteExponent,'symmetric','same');
        
        % normalize RemoteContrast to the range [0 1]
        %RemoteContrast = RemoteContrast/max(RemoteContrast(:));
        
        % replace zeros with a small number, to avoid division in zero
        RemoteContrast(RemoteContrast == 0) = 1e-6;
    end % if (strcmp(TypeOfImg,'gray') && (nargout == 3)) || (strcmp(TypeOfImg,'both') && (nargout == 4))
end % if (strcmp(TypeOfImg,'gray') || strcmp(TypeOfImg,'both'))

%% output parameters
switch TypeOfImg
    case 'gray'
        % SORF is calculated for gray image only
        varargout(1) = {MultiResSorfRespBmode};
        
        % check which parameters to output
        switch nargout
            case 2
                varargout(2) = {LocalContrast};
            case 3
                varargout(2) = {LocalContrast};
                varargout(3) = {RemoteContrast};
        end
    case 'color'
        % output the MultiResSorfRespElasto parameter
        varargout(1) = {MultiResSorfRespElasto};
    case 'both'
        % SORF for gray image
        varargout(1) = {MultiResSorfRespBmode};
        
        % SORF for color image
        varargout(2) = {MultiResSorfRespElasto};
        
        % check which parameters to output
        switch nargout
            case 3
                varargout(3) = {LocalContrast};
            case 4
                varargout(3) = {LocalContrast};
                varargout(4) = {RemoteContrast};
        end
end % switch TypeOfImg

end % function SorfProcessing

% combine different resolutions
function MultiResResp = CombineRes(SorfResponses,NRes,Power,cost)
%MultiResResp = mean(abs(Responses).^Power,3);
%MultiResResp = MultiResResp.^(1/Power);

MultiResResp = zeros(size(SorfResponses,1),size(SorfResponses,2));
for ResolInd = 1:NRes
    % response for current resolution
    SorfResp = SorfResponses(:,:,ResolInd);
    
    % update multi resolution response
    MultiResResp = MultiResResp+sign(SorfResp*cost(ResolInd)).*(((abs(SorfResp)).^Power)*cost(ResolInd));
end % for ResolInd = 1:NRes

% normalize response: divide by the number of resolutions, take sqrt
% and put the sign of the response)
% MultiResResp = MultiResResp/NRes;%to change to adaptive avg
MultiResResp = sign(MultiResResp).*((abs(MultiResResp)).^(1/Power));
end

% plot elasto results
function PlotElasto(InputImg,SorfResponseElasto,ResolutionStr)
% titles for test images
TestImgTitles = {'Red Center Green ','Green Center Red ','Yellow Center Blue ',...
    'Blue Center Yellow ','Red Center Cyan ','Cyan Center Red ',...
    'Magenta Center Green ','Green Center Magenta '};

% filter types
FilterTypes = {'Surround','Center'};

% plot SORF results (imagesc)
for FilterTypeInd = 1:2
     figure;
    subplot(3,4,1); imagesc(InputImg); title('Input image Elasto');
    subplot(3,4,2); imagesc(InputImg); title('Input image Elasto');
    subplot(3,4,3); imagesc(InputImg); title('Input image Elasto');
    subplot(3,4,4); imagesc(InputImg); title('Input image Elasto');
    for ResponseInd = 1:8
        subplot(3,4,ResponseInd+4);
        imagesc(SorfResponseElasto(:,:,(FilterTypeInd-1)*8+ResponseInd));
        title([TestImgTitles{ResponseInd} FilterTypes{FilterTypeInd} ...
            ', Cen res = ' ResolutionStr]);
    end % for ResponseInd = 1:8
    %colormap gray;
end % for FilterTypeInd = 1:2

% plot SORF results (contour)
for FilterTypeInd = 1:2
     figure;
    ax(1) = subplot(3,4,1); imshow(InputImg,[]); title('Input image Elasto');
    ax(2) = subplot(3,4,2); imshow(InputImg,[]); title('Input image Elasto');
    ax(3) = subplot(3,4,3); imshow(InputImg,[]); title('Input image Elasto');
    ax(4) = subplot(3,4,4); imagesc(InputImg,[]); title('Input image Elasto');
    for ResponseInd = 1:8
        ax(ResponseInd+4) = subplot(3,4,ResponseInd+4); imagesc(InputImg);
        Resp = SorfResponseElasto(:,:,(FilterTypeInd-1)*8+ResponseInd);
        hold on; contour(Resp<0,[0.5 0.5],'b'); hold off;
        title([TestImgTitles{ResponseInd} FilterTypes{FilterTypeInd} ...
            ', Cen res = ' ResolutionStr]);
    end % for ResponseInd = 1:8
    linkaxes(ax);
    %colormap gray;
end % for FilterTypeInd = 1:2
end