classdef SerialPort < handle
    %SERIALPORT handles Serial Connection with USB devices
    %   Handles complete connection
    
    properties
        connection %SerialConnection
    end % properties
    
    %TODO: make USB connection event based  on Bytes-Available Event
    
    methods
       
        function Close(obj)
            fclose(obj.connection);
        end %
        
        function Open(obj, portName, baudRate)
    
            obj.connection = serial(portName, ...
                   'BaudRate', baudRate, ...
                   'Parity', 'none', ...
                   'DataBits', 8, ...
                   'StopBits', 1, ...
                   'InputBufferSize', 1024*1024, ...    % 1MByte is fairly large
                   'OutputBufferSize', 1024*1024, ...   % 1MByte is fairly large
                   'Timeout', 1);
            obj.connection.Flowcontrol = 'hardware';                 % use hardware flow control (RTS/CTS)
            obj.connection.ReadAsyncMode = 'continuous'; % s.ReadAsyncMode could be manual or continous, for faster connection continous is requiered
            
            fopen(obj.connection);                      
        end %Open()
        
        function Flush(obj)                % flush (read in all data) from port, to clear it
            n=obj.connection.BytesAvailable();
            if (n > 0)
                fread(obj.connection, n, 'uint8');
            end
        end % Flush
        
        function WriteLine(obj, line)
            fwrite(obj.connection,[line 10],'uint8');
        end %WriteLine
        
        function n=BytesAvailable(obj)     % how many received chars are waiting?
            n=obj.connection.BytesAvailable();
        end %BytesAvailable
        
        function l = Read(obj, n)            % read (at most n chars) from SerPort
            if (nargin<1)
                n = obj.BytesAvailable();
            end
            l=fread(obj.connection, n, 'uint8');
        end %Read()
        
        
    end %methods
    
    methods(Static)
        function CloseAll()                      % close all open ports
            if ~(isempty(instrfind))
                fclose(instrfind);
            end
            delete(instrfindall);
        end
        
        function lCOM_Port = getAvailableComPort()
            % function lCOM_Port = getAvailableComPort()
            % Return a Cell Array of COM port names available on your computer

            try
                s=serial('IMPOSSIBLE_NAME_ON_PORT');fopen(s); 
            catch
                lErrMsg = lasterr;
            end

            %Start of the COM available port
            lIndex1 = findstr(lErrMsg,'COM');
            %End of COM available port
            lIndex2 = findstr(lErrMsg,'Use')-3;
            lComStr = lErrMsg(lIndex1:lIndex2);
            %Parse the resulting string
            lIndexDot = findstr(lComStr,',');

            % If no Port are available
            if isempty(lIndex1)
                lCOM_Port{1}='';
                return;
            end

            % If only one Port is available
            if isempty(lIndexDot)
                lCOM_Port{1}=lComStr;
                return;
            end

            lCOM_Port{1} = lComStr(1:lIndexDot(1)-1);

            for i=1:numel(lIndexDot)+1
                % First One
                if (i==1)
                    lCOM_Port{1,1} = lComStr(1:lIndexDot(i)-1);
                % Last One
                elseif (i==numel(lIndexDot)+1)
                    lCOM_Port{i,1} = lComStr(lIndexDot(i-1)+2:end);       
                % Others
                else
                    lCOM_Port{i,1} = lComStr(lIndexDot(i-1)+2:lIndexDot(i)-1);
                end
            end 
        end
    end %methods(static)
    
end

