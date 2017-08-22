
% clear;
clear;


nonpara{1}='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
paradir{1}='../groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear';
nonpara{2}='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/visflo_vs_visspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
paradir{2}='../groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/visflo_vs_visspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear';
label={'INVISIBLE','VISIBLE'};

for k=1:2
    fprintf('%s\n\n',label{k})
    
    %load mask
    maskim='../groupstat/25sub_no33no36/loc_resample/mask.img';
    [maskpath maskname maskend]=fileparts(maskim);
    V=spm_vol(maskim);
    [mask XYZmm_mask]=spm_read_vols(V);
    XYZmm_inmask=XYZmm_mask(:,mask(:)>0);
    
    %load results
    load(nonpara{k});
    l=true(1,size(XYZmm,2));
    
    %calculate surviving voxels
    crit1=pcrp<(0.05/size(XYZmm,2));%index to voxels with p-value correctable for volume
    crit2=l;%index to voxels in volume
    
    center_mm=XYZmm(:,crit1&crit2);%center in mm
    center_vox=round(V.mat\[center_mm; ones(1,size(center_mm,2))]);%center in vox
    pval=pcrp(crit1&crit2);
    rval=cr(crit1&crit2);
    
    % voxel threshold voxel
    %create VOI
    M=zeros(V.dim);
    P=zeros(V.dim);
    R=zeros(V.dim);
    O = ones(1,length(XYZmm));
    
    
    for n=1:size(center_vox,2)
        M(center_vox(1,n),center_vox(2,n),center_vox(3,n))=1;
        P(center_vox(1,n),center_vox(2,n),center_vox(3,n))=pval(n);
        R(center_vox(1,n),center_vox(2,n),center_vox(3,n))=rval(n);
    end
    
    
    [L,NUM]=bwlabeln(M);
    statsP = regionprops(L,P, 'area', 'centroid','PixelList','PixelValues');
    statsR = regionprops(L,R, 'area', 'centroid','PixelList','PixelValues');
    fprintf('%s\n','whole brain')
    for ki=1:length(statsR)
        if statsR(ki).Area>5
            [a mi]=max(statsR(ki).PixelValues);
            shortindex=statsR(ki).PixelList(mi,1)==center_vox(2,:)&statsR(ki).PixelList(mi,2)==center_vox(1,:)&statsR(ki).PixelList(mi,3)==center_vox(3,:);
            fprintf('%d %d %d (%d voxels): r=%2.2f pseudoT=%2.2f p=%2.4f\n',center_mm(1,shortindex),center_mm(2,shortindex),center_mm(3,shortindex),statsR(ki).Area,statsR(ki).PixelValues(mi),tinv(1-statsP(ki).PixelValues(mi),23),statsP(ki).PixelValues(mi))
        end
    end
    
    
    
    
    %MASK IMAGES
    %files={'amygdala_aal_3x3x3.nii','LOCp001_bilateral_localizer_3x3x3.nii
    %','V1_mask_25SUB_3x3x3.nii'};,
    files={'amygdala_aal_3x3x3.nii','fus_mask_25SUB_3x3x3.nii','obj_vs_scr_x_allstimuli_x_occtemp_3x3x3.nii'};%'LOC_locresample_p001_3x3x3.nii','LOC_locresample_p05fwe_3x3x3.nii'};%,'pFusp01fwe_bilateral_localizer_3x3x3.nii'};%'LOCp001_bilateral_localizer_3x3x3.nii','amygdala_probabilistic_2sd_3x3x3.nii',,'V1_mask_25SUB_3x3x3.nii'
    for f=1:length(files)
        %load mask
        maskim=fullfile('../mask/3x3x3/',files{f});
        [maskpath maskname maskend]=fileparts(maskim);
        V=spm_vol(maskim);
        [mask XYZmm_mask]=spm_read_vols(V);
        XYZmm_inmask=XYZmm_mask(:,mask(:)>0);
        
        %load results
        load(nonpara{k});
        
        l=false(1,size(XYZmm,2));
        %merge nonpara results with mask
        for q=1:size(XYZmm_inmask,2)
            lplus=sum(bsxfun(@eq,XYZmm,XYZmm_inmask(:,q)))==3;
            l=l+lplus;
        end
        
        %calculate surviving voxels
        crit1=pcrp<(0.05/voxelcount(maskim));%index to voxels with p-value correctable for volume
        crit2=l;%index to voxels in volume
        
        center_mm=XYZmm(:,crit1&crit2);%center in mm
        center_vox=round(V.mat\[center_mm; ones(1,size(center_mm,2))]);%center in vox
        pval=pcrp(crit1&crit2);
        rval=cr(crit1&crit2);
        
        % voxel threshold voxel
        %create VOI
        M=zeros(V.dim);
        P=zeros(V.dim);
        R=zeros(V.dim);
        O = ones(1,length(XYZmm));
        
        
        for n=1:size(center_vox,2)
            M(center_vox(1,n),center_vox(2,n),center_vox(3,n))=1;
            P(center_vox(1,n),center_vox(2,n),center_vox(3,n))=pval(n);
            R(center_vox(1,n),center_vox(2,n),center_vox(3,n))=rval(n);
        end
        
        
        [L,NUM]=bwlabeln(M);
        statsP = regionprops(L,P, 'area', 'centroid','PixelList','PixelValues');
        statsR = regionprops(L,R, 'area', 'centroid','PixelList','PixelValues');
        fprintf('%s\n',files{f})
        for ki=1:length(statsR)
            if statsR(ki).Area>1
                [a mi]=max(statsR(ki).PixelValues);
                shortindex=statsR(ki).PixelList(mi,1)==center_vox(2,:)&statsR(ki).PixelList(mi,2)==center_vox(1,:)&statsR(ki).PixelList(mi,3)==center_vox(3,:);
                fprintf('%d %d %d (%d voxels): r=%2.2f pseudoT=%2.2f p=%2.4f\n',center_mm(1,shortindex),center_mm(2,shortindex),center_mm(3,shortindex),statsR(ki).Area,statsR(ki).PixelValues(mi),tinv(1-statsP(ki).PixelValues(mi),23),statsP(ki).PixelValues(mi))
            end
        end
    
    
        %calculate surviving voxels left side 0.001 uncorrected
        crit1=pcrp<(0.05);%index to voxels with p-value correctable for volume
        crit2=l;%index to voxels in volume
        
        center_mm=XYZmm(:,crit1&crit2);%center in mm
        center_vox=round(V.mat\[center_mm; ones(1,size(center_mm,2))]);%center in vox
        pval=pcrp(crit1&crit2);
        rval=cr(crit1&crit2);
        
        % voxel threshold voxel
        %create VOI
        M=zeros(V.dim);
        P=zeros(V.dim);
        R=zeros(V.dim);
        O = ones(1,length(XYZmm));
        
        
        for n=1:size(center_vox,2)
            M(center_vox(1,n),center_vox(2,n),center_vox(3,n))=1;
            P(center_vox(1,n),center_vox(2,n),center_vox(3,n))=pval(n);
            R(center_vox(1,n),center_vox(2,n),center_vox(3,n))=rval(n);
        end
        
        
        [L,NUM]=bwlabeln(M);
        statsP = regionprops(L,P, 'area', 'centroid','PixelList','PixelValues');
        statsR = regionprops(L,R, 'area', 'centroid','PixelList','PixelValues');
        fprintf('%s 0.001 unc\n',files{f})
        for ki=1:length(statsR)
            if statsR(ki).Area>0
                [a mi]=max(statsR(ki).PixelValues);
                shortindex=statsR(ki).PixelList(mi,1)==center_vox(2,:)&statsR(ki).PixelList(mi,2)==center_vox(1,:)&statsR(ki).PixelList(mi,3)==center_vox(3,:);
                fprintf('%d %d %d (%d voxels): r=%2.2f pseudoT=%2.2f p=%2.4f\n',center_mm(1,shortindex),center_mm(2,shortindex),center_mm(3,shortindex),statsR(ki).Area,statsR(ki).PixelValues(mi),tinv(1-statsP(ki).PixelValues(mi),23),statsP(ki).PixelValues(mi))
            end
        end
        
%         %UNCORRECTED WHOLE BRAIN
%         %load results
%         load(nonpara{k});
%         l=true(1,size(XYZmm,2));
%         
%         %calculate surviving voxels
%         crit1=pcrp<(0.001);%index to voxels with p-value correctable for volume
%         crit2=l;%index to voxels in volume
%         
%         center_mm=XYZmm(:,crit1&crit2);%center in mm
%         center_vox=round(V.mat\[center_mm; ones(1,size(center_mm,2))]);%center in vox
%         pval=pcrp(crit1&crit2);
%         rval=cr(crit1&crit2);
%         
%         % voxel threshold voxel
%         %create VOI
%         M=zeros(V.dim);
%         P=zeros(V.dim);
%         R=zeros(V.dim);
%         O = ones(1,length(XYZmm));
%         
%         
%         for n=1:size(center_vox,2)
%             M(center_vox(1,n),center_vox(2,n),center_vox(3,n))=1;
%             P(center_vox(1,n),center_vox(2,n),center_vox(3,n))=pval(n);
%             R(center_vox(1,n),center_vox(2,n),center_vox(3,n))=rval(n);
%         end
%         
%         
%         [L,NUM]=bwlabeln(M);
%         statsP = regionprops(L,P, 'area', 'centroid','PixelList','PixelValues');
%         statsR = regionprops(L,R, 'area', 'centroid','PixelList','PixelValues');
%         fprintf('%s\n','whole brain')
%         for ki=1:length(statsR)
%             [a mi]=max(statsR(ki).PixelValues);
%             shortindex=statsR(ki).PixelList(mi,1)==center_vox(2,:)&statsR(ki).PixelList(mi,2)==center_vox(1,:)&statsR(ki).PixelList(mi,3)==center_vox(3,:);
%             fprintf('%d %d %d (%d voxels): r=%2.2f pseudoT=%2.2f p=%2.4f\n',center_mm(1,shortindex),center_mm(2,shortindex),center_mm(3,shortindex),statsR(ki).Area,statsR(ki).PixelValues(mi),tinv(1-statsP(ki).PixelValues(mi),23),statsP(ki).PixelValues(mi))
%         end
    end
    
end

