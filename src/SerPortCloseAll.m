% *************************************************************************    
function SerPortCloseAll()                      % close all open ports
    if ~(isempty(instrfind))
        fclose(instrfind);
    end
    delete(instrfindall);