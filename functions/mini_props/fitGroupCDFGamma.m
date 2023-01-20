function [groupparams,outcdf,x] = fitGroupCDFGamma(sortedData,groupIndex,fileIndex,groupName,outputDir)
%% Bootstrap data as a group first and then fit data to left-truncated gamma model.
% Each experimental group of recordings was bootstrapped 500 times to 
% simulate 500 sets of recordings by nonparametric bootstrapping, which 
% involved generating a simulated recording by random resampling of events 
% (with replacement) from each of the original recordings. For each set of 
% simulated recordings, the CDF was generated based on a left-truncated
% gamma model with alpha and beta parameters estimated as described 
% previously (Liu et al. 2014).  The median CDF is the CDF at the 50th 
% percentile of 500 CDFs computed above. The 95% confidence interval is 
% defined by the CDFs at the 2.5th and 97.5th percentiles.
%
% Man Ho Wong, University of Pittsburgh.
% -------------------------------------------------------------------------
% Input: - sortedData : must have file names as row names,
%                       or file names stored in a column named 'fileName'
%        - groupIndex : A table containing grouping info;
%                       can be generated with addGroup.m
%        - fileIndex : A table containing file info;
%                      can be imported from xlsx file by readIndex.m
%        - groupName : Name of the target group (in groupIndex)
%        - outputDir : directory to store output data
%
% Output:
%   groupparams: 2.5 percentile, median and 97.5% percentile of bootstrap data
%   x: x-coordinate values of the cdf.
%   outcdf: probabilities assessed at x.
%   The above variables are saved as:
%   analysis/exponFitting_bootstrap/cdfParamsAndXyValues_<Group Name>.mat
%   This function also prints the Gamma CDF parameters on the screen
%   (median and 2.5/97.5% CI).
%
% Note: This function was adapted from bootstrap_gammagroup_revised.m (
% Liu et al. (2014))
%
% Reference:
% Liu, M., Lewis, L. D., Shi, R., Brown, E. N., & Xu, W. (2014). 
% Differential requirement for NMDAR activity in SAP97β-mediated regulation
% of the number and strength of glutamatergic AMPAR-containing synapses. 
% Journal of Neurophysiology, 111(3), 648–658. 

%% Bootstrapping

fprintf('Running bootstrapGamma()... Press Ctrl + c to stop\n');

% set up parameters
nboot=500;
groupData = applyFilters(sortedData,groupIndex,fileIndex,groupName);
alldata = groupData.events;

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

fprintf('\nLeft-truncated Gamma CDF of ''%s'':\n',string(groupName));
fprintf('Alpha = %0.2f (CI %0.2f-%0.2f)\n', ...
    groupparams(1,2),groupparams(1,1),groupparams(1,3));
fprintf('Beta  = %0.2f (CI %0.2f-%0.2f)\n', ...
    groupparams(2,2),groupparams(2,1),groupparams(2,3));
fprintf('Mean  = %0.2f (CI %0.2f-%0.2f)\n', ...
    groupparams(3,2),groupparams(3,1),groupparams(3,3));

%% Save CDF parameters and X-/Y-coordinate values

fprintf('\nSaving CDF parameters and X-/Y-coordiate values...\n');

outputDir = [outputDir '/gamma_cdf_group/'];
outputFile = ['cdfParamsAndXyValues_' char(groupName) '.mat'];
if ~isfolder(outputDir)
    mkdir(outputDir);
end

save([outputDir outputFile],'groupparams','outcdf','x');
fprintf(['Done! CDF parameters and X-/Y-coordiate values were saved as:\n' ...
    '%s%s\n\n------\n\n'],outputDir,outputFile);
end
