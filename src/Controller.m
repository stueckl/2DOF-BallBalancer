classdef Controller < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model %contains buisness logic
        dvs % sensor
        view % graphical user Interface (run in other thread slow 30-60fps)
        servos
        dat %TODO: remove Test
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
            
            %TODO remove this part (bad testing)
            tic; 
            obj.dat = [];
            obj.dvs.GetEvents();
            while (toc<5.0)                        % run for 5 sec
                if obj.dvs.EventsAvailable()
                    obj.dat =  [obj.dat; {obj.dvs.GetEvents()}];
                end %if obj.dvs.EventsAvailable()
            end %while
            disp(obj.dat)
            
            %TODO: start view (if useful)
            
            %TODO: clean up
        end
        
    end %methods 
    
end

