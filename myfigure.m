function f=myfigure(siz1,siz2)
if nargin<1
    siz1=.5;
end
if nargin<2
    siz2=siz1;
end
sz=get( 0, 'ScreenSize' );
%sz(1)=sz(3);sz(2)=sz(4);
%sz=sz.*siz;
sz(1)=sz(3)-siz1*sz(3)-100;
sz(2)=sz(4)-siz2*sz(4)-100;
sz(3)=siz1*sz(3);
sz(4)=siz2*sz(4);
f=figure('Position',sz);
set(f,'Color','k')
set(gca,'Color','k','XColor','w','YColor','w','ZColor','w','FontName','Arial','FontSize',16)
set(gca,'DefaulttextColor','w','DefaulttextFontName','Arial','DefaulttextFontSize',16)
set(get(gca,'Title'),'Color','w')
hold on


