sublist=[4:10,12:23,25:26,30:39];%39];
exclude=[8,15,23,32];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher
%sublist=[33:39];
sublist(ismember(sublist,exclude))=[];

for k=1:length(sublist)
    str=['E:\spider\data\' sprintf('spi_mri_0_0%02.0f',sublist(k)) '\searchlite\norealign\s05waccmincha_invflo_vs_invspi_vector_radius08mm_' sprintf('spi_mri_0_0%02.0f',sublist(k)) '.nii'];
    fprintf('%s\n',str)
    %fprintf('%s\n',fullfile('E:\','spider','data',sprintf('spi_mri_0_0%02.0f',sublist(k)),'unistat','loc','con_0001.img'))
end