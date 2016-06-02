%% Test: Setting Servo positions
clc
clear all
close all

SerPortCloseAll();

% Servos Serial Handler Object
global s_x;
global s_y;
global s_retina;

InitPosDeg  = 180; 
CWdeg       = 135; 
CCWdeg      = 225; 
InitPosBin  = 2048;
CWbin       = 1536;
CCWbin      = 2560;
bin2deg     = (CCWbin - CWbin)/(CCWdeg - CWdeg);

portName_x = 'COM18';
portName_y = 'COM19';
portName_r = 'COM4';

baudRateServo   = 1000000;
baudRateRetina  = 6000000;

InitServos(portName_x, portName_y, baudRateServo);
InitRetina(portName_r, baudRateRetina);


%% Set the servos into the center position
SetPosition(s_x, InitPosBin);
SetPosition(s_y, InitPosBin);

%% The DVS events data
figure;
DVSImageMemory = zeros(128,128);        % allocate memory for image
tic;                                    % start timing
timeDelta = 0.005;                         % how often to fade/redraw
nextToc = toc + timeDelta;
displayDecay = 0.8;                     % how strongly fade per redraw time

%**************************************************************************
global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
gcf;
set(gcf, 'KeyPressFcn', @myKeyPressFcn);
% *************************************************************************

dt = 0.1; t = 0:dt:20;
x =  45*sin(5*t);
y =  45*sin(2*t);
plot(x,y);

i = 1;
c = 1;

xMEAN = zeros(1,1);
yMEAN = zeros(1,1);

EventBuffer = zeros(1,4);
while (~KEY_IS_PRESSED && i <= length(x))
   
    Events = get_retina_events();
    EventBuffer = vertcat(EventBuffer, Events);



    if ( not(isempty(Events)) )
        [m n] = size(Events);
        L(c) = m;
        
        eTEMP = zeros(m,2);
        eTEMP(1:end,:) = Events(1:end,1:2);

        xMEAN(c,1) = mean(eTEMP(:,1)); 
        yMEAN(c,1) = mean(eTEMP(:,2)); 
        c = c + 1;
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
    
    pause(0.025);
end

tStart  = 7.0;
tEnd    = 8.0;

T = zeros(length(EventBuffer) , 1 );
T(1:end, 1) = EventBuffer(1:end, 4);
I = (T > tStart*10^6) .* (T < tEnd*10^6);
indeices = find( I );
xFrame = EventBuffer(indeices, 1); save xFrame xFrame;
yFrame = EventBuffer(indeices, 2); save yFrame yFrame;
pFrame = EventBuffer(indeices, 3);

figure;
plot(xFrame, yFrame, 'o');
axis([1 128 1 128]);


teta = 0:1:3360;
xin = 50*cos(teta) + 61;
yin = 50*sin(teta) + 61;
hold on; plot(xin, yin, '.','Color', 'red');

figure;
plot(xMEAN, yMEAN, '--.');
axis([1 128 1 128]);

figure;
hist(L,0:4:max(L))
