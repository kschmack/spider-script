sublist=[4:10,12:14,16:19];
excl=[8,15];%exclude subjects
accfile1=fullfile('..','spss','vis_accuracy_14sub_250vox_off_anatomicmask_spmT001.mat');
accfile2=fullfile('..','spss','invis_accuracy_14sub_250vox_off_anatomicmask_spmT001.mat');
conditions={'visible','invisible'};

load(accfile1);
data=[accuracy];
load(accfile2);
data=[data accuracy];
data(ismember(sublist,excl),:)=[];
data=data*100;

% plot
figure;set(gcf,'Color','w');
errorbar(mean(data),std(data)./sqrt(size(data,1)),' k.','MarkerSize',30);
hold on;
plot([0 1 2 3],[50 50 50 50],':k')
ylim([25 100]);
xlim([.5 2.5]);
ylabel('Decoding Accuracy (%)')
set(gca,'XTick',[1 2],'XTickLabel',conditions)
axis square

% ttest
for k=1:2
[h p(k) ci stats(k)]=ttest(data(:,k)-50);
fprintf('%s: t(%d)=%2.2f p=%2.4f (paired t-test against chance level)\n',conditions{k},stats(k).df,stats(k).tstat,p(k))
end


