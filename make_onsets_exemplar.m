clear;
sublist=32%[4:10,12:23,25:26,30:39];
%exclude=[8,15,23,32];%8 objective over chance, 15 movement, 23 subjective 80% sehr sicher, 32 80% sicher

for subject=sublist
    %effint=[];effint_norp=[];
    runs=1:8;
    if subject==15; runs(end)=[]; end %no run 8 for subject 15:(
    allcontrast=cell(1,4);
    for run=runs        
        %% preliminaries
        %condition names
        connames{1}='visible flower';
        connames{2}='invisible flower';
        connames{3}='visible spider';
        connames{4}='invisible spider';
        
        %load resfile
        resfile=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',subject),'behav',sprintf('spi_mri_0_0%02.0f_%02.0f.res',subject,run));
        s=load(resfile);
        
        % cut off scanner trigger and empty row
        starttime=s(1,4);
        s(s(:,3)==32,:)=[];
        s(s(:,1)==0,:)=[];
        
        % correct for start time
        s(:,[4:5,14:21])=s(:,[4:5,14:21])-starttime;
        
       
        % divide in conditions and trash
        trashindex=find(ismember(s(:,2),[2 4 6 8])&s(:,1)==2&(s(:,3)==28|s(:,3)==29));
        trashindex=sort([trashindex; trashindex-1]);
        t=s(trashindex,:);
        s(trashindex,:)=[];
        
        %% stimuli
        % collapse sets into conditions
        s(:,2)=rem(s(:,2),4);
        s(s(:,2)==0,2)=4;
        
        
        % loop over conditions
        for con=1:4
            index=(s(:,2)==con&s(:,1)==1);
            names_condition=reshape(s(index,6:13),sum(index)*8,1);
            onsets_condition=reshape(s(index,14:21),sum(index)*8,1);
            
            %loop over exemplars
            for exemplar=1:16
                k=(con-1)*16+exemplar;
                names{k}=sprintf('%s %02.0f',connames{con},exemplar);
                onsets{k}=onsets_condition(names_condition==exemplar)/1000;
                
                %prepare contrast (autopad with zeros)
                contrast{con}(exemplar,k)=1;
                
            end
        end
        
        %% excluded invisible stimuli
        if ~isempty(t)
            % collapse sets into conditions
            t(:,2)=rem(t(:,2),4);
            t(t(:,2)==0,2)=4;
            
            
            % loop over conditions
            for excon=unique(t(:,2))'
                index=(t(:,2)==excon&t(:,1)==1);
                names_condition=reshape(t(index,6:13),sum(index)*8,1);
                onsets_condition=reshape(t(index,14:21),sum(index)*8,1);
                
                %loop over exemplars
                for exemplar=1:16
                    names{end+1}=sprintf('trash %s %02.0f',connames{excon},exemplar);
                    onsets{end+1}=onsets_condition(names_condition==exemplar)/1000;
                end
            end
        end

        %% awareness assessment and button presses
        names{end+1}='display AFC';
        onsets{end+1}=s(s(:,1)==1,4)./1000;
        names{end+1}='display CONF';
        onsets{end+1}=s(s(:,1)==2,4)./1000;
        names{end+1}='button presses';
        onsets{end+1}=s(:,5)./1000;
        
        %% right padded zeros to contrast
        conlength=length(onsets);
        contrast=cellfun(@(x) [x zeros(16,conlength+6-size(x,2))],contrast,'uni',0);

        %% cut off empty cells
        cutindex=cellfun(@isempty,onsets);
        onsets(cutindex)=[];
        names(cutindex)=[];
        contrast=cellfun(@(x) x(:,[~cutindex true(1,6)]),contrast,'uni',0);
        
        %% make zero-durations
        durations=cellfun(@(x) zeros(1,x),cellfun(@length,onsets,'uni',0),'uni',0);
                
        %% concatenate contrast
        allcontrast=cellfun(@(x,y) [x,y],allcontrast,contrast,'uni',0);
        
        %% save resfile
        filename=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',subject),'behav',sprintf('eventfmri_%01.0f.mat',run));
        save(filename, 'names', 'onsets', 'durations')
        clear('names', 'onsets', 'durations','contrast')
    end
    contrastname=fullfile('..','data',sprintf('spi_mri_0_0%02.0f',subject),'behav','exemplar_contrast.mat');
    save(contrastname, 'allcontrast','connames')
end