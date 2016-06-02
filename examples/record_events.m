function L = record_events()
clc

tic
figure(1);                              % open display

DVSImageMemory = zeros(128,128);        % allocate memory for image
tic;                                    % start timing
timeDelta = 0.005;                         % how often to fade/redraw
nextToc = toc + timeDelta;
displayDecay = 0.8;                     % how strongly fade per redraw time

format = 'yyyy_mm_dd__HH_MM_SS';
fileName = sprintf('events_%s.bin', datestr(now, format));
fid = fopen(fileName,'w');


global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
%gcf
set(gcf, 'KeyPressFcn', @myKeyPressFcn)

% *************************************************************************
c = 1;

while ~KEY_IS_PRESSED
    
    Events = get_retina_events();
        
    if ( not(isempty(Events)) )
%         if( Events(end,4) > 10*10^6 )
%             KEY_IS_PRESSED = 1;
%         end
        L(c) = length(Events);
        c = c + 1;
        
        writeEventData(fid, Events);
        
%/////////////////////////////////////////////////////////////////////////
%         DVSImageMemoryPointer=(128*(Events(:,1)) + Events(:,2))+1;  % compute pointer to those pixels that have send events
% 
%         DVSImageMemory(DVSImageMemoryPointer)=...
%             DVSImageMemory(DVSImageMemoryPointer)+...
%             2*(1-2*Events(:,3));                % update image memory for new events, use polarity
% 
%         if (toc >= nextToc)                       % have 20ms elapsed?
%             nextToc = nextToc+timeDelta;          % advance time memory
%             
%             DVSImageMemory = displayDecay * DVSImageMemory; 
%             
%             % fade image memory
%             imagesc(DVSImageMemory);            % display image
%             axis off square;                    % some cosmetics
%             title(sprintf('Time: %.1f s', Events(end, 4) / 10^6));
%             %caxis([-5 5]);
%             drawnow;                            % and really show now
%         end
% pause(0.5);
%/////////////////////////////////////////////////////////////////////////
    end    
end
fclose(fid);
% printf('End of Recording\n')
finalize_retina();



