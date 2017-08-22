clear;
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,33,36];
sublist(ismember(sublist,exclude))=[];



cen={[36 -68   1]'};
name='Fus';

fprintf('%s\n\n',name);
%[50 -38 -10]'} MAX INVISIBLE DECODING 
%[-44 -80  -4]',[48 -74  -6]' MAX VISIBLE DECODING
%[38 -44 -19]',[-36 -38 -19]' MAX objects > scrambled
%[ 50 -72   1]',[48 -76  -6]' MAX visible spider > visible flower	 
%[-16   2 -17]',[28  -4 -17]' Amygdala_aal visible decoding
radius=1;

corstr='';
for c=1:length(cen)
    corstr=[corstr sprintf('%d %d %d and ',cen{c})];
end
corstr(end-3:end)='';
corstr=[corstr '(' name ')'];
corstr=[corstr sprintf(' with radius %d mm',radius)];


% load template
V=spm_vol('/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/loc/mask.img');
[trash XYZmm]=spm_read_vols(V);

% adjust rounded coordinates
cor=[];
for c=1:length(cen)
    center=cen{c};
    f=find(round(XYZmm(3,:))==center(3));
    center(3)=XYZmm(3,f(1));
    
    %create spherical ROIs
    O = ones(1,length(XYZmm));
    cor = [cor find((sum((XYZmm-center*O).^2) <= radius))];
    

end
[x y z]=ind2sub(V.dim,cor);
XYZ=[x;y;z];

% get peak voxels visible
for sub=sublist
    filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/realign/s03waccmincha_visflo_vs_visspi_off_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub);
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
        filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/exemplar/s03waccmincha_visspi_vector_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub);
%    filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/realign/s03waccmincha_invflo_vs_invspi_vector_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub);
%     filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/unistat/exp/con_00%02.0f.img\n',sub,5);
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
[rp_sum_trans rp_diff_trans rp_sum_rot rp_diff_rot]=check_rp_function(sublist);

% peak visible
for k=1:length(sublist)
   peakdat(k)=dat(mcor_line(k),k); 
   peakcor_mm(:,k)=XYZmm(:,cor(mcor_line(k)));
end

[h p ci stats]=ttest(peakdat,0,0.05,'right');
[rsaf psaf]=corr(peakdat',SAF);
[rspindex pspindex]=corr(peakdat',SPINDEX);
%fprintf('Image %s\n\n',filelist{1})
fprintf('Individual peak voxel from %s around %s\n',str,corstr)
fprintf('Main effect T=%2.2f p=%2.4f\n',stats.tstat,p)
fprintf('Correlation SAF r=%2.2f p=%2.4f\n',rsaf,psaf)
fprintf('Correlation SPINDEX r=%2.2f p=%2.4f\n\n',rspindex,pspindex)

% maximum
[maxidat index]=max(dat,[],1);
for k=1:length(sublist)
    maxicor_mm(:,k)=XYZmm(:,cor(index(k)));
end
[rsaf_peak psaf_peak]=corr(maxidat',SAF);
[rspindex_peak pspindex_peak]=corr(maxidat',SPINDEX);

fprintf('Individual peak voxel from %s around %s \n',str2,corstr)
fprintf('Correlation SAF r=%2.2f p=%2.4f\n',rsaf_peak,psaf_peak)
fprintf('Correlation SPINDEX r=%2.2f p=%2.4f\n\n',rspindex_peak,pspindex_peak)




% mean
meandat=mean(dat,1);
[h p_mean ci stats_mean]=ttest(meandat,0,0.05,'right');
[rsaf_mean psaf_mean]=corr(meandat',SAF);
[rspindex_mean pspindex_mean]=corr(meandat',SPINDEX);

fprintf('Mean at %s\n',corstr)
fprintf('Main effect T=%2.2f p=%2.4f\n',stats_mean.tstat,p_mean)
fprintf('Correlation SAF r=%2.2f p=%2.4f\n',rsaf_mean,psaf_mean)
fprintf('Correlation SPINDEX r=%2.2f p=%2.4f\n',rspindex_mean,pspindex_mean)

gf=figure;
set(gf,'Position',[50 250 600 600],'Color','w');
d1=meandat+100/16;
d2=SAF;
scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',2,'SizeData',150)
xlim([0 13])
ylim([0 90])
axis square
h=lsline;
set(h,'Color','k','LineStyle','--','LineWidth',2);
xlabel(sprintf('Decoding Accuracy at %d %d %d',cen{1}),'FontSize',20,'FontName','Arial','Interpreter','none')
ylabel({'Spider Phobia Score'},'FontSize',20,'FontName','Arial')
set(gca,'YTick',[0:20:80],'XTick',[0:6.5:13],'FontSize',20,'FontName','Arial','LineWidth',2)

xlim([0 13])
ylim([0 90])
title(sprintf('Decoding accuracy %2.2f t=%2.2f p=%2.4f\ncorrelation SAF r=%2.2f p=%2.4f',mean(d1),stats_mean.tstat,p_mean,rsaf_mean,psaf_mean))
% 
% gf=figure;
% set(gf,'Position',[50 250 600 600],'Color','w');
% d1=meandat+100/16;
% d2=SPINDEX;
% scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',2,'SizeData',150)
% xlim([0 13])
% ylim([.6 1.3])
% axis square
% h=lsline;
% set(h,'Color','k','LineStyle','--','LineWidth',2);
% xlabel(sprintf('Decoding Accuracy at %d %d %d',cen{1}),'FontSize',20,'FontName','Arial','Interpreter','none')
% ylabel({'Surpression Time Spider'},'FontSize',20,'FontName','Arial')
% set(gca,'YTick',[.6:.2:1.2],'XTick',[0:6.5:13],'FontSize',20,'FontName','Arial','LineWidth',2)
% 
% xlim([0 13])
% ylim([.6 1.3])
% title(sprintf('Decoding accuracy %2.2f t=%2.2f p=%2.4f\ncorrelation SAF r=%2.2f p=%2.4f',mean(d1),stats_mean.tstat,p_mean,rsaf_mean,psaf_mean))
% d2=SPINDEX;
% d1=meandat'+50;
% f=figure;
% set(f,'Position',[50 250 900 900],'Color','w');
% scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',1.5,'SizeData',200)
% xlim([33 60])
% ylim([.6 1.3])
% axis square
% h=lsline;
% set(h,'Color','k','LineStyle','--','LineWidth',1.5);
% xlabel(sprintf('Decoding Accuracy\n%s',corstr),'FontSize',30,'FontName','Arial')
% ylabel({'Surpression Time Spider'},'FontSize',30,'FontName','Arial')
% set(gca,'YTick',[.6:.2:1.2],'XTick',[40:10:60],'FontSize',25,'FontName','Arial','LineWidth',1.5)
% plot2svg(fullfile('..','figures','bcfs_x_invisiblecategoydecoding_SPHERE.svg'));
% exportfig(gcf,fullfile('..','figures','bcfs_x_invisiblecategoydecoding_SPHERE.eps'),'Color','gray','Resolution',800)
% [r1 p1]=corr(d1,d2,'Type','Pearson');
% [r2 p2]=corr(d1,d2,'Type','Spearman');
% [r3 p3]=permutecorr(d1,d2,10000);
