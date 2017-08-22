sublist=[4:10,12:23,25:26,30:32];
exclude=[8,15,23,32];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher
sublist(ismember(sublist,exclude))=[];
name='E:\spider\data\spi_mri_0_004\searchlite\norealign\accmincha_visflo_vs_visspi_vector_radius08mm_spi_mri_0_0XX.nii';
for sub=1:length(sublist)
    fprintf('%s\n',strrep(name,'XX',sprintf('%02.0f',sublist(sub))))
    %V(sub)=spm_vol(sprintf('%s\n',strrep(name,'XX',sprintf('%02.0f',sublist(sub)))))
end
