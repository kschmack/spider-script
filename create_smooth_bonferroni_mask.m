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
spm_smooth(oim.fname,strrep(oim.fname,'p.nii','s03p.nii'),[3 3 3]);

%relaod p image and add smoothed p-values to label.mat
V=spm_vol(strrep(oim.fname,'p.nii','s03p.nii'));
[smoothp XYZmm3]=spm_read_vols(V);
smoothp(isnan(trash))=nan;

for k=1:length(pcrp)
   spcrp(k)=smoothp(XYZ(1,k),XYZ(2,k),XYZ(3,k));
end
% %BONFERRONI WHOLE BRAIN
clear;
load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/label.mat');
name='../groupstat/25sub_no33no36/searchlite_support_vector_regression_nosmooth/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/bonferroni_p10.nii';

% load template
V=spm_vol('../groupstat/25sub_no33no36/loc_resample/mask.img');
[trash XYZmm2]=spm_read_vols(V);

center=XYZ(:,pcrp<(0.1/length(XYZ)));
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
    'descrip', {'Bonferroni corrected voxels'});
oim=spm_create_vol(oim);
oim=spm_write_vol(oim,trash);

%UNCORRECTED WHOLE BRAIN
clear;
load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/label.mat');
name='../groupstat/25sub_no33no36/searchlite_support_vector_regression_nosmooth/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/uncorrected_p001.nii';

% load template
V=spm_vol('../groupstat/25sub_no33no36/loc_resample/mask.img');
[trash XYZmm2]=spm_read_vols(V);

center=XYZ(:,pcrp<(0.001));
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
    'descrip', {'p<0.001 voxels'});
oim=spm_create_vol(oim);
oim=spm_write_vol(oim,trash);


%MASK IMAGES
clear;
files={'LOCp001_bilateral_localizer_3x3x3.nii','amygdala_probabilistic_2sd_3x3x3.nii','LOp001_bilateral_localizer_3x3x3.nii','pFusp001_bilateral_localizer_3x3x3.nii','V1_mask_25SUB_3x3x3.nii'};
for f=1:length(files)
maskim=fullfile('../mask/3x3x3/',files{f});
[maskpath maskname maskend]=fileparts(maskim);

load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/label.mat');
%load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_searchlitewarp03_scale_labelscale_linear/coordinates.mat');
center=XYZmm(:,pcrp<=(0.5/voxelcount(maskim)));%[-42 -74 -10]'; %center in mm
radius=0; %radius in mm
name=sprintf('../groupstat/25sub_no33no36/searchlite_support_vector_regression_nosmooth/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/Bonferroni_plessequal05_within_%s.nii',maskname);


% load template
V=spm_vol(maskim);
[trash XYZmm]=spm_read_vols(V);

% % adjust rounded coordinates
% f=find(round(XYZmm(3,:))==center(3,:));
% center(3)=XYZmm(3,f(1));

%create VOI
M=zeros(V.dim);
O = ones(1,length(XYZmm));
for l=1:size(center,2)
    s = (sum((XYZmm-center(:,l)*O).^2) <= radius);
    M(s)=1;
end

%mask it
MM=M.*trash;

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

% %MAKE Pseudo-T-IMAGE TO DISPLAY
% load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/label.mat');
% spmpath=('../groupstat/25sub_no33no36/searchlite_support_vector_regression_nosmooth/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/test/');
% 
% % load original T-image
% V=spm_vol(fullfile(spmpath,'spmT_0001.img'));
% [trash XYZmm]=spm_read_vols(V);
% 
% % replace T-values with non-parametric p-values
% M=zeros(V.dim);
% O = ones(1,length(XYZmm));
% 
% pwhole=pcrp*length(pcrp);
% pseudot=convertRtoT(cr,23);
% 
% for l=1:size(XYZ,2)
%     x=XYZ(1,l);
%     y=XYZ(2,l);
%     z=XYZ(3,l);
%     M(x,y,z)=pseudot(l);
% end
% 
% %critical pseudo-T
% oim=spm_create_vol(V);
% oim=spm_write_vol(V,M);


%print values at coordinates
load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/label.mat');

corlist={[-18  35 -11],[-45 -70  -5],[42 -52 -11],[15 -79   7]};
namelist={'left OFC','left LOC','right LOC','V1'};
voxnum=[length(pcrp) voxelcount('../mask/3x3x3/LOCp001_bilateral_localizer_3x3x3.nii') voxelcount('../mask/3x3x3/LOCp001_bilateral_localizer_3x3x3.nii') length(pcrp)];
for k=1:length(corlist)
    x=corlist{k}(1);
    y=corlist{k}(2);
    z=corlist{k}(3);
    target=find(XYZmm(1,:)==x&XYZmm(2,:)==y&XYZmm(3,:)==z);
    fprintf('%s: pseudoT=%2.2f, p=%2.5f\n',namelist{k},convertRtoT(cr(target),23),pcrp(target)*voxnum(k))
end


