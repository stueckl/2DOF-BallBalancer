classdef BallBalancerView < handle
    %BallbalancerView Summary of this class goes here
    %   Detailed explanation goes here
    
    %TODO ELIMINATE BUGS :)
    
    properties
        controllerHandle
        fig
        axes
        plt
        leftConEl
        southConEl
    end
    
    methods
        
        %updates the plot with new event data
        function update(obj, events)
            obj.plt.XData = events(:,1);
            obj.plt.YData = events(:,2);
            col = zeros(size(events,1), 3);
            col(:,1) = events(:,3);
            obj.plt.CData = col;
        end %Update()
        
        function obj = BallBalancerView(con)
            
            obj.controllerHandle = con;
            
            obj.fig = figure('Position',[250 250 700 700],...
            'MenuBar','none',...
            'NumberTitle','off',...
            'Name','Simplematlabgui');
            set(obj.fig,'CloseRequestFcn',@(src,event) onclose(obj,src,event))
            set( gcf, 'toolbar', 'figure' )
            
            obj.axes = axes('Parent',obj.fig,'Units','norm','Position',[.05,.25,.7,0.7]);
            axes(obj.axes);
            obj.plt = scatter([0,1],[0,1], 7, [1,0,0]);
            axis([0,120,0,120]);
            
            obj.leftConEl = uiflowcontainer(obj.fig,'Units','norm','Position',[.8,.65,.15,0.3])
            obj.southConEl = uiflowcontainer(obj.fig,'Units','norm','Position',[.05,.05,.7,0.05])
            
            %check if demo dvs is used
            demoBox = uicontrol(obj.leftConEl,...
                'style','checkbox',...
                'units','pixel', ... 
                'position',[20 20 150 300],'String',{'Use Demo Data'},...
                'Callback',@(handle,event) use_demo(obj,handle,event),...
                'Value', obj.controllerHandle.useDemoBool);
           
            %location where demo file is located
            demoLocBox = uicontrol(obj.southConEl,...
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
        
        function use_demo(obj, src, event)
            if (get(src,'Value') == get(src,'Max'))
                obj.controllerHandle.useDemo(1);
            else
                obj.controllerHandle.useDemo(0);
            end
        end
        
        function onclose(obj,src,event)
            obj.controllerHandle.stopLoop();
            delete(src)
            delete(obj)
        end
        
        function selectFile(obj,src,event)
           [filename, pathname] = uigetfile;
           obj.controllerHandle.setDemoFileName(pathname, filename);
        end
            
        
    end %methods 
    
end