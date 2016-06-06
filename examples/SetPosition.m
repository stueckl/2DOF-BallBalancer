function SetPosition(s, GoalPosition)

    % ServoX Serial Handler Object
    ServoID = 1;
    
    % The instruction for motor command    
    WriteInstruction = 3; 
    
    LowestByte = mod(GoalPosition, 256);
    HighestByte = floor(GoalPosition / 256);
    parameters = [30, LowestByte, HighestByte];
    nParameters = length(parameters);
    packetLength = nParameters + 2;
    checkSum = ServoID + packetLength + WriteInstruction + sum(parameters);
    checkSum = 255 - mod(checkSum, 256);
    WritePacket = [255, 255, ServoID, packetLength, WriteInstruction, parameters, checkSum];

    fwrite(s, WritePacket,'uint8');
    
%     % The instruction for reading the error buffer and current position
%     ReadInstruction = 2; 
%     
%     parameters = [36, 2];
%     packetLength = 4;
%     checkSum = ServoID + packetLength + ReadInstruction + sum(parameters);
%     checkSum = 255 - mod(checkSum, 256);
%     ReadPacket = [255, 255, ServoID, 4, ReadInstruction, parameters, checkSum];   
%   
%     SerPortFlush(s_rh);
%     fwrite(s_rh, ReadPacket,'uint8');
%     IncomingPacket = SerPortRead(s_rh, 100)
%     % If you read two Bytes from same ServoID
%     if(IncomingPacket(9) == ServoID && IncomingPacket(10) == 4)
%         ErrorBuffer = IncomingPacket(5);
%         CurrentPosition = uint16(IncomingPacket(12) + IncomingPacket(13) * 256)
%     else
%         warning('An error is happened during last instruction');     
%     end
    
  
% % *************************************************************************
% function SerPortFlush(s)                % flush (read in all data) from port
%     n = s.BytesAvailable;
%     if (n > 0)
%         fread(s, n, 'uint8');
%     end
%     
% % *************************************************************************
% function l = SerPortRead(s, n)          % read (at most n chars) from SerPort
%     if (nargin < 1)
%         n = s.BytesAvailable;
%     end
%     l = fread(s, n, 'uint8');

    
    
    