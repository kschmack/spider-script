tic
clear;close all;
set(0,'ShowHiddenHandles','on');
delete(get(0,'Children'));
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36,33];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher, 36 movement, 33 spider index outlier
sublist(ismember(sublist,exclude))=[];
respath='../groupstat/25sub_no33no36/searchlite_support_vector_regression/'; 
radius=8;

%% SVR options
% data selection
conlist={{'visible flower','visible spider'},{'invisible spider','invisible flower'}};%KONTRASTNAME
conlegende={'visflo_vs_visspi','invflo_vs_invspi'};%KURZKONTRASTNAME der Results-Ordner benutzt wird
datalist={fullfile('..','data','spi_mri_0_0XX','unistat','exp','spmT_00NUMBER.img')};% PATH zu Einzelstatistik
datalegende={'searchlite','ess','spmT'};%KURZNAME von Path zu Con-bild/spmT-Bild der Results-Ordner benutzt wird 

labellist={'SAF','SPINDEX'};%Continuous labels that will be decoded
questfile=fullfile('..','spss','quest_cfs.xls');%path to file where labels are stored


mask_path=fullfile('..','groupstat','25sub_no33no36','loc','mask.img');%PATH to group stat mask image that will be used as mask for decoding (to avoid useless decoding outside the brain)

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
h=waitbar(0,'SVR searchlight working...');



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
    label=questdata(subindex,strcmp(questlegende,labelstring));% HIER ANPASSEN-> hier wird label generiert= vector mit einem Eintrag pro Subject
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
                
                %% hier werden aus den verwendeten Daten strings für den Resultsordner abgeleitet, hier anpassen sodass datastring=spmT00XX
                if strcmp(datastring,'searchlite')&&~isempty(strfind(data_path,fullfile('realign','w')))
                    datastring='searchlitenosmooth';
                    if ~isempty(strfind(data_path,fullfile('realign','w03')))
                        datastring='searchlitewarp03nosmooth';
                        
                    end
                elseif strcmp(datastring,'spmT')&&~isempty(strfind(data_path,'_resample'))
                    datastring='spmTwarp03';
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
                
%                 %%UPDATE HERE!!! 
%                 if ~isempty(strfind(data_path,'w03'))||~isempty(strfind(data_path,'resample'))
%                     mask_path=fullfile('..','groupstat','25sub_no33no36','loc_resample','mask.img');
%                 end

                [t maskstring d]=fileparts(mask_path);
                
                for sub=1:length(sublist)
                    data_path_list{sub}=strrep(data_path,'0XX',sprintf('0%02.0f',sublist(sub)));
                end
                
                %extract image values
                [imval,XYZ,XYZmm] = extract_image_values(data_path_list,mask_path);%extraction of multivariate image values for decoding
                
                %cut off nans
                cutindex=sum(isnan(imval))>0;
                imval(:,cutindex)=[];
                XYZ(:,cutindex)=[];
                XYZmm(:,cutindex)=[];
                
                %preprocess image values
                for prepdat=1:length(prepdatalist)
                    prepdatastring=prepdatalist{prepdat};
                    [prepimval]=preprocess_data(imval,prepdatastring);
                    
                    
                    %model selection
                    for ker=1:length(kernellist)
                        cmd=['-s 3 ' kernellist{ker} ' -q'];
                        kernelstring=kernellegende{str2double(regexp(kernellist{ker},'\d','match'))+1};
                        
                        resfilepath=fullfile(respath,sprintf('%s_x_%s_%s_%s_label%s_%s',constr,labelstring,datastring,...
                            prepdatastring,preplabelstring,kernelstring));
                        if ~exist(resfilepath)
                            mkdir(resfilepath)
                        end
                        resfile=fullfile(resfilepath,'label.mat');
                        
                        if ~exist(resfile,'file')%%start analysis
                            
                            % searchlight
                            O = ones(1,length(XYZ));
                            r = radius.*radius;
                            scaledpredlabel=nan(length(sublist),length(XYZmm));
                            scaledtestlabel=nan(length(sublist),1);
                            rawpredlabel=scaledpredlabel;
                            rawtestlabel=scaledtestlabel;
                            
                            %try matlabpool; end %use PARALLEL COMPUTING BOX IF INSTALLED

                            for k=1:length(XYZmm) % start voxel loop
                                % define spherical volume
                                s = (sum((XYZmm-XYZmm(:,k)*O).^2) <= r);
                                prepimval_s=prepimval(:,s);
                                
                                
                                for sub=sublist %start n-leave-one-out crossvalidation
                                    testdata=prepimval_s(ismember(sublist,sub),:);
                                    testlabel=preplabel(ismember(sublist,sub));
                                    traindata=prepimval_s(~ismember(sublist,sub),:);
                                    trainlabel=preplabel(~ismember(sublist,sub));
                                    
                                    %% MULTIVARIATE ANALYSIS
                                    % training and testing phase
                                    model =  svmtrain(trainlabel,traindata, cmd); %-t kernel type (0 linear 1 polynomial 2 gamma)
                                    [predlabel, acc] = svmpredict(testlabel, testdata, model);
                                    rawtestlabel(sublist==sub)=testlabel;
                                    rawpredlabel(sublist==sub,k)=predlabel;
                                    
                                    
                                end
                            end

                            %scale it back
                            scaledpredlabel=preprocess_data(rawpredlabel,['retro' preplabelstring],repmat(scalemax,length(rawpredlabel),1)',repmat(scalemin,length(rawpredlabel),1)');
                            scaledtestlabel=preprocess_data(rawtestlabel,['retro' preplabelstring],scalemax,scalemin);
                            
                            save(resfile,'XYZ','XYZmm','rawtestlabel','rawpredlabel','scaledpredlabel','scaledtestlabel','preplabelstring','scalemax','scalemin');
                        else load(resfile)
                        end
                        l=l+1;
                        waitbar(l/loops,h);
                        
                        % output images
                        strct=spm_vol(mask_path);

                        
                        varlist={'rawpredlabel','scaledpredlabel'};
                        for s=1:length(sublist)
                            
                            for v=1:length(varlist)
                                varstr=varlist{v};
                              
                                im=nan(strct.dim);
                                eval(['predim=' varstr '(s,:);'])
                                for k=1:length(predim)%reshaping f?r Doofe
                                    imsublist(XYZ(1,k),XYZ(2,k),XYZ(3,k))=predim(k);
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