% SMOOTH P
clear;
load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/label.mat');
name='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/p.nii';

% load template
V=spm_vol('../groupstat/25sub_no33no36/loc_resample/mask.img');
[trash XYZmm2]=spm_read_vols(V);


%fill in p values
trash(:,:,:)=nan;
for k=1:length(pcrp)
    trash(XYZ(1,k),XYZ(2,k),XYZ(3,k))=pcrp(k);
end

%write p image
oim   = struct('fname', name,...
    'dim',   {V.dim},...
    'dt',    {[16 0]},...
    'pinfo', {V.pinfo},...
    'mat',   {V.mat},...
    'descrip', {'Bonferroni corrected voxels'});
oim=spm_create_vol(oim);
oim=spm_write_vol(oim,trash);

%smooth p image
spm_smooth(oim.fname,strrep(oim.fname,'p.nii','s03p.nii'),[.5 .5 .5]);

%relaod p image and add smoothed p-values to label.mat
V=spm_vol(strrep(oim.fname,'p.nii','s03p.nii'));
[smoothp XYZmm3]=spm_read_vols(V);
smoothp(isnan(trash))=nan;

for k=1:length(pcrp)
   spcrp(k)=smoothp(XYZ(1,k),XYZ(2,k),XYZ(3,k));
end

%save new variables
newname=('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/newlabel.mat');
save(newname,'XYZ','XYZmm','cr','mcrp','ncrp','pcrp','spcrp','preplabelstring')




