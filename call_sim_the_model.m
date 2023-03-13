%% Simulate the_model in deployed mode multiple times and plot the results

% By Murali Yeddanapudi on 04-Mar-2022

%% 1st sim: with default parameter values
res{1} = sim_the_model();

%% 2nd sim: with dx2min and dx2max parameter values
stopTime = nan; % Use deafult value
tunablePrms.dx2min = -3; % Specify new value for dx2min
tunablePrms.dx2max =  4; % Specify new value for dx2max
res{end+1} = sim_the_model('StopTime', stopTime, ...
                           'TunableParameters',tunablePrms);

%% 3rd sim: simulate with a non-zero iinput signal
stopTime = nan; % Use deafult value
tunablePrms = []; % Use default values
% Note that, in the model the input u is sampled at a fixed time interval uST (=1)
% So the time axis for the input values is implicit at 1s (=uST) interval
u = [0 2 zeros(1,3) -2*ones(1,2) 0];
% => u(t) = 2 for t in [1,2), -2 for t in [6,8), 0 otherwise
res{end+1} = sim_the_model(StopTime=stopTime, ...
                           ExternalInput=u);

%% 4th sim: with dx2min, dx2max and non-zero input signal
tunablePrms.dx2min = -3; % Specify new value for dx2min
tunablePrms.dx2max =  4; % Specify new value for dx2max
u = [0 2 zeros(1,3) -2*ones(1,2) 0];
res{end+1} = sim_the_model(TunableParameters=tunablePrms, ...
                           ExternalInput=u);

%% Plot some results from the simulations
plot_results(res, 'Results from calling sim_the_model in MATLAB');

