classdef logMessage
    properties (Constant)
        Name = 'Created by Anthony Chen'; 
        Initialize = 'Initialized Activpal Analysis Program'; 
    end 
    
    methods (Static) 
        function GenerateLogMessage(varargin)
            varargin{1}.String = vertcat(horzcat('[',datestr(datetime),']: ',varargin{2}),(varargin{1}.String));
        end 
        
        function Export(varargin) 
            p1 = uigetdir; 
            lognotes = flipud(varargin{1}.String);
            fid = fopen(horzcat(p1,'\',datestr(datetime, 'yyyymmdd_HHMMSS'), '_ActivityLog.txt'), 'W');
            for i = 1:length(lognotes)
                fprintf(fid, '%s\n', lognotes{i});
            end 
            fclose(fid); 
            
        end 
    end
 
end