function analysis=imstat2(im,resolution)
R=1;

for j=1:length(resolution)
    res=resolution(j);
%             AlgParamsSeg = AlgorithmParams(P,res,FormatSeg,c);
    c=1;
    AlgParamsSeg = AlgorithmParams([],res,[],1,c);
    AlgParamsSeg.InputImg=im;
    AlgParamsSeg.InputImgBmode=im;
    SorfSeg = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
    Im=imresize(im,[256 256]);
    if(size(Im,3)>1)
        Im=rgb2gray(Im);
    end
%     SorfSeg=Im>0;
%     I=double(BW).*double(SorfSeg{1});
%     I(I==0)=nan;
    I=SorfSeg{1,1};
    m=nanmean(I(:));%nanmax(Neg2(:));
    s=nanstd(I(:));
    e = entropy(I(:));
    Contrast=(nanmax(I(:))-nanmin(I(:)))/(nanmax(I(:))+nanmin(I(:)));
    k= kurtosis(I(:));
    sk=skewness(I(:));
    analysis(R,:)=[Contrast,e,m,s,sk,k];
    R=R+1;
end

%analysisTear{i}=analysis;

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

