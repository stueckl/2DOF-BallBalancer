classdef MatrixOfMoves < handle
    %MATRIXOFMOVES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mat
        propabilities
        move
        actions
    end
    
    methods
        function obj = MatrixOfMoves(Pos, Vel, Act)
            %create matrix
            obj.actions = -500:50:500;
            
            obj.mat = ones([Pos Vel, length(obj.actions)]);
            %normalize
            for n = 1:Pos
                for m =1:Vel
                    obj.NormalizeState(n, m);
                end
            end
            
            
            %init empty
            obj.propabilities = zeros(4,4);
        end
        
        function obj = NormalizeState(obj, Pos, Vel)
           obj.mat(Pos,Vel,:) = obj.mat(Pos,Vel,:) /sum(obj.mat(Pos,Vel,:));
        end
        
        function id = GetActionByPropability(obj,Pos, Vel)
            id = find(rand<cumsum(obj.mat(Pos, Vel, :)),1,'first');
        end
        
        function id = GetBestAction(obj,Pos, Vel)
            id = find(max(obj.mat(Pos, Vel, :)));
        end
        
        function move = GetBestMove(obj, PosPercentage, VelPercentage)
            %iterate and add all propabilities 
            move = 0;
            i = 1;
            for n = 1:length(PosPercentage)
                if PosPercentage(n) ~= 0
                    for m = 1:length(VelPercentage)
                        %if probability exists for pos and vel add this
                        %value to move
                        if VelPercentage(m) ~= 0
                            act = obj.GetActionByPropability(n,m);
                            move = move + (PosPercentage(n)* VelPercentage(m) * obj.actions(act));
                            i = i +1;
                        end %if
                    end %for
                end %if
            end %for
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
                            act = obj.GetActionByPropability(n,m);
                            obj.propabilities(i,1:end) = [n, m, act, PosPercentage(n)*VelPercentage(m)];
                            obj.move = obj.move + (PosPercentage(n)* VelPercentage(m) * obj.actions(act));
                            i = i +1;
                        end %if
                    end %for
                end %if
            end %for
            move = obj.move;          
        end
        
        function Surf(obj)
            figure(3)
            surf(squeeze(obj.mat(:,4,:)));
        end
        
        function Learn(obj,betterVal,reward)
            s = size(obj.propabilities);
            %for lines in obj.propabilities
            for i = 1:s(1)
                pos = obj.propabilities(i,1);
                vel = obj.propabilities(i,2);
                act = obj.propabilities(i,3);
                obj.mat(pos, vel, act) = obj.mat(pos, vel, act) + obj.propabilities(i,4)*reward;
                if obj.mat(pos, vel, act) < 0
                    obj.mat(pos, vel, act) = 0;
                end                
                obj.NormalizeState(pos, vel);
            end
        end
    end
    
end

