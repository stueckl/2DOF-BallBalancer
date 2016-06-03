classdef BallBalancerView < handle
    %BallbalancerView Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        controllerHandle
        fig
        axes
        plt
        plt2
        leftConEl
        southConEl
        demoLocBox
    end
    
    methods
        
        %updates the plot with new event data
        function update(obj, events, pos, vel)
            obj.plt.XData = events(:,1);
            obj.plt.YData = events(:,2);
            col = zeros(size(events,1), 3);
            col(:,1) = events(:,3);
            obj.plt.CData = col;
            
            obj.plt2.XData =pos(1);
            obj.plt2.YData =pos(2);
            obj.plt2.UData =vel(1);
            obj.plt2.VData =vel(2);
            %To display calculated position (slow!!!)
%             scattersize = ones(size(events,1), 1);
%             scattersize(end) = 50;
%             obj.plt.SizeData = scattersize;
        end %Update()
        
        function obj = BallBalancerView(con)
            
            obj.controllerHandle = con;
            
            obj.fig = figure();
            set(obj.fig,'CloseRequestFcn',@(src,event) onclose(obj,src,event))
            set( gcf, 'toolbar', 'figure' )
            
            obj.axes = axes('Parent',obj.fig,'Units','norm','Position',[.05,.25,.7,0.7]);
            axes(obj.axes);
            obj.plt = scatter([0,1],[0,1], 7, [1,0,0]);
            hold on;
            obj.plt2 = quiver(0, 0, 1, 1);
            axis([0,120,0,120]);
            
            obj.leftConEl = uiflowcontainer(obj.fig,'Units','norm','Position',[.8,.65,.15,0.3])
            obj.southConEl = uiflowcontainer(obj.fig,'Units','norm','Position',[.05,.05,.9,0.07])
            
            %check if demo dvs is used
            demoBox = uicontrol(obj.leftConEl,...
                'style','checkbox',...
                'units','pixel', ... 
                'position',[20 20 150 300],'String',{'Use Demo Data'},...
                'Callback',@(handle,event) use_demo(obj,handle,event),...
                'Value', obj.controllerHandle.useDemoBool);
           
            %location where demo file is located
            obj.demoLocBox = uicontrol(obj.southConEl,...
                'style','edit',...
                'String','...',...
                'Position',[115 50 50 20],...
                'Tag','demoFile');
            
            %select demo file
            demoLocSel = uicontrol(obj.southConEl,...
                'String','Select...',...
                'Position',[115 50 50 20],...
                'Callback',@(handle,event) selectFile(obj,handle,event),...
                'Tag','startLoop');
           
            %button connect DVS
            connectDVS = uicontrol(obj.leftConEl,...
                'String','Connect DVS',...
                'Position',[115 50 50 20],...
                'Callback',@(handle,event) connectDVS(obj,handle,event),...
                'Tag','startLoop');
            
            %button start Main Loop
            startLoopBut = uicontrol(obj.leftConEl,...
                'String','Start Loop',...
                'Position',[115 50 50 20],...
                'Callback',@(handle,event) startLoop(obj,handle,event),...
                'Tag','startLoop');
            
            %button stop Main Loop        
            stopLoopBut = uicontrol(obj.leftConEl,...
               'String','Stop Loop',...
               'Position',[115 50 50 20],...
               'Callback',@(handle,event) stopLoop(obj,handle,event),...
               'Tag','startLoop');
           
            %button stop Main Loop        
            startBorderCap = uicontrol(obj.leftConEl,...
                'String','Capture Border',...
               'Position',[115 50 50 20],...
               'Callback',@(handle,event) captureBorder(obj,handle,event),...
               'Tag','startLoop');
           
        end
        
        function connectDVS(obj,handle,event)
            obj.controllerHandle.initDVS();
            obj.controllerHandle.connectDVS();
        end
        
        function startLoop(obj, src, event)
            obj.controllerHandle.startLoop();
        end
        
        function stopLoop(obj, src, event)
            obj.controllerHandle.stopLoop();
        end
        
        function captureBorder(obj,handle,event)
            instrfind
            obj.controllerHandle.recordBorder(); 
        end
        
        function use_demo(obj, src, event)
            if (get(src,'Value') == get(src,'Max'))
                obj.controllerHandle.useDemo(1);
            else
                obj.controllerHandle.useDemo(0);
            end
        end
        
        function onclose(obj,src,event)
            obj.controllerHandle.Destructor();
            delete(src);
            delete(obj);
        end
        
        function selectFile(obj,src,event)
           [filename, pathname] = uigetfile;
           obj.controllerHandle.setDemoFileName(pathname, filename);
           %TODO set textbox
        end
            
        
    end %methods 
    
end