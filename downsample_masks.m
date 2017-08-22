i1=fullfile('..','groupstat','25sub_no33no36','loc_resample','mask.img');
mask=dir(fullfile('..','mask','*.nii'));


Vi(1)=spm_vol(i1);
for m=1:length(mask);
    Vi(2)=spm_vol(fullfile('..','mask',mask(m).name));
    
    
    Vo.fname=fullfile('..','mask','3x3x3',strrep(mask(m).name,'.nii','_3x3x3.nii'));
    Vo.dim=Vi(1).dim;
    Vo.dt=Vi(1).dt;
    Vo.dt(1)=4;
    Vo.mat=Vi(1).mat;
    Vo.descrip='spm - algebra';
    
    flags{1}=[0];flags{2}=[0];flags{3}=[1];
    dmtx=0;
    f='(i1.*i2)>0.5';
    
    spm_imcalc(Vi,Vo,f,flags);
end


