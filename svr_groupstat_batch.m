clear;

old_job=('/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlite_support_vector_regression/invflo_vs_invspi_x_SAF_searchlite_scale_labelscale_linear/rawlabel/prototype.mat');

visstrlist={'visflo_vs_visspi','invflo_vs_invspi'};

aftersmooth=4;
if aftersmooth==0
string1='searchlite_support_vector_regression_nosmooth';
string2='rawpredlabel';
elseif aftersmooth==1
    string1='searchlite_support_vector_regression_smooth01';
    string2='s01rawpredlabel';
elseif aftersmooth==3
    string1='searchlite_support_vector_regression';
    string2='s03rawpredlabel';
    elseif aftersmooth==4
    string1='searchlite_support_vector_regression_08smooth03warp';
    string2='rawpredlabel';

end
datastring='spmTwarp03';



for v=1:length(visstrlist)
    visstr=visstrlist{v};
    covstrlist={'SPINDEX'};
    for c=1:length(covstrlist)
        covstr=covstrlist{c};
        
        load(old_job);
        labelstr='rawlabel';
        
        matlabbatch{1}.spm.stats.factorial_design.dir=strrep(matlabbatch{1}.spm.stats.factorial_design.dir,'invflo_vs_invspi',visstr);
        matlabbatch{1}.spm.stats.factorial_design.dir=strrep(matlabbatch{1}.spm.stats.factorial_design.dir,'SAF',covstr);
        
        load(fullfile(fileparts(matlabbatch{1}.spm.stats.factorial_design.dir{1}),'label.mat'))
        
        matlabbatch{1}.spm.stats.factorial_design.dir=strrep(matlabbatch{1}.spm.stats.factorial_design.dir,'searchlite_support_vector_regression',string1);
        matlabbatch{1}.spm.stats.factorial_design.dir=strrep(matlabbatch{1}.spm.stats.factorial_design.dir,'_searchlite_scale_',['_' datastring '_scale_']);
        
        if ~exist(matlabbatch{1}.spm.stats.factorial_design.dir{1},'dir')
            mkdir(matlabbatch{1}.spm.stats.factorial_design.dir{1})
            fprintf('Creating %s...\n',matlabbatch{1}.spm.stats.factorial_design.dir{1})
        end
        
        
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{1}.spm.stats.factorial_design.des.t1.scans,'invflo_vs_invspi',visstr);
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{1}.spm.stats.factorial_design.des.t1.scans,'rawpredlabel',string2);
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{1}.spm.stats.factorial_design.des.t1.scans,'SAF',covstr);
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans=strrep(matlabbatch{1}.spm.stats.factorial_design.des.t1.scans,'_searchlite_scale_',['_' datastring '_scale_']);
        
        
        matlabbatch{1}.spm.stats.factorial_design.cov.c=rawtestlabel;
        matlabbatch{1}.spm.stats.factorial_design.cov.cname=[covstr '_' labelstr];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name=strrep(matlabbatch{3}.spm.stats.con.consess{1}.tcon.name,'SAF',covstr);
        
        if ~isempty(strfind(datastring,'warp03'))
           matlabbatch{1}.spm.stats.factorial_design.masking.em=strrep(matlabbatch{1}.spm.stats.factorial_design.masking.em,'loc','loc_resample');
        end
        new_job=strrep(old_job,'invflo_vs_invspi',visstr);
        %new_job=strrep(new_job,'rawpredlabel',labelstr);
        new_job=strrep(new_job,'SAF',covstr);
        new_job=strrep(new_job,'prototype','job');
        new_job=strrep(new_job,'searchlite_support_vector_regression',string1);
        new_job=strrep(new_job,'_searchlite_scale_',['_' datastring '_scale_']);
        save(new_job,'matlabbatch');
        spm_jobman('run',new_job);
    end
end
