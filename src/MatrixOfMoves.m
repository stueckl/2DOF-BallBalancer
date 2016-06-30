classdef MatrixOfMoves < handle
    %MATRIXOFMOVES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mat
        propabilities
        move
    end
    
    methods
        function obj = MatrixOfMoves(Pos, Vel)
            obj.mat = zeros([Pos Vel]);
            obj.propabilities = zeros(4,3);
        end
        
        function move = GetMoveByPercentages(obj, PosPercentage, VelPercentage)
            %iterate and add all propabilities 
            obj.move = 0;
            i = 1;
            for n = 1:length(PosPercentage)
                if PosPercentage(n) ~= 0
                    for m = 1:length(VelPercentage)
                        %if probability exists for pos and vel add this
                        %value to move
                        if VelPercentage(m) ~= 0
                            obj.propabilities(i,1:3) = [n, m, PosPercentage(n)*VelPercentage(m)];
                            obj.move = obj.move + (PosPercentage(n)* VelPercentage(m) * obj.mat(n,m));
                            i = i +1;
                        end %if
                    end %for
                end %if
            end %for
            move = obj.move;          
        end
        
        function Surf(obj)
            figure(2)
            surf(obj.mat);
        end
        
        function MoveWasGood(obj,betterVal)
            s = size(obj.propabilities);
            %for lines in obj.propabilities
            for i = 1:s(1)
                pos = obj.propabilities(i,1);
                vel = obj.propabilities(i,2);
                obj.mat(pos, vel) = obj.propabilities(i,3);
            end
        end
    end
    
end

