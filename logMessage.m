classdef logMessage
    methods (Static) 
        function GenerateLogMessage(varargin)
            varargin{1}.String = vertcat(horzcat('[',datestr(datetime),']: ',varargin{2}),(varargin{1}.String));
        end
    end
end