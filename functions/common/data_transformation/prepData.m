%% This script loads and combines data from different analyses.

%% Load data and copy data to one table

if ~isempty(sortedDataPath) && exist(sortedDataPath,"file")
    load(sortedDataPath);
    % Copy 'sortedData' to 'data'
    vars = sortedData.Properties.VariableNames;
    vars = vars(vars ~= categorical({'events'}));
    data = sortedData(:,vars);
    data = data(data.include==1,:);
else
    disp('Please provide the path for SortedData.');
    return;
end

if ~isempty(decayReportPath) && exist(decayReportPath,"file")
    load(decayReportPath);
    % Copy 'decayReport' to 'data'
    data = outerjoin(data, decayReport, ...
                 'LeftKeys','fileName','RightKeys','Row', ...
                 'RightVariables',["meanI0", "meanTau"],'Type','left');
end

if ~isempty(nsfaReportPath) && exist(nsfaReportPath,"file")
    load(nsfaReportPath);
    % Copy 'nsfaReport' to 'data'
    filter = ~isoutlier(nsfaReport.N,"quartiles");  % remove outliers base on N
    data = outerjoin(data, nsfaReport(filter,:), ...
                 'LeftKeys','fileName','RightKeys','Row', ...
                 'RightVariables',["i, pA", "N", "g, pS"],'Type','left');
    % rename variables for easier access (optional)
    data.Properties.VariableNames(["i, pA","g, pS","meanI0","meanTau"]) = ...
                                  ["i","g","I0","tau"];
end

if ~isempty(memPropReportPath) && exist(memPropReportPath,"file")
    load(memPropReportPath);
    % Copy 'memPropReport' to 'data'
    data = outerjoin(data, memPropReport, ...
                 'LeftKeys','fileName','RightKeys','Row',...
                 'RightVariables',["tau, ms", "series R, MOhm", "input R, MOhm", ...
                 "membrane capacitance, pF"],'Type','left');
    % rename variables for easier access (optional)
    data.Properties.VariableNames(["tau, ms", "series R, MOhm", "input R, MOhm", ...
         "membrane capacitance, pF"]) = ["memTau", "seriesR","inputR","capacitance"];
end

