function [EdgeMask ImgWithEdge] = EdgeDetecting(AlgParams,ImageUsed,mask)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description
%       This function detects the edge of a US breast lesion.
%
% Usage:
%        EdgeMask = ActivContSeg(AlgParams,ImageUsed)
%
% Input:
%       AlgParams: algorithm parameters.
%       ImageUsed: a string, indicats whether to use B-mode, Elasto or both images
%       for the segmentation process. can be:  'gray', 'color', or 'both'.
%
% Output:
%       EdgeMask: lesion contour.
%       ImgWithEdge: Image with edge.
%
% Author:
%       Itai Lang, July/2012
%
% Last modification:
%      July/2012 - Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(ImageUsed,'gray') || strcmp(ImageUsed,'both'))
        % gray image 
        AlgParams.ColorImageFlag = 0;
        
        % B-mode input image
        InputImg = AlgParams.InputImg;
        
        %% prepare masks
        % local intensity:
        % use only first layer of the image and convert to double
        InputImgDouble = double(InputImg(:,:,1));
                
        % create average filter
        AvrgFilt = ones(AlgParams.AvrgFiltSize);
        AvrgFilt = AvrgFilt/sum(AvrgFilt(:));
        
        % calculate local intensity
        % LocalIntenTest = imfilter(InputImgDouble,AvrgFilt ,'symmetric','same');
        %LocalIntenMask = medfilt2(InputImgDouble,[4 4]);
        LocalIntenMask = ImgEnhance(AlgParams,InputImg);
        LocalIntenMask = double(LocalIntenMask);
        
        % normalize local intensity to the range [0 1]
        %LocalIntenMask = LocalInten/max(LocalInten(:));
        
        % relative intensity:
        % normalize to the range [0 1]
        %RelativeIntenMask = AlgParams.MultiRelativeInten;
        RelativeIntenMask=mask;
        %RelativeIntenMask(RelativeIntenMask>2) = 2;
        %RelativeIntenMask = RelativeIntenMask/2;
        %RelativeIntenMask = AlgParams.RelativeInten/max(AlgParams.RelativeInten(:));
         
        % enhance contrast of relative intensity
        %RelativeIntenMask = imadjust(RelativeIntenMask);
        %RelativeInten = histeq(RelativeIntenMask);
        %RelativeIntenMask = adapthisteq(RelativeIntenMask);
        
        % multi resolution SORF response
        MultiSorfBmodeMask = AlgParams.MultiSorfBmode;
        
        % normalize
        %MultiSorfBmodeMask = MultiSorfBmodeMask/max(MultiSorfBmodeMask(:));
        %MultiSorfBmodeMask = adapthisteq(MultiSorfBmodeMask);
        
        % relative contrast:
        % calculate relative contrast
        %RelativeContrastMask = AlgParams.LocalContrast./AlgParams.RemoteContrast;
        
        % normalize realtive contrast to the range [0 1]
        %RelativeContrastMask = RelativeContrastMask/max(RelativeContrastMask(:));
        
        %% seed point
        % check low threshhold for local intensity
        if ~isfield(AlgParams,'LocalIntenThLow')
            % if the paremater was not defined, set it to defuai value
            AlgParams.LocalIntenThLow = 0;
        end
        
        % find seed point according to local intensity
        if isfield(AlgParams,'SeedPoint')
            % if namual seed point exist, use it
            SeedPointLocalInten = AlgParams.SeedPoint;
        else
            % if manual seed point does not exist, calculate it
            [SeedPointLocalInten ImgWithSeedLocInten] = FindSeedPoint(LocalInten,AlgParams.LocalIntenThHigh,AlgParams.LocalIntenThLow);
        end
        
        %% active contour segmentation (level set)
        % different image masks for active contour segmentation
        ImgMasksBmode(:,:,1) = MultiSorfBmodeMask; % multi resolution SORF response mask
        ImgMasksBmode(:,:,2) = RelativeIntenMask; % relative intensity mask
        ImgMasksBmode(:,:,3) = LocalIntenMask; % local intensity mask
        
        % perform segmentation for B-mode image
        [AreaMaskBmode EdgeMaskBmode ImgWithEdgeBmode] = ActivContSeg(AlgParams,ImgMasksBmode,SeedPointLocalInten);
end % if (strcmp(ImageUsed,'gray') || strcmp(ImageUsed,'both'))

if (strcmp(ImageUsed,'color') || strcmp(ImageUsed,'both'))
        % color image
        AlgParams.ColorImageFlag = 1;
        
        %% prepare masks
        % Elasto SORF response: choose respose for red center - green center
        MultiSorfElastoMask = AlgParams.MultiSorfElasto(:,:,14); % complementary colors: cyan in center area - red in center area
        ProcIntenMask = AlgParams.ProcInten(:,:,2); % 1: S plane (from HSV trasformation), 2: L plane (from Lab trasformation)
        
        % check high threshhold for Elasto SORF response
        if ~isfield(AlgParams,'ElastoSorfThHigh')
            % if the paremater was not defined, set it to defuai value
            AlgParams.ElastoSorfThHigh = 1;
        end
        
        % find seed point according to Elasto SORF response
        if isfield(AlgParams,'SeedPointElasto')
            % if manual elasto seed point exist, use it
            SeedPointElasto = AlgParams.SeedPointElasto;
        elseif isfield(AlgParams,'SeedPoint')
            % if manual B-moed seed point exist, use it
            AlgParams.SeedPointElasto = AlgParams.SeedPoint;
            SeedPointElasto = AlgParams.SeedPointElasto;
        else
            % if namual seed point does not exist, calculate it
            [SeedPointElasto ImgWithSeedElasto] = FindSeedPoint(MultiSorfElastoMask,AlgParams.ElastoSorfThHigh,AlgParams.ElastoSorfThLow);
        end
        
        %% active contour segmentation (level set)
        % different image masks for active contour segmentation
        ImgMasksElasto(:,:,1) = MultiSorfElastoMask;
        ImgMasksElasto(:,:,2) = ProcIntenMask;
        
        % perform segmentation for Elasto image
        [AreaMaskElasto EdgeMaskElasto ImgWithEdgeElasto] = ActivContSeg(AlgParams,ImgMasksElasto,SeedPointElasto);
end % if (strcmp(ImageUsed,'color') || strcmp(ImageUsed,'both'))

%% combine edge masks and save results
switch ImageUsed
    case 'gray' % edge is determined by B-mode image only
        EdgeMask = EdgeMaskBmode;
        ImgWithEdge = ImgWithEdgeBmode;
        
        % embed B-mode edge in the Elasto image
        ImgWithEdgeElastoB = AlgParams.InputImgElasto;
        for nLayer = 1:3
            ImgLayerE = AlgParams.InputImgElasto(:,:,nLayer);
            
            % embed edge
            ImgLayerE(EdgeMaskBmode) = AlgParams.BmodeEdgeColor(nLayer);
            
            % update
            ImgWithEdgeElastoB(:,:,nLayer) = ImgLayerE;
        end % for nLayer = 1:3
        
        % add covex if needed
        if AlgParams.CovexEdgeFlag
            ImgWithEdgeCovxBmode = AddConvexEdge(ImgWithEdgeBmode,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
            ImgWithEdgeCovxElastoB = AddConvexEdge(ImgWithEdgeElastoB,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
        end
        
        % save results
        if AlgParams.SaveResBmode
            cd TempRes
            imwrite(ImgWithEdgeBmode,[AlgParams.ImgNum '_1_B-mode.bmp'],'bmp')
            imwrite(ImgWithEdgeElastoB,[AlgParams.ImgNum '_3_Elasto_B.bmp'],'bmp')
            
            if AlgParams.CovexEdgeFlag
                imwrite(ImgWithEdgeCovxBmode,[AlgParams.ImgNum '_2_B-mode_Convex.bmp'],'bmp')
                imwrite(ImgWithEdgeCovxElastoB,[AlgParams.ImgNum '_4_Elasto_B_Convex.bmp'],'bmp')
            end
            cd ..
        end
        
    case 'color' % edge is determined by Elasto image only
        EdgeMask = EdgeMaskElasto;
        ImgWithEdge = ImgWithEdgeElasto;
                
        % save results
        if AlgParams.SaveResElasto
            cd TempRes
            imwrite(ImgWithEdgeElasto,[AlgParams.ImgNum '_5_Elasto.bmp'],'bmp')
            cd ..
        end
        
    case 'both' % edge is determined by both B-mode and  Elasto images
        % embed B-mode edge in the Elasto image
        ImgWithEdgeElastoB = AlgParams.InputImgElasto;
        for nLayer = 1:3
            ImgLayerE = AlgParams.InputImgElasto(:,:,nLayer);
            
            % embed edge
            ImgLayerE(EdgeMaskBmode) = AlgParams.BmodeEdgeColor(nLayer);
            
            % update
            ImgWithEdgeElastoB(:,:,nLayer) = ImgLayerE;
        end % for nLayer = 1:3

        % edge is determined by B-mode image and elasto image
        AreaMask = AreaMaskBmode & AreaMaskElasto;
        [AreaMask AreaMaskPos EdgeMask ImgWithEdge] = EdgeAroundSeed(SeedPointLocalInten,AreaMask,AlgParams.InputImgBmodeOld,AlgParams.BmodeEdgeColor);
        
        % fix AreaMask if needed (if the seed point is not in the intersection)
        if isempty(AreaMaskPos)
            AreaMask = AreaMaskBmode & AreaMaskElasto;
            EdgeMask = bwmorph(AreaMask,'remove');    
        end % if isempty(AreaMaskPos)
        
        % embed edge in the input image
        ImgWithEdge = AlgParams.InputImgBmodeOld;
        ImgWithEdgeE = AlgParams.InputImgElasto;
        for nLayer = 1:3
            ImgLayer = AlgParams.InputImgBmodeOld(:,:,nLayer);
            ImgLayerE = AlgParams.InputImgElasto(:,:,nLayer);
            
            % embed edge
            ImgLayer(EdgeMask) = AlgParams.BmodeEdgeColor(nLayer);
            ImgLayerE(EdgeMask) = AlgParams.BmodeEdgeColor(nLayer);
            
            % update
            ImgWithEdge(:,:,nLayer) = ImgLayer;
            ImgWithEdgeE(:,:,nLayer) = ImgLayerE;
        end % for nLayer = 1:3
               
        % add convex if needed
        if AlgParams.CovexEdgeFlag
            ImgWithEdgeCovxBmode = AddConvexEdge(ImgWithEdgeBmode,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
            ImgWithEdgeCovxElastoB = AddConvexEdge(ImgWithEdgeElastoB,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
            ImgWithEdgeCovx = AddConvexEdge(ImgWithEdge,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
            ImgWithEdgeECovx = AddConvexEdge(ImgWithEdgeE,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
        end
        
        % put edges on both images
        % start with edge of B-mode image
        ImgWithEdgesBmode = ImgWithEdgeBmode;
        
        % start with elsto image
        ImgWithEdgesElasto = ImgWithEdgeElasto;
        
         % embed edge
        for Ind = 1:3
            % in B-mode image
            Layer = ImgWithEdgesBmode(:,:,Ind);
            Layer(EdgeMaskElasto) = AlgParams.ElastoEdgeColor(Ind);
            ImgWithEdgesBmode(:,:,Ind) = Layer;
            
            % in elasto image
            Layer = ImgWithEdgesElasto(:,:,Ind);
            Layer(EdgeMaskBmode) = AlgParams.BmodeEdgeColor(Ind);
            ImgWithEdgesElasto(:,:,Ind) = Layer;
        end
        
        % add covex if needed
        if  AlgParams.CovexEdgeFlag
            ImgWithEdgesConvexBmode = AddConvexEdge(ImgWithEdgesBmode,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
            ImgWithEdgesConvexElasto = AddConvexEdge(ImgWithEdgesElasto,AlgParams.BmodeEdgeColor,AlgParams.ConvexEdgeColor);
        end
        
        % test
        h1 = figure; %figure('Units','normalized','Position',[0 0 1 1]); % full screen figure
        subplot(1,2,1); imshow(ImgWithEdgeBmode); title(['B-mode image ' AlgParams.ImgNum ' B-mode edge']);
        subplot(1,2,2); imshow(ImgWithEdgeElastoB); title(['Elasto image ' AlgParams.ImgNum ' B-mode edge']);
        
        h3 = figure; %figure('Units','normalized','Position',[0 0 1 1]); % full screen figure
        subplot(1,2,1); imshow(ImgWithEdgesBmode); title(['B-mode image ' AlgParams.ImgNum]);
        subplot(1,2,2); imshow(ImgWithEdgesElasto); title(['Elasto image ' AlgParams.ImgNum]);
        
        % test with convex
        if AlgParams.CovexEdgeFlag
            h2 = figure; %figure('Units','normalized','Position',[0 0 1 1]); % full screen figure
            subplot(1,2,1); imshow(ImgWithEdgeCovxBmode); title(['B-mode image ' AlgParams.ImgNum ' B-mode edge with convex']);
            subplot(1,2,2); imshow(ImgWithEdgeCovxElastoB); title(['Elasto image ' AlgParams.ImgNum ' B-mode edge with convex']);

            h4 = figure; %figure('Units','normalized','Position',[0 0 1 1]); % full screen figure
            subplot(1,2,1); imshow(ImgWithEdgesConvexBmode); title(['B-mode image ' AlgParams.ImgNum ' with convex']);
            subplot(1,2,2); imshow(ImgWithEdgesConvexElasto); title(['Elasto image ' AlgParams.ImgNum ' with convex']);
        end
        
        % final edge
        h5 = figure; %figure('Units','normalized','Position',[0 0 1 1]); % full screen figure
        subplot(1,2,1); imshow(ImgWithEdge);  title(['B-mode image ' AlgParams.ImgNum ' combined edge']);
        subplot(1,2,2); imshow(ImgWithEdgeE);  title(['Elasto image ' AlgParams.ImgNum ' combined edge']);
        
        % final edge with convex
        if AlgParams.CovexEdgeFlag
            h6 = figure; %figure('Units','normalized','Position',[0 0 1 1]); % full screen figure
            subplot(1,2,1); imshow(ImgWithEdgeCovx);  title(['B-mode image ' AlgParams.ImgNum ' combined edge with convex']);
            subplot(1,2,2); imshow(ImgWithEdgeECovx);  title(['Elasto image ' AlgParams.ImgNum ' combined edge with convex']);
        end
        
        % save B-mode results
        if AlgParams.SaveResBmode
            cd TempRes
            imwrite(ImgWithEdgeBmode,[AlgParams.ImgNum '_1_B-mode.bmp'],'bmp')
            imwrite(ImgWithEdgeElastoB,[AlgParams.ImgNum '_3_Elasto_B.bmp'],'bmp')
            %print(h1,'-dbmp',[AlgParams.ImgNum '_10_B-mode_Edge.bmp']); % print figure to file
            imwrite(ImgWithEdge,[AlgParams.ImgNum '_6_Combined_B-mode.bmp'],'bmp')
            %print(h5,'-dbmp',[AlgParams.ImgNum '_13_Combined.bmp']); % print figure to file
            
            % convex
            if AlgParams.CovexEdgeFlag
                imwrite(ImgWithEdgeCovxBmode,[AlgParams.ImgNum '_2_B-mode_Convex.bmp'],'bmp')
                imwrite(ImgWithEdgeCovxElastoB,[AlgParams.ImgNum '_4_Elasto_B_Convex.bmp'],'bmp')
                %print(h2,'-dbmp',[AlgParams.ImgNum '_11_B-mode_Edge_Convex.bmp']); % print figure to file
                %print(h4,'-dbmp',[AlgParams.ImgNum '_12_Edges_Convex.bmp']); % print figure to file
                imwrite(ImgWithEdgeCovx,[AlgParams.ImgNum '_7_Combined_B-mode_Convex.bmp'],'bmp')
                %print(h6,'-dbmp',[AlgParams.ImgNum '_14_Combined_Convex.bmp']); % print figure to file
            end
            cd ..
        end
        
        % save Elasto results
        if AlgParams.SaveResElasto
            cd TempRes
            imwrite(ImgWithEdgeElasto,[AlgParams.ImgNum '_5_Elasto.bmp'],'bmp')
            imwrite(ImgWithEdgeE,[AlgParams.ImgNum '_8_Combined_Elasto.bmp'],'bmp')
            
            % convex
            if AlgParams.CovexEdgeFlag
                imwrite(ImgWithEdgeECovx,[AlgParams.ImgNum '_9_Combined_Elasto_Convex.bmp'],'bmp')
            end
            cd ..
        end
end % switch ImageUsed
end % [EdgeMask ImgWithEdge] = EdgeDetecting(AlgParams,ImageUsed)