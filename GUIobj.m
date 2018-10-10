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
        clockobj
    end 

    methods (Static)
        function enableActionPanel(handles)
            handles.WorkStartInput.Enable = 'off';
            handles.WorkEndInput.Enable = 'off';
            handles.wake_insert.Enable = 'off';
            handles.sleep_insert.Enable = 'off';
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
        
        
        
        function time_button_buttondownFcn_callback(src, event) 
            hr = src.Parent.Children(end).Value-1;
            min = src.Parent.Children(end-1).Value-1;
            sec = src.Parent.Children(end-2).Value-1;
            ms = src.Parent.Children(end-3).Value-1;

            TIME = [hr, min, sec, ms*10];
            src.Parent.Parent.Children(2).UserData = TIME; 
            close(src.Parent) 
            
        end 
        
    end

    methods
        function setJournalList(varargin)
            h = varargin{2};
            set(h.journal_command, 'Enable', 'on', 'String',  varargin{1}.action_list(1:end));
        end
        
        
        
        
%         function obj = GUIobj(val1, val2, val3)
%             obj.MetThreshold = val1;
%             obj.WearThreshold = val2;
%             obj.Sleep_Algorithm = val3;
%         end 
%         
%         function obj = set.MetThreshold(obj, value)
%             if isvector(value)
%                 if value(1) < value(2)
%                     obj.MetThreshold = value;
%                 end
%             end
%         end
%         
%         function obj = set.WearThreshold(obj, value)
%             if isa(value, 'numeric') && (value <= 1) && (value >= 0)
%                 obj.WearThreshold = value;
%             end
%         end
%         
%         function obj = set.Sleep_Algorithm(obj, value)
%             if isa(value, 'numeric') && (value <= 3) && (value > 0)
%                 obj.Sleep_Algorithm = value;
%             end
%         end

    end
end