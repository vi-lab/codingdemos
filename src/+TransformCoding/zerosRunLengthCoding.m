function rlcdata = zerosRunLengthCoding(zigzag)

% COMMENT ME UP
rlcdata = -ones(1, 64);

%DCvalue = zigzag(1);
ACvalues = zigzag(2:end);
% RLE
% find runs of zeros + magnitude , encode as value to lookup in table
ind = find(ACvalues);

prev = 0;

for i = 1:length(ind)
    %RLCruns(i) = ind(i) - prev - 1;
    rlcdata((i*2)-1: i*2) = [(ind(i) - prev - 1) ACvalues(ind(i))];
    prev = ind(i);
end
if prev ~= length(ACvalues)
    % there is a EOB
    % if there are any non-zero values i will be nonzero and we should
    % incrememnt i to make EOB at end. If i = [] then there all block is
    % zeros and should set a EOB at start
    if (isempty(i))
        i = 0;
    end
    i = i + 1;
    rlcdata((i*2)-1: i*2) = [0 0];
end
%RLCvalues = ACvalues(ind);

%rlcdata

return