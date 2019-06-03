function numValue = checkInputForValidNumber(input)
val = str2num(input);
if ~isempty(val)
    numValue = val;
else
    numValue = -1;
end