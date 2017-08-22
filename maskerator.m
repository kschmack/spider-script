imlist=dir('/Volumes/ZIMTZICKE/spider/mask/*nii');
    im1='/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/loc_resample/mask.img'
%im1='/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_realign_off_rad08_smo03war03/invis/mask.img';
f='i1.*i2';
flags{1}=0;flags{2}=0;flags{3}=1;

for k=1:length(imlist)
    im2=fullfile('/Volumes/ZIMTZICKE/spider/mask/',imlist(k).name);

    Vi(1)=spm_vol(im1);
    Vi(2)=spm_vol(im2);
    Vo=Vi(1);
    Vo.fname=fullfile('/Volumes/ZIMTZICKE/spider/mask/3x3x3/',strrep(imlist(k).name,'.nii','_3x3x3.nii'));
    Vo.dim=Vi(1).dim;
    Vo.dt=Vi(1).dt;
        Vo.mat=Vi(1).mat; 
    Vo.descrip= 'spm - algebra';
    spm_imcalc(Vi,Vo,f,flags);
% spm_check_orientations(Vi)
end