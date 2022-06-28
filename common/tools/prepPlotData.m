vars = compiledData.Properties.VariableNames;
vars = vars(vars ~= categorical({'events'}));
data = compiledData(:,vars);
data = data(data.include==1,:);

%% Copy nsfa and decay data

for i = 1:height(data)
    idx = find(nsfaReport.Properties.RowNames==string(data.fileName(i)));
    data.nsfa{i} = nsfaReport(idx,:);
end

for i = 1:height(data)
    idx = find(decayReport.Properties.RowNames==string(data.fileName(i)));
    data.decay{i} = decayReport(idx,:);
end


%%
output = table;
for i = 1:height(data)
    output.freq(i,1) = data.dataPoints{i}.freq(1);
    output.ampl(i,1) = data.dataPoints{i}.Amplitude(1);
    output.i(i,1) = data.nsfa{i}.("i, pA")(1);
    output.N(i,1) = data.nsfa{i}.N(1);
    output.I0(i,1) = data.decay{i}.meanI0{1};
    output.tau(i,1) = data.decay{i}.meanTau{1};
end

output.cond = data.condition;
output.sex = data.sex;
output.age = data.age;
output.cell = data.cellType;

%% Remove unwanted recordings

output = output(output.cond~=categorical({'handled-ctrl'}),:);
output = output(output.cond~=categorical({'challenged-ctrl'}),:);
output = output(output.cond~=categorical({'challenged-lbn'}),:);
output.cond = removecats(output.cond);

%% Convert age to age group

p17 = find(output.age>=17 & output.age<=18);
p22 = find(output.age>=22 & output.age<=23);
p53 = find(output.age>=53);

output.age = num2cell(output.age);
output.age(p17) = {'P17-18'};
output.age(p22) = {'P22-23'};
output.age(p53) = {'>= P53'};
output.age = categorical(output.age);

%% Remove P22-23

output = output(output.age~=categorical({'P22-23'}),:);
output.age = removecats(output.age);

%% Remove MSEW

output = output(output.cond~=categorical({'msew'}),:);
output.cond = removecats(output.cond);


