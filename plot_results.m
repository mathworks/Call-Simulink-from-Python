function figHndl = plot_results(res, plotTitle)
%PLOT_RESULTS Plot results from call_sim_the_model

% By Murali Yeddanapudi, 19-Sep-2022

figHndl = figure; hold on; cols = colororder;

plot(res{1}.x1.Time, res{1}.x1.Data, 'Color', cols(1,:), ...
    'DisplayName', 'x1 from 1st sim with default setting');
plot(res{2}.x1.Time, res{2}.x1.Data, 'Color', cols(2,:), ...
    'DisplayName', 'x1 from 2nd sim with limits on dx2');
plot(res{3}.x1.Time, res{3}.x1.Data, 'Color', cols(3,:), ...
    'DisplayName', 'x1 from 3rd sim with input u');
plot(res{4}.x1.Time, res{4}.x1.Data, 'Color', cols(4,:), ...
    'DisplayName', 'x1 from 4th sim with limits on dx2 and input u');
stairs(res{3}.u.Time, res{3}.u.Data, 'Color', cols(5,:), ...
    'DisplayName','input u in 3rd and 4th sims');

hold off; grid; ylim([-4 3]);
title(plotTitle,'Interpreter','none');
set(get(gca,'Children'),'LineWidth',2);
legend('Location','southeast');

end

% To call this MATLAB function from Python make sure to install the correct version of Python
% https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html?s_tid=srchtitle_Configure%20Your%20System%20to%20Use%20Python_1
% https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/python-compatibility.pdf
