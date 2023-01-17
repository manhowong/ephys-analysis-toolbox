function [pTable_rs, pTable_t] = multiTests(data,groupAs,groupBs,factors,groupIndex,fileIndex)
%% Get p-value table

nGroups = length(groupAs);
nFactors = length(factors);
pTable_rs = nan(nGroups,nFactors);
pTable_t = nan(nGroups,nFactors);

for g = 1:nGroups
    gA = applyFilters(data, groupIndex, fileIndex, groupAs{g});
    gB = applyFilters(data, groupIndex, fileIndex, groupBs{g});
    for k = 1:nFactors
        pTable_rs(g,k) = ranksum(gA.(factors{k}), gB.(factors{k}));
        [~, p] = ttest2(gA.(factors{k}), gB.(factors{k}));
        pTable_t(g,k) = p;
    end
    pairNames{g} = [groupAs{g} ' vs ' groupBs{g}];
end

pTable_rs = array2table(pTable_rs,"RowNames",pairNames,"VariableNames",factors);
pTable_t = array2table(pTable_t,"RowNames",pairNames,"VariableNames",factors);

