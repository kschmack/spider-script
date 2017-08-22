sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36];
sublist(ismember(sublist,exclude))=[];
a=[];b=[];
for sub=sublist
    %     fprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/
    %     realign/s05waccmincha_invflo_vs_invspi_off_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub
    %for k=19:22
        fprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/unistat/exp/con_00%02.0f.img\n',sub,3)
        %a=[a;k-18];
    %end
    %b=[b;repmat(find(sub==sublist),4,1)];
end
