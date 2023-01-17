% rank sum confidence interval for difference between two groups

function [delta ci]= ranksumci(x,y)


%%

m=length(x);
n=length(y);
d=[];
uy=0;

for i=1:m
    for j=1:n
        d(end+1)=y(j)-x(i);
    end
end

d=sort(d);
delta=median(d);
k=-1.96*sqrt(m*n*(m+n+1)/12)+m*n/2;

ci(1)=d(floor(k));
ci(2)=d(ceil(m*n-k));


