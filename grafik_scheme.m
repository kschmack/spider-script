clear;
close all;
sublist=[4:10,12:23,25:26,30:39];
% sublist=[4:40];
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,33,36];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher, 33 button malfunction, 36 movement
sublist(ismember(sublist,exclude))=[];

%exclude=[8,15,23,32,36,33];%8 objective over chance, 15 and 36 movement, 23 subjective 80% sehr sicher, 32 80% sicher

% exclude=[33];
% sublist(ismember(sublist,exclude))=[];

for k=1:length(sublist);
    sub=sublist(k);
    datapath=fullfile('..','bs_behav');
    data=[];
    for run=1:4
        filename=fullfile(datapath,sprintf('cfs_fade_spi_beh_0_0%02.0f_%d.res',sub,run));
        dat=load(filename);
        
        %% Errors and Missed trials
        %find errors
        a=dat(:,1)>200 & dat(:,1)<300 & dat(:,5)~=10  & dat(:,5)~=0;
        b=dat(:,1)>300 & dat(:,1)<400 & dat(:,5)~=6 & dat(:,5)~=0;
        c=dat(:,1)>400 & dat(:,1)<500 & dat(:,5)~=14 & dat(:,5)~=0;
        d=dat(:,1)>500 & dat(:,1)<600 & dat(:,5)~=22 & dat(:,5)~=0;
        inderr=a|b|c|d;
        err(sub==sublist,run)=sum(inderr);
        
        %find misses
        indmis=ismember(dat(:,5),[6,10,14,22])==0;
        missed(k,run)=sum(indmis);
        
        %cut off
        dat(indmis|inderr,:)=[];
        
        %% CREATE FINAL DATA MATRIX
        spiflow=abs((mod(dat(:,1),100)<=16)*3-2); %1 spider 2 flower
        lefrig=dat(:,2); %-1 left 1 right
        rt=dat(:,4)-dat(:,3); % surpression time
        data=[spiflow lefrig rt];
        %data(rt>17000,:)=[];

        %% CALCULATE RAW VALUES
        surtime(k,run,1)=mean(data((data(:,1)==1 & data(:,2)==-1),3));
        trials(k,run,1)=length(data((data(:,1)==1 & data(:,2)==-1),3));
        
        surtime(k,run,2)=mean(data((data(:,1)==1 & data(:,2)==1),3));
        trials(k,run,2)=length(data((data(:,1)==1 & data(:,2)==1),3));
        
        surtime(k,run,3)=mean(data((data(:,1)==2 & data(:,2)==-1),3));
        trials(k,run,3)=length(data((data(:,1)==2 & data(:,2)==-1),3));
        
        surtime(k,run,4)=mean(data((data(:,1)==2 & data(:,2)==1),3));
        trials(k,run,4)=length(data((data(:,1)==2 & data(:,2)==1),3));
    end
end
annotation={'spider left' 'spider right' 'flower left' 'flower right'};
surtime(isnan(surtime))=1000000000000000;

%% CALCULATE FINAL VALUES
runlist={[1:4],[2:4]};
runstr={'allruns','nofirstrun'};
bslegende=[];
legende={'surtime_spider_runstr_botheye','surtime_flower_runstr_botheye',...
    'surtime_spider_runstr_left','surtime_flower_runstr_left',...
    'surtime_spider_runstr_right','surtime_flower_runstr_right',...
    'surtime_both_runstr_left','surtime_both_runstr_right',...
    'surtime_spider_runstr_domeye','surtime_flower_runstr_domeye',...
    'surtime_spider_runstr_nondomeye','surtime_flower_runstr_nondomeye'};
for r=1:length(runlist);
    bslegende=[bslegende strrep(legende,'runstr',runstr{r})];
    runs=runlist{r};
    r0=r-1;
    bsdata(:,(12*r0)+1)=sum(surtime(:,runs,1).*trials(:,runs,1)+surtime(:,runs,2).*trials(:,runs,2),2)./sum(sum(trials(:,runs,1:2),3),2);
    bsdata(:,(12*r0)+2)=sum(surtime(:,runs,3).*trials(:,runs,3)+surtime(:,runs,4).*trials(:,runs,4),2)./sum(sum(trials(:,runs,3:4),3),2);
    bsdata(:,(12*r0)+3)=sum(surtime(:,runs,1).*trials(:,runs,1),2)./sum(sum(trials(:,runs,1),3),2);
    bsdata(:,(12*r0)+4)=sum(surtime(:,runs,3).*trials(:,runs,3),2)./sum(sum(trials(:,runs,3),3),2);
    bsdata(:,(12*r0)+5)=sum(surtime(:,runs,2).*trials(:,runs,2),2)./sum(sum(trials(:,runs,2),3),2);
    bsdata(:,(12*r0)+6)=sum(surtime(:,runs,4).*trials(:,runs,4),2)./sum(sum(trials(:,runs,4),3),2);
    
    bsdata(:,(12*r0)+7)=sum(surtime(:,runs,1).*trials(:,runs,1)+surtime(:,runs,3).*trials(:,runs,3),2)./sum(sum(trials(:,runs,[1,3]),3),2);
    bsdata(:,(12*r0)+8)=sum(surtime(:,runs,2).*trials(:,runs,2)+surtime(:,runs,4).*trials(:,runs,4),2)./sum(sum(trials(:,runs,[2,4]),3),2);
    index=((bsdata(:,(12*r0)+7)-bsdata(:,(12*r0)+8))>0)*2+3;
    for n=1:length(index)
        tmp1(n,1)=bsdata(n,index(n));
        tmp2(n,1)=bsdata(n,index(n)+1);
    end
    bsdata(:,(12*r0)+9)=tmp1;
    bsdata(:,(12*r0)+10)=tmp2;
    clear('tmp1','tmp2');
    
    index=((bsdata(:,(12*r0)+7)-bsdata(:,(12*r0)+8))<0)*2+3;
    for n=1:length(index)
        tmp1(n,1)=bsdata(n,index(n));
        tmp2(n,1)=bsdata(n,index(n)+1);
    end
    bsdata(:,(12*r0)+11)=tmp1;
    bsdata(:,(12*r0)+12)=tmp2;
    clear('tmp1','tmp2');
end

cutindex=~cellfun(@isempty,(strfind(bslegende,'right')))|~cellfun(@isempty,(strfind(bslegende,'left')));
bsdata(:,cutindex)=[];
bslegende(cutindex)=[];
for k=2:2:(length(bslegende))
    spilegende{k-1}=strrep(bslegende{k-1},'spider','spinorm');
    spidata(:,k-1)=bsdata(:,k-1)./bsdata(:,k);
    %spilegende{k}=strrep(bslegende{k-1},'spider','spidiff');
    %spidata(:,k)=bsdata(:,k)-bsdata(:,k-1);
    spilegende{k}=strrep(bslegende{k-1},'spider','spidiffnorm');
    spidata(:,k)=bsdata(:,k)-bsdata(:,k-1)./bsdata(:,k);

end
questfile=fullfile('..','spss','quest_cfs.xls');
[questdata questlegende]=xlsread(questfile);
questdata=questdata(ismember(questdata(:,1),sublist),:);

d2=(spidata(:,7));
f=figure;
set(f,'Position',[50 250 900 900],'Color','w');
% scatter([1:length(sublist)],d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',1.5,'SizeData',200)
text(1,1,sprintf('%2.1f ',d2))
xlim([0 length(sublist)+1])
ylim([.3 1.3])
axis square
xlabel('Subjects','FontSize',30,'FontName','Arial')
ylabel({'Surpression Time Spider'},'FontSize',30,'FontName','Arial')
set(gca,'YTick',[.4:.2:1.2],'FontSize',25,'FontName','Arial','LineWidth',1.5)
plot2svg(fullfile('..','newfigures','scheme.svg'));
%exportfig(gcf,fullfile('..','figures','bcfs_x_saf_2.eps'),'Color','gray','Resolution',800)
