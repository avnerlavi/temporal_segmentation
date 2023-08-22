function [params] = read_params(params_dir)
param_table = readtable(params_dir,'ReadRowNames',true,'ReadVariableNames',false);
params = struct;
for i = 1:size(param_table,1)
   row = param_table(i,~ismissing(param_table(i,:))) ;
   name = row.Properties.RowNames{1};
   
   vars =  table2cell(row(1,:));
   if(all(size(vars)==1)) %scalar variable
       vars = vars{1};
       t = str2double(vars);
       if(~isnan(t))
         vars = t;
       end
   else %tries to convert to vector
       try
       for j = 1:length(vars)
           v = squeeze(vars{j});
           if(isa(v,'char')||isa(v,'string'))
               v = str2double(v);
           end
           vars{j} = v;
       end
       vars = cell2mat(vars);
       catch
       end
   end
   params = setfield(params,name,vars);
end
end

