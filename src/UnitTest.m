function UnitTest() 
% erzeuge das FuncHandle fuer die Funkion mit dem folgenden Namen (als String) und gebe diese als Rueckgabewerte der Funktion wieder zurueck. 
Test1 = UnitTestDVSDemo();
disp(['UnitTestDVSDemo()' Test1])
end 

function b = UnitTestDVSDemo() 
%ARANGE
            %start services (Model gets only data from services)
            obj.dvs = DVS128Demo('com5', 6000000);
            obj.servos = Servos();
            obj.model = Model(obj);
            %start business logic
            %start DVS (in Model)
            obj.dvs.Connect();
            
%ACT         
            obj.filter = Filter(100);
            tic
            while toc<5.0
                %check for new events
                %TODO: solve it event based
                if obj.dvs.EventsAvailable()
                    eventData =  obj.dvs.GetEvents()
                    eventFiltered = obj.filter.SingleEvents(eventData);
                    %put them in filter & position calculation
                    %put them to gui
                    
                    %regler
                    
                    %motor movement
                    
                end %if obj.dvs.EventsAvailable()
            end %while
            
%ALERT
            b = 1;
end 
