classdef journal_data
    properties
        
        initialization_text = 'Journal-Activpal Command List';
        
    end
    
    methods(Static)
        
        % Method to Initialize Journal Bootup (Header Template)
        function [j_header_format, journal_header_count] = j_initialize
            fid = fopen(horzcat(pwd,'\Resources\','Journal_Header_Bootup.csv'));
            j_header_format = textscan(fid, '%s', 'Delimiter', ',');
            journal_header_count = length(j_header_format{1});
            fclose(fid);
        end
        
        function varargout = find_day(varargin)
            column_count = varargin{1};
            expDuration = varargin{2};
            selection = varargin{3};
            h = varargin{4};
           
            groups = column_count/expDuration;
            
            temp = transpose(reshape([1+5:column_count+5], expDuration, groups));
            [Selected_day_number_in_Journal,~] = find(temp == selection(2));
            
            DayVector = datetime(h.Data{selection(1),3}):datetime(h.Data{selection(1),5});

            varargout{1} = DayVector(Selected_day_number_in_Journal);
            varargout{2} = Selected_day_number_in_Journal;
            
        end
        
    end
    
    methods
        
        % Method to Import Journal Data
        function varargout = import_j_func(varargin)
            [f1,p1] = uigetfile('*.csv');
            fid = fopen(horzcat(p1,f1), 'r');
            journal_header_count = varargin{2};
            
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
            header_column = table_data(1,:);
            
            varargout{1} = header_column;
            varargout{2} = num2cell(zeros(1,length(header_column))+150);
            varargout{3} = table_data(2:end,:);
            varargout{4} = size(table_data,2);
            varargout{5} = duration{1};
        end
        
    end
end
