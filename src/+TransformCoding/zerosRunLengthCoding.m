function rlcdata = zerosRunLengthCoding(zigzag, maxlength)

% COMMENT ME UP

if ~exist('maxlength', 'var')
    maxlength = 15;
end

% We use -1 padding. A count of -1 means this pair is nothing and end of
% data. We need the padding so output of blkproc is equal for each block
% and thus can be joined into one output matrix
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


euirfghasdfhalsdhflakdglaisdghflashdkasdjhasd
 % now must handle special JPEG standard case limiting zeros to 15 for run
zclen = length(zcs);
j = 1; % new length counter
for i=1:zclen
    if(  zcs(i) > 15 )
        % work out how many (15,0)s are needed and insert into zerocounts
        % and values
        fifteenzs = floor(zcs(i) / 15);
        remz = rem(zcs(i), 15);
        for k=1:fifteenzs
            zerocounts(j) = 15;
            values(j) = 0;
            j = j + 1;
        end
        % and rem zeros plus val
        zerocounts(j) =remz;
        values(j) = vals(i);
    else
        zerocounts(j) = zcs(i);
        values(j) = vals(i);
    end
    j = j+1;
end

return