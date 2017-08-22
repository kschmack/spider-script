clear;
% %MAKE Pseudo-T-IMAGE TO DISPLAY
nonpara='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/label.mat';
load(nonpara);
%pcrp=spcrp;
spmpath=('/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlite_support_vector_regression_08smooth03warp/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/pseudot');

% load original T-image
V=spm_vol(fullfile(spmpath,'spmT_0001.img'));
[trash XYZmmtrash]=spm_read_vols(V);

% replace T-values with non-parametric p-values
M=zeros(V.dim);
O = ones(1,length(XYZmm));

pwhole=pcrp/length(pcrp);
pseudot=icdf('t',1-pcrp,23);%convertRtoT(cr,23);
pseudot(pseudot<0)=0; %cuto of negative values
pseudot(isinf(pseudot))=icdf('t',1-1/578000,23); %set Inf to maximal %pseudoTvalue as defined by number of permutations


for l=1:size(XYZ,2)
    x=XYZ(1,l);
    y=XYZ(2,l);
    z=XYZ(3,l);
    M(x,y,z)=pseudot(l);
end

%write pseudo-T image
oim=spm_create_vol(V);
oim=spm_write_vol(V,M);


%print values at coordinates
load('../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03_scale_labelscale_linear/label.mat');
corlist={[-18  35 -17],[-45 -70  -5],[42 -52 -11],[18 -70  -8]};
namelist={'left OFC','left LOC','right LOC','visual'};
voxnum=[length(pcrp) voxelcount('../mask/3x3x3/LOCp001_bilateral_localizer_3x3x3.nii') voxelcount('../mask/3x3x3/LOCp001_bilateral_localizer_3x3x3.nii') length(pcrp)];
%voxnum=[length(pcrp)  length(pcrp)  length(pcrp) length(pcrp)];
for k=1:length(corlist)
    x=corlist{k}(1);
    y=corlist{k}(2);
    z=corlist{k}(3);
    target=find(XYZmm(1,:)==x&XYZmm(2,:)==y&XYZmm(3,:)==z);
    fprintf('%s %d %d %d, pseudoT=%2.2f, r=%2.2f,p=%2.4f\n',namelist{k},corlist{k},pseudot(target),cr(target),pcrp(target)*voxnum(k))
end

%print surviving values with coordinates
%WHOLE BRAIN
% fprintf('\nWHOLE BRAIN')
% index=find(pcrp<0.05/length(pcrp));
% for k=1:length(index)
%    p=pcrp(index(k))*length(pcrp);
%    pseudoT=pseudot(index(k));
%    cor=[XYZmm(:,index(k))];
%    fprintf('%d %d %d pseudoT=%2.2f p=%2.5f\n',cor,pseudoT,p)
% end