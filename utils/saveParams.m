function saveParams(fileDir, varargin)
params = struct;

for i = 1:nargin - 1
    paramName = inputname(i + 1);
    if isa(varargin{i}, 'struct')
        params = mergeStructs(params, varargin{i}, paramName);
    else
        params.(paramName) = varargin{i};
    end
end

if fileDir(end) ~= '\'
    fileDir = [fileDir, '\'];
end
mkdir(fileDir);
filePath = [fileDir, 'params.xls'];

paramsCell = struct2cell(params);
paramsTable = cell2table(paramsCell, 'RowNames', fieldnames(params));

writetable(paramsTable, filePath, ...
    'WriteRowNames',true, 'WriteVariableNames', false);

end


function [merged_struct] = mergeStructs(structA, structB, structBName)
%%if one of the structures is empty do not merge
if isempty(structA)
    merged_struct=structB;
    return
end
if isempty(structB)
    merged_struct=structA;
    return
end
%%insert struct a
merged_struct=structA;
%%insert struct b
for j=1:length(structB)
    f = fieldnames(structB);
    for i = 1:length(f)
        merged_struct.([structBName,'__',f{i}]) = structB.(f{i});
    end
end
end