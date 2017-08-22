clear;%close all;
set(0,'ShowHiddenHandles','on');
delete(get(0,'Children'));
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36,33];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher, 36 movement, 33 spider index outlier
sublist(ismember(sublist,exclude))=[];
overwrite=1;
conlist={{'visible spider'}};%{'invisible flower','invisible spider'}
preplist={'vector'};%,,'vector','norm','scale'
spm_path_list={fullfile('..','data','spi_mri_0_0XX','unistat','plar_nonorm_nosmooth')};
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
            str1=regexp(conditions,' ','split');
            str1=str1{1};
            str=sprintf('%s%s',str1{1}(1:3),str1{2}(1:3));
            
            %start decoding if resfigure does not exist
            %if ~exist(figname,'file')||overwrite==1
            for sub=1:length(sublist)
                
                % check whether results exist
                resstr=sprintf('%s_%s_radius%02.0fmm_spi_mri_0_0%02.0f.mat',str,prep,radius,sublist(sub));
                respath=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',sublist(sub)),'searchlite','exemplar');
                if ~exist(respath,'dir')
                    mkdir(respath)
                end
                resfile=fullfile(respath,resstr);
                resfile2=fullfile(respath,['accmincha_' resstr]);
                spm_path_sub=strrep(spm_path,'XX',sprintf('%02.0f',sublist(sub)));
                mask_path_sub=fullfile(spm_path_sub,'mask.img');
                
                if ~exist(resfile,'file');
                    clear('beta_list','beta','label','runlabel','data','XYZ','XYZmm','accim');
                    
                    % load SPM
                    load(fullfile(spm_path_sub,'SPM.mat'))
                    
                    % find betas of corresponding conditions and make image list
                    for n=1:length(SPM.Vbeta)
                        beta(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[') ' conditions{1}]));
                    end
                    beta_index=find(beta);
                    
                    for n=1:length(beta_index)
                        beta_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta_index(n)));
                        labstr=regexp(SPM.Vbeta(beta_index(n)).descrip,' \d\d','match');
                        label(n,1)=str2double(labstr{1}(2:3));
                    end
                    
                    % find corresponding runs
                    runlabel=zeros(1,length(beta_index));
                    for ses=1:length(SPM.Sess)
                        runlabel=runlabel+ismember(beta_index,SPM.Sess(ses).col)*ses;
                    end
                    runlabel=runlabel';
                    
                    % extract values from mask
                    [data,XYZ,XYZmm] = extract_image_values(beta_list,mask_path_sub);                    
                    
                    % searchlight
                    O = ones(1,length(XYZ));
                    cr=nan(length(unique(runlabel)'),length(XYZ));fr=cr;cl=cr;fl=cr;
                    r = radius.*radius;
                    %try matlabpool; end %use PARALLEL COMPUTING BOX IF INSTALLED
                    accim=nan(1,length(XYZ));
                   
                    for k=1:length(XYZmm) % start voxel loop
                        
                        % define spherical volume
                        s = (sum((XYZmm-XYZmm(:,k)*O).^2) <= r);
                        data_s=data(:,s);
                        
                        % normalize data volumewise
                        [data_s]=preprocess_data(data_s,prep);
                        
                        for run=unique(runlabel)'
                            test_s=data_s(runlabel==run,:);
                            testlabel=label(runlabel==run);
                            train_s=data_s(runlabel~=run,:);
                            trainlabel=label(runlabel~=run);
                            
                            % normalize betas runwise
                            
                            % balance data
                            w=1./hist(trainlabel, numel(unique(trainlabel)));
                            w=w./sum(w); %normalize sum to 1
                            weightstr=sprintf(' -w+%d %2.20f',[unique(trainlabel)';w]);

                            
                            % crossvalkdate for this volume
                            % start run-wise crossvalidation
                            model =  svmtrain(trainlabel, train_s, ['-t 0 -c 16 -q' weightstr]); %-t kernel type (0 linear 1 polynomial 2 gamma)
                            [predlabel, acc] = svmpredict(testlabel, test_s, model);
                            
                            % output
                            for n=1:16
                                cp(run,n)=sum((testlabel==n)&(testlabel==predlabel));
                                fp(run,n)=sum((testlabel==n)&(testlabel~=predlabel));
                                cn(run,n)=sum((testlabel~=n)&(testlabel==predlabel));
                                fn(run,n)=sum((testlabel~=n)&(testlabel~=predlabel));
                            end
                        end
                        accim(k)=sum(cp(:)+cn(:))./sum(cp(:)+fp(:)+cn(:)+fn(:))*100;
                    end

                    save(resfile,'XYZ','XYZmm','accim');
                    %try matlabpool close; end
                else load(resfile)
                end
                % output images
                %accim=sum(cr+cl)./sum(cr+cl+fr+fl).*100;
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
                accimminuschance=accim-1/16*100;
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