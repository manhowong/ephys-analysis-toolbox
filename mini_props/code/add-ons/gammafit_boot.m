% fitampl.m: Fit amplitudes  d

function [params xTrunc] = gammafit_boot(data)

% Select data - sort and identify variables
[evtimes, evorder] = sort(data(:,2));
sdata = data(evorder,:);

% Extract variables from selected dataset
evampl=sdata(:,3);
n=length(evampl);


% Modify extracted data (shift to 0) to fit shifted models.
evampl2=evampl-min(evampl)+0.1;

% Truncation point is minimum value of thresholded amplitude data.
xTrunc=min(evampl);
%%%%% ANALYSIS

% Gamma amplitude analysis
A=[];
b=[];
Aeq=[];
Beq=[];
nonlcon=[];
lb=[0 0];
ub = [Inf Inf];
options = optimset('Algorithm','interior-point','Display','off');

% unshifted

% MLEs given by Matlab (limitation: alpha > 1)
phat = gamfit(evampl);

if (phat(1) > 170)
    phat(1) = 170;
end

gamf = @(x)-1*(-n*x(1)*log(x(2)) - n*log(gamma(x(1))) - sum(evampl)/x(2) + (x(1) - 1)*sum(log(evampl)));
x = fmincon(gamf,phat,Aeq,Beq,A,b,lb,ub,nonlcon,options);

alphahat = x(1);
betahat = x(2);

% Figure out 95% confidence intervals for mean of amplitude

gammean = alphahat*betahat;

%fisher information at maximum likelihood estimates

gamfish(1,:) = [n*psi(1,alphahat) n/betahat];
gamfish(2,:) = [n/betahat n*alphahat/betahat^2];

gamfishinv = inv(gamfish);

gamvaralpha = gamfishinv(1,1);
gamvarbeta = gamfishinv(2,2);

gamalphaCI = 1.96*gamvaralpha^(1/2);
gambetaCI = 1.96*gamvarbeta^(1/2);

gammeangrad(1,:) = betahat;
gammeangrad(2,:) = alphahat;

gammeanvar = gammeangrad'*gamfishinv*gammeangrad;

gammeanCI = 1.96*gammeanvar^(1/2);

% shifted
phat2 = gamfit(evampl2);

if (phat2(1) > 170)
    phat2(1) = 170;
end
gamfshifted = @(x)-1*(-n*x(1)*log(x(2)) - n*log(gamma(x(1))) - sum(evampl2)/x(2) + (x(1) - 1)*sum(log(evampl2)));

x = fmincon(gamfshifted,phat2,Aeq,Beq,A,b,lb,ub,nonlcon,options);

alphahat2 = x(1);
betahat2 = x(2);

gamFshift(1,:) = [n*psi(1,alphahat2) n/betahat2];
gamFshift(2,:) = [n/betahat2 n*alphahat2/betahat2^2];
% Estimated variance given by inverse of the estimated Fisher information

gamFshiftinv = inv(gamFshift);

% Estimated variances of parameters mu and lambda

gamshiftvaralpha = gamFshiftinv(1,1);
gamshiftvarbeta = gamFshiftinv(2,2);

gamshiftalphaCI = 1.96*gamshiftvaralpha^(1/2);
gamshiftbetaCI = 1.96*gamshiftvarbeta^(1/2);

% Figure out 95% confidence intervals for mean of amplitude

gamshiftmean = alphahat2*betahat2;

gammeangrad(1,:) = betahat2;
gammeangrad(2,:) = alphahat2;

gamshiftmeanvar = gammeangrad'*gamFshiftinv*gammeangrad;

% 95% confidence interval for mean
gamshiftmeanCI = 1.96*gamshiftmeanvar^(1/2);


% Truncated

% Use Monte Carlo sampling method to find maximum likelihood estimate.
% Start by expanding search region specified by maximum likelihood
% estimates of untruncated case.

%gamparaminit(1,:) = 20*alphahat;
%gamparaminit(2,:) = 20*betahat;


% Left-truncated gamma likelihood function

gamf1 = @(a,b)exp(-n*a*log(b) - n*log(gamma(a)) + (a - 1)*sum(log(evampl)) - sum(evampl)/b)/(1 - gamcdf(xTrunc,a,b))^n;

% log-likelihood function
gamf2 = @(a,b)-n*a*log(b) - n*log(gamma(a)) + (a - 1)*sum(log(evampl)) - sum(evampl)/b - n*log(1 - gamcdf(xTrunc,a,b));
gamf3 = @(x)-1*(-n*x(1)*log(x(2)) - n*log(gamma(x(1))) + (x(1) - 1)*sum(log(evampl)) - sum(evampl)/x(2) - n*log(1 - gamcdf(xTrunc,x(1),x(2))));
%gamf2 = @(x)-n*x(1)*log(x(2)) - n*log(gamma(x(1))) + (x(1) - 1)*sum(log(evampl)) - sum(evampl)/x(2) - n*log(1 - gamcdf(xTrunc,x(1),x(2)));

%gamj1 = @(x) -n*log(x(2)) - n*psi(x(1)) + sum(log(evampl)) - n*(1/(1-gamcdf(xTrunc,x(1),x(2))))*(-1/(x(2)^x(1)*gamma(x(1)))*quad(fun2,0,xTrunc) + (psi(x(1)) + log(x(2)))*gamcdf(xTrunc,x(1),x(2)));
%gamj2 = @(x)-n*x(1)/x(2) + sum(evampl)/x(2)^2 - n*(1/(1-gamcdf(xTrunc,x(1),x(2))))*(1/(x(2)^(x(1)+1)*gamma(x(1))) * xTrunc^gamtruncparamnew(1) * exp(-xTrunc/x(2)));

%gamgrad = [gamj1
%    gamj2];

%gamftrunc=[gamf3
%gamgrad];

% Monte-Carlo sampling/Bayesian methods to find maximum likelihood
% estimates

%{
stepi = gamparaminit(1)/100;
stepj = gamparaminit(2)/100;


gamtruncparamnext = gamparaminit;

gamfnext = gamf1(gamparaminit(1), gamparaminit(2));

% if the value of the likelihood function is too close to 0, use log-likelihood
% function instead.
if (gamfnext == 0)
    gamfnext = gamf2(gamparaminit(1),gamparaminit(2));
end
gamfnow = gamfnext;

% Sample at each point in the 200 by 200 grid constructed by value of stepi
% and stepj.
gamparamfinal = gamtruncparamnext;
for i = 0:99
    for j = 0:99
        gamtruncparamnext(1) = gamparaminit(1) - i*stepi;
        gamtruncparamnext(2) = gamparaminit(2) - j*stepj;
        if (1-gamcdf(xTrunc,gamtruncparamnext(1),gamtruncparamnext(2)) > 0.00000001)
            if (gamf1(gamparaminit(1),gamparaminit(2)) == 0)
                gamfnext = gamf2(gamtruncparamnext(1), gamtruncparamnext(2));
            else
                gamfnext = gamf1(gamtruncparamnext(1), gamtruncparamnext(2));
            end
            if (gamfnext > gamfnow)
                gamparamfinal = gamtruncparamnext;
                gamfnow = gamfnext;
            end
        end
    end
end

alphahat3 = gamparamfinal(1);
betahat3 = gamparamfinal(2);

%}

x0 = [alphahat betahat];
A=[];
b=[];
Aeq=[];
Beq=[];
nonlcon=[];
lb=[0 0];
ub = [Inf Inf];
options = optimset('Algorithm','interior-point','Display','off');
x = fmincon(gamf3,x0,Aeq,Beq,A,b,lb,ub,nonlcon,options);

alphahat3=x(1);
betahat3=x(2);

% Calculate Fisher information and 95% confidence intervals from Hessian
% matrix evaluated at maximum likelihood estimate

fun=@(t)t.^(alphahat3 - 1).*exp(-t/betahat3).*(log(t)).^2;
fun2 =@(t)t.^(alphahat3 - 1).*exp(-t/betahat3).*log(t);
fun3 = @(t)t.^(alphahat3).*exp(-t/betahat3).*log(t);

gamh1expec = -n*psi(1,alphahat3) - n*((1/(1-gamcdf(xTrunc,alphahat3,betahat3)))*(-1*(1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun,0,xTrunc) - quad(fun2,0,xTrunc)*(1/(betahat3^alphahat3*gamma(alphahat3)))*(log(betahat3) + psi(0,alphahat3))) + (log(betahat3) + psi(0,alphahat3))*(1/(betahat3^alphahat3*gamma(alphahat3))*quad(fun2,0,xTrunc) - gamcdf(xTrunc,alphahat3,betahat3)*(log(betahat3) + psi(0,alphahat3))) + psi(1,alphahat3)*gamcdf(xTrunc,alphahat3,betahat3)) + (1/(1-gamcdf(xTrunc,alphahat3,betahat3)))^2*(-1)*(-1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun2,0,xTrunc) + gamcdf(xTrunc,alphahat3,betahat3)*(log(betahat3) + psi(0,alphahat3)))^2);
gamh2expec = -n/betahat3 - n*((1/(1-gamcdf(xTrunc,alphahat3,betahat3)))*(alphahat3/betahat3*1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun2,0,xTrunc) - 1/betahat3^2*1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun3,0,xTrunc) + (log(betahat3) + psi(0,alphahat3))*(-alphahat3/betahat3*gamcdf(xTrunc,alphahat3,betahat3) - 1/betahat3*xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^alphahat3*gamma(alphahat3)) + alphahat3/betahat3*gamcdf(xTrunc,alphahat3,betahat3)) + 1/betahat3*gamcdf(xTrunc,alphahat3,betahat3)) - (1/(1-gamcdf(xTrunc,alphahat3,betahat3)))^2*(-1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun2,0,xTrunc) + (log(betahat3) + psi(0,alphahat3))*gamcdf(xTrunc,alphahat3,betahat3))*(alphahat3/betahat3*gamcdf(xTrunc,alphahat3,betahat3) - 1/betahat3^2*(-betahat3*xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^alphahat3*gamma(alphahat3)) + alphahat3*betahat3*gamcdf(xTrunc,alphahat3,betahat3))));
gamh3expec = -n/betahat3 - n*((1/(1-gamcdf(xTrunc,alphahat3,betahat3)))*(alphahat3/betahat3*1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun2,0,xTrunc) - 1/betahat3^2*1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun3,0,xTrunc) + (log(betahat3) + psi(0,alphahat3))*(-alphahat3/betahat3*gamcdf(xTrunc,alphahat3,betahat3) - 1/betahat3*xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^alphahat3*gamma(alphahat3)) + alphahat3/betahat3*gamcdf(xTrunc,alphahat3,betahat3)) + 1/betahat3*gamcdf(xTrunc,alphahat3,betahat3)) - (1/(1-gamcdf(xTrunc,alphahat3,betahat3)))^2*(-1/(betahat3^alphahat3*gamma(alphahat3))*quadl(fun2,0,xTrunc) + (log(betahat3) + psi(0,alphahat3))*gamcdf(xTrunc,alphahat3,betahat3))*(alphahat3/betahat3*gamcdf(xTrunc,alphahat3,betahat3) - 1/betahat3^2*(-betahat3*xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^alphahat3*gamma(alphahat3)) + alphahat3*betahat3*gamcdf(xTrunc,alphahat3,betahat3))));
gamh4expec = n*alphahat3/betahat3^2 - 2*n*(xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^(alphahat3 - 1)*gamma(alphahat3))/(1-gamcdf(xTrunc,alphahat3,betahat3)) + alphahat3*betahat3)/betahat3^3 - n*((1/(1 - gamcdf(xTrunc,alphahat3,betahat3)))*(xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^(alphahat3 + 2)*gamma(alphahat3))*(-alphahat3 - 1 + xTrunc/betahat3)) - (xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^(alphahat3 + 1)*gamma(alphahat3)))^2*(1/(1-gamcdf(xTrunc,alphahat3,betahat3)))^2);


% Fisher information

gamF = zeros(2,2);
gamF(1,:) = [-gamh1expec -gamh2expec];
gamF(2,:) = [-gamh3expec -gamh4expec];

gamFinv = inv(gamF);

gamvaralphatrunc = gamFinv(1,1);
gamvarbetatrunc = gamFinv(2,2);

gamtruncalphaCI = 1.96*gamvaralphatrunc^(1/2);
gamtruncbetaCI = 1.96*gamvarbetatrunc^(1/2);


% 95% confidence interval for mean of amplitude
gamtruncmean = xTrunc^alphahat3*exp(-xTrunc/betahat3)/(betahat3^(alphahat3 - 1)*gamma(alphahat3))/(1 - gamcdf(xTrunc,alphahat3,betahat3)) + alphahat3*betahat3;

gamtruncmeangrad(1,:) = exp(-xTrunc/betahat3)*((1/(1-gamcdf(xTrunc,alphahat3,betahat3)))*(xTrunc^alphahat3/gamma(alphahat3)*-1/betahat3^(alphahat3 - 1)*log(betahat3) + 1/(betahat3^(alphahat3 - 1))*(xTrunc^alphahat3*log(xTrunc)/gamma(alphahat3) - xTrunc^alphahat3/gamma(alphahat3)*psi(0,alphahat3))) + xTrunc^alphahat3/(betahat3^(alphahat3 - 1)*gamma(alphahat3))*(-1/(1 - gamcdf(xTrunc,alphahat3,betahat3))^2)*(-1*(1/(betahat3^alphahat3*gamma(alphahat3))*quad(fun2,0,xTrunc) - (log(betahat3) + psi(0,alphahat3))*gamcdf(xTrunc,alphahat3,betahat3)))) + betahat3;
gamtruncmeangrad(2,:) = xTrunc^alphahat3/gamma(alphahat3)*((1/(1-gamcdf(xTrunc,alphahat3,betahat3)))*(exp(-xTrunc/betahat3)*(-1)*(alphahat3 - 1)*betahat3^(-alphahat3) + 1/betahat3^(alphahat3 - 1)*exp(-xTrunc/betahat3)*(xTrunc/betahat3^2)) + exp(-xTrunc/betahat3)/betahat3^(alphahat3 - 1)*(-1/(1-gamcdf(xTrunc,alphahat3,betahat3))^2)*(xTrunc^alphahat3*exp(-xTrunc/betahat3))/(betahat3^(alphahat3 - 1)*gamma(alphahat3))) + alphahat3;

gamtruncmeanvar = gamtruncmeangrad'*gamFinv*gamtruncmeangrad;

gamtruncmeanCI = 1.96*gamtruncmeanvar^(1/2);


%%%%% FIGURES
%{
figure
hold on;
subplot(2,1,1)
hold on
[counts xout]=hist(evampl, 50);
bar(xout, counts/sum(counts)*100)
xlabel('Amplitude (pA)');
ylabel('Percent')
xs=xlim;
xlim([0 xs(2)]);
ys=ylim;
ylim([0 (ys(2)+2)]);

%Gamma overlay

subplot(2,1,1)
bin = (xout(2)-xout(1))/2;
z=(gamcdf(xout+bin, alphahat3, betahat3)-gamcdf(xout-bin, alphahat3, betahat3))/(1-gamcdf(xTrunc,alphahat3,betahat3));
plot(xout,z*100,'r')
title('Amplitude histogram - Gamma model')


% Gamma g-o-f
subplot(2,1,2)
%}
step=1/(2*n);
qqcdfstep=step:2*step:1;
qqcdf=qqcdfstep*(1 - gamcdf(xTrunc,alphahat3,betahat3)) + gamcdf(xTrunc,alphahat3,betahat3);
gamtruncqq=gaminv(qqcdf,alphahat3,betahat3);
%qqplot(evampl,gamtruncqq);
%title('Q-Q plot - Left-truncated Gamma model')

[h p k] = kstest2(evampl,gamtruncqq);
gof=[h p k];

%output = [ n, ieith, riseth, amplth, mu,unshiftedmuCI,sqrt(sigma2),unshiftedsigmaCI,lognh, hCI, mu2,shiftedmuCI,sqrt(sigma22),shiftedsigmaCI, h2, hCI2, logmuhat, lognmuCI, logsigmahat, lognsigmaCI, lognmode, lognmodeCI, logntruncmean, logntruncmeanCI, alphahat, gamalphaCI, betahat, gambetaCI, gammean, gammeanCI, alphahat2, gamshiftalphaCI, betahat2, gamshiftbetaCI,gamshiftmean, gamshiftmeanCI, alphahat3, gamtruncalphaCI, betahat3, gamtruncbetaCI, gamtruncmean, gamtruncmeanCI,muhat, invgunshiftedmuCI, lambdahat, invgunshiftedlambdaCI, invgunshiftedmean, invgunshiftedmeanCI, muhat2, invgshiftedmuCI, lambdahat2, invgshiftedlambdaCI, invgshiftedmean, invgshiftedmeanCI, invgmuhat, invgmuCI, invglambdahat, invglambdaCI, invgmode, invgmodeCI, invgtruncmean, invgtruncmeanCI, khat2, kCI, paretomean, paretomeanCI, %disp(output)
params=[alphahat3 gamtruncalphaCI betahat3 gamtruncbetaCI gamtruncmean gamtruncmeanCI];

