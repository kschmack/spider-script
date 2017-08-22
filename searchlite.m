clear;
sublist=[4,6:7];
radius=10;
conditions={'invisible spider','invisible flower'};

spm_path=fullfile('..','data','spi_mri_0_0XX','unistat','exp_nonorm_nosmooth');
mask_path=fullfile('..','data','spi_mri_0_0XX','unistat','exp_nonorm_nosmooth','mask.img');
feature_path=fullfile('..','data','spi_mri_0_0XX','unistat','loc_nonorm_nosmooth','spmT_0001.img');
feature_path='ttest';
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
    data=preprocess_data(data,'off');
    
    % start voxel loop
    for vox=1:length(voxellist);
        predicted=[];tested=predicted;

        % start run-wise crossvalidation
        for run=unique(runlabel)'
            testdata=data(runlabel==run,:);
            testlabel=label(runlabel==run);
            traindata=data(runlabel~=run,:);
            trainlabel=label(runlabel~=run);
            
            %voxel selection (F-test)
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
            
            accuracy(sub,vox)=sum(predicted==tested)/length(predicted);
        end
    end
end
accuracy=accuracy*100;
[a b]=fileparts(mask_path);
figure;
set(gcf,'Color','w')
plot(accuracy')
legend(cellfun(@num2str,num2cell(sublist),'uni',0))
hold on;
plot(mean(accuracy),':k','LineWidth',2);
set(gca,'XTick',1:length(voxellist),'XTickLabel',cellfun(@num2str,num2cell(voxellist),'uni',0))
ylabel('Accuracy in %')
xlabel('Voxel Number')
title(['Decoding Accuracy for' b],'Interpreter','none')
