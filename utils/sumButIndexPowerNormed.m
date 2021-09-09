function sumRes = sumButIndexPowerNormed(arr, indexToExclude, power)
if(indexToExclude == 1)
    sumRes = sum(abs(arr(:,:,:,2:end)).^power, 4);
elseif(indexToExclude == size(arr, 4))
    sumRes = sum(abs(arr(:,:,:,1:end-1)).^power, 4);
else
    sum1 = sum(abs(arr(:,:,:,1:indexToExclude-1)).^power, 4);
    sum2 = sum(abs(arr(:,:,:,indexToExclude+1:indexToExclude)).^power, 4);
    sumRes = sum1 + sum2;
end

sumRes = sumRes.^(1/power);
end