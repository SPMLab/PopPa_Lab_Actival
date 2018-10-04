classdef sleep_algorithm
    
    properties
    end
    
    methods (Static)
        function manual(varargin)
        end
        
        function activpal_data = deMaastricht(activpal_data, start_date, end_date)
            activpal_datenum = datenum(activpal_data{1});
            startnum = datenum(start_date);
            endnum = datenum(end_date);
            
            time_frame = activpal_datenum((activpal_datenum >= startnum) & (activpal_datenum <= endnum));
            
            
            
            %             etime(datevec(datetime('22-Jan-2018 19:00:00')),datevec(datetime('23-Jan-2018 12:00:00')))
            %             1.791669999947771  - 2.5
            %             x = abs(floor(datenum(activpal_data{1})) - datenum(activpal_data{1}))
            
            
        end
        
        function [handles, logstr] = insertWake(handles, time_selected, InsertDay)
            
            insertion_datenum = datenum(datestr(horzcat(datestr(InsertDay), ' ', time_selected)));
            activpal_data_datenum = datenum(handles.activpal_data.memory{1});
            activpal_data_matrix = handles.activpal_data.memory{2};
            
            activities = {'Sedentary', 'Standing', 'Stepping'};
            [~, k] = min(abs(activpal_data_datenum-insertion_datenum));
            activpal_data_matrix(k,end) = 2; 
            switch activpal_data_matrix(k,3)
                case 0
                    action = activities{1};
                case 1
                    action = activities{2};
                case 2
                    action = activities{3};
            end
            
            activpal_data_matrix(k,end) = 2; 
            
            logstr = horzcat('Wake Time Marked at ', datestr(activpal_data_datenum(k)),  ' as ', action);
            handles.activpal_data.memory = {datetime(datestr(activpal_data_datenum)), activpal_data_matrix};
        end
        
        function [handles, logstr] = insertSleep(handles, time_selected, InsertDay)
            
            insertion_datenum = datenum(datestr(horzcat(datestr(InsertDay), ' ', time_selected)));
            activpal_data_datenum = datenum(handles.activpal_data.memory{1});
            activpal_data_matrix = handles.activpal_data.memory{2};
            
            activities = {'Sedentary', 'Standing', 'Stepping'};
            [~, k] = min(abs(activpal_data_datenum-insertion_datenum));
            activpal_data_matrix(k,end) = 2;
            switch activpal_data_matrix(k,3)
                case 0
                    action = activities{1};
                case 1
                    action = activities{2};
                case 2
                    action = activities{3};
            end
            
            activpal_data_matrix(k,end) = 3;
            
            logstr = horzcat('Sleep Time Marked at ', datestr(activpal_data_datenum(k)),  ' as ', action);
            handles.activpal_data.memory = {datetime(datestr(activpal_data_datenum)), activpal_data_matrix};
        end
        
        
        function prolongedAlgo(varargin)
        end
        
    end
end