clear
clc
close all;

t1 = TargetHelium(1, 5, [1 1 1], TraceReclinear([1 0 1], [10 0]));

for t = 0:1e-3:1
    tic
    t1.drawObj(t);
    toc
    pause(0.01)
    drawnow
end




