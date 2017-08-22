clear;

%matfile='/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_exemplar_vector_rad08_smo03/visspi/SPM.mat';
%c={[-32 -50 -19]'};
%label={'left LOC'};


matfile='/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_realign_vector_rad08_smo03/vis/SPM.mat';

c={[6 -56 7]'};
label={'V1'};


load(matfile);
filelist=SPM.xY.P;
mm2vox=SPM.xY.VY(1).mat;%affine transformation mm 2 voxels
vox2mm=inv(mm2vox);%affine transformation vox 2 mm

for cic=1:length(c)
    center_xyz=c{cic};
    center = vox2mm*[center_xyz;1]; 
    center = round(center(1:3));

    radius=.5;
    for sub=1:length(filelist)
        [x y z]=meshgrid(1:100,1:100,1:100);
        XYZ=[x(:)';y(:)';z(:)'];
        O=ones(1,length(XYZ));
        o =  (sum((XYZ-center*O).^2) <= radius^2);
        mxyz=XYZ(:,o);
        %mxyzmm=vox2mm*XYZ(:,o);
        Vim=spm_vol(filelist{sub});
        [T]=spm_get_data(Vim,mxyz);
        data{sub}=T;
        xyz{sub}=mxyz;
        %xyzmm{sub}=mxyzmm;
            str=regexp(filelist{sub},'\d\d\d.nii','match');
            sublist(sub)=str2num(str{1}(1:3));
    end
    acc=cell2mat(data)'+50;
    %acc=reshape(cell2mat(data),length(data),length(filelist))
    
    

    questfile=fullfile('..','spss','quest_cfs.xls');
    [questdata questlegende]=xlsread(questfile);
    questdata=questdata(ismember(questdata(:,1),sublist),:);
    saf=questdata(:,strcmp(questlegende,'SAF'));
   
     
    d1=saf;
    d2=acc;
    f=figure;
    set(f,'Position',[50 250 600 600],'Color','w');
    scatter(d1,d2,' ko','MarkerEdgeColor',[1 1 1],'MarkerFaceColor',[.4 .4 .4],'LineWidth',1.5,'SizeData',200)
    xlim([0 100])
%ylim([3.8 11.2])
ylim([35 70])
    axis square
    h=lsline;
    set(h,'Color','k','LineStyle','-','LineWidth',1.5);
    xlabel('Spider Phobia Score','FontSize',15,'FontName','Helvetica')
    ylabel({sprintf('Exemplar Decoding Accuracy \nat %s%2.0f %2.0f %2.0f%s mm','[',center_xyz,']')},'FontSize',15,'FontName','Helvetica')
    set(gca,'YTick',[40:10:70],'FontSize',15,'FontName','Helvetica','LineWidth',1.5)
    set(gca,'XTick',[0:20:100],'FontSize',15,'FontName','Helvetica','LineWidth',1.5)
    set(gcf,'PaperPositionMode','auto')
    set(gca,'FontSize',15,'FontName','Helvetica','LineWidth',1.5)
    
    text(80,49,'chance level','FontSize',12,'FontName','Helvetica')
    line([0 100],[50 50],'Color','k','LineStyle',':','LineWidth',1.5)

    filename=sprintf('/Volumes/ZAFANDEL/projects/AngstEssenSachenAuf/figures/viscat_x_SAF_corrplot_%s.svg',label{cic});
    plot2svg(filename);
    exportfig(gcf,sprintf('/Volumes/ZAFANDEL/projects/AngstEssenSachenAuf/figures/viscat_x_SAF_corrplot_%s.eps',label{cic}),'Color','gray','Resolution',800)

end

