classdef NeuralFuzzyController < handle
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
        function obj = NeuralFuzzyController()
            %first layer of logic
            obj.learning = 1;
            obj.randomWeight = 1;
            obj.fuzzyLogic = Fuzzy();
            obj.fuzzyStates = obj.fuzzyLogic.createStates();
            
            %second layer of logic 
            %add a create a matrix  for each state and variable
            %Matrixes are build ['posHorz', 'velHorz']
            obj.fuzzyStatesPerVariable = transpose(obj.fuzzyLogic.GetNumStatesPerVariable());                      
            obj.matAngValX = MatrixOfMoves(obj.fuzzyStatesPerVariable(1), obj.fuzzyStatesPerVariable(3));
            obj.matAngValY = MatrixOfMoves(obj.fuzzyStatesPerVariable(2), obj.fuzzyStatesPerVariable(4));
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
            if obj.learning
                obj.randomfaktor = obj.randomWeight * (0.5 - rand(1));
                obj.randAngVal = obj.randomfaktor + obj.angVal; 
                angVal = obj.randAngVal;
            else
                angVal = obj.angVal;
            end
            
            
        end % Calculate()
        
        %goal is a value betwen -1 and 1 for good or bad previous action
        %val 1 stands for X and 2 for Y
        function Learn(obj,val,betterVal)
            if val == 1
                obj.matAngValX.MoveWasGood(betterVal);
            else
                obj.matAngValY.MoveWasGood(betterVal);
            end
        end
        
        %Learn from is for offline learning from other algorithms
        function LearnFrom(obj,goalAngVal)
            %iterate each output variable
            for val = 1:length(goalAngVal)
                %check if new value (random) is nearer to matrix value, if
                %yes it is a good value -> learn it.
                if abs(goalAngVal(val)- obj.randAngVal(val)) < abs(goalAngVal(val)-obj.angVal(val))
                    %learn
                    obj.Learn(val,obj.randAngVal(val));
                end
                
                %learn
            end
            obj.matAngValY.Surf();
            
        end
    end
    
end

