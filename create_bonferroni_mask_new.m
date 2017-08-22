% % %BONFERRONI WHOLE BRAIN
% clear;
%nonpara='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/visflo_vs_visspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
%paradir='../groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/visflo_vs_visspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear';

nonpara='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
paradir='../groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear';

load(nonpara);
name=fullfile(paradir,'bonferroni_p05.nii');
% 
% load template
V=spm_vol('../groupstat/25sub_no33no36/loc_resample/mask.img');
[trash XYZmm2]=spm_read_vols(V);

center=XYZ(:,pcrp<(0.05/length(XYZ)));
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
load(nonpara);
name=fullfile(paradir,'uncorrected_p001.nii');

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
%files={'amygdala_aal_3x3x3.nii','LOCp001_bilateral_localizer_3x3x3.nii','V1_mask_25SUB_3x3x3.nii'};
files={'LOp001_bilateral_localizer_3x3x3.nii','pFusp001_bilateral_localizer_3x3x3.nii','fus_mask_25SUB_3x3x3.nii'};%'LOC_locresample_p001_3x3x3.nii','LOC_locresample_p05fwe_3x3x3.nii'};%,'pFusp01fwe_bilateral_localizer_3x3x3.nii'};%'LOCp001_bilateral_localizer_3x3x3.nii','amygdala_probabilistic_2sd_3x3x3.nii',,'V1_mask_25SUB_3x3x3.nii'
for f=1:length(files)
    %load mask
    maskim=fullfile('../mask/3x3x3/',files{f});
    [maskpath maskname maskend]=fileparts(maskim);
    V=spm_vol(maskim);
    [mask XYZmm_mask]=spm_read_vols(V);
    XYZmm_inmask=XYZmm_mask(:,mask(:)>0);

    %load results
    load(nonpara);
    
    l=false(1,size(XYZmm,2));
    %merge nonpara results with mask
    for k=1:size(XYZmm_inmask,2)
        lplus=sum(bsxfun(@eq,XYZmm,XYZmm_inmask(:,k)))==3;
        l=l+lplus;
    end
    
    %calculate surviving voxels
    crit1=pcrp<(0.1/voxelcount(maskim));%index to voxels with p-value correctable for volume
    crit2=l;%index to voxels in volume
    
    center_mm=XYZmm(:,crit1&crit2);%center in mm
    center_vox=round(V.mat\[center_mm; ones(1,size(center_mm,2))]);%center in vox    
    pval=pcrp(crit1&crit2);
    
    %writ voxels in output image
    name=fullfile(paradir,sprintf('Bonferroni_p10_within_%s.nii',maskname));
    
    %create VOI
    M=zeros(V.dim);
    P=zeros(V.dim);
    O = ones(1,length(XYZmm));
    
    
    for n=1:size(center_vox,2)
        M(center_vox(1,n),center_vox(2,n),center_vox(3,n))=1;
        P(center_vox(1,n),center_vox(2,n),center_vox(3,n))=pval(n);
    end
        
    %write image
    oim   = struct('fname', name,...
        'dim',   {V.dim},...
        'dt',    {[16 0]},...
        'pinfo', {V.pinfo},...
        'mat',   {V.mat},...
        'descrip', {sprintf('Bonferroni corrected voxels within %s',maskname)});
    oim=spm_create_vol(oim);
    oim=spm_write_vol(oim,M);
    
    fprintf('%s: R %d  L %d\n',files{f},sum(center_mm(1,:)>0),sum(center_mm(1,:)<0))
    
end



