%clear;


cenlist={[42 -54   1],[-42 -54   1],[22 -60 -15],[-16 -62 -10],[16 -96 -2],[-16 -94 7]};
namelist={'midtemp_R_peakvisiblespider_10mm.nii','midtemp_L_peakvisiblespider_10mm.nii','fus_R_peakvisiblespider_10mm.nii','fus_L_peakvisiblespider_10mm.nii',...
    'early_R_peakvisiblespider_10mm.nii','early_L_peakvisiblespider_10mm.nii'};
for l=1:length(cenlist)
    center=cenlist{l}';
    name=fullfile('..','mask','exemplar',namelist{l});
    radius=10;
%     liste=dir(fullfile('..','mask','*midtemp_*10mm.nii'));
% for l=1:length(liste);
%     V=spm_vol(fullfile('..','mask',liste(l).name))
%     c=regexp(V.descrip,'\d.\d');
%     center=[str2double(V.descrip(c(1)-2:c(1)+3)) str2double(V.descrip(c(2)-2:c(2)+3))  str2double(V.descrip(c(3)-2:c(3)+3))]'
%     radius=10; %radius in mm
%     name=V.fname;
    
    % center=[-36 -80 -10]'; %center in mm -36 -38 -19 pFus_R_ 38 -44 -19  LO_R 48 -76  -6 LO_L -44 -82  -6 midTemp  50 -38 -10 LOC_R
    % radius=10; %radius in mm
    % name=fullfile('..','mask','LO_L_acc_peakvisdec_10mm.nii');
    
    
    % load template
    V=spm_vol('/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/loc/mask.img');
    [trash XYZmm]=spm_read_vols(V);
    
%     % adjust rounded coordinates
%     f=find(round(XYZmm(3,:))==center(3));
%     center(3)=XYZmm(3,f(1));
    
    %create VOI
    M=zeros(V.dim);
    O = ones(1,length(XYZmm));
    s = (sqrt(sum((XYZmm-center*O).^2)) <= radius);
    M(s)=1;
    
    %write image
    oim   = struct('fname', name,...
        'dim',   {V.dim},...
        'dt',    {[16 0]},...
        'pinfo', {V.pinfo},...
        'mat',   {V.mat},...
        'descrip', {sprintf('spherical voi at %2.1f %2.1f %2.1f radius %d mm',center(1),center(2),center(3),radius)});
    oim=spm_create_vol(oim);
    oim=spm_write_vol(oim,M);
end
