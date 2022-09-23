%% Copy sortedData

vars = sortedData.Properties.VariableNames;
vars = vars(vars ~= categorical({'events'}));
data = sortedData(:,vars);
data = data(data.include==1,:);

%% Copy decay report, NSFA report and membrane properties report
% Also filter out outliers

data = outerjoin(data, decayReport, ...
                 'LeftKeys','fileName','RightKeys','Row', ...
                 'RightVariables',["meanI0", "meanTau"],'Type','left');

filter = ~isoutlier(nsfaReport.N,"quartiles");
data = outerjoin(data, nsfaReport(filter,:), ...
                 'LeftKeys','fileName','RightKeys','Row', ...
                 'RightVariables',["i, pA", "N", "g, pS"],'Type','left');

filter = ~isoutlier(memPropReport.("input R, MOhm"),"quartiles");
data = outerjoin(data, memPropReport(filter,:), ...
                 'LeftKeys','fileName','RightKeys','Row',...
                 'RightVariables',["series R, MOhm", "input R, MOhm", ...
                 "membrane capacitance, pF"],'Type','left');


%% Convert age to age group

p17 = find(data.age>=17 & data.age<=18);
p22 = find(data.age>=22 & data.age<=23);
p53 = find(data.age>=53);

data.age = num2cell(data.age);
data.age(p17) = {'P17-18'};
data.age(p22) = {'P22-23'};
data.age(p53) = {'>= P53'};
data.age = categorical(data.age);

%% Remove unwanted recordings

% Remove unwanted conditions
data = data(data.condition~=categorical({'msew'}),:);
data = data(data.condition~=categorical({'handled-ctrl'}),:);
data = data(data.condition~=categorical({'challenged-ctrl'}),:);
data = data(data.condition~=categorical({'challenged-lbn'}),:);
data.condition = removecats(data.condition);

% Remove P22-23
data = data(data.age~=categorical({'P22-23'}),:);
data.age = removecats(data.age);

%% Change variable names for easier access (optional)
data.Properties.VariableNames(["i, pA","g, pS","meanI0","meanTau","series R, MOhm", ...
                               "input R, MOhm","membrane capacitance, pF"]) = ...
                              ["i","g","I0","tau","seriesR","inputR","capacitance"];

