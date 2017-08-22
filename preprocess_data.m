function [prepTS,scalemax,scalemin]=preprocess_data(TS,method,inmax,inmin,Upper,Lower)
% normalizes timeseries
% TS        - m x n matrix of n raw timeseries (one per column) with m timebins
% method    - method of normalization
%             'scale'       = scales timeseries to values between Upper and
%             Lower (standard -1 and 1) with respect to inmax (max) and
%             inmin(min)
%             'norm'        = zscore normalization (inmax mean, inmin std)
%             'vector'      = vector length of one (inmax vectornorm)
%             standard deviations are set to 2 standard deviations
% prepTS    - m x n matrix of n preprocessed timeseries with m timebins
% by KS 16.03.2011

switch method
    case {'off','retrooff'}
        prepTS=TS;
        scalemax=0;
        scalemin=0;
    case 'scale'
        if nargin<5
            Upper=1;Lower=0;
        end
        
        if nargin<3
            scalemax = max(TS);
            scalemin = min(TS);
        else scalemax = inmax;
            scalemin=inmin;
        end
        [r,c]= size(TS);
        l=repmat(Lower,r,c);
        u=repmat(Upper,r,c);
        ma=repmat(scalemax,r,1);
        mi=repmat(scalemin,r,1);
        
        prepTS= ((TS-mi).*((u-l)./(ma-mi))+l);
    

    case 'retroscale'
        if nargin<5
            Upper=1;Lower=-1;
        end
        
        if nargin<3
            scalemax = max(TS);
            scalemin = min(TS);
        else scalemax = inmax;
            scalemin=inmin;
        end
        [r,c]= size(TS);
        l=repmat(Lower,r,c);
        u=repmat(Upper,r,c);
        ma=repmat(scalemax,r,1);
        mi=repmat(scalemin,r,1);

        prepTS= ((TS-l).*((ma-mi)./(u-l))+mi);

    case 'norm'
        if nargin<4
            scalemax=mean(TS);
            scalemin=std(TS);
        else
            scalemax=inmax;
            scalemin=inmin;
        end
        m=repmat(scalemax,size(TS,1),1);
        s=repmat(scalemin,size(TS,1),1);
        prepTS=(TS-m)./s;

    case 'retronorm'
        if nargin<4
            scalemax=mean(TS);
            scalemin=std(TS);
        else
            scalemax=inmax;
            scalemin=inmin;
        end
        m=repmat(scalemax,size(TS,1),1);
        s=repmat(scalemin,size(TS,1),1);
        prepTS=TS.*s+m;
    
    case 'vector'
        if nargin<3
            scalemax=zeros(1,size(TS,2));
            for i=1:size(TS,2)
                scalemax(i)=norm(TS(:,i));
                %prepTS(:,i)=TS(:,i)./scalemax(i);
            end            
        else
            scalemax=inmax;
        end
        prepTS=bsxfun(@rdivide,TS,repmat(scalemax,size(TS,1),1));
        scalemin=[];
        
    case 'retrovector'
        if nargin<3
            scalemax=zeros(1,size(TS,2));
            for i=1:size(TS,2)
                scalemax(i)=norm(TS(:,i));
                %prepTS(:,i)=TS(:,i)./scalemax(i);
            end
        else
            scalemax=inmax;
        end
        prepTS=bsxfun(@times,TS,repmat(scalemax,size(TS,1),1));
        scalemin=[];
        
    case 'log'
        prepTS=log10(TS);
        scalemax=[];
        scalemin=[];
        
    case 'retrolog'
        prepTS=10.^TS;
        scalemax=[];
        scalemin=[];
end

