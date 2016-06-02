function replay_events()
% DVS128Display(portName, baudRate, figureNumber)
%
% portName:
%   Linux:   '/dev/ttyS<x>'
%   Mac OSX: '/dev/tty.KeySerial<x>'
%   Windows: 'com<x>'

[fileName,pathName,filterIndex] = uigetfile('*.bin','Event file','events_00_07_34.bin')
%fileName = 'events_23_44_58.bin';

% *************************************************************************
close all
figure;                                 % open display
DVSImageMemory=zeros(128,128);          % allocate memory for image

% *************************************************************************
tic;                                    % start timing
displayDecay = 0.8;                     % how strongly fade per redraw time

% *************************************************************************

fid = fopen([pathName, fileName], 'r');
[data,count] = fread(fid, 'int32');
fclose(fid);

Events(:,1) = data(1:4:end);
Events(:,2) = data(2:4:end);
Events(:,3) = data(3:4:end);
Events(:,4) = data(4:4:end);

nEvents = size(Events, 1);
endEventIndex = 1;
while(endEventIndex < nEvents)
    startEventIndex = endEventIndex;
    currentTime = toc;
    while (endEventIndex <= nEvents && Events(endEventIndex,4) / 10^6 <= currentTime)
        endEventIndex = endEventIndex + 1;
    end
    indexes = startEventIndex : endEventIndex;

    DVSImageMemoryPointer=(128*(Events(indexes,1)) + Events(indexes,2))+1;
                                                % compute pointer to those
                                                % pixels that have send
                                                % events
        DVSImageMemory(DVSImageMemoryPointer)=...
            DVSImageMemory(DVSImageMemoryPointer)+...
            2*(1-2*Events(indexes,3));                % update image memory for new events, use polarity

        DVSImageMemory=displayDecay*DVSImageMemory; % fade image memory

        imagesc(DVSImageMemory);            % display image
        axis off square;                    % some cosmetics
        caxis([-5 5]);
        %title([num2str(round(toc)) 's']);
        title(sprintf('Time: %.1f s', Events(endEventIndex, 4) / 10^6));
        drawnow;                            % and really show now

end
fclose(fid);

return
