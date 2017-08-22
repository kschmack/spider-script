clear;close all;
set(0,'ShowHiddenHandles','on');
delete(get(0,'Children'));
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36,33];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher, 36 movement, 33 spider index outlier
sublist(ismember(sublist,exclude))=[];
respath='../groupstat/25sub_no33no36/support_vector_regression/';

%% SVR options
% data selection
conlist={{'visible flower','visible spider'},{'invisible spider','invisible flower'}};
conlegende={'visflo_vs_visspi','invflo_vs_invspi'};
datalist={fullfile('..','data','spi_mri_0_0XX','searchlite','realign','s03wCONTRAST_off_radius08mm_spi_mri_0_0XX.nii')};%fullfile('..','data','spi_mri_0_0XX','unistat','exp','spmT_00NUMBER.img'){%fullfile('..','data','spi_mri_0_0XX','unistat','exp','ess_00NUMBER.img')}%
datalegende={'searchlite','ess','spmT'};

labellist={'SAF','SPINDEX'};%'SAF','SPINDEX'
questfile=fullfile('..','spss','quest_cfs.xls');

%feature selection
masklist={fullfile('..','mask','fuslatmidocctemp_26sub.nii')};
voxellist=[500];
featurelist={'pearson'};

% preprocessing
prepdatalist={'norm','vector','scale','log'};
preplabellist={'norm','vector','scale','log'};

% model selection
kernellist={'-t 0','-t 1','-t 2',};%-t 0 linear -t 1 polynomial -t 2 radial basis functions
kernellegende={'linear','polynomial','rbf'};

% VORSPIEL
% initialize waitbar
loops=length(conlist)*length(datalist)*length(labellist)*length(voxellist)*length(masklist)*length(featurelist)*length(prepdatalist)*length(preplabellist)*length(kernellist);
l=0;
h=waitbar(0,'Support vector regression working...');


% % make names and strings
% titstr=sprintf('%s - %s (%s %s %s)',conditions{1},conditions{2},mskstr,prep,ftrstr);
% cond=sort(conditions);
% str1=regexp(cond{1},' ','split');if isempty(str1{2});str1{2}='all'; end
% str2=regexp(cond{2},' ','split');if isempty(str2{2});str2{2}='all'; end
% figstr=sprintf('%s%s_vs_%s%s_%dsub_%s_%s_%s.jpg',str1{1}(1:3),str1{2}(1:3),str2{1}(1:3),str2{2}(1:3),length(sublist),mskstr,prep,ftrstr);
% figname=fullfile('..','results',spm_path(strfind(spm_path,'norealign'):end),figstr);

for lab=1:length(labellist)
    
    %load label
    labelstring=labellist{lab};
    [questdata questlegende]=xlsread(questfile);
    subindex=ismember(questdata(:,strcmp(questlegende,'Subject')),sublist);
    label=questdata(subindex,strcmp(questlegende,labelstring));
    if isempty(label); error('%s not in found in %s\n',labelstring,questfile);end
    
    for con=1:length(conlist)
        conditions=conlist{con};
        cond=sort(conditions);
        str1=regexp(cond{1},' ','split');if isempty(str1{2});str1{2}='all'; end
        str2=regexp(cond{2},' ','split');if isempty(str2{2});str2{2}='all'; end
        constr=sprintf('%s%s_vs_%s%s',str1{1}(1:3),str1{2}(1:3),str2{1}(1:3),str2{2}(1:3));
        connumber=find(strcmp(constr,conlegende));

        
        
        %preprocess label
        for preplab=1:length(preplabellist)
            preplabelstring=preplabellist{preplab};
            [preplabel,scalemax,scalemin]=preprocess_data(label,preplabelstring);
            
            for dat=1:length(datalist)
                clear('realconnumber');
                data_path=strrep(datalist{dat},'CONTRAST',constr);
                datastring=datalegende{~cellfun(@isempty,cellfun(@(x) strfind(data_path,x),datalegende,'uni',0))};
                if strcmp(datastring,'ess')
                    realconnumber=connumber+24;
                elseif strcmp(datastring,'spmT')
                    realconnumber=connumber*2+1;
                else realconnumber=999;
                end
                data_path=strrep(data_path,'NUMBER',sprintf('%02.0f',realconnumber));

                
                for msk=1:length(masklist)
                    mask_path=masklist{msk};
                    [t maskstring d]=fileparts(mask_path);
                    
                    for sub=1:length(sublist)
                        data_path_list{sub}=strrep(data_path,'0XX',sprintf('0%02.0f',sublist(sub)));
                    end
                    
                    %extract image values
                    [imval,XYZ,XYZmm] = extract_image_values(data_path_list,mask_path);
                    
                    %cut off nans
                    cutindex=sum(isnan(imval))>0;
                    imval(:,cutindex)=[];
                    XYZ(:,cutindex)=[];
                    XYZmm(:,cutindex)=[];
                    
                    %preprocess image values
                    for prepdat=1:length(prepdatalist)
                        prepdatastring=prepdatalist{prepdat};
                        [prepimval]=preprocess_data(imval,prepdatastring);
                        
                        %feature selection
                        for fea=1:length(featurelist)
                            featurestring=featurelist{fea};
                            
                            %voxel selection
                            for vox=voxellist
                                
                                %model selection
                                for ker=1:length(kernellist)
                                    cmd=['-s 3 ' kernellist{ker} ' -q'];
                                    kernelstring=kernellegende{str2double(regexp(kernellist{ker},'\d','match'))+1};
                                    
                                    resfile=fullfile(respath,sprintf('%s_x_%s_%s_%s_%s_%05.0fvox_%s_label%s_%s.mat',constr,labelstring,datastring,maskstring,featurestring,...
                                        vox,prepdatastring,preplabelstring,kernelstring))
                                    
                                    if ~exist(resfile)
                                        tic
                                        
                                        %start subject-wise cross-validation
                                        scaledpredlabel=nan(length(sublist),1);
                                        scaledtestlabel=nan(length(sublist),1);
                                        for sub=sublist
                                            testdata=prepimval(ismember(sublist,sub),:);
                                            testlabel=preplabel(ismember(sublist,sub));
                                            traindata=prepimval(~ismember(sublist,sub),:);
                                            trainlabel=preplabel(~ismember(sublist,sub));
                                            
                                            %feature selection
                                            findex=feature_select(traindata,trainlabel,featurestring,XYZ);
                                            
                                            %% MULTIVARIATE ANALYSIS
                                            % training and testing phase
                                            model =  svmtrain(trainlabel,traindata(:,findex(1:vox)), cmd); %-t kernel type (0 linear 1 polynomial 2 gamma)
                                            [predlabel, acc] = svmpredict(testlabel, testdata(:,findex(1:vox)), model);
                                            testlabelall(sublist==sub)=testlabel;
                                            predlabelall(sublist==sub)=predlabel;
                                            %scale it back
                                            scaledpredlabel(sublist==sub)=preprocess_data(predlabel,['retro' preplabelstring],scalemax,scalemin);
                                            scaledtestlabel(sublist==sub)=preprocess_data(testlabel,['retro' preplabelstring],scalemax,scalemin);
                                            
                                        end
                                        save(resfile,'scaledpredlabel','scaledtestlabel');
                                        toc
                                        
                                    else load(resfile)
                                    end
                                    [r(prepdat,preplab,ker) p(prepdat,preplab,ker)]=corr(scaledpredlabel,scaledtestlabel);
                                    rmse(prepdat,preplab,ker)=(sum(abs((scaledtestlabel-scaledpredlabel)./scaledtestlabel))./length(scaledtestlabel));
                                    l=l+1;
                                    waitbar(l/loops,h);
                                    
                                    
                                end %cross validation
                            end %voxel list
                        end %feature selection
                    end % preprocessing loop
                end %mask loop
            end %data loop
        end % preprocessing label list
        

        myfigure(1,.5)
        for k=1:size(r,3)
            if k==3
                text(0,1.05,sprintf('%s_x_%s_%s_%s_%s_%05.0fvox',constr,labelstring,datastring,maskstring,featurestring,...
                    vox),'Interpreter','none','Color','w');
            end
            mysubplot(1,size(r,3),k)
            title(kernellegende{k})
            plot(rmse(:,:,k),'LineWidth',2)
            ylim([0 1])
            set(gca,'XTickLabel',prepdatalist,'XTick',1:length(prepdatalist))
            lh=legend(preplabellist);
            set(lh,'Color','k','TextColor','w');
            ylabel('MAPE')
            xlabel('Data Preprocessing')
        end
        
                myfigure(1,.5)
        for k=1:size(r,3)
            if k==3
                text(0,1.15,sprintf('%s_x_%s_%s_%s_%s_%05.0fvox',constr,labelstring,datastring,maskstring,featurestring,...
                    vox),'Interpreter','none','Color','w');
            end
            mysubplot(1,size(r,3),k)
            title(kernellegende{k})
            plot(r(:,:,k),'LineWidth',2)
            ylim([-1 1])
            set(gca,'XTickLabel',prepdatalist,'XTick',1:length(prepdatalist))
            lh=legend(preplabellist);
            set(lh,'Color','k','TextColor','w');
            ylabel('Correlation coefficient')
            xlabel('Data Preprocessing')
        end

        
        
%             myfigure;
%     title(sprintf('%s_x_%s_%s_%s_%s_%05.0fvox_%s_label%s_%s.mat',constr,labelstring,datastring,maskstring,featurestring,...
%         vox,prepdatastring,preplabelstring,kernelstring),'Interpreter','none');
%     plot(r,' wo')
%     plot(find(p<0.05),r(p<0.05),' r.')
%     set(gca,'XTickLabel',voxellist,'XTick',1:length(voxellist))
%     xlabel('Voxel Number')
%     ylabel('Correlation coefficient')

    end % conditions loop
   
end % label list
% set(0,'ShowHiddenHandles','on');
% delete(get(0,'Children'));
