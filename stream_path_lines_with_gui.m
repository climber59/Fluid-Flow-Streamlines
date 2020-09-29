clc


% t.Data = importdata('circle.mat');

if(~exist('f1','var') || ~ishandle(f1))
	clear
	
	density = 1;
	numPoints = 100;
	window = [-5 5, -5 5];
	
	f1 = figure(1);
	clf
	f1.MenuBar='none';
	f1.Name = 'Flow Configuration';
	f1.NumberTitle = 'off';

	t = uitable('Parent',f1,'Units','normalized','Position',[0 0, 1 1],'FontSize',15);
	t.ColumnName = {'     Flow Type     ','Strength','x/theta','y','Show'};
	t.ColumnFormat = {{'None','Uniform','Source','Vortex','Doublet'},'numeric','numeric','numeric','logical'};
	t.ColumnEditable = true;
	t.Data = {'Source',10, 0, 0 true; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false; 'None' 0 0 0 false};
	t.Position(3) = t.Extent(3)+0.028;
	
	q = t.Position(3)+0.001;
	
	density_control = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.8 1-q 0.05],'String',num2str(density),'FontSize',11);
	density_control.Callback = 'density = str2double(density_control.String); ';
	uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[q 0.85 1-q 0.05],'String','Line Density','FontSize',14);

	points_control = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.7 1-q 0.05],'String',num2str(numPoints),'FontSize',11);
	points_control.Callback = 'numPoints = str2double(points_control.String); ';
	uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[q 0.75 1-q 0.05],'String','Mesh Size','FontSize',14);
	
	window_1 = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.6 (1-q)/2 0.05],'String',num2str(window(1)),'FontSize',11);
	window_2 = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[(1+q)/2 0.6 (1-q)/2 0.05],'String',num2str(window(2)),'FontSize',11);
	window_3 = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.555 (1-q)/2 0.05],'String',num2str(window(3)),'FontSize',11);
	window_4 = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[(1+q)/2 0.555 (1-q)/2 0.05],'String',num2str(window(4)),'FontSize',11);
	window_1.Callback = 'window(1) = str2double(window_1.String); ';
	window_2.Callback = 'window(2) = str2double(window_2.String); ';
	window_3.Callback = 'window(3) = str2double(window_3.String); ';
	window_4.Callback = 'window(4) = str2double(window_4.String);';
	uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[q 0.65 1-q 0.05],'String','Window','FontSize',14);
	
	show_stream = uicontrol('Parent',f1,'Style','checkbox','Units','normalized','Position',[0.8 0.4, 0.2 0.05],'String','Streamlines?');
	show_path = uicontrol('Parent',f1,'Style','checkbox','Units','normalized','Position',[0.8 0.35, 0.2 0.05],'String','Pathlines?');
	
	update = uicontrol('Parent',f1,'Style','pushbutton','Units','normalized','Position',[q 0.1, 1-q, 0.2],'String','Draw','Callback','eval(filename);','FontUnits','normalized','FontSize',0.3);
	
	
end	
%%
filename = mfilename;

uinf=[];	u_theta=[];
m=[];		m_coord=[];
k=[];		k_coord=[];
dub=[];		dub_coord=[];
for i = 1:length(t.Data)
	if(t.Data{i,5})
		switch t.Data{i,1}
			case 'Uniform'
				uinf = [uinf, t.Data{i,2}];
				u_theta = [u_theta, t.Data{i,3}];
			case 'Source'
				m = [m, t.Data{i,2}];
				m_coord = [m_coord; t.Data{i,3} t.Data{i,4}];
			case 'Vortex'
				k = [k t.Data{i,2}];
				k_coord = [k_coord; t.Data{i,3} t.Data{i,4}];
			case 'Doublet'
				dub = [dub t.Data{i,2}];
				dub_coord = [dub_coord; t.Data{i,3} t.Data{i,4}];
		end
	end
end

x_a=linspace(window(1),window(2),numPoints); %define x,y
y_a=linspace(window(3),window(4),numPoints);

u=zeros(length(x_a)); v=u; %initialize/preallocate
j=1;

for x=x_a
    i=1;
    for y=y_a
        for q=1:length(uinf) % add potential from any uniform flows
            u(i,j) = u(i,j) + uinf(q)*cos(u_theta(q));
            v(i,j) = v(i,j) + uinf(q)*sin(u_theta(q));
        end
		for q=1:length(m) % add potential from any source/sink flows
            u(i,j) = u(i,j) + 2*m(q)*(x-m_coord(q,1))/((x-m_coord(q,1))^2+(y-m_coord(q,2))^2);
            v(i,j) = v(i,j) + 2*m(q)*(y-m_coord(q,2))/((x-m_coord(q,1))^2+(y-m_coord(q,2))^2);
		end
		for q=1:length(k) % add potential from any votex flows
            u(i,j) = u(i,j) + k(q)*(k_coord(q,2)-y)/((x-k_coord(q,1))^2+(y-k_coord(q,2))^2);
            v(i,j) = v(i,j) + k(q)*(x-k_coord(q,1))/((x-k_coord(q,1))^2+(y-k_coord(q,2))^2);
		end
		for q=1:length(dub)
			u(i,j) = u(i,j) + dub(q)*((dub_coord(q,2)-y)^2-(dub_coord(q,1)-x)^2)/((dub_coord(q,1)-x)^2+(dub_coord(q,2)-y)^2)^2;
			v(i,j) = v(i,j) + -2*dub(q)*(x-dub_coord(q,1))*(y-dub_coord(q,2))/((dub_coord(q,1)-x)^2+(dub_coord(q,2)-y)^2)^2;
		end
        i=i+1;
    end
    j=j+1;
end

f2 = figure(2);
clf
f2.MenuBar = 'none';
f2.Name = 'Flow';
f2.NumberTitle = 'off';
ax = axes('Parent',f2,'Position',[0.05 0.05, 0.9 0.9]);
if(show_stream.Value || show_path.Value)
	if( show_stream.Value ) % plot streamlines
		streamslice(ax,x_a,y_a,u,v,density);
	end
	if(show_path.Value) % plot pathlines, V=<-v,u>
		h2 = streamslice(ax,x_a,y_a,-v,u,density,'noarrows'); 
		set(h2,'Color',[1 0 0])
	end
end

hold on
for i=1:length(k)	% mark vortex with green dot
	plot(ax,k_coord(i,1),k_coord(i,2),'go','MarkerFaceColor','green')
end
for i=1:length(m)	% mark source with magenta dot
	plot(ax,m_coord(i,1),m_coord(i,2),'mo','MarkerFaceColor','magenta')
end
for i=1:length(dub)	% mark source with magenta dot
	plot(ax,dub_coord(i,1),dub_coord(i,2),'mo','MarkerFaceColor','cyan')
end
hold off
axis equal
