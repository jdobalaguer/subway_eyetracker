classdef eyelink_process
    % class for processing eyelink data
    
    properties
    end
    
    methods
        % constructor
        function obj = eyelink_process()
        end
    end
    methods(Static)
        % fixation --------------------------------------------------------
        % detect eye fixation
        % subgaze(i,:) = [time,x,y]
        % clusters(i,:) = [time,nb_samples,x,y]
        function clusters = eyelink_detfix(subgaze)
            clusters = eyelink_process.eyelink_detfix2(subgaze);
        end
        
        
        % first method -- DEPRECATED ######
        %   new cluster candidate when next sample is far enough (so group only neighbours)
        %   discard fixation candidates by minimum of samples
        function clusters = eyelink_detfix1(subgaze)
            max_dist = 100;
            min_points = 3;
            
            clusters = [];
            while ~isempty(subgaze)
                i_subgaze = 1;
                
                % while same cluster
                pos = subgaze(i_subgaze,[2,3]);
                mean_pos = pos;
                time = subgaze(i_subgaze,1);
                mean_time = time;
                dist = 0;
                while dist < power(max_dist,2)
                    % cluster mean (pos,time)
                    mean_pos = (i_subgaze*mean_pos + pos)/(i_subgaze+1);
                    mean_time = (i_subgaze*mean_time + time)/(i_subgaze+1);
                    % eoa
                    if i_subgaze == size(subgaze,1)
                        break
                    end
                    % index
                    i_subgaze = i_subgaze + 1;
                    % pos, time
                    pos = subgaze(i_subgaze,[2,3]);
                    time = subgaze(i_subgaze,1);
                    % cut with NaN
                    if isequalwithequalnans(pos,[NaN,NaN])
                        break
                    end
                    % distance
                    dist = sum(power(pos-mean_pos,2));
                end
                
                % add cluster
                if i_subgaze >= min_points
                    clusters = [ clusters ; mean_time,i_subgaze,mean_pos];
                end
                % empty subgaze
                subgaze(1:i_subgaze,:) = [];
            end
        end
        
    % second method
    %   new cluster candidate when next sample is far enough (so group only neighbours)
    %   discard cluster candidates by maximum of samples
    %   discard cluster candidates by minimum of curvature
    function clusters = eyelink_detfix2(subgaze)
        max_dist = 60;
        min_points = 3;
        min_curv = .3;
        
        % check
        if isempty(subgaze) || all(all(isnan(subgaze(:,[2,3]))))
            clusters = [];
            return
        end
        % split subgaze
        c_subgaze = {};
        c_subgaze{1} = [];
        i_csubgaze = 1;
        for i_subgaze = 1:size(subgaze,1)
            % if nan's
            if all(isnan(subgaze(i_subgaze,[2,3,4])))
                % if not 3 points, remove it
                if size(c_subgaze{i_csubgaze},1)<3
                    c_subgaze{i_csubgaze} = [];
                    
                % if more, add vector
                else
                    i_csubgaze = i_csubgaze + 1;
                    c_subgaze{i_csubgaze} = [];
                end
            % add point
            else
                c_subgaze{i_csubgaze} = [ c_subgaze{i_csubgaze} ; subgaze(i_subgaze,:)];
            end
        end
        % for each trajectory
        clusters = [];
        for i_csubgaze = 1:length(c_subgaze)
            if size(c_subgaze{i_csubgaze},1)>3
                vc = zeros(1,size(c_subgaze{i_csubgaze},1)-2);
                % curvature 
                for i_vc = 2:(size(c_subgaze{i_csubgaze},1)-1)
                    x = c_subgaze{i_csubgaze}((i_vc-1):(i_vc+1),2);     % x vector (3 points)
                    y = c_subgaze{i_csubgaze}((i_vc-1):(i_vc+1),3);     % y vector (3 points)
                    % < copy-paste code >
                    A = [x.^2+y.^2,x,y,ones(size(x))];                  % set up least squares problem
                    [~,~,V] = svd(A,0);                                 % use economy version sing. value decompos.
                    a = V(1,4);                                         % choose eigenvector from V with smallest eigenvalue
                    b = V(2,4);
                    c = V(3,4);
                    d = V(4,4);
                    xc = -b/(2*a);                                      % find center and radius of the circle, a*(x^2+y^2)+b*x+c*y+d=0
                    yc = -c/(2*a);
                    r = sqrt(xc^2+yc^2-d/a);
                    % < / copy-paste code >
                    vc(i_vc-1) = inv(r);                                % add curvature to vector
                end

                % remove first and last points from c_subgaze{i_csubgaze}
                % (align vc and c_subgaze{i_csubgaze})
                c_subgaze{i_csubgaze}(1,:) = [];
                c_subgaze{i_csubgaze}(end,:) = [];

                % detect fixation points
                while ~isempty(c_subgaze{i_csubgaze})
                    % group points in cluster
                    i_points = 1;
                    for i_xy = 2:size(c_subgaze{i_csubgaze},1)
                        % point 
                        pxy = c_subgaze{i_csubgaze}(i_xy,[2,3]);
                        % cluster pos
                        mxy = [mean(c_subgaze{i_csubgaze}(i_points,2)),mean(c_subgaze{i_csubgaze}(i_points,3))];
                        % distance
                        dist = sum(power(pxy-mxy,2));
                        % update cluster
                        if dist < power(max_dist,2)
                            i_points(end+1) = i_xy;
                        else
                            break
                        end
                    end
                    % add cluster
                    if length(i_points)>=min_points && mean(vc(i_points))>=min_curv
                        mt = mean(c_subgaze{i_csubgaze}(i_points,1));
                        dt = max(c_subgaze{i_csubgaze}(i_points,1)) - min(c_subgaze{i_csubgaze}(i_points,1));
                        mxyp = [mean(c_subgaze{i_csubgaze}(i_points,2)),mean(c_subgaze{i_csubgaze}(i_points,3)),mean(c_subgaze{i_csubgaze}(i_points,4))];
                        % clusters(:,1) = time
                        % clusters(:,2) = d_time
                        % clusters(:,3) = n_samples
                        % clusters(:,4:5) = xy
                        % clusters(:,6) = pupil dilation
                        clusters = [clusters ; mt,dt,length(i_points),mxyp];
                    end
                    % remove points
                    c_subgaze{i_csubgaze}(i_points,:) = [];
                end
            end
        end
    end
        
    % heat map ------------------------------------------------------------
    
    end
    
end

