classdef MatrixOfMoves < handle
    %MATRIXOFMOVES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mat
    end
    
    methods
        function obj = MatrixOfMoves(Pos, Vel)
            obj.mat = ones([Pos Vel]);
            disp(obj.mat);
        end
        
        function move = GetMoveByPercentages(obj, PosPercentage, VelPercentage)
            %iterate and add all propabilities 
            move = 0;
            for n = 1:length(PosPercentage)
                if PosPercentage(n) ~= 0
                    for m = 1:length(VelPercentage)
                        %if probability exists for pos and vel add this
                        %value to move
                        if VelPercentage(m) ~= 0
                            move = move + (PosPercentage(n)* VelPercentage(m) * obj.mat(n,m));
                        end %if
                    end %for
                end %if
            end %for
            
        end
    end
    
end

