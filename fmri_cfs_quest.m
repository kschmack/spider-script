4close all
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher
sublist(ismember(sublist,exclude))=[];


questfile=fullfile('..','spss','quest_cfs.xls');
accfile=fullfile('..','data','spi_mri_0_0XX','multistat','norealign','invflo_vs_invspi_subjectXX_vector_fusiformlatmidocctemp_gyrus_wfupick_spmT_0001_250vox.mat');
controlaccfile=fullfile('..','data','spi_mri_0_0XX','multistat','norealign','invall_vs_visall_subjectXX_vector_fusiformlatmidocctemp_gyrus_wfupick_spmT_0001_250vox.mat');

%load questionaire data
data=[];legende=[];
[data legende]=xlsread(questfile);
data=data(ismember(data(:,1),sublist),:);

%load invisible accuracy
for sub=sublist
    load(strrep(accfile,'XX',sprintf('%02.0f',sub)));
    accall(sub==sublist)=crossacc*100;
end
data=[data accall'];
legende=[legende 'decoding_accuracy_invis'];

%load controll accuracy
for sub=sublist
    load(strrep(controlaccfile,'XX',sprintf('%02.0f',sub)));
    accall2(sub==sublist)=crossacc*100;
end
data=[data accall'./accall2'*100];
legende=[legende 'decoding_accuracy_invis_normalized'];


%make awarenesscheck data
[correct dprime binomialtest]=awareness_check_function(sublist);
data=[data correct' binomialtest' dprime'];
legende=[legende {'correct' 'binomialtest' 'dprime'}];

%load rp data
[rp_sum_trans rp_diff_trans rp_sum_rot rp_diff_rot]=check_rp_function(sublist);
data=[data rp_sum_trans rp_diff_trans rp_sum_rot rp_diff_rot];
legende=[legende {'rp_sum_trans' 'rp_diff_trans' 'rp_sum_rot' 'rp_diff_rot'}];

s=[];
while length(s)~=2
    [s,v] = listdlg('PromptString','Select TWO variables for correlation:',...
        'SelectionMode','multiple',...
        'ListString',legende);
end
% ausschluss=listdlg('PromptString','Select subjects you want to exclude:',...
%         'SelectionMode','multiple',...
%         'ListString',cellfun(@num2str,num2cell(data(:,1)),'uni',0));
% in=true(size(data,1),1);
% in(ausschluss)=false;
var1=data(:,s(1));
var2=data(:,s(2));

choice = questdlg('Do you want to include a variable of no interest?', ...
    'Answer','yes','no','no');
switch choice
    case 'no'
        [r p]=corr(var1,var2,'Type','Spearman');
        myfigure(.75,.75)
        scatter(var1,var2,'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','k','SizeData',100);%,'MarkerSize',20,'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','w')
        l=lsline;
        set(l,'LineStyle','--')
        hold on;
        %text(var1,var2,cellfun(@num2str,num2cell(data(in,1)),'uni',0),'VerticalAlignment','middle','HorizontalAlignment','center','Color','w');
        str= sprintf('%s x %s (r=%2.2f p=%2.4f)',legende{s(1)},legende{s(2)},r,p);
        title(str,'Interpreter','none')
        xlabel(legende{s(1)},'Interpreter','none');
        ylabel(legende{s(2)},'Interpreter','none');
        
        set(gcf,'InvertHardCopy','off','PaperPositionMode','auto');
        optname=fullfile('..','figures',sprintf('%s_x_%s.jpg',legende{s(1)},legende{s(2)}));
        print(optname,'-djpeg','-r600');
    case 'yes'
        myfigure(.75,.75)
        [noint,vorr] = listdlg('PromptString','Select ONE variable of no interest:',...
            'SelectionMode','single',...
            'ListString',legende);
        nointvar=data(:,noint);
        [r p]=partialcorr(var1,var2,nointvar,'Type','Spearman');
        myfigure(.75,.75)
        scatter(var1,var2,'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','k','SizeData',100);%,'MarkerSize',20,'MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','w')
        l=lsline;
        set(l,'LineStyle','--')
        str= sprintf('%s x %s corrected for %s(r=%2.2f p=%2.4f)',legende{s(1)},legende{s(2)},legende{noint},r,p);
        title(str,'Interpreter','none')
        xlabel(legende{s(1)},'Interpreter','none');
        ylabel(legende{s(2)},'Interpreter','none');
                set(gcf,'InvertHardCopy','off','PaperPositionMode','auto');
        optname=fullfile('..','figures',sprintf('%s_x_%s_partialout_%s.jpg',legende{s(1)},legende{s(2)},legende{noint}));
        print(optname,'-djpeg','-r600');
end



