%{
    requires previous calculations...

    e = eyelink();
    e.get_gaze();
    e.get_clusters();
    e.get_smoothedstations();
    e.save();
%}

function entrop_getunbiasedcorrelation(ep)
    
    % load eyelink
    e = eyelink.load();
    
    % numbers
    nb_participants = length(e.smoothedstations);
    
    % initialize values
    cor_g  = cell(1,nb_participants);
    cor_c  = cell(1,nb_participants);
    cor_e  = cell(1,nb_participants);
    cor_b  = cell(1,nb_participants);
    cor_r  = cell(1,nb_participants);
    cor_le = cell(1,nb_participants);
    cor_lb = cell(1,nb_participants);
    cor_lr = cell(1,nb_participants);
    yy_g   = cell(1,nb_participants);
    xx_c   = cell(1,nb_participants);
    xx_e   = cell(1,nb_participants);
    xx_b   = cell(1,nb_participants);
    xx_r   = cell(1,nb_participants);
    xx_le  = cell(1,nb_participants);
    xx_lb  = cell(1,nb_participants);
    xx_lr  = cell(1,nb_participants);
    
    % initialize log
    log = cell(1,nb_participants);
    file = main_file();
    file.set_interface('human');
    
    for i_participant = 1:nb_participants
        fprintf(['entrop_getcorrelation: participant ',num2str(i_participant),'\n']);
        
        % load log
        log{i_participant} = file.tree_read(i_participant);
        
        % load seq
        load(['sequences/seq_',num2str(i_participant),'.mat']);
        
        % initialize values
        yy_g{i_participant}   = {};
        xx_c{i_participant}   = {};
        xx_e{i_participant}   = {};
        xx_b{i_participant}   = {};
        xx_r{i_participant}   = {};
        xx_le{i_participant}  = {};
        xx_lb{i_participant}  = {};
        xx_lr{i_participant}  = {};
    
        % get values ------------------------------------------------------
        for i_map = 2:length(e.smoothedstations{i_participant})
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            map = e.eyelink_map.main_map;
            nb_stations = length(map.main_stations);
            
            % load gaze
            unbiasedgaze_map = load(['entropies/values/unbiasedgaze/ent_',num2str(seq_maps(i_map)),'.mat']);
            unbiasedgaze_map = unbiasedgaze_map.unbiasedgaze;

            % load entropy
            entropy_map = load(['entropies/values/entropies/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            entropy_map = entropy_map.entropy;
            
            % load bottleneck
            bottleneck_map = load(['entropies/values/bottlenecks/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            bottleneck_map = bottleneck_map.bottleneck;

            % load bottleneck
            radius_map = load(['entropies/values/radius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            radius_map = radius_map.radius;

            % load localentropy
            localentropy_map = load(['entropies/values/localentropies/forwardsoftmax/ent_',num2str(seq_maps(i_map)),'.mat']);
            localentropy_map = localentropy_map.localentropy;

            % load localbottleneck
            localbottleneck_map = load(['entropies/values/localbottlenecks/forwardsoftmax/ent_',num2str(seq_maps(i_map)),'.mat']);
            localbottleneck_map = localbottleneck_map.localbottleneck;
            
            % load localradius
            localradius_map = load(['entropies/values/localradius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
            localradius_map = localradius_map.localradius;
            
            % load crosses
            cross_map = zeros(1,nb_stations);
            for i_station = 1:nb_stations
                if length(map.main_stations(i_station).main_sublines)>2
                    cross_map(i_station) = 1;
                end
            end
            
            for i_trial = 1:length(e.smoothedstations{i_participant}{i_map})
                % route taken
                ii_map   = (log{i_participant}.data.map   == i_map);
                ii_trial = (log{i_participant}.data.trial == i_trial);
                in_stations = zeros(1,nb_stations);
                in_stations(unique(log{i_participant}.data.in_station(ii_map & ii_trial))) = 1;
                
                duration = e.mm_durations(i_participant,i_map,i_trial,1);
                duration_ok = duration>3900 && duration<4100;
                
                sum_crosstations = sum(in_stations & cross_map);
                
                % cross values
                cross_path = cross_map(in_stations & cross_map);
                if any(cross_path)
                    cross_path = cross_path / mean(cross_path);
                end
                
                % gaze values
                gaze_path = unbiasedgaze_map(i_trial,in_stations & cross_map);
                if any(gaze_path)
                    gaze_path = gaze_path / mean(gaze_path);
                    ok = 1;
                else
                    ok = 0;
                    %fprintf(['entrop_getregression: nok: (',num2str(i_participant),';',num2str(i_map),';',num2str(i_trial),')\n']);
                end
                
                % entropy values
                entropy_path = entropy_map(in_stations & cross_map);
                if any(entropy_path)
                    entropy_path = entropy_path / mean(entropy_path);
                else
                    entropy_path = ones(1,length(gaze_path));
                end
                
                % bottleneck values
                bottleneck_path = bottleneck_map(in_stations & cross_map);
                if any(bottleneck_path)
                    bottleneck_path = bottleneck_path / mean(bottleneck_path);
                else
                    bottleneck_path = ones(1,length(gaze_path));
                end
                
                % radius values
                radius_path = radius_map(in_stations & cross_map);
                if any(radius_path)
                    radius_path = radius_path / mean(radius_path);
                else
                    radius_path = ones(1,length(gaze_path));
                end
                
                % localentropy values
                localentropy_path = localentropy_map(i_trial,in_stations & cross_map);
                if any(localentropy_path)
                    localentropy_path = localentropy_path / mean(localentropy_path);
                else
                    localentropy_path = ones(1,length(gaze_path));
                end
                
                % localbottleneck values
                localbottleneck_path = localbottleneck_map(i_trial,in_stations & cross_map);
                if any(localbottleneck_path)
                    localbottleneck_path = localbottleneck_path / mean(localbottleneck_path);
                else
                    localbottleneck_path = ones(1,length(gaze_path));
                end
                
                % localradius values
                localradius_path = localradius_map(i_trial,in_stations & cross_map);
                if any(localradius_path)
                    localradius_path = localradius_path / mean(localradius_path);
                else
                    localradius_path = ones(1,length(gaze_path));
                end
                
                % if we have all of the calues
                if ok && duration_ok
                    % rename values
                    yg = gaze_path;
                    xc = cross_path;
                    xe = entropy_path;
                    xb = bottleneck_path;
                    xr = radius_path;
                    xle = localentropy_path;
                    xlb = localbottleneck_path;
                    xlr = localradius_path;
                    % reshape values
                    l_xx = length(xx_c{i_participant});
                    if l_xx<sum_crosstations
                        yy_g{i_participant}((l_xx+1):sum_crosstations)  = cell(1,sum_crosstations-l_xx);
                        xx_c{i_participant}((l_xx+1):sum_crosstations)  = cell(1,sum_crosstations-l_xx);
                        xx_e{i_participant}((l_xx+1):sum_crosstations)  = cell(1,sum_crosstations-l_xx);
                        xx_b{i_participant}((l_xx+1):sum_crosstations)  = cell(1,sum_crosstations-l_xx);
                        xx_r{i_participant}((l_xx+1):sum_crosstations)  = cell(1,sum_crosstations-l_xx);
                        xx_le{i_participant}((l_xx+1):sum_crosstations) = cell(1,sum_crosstations-l_xx);
                        xx_lb{i_participant}((l_xx+1):sum_crosstations) = cell(1,sum_crosstations-l_xx);
                        xx_lr{i_participant}((l_xx+1):sum_crosstations) = cell(1,sum_crosstations-l_xx);
                    end
                    % store values
                    yy_g{i_participant}{sum_crosstations}  = [yy_g{i_participant}{sum_crosstations}  , yg];
                    xx_c{i_participant}{sum_crosstations}  = [xx_c{i_participant}{sum_crosstations}  , xc];
                    xx_e{i_participant}{sum_crosstations}  = [xx_e{i_participant}{sum_crosstations}  , xe];
                    xx_b{i_participant}{sum_crosstations}  = [xx_b{i_participant}{sum_crosstations}  , xb];
                    xx_r{i_participant}{sum_crosstations}  = [xx_r{i_participant}{sum_crosstations}  , xr];
                    xx_le{i_participant}{sum_crosstations} = [xx_le{i_participant}{sum_crosstations} , xle];
                    xx_lb{i_participant}{sum_crosstations} = [xx_lb{i_participant}{sum_crosstations} , xlb];
                    xx_lr{i_participant}{sum_crosstations} = [xx_lr{i_participant}{sum_crosstations} , xlr];
                end
            end
        end
        
        % calculate correlations ------------------------------------------
        for i_participant = 1:nb_participants
            % initialize correlation variables
            cor_g{i_participant} = nan(1,length(yy_g{i_participant}));
            cor_c{i_participant} = nan(1,length(yy_g{i_participant}));
            cor_e{i_participant} = nan(1,length(yy_g{i_participant}));
            cor_b{i_participant} = nan(1,length(yy_g{i_participant}));
            cor_r{i_participant} = nan(1,length(yy_g{i_participant}));
            cor_le{i_participant} = nan(1,length(yy_g{i_participant}));
            cor_lb{i_participant} = nan(1,length(yy_g{i_participant}));
            cor_lr{i_participant} = nan(1,length(yy_g{i_participant}));
            % get values
            for i_crosstations = 1:length(yy_g{i_participant})
                if length(yy_g{i_participant}{i_crosstations})>2
                    cor_g{i_participant}(i_crosstations)  = tools_corr(yy_g{i_participant}{i_crosstations}',yy_g{i_participant}{i_crosstations}');
                    cor_c{i_participant}(i_crosstations)  = tools_corr(yy_g{i_participant}{i_crosstations}',xx_c{i_participant}{i_crosstations}');
                    cor_e{i_participant}(i_crosstations)  = tools_corr(yy_g{i_participant}{i_crosstations}',xx_e{i_participant}{i_crosstations}');
                    cor_b{i_participant}(i_crosstations)  = tools_corr(yy_g{i_participant}{i_crosstations}',xx_b{i_participant}{i_crosstations}');
                    cor_r{i_participant}(i_crosstations)  = tools_corr(yy_g{i_participant}{i_crosstations}',xx_r{i_participant}{i_crosstations}');
                    cor_le{i_participant}(i_crosstations) = tools_corr(yy_g{i_participant}{i_crosstations}',xx_le{i_participant}{i_crosstations}');
                    cor_lb{i_participant}(i_crosstations) = tools_corr(yy_g{i_participant}{i_crosstations}',xx_lb{i_participant}{i_crosstations}');
                    cor_lr{i_participant}(i_crosstations) = tools_corr(yy_g{i_participant}{i_crosstations}',xx_lr{i_participant}{i_crosstations}');
                end
            end
        end
    end
    
    % store correlations --------------------------------------------------
    ep.unbiasedcorrelation = struct();
    
    % values predicted by each model (+gaze)
    % {nb_participants}{nb_crosstations_in_the_selected_path}
    ep.unbiasedcorrelation.yy_g = yy_g;
    ep.unbiasedcorrelation.xx_c = xx_c;
    ep.unbiasedcorrelation.xx_e = xx_e;
    ep.unbiasedcorrelation.xx_b = xx_b;
    ep.unbiasedcorrelation.xx_r = xx_r;
    ep.unbiasedcorrelation.xx_le = xx_le;
    ep.unbiasedcorrelation.xx_lb = xx_lb;
    ep.unbiasedcorrelation.xx_lr = xx_lr;
    
    % correlations
    % {nb_participants}[nb_crosstations_in_the_selected_path]
    ep.unbiasedcorrelation.cor_g = cor_g;
    ep.unbiasedcorrelation.cor_c = cor_c;
    ep.unbiasedcorrelation.cor_e = cor_e;
    ep.unbiasedcorrelation.cor_b = cor_b;
    ep.unbiasedcorrelation.cor_r = cor_r;
    ep.unbiasedcorrelation.cor_le = cor_le;
    ep.unbiasedcorrelation.cor_lb = cor_lb;
    ep.unbiasedcorrelation.cor_lr = cor_lr;
end
