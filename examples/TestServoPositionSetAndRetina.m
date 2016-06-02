%% Test: Setting Servo positions
clc
clear all
SerPortCloseAll();

% Servos Serial Handler Object
global s_x;
global s_y;
global s_retina;

InitPosDeg  = 180; 
CWdeg       = 135; 
CCWdeg      = 225; 

InitPosBin  = 2048;     % 180 Deg
CWbin       = 1536;     % 135 Deg
CCWbin      = 2560;     % 225 Deg
bin2deg     = (CCWbin - CWbin)/(CCWdeg - CWdeg);

portName_x = 'COM6';
portName_y = 'COM7';
portName_r = 'COM8';

% The BaudRate configuration for Servos and for Retina
baudRateServo   = 1000000;
baudRateRetina  = 6000000;

InitServos(portName_x, portName_y, baudRateServo);
InitRetina(portName_r, baudRateRetina);


%% Set the servos into the center position 
% This values can be changed for a diiferent balancing target
SetPosition(s_x, InitPosBin);
SetPosition(s_y, InitPosBin);

SetPosition(s_x, CWbin);
SetPosition(s_y, CWbin);


for i=1500:100:2500
    SetPosition(s_x, i);
    pause(1);
end
%% The DVS events data
figure;
DVSImageMemory = zeros(128,128);        % allocate memory for image
tic;                                    % start timing
timeDelta = 0.005;                         % how often to fade/redraw
nextToc = toc + timeDelta;
displayDecay = 0.8;                     % how strongly fade per redraw time

%  Creat the file you want to save the events on it ***********************
format = 'yyyy_mm_dd__HH_MM_SS';
fileName = sprintf('events_%s.bin', datestr(now, format));
fid = fopen(fileName,'w');
%**************************************************************************
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
gcf;
set(gcf, 'KeyPressFcn', @myKeyPressFcn);
% *************************************************************************

dt = 0.1; t = 0:dt:20;
x =  45*sin(10*t);
y =  45*sin(2*t);
plot(x,y);

i = 1;
c = 1;

while (~KEY_IS_PRESSED && i <= length(x))
   
    Events = get_retina_events();
    
    if ( not(isempty(Events)) )
        L(c) = length(Events);
        c = c + 1;
        
        writeEventData(fid, Events);
        
% Show the events on the Image Memory *************************************
        % compute pointer to those pixels that have send events
        DVSImageMemoryPointer=(128*(Events(:,1)) + Events(:,2))+1;  

        DVSImageMemory(DVSImageMemoryPointer)=...
            DVSImageMemory(DVSImageMemoryPointer)+...
            2*(1-2*Events(:,3));          % update image memory for new events, use polarity

        if (toc >= nextToc)               % have 20ms elapsed?
            nextToc = nextToc+timeDelta;  % advance time memory
            
            DVSImageMemory = displayDecay * DVSImageMemory; 
            
            % fade image memory
            imagesc(DVSImageMemory);      % display image
            axis off square;              % some cosmetics
            title(sprintf('Time:          %.1f s', Events(end, 4) / 10^6));
            caxis([-5 5]);
            drawnow;                      % and really show now
        end
%**************************************************************************
    end   
        
    X = bin2deg * x(i) + InitPosBin;
    Y = bin2deg * y(i) + InitPosBin;
    
    SetPosition(s_x, X);
    SetPosition(s_y, Y);
    i = i + 1;
    
    pause(0.1);
end

fclose(fid);


