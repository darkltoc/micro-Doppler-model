classdef Linear
    %LINEAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        V_          % [vx vy vz] вектор скорости
        W_          % [Waz  Wel] направление (аз / уг. места?)
    end
    
    methods
          function obj = TraceReclinear(linVelocity, angleVelocity)
            if nargin == 0
               linVelocity   = [0 0 0];
               angleVelocity = [0 0];   % [Az El]
            end
            obj.V_ = linVelocity;
            obj.W_ = angleVelocity;
        end
        
         % --- linear moving
        function pos = location( obj, t )
            pos = t * obj.V_;
        end
        
        
        % --- [ az el ] rotation
        function angle = orientation( obj, t )
            angle = t * obj.W_;
        end
    end
end

