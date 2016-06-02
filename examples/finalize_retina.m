function finalize_retina()

global s_retina;

% *************************************************************************
SerPortWriteLine(s_retina, 'E-');               % stop DVS128

% *************************************************************************
SerPortClose(s_retina);                         % close serial port
disp ('COM-Port closed');






% *************************************************************************
% **  Serial Port Functions **
% *************************************************************************
function SerPortCloseAll()                      % close all open ports
    if ~(isempty(instrfind))
        fclose(instrfind);
    end
    delete(instrfindall);

% *************************************************************************
function SerPortClose(s)                        % close specified port
    fclose(s);
    
% *************************************************************************
function SerPortWriteLine(s, l)         % send this line 'l' to serial port with trailing return
    fwrite(s,[l 10],'uint8');

    
    