function plotEachRecCDF_gamma(group,newFig,color,inputDir)

%% Read data
inputFile = [inputDir '/' char(group) '/gammastats_all.mat'];

if ~isfile(inputFile)
    fprintf('''%s'' does not exist!\n',inputFile);
    return;
end

load(inputFile);
%% plot CDF for each recordings

x=0:0.01:100;
if newFig == 1
    figure;
end
hold on;

for f=1:height(allparams)
    % Fit gamma model
    alpha=allparams(f,1);
    beta=allparams(f,3);
    xTrunc=allxTrunc(f);
    currcdf=gamcdf(x,alpha,beta);
    truncval=max(currcdf(x<xTrunc));
    currcdf=currcdf-truncval;
    currcdf(currcdf<0)=0;
    currcdf=currcdf/(1-truncval);
    plot(x,currcdf,Color=color);
end

end
