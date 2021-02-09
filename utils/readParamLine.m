function  readParamLine(pLine,params)
if(size(pLine,1)>1)
    error('not a line')
end

for i=2:size(pLine,2)
    value = 1;
    
end
paramNameRaw = pLine{1};
structNames = split(paramNameRaw,'__');
tempStruct = params;
for i=1:size(structNames,2)-1
    if(~isfield(tempStruct,structNames{i}))
        tempStruct.(structNames{i}) = struct;
    end
    tempStruct = tempStruct.(structNames{i});
end
tempStruct.(structNames{end}) = value;
end

