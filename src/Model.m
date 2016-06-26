classdef Model < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        controller
        buffer
        filters
        ServoPositionX
        ServoPositionY
        filteredEvents
        ballPos
        ballVel
        angVal
        
    end %properties
    
    methods
        function obj = Model(con)
            obj.controller = con;
            obj.filters = Filter();
            obj.buffer = BufferRing(75);
            obj.ServoPositionX = 0;
            obj.ServoPositionY = 0;
        end %Model
        
        function OnNewEvent(obj, Events)
            %first filter events from out of border (they are worthless)
            obj.buffer.Add(obj.filters.DataFilter(Events))
            %position calculation and first simple velocity 
            [obj.ballPos, obj.ballVel] = obj.filters.DetermineBallPosition(obj.buffer.GetAll());
            
            %regler
            %To do: determine Kp Kd so that angVal is in [-500, 500]                
            obj.angVal = 9*(obj.ballPos - 60) + 40*(obj.ballVel);
            
           %calculate motor movement
            if ( (length(obj.angVal)<2) || (length(obj.ballPos)<2) )
                disp(obj.angVal);

            elseif ( (abs(obj.angVal(1)) < 500) && (abs(obj.angVal(2)) < 500) )
                %put them to gui
                obj.controller.view.update(obj.buffer.GetAll(), obj.ballPos, 10*obj.ballVel);

                obj.ServoPositionX = 2048+obj.angVal(1);
                obj.ServoPositionY = 2048-obj.angVal(2);
            end
            
        end %OnNewEvent()
        
        function positionX = GetServoPositionX(obj)
            positionX = obj.ServoPositionX;
        end %GetServoPositionX()
        
        function positionY = GetServoPositionY(obj)
            positionY = obj.ServoPositionY;
        end %GetServoPositionX()
    end %methods
    
    
end

