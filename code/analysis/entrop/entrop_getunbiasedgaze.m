%{
    remove centrality biases

    requires previous calculations...

    e = eyelink();
    e.get_gaze();
    e.get_clusters();
    e.get_smoothedstations();
    e.save();
%}

function entrop_getunbiasedgaze()
    
    entropy_player = 'god';
    entropy_dir = 'entropies';
    entropy_valdir = 'values';
    entropy_subdir = 'unbiasedgaze';
    entropy_prefile = 'ent_';
    
    % create folders ------------------------------------------------------
    if ~exist(entropy_dir,'dir')
        mkdir(entropy_dir);
    end
    if ~exist([entropy_dir,filesep,entropy_valdir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir]);
    end
    if ~exist([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir]);
    end

    % load eyelink
    e = eyelink.load();
    
    % numbers
    nb_participants = length(e.smoothedstations);
    
    for i_participant = 1:nb_participants
        fprintf(['entrop_getunbiasedgaze: participant ',num2str(i_participant),'\n']);

        % calculate betas - - - - - - - - - - - - - - - - - - - - - - - - -
        % load seq
        load(['sequences/seq_',num2str(i_participant),'.mat']);
        % initialise values
        yg = [];
        xr = [];
        xlr = [];
        for i_map = 2:length(e.smoothedstations{i_participant})
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            map = e.eyelink_map.main_map;
            
            % load radius
            radius_map = load(['entropies/values/radius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            radius_map = radius_map.radius;
            % load localradius
            localradius_map = load(['entropies/values/localradius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            localradius_map = localradius_map.localradius;
            % numbers
            nb_stations = length(localradius_map);
            nb_trials   = length(e.smoothedstations{i_participant}{i_map});

            for i_trial = 1:nb_trials
                duration = e.mm_durations(i_participant,i_map,i_trial,1);
                duration_ok = duration>3900 && duration<4100;
                % NOTE
                %{
                    TRIALS WITH MORE EXCHANGE STATIONS WILL COUNT MORE!!!
                %}
                if duration_ok
                    % gaze values
                    yg = [yg,e.smoothedstations{i_participant}{i_map}{i_trial}{1}];
                    % radial values
                    xr = [xr,radius_map];
                    xlr = [xlr,localradius_map(i_trial,:)];
                end
            end
        end

        % coefficients of the regression
        xrs = [xr;xlr];
        beta_r = tools_regress(yg',xrs')';

        % calculate residual errors (for each trial) - - - - - - - - - - - 
        for i_map = 2:length(e.smoothedstations{i_participant})
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            map = e.eyelink_map.main_map;
            
            % load radius
            radius_map = load(['entropies/values/radius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            radius_map = radius_map.radius;
            nb_stations = length(radius_map);
            
            % load localradius
            localradius_map = load(['entropies/values/localradius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            localradius_map = localradius_map.localradius;

            % numbers
            nb_stations = length(localradius_map);
            nb_trials   = length(e.smoothedstations{i_participant}{i_map});

            unbiasedgaze = nan(nb_trials,nb_stations);
            for i_trial = 1:nb_trials
                % gaze values
                yg = e.smoothedstations{i_participant}{i_map}{i_trial}{1};
                % radius values
                xr = radius_map;
                xlr = localradius_map(i_trial,:);
                xrs = [xr;xlr];
                % residual error
                unbiasedgaze(i_trial,:) = yg-(beta_r*xrs);
            end
            
            % save
            fprintf(['                                        map ',num2str(seq_maps(i_map)),': saving in file\n']);
            save([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_prefile,num2str(seq_maps(i_map))],'unbiasedgaze');
        end
    end
end
