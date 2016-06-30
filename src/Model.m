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
        oldBallPos
        newBallPos
        ballVel
        angVal
        qController
        
    end %properties
    
    methods
        function obj = Model(con)
            obj.controller = con;
            obj.filters = Filter();
            obj.buffer = BufferRing(75);
            obj.ServoPositionX = 0;
            obj.ServoPositionY = 0;
            obj.qController = QController();
            obj.angVal = [0,0];
            obj.oldBallPos = -1;
            obj.newBallPos = -1;
        end %Model
        
        function OnNewEvent(obj, Events, elapsed)
            disp('new event')
            %first filter events from out of border (they are worthless)
            obj.buffer.Add(obj.filters.DataFilter(Events));
            %position calculation and velocity
            obj.CalcBallPosAndVel(elapsed)
            
            %regler, choose one  
            obj.PDController();
            %disp(obj.angVal);
            obj.QController();
            %disp(obj.angVal);
            
           %calculate motor movement
            if ( (length(obj.angVal)<2) || (length(obj.newBallPos)<2) )
                disp(obj.angVal);

            elseif ( (abs(obj.angVal(1)) < 500) && (abs(obj.angVal(2)) < 500) )
                %put them to gui
                obj.controller.view.update(obj.buffer.GetAll(), obj.newBallPos, 0.5*obj.ballVel);

                obj.ServoPositionX = 2048+obj.angVal(1);
                obj.ServoPositionY = 2048-obj.angVal(2);
            end           
            
            obj.UpdateOldBallPosition();
            
        end %OnNewEvent()
        
        function CalcBallPosAndVel(obj, elapsed)
            obj.newBallPos = obj.filters.DetermineBallPosition(obj.buffer.GetAll());
            if(obj.oldBallPos == -1)
               obj.oldBallPos = obj.newBallPos;
            end
            obj.ballVel = (obj.newBallPos - obj.oldBallPos)/elapsed;
            obj.ballVel
        end %calcBallPosAndVel
        
        function UpdateOldBallPosition(obj)
            obj.oldBallPos = obj.newBallPos;
        end
        
        function positionX = GetServoPositionX(obj)
            positionX = obj.ServoPositionX;
        end %GetServoPositionX()
        
        function positionY = GetServoPositionY(obj)
            positionY = obj.ServoPositionY;
        end %GetServoPositionX()
        
        function PDController(obj)
            obj.angVal = 9*(obj.newBallPos - 60) + 40*(obj.ballVel);
        end
        
        function QController(obj) 
            PDAngVal = obj.angVal;
            obj.angVal = obj.qController.Calculate(obj.newBallPos, obj.ballVel);
            obj.qController.LearnFrom(PDAngVal);
        end                     
            
    end %methods
    
    
end

