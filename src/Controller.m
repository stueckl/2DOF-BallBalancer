classdef Controller < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isRunning
        model %contains buisness logic
        dvs % sensor
        view % graphical user Interface (run in other thread slow 30-60fps)
        servos
        dat %TODO for test only
    end %events
    
    methods
        %TODO: Get Baudrate and CO from a config file
        %TODO: Automatic scan Serial Ports
        function obj = Controller()
            
            %start services (Model gets only data from services)
            obj.dvs = DVS128('com5', 6000000);
            obj.servos = Servos();
            obj.model = Model(obj);
            %start business logic
            
            %start DVS (in Model)
            obj.dvs.Connect();  
            
            %TODO: start view (if useful)
            
            %run programm
            obj.Run();
        
            %TODO: clean up
        end
        
        function Run(obj)
            while obj.isRunning
                %check for new events
                %TODO: solve it event based
                if obj.dvs.EventsAvailable()
                    eventData =  obj.dvs.GetEvents();
                    %put them in filter & position calculation
                    %put them to gui
                    
                    %regler
                    
                    %motor movement
                    
                end %if obj.dvs.EventsAvailable()
            end %while
        end %Run()
            
        
    end %methods 
    
end

