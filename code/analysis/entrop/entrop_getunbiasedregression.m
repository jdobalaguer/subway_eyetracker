%{
    requires previous calculations...

    e = eyelink();
    e.get_gaze();
    e.get_clusters();
    e.get_smoothedstations();
    e.save();
%}

function entrop_getunbiasedregression(ep)
    
    % load eyelink
    e = eyelink.load();
    
    % numbers
    nb_participants = length(e.smoothedstations);
    
    % initialize values
    beta_c = [];
    beta_e = [];
    beta_b = [];
    beta_r = [];
    beta_le = [];
    beta_lb = [];
    beta_lr = [];
    beta_all = [];
    err_c = [];
    err_e = [];
    err_b = [];
    err_r = [];
    err_le = [];
    err_lb = [];
    err_lr = [];
    err_all = [];
    err2_c = [];
    err2_e = [];
    err2_b = [];
    err2_r = [];
    err2_le = [];
    err2_lb = [];
    err2_lr = [];
    err2_all = [];
    xx_c = [];
    xx_e = [];
    xx_b = [];
    xx_r = [];
    xx_le = [];
    xx_lb = [];
    xx_lr = [];
    yy_g = [];
    
    log = cell(1,nb_participants);
    file = main_file();
    file.set_interface('human');
    
    for i_participant = 1:nb_participants
        fprintf(['entrop_getregression: participant ',num2str(i_participant),'\n']);
        
        % load log
        log{i_participant} = file.tree_read(i_participant);
        
        % load seq
        load(['sequences/seq_',num2str(i_participant),'.mat']);
        
        % initialise regressors
        xc  = [];
        xe  = [];
        xb  = [];
        xr  = [];
        xle = [];
        xlb = [];
        xlr = [];
        yg  = [];

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

            % load radius
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
                
                % cross values
                cross_path = cross_map(in_stations & cross_map);
                
                % gaze values
                gaze_path = unbiasedgaze_map(i_trial,in_stations & cross_map);
                if any(gaze_path)
                    ok = 1;
                else
                    ok = 0;
                    %fprintf(['entrop_getregression: nok: (',num2str(i_participant),';',num2str(i_map),';',num2str(i_trial),')\n']);
                end
                
                % entropy values
                entropy_path = entropy_map(in_stations & cross_map);
                
                % bottleneck values
                bottleneck_path = bottleneck_map(in_stations & cross_map);
                
                % radius values
                radius_path = radius_map(in_stations & cross_map);
                
                % localentropy values
                localentropy_path = localentropy_map(i_trial,in_stations & cross_map);
                
                % localbottleneck values
                localbottleneck_path = localbottleneck_map(i_trial,in_stations & cross_map);
                
                % localradius values
                localradius_path = localradius_map(i_trial,in_stations & cross_map);
                
                % if we have all of the values
                if ok && duration_ok
                    % store regressors
                    xc  = [xc,cross_path];
                    xe  = [xe,entropy_path];
                    xb  = [xb,bottleneck_path];
                    xr  = [xr,radius_path];
                    xle = [xle,localentropy_path];
                    xlb = [xlb,localbottleneck_path];
                    xlr = [xlr,localradius_path];
                    yg  = [yg,gaze_path];
                end
            end
        end
        
        % transform to z-scores ...
        xc = tools_zscore(xc);
        xe = tools_zscore(xe);
        xb = tools_zscore(xb);
        xr = tools_zscore(xr);
        xle = tools_zscore(xle);
        xlb = tools_zscore(xlb);
        xlr = tools_zscore(xlr);
        yg = tools_zscore(yg);
        % get all
        xall = [xc;xe;xb;xr;xle;xlb;xlr];
        % store coefficients of the regression
        beta_c= [beta_c; tools_regress(yg',xc')'];
        beta_e= [beta_e; tools_regress(yg',xe')'];
        beta_b= [beta_b; tools_regress(yg',xb')'];
        beta_r= [beta_r; tools_regress(yg',xr')'];
        beta_le= [beta_le; tools_regress(yg',xle')'];
        beta_lb= [beta_lb; tools_regress(yg',xlb')'];
        beta_lr= [beta_lr; tools_regress(yg',xlr')'];
        beta_all= [beta_all; tools_regress(yg',xall')'];
        % store error
        err_c(end+1) =  mean(abs(yg-(xc*beta_c(end))));
        err_e(end+1) =  mean(abs(yg-(xe*beta_e(end))));
        err_b(end+1) =  mean(abs(yg-(xb*beta_b(end))));
        err_r(end+1) =  mean(abs(yg-(xr*beta_r(end))));
        err_le(end+1) = mean(abs(yg-(xle*beta_le(end))));
        err_lb(end+1) = mean(abs(yg-(xlb*beta_lb(end))));
        err_lr(end+1) = mean(abs(yg-(xlr*beta_lr(end))));
        % store error 2
        err2_c(end+1) = sqrt(mean(power(yg-(xc*beta_c(end)),2)));
        err2_e(end+1) = sqrt(mean(power(yg-(xe*beta_e(end)),2)));
        err2_b(end+1) = sqrt(mean(power(yg-(xb*beta_b(end)),2)));
        err2_r(end+1) = sqrt(mean(power(yg-(xr*beta_r(end)),2)));
        err2_le(end+1) = sqrt(mean(power(yg-(xle*beta_le(end)),2)));
        err2_lb(end+1) = sqrt(mean(power(yg-(xlb*beta_lb(end)),2)));
        err2_lr(end+1) = sqrt(mean(power(yg-(xlr*beta_lr(end)),2)));
        % store regressors
        xx_c = [xx_c , xc];
        xx_e = [xx_e , xe];
        xx_b = [xx_b , xb];
        xx_r = [xx_r , xr];
        xx_le = [xx_le , xle];
        xx_lb = [xx_lb , xlb];
        xx_lr = [xx_lr , xlr];
        yy_g = [yy_g , yg];

    end
    % store regressors
    ep.unbiasedregression = struct();
    ep.unbiasedregression.beta_c = beta_c;
    ep.unbiasedregression.beta_e = beta_e;
    ep.unbiasedregression.beta_b = beta_b;
    ep.unbiasedregression.beta_r = beta_r;
    ep.unbiasedregression.beta_le = beta_le;
    ep.unbiasedregression.beta_lb = beta_lb;
    ep.unbiasedregression.beta_lr = beta_lr;
    ep.unbiasedregression.beta_all = beta_all;
    
    ep.unbiasedregression.err_c = err_c;
    ep.unbiasedregression.err_e = err_e;
    ep.unbiasedregression.err_b = err_b;
    ep.unbiasedregression.err_r = err_r;
    ep.unbiasedregression.err_le = err_le;
    ep.unbiasedregression.err_lb = err_lb;
    ep.unbiasedregression.err_lr = err_lr;
    
    ep.unbiasedregression.err2_c = err2_c;
    ep.unbiasedregression.err2_e = err2_e;
    ep.unbiasedregression.err2_b = err2_b;
    ep.unbiasedregression.err2_r = err2_r;
    ep.unbiasedregression.err2_le = err2_le;
    ep.unbiasedregression.err2_lb = err2_lb;
    ep.unbiasedregression.err2_lr = err2_lr;
    
    ep.unbiasedregression.xx_c = xx_c;
    ep.unbiasedregression.xx_e = xx_e;
    ep.unbiasedregression.xx_b = xx_b;
    ep.unbiasedregression.xx_r = xx_r;
    ep.unbiasedregression.xx_le = xx_le;
    ep.unbiasedregression.xx_lb = xx_lb;
    ep.unbiasedregression.xx_lr = xx_lr;
    ep.unbiasedregression.yy_g = yy_g;
end
