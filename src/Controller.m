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
        dat %TODO for test only
        comPorts
    end %events
    
    methods
        %TODO: Get Baudrate and CO from a config file
        %TODO: Automatic scan Serial Ports
        function obj = Controller()
            
            % set this to 1 if application needs to start in demo mode
            obj.useDemoBool = 0;
            
            %start services (Model gets only data from services)
            obj.comPorts = {'com3', 'com7', 'com8'}
            
            obj.model = Model(obj);
            obj.initDVS();
            obj.connectDVS();
            if obj.useDemoBool == 0 
                obj.servo_x = Servos(obj.comPorts{2}, 1000000);
                obj.servo_y = Servos(obj.comPorts{3}, 1000000);
            end
            
            
            %start business logic

            %TODO: start view (if useful)
            
            obj.view = BallBalancerView(obj);
            %run programm
            %obj.Run();
        
            %TODO: clean up
        end
        
        function initDVS(obj)
            %init dvs
            if obj.useDemoBool == 1
                obj.dvs = DVS128Demo(obj.comPorts{1}, 6000000);
            else
                obj.dvs = DVS128(obj.comPorts{1}, 6000000);
            end
        end
        
        function connectDVS(obj)
           obj.dvs.Connect(); 
        end
        
        function Run(obj)
            i = 1;
            dat = cell(100,1);
            while obj.isRunning
                           
                %check for new events
                %TODO: solve it event based
                if obj.dvs.EventsAvailable()
                    eventData =  obj.dvs.GetEvents();
                    %put them in filter 
                    filteredData = obj.dvs.DataFilter(eventData);
                    %position calculation and first simple velocity 
                    [ballPos, ballVel] = obj.dvs.DetermineBallPosition(filteredData);
                    
                    %put them to gui
                    obj.view.update(filteredData, ballPos, 10*ballVel);
                    
                    %regler
                    %To do: determine Kp Kd so that angVal is in [-500, 500]                
                    angVal = 9*(ballPos - 60) + 43*(ballVel);
                    
                    %motor movement
                    if ( (obj.useDemoBool == 0) & (abs(angVal(1)) < 500) & (abs(angVal(2)) < 500) )
                        obj.servo_x.SetPosition(2048+angVal(1));
                        obj.servo_y.SetPosition(2048+angVal(1));
                    end
                    
                    dat{i} = eventData;
                    i = i + 1;
                end %if obj.dvs.EventsAvailable()
                pause(0.2)
            end %while
            save('lastRun.mat', 'dat');
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

