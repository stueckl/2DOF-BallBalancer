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
        PDAngVal
        iteration
        
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
            iteration = 0;
        end %Model
        
        function OnNewEvent(obj, Events, elapsed)
            %first filter events from out of border (they are worthless)
            obj.buffer.Add(obj.filters.DataFilter(Events));
            %position calculation and velocity
            obj.CalcBallPosAndVel(elapsed);
            %[obj.ballPos, obj.ballVel] = obj.filters.DetermineBallPosition(obj.buffer.GetAll());
            
            %regler, choose one  
            %obj.PDController();
            %disp(obj.angVal);
            obj.QController();
            %disp(obj.angVal);
            %obj.QControllerFromPD();
            
           %calculate motor movement
            if ( (length(obj.angVal)<2) || (length(obj.newBallPos)<2) )
                disp(obj.angVal);

            elseif ( (abs(obj.angVal(1)) < 500) && (abs(obj.angVal(2)) < 500) )
                %put them to gui
                obj.controller.view.update(obj.buffer.GetAll(), obj.newBallPos, 0.5*obj.ballVel);
                %disp(obj.angVal)
                obj.ServoPositionX = 2048+obj.angVal(1);
                obj.ServoPositionY = 2048-obj.angVal(2);
            else
                disp('>500')
                disp(obj.angVal)
            end           
            
            obj.UpdateOldBallPosition();
            
        end %OnNewEvent()
        
        function CalcBallPosAndVel(obj, elapsed)
            obj.newBallPos = obj.filters.DetermineBallPosition(obj.buffer.GetAll());
            if(obj.oldBallPos == -1)
               obj.oldBallPos = obj.newBallPos;
            end
            obj.ballVel = (obj.newBallPos - obj.oldBallPos)/(elapsed);
            disp(obj.ballVel)
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
            obj.angVal = 9*(obj.newBallPos - 60) + 0.07*(obj.ballVel);
        end
        
        function QController(obj) 
            %PDAngVal = obj.angVal;
            reward = obj.qController.reward2(obj.newBallPos, obj.oldBallPos, [60, 60]);
            %reward = obj.qController.reward2(obj.newBallPos, obj.oldBallPos, [60, 60]);
            %disp(reward)
            %first learn old move seperate for x and y
            s = size(obj.angVal);
            for val = 1:s(2)
                    obj.qController.Learn(val,obj.angVal(val),reward(val));
            end
            %calculate new move
            if length(obj.newBallPos) == 2
                
                obj.angVal = obj.qController.Calculate(obj.newBallPos, obj.ballVel);

                %obj.qController.Learn(PDAngVal);
            end
        end   
        function QControllerFromPD(obj)
            %calculate new move
            if length(obj.newBallPos) == 2
                obj.PDController();
                disp('PDController')
                disp(obj.angVal)
                if obj.iteration == 1
                    obj.qController.LearnFrom(obj.angVal);
                end
                obj.angVal = obj.qController.Calculate(obj.newBallPos, obj.ballVel);
                disp('QController')
                disp(obj.angVal)
                %obj.angVal = PDAngVal;

                %obj.qController.Learn(PDAngVal);
                obj.iteration = 1;
            end
        end  
            
    end %methods
    
    
end

