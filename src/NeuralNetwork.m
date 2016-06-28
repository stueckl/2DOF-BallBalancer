classdef NeuralNetwork
    %NEURALN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        network
        var
        numHidden
        numOut
        numIn
        %...
    end %properties
    
    methods
        
        function obj = NeuralNetwork(nIn, nOut, nHidd)
            obj.numIn = nIn;
            obj.numOut = nOut;
            obj.numHidden = nHidd;
            
        end %constructor
        
        % pretrain network if needed
        function pretrain(inputs, targets, iterations)
            
        end %pretrain
        
        % calculates network
        function out = calculate(obj, inputs)
            
        end %end train
        
        function train(obj, inputs, targets)
             
        end %end train
        
    end %methods
    
end

