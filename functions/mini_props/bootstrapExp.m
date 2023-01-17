function [groupparams,outcdf,y] = bootstrapExp(sortedData,groupIndex,fileIndex,groupName,outputDir)
% bootstrapExp: Run nonparametric bootstrap for a group of cells and
% estimate CDF of group average with confidence intervals.

% This function is adapted form bootstrap_ieigroup_revised.m to fit Man Ho's
% data structure. All variable names are the same.

% Input
%   groupedData: dataset (in Man Ho's data structure)
%   group: name of the group of recordings to run bootstrap

% Output
%   groupparams: 2.5 percentile, median and 97.5% percentile of bootstrap data
%   y: This can be confusing. 'y' is actually the x-coordinate values of
%      the cdf. The source code named it 'y' and I keep the same name here.
%   outcdf: probabilities assessed at 'y' (i.e. x-coordinate values).
%   The above variables are saved as:
%   analysis/exponFitting_bootstrap/cdfParamsAndXyValues_<Group Name>.mat
%   This function also prints the exponential CDF parameter lambda on the screen
%   (median and 2.5/97.5% CI).

% Example
%   [groupparams,outcdf,y] = bootstrapExp(groupedData,'control')
%   Output arguments are optional.

%% Bootstrapping

fprintf('Running bootstrapExp()... Press Ctrl + c to stop\n');

% set up parameters
nboot=500;
groupData = applyFilters(sortedData,groupIndex,fileIndex,groupName);
alldata = groupData.events;

%% Run bootstrap across each cell

ncells=length(alldata);
bootparams=zeros(nboot,ncells);

for b=1:nboot
    for c=1:ncells
        ieis = alldata{c}.iei;
%         Original algorithm:
%         bootdata=ieis(randi(allnsamples(c),allnsamples(c),1),:);
%         [params]=ieifit_boot(bootdata);
%         bootparams(b,c)=params(1);  % get freq
%         New code, more efficient:
        nEvents = length(ieis);
        bootdata = randsample(ieis,nEvents,1);
        bootparams(b,c)=nEvents/(sum(bootdata)/1000);  % get freq
    end
end

%% Get CDF based on params

x=0:0.01:5;
y=x*1000;
allcdf=zeros(nboot,length(x));
meanparams=zeros(nboot,1);

for i=1:nboot
    meanparams(i)=mean(bootparams(i,:),2);
    currlambda=meanparams(i);
    currcdf=expcdf(x,(1/currlambda));
    allcdf(i,:)=currcdf;
end

outcdf=prctile(allcdf,[2.5 50 97.5],1);
groupparams=prctile(meanparams,[2.5 50 97.5]);

%% Print CDF parameters to screen

fprintf(['\nExponential CDF of ''%s'':\n' ...
    'Lambda = %0.2f (CI %0.2f-%0.2f)\n\n'],string(groupName),groupparams(1,2), ...
    groupparams(1,1),groupparams(1,3));

%% Save CDF parameters and X-/Y-coordinate values

fprintf('Saving CDF parameters and X-/Y-coordiate values...\n');

outputFile = ['/cdfParamsAndXyValues_' char(groupName) '.mat'];

if ~isfolder(outputDir)
    mkdir(outputDir);
end

save([outputDir outputFile],'groupparams','outcdf','y');
fprintf(['Done! CDF parameters and X-/Y-coordiate values were saved as:\n' ...
    '../%s%s\n\n------\n\n'],outputDir,outputFile);
end


