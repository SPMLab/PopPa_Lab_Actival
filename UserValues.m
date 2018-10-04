classdef UserValues <  handles
    
    properties
        
        WearThreshold
        MetThreshold
        SleepAlgorithm
        
    end
    
    methods
        function set.WearThreshold(obj, val)
            if isa(val, 'float') && (val <= 1) && (val >= 0)
                obj.WearThreshold = val;
            end
        end
    end
end