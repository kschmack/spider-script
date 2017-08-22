clear
load /Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_exemplar_vector_rad08_smo03/tmp.mat
old=matlabbatch;

% s1=(matlabbatch{1}.spm.stats.factorial_design.des.t1.scans);
% s2=(matlabbatch{10}.spm.stats.factorial_design.des.t1.scans);
% matlabbatch{end}.spm.stats.factorial_design.des.pt.pair(2)=[];
% for k=1:length(s1)
%     matlabbatch{end}.spm.stats.factorial_design.des.pt.pair(k)=matlabbatch{end}.spm.stats.factorial_design.des.pt.pair(1);
%     matlabbatch{end}.spm.stats.factorial_design.des.pt.pair(k).scans{1}=s2{k};
%     matlabbatch{end}.spm.stats.factorial_design.des.pt.pair(k).scans{2}=s1{k};
% end


%% SUBJECT NUMBER
load /Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_exemplar_vector_rad08_smo03/exemplar.mat;



matlabbatch{end}.spm.stats.factorial_design.dir=[];
matlabbatch{end}.spm.stats.factorial_design.dir=strrep(matlabbatch{1}.spm.stats.factorial_design.dir,'visflo','visflo_vs_visspi');

m=matlabbatch(end);
clear('matlabbatch');
matlabbatch=m;
save('/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_exemplar_vector_rad08_smo03/tmp2.mat','matlabbatch')
for k=1:3:9
    matlabbatch{k}.spm.stats.factorial_design.dir=strrep(matlabbatch{k}.spm.stats.factorial_design.dir,'invspi','invspi');
    if ~exist(matlabbatch{k}.spm.stats.factorial_design.dir{1},'dir')
        mkdir(matlabbatch{k}.spm.stats.factorial_design.dir{1});
    end
    matlabbatch{k}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{k}.spm.stats.factorial_design.des.t1.scans,'_invspi_','_invspi_');
end
save('/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_exemplar_vector_rad08_smo03/invisiblespider_job.mat')
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
