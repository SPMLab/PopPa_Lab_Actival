classdef AP_data
    
    properties
        
    end
    
    methods (Static)
        
        function handles = initializeActivpalMemory(handles)
            % INITIALIZE ACTIVPAL MEMORY
            handles.activpal_data.working = cell(25, 7); 
            handles.activpal_data.memory = cell(25, 7); 
        end
        
        % IMPORTING ACTIVPAL CSV FILE
        function [handles, start_date, logstr] = import_activpal_func(handles)
            [f1,p1] = uigetfile('*.csv');
            
            % Import Data from Activpal File
            temp_data = csvread(horzcat(p1,f1), 1, 0);
            
            % Julian to Gregorian Conversion
            Datenum_formatIn = 'dd-mmm-yyyy HH:MM:SS';
            dates =  temp_data(:,1);
            date_vector = datevec((dates + datenum('30-12-1899 00:00:00', Datenum_formatIn)), Datenum_formatIn);
            formatted_date = datetime(date_vector);
            
            % Get File Metadata from Filename
            formatSpec_file = '%s%s%s%s%s%s%s%s%s%s';
            filename = textscan(f1,formatSpec_file, 'Delimiter', {' ','-'});
            formatSpec = 'Imported Activpal File\nParticipant: %s\nActivpal Unit: %s\nRecording Started at: %s\nRecording Ended at: %s';
            
            % Set Formated String For GUI
            AP_metadata = sprintf(formatSpec, filename{1}{1}, filename{2}{1}, datestr(formatted_date(1)),  datestr(formatted_date(end)));
            AP_subjectID = str2double(filename{1}{1});
            
            
            % Form Indexs for Day Transitions
            date_transition_indexs = [find(diff(date_vector(:,3)))];
            
            % If Add End of Data Time Point to Indexes
            if date_transition_indexs(end) ~= length(temp_data)
                date_transition_indexs = vertcat(date_transition_indexs, length(temp_data));
            end
            
            AP_datelist = datestr(date_vector(date_transition_indexs,:), 1);
            
            % [activpal_imported_data_datevec, activpal_imported_data, AP_metadata, AP_subjectID, AP_datelist, logstr] 
            
            activpal_data = {formatted_date,  horzcat(temp_data(:,[2:end]), nan(size(temp_data,1),1))}; 
            
            % Find Journal Column from Activpal Metadata
            start_date = handles.journal_data.memory{strcmp(cellstr(num2str(AP_subjectID)), handles.journal_data.memory(:,1)), 3};
            end_date = handles.journal_data.memory{strcmp(cellstr(num2str(AP_subjectID)), handles.journal_data.memory(:,1)), 5};

            
            % Save Activpal Data in Memory
            handles.activpal_data.working = activpal_data; 
            handles.activpal_data.memory = activpal_data;
            
            % Save Activpal Subject ID in Memory
            handles.subject_id = AP_subjectID;
            
            % Print Selected Activpal Metadata in GUI
            set(handles.AP_file_name,'String',AP_metadata, 'FontSize', 8.5);
            
            % Set Datelist for Dropdown Menu Control
            [~, k] = min(abs(datenum(AP_datelist) - datenum(start_date)));
            set(handles.ID_list, 'Enable', 'on', 'String', AP_datelist, 'Value', k);
            
            logstr = horzcat('Imported Activpal File from ', p1, f1);
            
        end
        
        % INSERT NEW EVENT TO ACTIVPAL DATA IN MEMORY
        function  [handles, logstr] = insertToActivpalData(handles, time_selected, InsertDay)
            
            f = waitbar(0, 'Inserting Event...');
            
            
            activpal_memory_data = handles.activpal_data.memory;
            
            insertion_datenum = datenum(horzcat(datestr(InsertDay), ' ', time_selected));
            data_for_insertion_time = datenum(activpal_memory_data{1});
            data_for_insertion_matrix = activpal_memory_data{2};
            
            k = 1;
            while 1
                try
                    if ismember(k/length(data_for_insertion_time), [0.1:0.1:0.9])
                        waitbar(k/length(data_for_insertion_time), f , 'Inserting Event...');
                    end
                    
                    if (data_for_insertion_time(k) < insertion_datenum) && (insertion_datenum <  data_for_insertion_time(k+1))
                        
                        insert_this_vector = data_for_insertion_matrix(k+1,:);
                        
                        insert_this_vector(2) = (data_for_insertion_time(k+1) - insertion_datenum).*24.*3600;
                        insert_this_vector(3) = data_for_insertion_matrix(k,3);
                        
                        data_for_insertion_matrix(k,2) = (data_for_insertion_matrix(k,2) - insert_this_vector(2));
                        
                        data_for_insertion_time = [data_for_insertion_time(1:k); insertion_datenum; data_for_insertion_time(k+1:end)];
                        data_for_insertion_matrix = [data_for_insertion_matrix(1:k,:); insert_this_vector; data_for_insertion_matrix(k+1:end,:)];
                        
                        logstr = horzcat('Event Created for ', datestr(insertion_datenum));
                        
                        break
                    end
                    k = k + 1;
                catch
                    if any(data_for_insertion_time == insertion_datenum)
                        logstr = 'Event already created at selected time';
                    else
                        logstr = 'Could not create event';
                    end
                    
                    break
                end
            end
            
            handles.activpal_data.memory = {datetime(datestr(data_for_insertion_time)), data_for_insertion_matrix};
            
            waitbar(1, f , 'Inserting Event...');
            close(f)
            
        end
        
        % MARK ACTIVPAL DATA
        function [handles, logstr] = markActivpal(handles, tempStart_time, tempEnd_time)
            indexes = find((datenum(handles.activpal_data.memory{1}) >= tempStart_time) & (datenum(handles.activpal_data.memory{1})  <= tempEnd_time));
            handles.activpal_data.memory{2}(indexes(1):indexes(end),end) = 1;
            
            logstr = horzcat('Action marked between ', datestr(tempStart_time),' to ', datestr(tempEnd_time)); 
        end
        
        % UNMARK ACTIVPAL DATA
        function [handles, logstr] = unmarkActivpal(handles, tempStart_time, tempEnd_time)
            indexes = find((datenum(handles.activpal_data.memory{1}) >= tempStart_time) & (datenum(handles.activpal_data.memory{1})  <= tempEnd_time));
            handles.activpal_data.memory{2}(indexes(1):indexes(end),end) = NaN;
            logstr = horzcat('Action unmarked between ', datestr(tempStart_time),' to ', datestr(tempEnd_time)); 
        end
        
        % CALCULATE OUTCOME VARIABLES
        function [ActionTimeFrame, WakeSleep, logstr] = calculate_activpalData(handles)
            try
                tempWake_time = datenum(datetime(handles.wake_insert.String));
                tempSleep_time = datenum(datetime(handles.sleep_insert.String));
                tempStart_time = datenum(datetime(handles.WorkStartInput.String));
                tempEnd_time = datenum(datetime(handles.WorkEndInput.String));
                
                ActionTimeFrame = struct;
                WakeSleep = struct;
                
                if (tempSleep_time > tempWake_time) && (tempEnd_time > tempStart_time)
                    activpal_data = handles.activpal_data.memory;
                    datenumbers = datenum(activpal_data{1});
                    
                    Action_time_frame_index = find((datenumbers >= tempStart_time) & (datenumbers <= tempEnd_time));
                    SleepkWake_time_frame_index = find((datenumbers >= tempWake_time) & (datenumbers <= tempSleep_time));
                    SleepkWake_time_frame_index = SleepkWake_time_frame_index-1;
                    
                    % time_frame_dates = activpal_data{1}(time_frame_index);
                    Action_time_frame_data = activpal_data{2}(Action_time_frame_index',:);
                    SleepWake_time_frame_data = activpal_data{2}(SleepkWake_time_frame_index',:);  
                    
                    % Find Unmarked Within Action Timeframe
                    Unmarked_ATF = Action_time_frame_data(Action_time_frame_data(:,end) == 0, :);
                    % Find Marked Within Action Timeframe
                    Marked_ATF = Action_time_frame_data(Action_time_frame_data(:,end) == 1, :);
                    
                    Action_time_frame_data_activity = Action_time_frame_data(:,3);
                    Action_time_frame_data_MET = Action_time_frame_data(:,5);
                    Acton_time_frame_data_interval = Action_time_frame_data(:,2);
                    
                    n = 1;
                    total_time = zeros(1,3);
                    total_timeSW = zeros(1,3);
                    for i = 0:2
                        temp_data_activity1 = Action_time_frame_data(Action_time_frame_data_activity == i, :);
                        temp_data_activity2 = SleepWake_time_frame_data(SleepWake_time_frame_data(:,3) == i, :);

                        total_time(n) = sum(temp_data_activity1(:,2))./60;
                        total_timeSW(n) = sum(temp_data_activity2(:,2))./60;

                        n = n + 1;
                    end
                    
                    MET_count{1} = Action_time_frame_data(Action_time_frame_data_MET < 3.0, 2);
                    MET_count{2} = Action_time_frame_data((Action_time_frame_data_MET >= 3.0) & (Action_time_frame_data_MET <= 6.0), 2);
                    MET_count{3} = Action_time_frame_data(Action_time_frame_data_MET > 6.0, 2);
                    
                    Time_MET = cellfun(@sum, MET_count)./60;
                    
                    time_frame_data_sit_transitions = Action_time_frame_data;
                    sed_breaks = time_frame_data_sit_transitions(time_frame_data_sit_transitions(:,3) == 2 | time_frame_data_sit_transitions(:,3) == 1, 2); 
                    ActionTimeFrame.Sit_to_Upright_Transitions =  numel(sed_breaks((sed_breaks >= 60))); 
                   
                    
                    TotalValidWearMin = sum(Marked_ATF(:,2))./60; % Total valid minutes 
                    TotalInvalidWearMin = sum(Unmarked_ATF(:,2))./60; % Total invalid minutes
                    ValidWearPercentage = TotalValidWearMin./(TotalInvalidWearMin + TotalValidWearMin); % Percentage of Valid re: Invalid
                    TotalWakeMin = sum(SleepWake_time_frame_data(:,2))./60; % Total wake minutes
                    PercentDayValidWear = TotalValidWearMin./TotalWakeMin; % Percent of day that was valid wear
             
                    
                    ActionPercent = total_time./sum(total_time); % of Action Timeframe in Sed, Stand, and Step 
                   
                    
                    PercentDay = total_timeSW./sum(total_timeSW); % of Day in Sed, Stand, Step
                    
                    % Total mintutes spent in extended sedentary bouts (?30
                    % minutes) in Action Timeframe 
                    prolonged_sitting_action = sum(Action_time_frame_data((Action_time_frame_data_activity == 0) & (Acton_time_frame_data_interval >= 1800),2))./60;
                    num_prolonged_sed = numel((Action_time_frame_data((Action_time_frame_data_activity == 0) & (Acton_time_frame_data_interval >= 1800),2))./60); 
                    % Total mintutes spent in extended sedentary bouts (?30
                    % minutes) in Action Timeframe 
                    
                    % Total mintutes spent in extended sedentary bouts (?30
                    % minutes) for Whole Wake Period
                    prolonged_sitting_day = sum(SleepWake_time_frame_data((SleepWake_time_frame_data(:,3) == 0) & (SleepWake_time_frame_data(:,2) >= 1800), 2))./60;
                    num_prolonged_sed_day = numel((SleepWake_time_frame_data((SleepWake_time_frame_data(:,3) == 0) & (SleepWake_time_frame_data(:,2) >= 1800),2))./60); 
                    
                    % Cumulative # Step Count in Action
                    Step_count_action = Action_time_frame_data(end,4) - Action_time_frame_data(1,4);
                    % Cumulative # Step Count in Day
                    Step_count_day = SleepWake_time_frame_data(end,4) - SleepWake_time_frame_data(1,4);
                    
                    ActionTimeFrame.Total_Time = total_time; 
                    ActionTimeFrame.Time_In_MET = Time_MET;
                    ActionTimeFrame.Total_Valid_Wear_Min = TotalValidWearMin;
                    ActionTimeFrame.Total_Invalid_Wear_Min = TotalInvalidWearMin;
                    ActionTimeFrame.Valid_Wear_Percentage = ValidWearPercentage;
                    ActionTimeFrame.Percent_Of_Actions_During_Action_Time_Frame = ActionPercent; 
                    ActionTimeFrame.Total_Prolonged_Sed_Min = prolonged_sitting_action; 
                    ActionTimeFrame.Step_Count = Step_count_action; 
                    ActionTimeFrame.Prolonged_Sed_Count = num_prolonged_sed; 
                    
                    WakeSleep.Total_Time = total_timeSW; 
                    WakeSleep.Total_Wake_Min = TotalWakeMin;
                    WakeSleep.Percent_Day_of_Valid_Wear = PercentDayValidWear;
                    WakeSleep.Percent_Of_Actions_During_WakeSleep_Time_Frame = PercentDay;
                    WakeSleep.Total_Prolonged_Sed_Min = prolonged_sitting_day;
                    WakeSleep.Step_Count = Step_count_day;
                    WakeSleep.Prolonged_Sed_Count = num_prolonged_sed_day;
                    
                    %L1 = horzcat('Total time spent in Sitting (', sprintf('%.2f', total_time(1)), ' mins), Standing (', sprintf('%.2f', total_time(2)), ' mins) and Stepping (', sprintf('%.2f', total_time(3)), ' mins)');
                    %L2 = horzcat('Total time spent in Light MET (', sprintf('%.2f', Time_In_MET(1)), ' mins), Moderate MET (', sprintf('%.2f', Time_In_MET(2)), ' mins) and Vigorous MET (', sprintf('%.2f', Time_In_MET(3)), ' mins)');
                    %L3 = horzcat('Number of Sit to Upright Transitions: ', sprintf('%.2f', sit_to_upright_transitions));
                    %L4 = horzcat('Total time spent in prolonged sitting: ', sprintf('%.2f', prolonged_sitting));
                    
                    % formatSpec = '%s\n%s\n%s\n%s\n';
                    % fprintf(formatSpec, L1, L2, L3, L4);
                    
                    %                 msg = cell(4,1);
                    %                 msg{1} = sprintf(L1);
                    %                 msg{2} = sprintf(L2);
                    %                 msg{3} = sprintf(L3);
                    %                 msg{4} = sprintf(L4);
                    %                 msb = msgbox(msg);
                   
                    logstr = 'Calculated';
                    
                else
                    ActionTimeFrame = struct;
                    WakeSleep = struct;
                    logstr = 'Non-Chronological Timeframe Pairs, Check Inputs';
                end
                
            catch
                ActionTimeFrame = struct;
                WakeSleep = struct;
                logstr = 'Invalid Timeframe Pairs, Check Inputs';
            end
        end
        
        % EXPORT ACTIVPAL AS CSV
        function Export(varargin)
            [file,path] = uiputfile('*.csv');
            
            metadata = cellstr(varargin{2});
            
            headers = {'Time',...
                'DataCount (samples)',...
                'Interval (s)',...
                'ActivityCode (0=sedentary, 1= standing, 2=stepping)',...
                'CumulativeStepCount',...
                'Activity Score (MET.h)',...
                'Abs(sumDiff)'};
            
            for i = 1:length(headers)
                headers{i} = char(headers{i});
            end
            
            fid = fopen(horzcat(path,file), 'W');
            for i = 1:length(metadata)
                fprintf(fid, '%s\n', metadata{i});
            end
            fprintf(fid, '%s\n', horzcat(headers{1},headers{2},headers{3},headers{4},headers{5}, headers{6}, headers{7}))
            fclose(fid);
            
            dlmwrite(horzcat(path,file), horzcat(datenum(varargin{1}{1}), varargin{1}{2}), 'delimiter', ',', 'precision', 6 ,'-append');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % PLOT ACTIVPAL HOURLY PLOTS
        function [logstr] = gen_subplot_coordinates(handles, start_date)
            delete(findobj(handles.d2d_panel,'type','axes'));
            
            x_axis_font = 9;
            y_axis_font = 9; 
            
            Panel_OuterPosition = int16(handles.d2d_panel.OuterPosition);
            Boarder_Gap = [15, 20];
            plot_values = [6,4]; % Column, Rows
            
            Timedate = handles.activpal_data.memory{1};
            Scores = handles.activpal_data.memory{2}(:,3);
            Markers = handles.activpal_data.memory{2}(:,end);
            
            Max_panel_width = int16(Panel_OuterPosition(3));
            Max_panel_height = int16(Panel_OuterPosition(4));
            
            Subplot_width = (Max_panel_width-Boarder_Gap(1)*2)./plot_values(1);
            Subplot_height = (Max_panel_height-Boarder_Gap(2)*2)./plot_values(2);
            left_pos = [Boarder_Gap(1):Subplot_width:Subplot_width*int16(plot_values(1))];
            bottom_pos = fliplr([Boarder_Gap(2):Subplot_height:(Subplot_height*int16(plot_values(2)))]);
            
            dv = datenum(start_date);
            
            fmtIn = 'HH:MM';
            time_ticks = cell(1, 24);
            time_labels = cell(1,24);
            for i = 1:24
                TT = datetime(datestr(dv+hours(i-1):datenum(hours(15/60)):dv+hours(i)));
                
                for ii = 1:length(TT)
                    TL = datestr(TT,fmtIn);
                end
                
                time_ticks{i} = TT;
                time_labels{i} = TL;
            end
            
            n = 1;
            for i = 1:length(bottom_pos)
                for ii = 1:length(left_pos)
                    LBpositions{ii,i} = [left_pos(ii), bottom_pos(i)]; %[left_pos(i), bottom_pos(ii)];
                    
                    Subplot_bottom = LBpositions{ii,i}(2);
                    Subplot_left = LBpositions{ii,i}(1);
                    
                    ax{n} = axes('Parent', handles.d2d_panel,...
                        'Units', 'pixel',...
                        'OuterPosition', [Subplot_left Subplot_bottom, Subplot_width, Subplot_height],...
                        'FontSize', 7, 'LineWidth', 0.25);
                    
                    yyaxis(ax{n}, 'left')
                    stairs(Timedate, Scores, '-', 'LineWidth', 0.05)
                    xticks(time_ticks{n});
                    xlim([time_ticks{n}(1), time_ticks{n}(end)])
                    xticklabels(time_labels{n});
                    yticks([0 1 2])
                    ylim([-0.5, 2.5])
                    set(ax{n}, 'YTickLabel', []);
                    ax{n}.XAxis.FontSize = x_axis_font;

                    yyaxis(ax{n}, 'right')
                    stem(Timedate, Markers,'r', 'LineWidth', 0.05)
                    yticks([0 1 2 3])
                    ylim([-0.5, 3.5])
                    set(ax{n}, 'YTickLabel', []);
                    n = n + 1;
                end
            end
            
            for i = 1:6:6*4
                yyaxis(ax{i}, 'left')
                set(ax{i}, 'YTickLabel', {'Sedentary', 'Standing', 'Stepping'});
                ax{n}.YAxis(1).FontSize = y_axis_font;
            end
            
            for i = 6:6:6*4
                yyaxis(ax{i}, 'right')
                set(ax{i}, 'YTickLabel',  {'Unmarked', 'Action', 'Wake', 'Sleep'});
                ax{n}.YAxis(2).FontSize = y_axis_font;
            end
            
            logstr = horzcat('Hourly Plot Plotted for ', datestr(dv)); 
        end
        
        % PLOT ACTIVPAL FULL PLOT
        function logstr = fullplot(handles)
            
            x_axis_font = 10;
            y_axis_font = 12;
            
            activpal_data = handles.activpal_data.memory;
            
            delete(findobj(handles.d2d_panel2,'type','axes'));
            
            ax = axes('Parent', handles.d2d_panel2,...
                'Units', 'pixel',...
                'FontSize', 7,...
                'LineWidth', 0.25);
            
            yyaxis(ax, 'left')
            stairs(activpal_data{1}, activpal_data{2}(:,3));
            yticks([0 1 2])
            ylim([-0.5, 2.5])
            set(ax, 'YTickLabel', {'Sedentary', 'Standing', 'Stepping'});
            
            yyaxis(ax, 'right')
            stem(activpal_data{1}, activpal_data{2}(:,end), 'r', 'LineWidth', 0.05)
            yticks([0 1 2 3])
            ylim([-0.5, 3.5])
            set(ax, 'YTickLabel', {'Unmarked', 'Action', 'Wake', 'Sleep'})
            
            ax.YAxis(1).FontSize = y_axis_font;
            ax.YAxis(2).FontSize = y_axis_font;
            ax.XAxis.FontSize = x_axis_font;
            
            logstr = horzcat('Full Plot Plotted'); 
        end
        
        % DELETE ACTIVPAL HOURLY PLOTS
        function delete_activpal_plots(varargin)
            delete(findobj(varargin{1}.d2d_panel,'type','axes'));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    methods
        
        function varargout = extract_time_frame(varargin)
            
            working_data = varargin{2};
            time_frame = varargin{3}; 
            time_datetime = working_data{1}; 
            time_datetime(datetime(time_datetime) == time_frame(1)); 
            mean = msgbox('395'); 
            
        end 
        
    end
end