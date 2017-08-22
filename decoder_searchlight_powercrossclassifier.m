clear;%close all;
set(0,'ShowHiddenHandles','on');
delete(get(0,'Children'));
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher
sublist(ismember(sublist,exclude))=[];
overwrite=1;
conlist={{'invisible flower','invisible spider'}};%{'invisible flower','invisible spider'}
preplist={'off'};%,,'vector','norm','scale'
spm_path_list={fullfile('..','data','spi_mri_0_0XX','unistat','exp_nonorm_nosmooth')};%fullfile('..','data','spi_mri_0_0XX','unistat','exp_nonorm_nosmooth_norealign'),...
radius=8;

loops=length(spm_path_list)*length(conlist)*length(preplist)*length(sublist);
l=0;
h=waitbar(0,'Searchlight working...');
for s=1:length(spm_path_list)
    spm_path=spm_path_list{s};
    realignstr=spm_path(strfind(spm_path,'norealign'):end);
    
    if isempty(realignstr); realignstr='realign';end
    for c=1:length(conlist)
        conditions=conlist{c};%{'visible spider','visible flower'};
        for p=1:length(preplist)
            prep=preplist{p};
            
            % make names and strings
            cond=sort(conditions);
            str1=regexp(cond{1},' ','split');if isempty(str1{2});str1{2}='all'; end
            str2=regexp(cond{2},' ','split');if isempty(str2{2});str2{2}='all'; end
            
            %start decoding if resfigure does not exist
            %if ~exist(figname,'file')||overwrite==1
            for sub=1:length(sublist)
                
                % check whether results exist
                resstr=sprintf('%s%s_vs_%s%s_powercrossset_%s_radius%02.0fmm_spi_mri_0_0%02.0f.mat',str1{1}(1:3),str1{2}(1:3),str2{1}(1:3),str2{2}(1:3),prep,radius,sublist(sub));
                respath=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',sublist(sub)),'searchlite',realignstr);
                if ~exist(respath,'dir')
                    mkdir(respath)
                end
                resfile=fullfile(respath,resstr);
                resfile2=fullfile(respath,['accmincha_' resstr]);
                spm_path_sub=strrep(spm_path,'XX',sprintf('%02.0f',sublist(sub)));
                mask_path_sub=fullfile(spm_path_sub,'mask.img');
                
%                 if ~exist(resfile,'file');
                    clear('beta1_list','beta2_list','beta3_list','beta4_list');
                    
                    % load SPM
                    load(fullfile(spm_path_sub,'SPM.mat'))
                    
                    % find betas of corresponding conditions and make image list
                    % set 1
                   
                    for n=1:length(SPM.Vbeta)
                        beta1(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[' ' conditions{1} ' set 1']));
                        beta2(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[' ' conditions{2} ' set 1']));
                        beta3(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[' ' conditions{1} ' set 2']));
                        beta4(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[' ' conditions{2} ' set 2']));
                    end
                    beta1_index=find(beta1);
                    for n=1:length(beta1_index)
                        beta1_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta1_index(n)));
                    end

                    beta2_index=find(beta2);
                    for n=1:length(beta2_index)
                        beta2_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta2_index(n)));
                    end
                    
                    beta3_index=find(beta3);
                    for n=1:length(beta3_index)
                        beta3_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta3_index(n)));
                    end
                    
                    beta4_index=find(beta4);
                    for n=1:length(beta4_index)
                        beta4_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta4_index(n)));
                    end

                    
                    % find corresponding runs
                    runindex1=zeros(1,length(beta1_index));
                    for ses=1:length(SPM.Sess)
                        runindex1=runindex1+ismember(beta1_index,SPM.Sess(ses).col)*ses;
                    end
                    runindex2=zeros(1,length(beta2_index));
                    for ses=1:length(SPM.Sess)
                        runindex2=runindex2+ismember(beta2_index,SPM.Sess(ses).col)*ses;
                    end
                    runindex3=zeros(1,length(beta3_index));
                    for ses=1:length(SPM.Sess)
                        runindex3=runindex3+ismember(beta3_index,SPM.Sess(ses).col)*ses;
                    end
                    runindex4=zeros(1,length(beta4_index));
                    for ses=1:length(SPM.Sess)
                        runindex4=runindex4+ismember(beta4_index,SPM.Sess(ses).col)*ses;
                    end
                    
                    
                    % extract values from mask
                    [imval1,XYZ,XYZmm] = extract_image_values(beta1_list,mask_path_sub);
                    [imval2,XYZ,XYZmm] = extract_image_values(beta2_list,mask_path_sub);
                    [imval3,XYZ,XYZmm] = extract_image_values(beta3_list,mask_path_sub);
                    [imval4,XYZ,XYZmm] = extract_image_values(beta4_list,mask_path_sub);
        
                    % concatenate data
                    data=[imval1;imval2;imval3;imval4];
                    label=[ones(size(imval1,1),1);ones(size(imval2,1),1)*2;ones(size(imval3,1),1)*3;ones(size(imval4,1),1)*4];
                    runlabel=[runindex1';runindex2';runindex3';runindex4'];
                    
                    
                    % searchlight
                    O = ones(1,length(XYZ));
                    cr=nan(length(unique(runlabel)'),length(XYZ));fr=cr;cl=cr;fl=cr;
                    r = radius.*radius;
                    %try matlabpool; end %use PARALLEL COMPUTING BOX IF INSTALLED
                    for k=1:length(XYZmm) % start voxel loop
                        
                        % define spherical volume
                        s = (sum((XYZmm-XYZmm(:,k)*O).^2) <= r);
                        data_s=data(:,s);
                        
                        % normalize data volumewise
                        [data_s]=preprocess_data(data_s,prep);
                        
                        for sets=1:2% start set loop
                            %for run=unique(runlabel)' %start run loop
                                
                                testindex=ismember(label,[(sets-1)*2+1 (sets-1)*2+2]);
                                trainindex=~ismember(label,[(sets-1)*2+1 (sets-1)*2+2]);
                                
                                test_s=data_s(testindex,:);
                                testlabel=label(testindex);

                                
                                train_s=data_s(trainindex,:);
                                trainlabel=label(trainindex);
                                
                                if ismember(3,testlabel)
                                    testlabel=testlabel-2;
                                end
                                if ismember(3,trainlabel);
                                    trainlabel=trainlabel-2;
                                end
                                
                                % normalize betas runwise
                                
                                % crossvalkdate for this volume
                                % start run-wise crossvalidation
                                model =  svmtrain(trainlabel, train_s, '-t 0 -q'); %-t kernel type (0 linear 1 polynomial 2 gamma)
                                [predlabel, acc] = svmpredict(testlabel, test_s, model);
                                
                                % output                               
                                cr(sets,k)=sum((testlabel==1)&(testlabel==predlabel));
                                fr(sets,k)=sum((testlabel==1)&(testlabel~=predlabel));
                                cl(sets,k)=sum((testlabel==2)&(testlabel==predlabel));
                                fl(sets,k)=sum((testlabel==2)&(testlabel~=predlabel));
                            %end
                        end
                    end
                    save(resfile,'XYZ','XYZmm','cr','fr','cl','fl');
                    %try matlabpool close; end
%                 else load(resfile)
%                 end
                % output images
                accim=sum(cr+cl)./sum(cr+cl+fr+fl).*100;
                strct=spm_vol(mask_path_sub);
                im=nan(strct.dim);
                for k=1:length(accim)%reshaping f?r Doofe
                    im(XYZ(1,k),XYZ(2,k),XYZ(3,k))=accim(k);
                end
                oim   = struct('fname', strrep(resfile,'.mat','.nii'),...
                    'dim',   {strct.dim},...
                    'dt',    {[16 0]},...
                    'pinfo', {strct.pinfo},...
                    'mat',   {strct.mat},...
                    'descrip', {['accuracy map']});
                oim=spm_create_vol(oim);
                oim=spm_write_vol(oim,im);
                fprintf('Written %s!\n',oim.fname)
                clear('im','oim');

                % output images
                accimminuschance=(sum(cr+cl)./sum(cr+cl+fr+fl).*100)-50;
                strct=spm_vol(mask_path_sub);
                im=nan(strct.dim);
                for k=1:length(accim)%reshaping f?r Doofe
                    im(XYZ(1,k),XYZ(2,k),XYZ(3,k))=accimminuschance(k);
                end

                oim   = struct('fname', strrep(resfile2,'.mat','.nii'),...
                    'dim',   {strct.dim},...
                    'dt',    {[16 0]},...
                    'pinfo', {strct.pinfo},...
                    'mat',   {strct.mat},...
                    'descrip', {['accuracy map']});
                oim=spm_create_vol(oim);
                oim=spm_write_vol(oim,im);
                fprintf('Written %s!\n',oim.fname)
                clear('im','oim');

                l=l+1;
                waitbar(l/loops,h);
            end %subloop
        end %prep list
    end %conditions loop
end %spm path list (realign and no realign)
delete(h);
%