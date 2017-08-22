tic
clear;
close all;
set(0,'ShowHiddenHandles','on');
delete(get(0,'Children'));
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36,33];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher, 36 movement, 33 spider index outlier
sublist(ismember(sublist,exclude))=[];
respath=fullfile('..','groupstat','25sub_no33no36','searchlite_support_vector_regression_permutation');
radius=8;

%% SVR options
% data selection
conlist={{'invisible spider','invisible flower'}};%{'visible spider','visible flower'}
conlegende={'visflo_vs_visspi','invflo_vs_invspi'};
datalist={fullfile('..','data','spi_mri_0_0XX','unistat','exp_resample_08smooth','spmT_00NUMBER.img')};%fullfile('..','data','spi_mri_0_0XX','searchlite','realign','s03w03CONTRAST_off_radius08mm_spi_mri_0_0XX.nii'), fullfile('..','data','spi_mri_0_0XX','unistat','exp','ess_00NUMBER.img') {%fullfile('..','data','spi_mri_0_0XX','unistat','exp','ess_00NUMBER.img')}%datalegende={'searchlite','ess','spmT'};
datalegende={'searchlite','ess','spmT'};

labellist={'SPINDEX'};%'SAF','SPINDEX'
questfile=fullfile('..','spss','quest_cfs.xls');


mask_path=fullfile('..','groupstat','25sub_no33no36','loc_resample_08smooth','mask.img');


% preprocessing
prepdatalist={'scale'};
preplabellist={'scale'};

% model selection
kernellist={'-t 0'};%-t 0 linear -t 1 polynomial -t 2 radial basis functions
kernellegende={'linear','polynomial','rbf'};

% VORSPIEL
% initialize waitbar
loops=length(conlist)*length(datalist)*length(labellist)*length(prepdatalist)*length(preplabellist)*length(kernellist);
l=0;




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
                if strcmp(datastring,'searchlite')&&~isempty(strfind(data_path,fullfile('realign','w')))
                    datastring='searchlitenosmooth';
                    if ~isempty(strfind(data_path,fullfile('realign','w03')))
                        datastring='searchlitewarp03nosmooth';
                        
                    end
                elseif strcmp(datastring,'spmT')&&~isempty(strfind(data_path,'_resample'))
                  if ~isempty(strfind(data_path,'_08smooth'))
                                          datastring='spmTwarp03smooth08';
                  else                     datastring='spmTwarp03';
                  end


                    
                end


                if strcmp(datastring,'searchlite')&&~isempty(strfind(data_path,fullfile('realign','s03w03')))
                    datastring='searchlitewarp03';
                end

                
                if strcmp(datastring,'ess')
                    realconnumber=connumber+24;
                elseif ~isempty(strfind(datastring,'spmT'))
                    realconnumber=connumber*2+1;
                else realconnumber=999;
                end
                data_path=strrep(data_path,'NUMBER',sprintf('%02.0f',realconnumber));
                if ~isempty(strfind(data_path,'w03'))||~isempty(strfind(data_path,'resample'))
                    mask_path=fullfile('..','groupstat','25sub_no33no36','loc_resample','mask.img');
                end
                
                [t maskstring d]=fileparts(mask_path);
                
                for sub=1:length(sublist)
                    data_path_list{sub}=strrep(data_path,'0XX',sprintf('0%02.0f',sublist(sub)));
                end
                
                %extract image values
                [imval,XYZ,XYZmm] = extract_image_values(data_path_list,mask_path);
                
                %calculate number of permutations needed
                nperms=ceil(1/(0.05/size(imval,2))/1000)*1000;
                
                %cut off nans
                cutindex=sum(isnan(imval))>0;
                imval(:,cutindex)=[];
                XYZ(:,cutindex)=[];
                XYZmm(:,cutindex)=[];
                
                %preprocess image values
                for prepdat=1:length(prepdatalist)
                    prepdatastring=prepdatalist{prepdat};
                    [prepimval]=preprocess_data(imval,prepdatastring);
                    clear('imval')
                    
                    %model selection
                    for ker=1:length(kernellist)
                        cmd=['-s 3 ' kernellist{ker}];
                        kernelstring=kernellegende{str2double(regexp(kernellist{ker},'\d','match'))+1};
                        
                        resfilepath=fullfile(respath,sprintf('%s_x_%s_%s_%s_label%s_%s',constr,labelstring,datastring,...
                            prepdatastring,preplabelstring,kernelstring));
                        if ~exist(resfilepath)
                            mkdir(resfilepath)
                        end
                        resfile=fullfile(resfilepath,'label.mat');
                        
                        if ~exist(resfile,'file')
                            
                            h=waitbar(0,sprintf('SVR %d of %d searchlight working...',l+1, loops));
                            
                            % searchlight
                            O = ones(1,length(XYZ));                            
                            r = radius.*radius;
                            scaledpredlabel=nan(length(sublist),1);
                            scaledtestlabel=nan(length(sublist),1);
                            rawpredlabel=scaledpredlabel;
                            rawtestlabel=scaledtestlabel;
                            rawpredlabel_perm=scaledpredlabel;
                            cr=nan(0,length(XYZ));
                            %try matlabpool; end %use PARALLEL COMPUTING
                            %BOX IF INSTALLED

                            if exist(fullfile(fileparts(resfile),'temprevearse.mat'),'file')
                                load(fullfile(fileparts(resfile),'temprevearse.mat'))
                                kstart=k;
                                cr(end+1:length(XYZ))=nan;
                                mcrp(end+1:length(XYZ))=nan;
                                ncrp(end+1:length(XYZ))=nan;
                                pcrp(end+1:length(XYZ))=nan;

                            else kstart=length(XYZmm);
                            end
                                
                            for k=kstart:-1:1 % start voxel loop

                                % define spherical volume
                                s = (sum((XYZmm-XYZmm(:,k)*O).^2) <= r);
                                prepimval_s=prepimval(:,s);
                                
                                waitbar(k/length(XYZmm),h,sprintf('Started with actual Volume %s',datestr(now)));
                                for sub=sublist
                                    testdata=prepimval_s(ismember(sublist,sub),:);
                                    testlabel=preplabel(ismember(sublist,sub));
                                    traindata=prepimval_s(~ismember(sublist,sub),:);
                                    trainlabel=preplabel(~ismember(sublist,sub));
                                    
                                    %% MULTIVARIATE ANALYSIS
                                    % training and testing phase
                                    model =  svmtrain(trainlabel,traindata, cmd); %-t kernel type (0 linear 1 polynomial 2 gamma)
                                    [predlabel, acc] = svmpredict(testlabel, testdata, model);
                                    rawtestlabel(sublist==sub)=testlabel;
                                    rawpredlabel(sublist==sub)=predlabel;
                                end
                                cr(k)=corr(rawtestlabel,rawpredlabel);
                                
                                crp=[cr(k) nan(1,nperms-1)];
                                pm=0;
                                while pm < nperms && sum(crp>cr(k))<3
                                    pm=pm+1;                                    
                                    preplabel_perm=preplabel(randperm(length(preplabel)));
                                    for sub=sublist                                        
                                        testdata_perm=prepimval_s(ismember(sublist,sub),:);
                                        testlabel_perm=preplabel_perm(ismember(sublist,sub));
                                        traindata_perm=prepimval_s(~ismember(sublist,sub),:);
                                        trainlabel_perm=preplabel_perm(~ismember(sublist,sub));
                                        
                                        %% MULTIVARIATE ANALYSIS
                                        % training and testing phase
                                        model =  svmtrain(trainlabel_perm,traindata_perm, cmd); %-t kernel type (0 linear 1 polynomial 2 gamma)
                                        [predlabel_perm, acc] = svmpredict(testlabel_perm, testdata_perm, model);
                                        rawpredlabel_perm(sublist==sub)=predlabel_perm;
                                    end 
                                    crp(pm)=corr(rawtestlabel,rawpredlabel_perm);
                                end
                                crp(isnan(crp))=[];
                                mcrp(k)=mean(crp);
                                ncrp(k)=length(crp);
                                pcrp(k)=1-sum(cr(k)>crp)/length(crp);
                                
                                
                                %if rem(k,100)==0
                                    save(fullfile(fileparts(resfile),'temprevearse.mat'),'k','cr','mcrp','ncrp','pcrp')
                                %end
                            end
                                                        
                            save(resfile,'XYZ','XYZmm','preplabelstring','cr','mcrp','ncrp','pcrp');
                            close (h);
                        else load(resfile)
                        end
                        l=l+1;

                        
                        % output images
                        strct=spm_vol(mask_path);

                        
                        varlist={'rawpredlabel','scaledpredlabel'};
                        for s=1:length(sublist)
                            
                            for v=1:length(varlist)
                                varstr=varlist{v};
                              
                                im=nan(strct.dim);
                                eval(['predim=' varstr '(s,:);'])
                                for k=1:length(predim)%reshaping f?r Doofe
                                    im(XYZ(1,k),XYZ(2,k),XYZ(3,k))=predim(k);
                                end
                                oim   = struct('fname', fullfile(resfilepath,sprintf('%s_spi_mri_0_0%02.0f.nii',varstr,sublist(s))),...
                                    'dim',   {strct.dim},...
                                    'dt',    {[16 0]},...
                                    'pinfo', {strct.pinfo},...
                                    'mat',   {strct.mat},...
                                    'descrip', {[varstr ' map']});
                                oim=spm_create_vol(oim);
                                oim=spm_write_vol(oim,im);
                                fprintf('Written %s!\n',oim.fname);
                                clear('predim','im');
                            end
                        end
                        
                        
                        
                    end %cross validation
                end % preprocessing loop
            end %data loop
        end % preprocessing label list
    end % conditions loop
end % label list
% set(0,'ShowHiddenHandles','on');
% delete(get(0,'Children'));
%[r(prepdat,preplab,ker) p(prepdat,preplab,ker)]=corr(scaledpredlabel,scaledtestlabel);
%rmse(prepdat,preplab,ker)=(sum(abs((scaledtestlabel-scaledpredlabel)./scaledtestlabel))./length(scaledtestlabel));

toc