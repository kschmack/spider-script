clear;
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,33,36];
sublist(ismember(sublist,exclude))=[];



fid=fopen('/Volumes/ZIMTZICKE/spider/script/maskresults.csv','w');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\t%s\t%s\t%s\t%s\t%s\t%s\n','Mask',...
'SAF peakloc','SAF peakvisible','SAF peakinvisible','SAF mean','SPINDEX peakloc','SPINDEX peakdecoding','SPINDEX mean',...
'SAF peakloc','SAF peakvisible','SAF peakinvisible','SAF mean','SPINDEX peakloc','SPINDEX peakdecoding','SPINDEX mean');
cd('/Volumes/ZIMTZICKE/spider/mask');
[files d] = uigetfile('*','Select the Maskfiles','MultiSelect','on');
if ~iscell(files)
    f{1}=files;
    clear('files');
    files=f;
end

for f=1:length(files)
    
    fprintf('\nMask: %s\n\n',files{f});
    
    % load mask and get voxel coordinates
    V=spm_vol(fullfile(pwd,files{f}));
    [Mval XYZmm]=spm_read_vols(V);
    linindex=find(Mval>0);
    [x y z]=ind2sub(V.dim,linindex);
    XYZ=[x,y,z]';
    
    % get peak voxels localizer
    for sub=sublist
        %filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/realign/s03wvisflo_vs_visspi_off_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub);
        %filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/unistat/exp/con_00%02.0f.img\n',sub,3);
        filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/unistat/loc/con_00%02.0f.img\n',sub,1);
    end
    [d strloc e]=fileparts(filelist{1});
    
    for k=1:length(filelist);
        im=spm_vol(filelist{k});
        [M]=spm_get_data(im,XYZ);
        locdata{k}=M';
    end
    locdat=cell2mat(locdata);
    [val lcor_line]=max(locdat,[],1);
    lcor_col=1:length(sublist);
    
    % get peak voxels visible
    for sub=sublist
        filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/realign/wvisflo_vs_visspi_off_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub);
        %filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/unistat/exp/con_00%02.0f.img\n',sub,3);
        %filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/unistat/loc/con_00%02.0f.img\n',sub,1);
    end
    [d str e]=fileparts(filelist{1});
    
    for k=1:length(filelist);
        im=spm_vol(filelist{k});
        [M]=spm_get_data(im,XYZ);
        maxdata{k}=M';
    end
    maxdat=cell2mat(maxdata);
    [val mcor_line]=max(maxdat,[],1);
    mcor_col=1:length(sublist);
    
    
    % get betas
    for sub=sublist
        filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/realign/winvflo_vs_invspi_vector_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub);
    end
    for k=1:length(filelist);
        im=spm_vol(filelist{k});
        [M]=spm_get_data(im,XYZ);
        data{k}=M';
    end
    dat=cell2mat(data);
    [d str2 e]=fileparts(filelist{1});
    
    %get spider data
    load(fullfile('..','groupstat','25sub_no33no36','covariates.mat'));
    
    % peak localizer
    for k=1:length(sublist)
        lpeakdat(k)=dat(lcor_line(k),k);
    end
    
    [h p(1) ci stats(1)]=ttest(lpeakdat,50,0.05,'right');
    [rsaf(1) psaf(1)]=corr(lpeakdat',SAF);
    [rspindex(1) pspindex(1)]=corr(lpeakdat',SPINDEX);
    %fprintf('Image %s\n\n',filelist{1})
    fprintf('Individual peak voxel from %s\n',strloc)
    fprintf('Main effect T=%2.2f p=%2.4f\n',stats(1).tstat,p(1))
    fprintf('correlation SAF r=%2.2f p=%2.4f\n',rsaf(1),psaf(1))
    fprintf('correlation SPINDEX r=%2.2f p=%2.4f\n\n',rspindex(1),pspindex(1))
    
    % peak visible
    for k=1:length(sublist)
        peakdat(k)=dat(mcor_line(k),k);
    end
    
    [h p(2) ci stats(2)]=ttest(peakdat,50,0.05,'right');
    [rsaf(2) psaf(2)]=corr(peakdat',SAF);
    [rspindex(2) pspindex(2)]=corr(peakdat',SPINDEX);
    %fprintf('Image %s\n\n',filelist{1})
    fprintf('Individual peak voxel from %s\n',str)
    fprintf('Main effect T=%2.2f p=%2.4f\n',stats(2).tstat,p(2))
    fprintf('correlation SAF r=%2.2f p=%2.4f\n',rsaf(2),psaf(2))
    fprintf('correlation SPINDEX r=%2.2f p=%2.4f\n\n',rspindex(2),pspindex(2))
    
    % maximum
    [maxidat index]=max(dat,[],1);
    [rsaf(3) psaf(3)]=corr(maxidat',SAF);
    [rspindex(3) pspindex(3)]=corr(maxidat',SPINDEX);
    [h p(3) ci stats(3)]=ttest(maxidat,50,0.05,'right');
    
    fprintf('Individual peak voxel from %s\n',str2)
    fprintf('correlation SAF r=%2.2f p=%2.4f\n',rsaf(3),psaf(3))
    fprintf('correlation SPINDEX r=%2.2f p=%2.4f\n\n',rspindex(3),pspindex(3))
    
    
    
    
    % mean
    meandat=mean(dat,1);
    [h p(4) ci stats(4)]=ttest(meandat,50,0.05,'right');
    [rsaf(4) psaf(4)]=corr(meandat',SAF);
    [rspindex(4) pspindex(4)]=corr(meandat',SPINDEX);
    
    fprintf('Mean\n')
    fprintf('Main effect T=%2.2f p=%2.4f\n',stats(4).tstat,p(4))
    fprintf('correlation SAF r=%2.2f p=%2.4f\n',rsaf(4),psaf(4))
    fprintf('correlation SPINDEX r=%2.2f p=%2.4f\n',rspindex(4),pspindex(4))
    
    
    % d1=meandat';
    % gf=figure;
    % set(gf,'Position',[50 250 1800 900],'Color','w');
    %
    % subplot(1,2,1)
    % d2=SAF;
    % scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',1.5,'SizeData',200)
    % xlim([30 70])
    % ylim([0 90])
    % axis square
    % h=lsline;
    % set(h,'Color','k','LineStyle','--','LineWidth',1.5);
    % xlabel(sprintf('Decoding Accuracy\n%s',files{f}),'FontSize',30,'FontName','Arial','Interpreter','none')
    % ylabel({'Surpression Time Spider'},'FontSize',30,'FontName','Arial')
    % set(gca,'YTick',[10:10:90],'XTick',[40:10:60],'FontSize',25,'FontName','Arial','LineWidth',1.5)
    % title(sprintf('Decoding accuracy %2.2f t=%2.2f p=%2.4f\ncorrelation SAF r=%2.2f p=%2.4f',mean(d1),stats(4).tstat,p(4),rsaf(4),psaf(4)))
    %
    %
    % subplot(1,2,2)
    % d2=SPINDEX;
    % scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',1.5,'SizeData',200)
    % xlim([30 70])
    % ylim([.6 1.4])
    % axis square
    % h=lsline;
    % set(h,'Color','k','LineStyle','--','LineWidth',1.5);
    % xlabel(sprintf('Decoding Accuracy\n%s',files{f}),'FontSize',30,'FontName','Arial','Interpreter','none')
    % ylabel({'Surpression Time Spider'},'FontSize',30,'FontName','Arial')
    % set(gca,'YTick',[.6:.2:1.4],'XTick',[40:10:60],'FontSize',25,'FontName','Arial','LineWidth',1.5)
    % set(gcf,'PaperPositionMode','auto')
    % title(sprintf('Decoding accuracy %2.2f t=%2.2f p=%2.4f\ncorrelation SPINDEX r=%2.2f p=%2.4f',mean(d1),stats(4).tstat,p(4),rspindex(4),pspindex(4)))
    %
    % d1=maxidat';
    %
    % subplot(1,2,f)
    % d2=SAF;
    % scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',1.5,'SizeData',200)
    % xlim([40 80])
    % ylim([0 90])
    % axis square
    % h=lsline;
    % set(h,'Color','k','LineStyle','--','LineWidth',1.5);
    % xlabel(sprintf('Decoding Accuracy\n%s',files{f}),'FontSize',30,'FontName','Arial','Interpreter','none')
    % ylabel({'Surpression Time Spider'},'FontSize',30,'FontName','Arial')
    % set(gca,'YTick',[10:10:90],'XTick',[40:10:60],'FontSize',25,'FontName','Arial','LineWidth',1.5)
    % title(sprintf('Decoding accuracy %2.2f t=%2.2f p=%2.4f\ncorrelation SAF r=%2.2f p=%2.4f',mean(d1),stats(3).tstat,p(3),rsaf(3),psaf(3)))
    %
    %
    % subplot(1,2,2)
    % d2=SPINDEX;
    % scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',1.5,'SizeData',200)
    % xlim([30 70])
    % ylim([.6 1.4])
    % axis square
    % h=lsline;
    % set(h,'Color','k','LineStyle','--','LineWidth',1.5);
    % xlabel(sprintf('Decoding Accuracy\n%s',files{f}),'FontSize',30,'FontName','Arial','Interpreter','none')
    % ylabel({'Surpression Time Spider'},'FontSize',30,'FontName','Arial')
    % set(gca,'YTick',[.6:.2:1.4],'XTick',[40:10:60],'FontSize',25,'FontName','Arial','LineWidth',1.5)
    % set(gcf,'PaperPositionMode','auto')
    % title(sprintf('Decoding accuracy %2.2f t=%2.2f p=%2.4f\ncorrelation SPINDEX r=%2.2f p=%2.4f',mean(d1),stats(3).tstat,p(3),rspindex(3),pspindex(3)))
    
    
    fprintf(fid,'%s\t',files{f})
    fprintf(fid,'%2.4f\t',round(psaf*10000)/10000);
    fprintf(fid,'%2.4f\t',round(pspindex*10000)/10000);
    fprintf(fid,'\t');
    fprintf(fid,'%2.2f\t',round(rsaf*100)/100);
    fprintf(fid,'%2.2f\t',round(rspindex*100)/100);
    fprintf(fid,'\n');

end
cd('/Volumes/ZIMTZICKE/spider/script')
fclose(fid);