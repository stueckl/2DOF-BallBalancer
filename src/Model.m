classdef Model < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        controller
    end %properties
    
    methods
        function obj = Model(con)
            obj.controller = con;
        end %Model
    end %methods
    
end

