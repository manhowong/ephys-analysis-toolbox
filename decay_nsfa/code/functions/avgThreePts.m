function threePts = avgThreePts(data)
%% Get three-point average for each data point.
% The three points are: the current point, one point before and after the
% current point. Since the first and the last point of the data have only 1
% adjacent point, the average will be the current point and one adjacent 
% point.
% Man Ho Wong, University of Pittsburgh, 2022-05-10
% -------------------------------------------------------------------------
% Input: - data : a column vector of data points
% -------------------------------------------------------------------------
% Output: - threePts : a column vector of each data point's three-point
%                      average; same length as data

%%

nData = length(data);
if nData < 3
    threePts = data;  % do nothing if data has less than three points
else    
    threePts = zeros(nData,1);
    for i = 2:nData-1
        threePts(i) = mean(data(i-1:i+1));
    end
    threePts(1) = mean(data(1:2));  % First point of data
    threePts(nData) = mean(data(nData-1:nData));  % last point of data
end

end
