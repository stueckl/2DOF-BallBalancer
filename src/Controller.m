classdef Controller < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isRunning
        model %contains buisness logic
        dvs % sensor
        useDemoBool
        view % graphical user Interface (run in other thread slow 30-60fps)
        servos
        dat %TODO for test only
    end %events
    
    methods
        %TODO: Get Baudrate and CO from a config file
        %TODO: Automatic scan Serial Ports
        function obj = Controller()
            
            % set this to 1 if application needs to start in demo mode
            obj.useDemoBool = 1;
            
            %start services (Model gets only data from services)
            obj.servos = Servos();
            obj.model = Model(obj);
            %start business logic
            
            %TODO: start view (if useful)
            obj.view = BallBalancerView(obj);
            
            %run programm
            obj.Run();
        
            %TODO: clean up
        end
        
        function initDVS(obj)
            %init dvs
            if obj.useDemoBool == 1
                obj.dvs = DVS128Demo('com5', 6000000);
            else
                obj.dvs = DVS128('com5', 6000000);
            end
        end
        
        function connectDVS(obj)
           obj.dvs.Connect();
        end
        
        function Run(obj)
            while obj.isRunning
                %check for new events
                %TODO: solve it event based
                if obj.dvs.EventsAvailable()
                    eventData =  obj.dvs.GetEvents();
                    %put them in filter & position calculation
                    %put them to gui
                    obj.view.update(eventData);
                    %regler
                    
                    %motor movement
                    
                end %if obj.dvs.EventsAvailable()
                pause(0.02)
            end %while
        end %Run()
            
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
        
    end %methods 
    
end

