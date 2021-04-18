classdef Circle
    %CIRCLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        absV_ % скорость движения
        radius_ % радиус окружности
        W_ % угловая скорость
    end
    
    methods
        
        function obj = TraceCircle(absV, R)
            if nargin == 1
               R = 20;
            end
            obj.absV_ = absV;
            obj.radius_ = R;
            obj.W_ = absV / R; % соотв. формуле
        end
           
          % --- linear moving
        function pos = location( obj, t )
            pos = obj.radius_ * [ cos(obj.W_ * t)  sin(obj.W_ * t)  t*0 ];
        end
        
        
        % --- [ az el ] rotation
        function ang = orientation( obj, t )
            ang = [ rad2deg(obj.W_ * t) + 90   zeros(size(t)) ]; % почему +90?
        end
    end
end

