clear
clc
close all;
% тестовый объект, лопасти на расстоянии 1 от центра, частота вращения 5,
% начальная позиция - точка [1 1 1], тип трассы - направленная (прямая или
% как ещё назвать трассу с заданным вектором скорости и вектором азимута и
% угла места)
% работоспособно

t1 = Shine_dot(1, 5, [1 0 1], Circle[1 1]); % TraceReclinear([1 0 1], [10 0])

for t = 0:1e-3:1
    tic
    t1.drawObj(t);
    toc
    pause(0.01)
    drawnow
end
