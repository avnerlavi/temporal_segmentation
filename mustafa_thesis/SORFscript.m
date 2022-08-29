% This Script created to run the SORF algorithm for texture analysis

%1- Read Image:
Path=['C:\Users\97254\Pictures\CRL_Crown_rump_length_12_weeks_ecografia_Dr._Wolfgang_Moroder'];
Format='jpg';
Im=imread([Path,'.',Format]);

%2- Define the parameters:
res=[3 5 7 9 11 13 15 17 19]; % Resolutions:The radiuses of the kerenels (DoG) 
analysis=imstat2(Im,res);       % Statistical measures for each scale/ resolution response
K=analysis(:,6);                % The fourth moment 
S=analysis(:,4);                % The second moment 

Snorm=S/max(S(:));
Knorm=K/max(K(:));
                                % The weights of the scales 
c=-exp(Snorm.*Knorm);            %
Costnorm=normalize01(Costnorm);       %

% Costnorm is the weight function of the scales in order to get an weighted SORF
% or choose Costnorm as uniform function (ones(1,length(res))) -optional 

%3- Creat Struct of the param
AlgParamsSeg = AlgorithmParams(Path,res,Format,Im,Costnorm);
AlgParamsSeg.InputImg=Im;

% SORF CALCULATION:
[Sorf,MultiResSorfResp]  = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
SorfSeg=Sorf{1,1};
figure;subplot(1,2,1);imshow(Im,[]);title('Original Image')
subplot(1,2,2);imshow(SorfSeg,[]);title('Texture')
