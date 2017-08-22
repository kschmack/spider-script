clear;close all;
set(0,'ShowHiddenHandles','on');
delete(get(0,'Children'));
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36,33];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher, 36 movement, 33 spider index outlier
sublist(ismember(sublist,exclude))=[];
sublist(ismember(sublist,exclude))=[];
voxellist=[50:50:400];
overwrite=1;
conlist={{'visible spider'}};
preplist={'vector'};%,,'vector','norm','scale'
spm_path_list={fullfile('..','data','spi_mri_0_0XX','unistat','plar_nonorm_nosmooth')};

%mask_path=fullfile('..','data','spi_mri_0_0XX','mask','loc_bilateral_sspi_mri_0_0XX.nii');
%mask_path=fullfile('..','data','spi_mri_0_0XX','mask','spi_mri_0_0XX_anatomic_locp001.nii');
%mask_path=fullfile('..','data','spi_mri_0_0XX','mask','mwspi_mri_0_0XX_fusiformlatmidocctemp_gyrus_wfupick.nii');
%mask_path=fullfile('..','data','spi_mri_0_0XX','mask','sculp_sspi_mri_0_0XX.nii');
mask_path=fullfile('..','data','spi_mri_0_0XX','unistat','plar_nonorm_nosmooth','mask.img');
%feature_path=fullfile('..','data','spi_mri_0_0XX','unistat','loc_nonorm_nosmooth','spmT_0001.img');
%feature_path='ftest';
feature_path=fullfile('..','data','spi_mri_0_0XX','unistat','plar_nonorm_nosmooth','spmT_0008.img');


loops=length(spm_path_list)*length(conlist)*length(preplist)*length(sublist)*length(voxellist);
l=0;
h=waitbar(0,'Decoder working...');
for s=1:length(spm_path_list)
    spm_path=spm_path_list{s};
    for c=1:length(conlist)
        conditions=conlist{c};%{'visible spider','visible flower'};
        for p=1:length(preplist)
            prep=preplist{p};
            
            % make names and strings
            [a mskstr]=fileparts(mask_path);
            mskstr=strrep(mskstr,'mwspi_mri_0_0XX_','');
            mskstr=strrep(mskstr,'spi_mri_0_0XX_','');
            [c ftrstr]=fileparts(feature_path);
            %titstr=sprintf('%s - %s (%s %s %s)',conditions{1},conditions{2},mskstr,prep,ftrstr);
            str1=regexp(conditions,' ','split');
            str1=str1{1};
            str=sprintf('%s%s',str1{1}(1:3),str1{2}(1:3));
            %figstr=sprintf('%s%s_vs_%s%s_%dsub_%s_%s_%s.jpg',str1{1}(1:3),str1{2}(1:3),str2{1}(1:3),str2{2}(1:3),length(sublist),mskstr,prep,ftrstr);
            %figname=fullfile('..','results',spm_path(strfind(spm_path,'norealign'):end),figstr);
            
            %start decoding if resfigure does not exist
            %if ~exist(figname,'file')||overwrite==1
            accuracy=nan(length(sublist),length(voxellist));
            for sub=1:length(sublist)
                for vox=1:length(voxellist);
                    
                    % check whether results exist
                    resstr=sprintf('exemplar_%s_subject%02.0f_%s_%s_%s_%dvox.mat',str,sublist(sub),prep,mskstr,ftrstr,voxellist(vox));
                    respath=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',sublist(sub)),'multistat','exemplar');
                    if ~exist(respath,'dir')
                        mkdir(respath)
                    end
                    resfile=fullfile(respath,resstr);
                    
                    if ~exist(resfile,'file');
                        clear('beta_list','beta','label','runlabel','data');
                        
                        % load SPM
                        spm_path_sub=strrep(spm_path,'XX',sprintf('%02.0f',sublist(sub)));
                        load(fullfile(spm_path_sub,'SPM.mat'))
                        
                        % find betas of corresponding conditions and make image list
                        for n=1:length(SPM.Vbeta)
                            beta(n)=~isempty(strfind(SPM.Vbeta(n).descrip,[') ' conditions{1}]));
                        end
                        beta_index=find(beta);
                        
                        for n=1:length(beta_index)
                            beta_list{n,1}=fullfile(spm_path_sub,sprintf('beta_%04.0f.img',beta_index(n)));
                            lab=regexp(SPM.Vbeta(beta_index(n)).descrip,' \d\d','match');
                            label(n,1)=str2double(lab{1}(2:3));
                        end
                        
                        % find corresponding runs
                        runlabel=zeros(1,length(beta_index));
                        for ses=1:length(SPM.Sess)
                            runlabel=runlabel+ismember(beta_index,SPM.Sess(ses).col)*ses;
                        end
                        runlabel=runlabel';
                        
                        % extract values from mask
                        mask_path_sub=strrep(mask_path,'XX',sprintf('%02.0f',sublist(sub)));
                        [data,XYZ,XYZmm] = extract_image_values(beta_list,mask_path_sub);
                        
                        % exclude NaN-Voxels (due to smoothed masks)
                        nanindex=sum(isnan(data))==size(data,1);
                        data(:,nanindex)=[];
                        XYZ(:,nanindex)=[];
                        XYZmm(:,nanindex)=[];
                        
                        % normalize betas
                        data=preprocess_data(data,prep);
                        
                        % start voxel loop
                        predicted=[];tested=predicted;
                        
                        % start run-wise crossvalidation
                        for run=unique(runlabel)'
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
                            
                            % balance data
                            w=1./hist(trainlabel, numel(unique(trainlabel)));
                            w=w./sum(w); %normalize sum to 1
                            weightstr=sprintf(' -w+%d %2.20f -q',[unique(trainlabel)';w]);
                            
                            % parameter tests
                            cmd = ['-t 0 -c 16 ' weightstr];
                            
                            %train classifier
                            model =  svmtrain(trainlabel, traindata, cmd);
                            [predlabel, acc] = svmpredict(testlabel, testdata, model);
                            predicted=[predicted;predlabel];
                            tested=[tested;testlabel];
                        end
                        crossacc=sum(predicted==tested)./length(predicted);
                        save(resfile,'crossacc','predicted','tested')
                    else
                        load(resfile);
                    end
                    accuracy(sub,vox)=crossacc;
                    l=l+1;
                    waitbar(l/loops,h);
                end %voxelloop
            end %subloop
            plotacc=accuracy.*100+(repmat(linspace(0,.75,length(sublist))',1,size(accuracy,2)));
            
            scrsz = get(0,'ScreenSize');
            figure('Position',[20 20 scrsz(3)*.9 scrsz(4).*9]);
            ca=[[eye(3); 1 1 0; 0 1 1; 1 0 1;.5 .5 .5];[eye(3); 1 1 0; 0 1 1; 1 0 1;.5 .5 .5].*.5];
            set(gcf,'Color','w','DefaultAxesColorOrder',ca)
            plot(plotacc')
            legend(cellfun(@num2str,num2cell(sublist),'uni',0),'Location','BestOutside')
            hold on;
            m(p,:)=mean(accuracy*100);
            e(p,:)=std(accuracy*100);
            
            plot(m(p,:),':k','LineWidth',2);
            [hy pval ci stat]=ttest(accuracy-(1/16));
            sigindex=find(hy);
            plot(sigindex,m(p,sigindex),' ro','MarkerEdgeColor','k','MarkerFaceColor','k')
            plot(sigindex,m(p,sigindex),' *','MarkerEdgeColor','w','MarkerSize',5)
            set(gca,'XTick',1:length(voxellist),'XTickLabel',cellfun(@num2str,num2cell(voxellist),'uni',0))
            if length(voxellist)>10
                set(gca,'XTick',2:2:length(voxellist),'XTickLabel',cellfun(@num2str,num2cell(voxellist(2:2:length(voxellist))),'uni',0))
            end
            ylabel('Accuracy in %')
            xlabel('Voxel Number')
            ylim([0 20])
%             title(titstr,'Interpreter','none')
            %if overwrite==0
%             set(gcf,'PaperPositionMode','auto');
%             print(figname,'-djpeg','-r200');
%             close;
            % end
            %end %if exist loop
        end %prep list
    end %conditions loop
end %spm path list (realign and no realign)
delete(h);


questfile=fullfile('..','spss','quest_cfs.xls');
[questdata questlegende]=xlsread(questfile);
subindex=ismember(questdata(:,strcmp(questlegende,'Subject')),sublist);

saf=questdata(subindex,strcmp(questlegende,'SAF'));
spindex=questdata(subindex,strcmp(questlegende,'SPINDEX'));

%
% % compare preprocessing
% f=myfigure(1,.4);%('Position',[20 20 scrsz(3)*.9 scrsz(4).*9],'Color','k');
% imagesc([m;ones(1,size(m,2))*60;ones(1,size(m,2))*50]);
% colormap('jet');
% set(gca,'XTick',1:length(voxellist),'XTickLabel',cellfun(@num2str,num2cell(voxellist),'uni',0))
% if length(voxellist)>10
%     set(gca,'XTick',2:2:length(voxellist),'XTickLabel',cellfun(@num2str,num2cell(voxellist(2:2:length(voxellist))),'uni',0))
% end
% set(gca,'YTick',1:length(preplist),'YTickLabel',{'none','unitlength','z-score','scale'})
% xlabel('Voxel Number','Color','w')
% ylabel('Preprocessing','Color','w')
% xlim([0.5 size(m,2)+.5])
% ylim([0.5 length(preplist)+.5])
% title('Decoding Accuracy','Interpreter','none')
% set(gcf,'InvertHardCopy','off');
% line([4.5,5.5;4.5,5.5;4.5 4.5;5.5 5.5],[1.5 1.5;2.5 2.5;1.5 2.5;1.5 2.5],'LineWidth',3,'Color','k')
% colorbar('YTick',[50,55,60],'YTickLabel',{'50%','55%','60%'},'Color','k','XColor','w','YColor','w','ZColor','w','FontName','Arial','FontSize',14)%print('Optimiz','-djpeg','-r200');
% set(gcf,'PaperPositionMode','auto');
% optname=fullfile('..','figures','optimizing.jpg');
% print(optname,'-djpeg','-r600');
% close;
