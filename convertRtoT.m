function t=convertRtoT(r,df)

if length(r)==1
t=sqrt(df*r^2/(1-r^2));
else 
    for k=1:length(r)
        t(k)=sqrt(df*r(k)^2/(1-r(k)^2));
    end
    
end