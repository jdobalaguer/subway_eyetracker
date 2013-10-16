classdef analysis_writer < handle
    % class for write analysis equations
    
    properties
        % analysis
        analysis
        
        % gui objects
        obj_window
        obj_tab
        obj_tab_popup
        obj_body
        obj_body_ntext
        obj_body_modepopup
        obj_body_exp
        obj_body_exp_exptext
        obj_body_gui
        obj_body_rempushbutton
        obj_body_updpushbutton
        obj_body_addpushbutton
        obj_body_gui_var
        obj_body_gui_var_popup
        obj_body_gui_ind
        obj_body_gui_ind_popup
        obj_body_gui_act
        obj_body_gui_act_popup
        obj_equat
        obj_equat_ntext
        obj_equat_xpopup
        obj_equat_ypopup
        obj_equat_addpushbutton
        
        % gui parameters
        gui_background
        gui_position
        gui_size
        gui_space
        gui_heightlabels
        gui_height_title
        gui_space_tab
        gui_height_tabpopup
        gui_space_body
        gui_height_bodypopup
        gui_length_v1popup
        gui_length_v2popup
        gui_length_v3popup
        gui_height_bodylabel
        gui_length_bodylabel
        gui_height_bodypushbutton
        gui_length_bodypushbutton
        gui_space_equat
        gui_height_equatlabel
        gui_length_equatlabel
        
        % gui auxiliar parameters
        gui_body_possize
        
        % values
        data_models
        data_modules
        data_fields
        variables                   % attention: last one is the 'new'!
    end
    
    methods
        % constructor
        function obj = analysis_writer(analysis)
            % analysis
            obj.analysis = analysis;
            
            % values
            obj.data_models = obj.analysis.file.find_interfaces();
            obj.data_modules = {'header', 'data'};
            obj.analysis.file.set_interface('human');
            fields = obj.analysis.file.tree_fields();
            obj.analysis.file.close();
            obj.data_fields = {fieldnames(fields.header)',fieldnames(fields.data)'};
            obj.variables = analysis.variables;
            obj.variables{end+1} = analysis_meta(obj.analysis.par_created('human'));
            
            % gui parameters
            obj.gui_background = [.8 .8 .8];
            obj.gui_position = [obj.analysis.gui_size(1),0];
            obj.gui_size = obj.analysis.gui_size;
            obj.gui_space = 10;
            obj.gui_heightlabels = 10;
            obj.gui_height_title = 24;
            obj.gui_space_tab = 10;
            obj.gui_height_tabpopup = 24;
            obj.gui_space_body = 10;
            obj.gui_height_bodypopup = 24;
            obj.gui_length_v1popup = 80;
            obj.gui_length_v2popup = 60;
            obj.gui_length_v3popup = 115;
            obj.gui_height_bodylabel = 24;
            obj.gui_length_bodylabel = 24;
            obj.gui_height_bodypushbutton = 24;
            obj.gui_length_bodypushbutton = 40;
            obj.gui_space_equat = 10;
            obj.gui_height_equatlabel = 24;
            obj.gui_length_equatlabel = 24;
            
            % gui start
            obj.gui_start();
        end
        
        % GUI =============================================================
        % drawing ---------------------------------------------------------
        % draw the gui
        function obj = gui_start(obj)
            l_variables = length(obj.variables);
            
            % WINDOW
            obj.obj_window = figure(...
                'Color',obj.gui_background,...
                'Name','analysis equation writer',...
                'Units','pixels',...
                'Position',[obj.gui_position,obj.gui_size],...
                'MenuBar','no',...
                'Resize','off',...
                'CloseRequestFcn',@obj.closed_window ...
            );
            
            % TITLE
            % title
            panel_pos =  [  obj.gui_space ...
                            obj.gui_size(2)-obj.gui_space-obj.gui_height_title ];
            panel_size = [  obj.gui_size(1)-2*obj.gui_space ...
                            obj.gui_height_title ];
            uicontrol(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'Style','text',...
                'Units','pixel',...
                'Position', [panel_pos panel_size],...
                'String', ' analysis equation writer' ...
                );
            
            % TAB
            % tab layout
            panel_size(2) = 2*obj.gui_space_tab + obj.gui_height_tabpopup;
            panel_pos(2) = panel_pos(2)-panel_size(2)-obj.gui_space;
            obj.obj_tab = uipanel(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'BorderType','none',...
                'Units','pixel',...
                'Position',[panel_pos panel_size]);
            % tab popup list
            popup_string = obj.get_varnames();
            item_pos =  [   obj.gui_space_tab ...
                            obj.gui_space_tab ];
            item_size = [   panel_size(1)-2*obj.gui_space_tab ...
                            obj.gui_height_tabpopup ];
            obj.obj_tab_popup = uicontrol(...
                'Parent',obj.obj_tab,...
                'Style','popup',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'String', popup_string,...
                'Value', 1,...
                'Callback', @obj.set_var_tab...
                );
            
            % BODY
            panel_size(2) = 500;
            panel_pos(2) = panel_pos(2)-panel_size(2)-obj.gui_space;
            obj.gui_body_possize = [panel_pos panel_size];
            obj.obj_body = cell(1,l_variables);
            obj.obj_body_ntext = {};
            obj.obj_body_modepopup = {};
            obj.obj_body_gui_var = {};
            obj.obj_body_gui_var_popup = {};
            obj.obj_body_gui_ind = {};
            obj.obj_body_gui_ind_popup = {};
            obj.obj_body_gui_act = {};
            obj.obj_body_gui_act_popup = {};
            obj.obj_body_rempushbutton = {};
            obj.obj_body_updpushbutton = {};
            obj.obj_body_addpushbutton = {};
            for i_variables = 1:l_variables
                % set configuration
                obj.set_body(i_variables);
            end
            set(obj.obj_body{1},'Visible','on');
            panel_possize = get(obj.obj_body{get(obj.obj_tab_popup,'Value')},'Position');
            panel_size(2) = panel_possize(4);
            
            % EQUAT
            panel_size(2) = 5*obj.gui_space_equat + 4*obj.gui_height_equatlabel;
            panel_pos(2) = panel_pos(2)-panel_size(2)-obj.gui_space;
            % equat layout
            obj.obj_equat = uipanel(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'BorderType','none',...
                'Units','pixel',...
                'Position',[panel_pos panel_size] ...
                );
            % name label
            item_size(1) = obj.gui_length_equatlabel;
            item_size(2) = obj.gui_height_equatlabel;
            item_pos(1) = obj.gui_space_equat;
            item_pos(2) = panel_size(2) - obj.gui_space_equat - obj.gui_height_equatlabel;
            uicontrol(...
                'Parent',obj.obj_equat,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'n' ...
                );
            item_pos(1) = item_pos(1) + item_size(1) + obj.gui_space;
            item_size(1) = panel_size(1) - 3*obj.gui_space_equat - obj.gui_length_equatlabel;
            % name entry textbox
            obj.obj_equat_ntext = uicontrol(...
                'Parent',obj.obj_equat,...
                'BackgroundColor',obj.gui_background,...
                'Style','edit',...
                'Units','pixel',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size]...
                );
            % x label
            item_size(1) = obj.gui_length_equatlabel;
            item_size(2) = obj.gui_height_equatlabel;
            item_pos(1) = obj.gui_space_equat;
            item_pos(2) = item_pos(2) - obj.gui_space_equat-obj.gui_height_equatlabel;
            uicontrol(...
                'Parent',obj.obj_equat,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'x' ...
                );
            item_pos(1) = item_pos(1) + item_size(1) + obj.gui_space;
            item_size(1) = panel_size(1) - 3*obj.gui_space_equat - obj.gui_length_equatlabel;
            % x expression entry textbox
            obj.obj_equat_xpopup = uicontrol(...
                'Parent',obj.obj_equat,...
                'BackgroundColor',obj.gui_background,...
                'Style','popup',...
                'Units','pixel',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size],...
                'String',' ',...
                'Enable','off' ...
                );
            % y label
            item_size(1) = obj.gui_length_equatlabel;
            item_size(2) = obj.gui_height_equatlabel;
            item_pos(1) = obj.gui_space_equat;
            item_pos(2) = item_pos(2) - obj.gui_space_equat-obj.gui_height_equatlabel;
            uicontrol(...
                'Parent',obj.obj_equat,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'y' ...
                );
            item_pos(1) = item_pos(1) + item_size(1) + obj.gui_space;
            item_size(1) = panel_size(1) - 3*obj.gui_space_equat - obj.gui_length_equatlabel;
            % y expression entry textbox
            obj.obj_equat_ypopup = uicontrol(...
                'Parent',obj.obj_equat,...
                'BackgroundColor',obj.gui_background,...
                'Style','popup',...
                'Units','pixel',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size],...
                'String',' ',...
                'Enable','off' ...
                );
            % add pushbutton
            item_size(1) = panel_size(1) - 2*obj.gui_space_equat;
            item_size(2) = obj.gui_height_equatlabel;
            item_pos(1) = obj.gui_space_equat;
            item_pos(2) = item_pos(2) - obj.gui_space_equat-obj.gui_height_equatlabel;
            obj.obj_equat_addpushbutton = uicontrol(...
                'Parent',obj.obj_equat,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'add equation',...
                'Callback', @obj.add_equat ...
                );
            obj.update_equat();
        end
        
        % callback methods ------------------------------------------------
        % tab selection. show a body, hide others
        function obj = set_var_tab(obj,gui_obj,~)
            for i_body = 1:length(obj.obj_body)
                set(obj.obj_body{i_body},'Visible','off');
            end
            set(obj.obj_body{get(gui_obj,'Value')},'Visible','on');
        end
        % close analysis_writer window
        function obj = closed_window(obj,~,~)
            set(obj.obj_window,'Visible','off');
            set(obj.analysis.obj_plot_aw,'Value',0);
        end
        % switch mode
        function obj = set_bodymode(obj,gui_obj,~)
            i_body = get(obj.obj_tab_popup,'Value');
            mode = get(gui_obj,'Value');
            switch(mode)
                case 1
                    set(obj.obj_body_exp{i_body},'Visible','on');
                    set(obj.obj_body_gui{i_body},'Visible','off');
                case 2
                    set(obj.obj_body_exp{i_body},'Visible','off');
                    set(obj.obj_body_gui{i_body},'Visible','on');
                otherwise
                    strings = get(gui_obj,'Strings');
                    error(['analysis_writer: set_mode: mode ',strings{mode},' not valid\n']);
            end
        end
        % add variable
        function obj = add_var(obj,~,~)
            % update visibility of buttons
            set(obj.obj_body_addpushbutton{end},'Visible','off');
            set(obj.obj_body_updpushbutton{end},'Visible','on');
            set(obj.obj_body_rempushbutton{end},'Visible','on');
            % update variables
            mode = get(obj.obj_body_modepopup{end},'Value');
            switch(mode)
                case 1
                    % exp add
                    
                    obj.variables{end}.name = get(obj.obj_body_ntext{end},'String');
                    obj.variables{end}.expression = get(obj.obj_body_exp_exptext{end},'String');
                    % look for fields + index #############################
                    % look for variables + index ##########################
                    obj.variables{end}.index_name = {};
                    obj.variables{end}.variables = {};
                case 2
                    % gui add
                    
                    % #####################################################
                otherwise
                    strings = get(gui_obj,'Strings');
                    error(['analysis_writer: set_mode: mode ',strings{mode},' not valid\n']);
            end
            obj.variables{end+1} = analysis_meta(obj.analysis.par_created('human'));
            % update tab popup
            strings = obj.get_varnames();
            set(obj.obj_tab_popup,'String',strings);
            % update bodies
            set(obj.obj_body{end},'Title',strings{end-1});
            obj.set_body(length(obj.variables));
            % update equat
            obj.update_equat();
            % update analysis
            obj.analysis.variables{end+1} = obj.variables{end-1};
        end
        % set data fields
        function obj = set_obj_body_gui_v3(obj,gui_obj,~)
            i_body = get(obj.obj_tab_popup,'Value');
            set(obj.obj_body_gui_var_popup{i_body}{3},...
                'Value',1,...
                'String',obj.data_fields{get(gui_obj,'Value')} ...
                );
        end
        % upd variable
        function obj = upd_var(obj,~,~)
            i_body = get(obj.obj_tab_popup,'Value');
            % update variables
            mode = get(obj.obj_body_modepopup{end},'Value');
            switch(mode)
                case 1
                    % exp upd
                    
                    obj.variables{i_body}.name = get(obj.obj_body_ntext{i_body},'String');
                    obj.variables{i_body}.expression = get(obj.obj_body_exp_exptext{i_body},'String');
                    % look for fields + index #############################
                    % look for variables + index ##########################
                    obj.variables{i_body}.index_name = {};
                    obj.variables{i_body}.variables = {};
                case 2
                    % gui upd
                    
                    % #####################################################
                otherwise
                    strings = get(gui_obj,'Strings');
                    error(['analysis_writer: set_mode: mode ',strings{mode},' not valid\n']);
            end
            % update tab popup
            strings = obj.get_varnames();
            set(obj.obj_tab_popup,'String',strings);
            % update bodies
            set(obj.obj_body{i_body},'Title',strings{i_body});
            % update equat
            obj.update_equat();
            % update analysis
            obj.analysis.variables{i_body} = obj.variables{i_body};
        end
        % rem variable
        function obj = rem_var(obj,~,~)
            i_body = get(obj.obj_tab_popup,'Value');
            % remove variable
            obj.variables(i_body) = [];
            % remove body
            delete(obj.obj_body{i_body});
            obj.obj_body(i_body) = [];
            % show next body
            set(obj.obj_body{i_body},'Visible','on');
            % update tab popup
            strings = obj.get_varnames();
            set(obj.obj_tab_popup,'String',strings);
            % update equat
            xequat = get(obj.obj_equat_xpopup,'Value');
            if  xequat >= i_body && xequat>1
                set(obj.obj_equat_xpopup,'Value',xequat-1);
            end
            yequat = get(obj.obj_equat_ypopup,'Value');
            if  yequat >= i_body && yequat>1
                set(obj.obj_equat_ypopup,'Value',yequat-1);
            end
            obj.update_equat();
            % update analysis
            obj.analysis.variables(i_body) = [];
        end
        % add equation
        function  obj = add_equat(obj,~,~)
            n_exp = get(obj.obj_equat_ntext,'String');
            x_exp = ['‘',obj.variables{get(obj.obj_equat_xpopup,'Value')}.name,'’'];
            y_exp = ['‘',obj.variables{get(obj.obj_equat_ypopup,'Value')}.name,'’'];
            obj.analysis.add_equation(n_exp,x_exp,y_exp);
        end
        
        % auxiliar functions ----------------------------------------------
        % get obj.variables{:}.name
        function strings = get_varnames(obj)
            l_variables = length(obj.variables);
            strings = cell(1,l_variables);
            for i = 1:l_variables
                strings{i} = [' ',obj.variables{i}.name,' '];
            end
        end
        % set body number i_body
        function obj = set_body(obj,i_body)
            % BODY
            panel_possize = obj.gui_body_possize;
            panel_size = panel_possize([3,4]);
            body_panel = uipanel(...
                'Parent',obj.obj_window,...
                'BackgroundColor',obj.gui_background,...
                'Title',obj.variables{i_body}.name,...
                'Units','pixel',...
                'Position',obj.gui_body_possize,...
                'Visible','off' ...
            );
            obj.obj_body{i_body} = body_panel;
            
            % NAME
            % name label
            item_size = [   obj.gui_length_bodylabel, ...
                            obj.gui_height_bodypopup ];
            item_pos  = [   obj.gui_space_body, ...
                            panel_size(2) - obj.gui_space_body - obj.gui_heightlabels - obj.gui_height_bodypopup ];
            uicontrol(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Enable','off',...
                'Units','pixel',...
                'Position', [item_pos item_size],...
                'HorizontalAlignment','left',...
                'String', 'n' ...
                );
            % name entry textbox
            item_pos(1) = item_pos(1) + item_size(1) + obj.gui_space;
            item_size(1) = panel_size(1) - 3*obj.gui_space_equat - obj.gui_length_bodylabel;
            obj.obj_body_ntext{i_body} = uicontrol(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Style','edit',...
                'Units','pixel',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size]...
                );
            
            % MODE
            % mode popup
            item_size(1) = panel_size(1) - 2*obj.gui_space_equat;
            item_size(2) = obj.gui_height_bodypopup;
            item_pos(1) = obj.gui_space;
            item_pos(2) = item_pos(2) - obj.gui_space_body - item_size(2);
            obj.obj_body_modepopup{i_body} = uicontrol(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Style','popup',...
                'Units','pixel',...
                'String',' expression| gui',...
                'Value',2,...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size],...
                'Callback', @obj.set_bodymode...
                );
            
            % EXP and GUI layouts
            subpanel_size = [ panel_size(1) - 2*obj.gui_space_body ...
                              panel_size(2) - 5*obj.gui_space_body - obj.gui_heightlabels - 2*obj.gui_height_bodypopup - obj.gui_height_bodypushbutton];
            subpanel_pos  = [ item_pos(1) ...
                              item_pos(2) - obj.gui_space_body - subpanel_size(2)];
            obj.obj_body_exp{i_body} = uipanel(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Units','pixel',...
                'Position',[subpanel_pos subpanel_size],...
                'Visible','off' ...
                );
            obj.obj_body_gui{i_body} = uipanel(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Units','pixel',...
                'Position',[subpanel_pos subpanel_size],...
                'Visible','on' ...
                );
            
            % EXP
            % exp text
            obj.obj_body_exp_exptext{i_body} = uicontrol(...
                'Parent',obj.obj_body_exp{i_body},...
                'BackgroundColor',obj.gui_background,...
                'Style','edit',...
                'Units','pixel',...
                'Max',2,...
                'String',obj.variables{i_body}.expression,...
                'HorizontalAlignment','left',...
                'Position', [0 0 subpanel_size]...
                );

            % GUI
            % var layout
            hipopanel_size = [subpanel_size(1)-2*obj.gui_space_body ...
                              obj.gui_height_bodypopup];
            hipopanel_pos  = [obj.gui_space_body ...
                              subpanel_size(2) - obj.gui_space_body - hipopanel_size(2)];
            obj.obj_body_gui_var{i_body} = uipanel(...
                'Parent',obj.obj_body_gui{i_body},...
                'BackgroundColor',obj.gui_background,...
                'Units','pixel',...
                'Position',[hipopanel_pos hipopanel_size],...
                'BorderType','none',...
                'Visible','on' ...
                );
            % v label
            hipoitem_size(1) = obj.gui_length_bodylabel;
            hipoitem_size(2) = obj.gui_height_bodylabel;
            hipoitem_pos(1) = 0;
            hipoitem_pos(2) = hipopanel_size(2) - obj.gui_height_bodylabel;
            uicontrol(...
                'Parent',obj.obj_body_gui_var{i_body},...
                'BackgroundColor',obj.gui_background,...
                'Style','togglebutton',...
                'Units','pixel',...
                'Position', [hipoitem_pos hipoitem_size],...
                'HorizontalAlignment','left',...
                'String', 'v' ...
                );
            % v popups
            obj.obj_body_gui_var_popup{i_body} = {};
            % v1 popup
            hipoitem_pos(1) = hipoitem_pos(1) + hipoitem_size(1) + obj.gui_space_body;
            hipoitem_size(1) = obj.gui_length_v1popup;
            obj.obj_body_gui_var_popup{i_body}{1} = uicontrol(...
                'Parent',obj.obj_body_gui_var{i_body},...
                'BackgroundColor',obj.gui_background,...
                'Style','popup',...
                'Units','pixel',...
                'Position', [hipoitem_pos hipoitem_size],...
                'HorizontalAlignment','left',...
                'String', obj.data_models ...
                );
            % v2 popup
            hipoitem_pos(1) = hipoitem_pos(1) + hipoitem_size(1);
            hipoitem_size(1) = obj.gui_length_v2popup;
            obj.obj_body_gui_var_popup{i_body}{2} = uicontrol(...
                'Parent',obj.obj_body_gui_var{i_body},...
                'BackgroundColor',obj.gui_background,...
                'Style','popup',...
                'Units','pixel',...
                'Position', [hipoitem_pos hipoitem_size],...
                'HorizontalAlignment','left',...
                'String', obj.data_modules,...
                'Value',2,...
                'Callback', @obj.set_obj_body_gui_v3 ...
                );
            % v3 popup
            hipoitem_pos(1) = hipoitem_pos(1) + hipoitem_size(1);
            hipoitem_size(1) = obj.gui_length_v3popup;
            obj.obj_body_gui_var_popup{i_body}{3} = uicontrol(...
                'Parent',obj.obj_body_gui_var{i_body},...
                'BackgroundColor',obj.gui_background,...
                'Style','popup',...
                'Units','pixel',...
                'Position', [hipoitem_pos hipoitem_size],...
                'HorizontalAlignment','left',...
                'String', obj.data_fields{get(obj.obj_body_gui_var_popup{i_body}{2},'Value')} ...
                );
                        
            % #############################################################
            
            % SAVE
            % remove button
            item_size(1) = obj.gui_length_bodypushbutton;
            item_size(2) = obj.gui_height_bodypushbutton;
            item_pos(1) = panel_size(1) - 2*obj.gui_space_body - 2*obj.gui_length_bodypushbutton;
            item_pos(2) = obj.gui_space_body;
            obj.obj_body_rempushbutton{i_body} = uicontrol(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Units','pixel',...
                'String','rem',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size],...
                'Callback', @obj.rem_var...
                );
            % update button
            item_pos(1) = item_pos(1) + obj.gui_space_body + item_size(1);
            obj.obj_body_updpushbutton{i_body} = uicontrol(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Units','pixel',...
                'String','upd',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size],...
                'Callback', @obj.upd_var...
                );
            % add button
            obj.obj_body_addpushbutton{i_body} = uicontrol(...
                'Parent',body_panel,...
                'BackgroundColor',obj.gui_background,...
                'Style','pushbutton',...
                'Units','pixel',...
                'String','add',...
                'HorizontalAlignment','left',...
                'Position', [item_pos item_size],...
                'Callback', @obj.add_var...
                );
            % hide buttons
            if i_body == length(obj.obj_body)
                set(obj.obj_body_rempushbutton{i_body},'Visible','off');
                set(obj.obj_body_updpushbutton{i_body},'Visible','off');
            else
                set(obj.obj_body_addpushbutton{i_body},'Visible','off');
            end
        end
        % update equat popups
        function obj = update_equat(obj)
            % variables available
            if length(obj.variables) > 1
                strings = obj.get_varnames();
                strings(end) = [];
                % x popup
                set(obj.obj_equat_xpopup,...
                    'String',strings,...
                    'Enable','on' ...
                    );
                % y popup
                set(obj.obj_equat_ypopup,...
                    'String',strings,...
                    'Enable','on' ...
                    );
                % add pushbutton
                set(obj.obj_equat_addpushbutton,...
                    'Enable','on' ...
                    );
            % no variables
            else
                set(obj.obj_equat_xpopup,...
                    'String',' ',...
                    'Enable','off' ...
                    );
                set(obj.obj_equat_ypopup,...
                    'String',' ',...
                    'Enable','off' ...
                    );
                set(obj.obj_equat_addpushbutton,'Enable','off');
            end
        end
    end
end