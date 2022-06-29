function [groupparams,outcdf,x] = bootstrapGamma(groupedData,group)
% bootstrapGamma: Run nonparametric bootstrap for a group of cells and
% estimate CDF of group average with confidence intervals.

% This function is adapted form bootstrap_gammagroup_revised.m to fit Man Ho's
% data structure. All variable names are the same.

% Input
%   groupedData: dataset (in Man Ho's data structure)
%   group: name of the group of recordings to run bootstrap

% Output
%   groupparams: 2.5 percentile, median and 97.5% percentile of bootstrap data
%   y: This can be confusing. 'y' is actually the x-coordinate values of
%      the cdf. The source code named it 'y' and I keep the same name here.
%   outcdf: probabilities assessed at y (i.e. x-coordinate values).
%   The above variables are saved as:
%   analysis/exponFitting_bootstrap/cdfParamsAndXyValues_<Group Name>.mat
%   This function also prints the Gamma CDF parameters on the screen
%   (median and 2.5/97.5% CI).

% Example
%   [groupparams,outcdf,x] = bootstrapGamma(groupedData,'control')
%   Output arguments are optional.

%% Bootstrapping

fprintf('Running bootstrapGamma()... Press Ctrl + c to stop\n');

% set up parameters
nboot=500;
alldata = groupedData.events{group}.events; % Codes before this in the source
                                            % code is not needed anymore
                                            % with Man Ho's data structure

allnsamples=zeros(length(alldata),1);
for f=1:length(alldata)
    allnsamples(f)=size(alldata{f,1},1);    % In source code, 1 is substracted
end                                         % from the total event count. It's
ncells=length(alldata);                     % not needed for Man Ho's data
                                            % structure because this has
                                            % been taken care of

% Run bootstrap across each cell
bootparams=zeros(nboot,ncells,3);
bootmean=zeros(nboot,ncells);

for b=1:nboot
    for c=1:ncells
        data=table2array(alldata{c});
        bootdata=data(randi(allnsamples(c),allnsamples(c),1),:);
        [params xTrunc]=gammafit_boot(bootdata);
        bootparams(b,c,:)=[params(1) params(3) xTrunc];
        bootmean(b,c)=params(5);
    end
end


bootmean=mean(bootmean,2);


%% Get CDF based on params

x=0:0.01:100;
allcdf=zeros(nboot,length(x));
meanparams=zeros(nboot,3);

for i=1:nboot
    meanparams(i,:)=mean(bootparams(i,:,:),2);
    xTrunc=meanparams(i,3);
    curralpha=meanparams(i,1);
    currbeta=meanparams(i,2);
    currcdf=gamcdf(x,curralpha,currbeta);
    truncval=max(currcdf(x<xTrunc));
    currcdf=currcdf-truncval;
    currcdf(currcdf<0)=0;
    currcdf=currcdf/(1-truncval);
    allcdf(i,:)=currcdf;
end

outcdf=prctile(allcdf,[2.5 50 97.5],1);
groupparams(1,:)=prctile(meanparams(:,1),[2.5 50 97.5]);
groupparams(2,:)=prctile(meanparams(:,2),[2.5 50 97.5]);
groupparams(3,:)=prctile(bootmean,[2.5 50 97.5]);

%% Print CDF parameters to screen

fprintf('\nLeft-truncated Gamma CDF of ''%s'':\n',string(group));
fprintf('Alpha = %0.2f (CI %0.2f-%0.2f)\n', ...
    groupparams(1,2),groupparams(1,1),groupparams(1,3));
fprintf('Beta  = %0.2f (CI %0.2f-%0.2f)\n', ...
    groupparams(2,2),groupparams(2,1),groupparams(2,3));
fprintf('Mean  = %0.2f (CI %0.2f-%0.2f)\n', ...
    groupparams(3,2),groupparams(3,1),groupparams(3,3));

%% Save CDF parameters and X-/Y-coordinate values

fprintf('\nSaving CDF parameters and X-/Y-coordiate values...\n');

outputDir = ['analysis/gammaFitting_bootstrap/'];
outputFile = ['cdfParamsAndXyValues_' char(group) '.mat'];

if ~isfolder(outputDir)
    mkdir(outputDir);
end

save([outputDir outputFile],'groupparams','outcdf','x');
fprintf(['Done! CDF parameters and X-/Y-coordiate values were saved as:\n' ...
    '../%s%s\n\n------\n\n'],outputDir,outputFile);
end
