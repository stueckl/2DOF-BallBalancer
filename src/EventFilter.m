classdef EventFilter < handle
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        buffer
    end
    
    methods
        function obj = EventFilter(buffersize)
            obj.buffer = [];
            dummy = nan(buffersize,1);
            obj.buffer = [dummy dummy dummy dummy];

        end % Filter()
        
        function SingleEvents(obj, newEvents)
            
            %check if new values are in old
            a = size(newEvents);
            for r = 1:a(1)
                XHit = find(obj.buffer(:,1) == newEvents(r,1))
            end
            for r = 1:a(1)
                YHit = find(obj.buffer(:,2) == newEvents(r,2))
            end
            %add new values to buffer
            a = size(newEvents);          
            obj.buffer = [newEvents; obj.buffer(1:end-a(1),:)];
            
        end %SingleEvents
    end
    
end

