classdef main_monitor < handle
    % interface for screen and audio
    
    % properties ##########################################################
    properties
        % use
        use % [use_screen , use_audio , use_eyelink]
        
        % screen
        screen_window
        screen_rect
        screen_maprect
        % draw
        draw_bordertop
        draw_bordersides
        draw_borderbottom
        % text
        text_pause
        text_size
        text_linespace
        % timebar
        timebar_rect
        % audioport
        audioport
        % keyboard
        kb_numbers
        kb_chars
        kb_space
        kb_return
        kb_escape
        kb_backspace
        % eyelink
        eyelink
        eyelink_eye
        eyelink_edf
        % runs
        run_maps
        run_trainmaps
        run_trials
    end
    
    % methods #############################################################
    methods
        % constructor
        function obj = main_monitor()
            obj.use = [0 0 0];
            
            obj.screen_window = [];
            obj.screen_rect = [0 0 0 0];
            obj.screen_maprect = [0 0 0 0];
            
            obj.draw_bordertop = 100;
            obj.draw_bordersides = 100;
            obj.draw_borderbottom = 100;
            
            obj.text_pause = 0.2;
            obj.text_size = 20;
            obj.text_linespace = 50;
            
            obj.timebar_rect = [0,0,0,0];
            
            obj.audioport = [];
            
            if IsWin
                obj.kb_numbers   = 48:57;
                obj.kb_chars     = [65:90];
                obj.kb_space     = 32;
                obj.kb_return    = 13;
                obj.kb_escape    = 27;
                obj.kb_backspace = 8;
            elseif ismac
                obj.kb_numbers   = 30:39;
                obj.kb_chars     = 4:29;
                obj.kb_space     = 44;
                obj.kb_return    = 40;
                obj.kb_escape    = 41;
                obj.kb_backspace = 42;
            else
                obj.kb_numbers   = 11:20;
                obj.kb_chars     = [25:34,39:47,53:59];
                obj.kb_space     = 66;
                obj.kb_return    = 37;
                obj.kb_escape    = 10;
                obj.kb_backspace = 23;
            end
            
            obj.eyelink = [];
            obj.eyelink_eye = -1;
            
            obj.run_maps = 0;
            obj.run_trainmaps = 0;
            obj.run_trials = 0;
        end
        
        % monitor methods =================================================
        % open / close ----------------------------------------------------
        % open the monitor
        function obj = monitor_open(obj,use,i_subject)
            obj.use = use;
            if use(1)
                ListenChar(2);
                obj.screen_open();
                if use(2)
                    obj.audioport_open();
                end
                if use(3)
                    obj.eyelink_open(i_subject);
                end
            end
        end
        function obj = monitor_close(obj)
            if obj.use(1)
                ListenChar(0);
                obj.screen_close();
                if obj.use(2)
                    obj.audioport_close();
                end
                if obj.use(3)
                    obj.eyelink_stop();
                end
            end
            obj.use = [0 0 0];
        end
        
        % run methods =====================================================
        % set the run variables from the main class
        function obj = set_runs(obj,run_maps,run_trainmaps,run_trials)
            obj.run_maps = run_maps;
            obj.run_trainmaps = run_trainmaps;
            obj.run_trials = run_trials;
        end
        
        % read methods ====================================================
        % read keyboard
        function [key_code,mouse_pos,mouse_buttons] = keymouse_read(~)
            % keyboard
            [~, ~, key_code] = KbCheck;
            % mouse
            [mouse_x,mouse_y,mouse_buttons] = GetMouse();
            mouse_pos = [mouse_x,mouse_y];
        end

        % screen methods ==================================================
        % open / close ----------------------------------------------------
        % open the screen
        function obj = screen_open(obj)
            AssertOpenGL;
            Screen('Preference','Verbosity',0);
            Screen('Preference','SkipSyncTests',2);
            [obj.screen_window,obj.screen_rect]=Screen('OpenWindow',0,255,[0,0,1080,810],[],2,0,16);
            %[obj.screen_window,obj.screen_rect]=Screen('OpenWindow',0,255,[],[],2,0,16);
            %obj.screen_rect = [0,0,1024,1280];
            Screen('Blendfunction',obj.screen_window,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

        end
        % close the screen
        function obj = screen_close(obj)
            Screen('CloseAll');
            Screen('Preference', 'SkipSyncTests', 0);
            obj.screen_window = [];
            obj.screen_rect = [0 0 0 0];
        end

        % generic ---------------------------------------------------------
        % generic text screen
        function obj = screen_text(obj,nx,ny,text)
            % text size
            Screen('TextSize', obj.screen_window, obj.text_size);
            if ~nx
                nx = 'center';
            end
            % for each text line
            for text_line = text
                % text y position
                if ny
                    ny = ny+obj.text_linespace;
                else
                    ny = 'center';
                end
                % draw
                [~,ny,~] = DrawFormattedText(obj.screen_window,char(text_line),nx,ny);
            end
            Screen(obj.screen_window, 'Flip');
            % pause
            pause(obj.text_pause);
            % wait until keyboard/mouse event
            key_code = 0;
            mouse_buttons = 0;
            while ~(any(key_code) || any(mouse_buttons))
                [key_code,~,mouse_buttons] = obj.keymouse_read();
            end
        end
        % generic input screen
        function answer = screen_interaction(obj,nums,chars,text)
            answer = '';
            ok = 0;
            while ~ok || isempty(answer)
                % draw in screen
                ok = 0;
                if isempty(answer)
                    obj.screen_text(0,0,{text});
                else
                    obj.screen_text(0,0,{text,' ',answer});
                end
                
                % read from keyboard
                key_code = obj.keymouse_read();
                
                % apply to answer
                key_num = find(key_code);
                if ~isempty(key_num)
                    key_num = key_num(1);
                    if any(find(key_code)==obj.kb_return)
                        % enter
                        ok = 1;
                    elseif any(find(key_code)==obj.kb_backspace) && ~isempty(answer)
                        % backspace
                        answer(end) = [];
                    elseif nums && any(find(key_code)==obj.kb_numbers)
                        % number digits
                        n = KbName(key_num);
                        answer = [answer n(1)];
                    elseif chars
                        % chars
                        if any(find(key_code)==obj.kb_space)
                            % space
                            answer = [answer ' '];
                        elseif any(find(key_code,1)==obj.kb_chars)
                            % normal characters
                            ch = KbName(key_num);
                            answer = [answer ch(1)];
                        end
                    end
                end
            end
        end
        
        % training --------------------------------------------------------
        % start training screen
        function obj = screen_pretrain(obj)
            obj.screen_text(0,0,{'Training',' ',' ','You will can train with this first map to be','used with the interface'});
        end
        % stop training screen
        function obj = screen_posttrain(obj)
            obj.screen_text(0,0,{'End of training',' ',' ','We now will start with the main experiment'});
        end
        
        % map -------------------------------------------------------------
        % start training map screen
        function obj = screen_pretrainmap(obj,run_map)
            obj.screen_text(0,0,{['Map nº ',num2str(run_map),' of ',num2str(obj.run_trainmaps)],['Remember you will have ',num2str(obj.run_trials),' trials for each map']});
        end
        % start map screen
        function obj = screen_premap(obj,run_mapwithouttrain)
            obj.screen_text(0,0,{['Map nº ',num2str(run_mapwithouttrain),' of ',num2str(obj.run_maps-obj.run_trainmaps)],['Remember you will have ',num2str(obj.run_trials),' trials for each map']});
        end
        % quest screen
        function obj = screen_quest(obj)
            obj.screen_text(0,0,{'Speed of lines?'});
        end
        
        % trial -----------------------------------------------------------
        % start trial screen
        function obj = screen_pretrial(obj,run_mapwithouttrain,run_trial)
            if run_mapwithouttrain > 0
                obj.screen_text(0,0,{ ...
                    ['Map nº ',num2str(run_mapwithouttrain),' of ',num2str(obj.run_maps-obj.run_trainmaps)] ...
                    ['Trial nº ',num2str(run_trial),' of ',num2str(obj.run_trials)] ...
                    });
            else
                obj.screen_text(0,0,{ ...
                    ['Trial nº ',num2str(run_trial),' of ',num2str(obj.run_trials)] ...
                    });
            end
        end
        
        % time ------------------------------------------------------------
        % no time screen
        function obj = screen_notime(obj)
            obj.screen_text(0,0,{ ...
                    'The journey was too long!' ...
                    });
        end
        
        % clicking --------------------------------------------------------
        % no time screen
        function obj = screen_noclicking(obj)
            obj.screen_text(0,0,{ ...
                    'Time expired' ...
                    });
        end
        
        % audioport methods ===============================================
        % open audio port
        function obj = audioport_open(obj)
            PsychPortAudio('Verbosity',0);
            InitializePsychSound;
            try
                obj.audioport = PsychPortAudio('Open', [], [], 1, [], 1);
            catch
                psychlasterror('reset');
                obj.audioport = PsychPortAudio('Open', [], [], 1, [], 1);
            end
        end
        % close audio port
        function obj = audioport_close(obj)
            PsychPortAudio('Close', obj.audioport);
            obj.audioport = [];
        end
        
        % eyelink methods =================================================
        % open eyelink
        function obj = eyelink_open(obj,i_subject)
            dummy = 0;
            
            % initialization
            if ~EyelinkInit(dummy, 1)
                fprintf('main_monitor: eyelink_open: error in EyelinkInit\n');
                obj.close_monitor();
                return;
            end
            obj.eyelink = EyelinkInitDefaults(obj.screen_window);
            obj.eyelink_cmd('link_sample_data = LEFT,RIGHT,GAZE,AREA');

            % file
            %obj.eyelink_edf = ['subway',num2str(i_subject),'.edf'];
            obj.eyelink_edf = sprintf('subway%d.edf',i_subject);
            Eyelink('Openfile', obj.eyelink_edf);
        end
        
        % calibrate eyelink
        function obj = eyelink_calib(obj)
            if obj.use(3)
                obj.eyelink_stop();
                EyelinkDoTrackerSetup(obj.eyelink);
                %EyelinkDoDriftCorrection(obj.eyelink);                  % what was that for??????????????
                Screen('FillRect', obj.screen_window, 255);
                obj.eyelink_start();
            end
        end
        
        % start eyelink
        function obj = eyelink_start(obj)
            if obj.use(3)
                Eyelink('StartRecording');
                WaitSecs(0.1);
                obj.eyelink_msg('SYNCTIME');
            end
        end
        
        % send a message
        function obj = eyelink_msg(obj,msg)
            if obj.use(3)
                Eyelink('Message',msg);
            else
                fprintf(['main_monitor: eyelink_msg: ',msg,'\n']);
            end
        end
        
        % send a command
        function obj = eyelink_cmd(obj,cmd)
            if obj.use(3)
                Eyelink('Command',cmd);
            end
        end
        
        % get gaze position
        function [x,y] = eyelink_get(obj)
            if obj.use(3)
                error = Eyelink('CheckRecording');
                if(error~=0)
                    obj.monitor_close();
                    error('main_monitor: eyelink_get: eyelink not recording\n');
                end
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt = Eyelink('NewestFloatSample');
                    if obj.eyelink_eye ~= -1
                        x = evt.gx(obj.eyelink_eye+1);
                        y = evt.gy(obj.eyelink_eye+1);
                        if x==obj.eyelink.MISSING_DATA || ...
                           y==obj.eyelink.MISSING_DATA || ...
                           evt.pa(obj.eyelink_eye+1) < 1
                            x = -1;
                            y = -1;
                        end
                    else
                        obj.eyelink_eye = Eyelink('EyeAvailable');
                        if obj.eyelink_eye == obj.eyelink.BINOCULAR;
                            obj.eyelink_eye = obj.eyelink.LEFT_EYE;
                        end
                        x = -2;
                        y = -2;
                    end
                else
                    x = -3;
                    y = -3;
                end
            else
                x = -4;
                y = -4;
            end
        end
        
        % draw gaze position
        function obj = eyelink_draw(obj)
            [gaze_x,gaze_y] = obj.eyelink_get();
            gaze_rayon = 5;
            gaze_rect = [gaze_x - gaze_rayon , gaze_y - gaze_rayon , ...
                         gaze_x + gaze_rayon , gaze_y + gaze_rayon];
            Screen('FillOval', obj.screen_window, [255,0,0], gaze_rect);
        end

        % stop eyelink
        function obj = eyelink_stop(obj)
            if obj.use(3)
                WaitSecs(0.1);
                Eyelink('StopRecording');
            end
        end
        
        % fetch edf file
        function obj = eyelink_file(obj)
            if obj.use(3)
                Eyelink('CloseFile');
                dest = ['gaze/',obj.eyelink_edf];
                Eyelink('ReceiveFile',obj.eyelink_edf,dest);
            end
        end
        
        % map methods =====================================================
        % resize the map to the screen resolution
        function obj = map_resize(obj,main_map)
            % map rect
            obj.screen_maprect = [obj.screen_rect(1)+obj.draw_bordersides, obj.screen_rect(2)+obj.draw_bordertop, obj.screen_rect(3)-obj.draw_bordersides, obj.screen_rect(4)-obj.draw_borderbottom];
            % timebar rect
            bottom_rect = [0,obj.screen_rect(4)-obj.draw_borderbottom,obj.screen_rect(3),obj.screen_rect(4)];
            obj.timebar_rect = bottom_rect;
            % resize
            main_map.resize_map(1,obj.screen_maprect,obj.timebar_rect);
        end
        % draw simple map (without avatar, flag, options)
        function obj = map_simpledraw(obj,main_map)
            main_map.draw_map(obj.screen_window, obj.screen_rect);        % subway_map
            Screen(obj.screen_window, 'Flip');
        end
        % draw the map and the timebar
        % used while planning and moving
        function obj = map_timedraw(obj,main_map,text)
            if ~exist('text','var')
                text = '';
            end
            main_map.draw_map(obj.screen_window, obj.screen_rect);        % subway_map
            main_map.main_avatar.draw(obj.screen_window, obj.screen_rect, main_map.main_stations, main_map.main_sublines); % avatar
            main_map.main_timebar.draw(obj.screen_window);                % timebar
            DrawFormattedText(obj.screen_window,text,'center',.5*obj.draw_bordertop);
            Screen(obj.screen_window, 'Flip');
        end
        % draw the map, with options
        % used in quest
        function obj = map_optionsdraw(obj,main_map,text)
            if ~exist('text','var')
                text = '';
            end
            main_map.draw_options(obj.screen_window,obj.screen_rect);     % options
            main_map.draw_map(obj.screen_window, obj.screen_rect);        % subway_map
            DrawFormattedText(obj.screen_window,text,'center',.5*obj.draw_bordertop);
            Screen(obj.screen_window, 'Flip');
        end
        % draw the map, with time and options
        % used while clicking
        function obj = map_timeoptionsdraw(obj,main_map,text)
            if ~exist('text','var')
                text = '';
            end
            main_map.draw_options(obj.screen_window,obj.screen_rect);     % options
            main_map.draw_map(obj.screen_window, obj.screen_rect);        % subway_map
            main_map.main_avatar.draw(obj.screen_window, obj.screen_rect, main_map.main_stations, main_map.main_sublines); % avatar
            main_map.main_timebar.draw(obj.screen_window);                % timebar
            DrawFormattedText(obj.screen_window,text,'center',.5*obj.draw_bordertop);
            Screen(obj.screen_window, 'Flip');
        end
        % draw map with topology number
        % used with show_maps([i_maps])
        function obj = map_topologydraw(obj,main_map)
            main_map.draw_map(obj.screen_window, obj.screen_rect);        % subway_map
            main_map.main_avatar.draw(obj.screen_window, obj.screen_rect, main_map.main_stations, main_map.main_sublines); % avatar
            main_map.draw_topology(obj.screen_window, obj.screen_rect);
            Screen(obj.screen_window, 'Flip');
        end
        % draw the map with gaze position
        % used when checking eye-tracker
        function obj = map_eyelinkdraw(obj,main_map)
            if obj.use(3)   % eyelink gaze drawing
                main_map.draw_map(obj.screen_window, obj.screen_rect);        % subway_map
                obj.eyelink_draw();
                Screen(obj.screen_window, 'Flip');
            end
        end
        % draw map with eyelink gaze
        % used when checking eye-tracker
        function obj = map_eyelinkcheck(obj,main_map)
            if obj.use(3)
                % empty keyboard/mouse buffer
                [~,~,mouse_buttons] = obj.keymouse_read();
                while any(mouse_buttons)
                    [~,~,mouse_buttons] = obj.keymouse_read();
                end
                % loop
                ok = 0;
                while ~ok
                    % draw map
                    obj.map_eyelinkdraw(main_map);
                    
                    % read from keyboard/mouse
                    [key_code,~,mouse_buttons] = obj.keymouse_read();

                    % apply to answer
                    if any(find(key_code)==obj.kb_escape)
                        % go out
                        ok = 1;
                    elseif any(mouse_buttons)
                        % calibrate
                        obj.eyelink_calib();
                    end
                end
            end
        end
    end
end

