classdef Fuzzy < handle
    
    
    properties
        posFunc
        velFunc
        posPercOneState
        velPercOneState
        pos
        vel
        numPosStates
        numVelStates
        minPos
        maxPos
        minVel
        maxVel
    end %properties
    
    methods
        
        function obj = Fuzzy(position, velocity)
            
            % all settings here
            obj.numPosStates = 3;
            obj.numVelStates = 3;
            
            obj.minPos = [0;0];
            obj.maxPos = [120;120];
            obj.minVel = [-10;-10];
            obj.maxVel = [10;10];
            
            obj.posPercOneState = 0;
            obj.velPercOneState = 0;
            % end settings
            
            
            
            obj.pos = (position-obj.minPos)/(obj.maxPos-obj.minPos);
            obj.vel = (velocity-obj.minVel)/(obj.maxVel-obj.minVel);
            
            obj.getStates()
            
            obj.calculate()
        end %Fuzzy
        
        
        function names = getStates(obj)
            posName = ['posHorz'; 'posVert'];
            velName = ['velHorz'; 'velVert'];
            
            multiplePosName = padarray(posName, obj.numPosStates-1, 'replicate', 'both');
            posNumbers = [1:obj.numPosStates, 1:obj.numPosStates]';
            
            multipleVelName = padarray(velName, obj.numVelStates-1, 'replicate', 'both');
            velNumbers = [1:obj.numVelStates, 1:obj.numVelStates]';
            
            names = [multiplePosName, num2str(posNumbers); multipleVelName, num2str(velNumbers)];
        end %getStates
        
        
        function percentages = calculate(obj)
            percentages = zeros(2*obj.numPosStates+2*obj.numVelStates,1);
            j=1;
            for i=1:obj.numPosStates
                percentages(j) = obj.getPercentage(i, obj.pos(1), 0);
                j = j + 1;
            end
            for i=1:obj.numPosStates
                percentages(j) = obj.getPercentage(i, obj.pos(2), 0);
                j = j + 1;
            end
            for i=1:obj.numVelStates
                percentages(j) = obj.getPercentage(i, obj.vel(1), 1);
                j = j + 1;
            end
            for i=1:obj.numVelStates
                percentages(j) = obj.getPercentage(i, obj.vel(2), 1);
                j = j + 1;
            end
            
        end %calculate
        
        
        function percentage = getPercentage(obj, state, posvelValue, pos0vel1)
            if pos0vel1
                width = 120/(obj.numVelStates + obj.velPercOneState -1);
                totalWidth = (2-obj.velPercOneState)*width;
                
                startInterval = (state)*width-totalWidth;
                firstIntervalPoint = startInterval+(1-obj.velPercOneState)*width;
                secondIntervalPoint = startInterval+ width;
                endInterval = (state)*width;      
            else
                width = 1/(obj.numPosStates + obj.posPercOneState -1);
                totalWidth = (2-obj.posPercOneState)*width;
                
                startInterval = (state)*width-totalWidth;
                firstIntervalPoint = startInterval+(1-obj.posPercOneState)*width;
                secondIntervalPoint = startInterval+ width;
                endInterval = (state)*width;               
            end
            
            if ( (posvelValue > startInterval) && (posvelValue < firstIntervalPoint) )
                percentage = (posvelValue - startInterval)/(firstIntervalPoint - startInterval);
            elseif (posvelValue >= firstIntervalPoint) && (posvelValue <= secondIntervalPoint )
                percentage = 1;
            elseif (posvelValue > secondIntervalPoint) && (posvelValue < endInterval)
                percentage = (posvelValue - endInterval)/(secondIntervalPoint - endInterval);
            else
                percentage =0;
            end
            
        end %getPercentage
        
        
    end % methods
    
end