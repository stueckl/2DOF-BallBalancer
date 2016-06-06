function InitRetina(portName, baudRate)

global s_retina;

% *************************************************************************
s_retina = SerPortOpen(portName, baudRate);    % open serial port
disp ('COM-Port open');

% *************************************************************************
SerPortFlush(s_retina);                 % clear possible input
SerPortWriteLine(s_retina, 'r');        % reset DVS128
pause(1);                               % wait briefly
SerPortFlush(s_retina);                 % again clear input
disp('DVS128 reset');
pause(0.5);                             % wait briefly

% *************************************************************************
SerPortWriteLine(s_retina, '!E4');      % setup Data Format (binary without TS)
pause(0.5);                             % wait briefly
SerPortFlush(s_retina);                 % again clear input
disp('DVS128 data format E4 (binary events, with 4 byte TS)');

% *************************************************************************
SerPortWriteLine(s_retina, 'E+');       % start DVS128 event sendig
pause(0.5);                             % wait briefly
SerPortRead(s_retina, 3);               % dummy read 3 chars as reply
disp('DVS128 start event streaming');


% *************************************************************************
function s = SerPortOpen(portName, baudRate)      % open specified port
    if (nargin<2)
        baudRate = 6000000;
    end
    if (nargin<1)
        portName='COM1';
    end
    
    s = serial(portName, ...
           'BaudRate', baudRate, ...
           'Parity', 'none', ...
           'DataBits', 8, ...
           'StopBits', 1, ...
           'InputBufferSize', 1024*1024, ...    % 1MByte is fairly large
           'OutputBufferSize', 1024*1024, ...   % 1MByte is fairly large
           'Timeout', 1);
    s.Flowcontrol = 'hardware';                 % use hardware flow control (RTS/CTS)
    s.ReadAsyncMode = 'continuous';     % If ReadAsyncMode is continuous, the serial port object
                                        % continuously queries the device to determine if data is
                                        % available to be read. If data is available, it is
                                        % automatically read and stored in the input buffer.
                                        % If issued, the readasync function is ignored.
                                                % !!!!! Georg? please explain properly ;)


% es gibt in Matlab zwei M�glichkeiten die Daten zu erhalten. Entweder man setzt
%   s.ReadAsyncMode = manual;
% oder
%   s.ReadAsyncMode = continuos;
% Im ersten Fall wird von Matlab nicht permanent gepr�ft ob Daten vorliegen sondern dies muss manuell erfolgen.
% Im Fall von �continous� wird permanent nach neuen verf�gbaren Daten gesucht und diese im input-Buffer gespeichert.
% Um eine h�here Geschwindigkeit zu erreichen sollte s.ReadAsyncMode = continous gew�hlt werden.
    fopen(s);                           % finally open the serial port

% *************************************************************************
function SerPortFlush(s)                % flush (read in all data) from port
    n = s.BytesAvailable;
    if (n > 0)
        fread(s, n, 'uint8');
    end

% *************************************************************************
function SerPortWriteLine(s, l)         % send this line 'l' to serial port with trailing return
    fwrite(s,[l 10],'uint8');

% *************************************************************************
function l = SerPortRead(s, n)            % read (at most n chars) from SerPort
    if (nargin < 1)
        n = s.BytesAvailable;
    end
    l = fread(s, n, 'uint8');


