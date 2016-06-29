classdef NeuralFuzzyController < handle
    %NEURALFUZZYCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        matAngValX
        matAngValY
        fuzzyLogic
        fuzzyStates
        fuzzyStatesPerVariable
        fuzzyComperator
        percentages
    end
    
    methods
        function obj = NeuralFuzzyController()
            %first layer of logic
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
            %get move by percentages for each axis
            angVal(1) = obj.matAngValX.GetMoveByPercentages(obj.percentages(1:6),obj.percentages(13:22));
            angVal(2) = obj.matAngValY.GetMoveByPercentages(obj.percentages(7:12),obj.percentages(23:32));

            %third layer comparison
            
        end % Calculate()
    end
    
end

