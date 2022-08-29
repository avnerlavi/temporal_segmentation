function FieldMask = CalcFieldMask(FieldSize,DecayCoef,CenSize,TypeOfFltr)

% initialize mask with defualt values, compatible for "average" filter type
FieldMask = ones(FieldSize,FieldSize);

% calculate decaying Gaussian values if filter type is "gaussian"
if strcmp(TypeOfFltr,'gaussian')
    for i=1:1:FieldSize
        for j=1:1:FieldSize
            %mask is given the values of a decaying Gaussian
            FieldMask(i,j) = exp(-((i-(FieldSize+1)/2)^2+(j-(FieldSize+1)/2)^2)/DecayCoef^2);
        end
    end
end % if strcmp(TypeOfFltr,'gaussian')

% put zeros in center region if needed
if (CenSize ~= 0)
    % put zeros in the position of the center region of the rceptive field
    FieldMask(round((FieldSize-CenSize+2)/2):round((FieldSize+CenSize)/2),round((FieldSize-CenSize+2)/2):round((FieldSize+CenSize)/2)) = ...
        zeros(CenSize,CenSize);
end

% normalization the total weight of the mask to 1
FieldMask = FieldMask/sum(FieldMask(:));
end