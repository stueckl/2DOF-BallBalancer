classdef BufferRing < handle
    %BUFFERRING Summary of this class goes here
    %   A class for Buffering events 
    % A simple Ring buffer
    % moves all elents one step further, first item has always position 1
    % biggest advantege of this buffer is the static size
    
    properties
        buffer
        buffersize
    end
    
    methods
        function obj = BufferRing(buffersize)
            obj.buffer = [];
            obj.buffersize = buffersize;
            dummy = nan(buffersize,1);
            obj.buffer = [dummy dummy dummy dummy];
        end % BufferRing
        
        function Add(obj, newEvents)
            
            %cut new values to 100
            a = size(newEvents);
            %if new events is bigger than buffer than copy only the newest
            %into buffer
            if a(1) >= obj.buffersize
                obj.buffer = newEvents(a(1)-obj.buffersize+1:a(1), 1:4);
            else
                % later: do not copy double items
    %             for r = 1:a(1)
    %                 XHit = find(obj.buffer(:,1) == newEvents(r,1))
    %             end
    %             for r = 1:a(1)
    %                 YHit = find(obj.buffer(:,2) == newEvents(r,2))
    %             end
    %             %add new values to buffer
                obj.buffer = [newEvents; obj.buffer(1:end-a(1),:)];
            end
            
        end %Add
        
        function all = GetAll(obj)
            all = obj.buffer;
        end %GetAll()
        
        function s = Size(obj)
            s = size(obj.buffer);
        end % Size()
    end
    
end

