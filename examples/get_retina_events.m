function events = get_retina_events()
    global s_retina;
    n = SerPortBytesAvailable(s_retina);        % count available bytes
    if (n>5)                                    % at least 6 bytes (==1 event)?
        events=DVS128GetEvents(s_retina, ...
            floor(n/6));                        % fetch n/6 full events from sensor
    else
        events = [];
    end
           
        
        
% *************************************************************************
function n=SerPortBytesAvailable(s)     % how many received chars are waiting?
    n=s.BytesAvailable();


% *************************************************************************
% **  DVS128 Functions **
% *************************************************************************
function events = DVS128GetEvents(s, n) % get n events (=2*n bytes) from sensor
    eventBytes=SerPortRead(s, 6*n);     % read events from serial port

    eventY=eventBytes(1:6:end);         % fetch every 2nd byte starting from 1st
    eventX=eventBytes(2:6:end);         % fetch every 2nd byte starting from 2nd

    timeStamp = 256^3 * eventBytes(3:6:end) + 256^2 * eventBytes(4:6:end) + 256 * eventBytes(5:6:end) + eventBytes(6:6:end);
    
% % %     %   split data in polarity and y-events
    eventP = eventX > 127;
    eventX=(eventX-(128*eventP));
    eventY=(eventY - 128);
    
    % just peack up meaningful events
    eventIndexes = find(eventX >= 0 & eventX <= 127 & eventY >= 0 & eventY <= 127 & timeStamp < 10^9);
    eventX = eventX(eventIndexes);
    eventY = eventY(eventIndexes);
    eventP = eventP(eventIndexes);
    timeStamp = timeStamp(eventIndexes);
    
    if (timeStamp > 500000000)
        ok = 0;
    end
    
    events=[eventX eventY eventP timeStamp];
    
    
% *************************************************************************
function l = SerPortRead(s, n)            % read (at most n chars) from SerPort
    if (nargin<1)
        n = s.BytesAvailable;
    end
    l=fread(s, n, 'uint8');


