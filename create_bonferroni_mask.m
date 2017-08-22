% % %BONFERRONI WHOLE BRAIN
clear;
nonpara='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
paradir='../groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear';
% 
% load(nonpara);
% name=fullfile(paradir,'bonferroni_p10.nii');
% % 
% % load template
% V=spm_vol('../groupstat/25sub_no33no36/loc_resample/mask.img');
% [trash XYZmm2]=spm_read_vols(V);
% 
% center=XYZ(:,pcrp<(0.1/length(XYZ)));
% trash(:,:,:)=0;
% for c=1:length(center)
%     trash(center(1,c),center(2,c),center(3,c))=1;
% end
% 
% 
% %write image
% oim   = struct('fname', name,...
%     'dim',   {V.dim},...
%     'dt',    {[16 0]},...
%     'pinfo', {V.pinfo},...
%     'mat',   {V.mat},...
%     'descrip', {'Bonferroni corrected voxels'});
% oim=spm_create_vol(oim);
% oim=spm_write_vol(oim,trash);
% 
%UNCORRECTED WHOLE BRAIN
load(nonpara);
name=fullfile(paradir,'uncorrected_p05.nii');

% load template
V=spm_vol('../groupstat/25sub_no33no36/loc_resample/mask.img');
[trash XYZmm2]=spm_read_vols(V);

center=XYZ(:,pcrp<(0.05));
trash(:,:,:)=0;
for c=1:length(center)
    trash(center(1,c),center(2,c),center(3,c))=1;
end


%write image
oim   = struct('fname', name,...
    'dim',   {V.dim},...
    'dt',    {[16 0]},...
    'pinfo', {V.pinfo},...
    'mat',   {V.mat},...
    'descrip', {'p<0.05 voxels'});
oim=spm_create_vol(oim);
oim=spm_write_vol(oim,trash);


%MASK IMAGES

files={'amygdala_aal_3x3x3.nii','LOCp001_bilateral_localizer_3x3x3.nii','V1_mask_25SUB_3x3x3.nii'};
%files={'LOp001_bilateral_localizer_3x3x3.nii','pFusp001_bilateral_localizer_3x3x3.nii'};%,'pFusp01fwe_bilateral_localizer_3x3x3.nii'};%'LOCp001_bilateral_localizer_3x3x3.nii','amygdala_probabilistic_2sd_3x3x3.nii',,'V1_mask_25SUB_3x3x3.nii'
for f=1:length(files)
maskim=fullfile('../mask/3x3x3/',files{f});
[maskpath maskname maskend]=fileparts(maskim);

load(nonpara);
%load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_searchlitewarp03_scale_labelscale_linear/coordinates.mat');
center=XYZmm(:,pcrp<(0.05/voxelcount(maskim)));%[-42 -74 -10]'; %center in mm
pval=pcrp(pcrp<(0.05/voxelcount(maskim)));
radius=0; %radius in mm
name=fullfile(paradir,sprintf('Bonferroni_p05_within_%s.nii',maskname));


% load template
V=spm_vol(maskim);
[trash XYZmm]=spm_read_vols(V);

% % adjust rounded coordinates
% f=find(round(XYZmm(3,:))==center(3,:));
% center(3)=XYZmm(3,f(1));

%create VOI
M=zeros(V.dim);
P=zeros(V.dim);
O = ones(1,length(XYZmm));
for l=1:size(center,2)
    s = (sum((XYZmm-center(:,l)*O).^2) <= radius);
    M(s)=1;
    P(s)=pval(l);
end

%mask it
MM=M.*trash;
PM=P.*trash;

%write image
oim   = struct('fname', name,...
    'dim',   {V.dim},...
    'dt',    {[16 0]},...
    'pinfo', {V.pinfo},...
    'mat',   {V.mat},...
    'descrip', {sprintf('Bonferroni corrected voxels within %s',maskname)});
oim=spm_create_vol(oim);
oim=spm_write_vol(oim,MM);

end

clear;

