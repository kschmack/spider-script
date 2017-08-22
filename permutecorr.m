function [r p]=permutecorr(x,y,n,str)

if nargin<4
    str='two';
end

d=length(x);
rho=zeros(1,n);
for k=1:n
   y2=y(randperm(d));
   rho(k)=corr(x,y2);
end
r=corr(x,y);
pup=sum(rho>r)/n;
if pup<.5;p=pup;else p=1-pup;end
if strcmp(str,'two')
    p=p*2;
elseif strcpm(str,'one');
    p=p;
else error('Please choose between the options ''one'' for one-sided p-value and ''two'' for two-sided p-value!'\n)
    
end



