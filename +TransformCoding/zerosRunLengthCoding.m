function rlcDataBlock = zerosRunLengthCoding(coeffsBlock)

% input data is takes as 64 values raster order
coeffs = reshape(coeffsBlock.', 64, []).'; % now 1 row per block
rlcData = ones(size(coeffs,1), (size(coeffs,2)*2)-2);

% We use -1 padding. A count of -1 means this pair is nothing and end of
% data. We need the padding so to avoid cell arrays

% For each row
for block=1:size(coeffs, 1)
    runLengths =    -ones(1, 63);
    values =        -ones(1, 63);

    ACvalues = coeffs(block, 2:end);
    % RLE
    % find runs of zeros + magnitude , encode as value to lookup in table
    ind = find(ACvalues);
    numberOfValues = length(ind);
    % Run length is essentially the difference between the current nonzero
    % index and the previous one
    pind = [0 ind(1:end-1)];
    runLengths(1:numberOfValues) = ind - pind - 1;
    values(1:numberOfValues) = ACvalues(ind);

    if isempty(ind) || ~isempty(ind) && (ind(end) ~= length(ACvalues))
        % there is a EOB
        runLengths(numberOfValues+1)   = 0;
        values(numberOfValues+1)       = 0;
    end

    % Now must handle special JPEG standard case limiting zeros to 15 for run
    if nnz(runLengths > 15)
        overFifteens = find(runLengths > 15);
        
        % Work out how many (15,0)s are needed
        fifteensNeeded  = floor(runLengths(overFifteens) / 15);
        remainders      = rem(runLengths(overFifteens), 15);
        % Update with remainder zeros number
        runLengths(overFifteens) = remainders;
        % Insert (15,0)s
        for i=1:length(overFifteens)
            if fifteensNeeded(i)
                count = fifteensNeeded(i);
                vs = ones(1,count).*15;
                zs = zeros(1,count);
                 % insert and remove last 'count' values which will be -1s
                runLengths = [runLengths(1:overFifteens(i)-1) vs runLengths(overFifteens(i):end - count)];
                values = [values(1:overFifteens(i)-1) zs values(overFifteens(i):end - count)];
            end
        end
    end

    rlcData(block,:) = [runLengths values];
end

rlcDataBlock = reshape(rlcData.', [], size(coeffsBlock,1)).'; % now 1 row per block

end
