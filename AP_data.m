classdef AP_data
    
    properties
        Boarder_Gaps = [15, 15];
        activpal_action_list = {'1) INSERT EVENT', '2) MARK WORK', '3) UNDO INSERT'};

    end
    
    methods (Static) 
        
        % IMPORTING ACTIVPAL CSV FILE
        function varargout = import_activpal_func
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
            
            varargout{1} = formatted_date;
            varargout{2} = temp_data(:,[2:end]);
            varargout{3} = AP_metadata;
            varargout{4} = AP_subjectID;
            varargout{5} = AP_datelist;
        end
        
        % PARSING ACTIVPAL DATA FOR ANALYSIS / PLOTTING
        function varargout = parse_activpal_data(varargin)
            % 1 = Activpal Memory 
            % 2 = Selected Date 
            % 3 = For Plotting (T/F) 
            
            activpal_datetime = datenum(varargin{1}{1});
            activpal_matrix = varargin{1}{2};
            
            % Check for if Parse for data or Prase for Plotting when parsed
            % for date the input 3 (selected_date) will be a 2 element
            % vector stating start and end dates. 
            
            % If parse for plotting, the start date is a one element date
            % for start date. End date will be the same date at the very
            % last second before the next day 
            
            switch nargin
                
                case 2
                    start_date = datenum(datetime(varargin{2})+hours(0));
                    end_date = datenum(datetime(varargin{2})+hours(23)+minutes(59)+seconds(59));
                    
                    try
                        indexes = find((activpal_datetime >= start_date) & (activpal_datetime <= end_date));
                        logindexs = [indexes(1), indexes(end)];
                        
                        if indexes(1) ~= 1
                            indexes = [indexes(1)-1; indexes];
                        end
                        
                        if indexes(end) ~= length(activpal_datetime)
                            indexes = [indexes; indexes(end)+1];
                        end
                        
                        time_frame = activpal_datetime(indexes);
                        data_frame = activpal_matrix(indexes,:);
                        
                        logstr = horzcat('Timeframe plotted between ', datestr(activpal_datetime(logindexs(1))), ' to ', datestr(activpal_datetime(logindexs(end))));
                        
                    catch
                        logstr = 'Error in determining start and end dates';
                    end
                    
                case 3
                    start_date = datenum(varargin{2});
                    end_date = datenum(varargin{3});
                    
                    try
                        indexes = find((activpal_datetime >= start_date) & (activpal_datetime <= end_date));
                        logindexs = [indexes(1), indexes(end)];
                        
                        time_frame = activpal_datetime(indexes);
                        data_frame = activpal_matrix(indexes,:);
                        
                        logstr = horzcat('Timeframe extracted between ', datestr(activpal_datetime(logindexs(1))), ' to ', datestr(activpal_datetime(logindexs(end))));
                        
                    catch
                        logstr = 'Error in determining start and end dates';
                    end
            end
            
            varargout{1} = {time_frame, data_frame};
            varargout{2} = logstr; 
            
        end
        
        % DELETE ACTIVPAL HOURLY PLOTS
        function delete_activpal_plots(varargin)
            delete(findobj(varargin{1}.d2d_panel,'type','axes'));
        end
        
        % INSERT NEW EVENT TO ACTIVPAL DATA IN MEMORY
        function varargout = insertToActivpalData(varargin)
            
            f = waitbar(0, 'Inserting Event...'); 
            

            activpal_memory_data = varargin{1};
            time_selected_for_insertion = varargin{2};
            InsertDay = varargin{3};
            
            insertion_datenum = datenum(horzcat(datestr(InsertDay), ' ', time_selected_for_insertion));
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
                    logstr = 'Could not create event';
                    break
                end
            end
            
            varargout{1} = {datetime(datestr(data_for_insertion_time)), data_for_insertion_matrix};
            varargout{2} = logstr; 
            
            waitbar(1, f , 'Inserting Event...');
            close(f)

        end
        
        % CALCULATE OUTCOME VARIABLES
        function varargout = calculate_activpalData(varargin)
            
            activpal_data = varargin{1};
            tempStart_time = varargin{2};
            tempEnd_time = varargin{3};
            
            datenumbers = datenum(activpal_data{1});
            
            time_frame_index = find((datenumbers >= tempStart_time) & (datenumbers <= tempEnd_time));
            
            % time_frame_dates = activpal_data{1}(time_frame_index); 
            time_frame_data = activpal_data{2}(time_frame_index',:);
            
            time_frame_data_activity = time_frame_data(:,3);
            time_frame_data_MET = time_frame_data(:,5); 
            time_frame_data_interval = time_frame_data(:,2);
            
            n = 1; 
            total_time = zeros(1,3); 
            for i = 0:2
                temp_data_activity = time_frame_data(time_frame_data_activity == i, :);
                total_time(n) = sum(temp_data_activity(:,2))./60;
                n = n + 1;
            end
            
            MET_count{1} = time_frame_data(time_frame_data_MET < 3.0, 2);
            MET_count{2} = time_frame_data((time_frame_data_MET >= 3.0) & (time_frame_data_MET <= 6.0), 2);
            MET_count{3} = time_frame_data(time_frame_data_MET > 6.0, 2);
            
            Time_In_MET = cellfun(@sum, MET_count)./60;
            
            time_frame_data_sit_transitions = time_frame_data_activity;
            time_frame_data_sit_transitions(time_frame_data_sit_transitions == 2) = 1; 
            sit_to_upright_transitions = numel(find(diff(time_frame_data_sit_transitions) == 1));
            
            prolonged_sitting = sum(time_frame_data((time_frame_data_activity == 0) & (time_frame_data_interval >= 1800),2))./60;
            
            varargout{1} = total_time; % minutes spent sitting, standing, and stepping 
            varargout{2} = Time_In_MET; % Time in MET Categories
            varargout{3} = sit_to_upright_transitions; % Sit to Upright Transitions
            varargout{4} = prolonged_sitting; % Minute Spent in Prolonged Sitting 
        end
        
    end
    
    methods
        
        % PLOT ACTIVPAL HOURLY PLOTS
        function gen_subplot_coordinates(varargin)
            handles = varargin{2};
            Panel_OuterPosition = int16(handles.d2d_panel.OuterPosition);
            Boarder_Gap = varargin{1}.Boarder_Gaps;
            plot_values = [6,4]; % Column, Rows 
            seg_data = varargin{3};
            
            Timedate = datetime(datestr(seg_data{1})); 
            Scores = seg_data{2}(:,3); 
            
            Max_panel_width = int16(Panel_OuterPosition(3));
            Max_panel_height = int16(Panel_OuterPosition(4));
            
            Subplot_width = (Max_panel_width-Boarder_Gap(1)*2)./plot_values(1);
            Subplot_height = (Max_panel_height-Boarder_Gap(2)*2)./plot_values(2);
            left_pos = [Boarder_Gap(1):Subplot_width:Subplot_width*int16(plot_values(1))];
            bottom_pos = fliplr([Boarder_Gap(2):Subplot_height:Subplot_height*int16(plot_values(2))]);
            
            for i = 1:length(left_pos)
                for ii = 1:length(bottom_pos)
                    LBpositions{ii,i} = [left_pos(i), bottom_pos(ii)];
                end
            end
            
            delete(findobj(handles.d2d_panel,'type','axes'));
            
            n = 1;
            for i = 1:size(LBpositions,2) % C
                for ii = 1:size(LBpositions,1) % R
                    Subplot_bottom = LBpositions{ii,i}(2);
                    Subplot_left = LBpositions{ii,i}(1);
                    ax{n} = axes('Parent', handles.d2d_panel,...
                        'Units', 'pixel',...
                        'OuterPosition', [Subplot_left Subplot_bottom, Subplot_width, Subplot_height],...
                        'FontSize', 7, 'LineWidth', 0.25);
                    
                    stairs(Timedate, Scores, '-', 'LineWidth', 0.05)
                    
                    dv = datenum(varargin{4});
                    
                    fmtIn = 'HH:MM';
                    time_ticks = datetime(datestr(dv+hours(n-1):datenum(hours(15/60)):dv+hours(n)));
                    xticks(time_ticks);
                    xlim([time_ticks(1), time_ticks(end)])
                    
                    time_labels = cell(1, length(time_ticks));
                    for I = 1:length(time_ticks)
                        time_labels{I} = datestr(time_ticks(I),fmtIn);
                    end
                    
                    xticklabels(time_labels);
                    
                    yticks([0 1 2])
                    ylim([-0.5, 2.5])
                    if n > plot_values(2)
                        set(ax{n}, 'YTickLabel', []);
                    else
                        yticks([0 1 2])
                        yticklabels({'Sedentary', 'Standing', 'Stepping'})
                    end
                    ax{n}.XAxis.FontSize = 7;
                    ax{n}.YAxis.FontSize = 7;
                    
                    n = n + 1;
                end
            end
        end

        function varargout = extract_time_frame(varargin)
            
            working_data = varargin{2};
            time_frame = varargin{3}; 
            time_datetime = working_data{1}; 
            time_datetime(datetime(time_datetime) == time_frame(1)); 
            mean = msgbox('395'); 
            
        end 
        
    end
end