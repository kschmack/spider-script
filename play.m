clear;
for subject=4:7;
    effint=[];
    for run=1:8
        
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
        
        %load resfile
        s=load(['C:\Dokumente und Einstellungen\kschmack\Desktop\spider\data\spi_mri_0_00' num2str(subject) '\behav\spi_mri_0_00' num2str(subject) '_0' num2str(run) '.res']);
        
        
        % cut off scanner trigger
        starttime=s(1,4);
        s(s(:,3)==32,:)=[];
        
        % correct for start time
        s(:,[4:5,14:21])=s(:,[4:5,14:21])-starttime;
        
        % divide in results and trash
        trashindex=find(ismember(s(:,2),[2 4 6 8])&s(:,1)==2&s(:,3)~=31);
        trashindex=sort([trashindex; trashindex-1]);
        t=s(trashindex,:);
        s(trashindex,:)=[];
        
        % onset
        on=[];
        for vector=1:8
            index=(s(:,2)==vector&s(:,1)==1);
            onsets{vector}=s(index,14)./1000;
            on=[on;onsets{vector}];
        end
        index=(s(:,1)==1);
        onsets{9}=s(index,14)./1000;
        index=(t(:,1)==1);
        onsets{10}=t(index,14)./1000;
        on=[on;onsets{10}];

        % durations
        for vector=1:8
            index=(s(:,2)==vector&s(:,1)==1);
            durations{vector}=s(index,21)./1000-s(index,14)./1000+.8;
        end
        durations{9}=zeros(length(onsets{9}),1)+4.5;
        index=(t(:,1)==1);
        durations{10}=t(index,21)./1000-t(index,14)./1000+.8;
        
        % cut off empty cells
                all(run,:)=sort(on);        
        % compare runs
        
        %effint=[effint,eye(9),zeros(9,sum(cutindex)),zeros(9,6)];
        %filename=(['C:\Dokumente und Einstellungen\kschmack\Desktop\spider\data\spi_mri_0_00' num2str(subject) '\behav\behavfmridata' '_' num2str(run) '.mat']);
        %save(filename, 'names', 'onsets', 'durations')
    end
    contrastname=(['C:\Dokumente und Einstellungen\kschmack\Desktop\spider\data\spi_mri_0_00' num2str(subject) '\behav\effectsofinterest.mat']);
    save(contrastname, 'effint')
end