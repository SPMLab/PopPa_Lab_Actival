classdef GUIobj 
    
    properties (Constant)
        initialization_text = "Journal Action";
        
        action_list = {'1) INSERT EVENT',...
            '2) MARK DATA',...
            '3) UNMARK DATA',...
            '4) INSERT WAKE',...
            '5) INSERT SLEEP',...
            '6) CALCULATE',...
            '7) UNDO EVENT INSERT'};
    end
    
    properties

        MetThreshold = [3 6];
        WearThreshold = 0.8; 
        Sleep_Algorithm = 1;
        
    end
    
    methods (Static)
        function enableActionPanel(handles)
            handles.WorkStartInput.Enable = 'on';
            handles.WorkEndInput.Enable = 'on';
            handles.wake_insert.Enable = 'on';
            handles.sleep_insert.Enable = 'on';
        end
        
        function enableJournalTable(handles)
            handles.journal_table.Enable = 'on';
        end
        
        function enableGoodSelectionIndicator(handles)
            handles.action_panel_indicator.Enable = 'on';
            handles.action_panel_indicator.ForegroundColor = [0.3 1 0.2];
        end 
        
        function disableGoodSelectionIndicator(handles) 
            handles.action_panel_indicator.Enable = 'on';
            handles.action_panel_indicator.ForegroundColor = [1 0 0];
        end 
        
        function start_date = find_list_StartDate(handles) 
            start_date = handles.ID_list.String(get(handles.ID_list,'Value'),:);
        end 
        
        function calculateActionFrame(varargin) 
            
        end 
        
    end
    
    methods
        function setJournalList(varargin)
            h = varargin{2};
            set(h.journal_command, 'Enable', 'on', 'String',  varargin{1}.action_list(1:end));
        end
        
        function obj = GUIobj(val1, val2, val3)
            obj.MetThreshold = val1;
            obj.WearThreshold = val2;
            obj.Sleep_Algorithm = val3;
        end 
        
        function obj = set.MetThreshold(obj, value)
            if isvector(value)
                if value(1) < value(2)
                    obj.MetThreshold = value;
                end
            end
        end
        
        function obj = set.WearThreshold(obj, value)
            if isa(value, 'numeric') && (value <= 1) && (value >= 0)
                obj.WearThreshold = value;
            end
        end
        
        function obj = set.Sleep_Algorithm(obj, value)
            if isa(value, 'numeric') && (value <= 3) && (value > 0)
                obj.Sleep_Algorithm = value;
            end
        end

    end
end