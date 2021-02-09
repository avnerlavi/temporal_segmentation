function [params] = readParams(infileDir)
pTable = readtable(infileDir,'ReadVariableNames',false);
pCell = table2cell(pTable);

params = struct;

for i=1:size(table,1)
   readParamLine(pCell{i,:},params); 
end
    
end

