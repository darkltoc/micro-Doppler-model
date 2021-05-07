classdef Shine_dot < Target
    %SHINE_DOT Summary of this class goes here
    %   posArr[n][x y z]
    
    properties
        bladeSize_  = 1;
        rotFreq_    = 10;
    end
    
    methods
        function obj = Shine_dot(bladeSize, rotFreq,...
                position, traceType)
            if nargin == 2
                position = [0 0 0];
                traceType = TraceReclinear;
            end
            
            %SHINE_DOT Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@Target( position, traceType );
            
            obj.bladeSize_  = bladeSize;
            obj.rotFreq_    = rotFreq;
        end
        
        function posArr = pointState( obj, t )
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if size( t, 2 )~=1
                warning('lols')
                t = t';
            end
            posArr = zeros(size(t, 1), 2, 3);
            posArr(:, 1, :) = [   cos( 2*pi*obj.rotFreq_*t ) ...
                sin( 2*pi*obj.rotFreq_*t ) ...
                zeros(size(t)) ] * obj.bladeSize_;
            posArr(:, 2, :) = [   cos( 2*pi*obj.rotFreq_*t ) ...
                sin( 2*pi*obj.rotFreq_*t ) ...
                zeros(size(t)) ] * -obj.bladeSize_;
        end
        
        function draw( obj, t, ax )
            % Helium target state drawning
            posArr = squeeze( obj.getPosition( t(1,1) ) );
            
            obj.handlePlot_(end + 1) = plot3(ax, posArr(:,1), ...
                                        posArr(:,2), ...
                                        posArr(:,3), 'ok', ...
                                        'markerfacecolor', 'b', ...
                                        'markersize', 5);   
        end
        
    end
end

