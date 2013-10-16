mm = main_map();

% new stations
mm.main_stations = main_station();
for i=1:49
    mm.main_stations(i) = main_station();
end

% new sublines
mm.main_sublines = main_subline();
for i=1:10
    this_subline = main_subline();
    if mod(i,2)
        this_subline.draw_color = [127,127,127] + round(128*rand(1,3));
    else
        this_subline.draw_color = mm.main_sublines(i-1).draw_color;
    end
    mm.main_sublines(i) = this_subline;
    
end

% link sublines
mm.main_sublines(1).main_stations = [1,2,3,4,12,13,21,33,45,44,49,48,47,46,38,37,29,17,5,6];
mm.main_sublines(2).main_stations = fliplr([1,2,3,4,12,13,21,33,45,44,49,48,47,46,38,37,29,17,5,6]);
mm.main_sublines(3).main_stations = [6,7,8,9,10,11,12,16,20,28,32,36,44,43,42,41,40,39,38,34,30,22,18,14];
mm.main_sublines(4).main_stations = fliplr([6,7,8,9,10,11,12,16,20,28,32,36,44,43,42,41,40,39,38,34,30,22,18,14]);
mm.main_sublines(5).main_stations = [9,15,19,25,31,35,41];
mm.main_sublines(6).main_stations = fliplr([9,15,19,25,31,35,41]);
mm.main_sublines(7).main_stations = 22:28;
mm.main_sublines(8).main_stations = fliplr(22:28);
mm.main_sublines(9).main_stations = [1,6,14];
mm.main_sublines(10).main_stations = fliplr([1,6,14]);

obj = mm;
clear mm;

% link stations
nb_stations = length(obj.main_stations);
nb_sublines = length(obj.main_sublines);
for i_station = 1:nb_stations
    obj.main_stations(i_station).main_sublines = [];
    for i_subline = 1:nb_sublines
        if ismember(i_station,obj.main_sublines(i_subline).main_stations)
            obj.main_stations(i_station).main_sublines(end+1) = i_subline;
        end
    end
end

% x position
stations = [1,2,3,4]; y = 0;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 5:13; y = 1;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 14:16; y = 2;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 17:21; y = 3;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 22:28; y = 4;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 29:33; y = 5;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 34:36; y = y+1;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 37:45; y = y+1;
for station=stations;obj.main_stations(station).draw_position(1)=y;end
stations = 46:49; y = y+1;
for station=stations;obj.main_stations(station).draw_position(1)=y;end

% y position
stations = [1,6,14,18,22,30,34,38,46]; y = 1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end
stations = [7,23,39]; y = y+1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end
stations = [2,8,24,40,47]; y = y+1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end
stations = [9,15,19,25,31,35,41]; y = y+1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end
stations = [3,10,26,42,48]; y = y+1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end
stations = [11,27,43]; y = y+1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end
stations = [4,12,16,20,28,32,36,44,49]; y = y+1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end
stations = [13,21,33,45]; y = y+1;
for station=stations;obj.main_stations(station).draw_position(2)=y;end

% traveltime
nb_sublines = length(obj.main_sublines);
for i_subline = 1:nb_sublines
    obj.main_sublines(i_subline).set_traveltime(1,0,1);
end

% time bar
obj.main_timebar.maxvalue = 50;

% save
save('map_1.mat','obj');
clear all