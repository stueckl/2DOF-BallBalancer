function InitServos(portName_x, portName_y, baudRate)

    % Servos Serial Handler Object
    global s_x;
    global s_y;
    
    if (nargin<3)
        baudRate = 1000000;
    end
    if (nargin<1)
        portName_x = 'COM18';
        portName_y = 'COM19';
    end
    
    s_x = SerPortOpen(portName_x, baudRate);    % open serial port for SrvoX
    s_y = SerPortOpen(portName_y, baudRate);    % open serial port for SrvoY
    SerPortFlush(s_x);
    SerPortFlush(s_y);

function s = SerPortOpen(portName, baudRate)      % open specified port
    s = serial(portName, ...
           'BaudRate', baudRate, ...
           'Parity', 'none', ...
           'DataBits', 8, ...
           'StopBits', 1);
       
    fopen(s);                           % finally open the serial port

    % add a little bit of programming fun ! :D
%     for k=1:1:4
%         disp('Initialization in progress -'); pause(0.1); clc; 
%         disp('Initialization in progress \'); pause(0.1); clc; 
%         disp('Initialization in progress |'); pause(0.1); clc;
%     end
    disp ('Servos are Initialized');
    
% *************************************************************************
function SerPortFlush(s)                % flush (read in all data) from port
    n = s.BytesAvailable;
    if (n > 0)
        fread(s, n, 'uint8');
    end
    
% *************************************************************************    
% function SerPortCloseAll()                      % close all open ports
%     if ~(isempty(instrfind))
%         fclose(instrfind);
%     end
%     delete(instrfindall);