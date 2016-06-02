classdef Servos < handle
    %SERVOS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        baudRate
        portName
        s
        InitPosDeg   
        CWdeg 
        CCWdeg 
        InitPosBin  
        CWbin      
        CCWbin  
        bin2deg
    end %properties
    
    methods
        function obj = Servos(pN, bR)
            
            if (nargin<2)
                obj.baudRate = 1000000;
            else
                obj.baudRate = bR;
            end
            
            obj.portName = pN;
                
            obj.InitPosDeg  = 180; 
            obj.CWdeg       = 135; 
            obj.CCWdeg      = 225; 

            obj.InitPosBin  = 2048;     % 180 Deg
            obj.CWbin       = 1536;     % 135 Deg
            obj.CCWbin      = 2560;     % 225 Deg
            obj.bin2deg     = (obj.CCWbin - obj.CWbin)/(obj.CCWdeg - obj.CWdeg);
            
            obj.InitServos();
        end %Servos()
        
        function SetPosition(obj, GoalPosition)

            % ServoX Serial Handler Object
            ServoID = 1;

            % The instruction for motor command    
            WriteInstruction = 3; 

            LowestByte = mod(GoalPosition, 256);
            HighestByte = floor(GoalPosition / 256);
            parameters = [30, LowestByte, HighestByte];
            nParameters = length(parameters);
            packetLength = nParameters + 2;
            checkSum = ServoID + packetLength + WriteInstruction + sum(parameters);
            checkSum = 255 - mod(checkSum, 256);
            WritePacket = [255, 255, ServoID, packetLength, WriteInstruction, parameters, checkSum];

            fwrite(obj.s, WritePacket,'uint8');
            
        end %SetPosition
        
       
        function InitServos(obj)

            % Servos Serial Handler Object
            obj.SerPortOpen()    % open serial port 

            %obj.SerPortFlush(obj);
            
        end

        function SerPortOpen(obj)      % open specified port
            obj.s = serial(obj.portName, ...
                   'BaudRate', obj.baudRate, ...
                   'Parity', 'none', ...
                   'DataBits', 8, ...
                   'StopBits', 1);

            fopen(obj.s);                           % finally open the serial port

            % add a little bit of programming fun ! :D
        %     for k=1:1:4
        %         disp('Initialization in progress -'); pause(0.1); clc; 
        %         disp('Initialization in progress \'); pause(0.1); clc; 
        %         disp('Initialization in progress |'); pause(0.1); clc;
        %     end
            disp ('Servo is Initialized');
        end
        
        
        % *************************************************************************
        function SerPortFlush(obj)                % flush (read in all data) from port
            n = obj.s.BytesAvailable;
            if (n > 0)
                fread(obj.s, n, 'uint8');
            end
        end
        
        % *************************************************************************    
        % function SerPortCloseAll()                      % close all open ports
        %     if ~(isempty(instrfind))
        %         fclose(instrfind);
        %     end
        %     delete(instrfindall);
        
        
    end %methods
    
end

