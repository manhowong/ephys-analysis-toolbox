function mergedData = mergeData(data, subTableCol, varName, r2Thres, bootSettings)
%% Merge data from multiple recordings in subtables.
% Data from each recording can be bootstrapped before merging (optional).
% Man Ho Wong, University of Pittsburgh
% -------------------------------------------------------------------------
% Inputs: - data : table with each subtable storing data of one recording
%         - subTableCol : name of sub table storing the recording data
%         - varName : variable name of the data to be merged, e.g. 'tau' 
%         - r2Thres : r-squared threshold for filtering data;
%                     if not used, set it to 0;
%         - bootSettings : struct; settings for bootstrapping*. Contains
%           following fields:
%           - nBoot : number of bootstrap runs
%           - nResample : number of data points to be sampled from each
%                         recording
%           - jitter : add random jitter to resampled data points if true
%           *set all fields to 0 to opt out bootstrapping
% -------------------------------------------------------------------------
% Outputs: - mergedData : a single-column vector containing the data of
%                         your selected variable
% -------------------------------------------------------------------------
% Example:

% bootSettings.nBoot = 100;
% bootSettings.nResample = 500;
% bootSettings.jitter = true;
% mergedData = mergeData(decayReport, 'events', 'tau', 0.9, bootSettings)

%%

nBoot = bootSettings.nBoot;
nResample = bootSettings.nResample;
jitter = bootSettings.jitter;

%%
nFiles = height(data);

% preallocate space if data will be bootstrapped
if nBoot > 0
    mergedData = zeros(nFiles*nBoot*nResample,1);
else
    mergedData = [];
end

for f = 1:nFiles
    % Get event info from each recording
    oneFile = data.(subTableCol){f};
    if r2Thres ~= 0
        oneFile = oneFile(oneFile.('r^2') > r2Thres, :); % only well fitted events
    end
    dataPts = oneFile.(varName);
    % Merge data from all recordings
    if nBoot > 0
        % Bootstrap data
        bootDataPts = bootstrapData(dataPts, nBoot, nResample, jitter);
        nPoints = nBoot*nResample;
        mergedData( (1+(f-1)*nPoints) : f*nPoints ) = bootDataPts(:);
    else
        mergedData = [mergedData;dataPts];
    end
end