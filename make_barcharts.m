function make_barcharts(y,group,label)


%Define a structure called "data" containing 5 categorical variables.
%Each is comprised of random numbers drawn from the normal distribution. 
%We add different offsets to each variable.
data.first=y(group==0);
data.second=y(group==1);

%Let's loop through the fields of the structure and calculate the mean 
%of each then plot these. There's an elegant way to do this:
f=fields(data); %makes a cell array of strings containing field names

for ii=1:length(f)
	mu(ii)=mean( data.(f{ii}) ); %note the brackets around the string
end

%plot!
H=bar(mu);

set(H,'FaceColor',[1,1,1]*0.5,'LineWidth',2) %Fill bars in gray

%Add labels on x axis. We can use the "f" variable made above
set(gca,'XTickLabel',label)


%Loop through our data structure and extract the SD:
for ii=1:length(f)
	sd(ii)=std( data.(f{ii}) )./sqrt(length(data.(f{ii}))) ; %note the brackets around the string
end

%We know the means, so we have enough information to add the error bars
hold on %without this the current plot will be wiped when we start plotting

for ii=1:length(f)
   plot([ii,ii],[mu(ii)-sd(ii),mu(ii)+sd(ii)],'-k','LineWidth',2)
end

hold off
