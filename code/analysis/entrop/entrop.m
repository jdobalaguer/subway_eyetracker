classdef entrop < handle
    % class for the entropy analysis
    
    properties
        likegod

        regression
        localregression
        unbiasedregression
        unbiasedlocalregression

        correlation
        unbiasedcorrelation
    end
    
    methods
        % constructor
        function obj = entrop()
        end
        
        % features in the data --------------------------------------------
        % see for which trials god and human overlap in their path
        % (~ human are optimal)
        function get_likegod(obj)
            obj.likegod = {};
            entrop_likegod(obj);
        end
        
        % models ----------------------------------------------------------
        % create entropy files for all maps
        % (calculates the entropy at each station, given the god player)
        function get_radius(~)
            entrop_getradius();
        end
        
        % create entropy files for all maps
        % (calculates the entropy at each station, given the god player)
        function get_entropy(~)
            entrop_getentropy();
        end
        
        % create bottleneck files for all maps
        % (calculates the bottleneckness at each station, given the god player)
        function get_bottleneck(~)
            entrop_getbottleneck();
        end
        
        % create localentropy files for all maps
        % (calculates the entropy at each station, given the forwardsoftmax player)
        function get_localentropy(~)
            entrop_getlocalentropy();
        end
        
        % create localbottleneck files for all maps
        % (calculates the bottleneckness at each station, given the forwardsoftmax player)
        function get_localbottleneck(~)
            entrop_getlocalbottleneck();
        end
        
        % create localbottleneck files for all maps
        % (calculates the bottleneckness at each station, given the forwardsoftmax player)
        function get_localradius(~)
            entrop_getlocalradius();
        end

        % regressions -----------------------------------------------------
        % linear regression of gaze data and models
        function get_regression(obj)
            entrop_getregression(obj);
        end
        
        % plot regression errors
        function plot_regressionerrors(obj)
            figure;
            tools_dotplot([obj.regression.err_c; ...
                            obj.regression.err_e; ...
                            obj.regression.err_b; ...
                            obj.regression.err_r; ...
                            obj.regression.err_le; ...
                            obj.regression.err_lb; ...
                            obj.regression.err_lr]');
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
            
            figure;
            tools_dotplot([obj.regression.err2_c; ...
                            obj.regression.err2_e; ...
                            obj.regression.err2_b; ...
                            obj.regression.err2_r; ...
                            obj.regression.err2_le; ...
                            obj.regression.err2_lb; ...
                            obj.regression.err2_lr]');
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
        end
        
        % plot regression errors
        function plot_regressionbetas(obj)
            figure;
            tools_dotplot(obj.regression.beta_all);
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
        end

        % local regressions -----------------------------------------------
        % linear regression of gaze data and models
        function get_localregression(obj)
            entrop_getlocalregression(obj);
        end
        
        % correlations ----------------------------------------------------
        % correlation of gaze data and models
        function get_correlation(obj)
            entrop_getcorrelation(obj);
        end
        
        % plot correlation coefficients
        function plot_correlation(obj)
            entrop_plotcorrelation(obj);
        end
        
        % merge all correlations (number of cross_stations in the path)
        function merge_correlation(obj)
            entrop_mergecorrelation(obj);
        end
        
        % plot merge correlation coefficients
        function plot_mergecorrelation(obj)
            entrop_plotmergecorrelation(obj);
        end
        
        % local correlations ----------------------------------------------
        function get_localcorrelation(obj)
            entrop_getlocalcorrelation(obj);
        end
        
        % unbiased correlations -------------------------------------------
        function get_unbiasedcorrelation(obj)
            entrop_getunbiasedcorrelation(obj);
        end
        function plot_unbiasedcorrelation(obj)
            entrop_plotunbiasedcorrelation(obj);
        end
        function merge_unbiasedcorrelation(obj)
            entrop_mergeunbiasedcorrelation(obj);
        end
        function plot_mergeunbiasedcorrelation(obj)
            entrop_plotmergeunbiasedcorrelation(obj);
        end
        
        % unbiased regressions --------------------------------------------
        % remove radial biases
        function get_unbiasedgaze(obj)
            entrop_getunbiasedgaze();
        end
        
        function get_unbiasedregression(obj)
            entrop_getunbiasedregression(obj);
        end
        
        % plot unbiasedregression errors
        function plot_unbiasedregressionerrors(obj)
            figure;
            tools_dotplot([obj.unbiasedregression.err_c; ...
                            obj.unbiasedregression.err_e; ...
                            obj.unbiasedregression.err_b; ...
                            obj.unbiasedregression.err_r; ...
                            obj.unbiasedregression.err_le; ...
                            obj.unbiasedregression.err_lb; ...
                            obj.unbiasedregression.err_lr]');
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
            
            figure;
            tools_dotplot([obj.unbiasedregression.err2_c; ...
                            obj.unbiasedregression.err2_e; ...
                            obj.unbiasedregression.err2_b; ...
                            obj.unbiasedregression.err2_r; ...
                            obj.unbiasedregression.err2_le; ...
                            obj.unbiasedregression.err2_lb; ...
                            obj.unbiasedregression.err2_lr]');
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
        end
        
        % plot unbiasedregression errors
        function plot_unbiasedregressionbetas(obj)
            figure;
            tools_dotplot(obj.unbiasedregression.beta_all);
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
        end
        
        function get_unbiasedlocalregression(obj)
            entrop_getunbiasedlocalregression(obj);
        end

        % unbiased local regressions --------------------------------------
        
        % plot unbiasedlocalregression errors
        function plot_unbiasedlocalregressionerrors(obj)
            figure;
            tools_dotplot([obj.unbiasedlocalregression.err_c; ...
                            obj.unbiasedlocalregression.err_e; ...
                            obj.unbiasedlocalregression.err_b; ...
                            obj.unbiasedlocalregression.err_r; ...
                            obj.unbiasedlocalregression.err_le; ...
                            obj.unbiasedlocalregression.err_lb; ...
                            obj.unbiasedlocalregression.err_lr]');
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
            
            figure;
            tools_dotplot([obj.unbiasedlocalregression.err2_c; ...
                            obj.unbiasedlocalregression.err2_e; ...
                            obj.unbiasedlocalregression.err2_b; ...
                            obj.unbiasedlocalregression.err2_r; ...
                            obj.unbiasedlocalregression.err2_le; ...
                            obj.unbiasedlocalregression.err2_lb; ...
                            obj.unbiasedlocalregression.err2_lr]');
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
        end
        
        % plot unbiasedlocalregression errors
        function plot_unbiasedlocalregressionbetas(obj)
            figure;
            tools_dotplot(obj.unbiasedlocalregression.beta_all);
            set(gca,'xtick',1:7);
            set(gca,'xticklabel',{'c','e','b','r','le','lb','lr'});
        end

        % plots -----------------------------------------------------------
        function plot_r(~)
            entrop_plotr();
        end
        function plot_lb(~)
            entrop_plotlb();
        end
        function plot_unbiasedlb(~)
            entrop_plotunbiasedlb();
        end
        function plot_lr(~)
            entrop_plotlr();
        end

    % save/load -----------------------------------------------------------
        % save the map into a file
        function obj = save(obj)
            ep = obj;
            save(entrop.savefile(),'ep');
        end
    end
    methods(Static)
        % load the map from a file
        function ep = load()
            load(entrop.savefile(),'ep');
        end
        
        % give the path where to save
        function f = savefile()
            f = 'analysis_files/entropy.mat';
        end
    end
end
    
