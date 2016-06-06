classdef DVS128Demo < handle
    %DVS128 Demo Class for testing with datasets
    % maybe not all method are supported (experimental class)
    
    properties (SetAccess = private) 
        baudRate
        portName
        serial %serial Port
        demodata
        demodataI
    end %properties
    
    events
        %TODO: Event based solution
        NewEvents
    end %events
    
    methods
        %TODO: create overload functions
        function obj = DVS128Demo(pN, bR)
            
            %set USB-Port configuration
            obj.baudRate = bR;
            obj.portName = pN;
        end %function DVS128()
        
        function Connect(obj)
                      
            %TODO: could be the reason of an Serial Port conflict (obj.SerPortCloseAll();)
            %obj.serial = SerialPort();
            %obj.serial.CloseAll();
            %obj.serial.Open(obj.portName, obj.baudRate);     
            disp ('COM-Port open');
            
            % clear input
            %obj.serial.Flush();                    
            %obj.Reset();
            
            % set data format with time stamp
            %obj.serial.WriteLine('!E2');         
            %pause(0.1);                         
            %obj.serial.Flush()
            disp('DVS128 enable timestamp');
            
            % start DVS128 event sendig
            %obj.serial.WriteLine('E+'); 
            % dummy read 3 chars as reply
            %obj.serial.Read(3);     
            
            % Load file
            file = load('recordedData3.mat');
            disp(file)

            obj.demodata = file.dat;
            obj.demodataI = 1;
            
            %disp(strcat('DVS128 start event streaming from: ', file.dat));            

        end %connect()
        
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
            
            epsilon=2;
            MinPts=10;
            A=filteredData(filteredData(:,3)==1, 1:2);
            IDX=DBSCAN(A,epsilon,MinPts);
            clusterNumb = mode(IDX);
            ballPos   = mean(A(IDX==clusterNumb, :));
            
            epsilon=6;
            MinPts=10;
            A=filteredData(:, 1:2);
            IDX=DBSCAN(A,epsilon,MinPts);
            clusterNumb = mode(IDX);
            ballPos1   = mean(A(IDX==clusterNumb, :));
            ballVel = ballPos - ballPos1;
            
        end % DetermineBallPosition()
                
        
        function setFileName(obj, path, name)
           filename = strcat([path, name]);
           save('settings.mat', 'filename');
           obj.Connect();
        end
        
        function Reset(obj)
            obj.serial.WriteLine('r');           
            pause(0.2);                             
            obj.serial.Flush();                  
            disp('DVS128 reset');
        end %reset()
        
        function Close(obj)
            %obj.serial.WriteLine('E-');                     
            %obj.serial.Close();                             
            disp ('COM-Port closed');  
        end %Close()
        
        function events = GetEvents(obj)  % get n events (=4*n bytes) from sensor
            events = [];
            events = obj.demodata{obj.demodataI};
            obj.demodataI = obj.demodataI +1;
            
            % reset after last element
            if obj.demodataI == size(obj.demodata, 1)
                obj.demodataI = 1;
            end
        end %GetEvents
        
        function events = EventsAvailable(obj)
            a = size(obj.demodata);%.ans.dat);
            events = 0;
            if obj.demodataI < a(1)
                events = 1;
            end
            
        end %EventsAvailable

    end %methods
    

end

