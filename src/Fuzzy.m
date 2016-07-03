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
        states
    end %properties
    
    methods
        
        function obj = Fuzzy()
            
            % all settings here
            obj.numPosStates = 6;
            obj.numVelStates = 10;
            
            obj.minPos = [0;0];
            obj.maxPos = [120;120];
            obj.minVel = [-250;-250];
            obj.maxVel = [250;250];
            
            obj.posPercOneState = 0;
            obj.velPercOneState = 0;
            % end settings
           
            obj.states = obj.createStates();           
            
            
        end %Fuzzy
        
        function count = GetNumStatesPerVariable(obj)
            %TODO: Not best solution
            diffstates = obj.GetDiffStates();
            num = size(diffstates);
            count = zeros(num(1),1);
            %iterate States
            for n = 1:length(obj.states)
                %iterate different states. search for hits
                for j = 1:num(1)
                    str = strrep(obj.states(n),diffstates(j,:),'');
                    if  ~strcmp(obj.states(n),str)
                       count(j) = count(j) + 1; 
                    end
                    %diffstates(j,2) = [posName(1,:) , strrep(states(n),posName(1,:),'')];
                    %end
                end
            end
        
        end %GetStates()
       
        function diffstates = GetDiffStates(obj)                
                diffstates = ['posHorz';
                'posVert';
                'velHorz';
                'velVert'];
        
        end %GetDiffStates()
        
        function states = GetStates(obj)
            states = obj.states;
        
        end %GetStates()
        
        
        function names = createStates(obj)
            posName = ['posHorz'; 'posVert'];
            velName = ['velHorz'; 'velVert'];
            
            multiplePosName = padarray(posName, obj.numPosStates-1, 'replicate', 'both');
            posNumbers = [1:obj.numPosStates, 1:obj.numPosStates]';
            
            multipleVelName = padarray(velName, obj.numVelStates-1, 'replicate', 'both');
            velNumbers = [1:obj.numVelStates, 1:obj.numVelStates]';
            
            names = strtrim([num2cell([multiplePosName, num2str(posNumbers, '%-1d ')],2); ...
                     num2cell([multipleVelName, num2str(velNumbers, '%-1d ')],2)]);
        end %getStates
        
        
        function percentages = calculate(obj, position, velocity)
            
            if ( ( position(1)<obj.minPos(1) ) || ( position(2)<obj.minPos(2) ) || ...
                 ( position(1)>obj.maxPos(1) ) || ( position(2)>obj.maxPos(2) ) || ...
                 ( velocity(1)<obj.minVel(1) ) || ( velocity(2)<obj.minVel(2) ) || ...
                 ( velocity(1)>obj.maxVel(1) ) || ( velocity(2)>obj.maxVel(2) ) )
                
                velocity(1) = obj.LimitValue(velocity(1),obj.minVel(1),obj.maxVel(1));
                velocity(2) = obj.LimitValue(velocity(2),obj.minVel(2),obj.maxVel(2));
                disp('Position or Velocity outside of expected interval. Change the minPos ... maxVel Properties of Fuzzy.')
                disp([position(1), position(2), velocity(1), velocity(2)])
                
                
            end
            
                
            obj.pos = (position-obj.minPos)/(obj.maxPos-obj.minPos);
            obj.vel = (velocity-obj.minVel)/(obj.maxVel-obj.minVel);
            
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
                width = 1/(obj.numVelStates + obj.velPercOneState -1);
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
        
        function newvalue = LimitValue(obj,value, min, max)
            newvalue = value;
            if  value > max 
                newvalue(1) = max;
            elseif value < min 
                newvalue = min;
            end
        end %LimitValues
        
        
    end % methods
    
end