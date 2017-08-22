sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36,33];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher, 36 movement, 33 spider index outlier
sublist(ismember(sublist,exclude))=[];


%for sub=4:7
%     batchjob_allpreprocess(sub)
%     batchjob_loc_nonorm_nosmooth(sub)
%     batchjob_loc_nonorm(sub)
%     batchjob_exp_nonorm_nosmooth(sub)
%     batchjob_exp(sub)
%     batchjob_mask(sub)
%end

% for sub=8;%17:19%[8:10,12:19]
%     batchjob_allpreprocess(sub)
% end
% fid=fopen('logfile.txt','w');
% for sub=[4:10,12:19]%15 not run!
%     try
%         batchjob_exp_nonorm_nosmooth(sub)
%         batchjob_exp(sub)
%     catch
%         fprintf(fid,'Subject %d: error in single stats\n',sub);
%     end
% end

% LOCALIZER FOR ALL AUSSER 8
% for subject=[9:10,12:19]
%     %try
%         batchjob_loc_nonorm_nosmooth(subject)
%         batchjob_loc_nonorm(subject)
%     %catch
%         %fprintf(fid,'Subject %d: error in loc stats\n',sub);
%     %end
% end

% LOCALIZER FOR 8
% try
% spm_jobman('run','..\data\spi_mri_0_008\jobs\loc_nonorm_nosmooth_spi_mri_0_008.mat');
% spm_jobman('run','..\data\spi_mri_0_008\jobs\loc_nonorm_spi_mri_0_008.mat');
% catch
%     fprintf(fid,'Subject 8: error in loc stats\n');
% end
% MASK
% for subject=[4:10,12:19]
%     try
%     batchjob_mask(subject)
%     catch
%         fprintf(fid,'Subject %d: error in mask\n',sub);
%     end
% end
%fclose(fid)
%batchjob_exp_nonorm(8)

for sub=sublist
batchjob_exp(sub)
end
% batchjob_loc(sub)
% batchjob_exp_nonorm(sub)
% end
% for sub=[30:32]
%     batchjob_allpreprocess(sub)
% end
% for sub=[30:32]
%     batchjob_loc_nonorm_nosmooth(sub)
%     batchjob_loc_nonorm(sub)
%     batchjob_loc(sub)
%     batchjob_exp_nonorm_nosmooth(sub)
%     batchjob_exp_nonorm(sub)
%     batchjob_exp(sub)
%     batchjob_exp_nonorm_nosmooth_norealign(sub);
% end
% for sub=[30:32]
%    batchjob_mask(sub)
% end
% for sub=19%
%     batchjob_converge_mask(sub)
% batchjob_nobrain(sub)
% end
% sublist=[4:10,12:23,25:26,30:39];
% exclude=[8,15,23,32];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher
% sublist(ismember(sublist,exclude))=[];
% for sub=[33:39]
%     batchjob_allpreprocess(sub)
% end
% for sub=[33:39]
%     batchjob_loc_nonorm_nosmooth(sub)
%     batchjob_loc_nonorm(sub)
%     batchjob_loc(sub)
%     batchjob_exp_nonorm_nosmooth(sub)
%     batchjob_exp_nonorm(sub)
%     batchjob_exp(sub)
%     batchjob_exp_nonorm_nosmooth_norealign(sub);
% end
% for sub=[33:39]
%batchjob_mask(sub)
% end

%decoder_searchlight.m
% 
% for sub=[33:39]
% batchjob_normalizesmooth_searchlight_off(sub)
% end

% sublist=[4:10,12:23,25:26,30:39];
% exclude=[8,15,23,32];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher
% sublist(ismember(sublist,exclude))=[];
% for sub=sublist
%    batchjob_addcon_exp(sub) 
% end
% sublist=[4:10,12:23,25:26,30:39];
% % exclude=[8,15,23,32,36]
% % sublist(ismember(sublist,exclude))=[];
% for sub=sublist
% % %    batchjob_addcon_exp_nonorm(sub) 
% % %    batchjob_addcon_exp_nonorm_nosmooth(sub) 
% % %    batchjob_addcon_exp_nonorm_nosmooth_norealign(sub) 
% % %    batchjob_addcon2_exp(sub) 
% % %    batchjob_addcon_anova_exp(sub) 
% batchjob_addcon4_exp(sub)
% end
% 
%decoder_searchlight_powercrossclassifier
%decoder_searchlight_crossclassifier
% sublist=[4:10,12:23,25:26,30:39];
% exclude=[8,15,23,32];
% sublist(ismember(sublist,exclude))=[];
% for sub=sublist
%     batchjob_normalizesmooth_searchlight(sub,'invflo_vs_invspi_powercrossset_off_radius08mm_')
%     batchjob_normalizesmooth_searchlight(sub,'invflo_vs_invspi_crossset_off_radius08mm_')
% 
% end
% 

% sublist=[4:10,12:23,25:26,30:39];
% exclude=[8,15,23,32,33,36]; %33 spindex outlier, 36 movement
% sublist(ismember(sublist,exclude))=[];
% for sub=sublist
%     batchjob_normalize_searchlight(sub,'visflo_vs_visspi_vector_radius08mm_')
    %batchjob_normalize_searchlight(sub,'visflo_vs_visspi_off_radius08mm_')
    %batchjob_normalizesmooth_searchlight(sub,'invflo_vs_invspi_crossset_off_radius08mm_')
% end

% sublist=[4:10,12:23,25:26,30:39];
% exclude=[8,15,23,32];
% sublist(ismember(sublist,exclude))=[];
% for sub=sublist
%     batchjob_normalizesmooth(sub);
% end
% for sub=sublist
%     batchjob_loc_resample(sub);
% end
% for sub=sublist
%     batchjob_exp_resample(sub)
% end

% sublist=[19:23,25:26,30:39];
% exclude=[8,15,23,32,18];
% sublist(ismember(sublist,exclude))=[];
% for sub=sublist
%     batchjob_plar_nonorm_nosmooth(sub);
% end
% %%% 18 nicht gelaufen

% 
% sublist=[4:10,12:23,25:26,30:39];
% exclude=[8,15,23,32,33,36];
% sublist(ismember(sublist,exclude))=[];
% for sub=sublist
%     batchjob_normalizesmooth_searchlight(sub,'invspi_vector_radius08mm_')
%     batchjob_normalizesmooth_searchlight(sub,'invflo_vector_radius08mm_')
%     batchjob_normalizesmooth_searchlight(sub,'visflo_vector_radius08mm_')
% end

% decoder_searchlight;
% decoder_searchlight2;