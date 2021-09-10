function sumRes = sumButIndexPowerNormed(arr, indexToExclude, power)
sumRes = sum(abs(arr).^power, 4) - abs(arr(:,:,:, indexToExclude)).^power;
sumRes = sumRes.^(1/power);
end