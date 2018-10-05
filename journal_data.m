classdef journal_data
    properties      
    end
    
    methods(Static)
        
        function [journal_header_count, handles] = initialize_Journal(handles) 
            % Method to Initialize Journal Bootup (Header Template);
            % Read Journal Header Bootup File to initialize the number of headers per day
            % Set Default Journal Table Data
            
            fid = fopen(horzcat(pwd,'\Resources\','Journal_Header_Bootup.csv'));
            j_header_format = textscan(fid, '%s', 'Delimiter', ',');
            journal_header_count = length(j_header_format{1});
            fclose(fid);
            
            set(handles.journal_table, 'ColumnName', j_header_format{1});
            set(handles.journal_table, 'ColumnWidth', num2cell(zeros(1,length(j_header_format{1}))+150));
            
            handles.journal_data.default = cell(100,length(j_header_format{1}));
            handles.journal_data.memory = cell(100,length(j_header_format{1}));
            set(handles.journal_table, 'Data', handles.journal_data.default, 'ColumnEditable', false);
        end
        
        function [handles, logstr] = import_journal_file(journal_header_count, handles)
            % Import Journal Data
            % Display Journal Data to Journal Table 
            % Save Journal Data to Memory 
             % Enable Activpal Button 

            [f1,p1] = uigetfile('*.csv');
            fid = fopen(horzcat(p1,f1), 'r');
            
            if fid == -1
                errordlg('Check filename', 'Error Alert');
            else
                
                scanned_data = textscan(fid, '%s', 'Delimiter', ',');
                duration = inputdlg('Enter Duration of Experiment (in days):', 'Resizing Input');
                
                column_count = (3+journal_header_count*str2double(duration{1})); % Fixed 3 + Custom Header Count * duration of study
                table_data = transpose(reshape(scanned_data{1},column_count,length(scanned_data{1})/column_count));
                
                fclose(fid);
            end
            
            % Initialize Day Start and Day End Cell Vectors
            dayStart = cell(size(table_data,1),1);
            dayEnd = cell(size(table_data,1),1);
            
            dayStart{1} = 'Start Day';
            dayEnd{1} = 'End Day';
            
            n = 2;
            for i = 1:size(table_data(2:end,[2,3]), 1)
                try
                    [~,dayStart{n}] = weekday(table_data{n,2});
                    [~,dayEnd{n}] = weekday(table_data(n,3));
                catch
                    dayStart{n} = 'Not a Date';
                    dayEnd{n} = 'Not a Date';
                end
                n = n + 1;
            end
            
            table_data = [table_data(:,1), dayStart, table_data(:,2), dayEnd, table_data(:,3:end)];
            
            Column_Head = table_data(1,:);
            Column_Width = num2cell(zeros(1,length(Column_Head))+150);
            Column_Count = size(table_data,2); 
            Duration = duration{1}; 
            Data_for_Print = table_data(2:end,:); 
            
            % Print Journal Data to Journal Table
            set(handles.journal_table, 'ColumnName', Column_Head);
            set(handles.journal_table, 'ColumnWidth', Column_Width);
            set(handles.journal_table, 'Data', Data_for_Print);
            
            handles.journal_data.memory =  Data_for_Print;
            handles.journal_data.column_count = Column_Count;
            handles.journal_data.expDuration = Duration;
            
            handles.activpal_import.Enable = 'on';

            logstr = horzcat('Imported Journal File from ', p1, f1);
        end
        
        function varargout = find_day(varargin)
            column_count = varargin{1};
            expDuration = varargin{2};
            selection = varargin{3};
            h = varargin{4};
           
            groups = column_count/expDuration;
            
            temp = transpose(reshape([1+5:column_count+5], groups, expDuration));
            [Selected_day_number_in_Journal,~] = find(temp == selection(2));
            
            DayVector = datetime(h.Data{selection(1),3}):datetime(h.Data{selection(1),5});

            varargout{1} = DayVector(Selected_day_number_in_Journal);
            varargout{2} = Selected_day_number_in_Journal;
            
        end

    end
end
