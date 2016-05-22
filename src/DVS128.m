classdef DVS128 < handle
    %DVS128 Service for DVS128 Sensor
    %   Deals all Stuff with the Sensor an generates an event, when new
    %   data is sent over USB connection (Based on DVS128 with Timestamp)
    
    properties (SetAccess = private) 
        baudRate
        portName
        serial %serial Port
    end %properties
    
    events
        %TODO: Event based solution
        NewEvents
    end %events
    
    methods
        %TODO: create overload functions
        function obj = DVS128(pN, bR)
            
            %set USB-Port configuration
            obj.baudRate = bR;
            obj.portName = pN;
        end %function DVS128()
        
        function Connect(obj)
                      
            %TODO: could be the reason of an Serial Port conflict (obj.SerPortCloseAll();)
            obj.serial = SerialPort();
            obj.serial.CloseAll();
            obj.serial.Open(obj.portName, obj.baudRate);     
            disp ('COM-Port open');
            
            % clear input
            obj.serial.Flush(obj.serial);                    
            obj.Reset();
            
            % set data format with time stamp
            obj.serial.WriteLine(obj.serial, '!E2');         
            pause(0.1);                         
            obj.serial.Flush(obj.serial)
            disp('DVS128 enable timestamp');
            
            % start DVS128 event sendig
            obj.serial.WriteLine(obj.serial, 'E+'); 
            % dummy read 3 chars as reply
            obj.serial.Read(obj.serial, 3);                     
            disp('DVS128 start event streaming');            

        end %connect()
        
        function Reset(obj)
            obj.serial.WriteLine(obj.serial, 'r');           
            pause(0.2);                             
            obj.serial.Flush(obj.serial);                  
            disp('DVS128 reset');
        end %reset()
        
        function Close(obj)
            obj.serial.WriteLine(obj.serial, 'E-');                     
            obj.serial.Close(obj.serial);                             
            disp ('COM-Port closed');  
        end %Close()
        
        function events = GetEvents(obj)  % get n events (=4*n bytes) from sensor
            n=obj.serial.BytesAvailable();                
            %if at leat one response is complete
            %TODO: check if Bytes Availible is always multible of 4
            if (n>3)        
                eventBytes=obj.serial.Read(s, 4*n);
                eventY=eventBytes(1:4:end);         % fetch every 2nd byte starting from 1st
                eventX=eventBytes(2:4:end);         % fetch every 2nd byte starting from 2nd

                timeStamp = 256*eventBytes(3:4:end) + eventBytes(4:4:end);

                % split data in polarity and y-events
                eventP=eventX>127;
                eventX=(eventX-(128*eventP));

                eventY = eventY - 128;
                events =[eventX eventY eventP timeStamp];
            end % (n>3)
        end %GetEvents

    end %methods
    

end

