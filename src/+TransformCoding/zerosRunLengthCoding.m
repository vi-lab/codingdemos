function rlcData = zerosRunLengthCoding(zigzag)

% COMMENT ME UP

% TODO: optimise away some for loops and maybe rethink this, ie not use
% blkproc and use something else

% We use -1 padding. A count of -1 means this pair is nothing and end of
% data. We need the padding so output of blkproc is equal for each block
% and thus can be joined into one output matrix
%rlcdata = ones(1, 64);
runLengths =    -ones(1, 63);
values =        -ones(1, 63);

%DCvalue = zigzag(1);
ACvalues = zigzag(2:end);
% RLE
% find runs of zeros + magnitude , encode as value to lookup in table
ind = find(ACvalues);

prev = 0;

for i = 1:length(ind)
    %RLCruns(i) = ind(i) - prev - 1;
    %rlcdata((i*2)-1: i*2) = [(ind(i) - prev - 1) ACvalues(ind(i))];
    runLengths(i)   = (ind(i) - prev - 1);
    values(i)       = ACvalues(ind(i));
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
    %rlcdata((i*2)-1: i*2) = [0 0];
    runLengths(i)   = 0;
    values(i)       = 0;
end
%RLCvalues = ACvalues(ind);


% Now must handle special JPEG standard case limiting zeros to 15 for run
for i=1:length(runLengths)
    if runLengths(i) < 0
        break;
    end
    if  runLengths(i) > 15 
        % Work out how many (15,0)s are needed and insert
        fifteenzs = floor(runLengths(i) / 15);
        remz = rem(runLengths(i), 15);
        % Update with remainder zeros number
        runLengths(i) = remz;
        % Insert (15,0)s
        for k=1:fifteenzs
            runLengths = [runLengths(1:i-1) 15 runLengths(i:end - 1)]; % insert and remove last 2 values which will be -1s
            values = [values(1:i-1) 0 values(i:end - 1)]; % insert and remove last 2 values which will be -1s
        end
    end
end
%zigzag
%runLengths
%values

rlcData = [runLengths values];


return