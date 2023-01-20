function [groupparams,outcdf,x] = fitGroupCDFExp(sortedData,groupIndex,fileIndex,groupName,outputDir)
%% Bootstrap data as a group first and then fit data to exponential model.
% Each experimental group of recordings was bootstrapped 500 times to 
% simulate 500 sets of recordings by nonparametric bootstrapping, which 
% involved generating a simulated recording by random resampling of events 
% (with replacement) from each of the original recordings. For each set of 
% simulated recordings, the CDF of IEI was generated based on an 
% exponential model with mean (μ) equal to the reciprocal of the mean 
% frequency of the recordings. The median CDF is the CDF at the 50th 
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
%   This function also prints the exponential CDF parameter lambda on the screen
%   (median and 2.5/97.5% CI).
%
% Note: This function was adapted from bootstrap_ieigroup_revised.m (
% Liu et al. (2014))
%
% Reference:
% Liu, M., Lewis, L. D., Shi, R., Brown, E. N., & Xu, W. (2014). 
% Differential requirement for NMDAR activity in SAP97β-mediated regulation
% of the number and strength of glutamatergic AMPAR-containing synapses. 
% Journal of Neurophysiology, 111(3), 648–658. 

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

pts=0:0.01:5;
x=pts*1000;
allcdf=zeros(nboot,length(pts));
meanparams=zeros(nboot,1);

for i=1:nboot
    meanparams(i)=mean(bootparams(i,:),2);
    currlambda=meanparams(i);
    currcdf=expcdf(pts,(1/currlambda));
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

outputDir = [outputDir '/exp_cdf_group/'];
outputFile = ['cdfParamsAndXyValues_' char(groupName) '.mat'];
if ~isfolder(outputDir)
    mkdir(outputDir);
end

save([outputDir outputFile],'groupparams','outcdf','x');
fprintf(['Done! CDF parameters and X-/Y-coordiate values were saved as:\n' ...
    '%s%s\n\n------\n\n'],outputDir,outputFile);
end


