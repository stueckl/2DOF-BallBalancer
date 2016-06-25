classdef Filter < handle
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        test
    end
    
    methods
        function obj = Filter()
            obj.test = 1;
        end %Filter()
        function filteredData = DataFilter(obj, eventData)
            filter1Data = obj.EventFlashFilter(eventData);
            filteredData = obj.CircularFilter(filter1Data);
        end %DataFilter()
        
        function filter1Data = EventFlashFilter(obj, eventData)
            %TO DO: filter all when there are events everywhere
            filter1Data = eventData;
        end %EventFlashFilter()
        
        function filteredData = CircularFilter(obj, filter1Data)
            %To Do: check radius and center of circle
            x = filter1Data(:, 1);
            y = filter1Data(:, 2);
            filteredData = filter1Data((x - 60).^2+(y - 60).^2<52^2, :);
        end %CircularFilter()
        
        
        function [ballPos, ballVel] = DetermineBallPosition(obj, filteredData)
            %ToDo DBSCAN cluster center?
            
            ballPos = [0, 0];
            epsilon=2;
            MinPts=10;
            A=filteredData(filteredData(:,3)==1, 1:2);
            IDX=DBSCAN(A,epsilon,MinPts);
            clusterNumb = mode(IDX);
            ballPos   = mean(A(IDX==clusterNumb, :));
            ballVel = [0, 0];
            epsilon=6;
            MinPts=10;
            A=filteredData(:, 1:2);
            IDX=DBSCAN(A,epsilon,MinPts);
            clusterNumb = mode(IDX);
            ballPos1   = mean(A(IDX==clusterNumb, :));
            ballVel = ballPos - ballPos1;
            
        end % DetermineBallPosition()
    end
    
end

