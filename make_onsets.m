clear;
for subject=33:39;%23%[4:9,12:23,25:26,30:32];
    effint=[];effint_norp=[];
    runs=1:8;
    if subject==15; runs(end)=[]; end %no run 8 for subject 15:(
    for run=runs        
        names{1}='visible flower set 1';onsets{1}=[]; durations{1}=[];
        names{2}='invisible flower set 1';onsets{2}=[]; durations{2}=[];
        names{3}='visible spider set 1';onsets{3}=[]; durations{3}=[];
        names{4}='invisible spider set 1';onsets{4}=[]; durations{4}=[];
        names{5}='visible flower set 2'; onsets{5}=[]; durations{5}=[];
        names{6}='invisible flower set 2'; onsets{6}=[]; durations{6}=[];
        names{7}='visible spider set 2'; onsets{7}=[]; durations{7}=[];
        names{8}='invisible spider set 2'; onsets{8}=[]; durations{8}=[];
        names{9}='awareness assessment'; onsets{9}=[]; durations{9}=[];
        names{10}='trash regressor'; onsets{10}=[]; durations{10}=[];
        namesofinterest=names(1:9);
        
        %load resfile
        resfile=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',subject),'behav',sprintf('spi_mri_0_0%02.0f_%02.0f.res',subject,run));
        s=load(resfile);
        
        
        % cut off scanner trigger
        starttime=s(1,4);
        s(s(:,3)==32,:)=[];
        
        % correct for start time
        s(:,[4:5,14:21])=s(:,[4:5,14:21])-starttime;
        
        % divide in results and trash
        trashindex=find(ismember(s(:,2),[2 4 6 8])&s(:,1)==2&(s(:,3)==28|s(:,3)==29));
        trashindex=sort([trashindex; trashindex-1]);
        t=s(trashindex,:);
        s(trashindex,:)=[];
        
        % onsets
        for vector=1:8
            index=(s(:,2)==vector&s(:,1)==1);
            onsets{vector}=s(index,14)./1000;
        end
        index=(s(:,1)==1);
        onsets{9}=s(index,14)./1000;
        index=(t(:,1)==1);
        onsets{10}=t(index,14)./1000;
        
        % durations
        for vector=1:8
            index=(s(:,2)==vector&s(:,1)==1);
            durations{vector}=s(index,21)./1000-s(index,14)./1000+.8;
        end
        durations{9}=zeros(length(onsets{9}),1)+4.5;
        index=(t(:,1)==1);
        durations{10}=t(index,21)./1000-t(index,14)./1000+.8;
        
        % cut off empty cells
        cutindex=cellfun(@isempty,durations);
        if sum(cutindex)>0
            for k=1:sum(cutindex)
                cutindex2=find(cutindex);
                fprintf('subject %d run %d cut %s\n',subject,run,names{cutindex2(k)})
            end
        end
        durations(cutindex)=[];
        onsets(cutindex)=[];
        names(cutindex)=[];
        
        tmp=eye(9);
        nointerestvector=~ismember(namesofinterest,names);
        if sum(nointerestvector)>0
        tmp(nointerestvector,:)=0;
        tmp(:,nointerestvector)=[];
        end
        effint=[effint,tmp,zeros(9,sum(ismember(names,{'trash regressor'}))),zeros(9,6)];
                effint_norp=[effint_norp,tmp,zeros(9,sum(ismember(names,{'trash regressor'})))];
                
        %load resfile
        filename=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',subject),'behav',sprintf('behavfmridata_%01.0f.mat',run));
        save(filename, 'names', 'onsets', 'durations')
    end
    contrastname=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',subject),'behav','effectsofinterest.mat');
    save(contrastname, 'effint')
    contrastname2=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',subject),'behav','effectsofinterest_norp.mat');
    save(contrastname2, 'effint_norp')

end