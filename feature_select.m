function [findex]=feature_select(traindata,trainlabel,method,XYZ)
% performs feature selection
% traindata
% trainlabel
% method    'ftest' - orders features according to f values 
%           'none' - uses all features
%           'searchlite' - outputs all features, the searchlite will be
%           performed outside this script
%           'spmT*.img' - orders features according to values in image
% XYZ       - necessary argument, if method is an image 
% findex    - vector with sorted indices, starting with the index of the
% feature that has the highest value

[pfad name endung]=fileparts(method);
if strcmp(endung, '.img') || strcmp(endung,'.nii')
   if nargin<4
       error('Please specify the voxel coordinates!')
   end
   v=spm_vol(method);
   f=spm_get_data(v,XYZ);
   f(isnan(f))=min(f);
   [fsort,findex]=sort(f,'descend');
end

switch method
    case 'ftest'
        f=zeros(1,size(traindata,2));
            for k=1:size(traindata,2)
                [p fval]=anova1(traindata(:,k),trainlabel,'off');
                f(k)=fval{2,5};
            end
            [fsort,findex]=sort(f,'descend');
    case 'ttest'
        vec1=traindata(trainlabel==1,:);
        vec2=traindata(trainlabel==-1,:);
        [h,p,ci,stats] = ttest2(vec1,vec2);
        f=stats.tstat;
        f1=f;f2=f;
        f1(f1<0)=0;f2(f2>0)=0;
        [fsort1,findex1]=sort(f1,'descend');
        [fsort2,findex2]=sort(f2,'ascend');
        fsort=[fsort1;fsort2];
        findex=[findex1;findex2];
        fsort=fsort(:);
        findex=findex(:);
        findex(fsort~=0);
    case {'none','searchlite'}
        f=1:size(traindata,2);
        [fsort,findex]=sort(f,'descend');
    case 'pearson'
        f=corr(traindata,trainlabel);
        [fsort,findex]=sort(abs(f),'descend');
end
