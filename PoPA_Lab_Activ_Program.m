% PopPA Lab Activity Tracker Analysis Program 
% Created by: Anthony Chen, PhD Student 
% Start Date: July 4th, 2018
% Associated Objs 
    % journal_data.m
    % AP_data.m
    
function varargout = PoPA_Lab_Activ_Program(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PoPA_Lab_Activ_Program_OpeningFcn, ...
                   'gui_OutputFcn',  @PoPA_Lab_Activ_Program_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% --- Executes just before PoPA_Lab_Activ_Program is made visible.
function PoPA_Lab_Activ_Program_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject; guidata(hObject, handles);

try 
    J_obj = journal_data; % Get Journal Data Object
    AP_obj = AP_data; % Get Activpal Data Object
    
    [j_header_format, ~] = J_obj.j_initialize; % Run Journal Table Header Method
    
    % Journal Header Bootup File determine the number of headers per day
    % when reading journal file
      
    % Set Journal Table Header
    set(handles.journal_table, 'ColumnName', j_header_format{1}); 
    set(handles.journal_table, 'ColumnWidth', num2cell(zeros(1,length(j_header_format{1}))+150));
    
    % Set Default Journal Table Data
    handles.journal_data.default = cell(100,length(j_header_format{1})); guidata(hObject, handles); 
    handles.journal_data.memory = cell(100,length(j_header_format{1})); guidata(hObject, handles); 
    set(handles.journal_table, 'Data', handles.journal_data.default, 'ColumnEditable', false); 
    
    % Initialize Activpal Data 
    handles.activpal_data.working = cell(25, 7); guidata(hObject, handles); 
    handles.activpal_data.memory = cell(25, 7); guidata(hObject, handles); 
    
catch ME
    errordlg(ME.message, 'Error Alert');
    set(handles.activpal_import, 'Enable', 'off');  
    set(handles.journal_table, 'Enable', 'off');
end 

%%%%% FOR REMOVAL
% try 
%     % Vector for Activpal Header
%     Activpal_Headers = {'Datetime'; 'DataCount (samples)'; 'Interval (s)'; 'ActivityCode (0=sedentary, 1= standing, 2=stepping)';...
%         'CumulativeStepCount'; 'Activity Score (MET.h)'; 'Abs(sumDiff)'}; 
% 
%     % Set Activpal Table Header
%     set(handles.activpal_table, 'ColumnName', Activpal_Headers); 
%     set(handles.activpal_table, 'ColumnWidth', num2cell(zeros(1,length(Activpal_Headers))+150));
%     
%     % Set Default activPAL Table Data
%     handles.activpal_data.working = cell(25, length(Activpal_Headers)); guidata(hObject, handles); 
%     handles.activpal_data.memory = cell(25, length(Activpal_Headers)); guidata(hObject, handles); 
%     set(handles.activpal_table, 'Data', handles.activpal_data.default, 'ColumnEditable', false); 
%     
% catch ME
%     errordlg(ME.message, 'Error Alert');
%     set(handles.activpal_import, 'Enable', 'off');  
%     set(handles.import_journal, 'Enable', 'off');
% end 
%%%%%

% --- Executes on button press in import_journal button.
function import_journal_Callback(hObject, eventdata, handles)
try
    AP_obj = AP_data;
    AP_obj.delete_activpal_plots(handles)
    
    J_obj = journal_data; % Get Journal Data Object
    [~, journal_header_count] = J_obj.j_initialize; % Run Journal Table Header Method
    [Column_Head, Column_Width, table_data, column_count, duration] = J_obj.import_j_func(journal_header_count);
    
    % Print Journal Data to Journal Table 
    set(handles.journal_table, 'ColumnName', Column_Head);
    set(handles.journal_table, 'ColumnWidth', Column_Width);
    set(handles.journal_table, 'Data', table_data);
    
    % Save Journal Data to Memory 
    handles.journal_data.memory =  table_data; guidata(hObject, handles);
    handles.journal_data.column_count = column_count; guidata(hObject, handles);
    handles.journal_data.expDuration= duration ; guidata(hObject, handles); 
    
    % Enable Activpal Button 
    handles.activpal_import.Enable = 'on';     
    
    
catch ME
    errordlg(ME.message, 'Error Alert');
end 

% --- Outputs from this function are returned to the command line.
function varargout = PoPA_Lab_Activ_Program_OutputFcn(~, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in activpal_import button.
function activpal_import_Callback(hObject, eventdata, handles)
try
    % Create instance of Class AP_data 
    AP_obj = AP_data; 
    
    % Run Import Activpal Function
    %[activpal_imported_data_datevec, activpal_imported_data, AP_metadata, AP_subjectID, AP_datelist] = AP_obj.import_activpal_func;
    
    [activpal_imported_data_datevec, activpal_imported_data, AP_metadata, AP_subjectID, AP_datelist] = AP_obj.import_activpal_func;
    
    
    % Save Activpal Subject ID in Memory
    handles.subject_id = AP_subjectID; guidata(hObject, handles);
    
    % Save Activpal Data in Memory
    handles.activpal_data.working = {activpal_imported_data_datevec, activpal_imported_data}; guidata(hObject, handles);
    handles.activpal_data.memory = {activpal_imported_data_datevec, activpal_imported_data}; guidata(hObject, handles);
    
    % Print Selected Activpal Metadata in GUI
    set(handles.AP_file_name,'String',AP_metadata);
    
    % Set Datalist for Dropdown Menu Control 
    set(handles.ID_list, 'Enable', 'on', 'String', AP_datelist); 
    
    parsed_data = AP_obj.parse_activpal_data(handles.activpal_data.memory, AP_datelist(1,:), true);
    [seg_data, plot_values] = AP_obj.activpal_list_func(parsed_data);
    AP_obj.gen_subplot_coordinates(handles, plot_values, seg_data)
    
    % Set Journal List Command & Undo Check
    set(handles.journal_command, 'Enable', 'on', 'String', AP_obj.activpal_action_list{1}); 
    
    % Enable Journal Table for Interaction
    handles.journal_table.Enable = 'on'; 
    
    % Enable Work Start/End Boxes for Interaction
    handles.WorkStartInput.Enable = 'on'; 
    handles.WorkEndInput.Enable = 'on'; 
    
catch ME
     errordlg(ME.message, 'Error Alert');
end 


% --- Executes on selection change in ID_list.
function ID_list_Callback(hObject, eventdata, handles)
try 
    data_for_display = {handles.activpal_data.memory{1}{get(hObject,'Value')}, handles.activpal_data.memory{2}{get(hObject,'Value')}};
    
    % Create instance of Class AP_data 
    AP_obj = AP_data; 
    
    % Run Plot Activpal Function
    [seg_data, plot_values] = AP_obj.activpal_list_func(data_for_display);
    AP_obj.gen_subplot_coordinates(handles, plot_values, seg_data)
                            
catch ME 
     errordlg(ME.message, 'Error Alert');
end

% --- Executes during object creation, after setting all properties.
function ID_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in journal_table.
function journal_table_CellSelectionCallback(hObject, eventdata, handles)
try
    str = hObject.Data{eventdata.Indices(1,1), eventdata.Indices(1,2)};
    if size(eventdata.Indices,1) == 1 ...
            && ~isempty(regexp(str, '\d{1,2}:\d{2,}', 'once'))...
            && strcmp(num2str(handles.subject_id), hObject.Data{eventdata.Indices(1)}) == 1
        
        handles.journal_data.cell_selection = eventdata.Indices; guidata(hObject, handles);
        
        % Make Action Panel Indicator Visible
        handles.action_panel_indicator.Enable = 'on';
        handles.action_panel_indicator.ForegroundColor = [0.3 1 0.2]; 
        
    else
        handles.action_panel_indicator.ForegroundColor = [1 0 0]; 
    end
    
catch ME
    errordlg(ME.message, 'Error Alert');
end


% --- Executes on selection change in journal_command.
function journal_command_Callback(hObject, eventdata, handles)

J_obj = journal_data; % Get Journal Data Object
AP_obj = AP_data;
try
    if isfield(handles.journal_data, 'cell_selection')
        listselection = hObject.Value;
        j_data = handles.journal_data.memory;
        j_selection = handles.journal_data.cell_selection;
        expDuration = handles.journal_data.expDuration;
        
        
        time_selected = j_data{j_selection(1), j_selection(2)};
        
        [InsertDay, Selected_day_number_in_Journal, Selected_day_number_in_Activpal] = ...
            J_obj.find_day(...
            length(handles.journal_table.ColumnName)-5, ... % Non-fixed Journal Column #
            str2double(expDuration),...                     % # of Experimental Recording in Journal
            j_selection,...                                 % Selected Cell in J Table
            get(handles.journal_table), ...                 % Journal Table Struct
            handles.activpal_data.memory);                 % Activpal Data in Working Memory
        
        switch listselection
            case 1
                % Run Insert Function 
                data_for_display = AP_obj.insertToActivpalData(handles.activpal_data.working,...
                    time_selected,...
                    InsertDay,...
                    Selected_day_number_in_Activpal);
                
                % Save Current Activpal State for Undo
                handles.activpal_data.working = handles.activpal_data.memory; guidata(hObject, handles);
                
                % Save Inserted Activpal Data to Memory
                handles.activpal_data.memory{1}{Selected_day_number_in_Activpal} = data_for_display{1};
                handles.activpal_data.memory{2}{Selected_day_number_in_Activpal} = data_for_display{2};
                guidata(hObject, handles);
                                
                % Segregate Data and Plot in GUI
                [seg_data, plot_values] = AP_obj.activpal_list_func(data_for_display);
                AP_obj.gen_subplot_coordinates(handles, plot_values, seg_data)
                
                % Open Undo Option
                set(handles.journal_command, 'Enable', 'on', 'Value', length(AP_obj.activpal_action_list(:)), 'String', AP_obj.activpal_action_list(:));
                
                handles.Selected_day_number_in_Activpal = Selected_day_number_in_Activpal;
                guidata(hObject, handles); 
                
            case 2
                tempStart_time = datevec(handles.WorkStartInput.String);
                tempEnd_time = datevec(handles.WorkEndInput.String);
                
                working_data = {handles.activpal_data.memory{1}{Selected_day_number_in_Activpal},...
                                handles.activpal_data.memory{2}{Selected_day_number_in_Activpal}};
                            
                AP_obj.extract_time_frame(working_data, [datetime(handles.WorkStartInput.String); datetime(handles.WorkEndInput.String)]); 
                
                
            case 3
                
                % Undo Inserted Activpal Data from Working Memory
                handles.activpal_data.memory = handles.activpal_data.working; guidata(hObject, handles); 
               
                data_for_display = {handles.activpal_data.memory{1}{handles.Selected_day_number_in_Activpal },...
                    handles.activpal_data.memory{2}{handles.Selected_day_number_in_Activpal }};
                
                % Segregate Data and Plot in GUI
                [seg_data, plot_values] = AP_obj.activpal_list_func(data_for_display);
                AP_obj.gen_subplot_coordinates(handles, plot_values, seg_data)
                
                set(handles.journal_command, 'Enable', 'on', 'Value', length(AP_obj.activpal_action_list(1:2)), 'String', AP_obj.activpal_action_list(1:2));
                
            otherwise
                
        end
    end
catch ME
    errordlg(ME.message, 'Error Alert');
end

% --- Executes during object creation, after setting all properties.
function journal_command_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
obj = journal_data;
set(hObject, 'String', obj.initialization_text); 


% --------------------------------------------------------------------
function journal_table_ButtonDownFcn(hObject, eventdata, handles)



function WorkStartInput_Callback(hObject, eventdata, handles)
function WorkStartInput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function WorkEndInput_Callback(hObject, eventdata, handles)
function WorkEndInput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Wake/Sleep Detection 
% Marking Work/PW
% Exporting 
% Validity Idx 
% MET Segregation and Find time spent in those MET zones 

