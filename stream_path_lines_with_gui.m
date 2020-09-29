function [] = stream_path_lines_with_gui()
	density = 1;
	meshSize = 100;
	window = [-5 5, -5 5];
	tab = [];
	
	show_stream = [];
	show_path = [];
		
	buildGUI();
	calculate();
	
	function [] = buildGUI()
		

		f1 = figure(1);
		clf('reset')
		f1.MenuBar='none';
		f1.Name = 'Flow Configuration';
		f1.NumberTitle = 'off';

		tab = uitable('Parent',f1,'Units','normalized','Position',[0 0, 1 1],'FontSize',15);
		tab.ColumnName = {'Enable','     Flow Type     ','Strength','x/theta','y'};
		tab.ColumnFormat = {'logical',{'     -','Uniform','Source','Vortex','Doublet'},'numeric','numeric','numeric'};
		tab.ColumnEditable = true;
		tab.Data = repmat({false '     -' 0 0 0},30,1);
		tab.Data(1,:) = {true, 'Source',10, 0, 0};
		tab.Position(3) = tab.Extent(3)+0.028;
		tab.CellEditCallback = @tableEdit;

		q = tab.Position(3)+0.001;

		density_control = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.8 1-q 0.05],'String',num2str(density),'FontSize',11,'Callback',@densityChange); %#ok<NASGU>
		densityLbl = uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[q 0.85 1-q 0.05],'String','Line Density','FontSize',14); %#ok<NASGU>

		mesh_control = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.7 1-q 0.05],'String',num2str(meshSize),'FontSize',11,'Callback',@meshChange); %#ok<NASGU>
		meshLbl = uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[q 0.75 1-q 0.05],'String','Mesh Size','FontSize',14); %#ok<NASGU>
		
		windowEdit(1) = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.6 (1-q)/2 0.05],'String',num2str(window(1)),'FontSize',11,'Callback',{@windowChange 1});
		windowEdit(2) = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[(1+q)/2 0.6 (1-q)/2 0.05],'String',num2str(window(2)),'FontSize',11,'Callback',{@windowChange 2});
		windowEdit(3) = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[q 0.555 (1-q)/2 0.05],'String',num2str(window(3)),'FontSize',11,'Callback',{@windowChange 3});
		windowEdit(4) = uicontrol('Parent',f1,'Style','edit','Units','normalized','Position',[(1+q)/2 0.555 (1-q)/2 0.05],'String',num2str(window(4)),'FontSize',11,'Callback',{@windowChange 4}); %#ok<NASGU>
		windowLbl = uicontrol('Parent',f1,'Style','text','Units','normalized','Position',[q 0.65 1-q 0.05],'String','Window','FontSize',14); %#ok<NASGU>

		show_stream = uicontrol('Parent',f1,'Style','checkbox','Units','normalized','Position',[0.8 0.4, 0.2 0.05],'String','Streamlines?','Value',1);
		show_path = uicontrol('Parent',f1,'Style','checkbox','Units','normalized','Position',[0.8 0.35, 0.2 0.05],'String','Pathlines?');

		drawBtn = uicontrol('Parent',f1,'Style','pushbutton','Units','normalized','Position',[q 0.1, 1-q, 0.2],'String','Draw','Callback',@calculate,'FontUnits','normalized','FontSize',0.3); %#ok<NASGU>
	end
	
	% called whenever a new value is entered in the table
	function [] = tableEdit(~,evt)
		if evt.Indices(2) > 2 && isnan(evt.NewData)
			num = str2num(evt.EditData);
			if ~isempty(num) && ~isnan(num)
				tab.Data{evt.Indices(1), evt.Indices(2)} = num;
			else
				tab.Data{evt.Indices(1), evt.Indices(2)} = evt.PreviousData;
			end
		end
	end
	
	% updates the saved line density when user changes it in the UI
	function [] = densityChange(src,~)
		density = str2num(src.String);
	end
	
	% updates the saved mesh size when user changes it in the UI
	function [] = meshChange(src,~)
		meshSize = str2num(src.String);
	end
	
	% updates the saved x/y domain when user changes them in the UI
	function [] = windowChange(src,~,index)
		window(index) = str2num(src.String);
	end
	
	% calculates velocity potential u and v, then draws the flows
	function [] = calculate(~,~)
		uinf=[];	u_theta=[];
		m=[];		m_coord=[];
		k=[];		k_coord=[];
		dub=[];		dub_coord=[];
		for i = 1:length(tab.Data)
			if(tab.Data{i,1})
				switch tab.Data{i,2}
					case 'Uniform'
						uinf = [uinf, tab.Data{i,3}];
						u_theta = [u_theta, tab.Data{i,4}];
					case 'Source'
						m = [m, tab.Data{i,3}];
						m_coord = [m_coord; tab.Data{i,4} tab.Data{i,5}];
					case 'Vortex'
						k = [k tab.Data{i,3}];
						k_coord = [k_coord; tab.Data{i,4} tab.Data{i,5}];
					case 'Doublet'
						dub = [dub tab.Data{i,3}];
						dub_coord = [dub_coord; tab.Data{i,4} tab.Data{i,5}];
				end
			end
		end
		x = linspace(window(1),window(2),meshSize); %define x,y
		y = linspace(window(3),window(4),meshSize);
		
		u = zeros(length(x)); %initialize/preallocate
		v = u;

		for i = 1:length(x)
			for j = 1:length(y)
				for q = 1:length(uinf) % add potential from any uniform flows
					u(i,j) = u(i,j) + uinf(q)*cos(u_theta(q));
					v(i,j) = v(i,j) + uinf(q)*sin(u_theta(q));
				end
				for q = 1:length(m) % add potential from any source/sink flows
					u(i,j) = u(i,j) + 2*m(q)*(x(j)-m_coord(q,1))/((x(j)-m_coord(q,1))^2+(y(i)-m_coord(q,2))^2);
					v(i,j) = v(i,j) + 2*m(q)*(y(i)-m_coord(q,2))/((x(j)-m_coord(q,1))^2+(y(i)-m_coord(q,2))^2);
				end
				for q = 1:length(k) % add potential from any vortex flows
					u(i,j) = u(i,j) + k(q)*(k_coord(q,2)-y(i))/((x(j)-k_coord(q,1))^2+(y(i)-k_coord(q,2))^2);
					v(i,j) = v(i,j) + k(q)*(x(j)-k_coord(q,1))/((x(j)-k_coord(q,1))^2+(y(i)-k_coord(q,2))^2);
				end
				for q = 1:length(dub)
					u(i,j) = u(i,j) + dub(q)*((dub_coord(q,2)-y(i))^2-(dub_coord(q,1)-x(j))^2)/((dub_coord(q,1)-x(j))^2+(dub_coord(q,2)-y(i))^2)^2;
					v(i,j) = v(i,j) + -2*dub(q)*(x(j)-dub_coord(q,1))*(y(i)-dub_coord(q,2))/((dub_coord(q,1)-x(j))^2+(dub_coord(q,2)-y(i))^2)^2;
				end
			end
		end
		
		% draws the path/streamlines
		f2 = figure(2);
		clf('reset');
		f2.MenuBar = 'none';
		f2.Name = 'Flow';
		f2.NumberTitle = 'off';
		ax = axes('Parent',f2,'Position',[0.05 0.05, 0.9 0.9]);
		if(show_stream.Value || show_path.Value)
			if( show_stream.Value ) % plot streamlines
				h1 = streamslice(ax,x,y,u,v,density);
				set(h1,'Color', [0 0 1]);
			end
			if(show_path.Value) % plot pathlines, V=<-v,u>
				h2 = streamslice(ax,x,y,-v,u,density,'noarrows'); 
				set(h2,'Color', [1 0 0]);
			end
		end
		
		hold on
		if ~isempty(k)	% mark vortices with green dots
			plot(ax,k_coord(:,1),k_coord(:,2),'go','MarkerFaceColor','green')
		end
		if ~isempty(m)	% mark sources with magenta dots
			plot(ax,m_coord(:,1),m_coord(:,2),'mo','MarkerFaceColor','magenta')
		end
		if ~isempty(dub)	% mark doublets with cyan dots
			plot(ax,dub_coord(:,1),dub_coord(:,2),'co','MarkerFaceColor','cyan')
		end
		hold off
		
		axis equal
	end
end
