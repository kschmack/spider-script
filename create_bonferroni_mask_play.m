
clear;
nonvis='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/visflo_vs_visspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
parvis='../groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/visflo_vs_visspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear';

noninv='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
parinv='../groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear';

v=load(nonvis);
i=load(noninv);


%MASK IMAGES


files1=dir(fullfile('../mask/3x3x3/LO*'));
files2=dir(fullfile('../mask/3x3x3/pFus*'));
files3=dir(fullfile('../mask/3x3x3/fus*'));
files4=dir(fullfile('../mask/3x3x3/lat*'));
files5=dir(fullfile('../mask/3x3x3/midtemp*'));
files6=dir(fullfile('../mask/3x3x3/temp*'));
files7=dir(fullfile('../mask/3x3x3/V1*'));
files=[files7];

for f=1:length(files)
    
    %load mask
    maskim=fullfile('../mask/3x3x3/',files(f).name);
    [maskpath maskname maskend]=fileparts(maskim);
    V=spm_vol(maskim);
    [mask XYZmm_mask]=spm_read_vols(V);
    XYZmm_inmask=XYZmm_mask(:,mask(:)>0);


    %merge nonpara results with mask
    l=false(1,size(v.XYZmm,2));%index to voxels in mask
    for k=1:size(XYZmm_inmask,2)
        lplus=sum(bsxfun(@eq,v.XYZmm,XYZmm_inmask(:,k)))==3;
        l=l+lplus;
    end
    
    %calculate surviving voxels
    crit1=v.pcrp<(0.05/voxelcount(maskim));%index to voxels with visible p-value correctable for volume
    crit2=i.pcrp<(0.05/voxelcount(maskim));%index to voxels with visible p-value correctable for volume
    crit3=l;%index to voxels in volume
    
    mycrit=sum(crit2&crit3)>0&sum(crit1&crit3)==0;
    if mycrit
       fprintf('%s\n',maskim);
    end
%     center_mm=XYZmm(:,crit1&crit2);%center in mm
%     center_vox=round(V.mat\[center_mm; ones(1,size(center_mm,2))]);%center in vox    
%     pval=pcrp(crit1&crit2);
%     
%     %writ voxels in output image
%     name=fullfile(paradir,sprintf('Bonferroni_p05_within_%s.nii',maskname));
%     
%     %create VOI
%     M=zeros(V.dim);
%     P=zeros(V.dim);
%     O = ones(1,length(XYZmm));
%     
%     
%     for n=1:size(center_vox,2)
%         M(center_vox(1,n),center_vox(2,n),center_vox(3,n))=1;
%         P(center_vox(1,n),center_vox(2,n),center_vox(3,n))=pval(n);
%     end
%         
%     %write image
%     oim   = struct('fname', name,...
%         'dim',   {V.dim},...
%         'dt',    {[16 0]},...
%         'pinfo', {V.pinfo},...
%         'mat',   {V.mat},...
%         'descrip', {sprintf('Bonferroni corrected voxels within %s',maskname)});
%     oim=spm_create_vol(oim);
%     oim=spm_write_vol(oim,M);
    
end



