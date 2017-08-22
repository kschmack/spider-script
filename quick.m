% %load('..\groupstat\27sub\loc\job.mat')
%
% %% PREPROCESSING
% % for k=1:3:18
% %     matlabbatch{k}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{k}.spm.stats.factorial_design.des.t1.scans,'vector','off');
% % end
% % save('..\groupstat\27sub\searchlight_realign_off_rad08_smo05\masterjob.mat','matlabbatch')
%
% % % REALIGNMENT
% % for k=1:3:18
% %     matlabbatch{k}.spm.stats.factorial_design.dir=strrep(matlabbatch{k}.spm.stats.factorial_design.dir,'realign','norealign');
% %     matlabbatch{k}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{k}.spm.stats.factorial_design.des.t1.scans,'realign','norealign');
% % end
load ../groupstat/25sub_no33no36/searchlight_realign_vector_rad08_smo03/masterjob_invisible.mat

%% SUBJECT NUMBER
for k=1:3:9
    matlabbatch{k}.spm.stats.factorial_design.dir=strrep(matlabbatch{k}.spm.stats.factorial_design.dir,'invis','vis');
      %  matlabbatch{k}.spm.stats.factorial_design.dir=strrep(matlabbatch{k}.spm.stats.factorial_design.dir,'_smo03','_nosmooth');
    if ~exist(matlabbatch{k}.spm.stats.factorial_design.dir{1},'dir')
        mkdir(matlabbatch{k}.spm.stats.factorial_design.dir{1});
    end

    matlabbatch{k}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{k}.spm.stats.factorial_design.des.t1.scans,'s03waccmincha_invflo_vs_invspi_vector_radius08mm_','s03waccmincha_visflo_vs_visspi_vector_radius08mm_');
    
end
save('../groupstat/25sub_no33no36/searchlight_realign_vector_rad08_smo03/masterjob_visible.mat','matlabbatch')
%
% % output images
% strct=spm_vol(mask_path);
% im=nan(strct.dim);
%
% varlist={'rawpredlabel','scaledpredlabel'};
% for s=1:length(sublist)
%
%     for v=1:length(varlist)
%         varstr=varlist{v};
%
%         eval(['predim=' varstr '(s,:);'])
%         for k=1:length(predim)%reshaping f?r Doofe
%             im(XYZ(1,k),XYZ(2,k),XYZ(3,k))=predim(k);
%         end
%         oim   = struct('fname', fullfile(resfilepath,sprintf('%s_spi_mri_0_0%02.0f.nii',varstr,sublist(s))),...
%             'dim',   {strct.dim},...
%             'dt',    {[16 0]},...
%             'pinfo', {strct.pinfo},...
%             'mat',   {strct.mat},...
%             'descrip', {[varstr ' map']});
%         oim=spm_create_vol(oim);
%         oim=spm_write_vol(oim,im);
%         fprintf('Written %s!\n',oim.fname);
%         clear('predim');
%         im=nan(strct.dim);
%     end
% end#
