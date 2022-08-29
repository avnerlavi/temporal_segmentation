
res=[1 3 5 7 9 11 13 15];CC=[1,0.5,0.5,0.3,0.3,0.1,0,0];%CC=[1,1,0.5,0.5,0.3,0.1];
AlgParamsSeg = AlgorithmParams(Path,res,Format,ImC,CC);
AlgParamsSeg.InputImg=abs(JJ+abs(min(JJ(:))));
[Sorf,MultiResSorfRespBmode]  = SorfProcessing(AlgParamsSeg,'gray','gaussian','gaussian','SORF');
SorfSeg=Sorf{1,1};figure;imshow(SorfSeg,[])

[MG, S, TM]=fth(SorfSeg,3,[2,3],1);
figure;imshow(MG,[])