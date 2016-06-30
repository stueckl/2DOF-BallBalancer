classdef Controller < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isRunning
        model %contains buisness logic
        dvs % sensor
        useDemoBool
        view % graphical user Interface (run in other thread slow 30-60fps)
        servo_x
        servo_y
        comPorts
    end %events
    
    methods
        %TODO: Get Baudrate and CO from a config file
        %TODO: Automatic scan Serial Ports
        function obj = Controller()
            
            % set this to 1 if application needs to start in demo mode
            obj.useDemoBool = 1;
            
            %start services (Model gets only data from services)
            SerialPort.CloseAll();
            obj.comPorts = SerialPort.getAvailableComPort();
            
            disp(obj.comPorts)
            %start business logic         
            obj.model = Model(obj);
            obj.initDVS();
            obj.dvs.Connect();
            if obj.useDemoBool == 0 
                obj.servo_x = Servos(obj.comPorts(2), 1000000);
                obj.servo_y = Servos(obj.comPorts(1), 1000000);
            end
                     
            %TODO: start view (if useful)
            
            obj.view = BallBalancerView(obj);
            tic
        end
        
        %TODO: Put into clean abstract class ofr DVSs
        function initDVS(obj)
            %init dvs
            if obj.useDemoBool == 1
                obj.dvs = DVS128Demo(obj.comPorts(1), 6000000);
            else
                obj.dvs = DVS128(obj.comPorts(3), 6000000);
            end
        end
        
        
        %TODO: put into model
        function OnNewEvent(obj,eventcount)
            
            %overload function
            %if nargin < 1
            %    eventcount = obj.dvs.EventsAvailable();
            %end %nargin ==1
            
            %get events (function is only called if there are new events)
            %position and velocity
            
            %logic
            obj.model.OnNewEvent(obj.dvs.GetEvents());
            
            %move servo
            if (obj.useDemoBool == 0)
                obj.servo_x.SetPosition(obj.model.GetServoPositionX());
                obj.servo_y.SetPosition(obj.model.GetServoPositionY());
            else
                %disp(['x position:' obj.model.GetServoPositionX()])
                %disp(['y posotion:' obj.model.GetServoPositionY()])
            end %(obj.useDemoBool == 0)
            
        end % OnNewEvent
        function Run(obj)
            time = 0;
            while obj.isRunning
                %DEBUG: display time needed for loop
                disp(toc - time);
                time = toc;
          
                %check for new events
                %if new events calculate
                %
                %check for new events
                %TODO: solve it event based
                if obj.dvs.EventsAvailable()
                        %calculate model
                        obj.OnNewEvent();                        
                        
                end %if obj.dvs.EventsAvailable()
                pause(0);
            end %while
%             save('lastRun.mat', 'dat');
        end %Run()
        
        function recordBorder(obj)

            tempEventdataAll = [];
            for j=0:pi/100:20*pi
                obj.servo_x.SetPosition(2048+400*cos(j));
                obj.servo_y.SetPosition(2048+400*sin(j));
                for i=1:1
                    if obj.dvs.EventsAvailable()
                        eventData =  obj.dvs.GetEvents();
                        %put them in filter & position calculation
                        %put them to gui
                        obj.view.update(eventData);
                        %regler
                        tempEventdataAll = vertcat(tempEventdataAll, eventData);
                        %motor movement

                    end %if obj.dvs.EventsAvailable()
                    pause(0.001)
                end
            end %while
            save('recodedBorder.mat', 'tempEventdataAll');
        end %recordBorder()
        
        
            
        function startLoop(obj)
           if obj.isRunning == 1
              return 
           end
           obj.isRunning = 1;
           obj.Run();
        end %starts the Main Loop
        
        function stopLoop(obj)
           if obj.isRunning == 0
               return
           end
           obj.isRunning = 0;
        end % stops the Main Loop
        
        function useDemo(obj, val)
            if  obj.useDemoBool ~= val
                obj.useDemoBool = val;
                disp(val)
                obj.initDVS();
                obj.connectDVS();
            end
        end %determines if demo dvs is used
        
        function setDemoFileName(obj, path, name)
            if obj.useDemoBool == 1
                obj.initDVS();
                obj.dvs.setFileName(path, name);
                obj.connectDVS();
            end
        end
        
        function setRandomPos(obj)
            obj.servo_y.SetPosition(2000);
        end
        
        function Destructor(obj)
            obj.stopLoop();
            if ~isequal(instrfind, [])
                fclose(instrfind);
            end
            
        end
        
    end %methods 
    
end

