clear;close all;
sublist=14%[4:7,9,12:14,16:21];
voxellist=[250];
overwrite=1;
conlist={{'invisible flower','invisible spider'}};
preplist={'off'};
spm_path=fullfile('..','data','spi_mri_0_0XX','unistat','exp_nonorm_nosmooth');
%mask_path=fullfile('..','data','spi_mri_0_0XX','mask','spi_mri_0_0XX_anatomic_locp001.nii');
mask_path=fullfile('..','data','spi_mri_0_0XX','mask','mwspi_mri_0_0XX_fusiformlatmidocctemp_gyrus_wfupick.nii');
%mask_path=fullfile('..','data','spi_mri_0_0XX','unistat','exp_nonorm_nosmooth','mask.img');
feature_path=fullfile('..','data','spi_mri_0_0XX','unistat','loc_nonorm_nosmooth','spmT_0001.img');
%feature_path='ttest';


for c=1:length(conlist)
    conditions=conlist{c};%{'visible spider','visible flower'};
    for p=1:length(preplist)
        prep=preplist{p};
        
        % make names and strings
        [a mskstr]=fileparts(mask_path);
        mskstr=strrep(mskstr,'mwspi_mri_0_0XX_','');
        mskstr=strrep(mskstr,'spi_mri_0_0XX_','');
        [c ftrstr]=fileparts(feature_path);
        titstr=sprintf('%s - %s (%s %s %s)',conditions{1},conditions{2},mskstr,prep,ftrstr);
        cond=sort(conditions);
        str1=regexp(cond{1},' ','split');
        str2=regexp(cond{2},' ','split');
        figstr=sprintf('%s%s_vs_%s%s_%dsub_%s_%s_%s.jpg',str1{1}(1:3),str1{2}(1:3),str2{1}(1:3),str2{2}(1:3),length(sublist),mskstr,prep,ftrstr);
        figname=fullfile('..','results',figstr);
        
        %start decoding if resfigure does not exist
        if ~exist(figname,'file')||overwrite==1
            for sub=1:length(sublist)
                clear('beta1_list','beta2_list');
                
                % load SPM
                spm_path_sub=strrep(spm_path,'XX',sprintf('%02.0f',sublist(sub)));
                load(fullfile(spm_path_sub,'SPM.mat'))
                
                % find betas of corresponding conditions and make image list
                for n=1:length(SPM.Vbeta)
                    beta1(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[' ' conditions{1}]));
                    beta2(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[' ' conditions{2}]));
                end
                beta1_index=find(beta1);
                for n=1:length(beta1_index)
                    beta1_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta1_index(n)));
                end
                beta2_index=find(beta2);
                for n=1:length(beta2_index)
                    beta2_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta2_index(n)));
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
                
                % extract values from mask
                mask_path_sub=strrep(mask_path,'XX',sprintf('%02.0f',sublist(sub)));
                [imval1,XYZ,XYZmm] = extract_image_values(beta1_list,mask_path_sub);
                [imval2,XYZ,XYZmm] = extract_image_values(beta2_list,mask_path_sub);
                
                % concatenate data
                data=[imval1;imval2];
                label=[ones(size(imval1,1),1);ones(size(imval2,1),1)*2];
                runlabel=[runindex1';runindex2'];
                
                % exclude NaN-Voxels (due to smoothed masks)
                nanindex=sum(isnan(data))==size(data,1);
                data(:,nanindex)=[];
                XYZ(:,nanindex)=[];
                XYZmm(:,nanindex)=[];
                
                % normalize betas
                data=preprocess_data(data,prep);
                
                % start voxel loop
                for vox=1:length(voxellist);
                    predicted=[];tested=predicted;
                    
                    % start run-wise crossvalidation
                    for run=1:8;%unique(runlabel)'
                        testdata=data(runlabel==run,:);
                        testlabel=label(runlabel==run);
                        traindata=data(runlabel~=run,:);
                        trainlabel=label(runlabel~=run);
                        
                        %voxel selection
                        [findex]=feature_select(traindata,trainlabel,strrep(feature_path,'XX',sprintf('%02.0f',sublist(sub))),XYZ);
                        testdata=testdata(:,findex(1:voxellist(vox)));
                        traindata=traindata(:,findex(1:voxellist(vox)));
                        
                        % normalize run-wise
                        %             [traindata scalemax scalemin]=preprocess_data(traindata,'norm');
                        %             [testdata]=preprocess_data(testdata,'norm',scalemax,scalemin);
                        
                        %train classifier
                        model =  svmtrain(trainlabel, traindata, '-t 0');
                        [predlabel, acc] = svmpredict(testlabel, testdata, model);
                        predicted=[predicted;predlabel];
                        tested=[tested;testlabel];
                        
                    end
                    accuracy(sub,vox)=sum(predicted==tested)/length(predicted);
                end
            end
            plotacc=accuracy.*100+(repmat(linspace(0,.75,length(sublist))',1,size(accuracy,2)));
            
            scrsz = get(0,'ScreenSize');
            figure('Position',[20 20 scrsz(3)*.9 scrsz(4).*9]);
            ca=[[eye(3); 1 1 0; 0 1 1; 1 0 1;.5 .5 .5];[eye(3); 1 1 0; 0 1 1; 1 0 1;.5 .5 .5].*.5];
            set(gcf,'Color','w','DefaultAxesColorOrder',ca)
            plot(plotacc')
            legend(cellfun(@num2str,num2cell(sublist),'uni',0),'Location','BestOutside')
            hold on;
            m=mean(accuracy*100);
            plot(m,':k','LineWidth',2);
            for t=1:size(accuracy,2)
                [h(t) p(t)]=ttest(accuracy(:,t),ones(size(accuracy,1),1)*50);
            end
            sigindex=find(p<.05);
            plot(sigindex,m,' ro','MarkerEdgeColor','k','MarkerFaceColor','k')
            plot(sigindex,m,' *','MarkerEdgeColor','w','MarkerSize',5)
            set(gca,'XTick',1:length(voxellist),'XTickLabel',cellfun(@num2str,num2cell(voxellist),'uni',0))
            if length(voxellist)>10
                set(gca,'XTick',2:2:length(voxellist),'XTickLabel',cellfun(@num2str,num2cell(voxellist(2:2:length(voxellist))),'uni',0))
            end
            ylabel('Accuracy in %')
            xlabel('Voxel Number')
            title(titstr,'Interpreter','none')
            if overwrite==0
            set(gcf,'PaperPositionMode','auto');
            print(figname,'-djpeg','-r200');
            close;
            end
        end %if exist loop
    end %prep list
end %conditions loop