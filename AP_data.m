classdef AP_data
    
    properties
        Boarder_Gaps = [15, 15];
        activpal_action_list = {'1) INSERT EVENT', '2) MARK WORK', '3) UNDO INSERT'};
        datenum_formatIn = 'dd-mmm-yyyy HH:MM:SS';

    end
    
    methods
        
        % IMPORTING ACTIVPAL CSV FILE
        function varargout = import_activpal_func(varargin)
            [f1,p1] = uigetfile('*.csv');
            
            % Import Data from Activpal File
            temp_data = csvread(horzcat(p1,f1), 1, 0);
            
            % Julian to Gregorian Conversion
            Datenum_formatIn = varargin{1}.datenum_formatIn;
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
            % 1 = Obj Properties 
            % 2 = Activpal Memory 
            % 3 = Selected Date 
            % 4 = For Plotting (T/F) 
            
            activpal_datetime = datenum(varargin{2}{1});
            activpal_matrix = varargin{2}{2};
            
            % Check for if Parse for data or Prase for Plotting when parsed
            % for date the input 3 (selected_date) will be a 2 element
            % vector stating start and end dates. 
            
            % If parse for plotting, the start date is a one element date
            % for start date. End date will be the same date at the very
            % last second before the next day 
            
            switch varargin{4}
                
                case 0
                    start_date = datenum(varargin{3}{1});
                    end_date = datenum(varargin{3}{2}); 
                    
                    [~, k_start] = min(abs(activpal_datetime - start_date));

                    if end_date < activpal_datetime(end)
                        [~, k_end] = min(abs(activpal_datetime - end_date));
                    else
                        k_end = activpal_datetime(end);
                    end
                    
                case 1
                    start_date = datenum(varargin{3});
                    end_date1 = datenum(datetime(varargin{3})+days(1)-seconds(1));
                    end_date2 = datenum(datetime(varargin{3})+days(1));
                    
                    [~, k_start] = min(abs(activpal_datetime - start_date));
                    
                    if k_start > 1
                        k_start = k_start - 1;
                    end
                    
                    if end_date1 < activpal_datetime(end)
                        [~, k_end] = min(abs(activpal_datetime - end_date1));
                        
                        if activpal_datetime(k_end) <= end_date2
                            k_end = k_end + 1;
                        end
                        
                    else
                        k_end = activpal_datetime(end);
                    end
                    
            end
            
            varargout{1} = {activpal_datetime(k_start:k_end); activpal_matrix(k_start:k_end,:)};
            
        end
        
        % PARSE ACTIVPAL DATA IN HOURLY DATA FOR PLOTTING
        function varargout = activpal_list_func(varargin)
            display_data = varargin{2}{2};
            date_data = varargin{2}{1};
            
            [xb, yb] = stairs(datetime(datevec(date_data)), display_data(:,3)); 
            date_data = xb; 
            
            % Convert to Date Vector 
            date_vector = datevec(date_data);
            
            % Prase out only day of date vector 
            parsed_day = date_vector(:,3);
            
            % Parse out only the day that is the highest frequency
            parsed_dayhour = date_vector(parsed_day ==  mode(date_vector(:,3)), :);
            parsed_daydata = yb(parsed_day ==  mode(date_vector(:,3)), :); 
            
            % Find when hours transitions
            hour_idx = [find(diff(parsed_dayhour(:,4))); length(parsed_dayhour(:,4))];
            
            % Find which hours are used
            hours_used = date_vector(hour_idx',4);
            
            n = 0;
            day_data1 = cell(24,1);
            day_data2 = cell(24,1);
            
            for i = 1:24
                if any(hours_used == n)
                    rows = find(parsed_dayhour(:,4) == n);
                    % If first of the hour used & first of the week
                    if rows(1) == 1 && ((datenum(parsed_dayhour(rows(1),:)) == datenum(xb(1))) == 1)
                        day_data1{i} = datetime(parsed_dayhour(rows(1):rows(end)+1,:));
                        day_data2{i} = parsed_daydata(rows(1):rows(end)+1,:);
                    
                    % 
                    elseif rows(1) == 1 && ((datenum(parsed_dayhour(rows(1),:)) == datenum(xb(1))) == 0)
                        day_data1{i} = [xb(1:2); datetime(parsed_dayhour(rows(1):rows(end)+1,:))];
                        day_data2{i} = [yb(1:2); parsed_daydata(rows(1):rows(end)+1,:)];
                        
                    elseif rows == length(parsed_dayhour) && ((datenum(parsed_dayhour(length(parsed_dayhour),:)) == datenum(xb(1))) == 0)
                        day_data1{i} = [datetime(parsed_dayhour(rows(1):rows(end),:)); xb(end-1:end)];
                        day_data2{i} = [parsed_daydata(rows(1):rows(end),:); yb(end-1:end)];
                        
                    else
                        day_data1{i} = datetime(parsed_dayhour(rows(1)-1:rows(end)+1,:));
                        day_data2{i} = parsed_daydata(rows(1):rows(end),:);
                    end
                    n = n + 1;
                    
                else
                    start_time = datetime([date_vector(1,[1:2]), mode(date_vector(:,3)), n, 0, 0]);
                    end_time = datetime([date_vector(1,[1:2]), mode(date_vector(:,3)), n, 59, 59]);
                    day_data1{i} = [start_time; start_time; end_time; end_time];
                    day_data2{i} = nan(length(day_data1{i}),1);
                    
                    if any(hours_used < n) ==  0
                        % day_data2{i}(:,3) = parsed_daydata(hour_idx(1),1);
                    elseif any(hours_used < n) ==  1
                        if ~isempty(parsed_daydata(hour_idx(find((hours_used < n) == 0, 1, 'first')-1)+1,1)) == 1
                            day_data2{i}(:) = parsed_daydata(hour_idx(find((hours_used < n) == 0, 1, 'first')-1),1);
                        else
                            day_data2{i}(:) = parsed_daydata(hour_idx(find((hours_used < n) == 0, 1, 'first')-1)+1,1);
                        end
                    end
                    n = n + 1;
                end
                
                
                
            end
            
            subplot_columns = 6;
            subplot_rows = 4;
            
            varargout{1} = [day_data1, day_data2];
            varargout{2} = [subplot_rows, subplot_columns];
        end
        
        function gen_subplot_coordinates(varargin)
            handles = varargin{2};
            Panel_OuterPosition = int16(handles.d2d_panel.OuterPosition);
            Boarder_Gap = varargin{1}.Boarder_Gaps;
            plot_values = varargin{3};
            seg_data = varargin{4};
            
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
                    
                    Timedate = seg_data{n,1};
                    Scores = seg_data{n,2};
                    stairs(Timedate, Scores, '-', 'LineWidth', 0.05)
                    
                    %                     if any(isnan(seg_data{n,2}(:,3)))
                    %                         step(seg_data{n,1},seg_data{n,2}(:,3), '.');
                    %                     else
                    %                         Timedate = seg_data{n,1};
                    %                         Scores = seg_data{n,2}(:,3);
                    %                         Timedate(Scores == 2);
                    %
                    %                         for I = 0:2
                    %                             Timedate = seg_data{n,1};
                    %                             Scores = seg_data{n,2}(:,3);
                    %                             step(Timedate(Scores == I), Scores(Scores == I), '.', 'LineWidth', 0.1); hold on;
                    %                         end
                    %
                    %                     end
                    
                    dv = datevec(seg_data{n,1}(1));
                    
                    fmtIn = 'HH:MM';
                    time_ticks = datetime(horzcat(dv(1:4),0,0)):hours(15/60):datetime(horzcat(dv(1:3), dv(4)+1, 0, 0));
                    xticks(time_ticks);
                    xlim([datetime(horzcat(dv(1:4), 0, 0)), datetime(horzcat(dv(1:3), dv(4)+1, 0, 0))])
                    
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
        
        function delete_activpal_plots(varargin)
            delete(findobj(varargin{2}.d2d_panel,'type','axes'));
        end
        
        function varargout = insertToActivpalData(varargin)
            
            activpal_memory_data = varargin{2};
            time_selected_for_insertion = varargin{3};
            InsertDay = varargin{4};
            Selected_day_number_in_Activpal = varargin{5};
            
            data_for_insertion = {activpal_memory_data{1}{Selected_day_number_in_Activpal},...
                activpal_memory_data{2}{Selected_day_number_in_Activpal}};
            
            
            temp_time = datevec(time_selected_for_insertion, 'HH:MM');
            temp_day = datevec(InsertDay);
            
            insertion_datetime = datetime([temp_day(1:3), temp_time(4:6)]);
            
            k = 1;
            while 1
                try
                    if (data_for_insertion{1}(k) < insertion_datetime) && (insertion_datetime <  data_for_insertion{1}(k+1))
                       
                        insert_this_vector = data_for_insertion{2}(k+1,:);
                        insert_this_vector(2) = seconds(data_for_insertion{1}(k+1) - insertion_datetime);
                        insert_this_vector(3) = data_for_insertion{2}(k,3);
                        
                        data_for_insertion{2}(k,2) = data_for_insertion{2}(k,2) - insert_this_vector(2);
                        
                        
                        data_for_insertion{1} = [data_for_insertion{1}(1:k,:); insertion_datetime; data_for_insertion{1}(k+1:end,:)];
                        data_for_insertion{2} = [data_for_insertion{2}(1:k,:); insert_this_vector; data_for_insertion{2}(k+1:end,:)];
                        break
                    end
                    k = k + 1;
                catch
                    break
                end
            end
            
            varargout{1} = data_for_insertion; 
            
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