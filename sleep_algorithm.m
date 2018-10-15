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
            handles.wake_insert.Value = 1; 
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
            handles.sleep_insert.Value = 1; 
            logstr = horzcat('Sleep Time Marked at ', datestr(activpal_data_datenum(k)),  ' as ', action);
            handles.activpal_data.memory = {datetime(datestr(activpal_data_datenum)), activpal_data_matrix};
        end
       
        function handles = Sleep_AlgoSelection(handles, selection)
            switch selection
                case 1
                    handles.wakeSleep_method_closest.Checked = 'on';
                    handles.wakeSleep_method_DeM.Checked = 'off';
                    handles.wakeSleep_method_Manual.Checked = 'off';
                case 2
                    handles.wakeSleep_method_closest.Checked = 'off';
                    handles.wakeSleep_method_DeM.Checked = 'off';
                    handles.wakeSleep_method_Manual.Checked = 'on';
                case 3
                    handles.wakeSleep_method_closest.Checked = 'off';
                    handles.wakeSleep_method_DeM.Checked = 'on';
                    handles.wakeSleep_method_Manual.Checked = 'off';
            end
        end
        
        function val = Check_Sleep_Algo(handles)
  
            checks = {handles.wakeSleep_method_closest.Checked; handles.wakeSleep_method_Manual.Checked; handles.wakeSleep_method_DeM.Checked};
            val = find(cellfun(@(x)strcmp(x, 'on'), checks, 'UniformOutput', true)); 
            
        end 
        
        function prolongedAlgo(varargin)
        end
        
    end
end