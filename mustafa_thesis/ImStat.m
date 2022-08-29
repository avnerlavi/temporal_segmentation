function analysis=ImStat(num)
analysisNoTear=cell(1,11);
for i=num
%     P=['C:\Users\97254\Documents\MATLAB\thesis\Images\Tear\',num2str(i)];
%     FormatSeg='bmp';
    %P=['C:\Users\97254\Documents\MATLAB\thesis\Images\FilteredIm\FiltSeg',num2str(i)];
    P=['C:\Users\97254\Documents\MATLAB\thesis\Images\ShoulderPartialTear',num2str(num)];
    FormatSeg='png';
    R=1;
    if ~exist(P, 'dir')
        for j=3:2:21
            res=[j];
%             AlgParamsSeg = AlgorithmParams(P,res,FormatSeg,c);
            c=1;
            AlgParamsSeg = AlgorithmParams(P,res,FormatSeg,1,c);
            SorfSeg = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
            Im=imread([P,'.',FormatSeg]);
            Im=imresize(Im,[256 256]);
            if(size(Im,3)>1)
                Im=rgb2gray(Im);
            end
            BW=Im>0;
            I=double(BW).*double(SorfSeg{1});
            I(I==0)=nan;
            m=nanmean(I(:));%nanmax(Neg2(:));
            s=nanstd(I(:));
            e = entropy(I(:));
            Contrast=(nanmax(I(:))-nanmin(I(:)))/(nanmax(I(:))+nanmin(I(:)));
            k= kurtosis(I(:));
            sk=skewness(I(:));
            analysis(R,:)=[Contrast,e,m,s,sk,k];
            R=R+1;
        end
    end
    analysisTear{i}=analysis;
   
end
S=analysis(:,4);
Snorm=S/max(S(:));
C=analysis(:,1);
Cnorm=C/max(C(:));
K=analysis(:,6);
Knorm=K/max(K(:));
%analysisNoTear=mean(analysis, 1);
%analysisTear=mean(analysis(70:end,:), 1)
end
%%
% IM=imread('NewIm1.PNG');
% imageSegmenter(IM);
% %%
% [MG, S, TM]=fth(uint8(Im),3,[3 3],3);
% BWW=MG==2;
% FinalBWW=BWW.*seg;
% Se=strel('disk',3);
% Bw=imopen(FinalBWW,Se);
% % Se2=strel('disk',3);
% % BwIntensity=imopen(Bw,Se2);
% BwSorf=tear2;
% figure;imshow(Bw,[])

%
