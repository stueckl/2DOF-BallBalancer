classdef QController < handle
    %NEURALFUZZYCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        learning
        matAngValX
        matAngValY
        fuzzyLogic
        fuzzyStates
        fuzzyStatesPerVariable
        fuzzyComperator
        percentages
        randomWeight
        randomfaktor
        angVal
        randAngVal
    end
    
    methods
        function obj = QController()
            %first layer of logic
            obj.learning = 1;
            obj.randomWeight = 1;
            obj.fuzzyLogic = Fuzzy();
            obj.fuzzyStates = obj.fuzzyLogic.createStates();
            
            %second layer of logic 
            %add a create a matrix  for each state and variable
            %Matrixes are build ['posHorz', 'velHorz']
            obj.fuzzyStatesPerVariable = transpose(obj.fuzzyLogic.GetNumStatesPerVariable());                      
            obj.matAngValX = MatrixOfMoves(obj.fuzzyStatesPerVariable(1), obj.fuzzyStatesPerVariable(3), 5);
            obj.matAngValY = MatrixOfMoves(obj.fuzzyStatesPerVariable(2), obj.fuzzyStatesPerVariable(4), 5);
            %load nets based on States names from subfolders
            
            %third layer of logic
            
            
        end %NeuralFuzzyController()
        
        function angVal = Calculate(obj, ballPos, ballVel)
            
            %first layer calculation
            transBallPos = transpose(ballPos);
            transBallVel = transpose(ballVel);
            obj.percentages = obj.fuzzyLogic.calculate(transBallPos, transBallVel);
            %now we know which state got which percentage than we can get
            %the values for Velocity and position sorted by X and Y
            %With them we can look up in the table of moves
            %with the value we can move
            
            
            
            %second layer calculation
            %get move by percentages for each axis and calculate them
            
            obj.angVal(1) = obj.matAngValX.GetMoveByPercentages(obj.percentages(1:6),obj.percentages(13:22));
            obj.angVal(2) = obj.matAngValY.GetMoveByPercentages(obj.percentages(7:12),obj.percentages(23:32));
            angVal = obj.angVal;
            
            
        end % Calculate()
        
        function angVal = CalculateBest(obj)
            angVal(1) = obj.matAngValX.GetBestMove(obj.percentages(1:6),obj.percentages(13:22));
            angVal(2) = obj.matAngValY.GetBestMove(obj.percentages(7:12),obj.percentages(23:32));

        end
        
        %reward is a value between 0.x to 1.x to increasing or decreasing
        %the percentage values bigger than 1 are rewards and lower than 1
        %punishments
        function reward = rewardDist(obj, newBallPos, oldBallPos, center)
            %reward decreased distance to center,
            %distXOld = abs(ballXNew - CenterX)
            %distXNew = abs(ballXOld - CenterX)
            %improvedDistance = distXOld - distXNew
            %if improvedDistance > distXOld punish
            %same for y
            
            %set to neutral
            reward = [1,1];
            
            %calculate improved distance to center
            distOld = abs(oldBallPos - center);
            distNew = abs(newBallPos - center);
            imprDist = distOld - distNew;
            
            %reward if greater than zero, punish otherwise
            reward = 10*(reward .* 2 .* obj.sigmoid(0.01*imprDist)-1);

            %reward low speed in center
            %reward = reward .* 2. * obj.sigmoid(1./abs(ballVel));
            
        end %reward()
        
        function reward = rewardDistAndVel(obj, newBallPos, oldBallPos, ballVel, center)
            %reward decreased distance to center,
            %distXOld = abs(ballXNew - CenterX)
            %distXNew = abs(ballXOld - CenterX)
            %improvedDistance = distXOld - distXNew
            %if improvedDistance > distXOld punish
            %same for y
            
            %set to neutral
            reward = [1,1];
            
            %calculate improved distance to center
            distOld = abs(oldBallPos - center);
            distNew = abs(newBallPos - center);
            imprDist = distOld - distNew;
            
            %reward if greater than zero, punish otherwise
            reward = 10*(reward .* 2 .* obj.sigmoid(0.01*imprDist)-1);

            %reward low speed in center
            %reward = reward .* 2. * obj.sigmoid(1./abs(ballVel));
            
        end %reward()
        
        function g = sigmoid(obj, z)
          g = 1.0 ./ ( 1.0 + exp(-z)); 
        end %end sigmoid
        
        %goal is a value betwen -1 and 1 for good or bad previous action
        %val 1 stands for X and 2 for Y
        function Learn(obj,val,betterVal,reward)
            if val == 1
                obj.matAngValX.Learn(betterVal,reward);
            else
                obj.matAngValY.Learn(betterVal,reward);
            end
        end
        
        %Learn from is for offline learning from other algorithms
        function LearnFrom(obj,goalAngVal)
            bestMove = obj.CalculateBest();
            %iterate each output variable
            s = size(goalAngVal);
            for val = 1:s(2)
                %check if move is better than best move
                if abs(goalAngVal(val)- obj.angVal(val)) < abs(goalAngVal(val)-bestMove(val))
                    %learn
                    obj.Learn(val,obj.angVal(val),0.1);
                else
                    obj.Learn(val,obj.angVal(val),-0.1);
                end
                
                %learn
            end
            obj.matAngValX.Surf();
            
        end
    end
    
end

