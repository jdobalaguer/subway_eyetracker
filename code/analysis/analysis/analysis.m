classdef analysis < handle
    % class for analyse the data
    
    properties
        % main maps
        mainmap_prename
        mainmap_dir
        % sequence
        seq_prename
        seq_dir
        % player files
        file
        
        % gui parameters
        gui_background
        gui_position
        gui_size
        gui_space
        gui_heightlabels
        gui_height_title
        gui_space_figure
        gui_height_figurebutton
        gui_length_figurebutton
        gui_space_data
        gui_height_datapopup
        gui_height_datacheckbox
        gui_space_plot
        gui_height_plotlabel
        gui_length_plotlabel
        gui_height_plotcheckbox
        gui_height_plotlistbox
        gui_height_plottextbox
        gui_height_plotpushutton
        gui_length_plotpushbutton
        gui_height_doit
        gui_length_doit
        % gui objects
        obj_window
        obj_title
        obj_figure
        obj_figure_list
        obj_figure_hold
        obj_data
        obj_data_criterion
        obj_data_parpanel
        obj_data_parchecks
        obj_plot
        obj_plot_minimum
        obj_plot_average
        obj_plot_maximum
        obj_plot_fillstd
        obj_plot_regression
        obj_plot_list
        obj_plot_nbutton
        obj_plot_xbutton
        obj_plot_ybutton
        obj_plot_ntext
        obj_plot_xtext
        obj_plot_ytext
        obj_plot_aw
        obj_plot_add
        obj_plot_del
        obj_doit
        % gui options
        opt_figure_current
        opt_figure_figures
        opt_figure_curvecolor
        opt_figure_filltransparency
        opt_figure_curveindex
        opt_data_criterion
        opt_data_bysequence
        opt_data_byparticipant
        opt_plot_minmax
        opt_plot_value
        opt_plot_equations
        % values
        data
        variables
        doit_values
        
        % analysis writer
        analysis_writer
    end
    
    
    methods
        % constructor
        function obj = analysis()
            % main map
            obj.mainmap_prename = 'map_';
            obj.mainmap_dir = 'maps';
            
            % sequence
            obj.seq_prename = 'seq_';
            obj.seq_dir = 'sequences';
            
            % file
            obj.file = main_file();
            
            % gui parameters
            obj.gui_background = [.8 .8 .8];
            obj.gui_position = [0,0];
            obj.gui_size = [350,950];
            obj.gui_space = 10;
            obj.gui_heightlabels = 10;
            obj.gui_height_title = 15;
            obj.gui_space_figure = 7.5;
            obj.gui_height_figurebutton = 24;
            obj.gui_length_figurebutton = 40;
            obj.gui_space_data = 7.5;
            obj.gui_height_datapopup = 24;
            obj.gui_height_datacheckbox = 24;
            obj.gui_space_plot = 7.5;
            obj.gui_height_plotlabel = 24;
            obj.gui_length_plotlabel = 24;
            obj.gui_height_plotcheckbox = 24;
            obj.gui_height_plotlistbox = 100;
            obj.gui_height_plottextbox = 24;
            obj.gui_height_plotpushutton = 24;
            obj.gui_length_plotpushbutton = 40;
            obj.gui_height_doit = 30;
            obj.gui_length_doit = 50;
            
            % options
            obj.opt_figure_current = 0;
            obj.opt_figure_figures = [];
            obj.opt_figure_curvecolor = { ...
                [0 0 1], ... b
                [0 1 0], ... g
                [1 0 0], ... r
                [0 1 1], ... c
                [1 0 1], ... m
                [1 1 0], ... y
                [0 0 0], ... k
                };
            obj.opt_figure_filltransparency = .85;
            obj.opt_figure_curveindex = [];
            obj.opt_data_criterion = 1;
            obj.opt_data_bysequence = [];
            obj.opt_data_byparticipant = [];
            obj.opt_plot_minmax = [0 0 0 0 0];
            obj.opt_plot_value = 0;
            obj.opt_plot_equations = {};
            
            % values
            obj.data = struct();
            obj.variables = {};
            obj.doit_values = {};
            
            % gui start
            obj.gui_start();
            
            % analysis writer
            obj.analysis_writer = analysis_writer(obj);
            set(obj.analysis_writer.obj_window, 'Visible', 'off');
        end
        
        % GUI =============================================================
        % drawing ---------------------------------------------------------
        % draw the gui
        function obj = gui_start(obj)
            % WINDOW
            obj.obj_window = figure(...
                'Color',obj.gui_background,...
                'Name','analysis user interface',...
                'Units','pixels',...
                'Position',[obj.gui_position,obj.gui_size],...
                'MenuBar','no',...
                'Resize','off',...
                'CloseRequestFcn',@obj.closed_window...
            );
            
            % TITLE
            % title
            panel_pos = [   obj.gui_space ...
                            obj.gui_size(2)-obj.gui_space-obj.gui_height_title ];
            panel_size = [  obj.gui_size(1)-2*obj.gui_space ...
                            obj.gui_height_title ];
            uicontrol(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'Style','text',...
                'Units','pixel',...
                'Position', [panel_pos panel_size],...
                'String', ' analysis user interface');
            
            % FIGURE
            % figure panel
            panel_size(2) = obj.gui_heightlabels + obj.gui_height_figurebutton + 2*obj.gui_space_figure;
            panel_pos(2) = panel_pos(2)-panel_size(2)-obj.gui_space;
            obj.obj_figure = uipanel(...
                'Parent',obj.obj_window,...
                'Title',' figure ',...
                'BackgroundColor',obj.gui_background,...
                'Units','pixels',...
                'Position',[panel_pos panel_size]...
            );
            % figure popup list
            item_pos =  [   obj.gui_space_figure...
                            obj.gui_space_figure ];
            item_size = [   panel_size(1)-3*obj.gui_space_figure-obj.gui_length_figurebutton...
                            obj.gui_height_figurebutton ];
            obj.obj_figure_list = uicontrol(...
                'Parent',obj.obj_figure,...
                'Style','popup',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String',{' new figure'},...
                'Callback', @obj.set_opt_figure_current...
            );
            % hold toggle button
            item_pos = [item_pos(1)+item_size(1)+obj.gui_space_figure item_pos(2)];
            item_size = [obj.gui_length_figurebutton obj.gui_height_figurebutton];
            obj.obj_figure_hold = uicontrol(...
                'Parent',obj.obj_figure,...
                'Style','togglebutton',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'Visible','off',...
                'String','hold'...
            );
            
            % DATA
            % data panel
            obj.obj_data = uipanel(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'Title',' data ',...
                'Units','pixels');
            % criterion popup list
            item_pos =  [   obj.gui_space_data...
                            obj.gui_space_data ];
            item_size = [   panel_size(1)-2*obj.gui_space_data...
                            obj.gui_height_datapopup ];
            obj.obj_data_criterion = uicontrol(...
                'Parent',obj.obj_data,...
                'Style','popup',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String',' all| by participant',...
                'Value',obj.opt_data_criterion,...
                'Callback', @obj.set_opt_data_criterion...
            );
            % data participants layout
            nb_participants = obj.par_created('human');
            layout_size = [item_size(1) obj.gui_space_data + nb_participants*obj.gui_height_datacheckbox];
            layout_pos = item_pos;
            obj.obj_data_parpanel = uipanel(...
                'Parent',obj.obj_data,...
                'BackgroundColor',obj.gui_background,...
                'BorderType','no',...
                'Units','pixel',...
                'Position', [layout_pos layout_size],...
                'Visible','off' ...
            );
            obj.opt_data_byparticipant = zeros(1,nb_participants);
            % by participant checkboxes
            layout_pos = [0 layout_size(2)-obj.gui_space_data-obj.gui_height_datacheckbox];
            layout_size = [layout_size(1) obj.gui_height_datacheckbox];
            obj.obj_data_parchecks = [];
            for i_par = 1:nb_participants
                check_box = uicontrol(...
                    'Parent',obj.obj_data_parpanel,...
                    'BackgroundColor',obj.gui_background,...
                    'Style','checkbox',...
                    'Units','pixel',...
                    'Position', [layout_pos layout_size],...
                    'String',[' participant',num2str(i_par)],...
                    'Callback', @obj.set_opt_data_byparticipant...
                );
                obj.obj_data_parchecks = [obj.obj_data_parchecks check_box];
                layout_pos(2) = layout_pos(2)-obj.gui_height_datacheckbox;
            end
            % set the position of the data panel
            panel_size(2) = obj.gui_heightlabels + obj.gui_height_datapopup + 2*obj.gui_space_data;
            switch obj.opt_data_criterion
                case 2
                    height_panel = get(obj.obj_data_parpanel,'Position');
                    height_panel = height_panel(4);
                    panel_size(2) = panel_size(2)+obj.gui_space_data+height_panel;
                case 3
                    height_panel = get(obj.obj_data_parpanel,'Position');
                    height_panel = height_panel(4);
                    panel_size(2) = panel_size(2)+obj.gui_space_data+height_panel;
            end
            panel_pos(2) = panel_pos(2)-panel_size(2)-obj.gui_space;
            set(obj.obj_data,'Position',[panel_pos panel_size]);
            
            % PLOT
            % plot panel
            panel_size(2) = obj.gui_heightlabels + 6*obj.gui_space_plot + 5*obj.gui_height_plotcheckbox + obj.gui_height_plotlistbox + 3*obj.gui_height_plotlabel;
            panel_pos(2) = panel_pos(2)-panel_size(2)-obj.gui_space;
            obj.obj_plot = uipanel(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'Title',' plot ',...
                'Units','pixel',...
                'Position',[panel_pos panel_size]);
            % min checkbox
            item_pos =  [   obj.gui_space_plot...
                            panel_size(2) - obj.gui_heightlabels - obj.gui_space_plot - obj.gui_height_plotcheckbox ];
            item_size = [   panel_size(1) - 2*obj.gui_space_plot...
                            obj.gui_height_plotcheckbox ];
            obj.obj_plot_minimum = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','checkbox',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String',' minimum',...
                'Callback', @obj.set_opt_plot_min...
            );
            % average checkbox
            item_pos(2) = item_pos(2) - obj.gui_height_plotcheckbox;
            obj.obj_plot_average = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','checkbox',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String',' average',...
                'Callback', @obj.set_opt_plot_av...
            );
            % max checkbox
            item_pos(2) = item_pos(2) - obj.gui_height_plotcheckbox;
            obj.obj_plot_maximum = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','checkbox',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String',' maximum',...
                'Callback', @obj.set_opt_plot_max...
            );
            % fillstd checkbox
            item_pos(2) = item_pos(2) - obj.gui_height_plotcheckbox;
            obj.obj_plot_fillstd = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','checkbox',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String',' fill std',...
                'Callback', @obj.set_opt_plot_fillstd...
            );
            % regression checkbox
            item_pos(2) = item_pos(2) - obj.gui_height_plotcheckbox;
            obj.obj_plot_regression = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','checkbox',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String',' regression',...
                'Callback', @obj.set_opt_plot_regression...
            );
            % expressions listbox
            item_size(1) = (panel_size(1) - 2*obj.gui_space_plot);
            item_size(2) = obj.gui_height_plotlistbox;
            item_pos(2) = item_pos(2) - obj.gui_space_plot - obj.gui_height_plotlistbox;
            obj.obj_plot_list = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','listbox',...
                'Units','pixel',...
                'Position', [item_pos , item_size],...
                'Callback', @obj.set_opt_plot_value...
            );
            % update expressions list
            obj.gui_updatelist();
            % n label
            item_size(1) = obj.gui_length_plotlabel;
            item_size(2) = obj.gui_height_plotlabel;
            item_pos(1) = obj.gui_space_plot;
            item_pos(2) = item_pos(2) - obj.gui_space_plot-obj.gui_height_plotlabel;
            obj.obj_plot_nbutton = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'n' ...
            );
            item_pos(1) = item_pos(1) + item_size(1) + obj.gui_space;
            item_size(1) = panel_size(1) - 4*obj.gui_space_plot - obj.gui_length_plotpushbutton -obj.gui_height_plotlabel;
            % name entry textbox
            obj.obj_plot_ntext = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','edit',...
                'Units','pixel',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size]...
            );
            % analysis_writer pushbutton
            item_pos(1) = item_pos(1)+item_size(1)+obj.gui_space_plot;
            item_size(1) = obj.gui_length_plotpushbutton;
            obj.obj_plot_aw = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','togglebutton',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String','AW',...
                'Callback', @obj.set_opt_plot_aw...
            );
            % x label
            item_size(1) = obj.gui_length_plotlabel;
            item_size(2) = obj.gui_height_plotlabel;
            item_pos(1) = obj.gui_space_plot;
            item_pos(2) = item_pos(2) - obj.gui_space_plot-obj.gui_height_plotlabel;
            obj.obj_plot_xbutton = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'x' ...
            );
            item_pos(1) = item_pos(1) + item_size(1) + obj.gui_space;
            item_size(1) = panel_size(1) - 4*obj.gui_space_plot - obj.gui_length_plotpushbutton -obj.gui_height_plotlabel;
            % x expression entry textbox
            obj.obj_plot_xtext = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','edit',...
                'Units','pixel',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size]...
            );
            % add expression pushbutton
            item_pos(1) = item_pos(1)+item_size(1)+obj.gui_space_plot;
            item_size(1) = obj.gui_length_plotpushbutton;
            obj.obj_plot_add = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String','add',...
                'Callback', @obj.set_opt_plot_add...
            );
            % y label
            item_size(1) = obj.gui_length_plotlabel;
            item_size(2) = obj.gui_height_plotlabel;
            item_pos(1) = obj.gui_space_plot;
            item_pos(2) = item_pos(2) - obj.gui_space_plot-obj.gui_height_plotlabel;
            obj.obj_plot_ybutton = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'y' ...
            );
            item_pos(1) = item_pos(1) + item_size(1) + obj.gui_space;
            item_size(1) = panel_size(1) - 4*obj.gui_space_plot - obj.gui_length_plotpushbutton -obj.gui_height_plotlabel;
            % y expression entry textbox
            obj.obj_plot_ytext = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','edit',...
                'Units','pixel',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size]...
            );
            % del expression pushbutton
            item_pos(1) = item_pos(1)+item_size(1)+obj.gui_space_plot;
            item_size(1) = obj.gui_length_plotpushbutton;
            obj.obj_plot_del = uicontrol(...
                'Parent',obj.obj_plot,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String','del',...
                'Callback', @obj.set_opt_plot_del...
            );

            % DO IT
            % do it button
            panel_size(2) = obj.gui_height_doit;
            panel_pos(2) = panel_pos(2)-panel_size(2)-obj.gui_space;
            panel_size(1) = obj.gui_length_doit;
            panel_pos(1) = .5*(obj.gui_size(1)-obj.gui_length_doit);
            obj.obj_doit = uicontrol(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Units','pixel',...
                'Position', [panel_pos panel_size],...
                'String',' do it!',...
                'Callback', @obj.do_it...
            );
        end

        % update data panel position/size
        function obj = gui_updatedata(obj)
            % change panel position and size
            data_pos = get(obj.obj_data,'Position');
            data_pos(2) = data_pos(2)+data_pos(4);
            data_pos(4) = obj.gui_heightlabels + 2*obj.gui_space_data + obj.gui_height_datapopup;
            switch obj.opt_data_criterion
                case 2
                    height_panel = get(obj.obj_data_parpanel,'Position');
                    height_panel = height_panel(4);
                    data_pos(4) = data_pos(4) + height_panel;
            end
            data_pos(2) = data_pos(2)-data_pos(4);
            set(obj.obj_data,'Position',data_pos);
            % update criterion position
            criterion_pos = get(obj.obj_data_criterion,'Position');
            criterion_pos(2) = data_pos(4)-obj.gui_heightlabels-obj.gui_space_data-obj.gui_height_datapopup;
            set(obj.obj_data_criterion,'Position',criterion_pos);
            % make sequence/participants panel visible/invisible
            switch obj.opt_data_criterion
                case 1
                    set(obj.obj_data_parpanel,'Visible','off');
                case 2
                    set(obj.obj_data_parpanel,'Visible','on');
            end
        end
        
        % callback methods ------------------------------------------------
        function obj = set_opt_figure_current(obj,gui_obj,~)
            fig_val = get(gui_obj,'Value');
            if fig_val > 1
                obj.opt_figure_current = obj.opt_figure_figures(fig_val-1);
            else
                obj.opt_figure_current = 0;
            end
        end
        function obj = closed_figure(obj,gui_obj,~)
            % find figure index
            i_fig = find(obj.opt_figure_figures==gui_obj);
            % variables
                % color index
            obj.opt_figure_curveindex(i_fig) = [];
                % set current figure variable
            if i_fig > 1
                obj.opt_figure_current = obj.opt_figure_figures(i_fig);
            else
                obj.opt_figure_current = 0;
            end
                % remove figure from list variable
            obj.opt_figure_figures(i_fig) = [];
            % objects
                % list
            set(obj.obj_figure_list,'Value',i_fig);
            figures_list = get(obj.obj_figure_list,'String');
            figures_list(i_fig+1) = [];
            set(obj.obj_figure_list,'String',figures_list);
            % delete object
            delete(gui_obj);
        end
        function obj = closed_window(obj,gui_obj,~)
            % figures
            for h_fig = obj.opt_figure_figures
                delete(h_fig);
            end
            obj.opt_figure_current = 0;
            obj.opt_figure_figures = [];
            set(obj.obj_figure_list,'String',' new figure');
            % analysis writer
            if ~isempty(obj.analysis_writer)
                delete(obj.analysis_writer.obj_window);
                delete(obj.analysis_writer);
            end
            % window
            delete(gui_obj);
            delete(obj);
        end
        function obj = set_opt_data_criterion(obj,gui_obj,~)
            obj.opt_data_criterion = get(gui_obj,'Value');
            obj.gui_updatedata();
            obj.gui_updateplot();
            obj.gui_updatedoit();
        end
        function obj = set_opt_data_byparticipant(obj,gui_obj,~)
            i_par = (gui_obj==obj.obj_data_parchecks);
            v_par = get(obj.obj_data_parchecks(i_par),'Value');
            obj.opt_data_byparticipant(i_par) = v_par;
        end
        function obj = set_opt_plot_min(obj,gui_obj,~)
            obj.opt_plot_minmax(1) = get(gui_obj,'Value');
        end
        function obj = set_opt_plot_av(obj,gui_obj,~)
            obj.opt_plot_minmax(2) = get(gui_obj,'Value');
        end
        function obj = set_opt_plot_max(obj,gui_obj,~)
            obj.opt_plot_minmax(3) = get(gui_obj,'Value');
        end
        function obj = set_opt_plot_fillstd(obj,gui_obj,~)
            obj.opt_plot_minmax(4) = get(gui_obj,'Value');
        end
        function obj = set_opt_plot_regression(obj,gui_obj,~)
            obj.opt_plot_minmax(5) = get(gui_obj,'Value');
        end
        function obj = set_opt_plot_value(obj,gui_obj,~)
            obj.opt_plot_value = get(gui_obj,'Value');
            set(obj.obj_plot_list,'Value',obj.opt_plot_value);
        end
        function obj = set_opt_plot_aw(obj,~,~)
            if get(obj.obj_plot_aw,'Value');
                set(obj.analysis_writer.obj_window,'Visible','on');
            else
                set(obj.analysis_writer.obj_window,'Visible','off');
            end
        end
        function obj = set_opt_plot_add(obj,~,~)
            n_exp = get(obj.obj_plot_ntext,'String');
            x_exp = get(obj.obj_plot_xtext,'String');
            y_exp = get(obj.obj_plot_ytext,'String');
            obj.add_equation(n_exp,x_exp,y_exp);
        end
        function obj = set_opt_plot_del(obj,~,~)
            i_list = sort(get(obj.obj_plot_list,'Value'),'descend');
            % delete elements from expression lists and values
            for i = i_list
                obj.opt_plot_equations(i) = [];
            end
            % unselect
            if length(obj.opt_plot_equations)==1
                set(obj.obj_plot_list,'Value',1);
                obj.opt_plot_value = 1;
            else                
                set(obj.obj_plot_list,'Value',[]);
                obj.opt_plot_value = [];
            end
            % update list
            obj.gui_updatelist();
        end
        
        % auxiliar functions ----------------------------------------------
        % add an equation
        function obj = add_equation(obj,n_exp,x_exp,y_exp)
            if ~isempty(n_exp) && ~isempty(x_exp) && ~isempty(y_exp)
                % add equation
                equation = analysis_equation();
                    % name
                equation.name = n_exp;
                    % expressions
                equation.expressions = {x_exp,y_exp};
                    % values
                nb_participants = obj.par_created('human');
                equation.values = cell(2,nb_participants);
                    % add
                obj.opt_plot_equations{end+1} = equation;
                % update value
                obj.opt_plot_value = length(obj.opt_plot_equations);
                % update list
                obj.gui_updatelist();
                set(obj.obj_plot_list,'Value',obj.opt_plot_value);
            end
        end
        % update equations list
        function obj = gui_updatelist(obj)
            if ~isempty(obj.opt_plot_equations)
                l = length(obj.opt_plot_equations);
                nameslist = cell(1,l);
                for i = 1:l
                    nameslist{i} = obj.opt_plot_equations{i}.name;
                end
                set(obj.obj_plot_list, ...
                    'Max',length(obj.opt_plot_equations),...
                    'Min',0,...
                    'String',nameslist ...
                );
            else
                set(obj.obj_plot_list, ...
                    'Max',0,...
                    'Min',0,...
                    'String',{} ...
                );
            end
        end
        % update plot panel position
        function obj = gui_updateplot(obj)
            % change panel position and size
            data_pos = get(obj.obj_data,'Position');
            plot_pos = get(obj.obj_plot,'Position');
            plot_pos(2) = data_pos(2)-plot_pos(4)-obj.gui_space;
            set(obj.obj_plot,'Position',plot_pos);
        end
        % update plot doit position
        function obj = gui_updatedoit(obj)
            % change panel position and size
            plot_pos = get(obj.obj_plot,'Position');
            doit_pos = get(obj.obj_doit,'Position');
            doit_pos(2) = plot_pos(2)-doit_pos(4)-obj.gui_space;
            set(obj.obj_doit,'Position',doit_pos);
        end
        
        % PLOTTING ========================================================
        % fill plot (with std deviation)
        function obj = plot(obj,xdata,ydata,color)
            if any(obj.opt_plot_minmax)
                % ymean
                if size(ydata,1)>1
                    ymean = mean(ydata);
                else
                    ymean = ydata;
                end
                    
                % min
                if obj.opt_plot_minmax(1)
                    if size(ydata,1)>1
                        ymin = min(ydata);
                    else
                        ymin = ydata;
                    end
                    plot(xdata,ymin,'Color',color);
                end
                % average
                if obj.opt_plot_minmax(2)
                    % with linear regression
                    if obj.opt_plot_minmax(5)
                        line_style = '--';
                        line_width = 1;
                        marker = '+';
                    else
                        line_style = '-';
                        line_width = 2;
                        marker = 'none';
                    end
                    plot(xdata,ymean,'k.','Color',color,'LineStyle',line_style,'LineWidth',line_width,'Marker',marker);
                end
                % max
                if obj.opt_plot_minmax(1)
                    if size(ydata,1)>1
                        ymax = max(ydata);
                    else
                        ymax = ydata;
                    end
                    plot(xdata,ymax,'Color',color);
                end
                % fill standard deviation
                if obj.opt_plot_minmax(4) && size(ydata,1) > 1
                    ystd = std(ydata);
                    ystdp = ymean + ystd;
                    ystdn = ymean - ystd;
                    xfill = [xdata xdata(end:-1:1)];
                    yfill = [ystdp ystdn(end:-1:1)];
                    fill(xfill,yfill,color,'EdgeAlpha',0,'FaceColor',color,'FaceAlpha',1-obj.opt_figure_filltransparency);
                end
                % linear regression
                if obj.opt_plot_minmax(5)
                    p = polyfit(xdata,ymean,1);
                    ylin = xdata*p(1) + p(2);
                    plot(xdata,ylin,'Color',color,'LineWidth',2);
                end
            else
                plot(xdata,ydata,'Color',color,'LineWidth',2);
            end
        end
        
        % PARSING =========================================================
        % plot the analysis
        function obj = do_it(obj,~,~)
            try
                % CLEAR SCREEN
                clc;
                
                % IDENTIFY PARTICIPANTS
                % select participants
                nb_par = length(obj.opt_data_byparticipant);
                switch(obj.opt_data_criterion)
                    case 1
                        % all
                        participants = ones(1,nb_par);
                    case 2
                        % by participant
                        participants = obj.opt_data_byparticipant;
                end
                % find participants index
                participants = find(participants);
                
                % EVALUATE EXPRESSIONS
                % load expressions
                l_equations = length(obj.opt_plot_equations);
                x_expressions = cell(1,l_equations);
                y_expressions = cell(1,l_equations);
                for i_equations = 1:l_equations
                    x_expressions{i_equations} = obj.opt_plot_equations{i_equations}.expressions{1};
                    y_expressions{i_equations} = obj.opt_plot_equations{i_equations}.expressions{2};
                end
                expressions = {x_expressions , y_expressions};
                % for each dimension (x, y)
                value_dim = {};
                fprintf(                            '                 evaluating expressions\n');
                for i_dim = 1:2
                    % for each expression
                    fprintf([                       '                   dimension ',num2str(i_dim),'\n']);
                    value_exp = {};
                    for i_expressions = 1:length(expressions{i_dim}(obj.opt_plot_value))
                        if length(obj.opt_plot_value) > 1
                            expression = expressions{i_dim}{obj.opt_plot_value(i_expressions)};
                        else
                            expression = expressions{i_dim}{obj.opt_plot_value};
                        end
                        % EVALUATE EXPRESSIONS for each participant
                        value_par = {};
                        fprintf([                   '                     evaluating expression ''',expression,'''\n']);
                        for i_participants = participants
                            fprintf([               '                       participant ',num2str(i_participants),'\n']);
                            % process expression
                            if isempty(obj.opt_plot_equations{obj.opt_plot_value(i_expressions)}.values{i_dim,i_participants})
                                value = obj.eval_action(expression, i_participants).value;
                                obj.opt_plot_equations{obj.opt_plot_value(i_expressions)}.values{i_dim,i_participants} = value;
                                value_par{end+1} = value;
                            % already done. take it from memory
                            else
                                value_par{end+1} = obj.opt_plot_equations{obj.opt_plot_value(i_expressions)}.values{i_dim,i_participants};
                            end
                        end
                        value_exp{end+1} = value_par;
                    end
                    value_dim{end+1} = value_exp;
                end
                
                % ACTION ACROSS PARTICIPANTS
                % syntax: value_dim{dimension}{expression}{participant}
                %         value_xplot{expression}
                %         value_yplot{expression}
                
                value_xplot = {};
                value_yplot = {};
                for i_exp = 1:length(value_dim{2})
                    % join participants
                    tmp_yplot = [];
                    for i_par = 1:length(value_dim{2}{i_exp})
                        tmp_yplot = [tmp_yplot ; value_dim{2}{i_exp}{i_par}];
                    end
                    value_xplot{end+1} = value_dim{1}{i_exp}{1};
                    value_yplot{end+1} = tmp_yplot;
                end
                
                % SELECT FIGURE
                if ~obj.opt_figure_current
                    % new figure
                    fig_val = figure();
                    set(fig_val,'CloseRequestFcn',@obj.closed_figure);
                    % color
                    obj.opt_figure_curveindex(end+1) = 1;
                    i_curveindex = length(obj.opt_figure_curveindex);
                    curve_index = 1;
                    % set to current
                    obj.opt_figure_current = fig_val;
                    % add to list
                    obj.opt_figure_figures = [obj.opt_figure_figures fig_val];
                    figures_list = get(obj.obj_figure_list,'String');
                    figures_list{end+1} = [' Figure ',num2str(obj.opt_figure_current)];
                    set(obj.obj_figure_list,...
                        'String',figures_list,...
                        'Value',length(obj.opt_figure_figures)+1 ...
                    );
                    % show hold button (if it's not visible already)
                    set(obj.obj_figure_hold,'Visible','on');
                else
                    % select current figure
                    set(0,'CurrentFigure',obj.opt_figure_current);
                    i_curveindex = find(obj.opt_figure_figures==obj.opt_figure_current);
                    curve_index = obj.opt_figure_curveindex(i_curveindex);
                end
                
                % hold
                hold_fig = get(obj.obj_figure_hold,'Value');
                if ~hold_fig
                    clf(obj.opt_figure_current);
                    curve_index = 1;
                else
                    
                end
                hold on;

                % PLOT
                for i_exp = 1:length(value_xplot)
                    obj.plot(value_xplot{i_exp},value_yplot{i_exp},obj.opt_figure_curvecolor{curve_index});
                    curve_index = curve_index+1;
                    if curve_index > length(obj.opt_figure_curvecolor)
                        curve_index = 1;
                    end
                end
                obj.opt_figure_curveindex(i_curveindex) = curve_index;
                % hold
                hold('off');
                
                % test
                % subjects / trials / models
                doit_values = zeros(size(value_yplot{1},1),size(value_yplot{1},2),length(value_yplot));
                for i = 1:size(value_yplot{1},1)
                    for j = 1:size(value_yplot{1},2)
                        for k = 1:length(value_yplot)
                            a = value_yplot{k};
                            doit_values(i,j,k) = a(i,j);
                        end
                    end
                end
                
                obj.doit_values = doit_values;
            catch err
                obj.file.close();
                rethrow(err);
            end
        end

        % evaluate expressions --------------------------------------------
        % parse and evaluate the expression
        function [exp_meta,exp_action] = eval_exp(obj,expression,i_participants)
            i_char = 1;
            meta = {};
            exp_action = [];
            new_expression = '';
            % create a new expression with meta variables
            while i_char <= length(expression)
                % field expression
                if strcmp(expression(i_char),'“')
                    field_start = i_char+1;
                    i_open = 1;
                    while i_open>0 && i_char <= length(expression)
                        % calling a new meta variable
                        i_char = i_char+1;
                        if i_char > length(expression)
                            error(           'analysis: do_it: error. ''“'' open without ''”'' closing');
                        end
                        if strcmp(expression(i_char),'”')
                            i_open = i_open-1;
                        end
                    end
                    field_end = i_char-1;
                    field = expression(field_start : field_end);
                    meta{end+1} = obj.eval_field(field,i_participants);
                    new_expression = [new_expression, '(meta{',num2str(length(meta)),'}.value)'];
                % action expression
                elseif strcmp(expression(i_char),'«')
                    action_start = i_char+1;
                    i_open = 1;
                    while i_open>0 && i_char <= length(expression)
                        i_char = i_char+1;
                        if i_char > length(expression)
                            error([          'analysis: do_it: error. ''«'' open without ''»'' closing in ',expression]);
                        end
                        if strcmp(expression(i_char),'«')
                            i_open = i_open+1;
                        elseif strcmp(expression(i_char),'»')
                            i_open = i_open-1;
                        end
                    end
                    action_end = i_char-1;
                    action = expression(action_start : action_end);
                    meta{end+1} = obj.eval_action(action,i_participants);
                    new_expression = [new_expression, '(meta{',num2str(length(meta)),'}.value)'];
                % action expression (root level)
                elseif strcmp(expression(i_char),'|')
                    exp_action = expression(i_char+1:end);
                    i_char = length(expression);
                % variable expression
                elseif strcmp(expression(i_char),'‘')
                    var_start = i_char+1;
                    i_open = 1;
                    while i_open>0 && i_char <= length(expression)
                        % calling a new meta variable
                        i_char = i_char+1;
                        if i_char > length(expression)
                            error(           'analysis: do_it: error. ''‘'' open without ''’'' closing');
                        end
                        if strcmp(expression(i_char),'’')
                            i_open = i_open-1;
                        end
                    end
                    var_end = i_char-1;
                    var = expression(var_start : var_end);
                    meta{end+1} = obj.eval_var(var,i_participants);
                    new_expression = [new_expression, '(meta{',num2str(length(meta)),'}.value)'];
                else
                    % not a meta expression
                    new_expression(end+1) = expression(i_char);
                end
                i_char = i_char+1;
            end
            % sort meta variables
            meta = obj.sort_meta(meta);
            % evaluate the expression
            exp_meta = analysis_meta(0);
            if isempty(meta)
                exp_meta.index_name = {};
                exp_meta.index_value = [];
            else
                exp_meta.index_name = meta{1}.index_name;
                exp_meta.index_value = meta{1}.index_value;
            end
            exp_meta.value = eval(new_expression);
        end
        
        % sort meta variables (in function of their index)
        function meta = sort_meta(~,meta)
            % IMPORTANT. we are supposing that a priori meta variables will follow the same index values
            if length(meta) > 1
                % check meta variables have same indexes
                for i_meta = 2:length(meta)
                    if ~all(ismember(meta{i_meta-1}.index_name,meta{i_meta}.index_name))   || ...
                       ~all(ismember(meta{i_meta}.index_name  ,meta{i_meta-1}.index_name))
                        for j_meta = 1:length(meta)
                            for j_index = 1:length(meta{j_meta}.index_name)
                                fprintf(['analysis: sort_meta: meta{',num2str(j_meta),'}.index_name{',num2str(j_index),'} = ',meta{j_meta}.index_name{j_index},'\n']);
                            end
                        end
                        error('analysis: sort_meta: trying to evaluate between metavariables of different indexes');
                    end
                end
                % check meta lengths
                for i_meta = 2:length(meta)
                    if length(meta{i_meta-1}.value) ~= length(meta{i_meta}.value)
                        for j_meta = 1:length(meta)
                            fprintf(['analysis: sort_meta: length(meta{',num2str(j_meta),'}.value) = ',num2str(length(meta{j_meta}.value)),'\n']);
                        end
                        error('analysis: sort_meta: trying to evaluate between metavariables with different lengths');
                    end
                end
                % set indexes order
                for i_meta = 2:length(meta)
                    % identify order
                    order = zeros(1,length(meta{i_meta}.index_name));
                    for i_index = 1:length(meta{i_meta}.index_name)
                        for i_ref = 1:length(meta{1}.index_name)
                            if strcmp(meta{1}.index_name{i_ref},meta{i_meta}.index_name{i_index})
                                order(i_index) = i_ref;
                                break;
                            end
                        end
                    end
                    % modify index order
                    meta{i_meta}.index_name  = meta{i_meta}.index_name{order};
                    meta{i_meta}.index_value = meta{i_meta}.index_value(:,order);
                end
                % check that indexes match
                for i_meta = 2:length(meta)
                    if any(meta{i_meta-1}.index_value - meta{i_meta-1}.index_value)
                        error('analysis: sort_meta: trying to evaluate between indexes that doesn''t match');
                    end
                end
            end
        end
        
        % loads or calculates a variable
        function meta = eval_var(obj,var_name,i_participants)
            % find variable
            i_variables = 0;
            for j_variables = 1:length(obj.variables)
                if strcmp(var_name,obj.variables{j_variables}.name)
                    i_variables = j_variables;
                    break;
                end
            end
            % if not found error
            if ~i_variables
                error(['analysis: eval_var: variable ''',var_name,''' doesn''t exist\n']);
            end
            
            % if still not calculated
            if isempty(obj.variables{i_variables}.value{i_participants})
                % calculate
                meta = obj.eval_action(obj.variables{i_variables}.expression, i_participants);
                % save in variable
                obj.variables{i_variables}.index_name = meta.index_name;
                obj.variables{i_variables}.index_value{i_participants} = meta.index_value;
            % if already calculated
            else
                % load from variable
                meta = analysis_meta(0);
                meta.index_name = obj.variables{i_variables}.index_name;
                meta.index_value = obj.variables{i_variables}.index_value{i_participants};
            end
        end
        
        % create a meta corresponding to a field from data
        function field_meta = eval_field(obj,complete_field,i_participant)
            field_meta = analysis_meta(0);
            fields = regexp(complete_field,'[.]','split');
            
            % load interface if still not
            if ~isfield(obj.data,fields{1}) || isempty(obj.data.(fields{1}){i_participant})
                obj.load_interface(fields{1},i_participant);
            end
            % switch for special fields
            switch fields{1}
                case 'maps'
                    % field
                    field_meta.expression = complete_field;
                    % index names
                    field_meta.index_name = {};
                    % index values
                    field_meta.index_value = [];
                    % value
                    field_meta.value = [];
                case 'seq'
                    % field
                    field_meta.expression = complete_field;
                    % index names
                    field_meta.index_name = {'map','trial'};
                    % index values
                    field_meta.index_value = [obj.data.seq{i_participant}.map',...
                                                obj.data.seq{i_participant}.trial'];
                    % value
                    field_meta.value = obj.data.seq{i_participant}.(fields{2});
                otherwise
                    % expression
                    field_meta.expression = complete_field;
                    % header field
                    if strcmp(fields{2},'header')
                        % index names
                        field_meta.index_name = {};
                        % index values
                        field_meta.index_value = [];
                        % value
                        field_meta.value = eval(['obj.data.',fields{1},'{i_participant}.header.',fields{3}]);
                    % data field
                    elseif strcmp(fields{2},'data')
                        tmp_indexes = regexp(fields{3},'[←]','split');
                        fields{3} = tmp_indexes{1};
                        % index names
                        field_meta.index_name = {};
                        % index values
                        field_meta.index_value = [];
                        if length(tmp_indexes) > 1
                            tmp_indexes = tmp_indexes{2};
                            tmp_indexes = regexp(tmp_indexes,'[,]','split');
                            for i_tmpindexes = 1:length(tmp_indexes)
                                % index names
                                field_meta.index_name{end+1} = strtrim(tmp_indexes{i_tmpindexes});
                                % index values
                                field_meta.index_value = [field_meta.index_value , eval(['obj.data.',fields{1},'{i_participant}.data.',strtrim(tmp_indexes{i_tmpindexes})])'];
                            end
                        end
                        % value
                        field_meta.value = eval(['obj.data.',fields{1},'{i_participant}.data.',fields{3}]);
                    else
                        error(['analysis: eval_field: field ''',fields{1},'.',fields{2},''' sounds weird']);
                    end
            end
        end
        
        % apply an action to a meta variable
        function meta = eval_action(obj,expression, i_participants)
            % evaluate the meta
            [meta,actions] = obj.eval_exp(expression,i_participants);
            if ~isempty(actions)
                % split the actions
                actions = regexp(actions,'[|]','split');

                % apply actions
                for i_actions = 1:length(actions)
                    % parse action and indexes
                    keys = regexp(actions{i_actions},'\s','split');
                    if isempty(keys{1})
                        keys(1) = [];
                    end
                    if isempty(keys{end})
                        keys(end) = [];
                    end
                    
                    if length(keys) < 2
                        error('analysis:eval_action: not keys enough');
                    end
                    
                    index = keys{1};
                    action = keys{2};
                    modulators = {keys{3:end}};

                    % identify index
                    i_find = find(strcmp(index,meta.index_name));
                    if isempty(i_find)
                        error(['analysis:eval_action: index ',index,' not available']);
                    else
                        i_indexname = i_find;
                    end
                    % constraint index number
                    [numbers, is_number] = str2num(action);
                    if is_number
                        if length(i_indexname) ~= 1
                            error('analysis:eval_action: setting more than one index');
                        else
                            i_row = 1;
                            while i_row<size(meta.index_value,1)
                                if all(meta.index_value(i_row,i_indexname) ~= numbers)
                                    meta.index_value(i_row,:) = [];
                                    meta.value(i_row) = [];
                                else
                                    i_row = i_row+1;
                                end
                            end
                            % delete the index if is determined to one only possible value
                            if length(numbers)==1
                                meta.index_name(i_indexname) = [];
                                meta.index_value(:,i_indexname) = [];
                            end
                       end
                    % apply normal action
                    else
                        % delete indexes
                        meta.index_name(i_indexname) = [];
                        meta.index_value(:,i_indexname) = [];
                        % apply action over values sharing the same index
                        j_index = 1;
                        while j_index <= size(meta.index_value,1)
                            % current index
                            index_value = meta.index_value(j_index,:);
                            % find rows and values with same mts conditions
                            index_row = [];
                            value = [];
                            for k_index = 1:size(meta.index_value,1)
                                if all(index_value == meta.index_value(k_index,:))
                                    index_row(end+1) = k_index;
                                    value(end+1) = meta.value(k_index);
                                end
                            end
                            % remove all rows and values but the first
                            meta.index_value(index_row(2:end),:) = [];
                            meta.value(index_row(2:end)) = [];
                            % save the new value
                            eval_str = [action,'(value'];
                            for i_modulators = 1:length(modulators)
                                eval_str = [eval_str,',',modulators{i_modulators}];
                            end
                            eval_str = [eval_str,')'];
                            value = eval(eval_str);
                            meta.value(index_row(1)) = value;
                            % go to next mts
                            j_index = j_index+1;
                        end
                    end
                end
            end
        end
        
        function obj = load_interface(obj,interface,i_participant)
            % create field if still not
            if ~isfield(obj.data,interface)
                obj.data.(interface) = cell(1,obj.par_created('human'));
            end
            
            obj.file.set_interface(interface);
            if strcmp(interface,'seq')
                obj.data.seq{i_participant} = obj.seq_load(i_participant);
            elseif strcmp(interface,'map')
                % TODO load maps ########################################################
            else
                if ~obj.par_created(interface)
                    error([     'analysis:do_it: ''',interface,''' not available']);
                end
                obj.data.(interface){i_participant} = obj.par_read(interface,i_participant);
            end
        end
        
        % loading files ===================================================
        % sequence methods ------------------------------------------------
        % number of sequence already generated, + 1
        function nbseqs = seq_created(obj)
            nbseqs = 1;
            while exist([obj.seq_dir,'/',obj.seq_prename,num2str(nbseqs),'.mat'],'file')
                nbseqs = nbseqs+1;
            end
            nbseqs = nbseqs-1;
        end
        % load sequence variables
        function seq_struct = seq_load(obj,number)
            % load the sequence
            load([obj.seq_dir,'/',obj.seq_prename,num2str(number),'.mat']);
            % create struct
            seq_struct = struct();
            % add special fields and indexes
            seq_struct.map = [];
            seq_struct.trial = [];
            seq_struct.mapnumber = [];
            seq_struct.optimaltime = [];
            seq_struct.startpos = [];
            seq_struct.startline = [];
            seq_struct.endpos = [];
            
            nb_maps = length(seq_maps);
            nb_trials = length(seq_timetrials{1});
            for i_map = 1:nb_maps
                for i_trial = 1:nb_trials
                    seq_struct.map(end+1) = i_map;
                    seq_struct.trial(end+1) = i_trial;
                    seq_struct.mapnumber(end+1) = seq_maps(i_map);
                    seq_struct.optimaltime(end+1) = seq_timetrials{i_map}(i_trial);
                    seq_struct.startpos(end+1) = seq_postrials{i_map}(i_trial,1);
                    seq_struct.startline(end+1) = seq_postrials{i_map}(i_trial,2);
                    seq_struct.endpos(end+1) = seq_postrials{i_map}(i_trial,3);
                end
            end
        end
        
        % file methods ----------------------------------------------------
        % number of participants already generated, +1
        function nbpars = par_created(obj,interface)
            obj.file.tree_interface = interface;
            nbpars = obj.file.tree_last()-1;
        end
        function file_struct = par_read(obj,interface,i_participant)
            obj.file.tree_interface = interface;
            file_struct = obj.file.tree_read(i_participant);
        end
        
        % main map methods ------------------------------------------------
        % number of main maps already generated, +1
        function nbmaps = mainmaps_created(obj)
            nbmaps = 1;
            while exist([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(nbmaps),'.mat'],'file')
                nbmaps = nbmaps+1;
            end
            nbmaps = nbmaps - 1;
        end
    end
end
