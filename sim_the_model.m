function res = sim_the_model(args)
% Utility function to simulate a Simulink model (named 'the_model') with
% the specified parameter and input signal values.
% 
% Inputs:
%    StopTime:
%       Simulation stop time, default is nan
%    TunableParameters
%       A struct where the fields are the tunanle referenced
%       workspace variables with the values to use for the
%       simulation.
%    ExternalInput:
%       External Input signal, defualt is empty 
%    ConfigureForDeployment:
%       Sepcify if the simulation input should be configured
%       for deployment, default is true
%
%    Values of nan or empty for the above inputs indicate that sim should
%    run with the default values set in the model.
% 
% Outputs:
%    res: A structure with the time and data values of the logged signals.

% By: Murali Yeddanapudi, 20-Feb-2022

arguments
    args.StopTime (1,1) double = nan
    args.TunableParameters = []
    args.ExternalInput (1,:) {mustBeNumericOrLogical} = []
    args.ConfigureForDeployment (1,1) {mustBeNumericOrLogical} = true
    args.InputFcn (1,1) {mustBeFunctionHandle} = @emptyFunction
    args.OutputFcn (1,1)  {mustBeFunctionHandle} = @emptyFunction
    args.OutputFcnDecimation (1,1) {mustBeInteger, mustBePositive} = 1
end

    %% Create the SimulationInput object
    % Note that the name of the model is hard-coded to 'the_model'
    si = Simulink.SimulationInput('the_model');
    
    %% Load the StopTime into the SimulationInput object
    if ~isnan(args.StopTime)
        si = si.setModelParameter('StopTime', num2str(args.StopTime));
    end
    
    %% Load the specified tunable parameters into the simulation input object
    if isstruct(args.TunableParameters) 
        tpNames = fieldnames(args.TunableParameters);
        for itp = 1:numel(tpNames)
            tpn = tpNames{itp};
            tpv = args.TunableParameters.(tpn);
            si = si.setVariable(tpn, tpv);
        end
    end
    
    %% Load the external input into the SimulationInput object
    if ~isempty(args.ExternalInput)
        % In the model, the external input u is a discrete signal with sample
        % time 'uST'. Hence the time points where it is sampled are set, i.e.,
        % they are multiples of uST: 0, uST, 2*uST, 3*uST, .. We only specify
        % the data values here using the struct with empty time field as
        % described in Guy's blog post:
        % https://blogs.mathworks.com/simulink/2012/02/09/using-discrete-data-as-an-input-to-your-simulink-model/
        uStruct.time = [];
        uStruct.signals.dimensions = 1;
        % values needs to be column vector
        uStruct.signals.values = reshape(args.ExternalInput,numel(args.ExternalInput),1);
        si.ExternalInput = uStruct;
    end
    
    %% Configure for deployment
    if args.ConfigureForDeployment
        si = simulink.compiler.configureForDeployment(si);
    elseif ismcc || isdeployed
        error("Simulation needs to be configured for deployment");
    end
    
    %% InputFcn
    if ~isequal(args.InputFcn, @emptyFunction)
        si = simulink.compiler.setExternalInputsFcn(si, args.InputFcn);
    end

    %% OutputFcn
    prevSimTime = nan;
    function locPostStepFcn(simTime)
        so = simulink.compiler.getSimulationOutput('the_model');
        res = extractResults(so, prevSimTime);
        stopRequested = feval(args.OutputFcn, simTime, res);
        if stopRequested
            simulink.compiler.stopSimulation('the_model');
        end
        prevSimTime = simTime;
    end
    if ~isequal(args.OutputFcn, @emptyFunction)
        si = simulink.compiler.setPostStepFcn(si, @locPostStepFcn, ...
            'Decimation', args.OutputFcnDecimation);
    end
    
    %% call sim
    so = sim(si);
    
    %% Extract the simulation results
    % Package the time and data values of the logged signals into a structure
    res = extractResults(so,nan);

end % sim_the_model_using_matlab_runtime

function res = extractResults(so, prevSimTime)
    % Package the time and data values of the logged signals into a structure
    ts = simulink.compiler.internal.extractTimeseriesFromDataset(so.logsout);
    for its=1:numel(ts)
        if isfinite(prevSimTime)
            idx = find(ts{its}.Time > prevSimTime);
            res.(ts{its}.Name).Time = ts{its}.Time(idx);
            res.(ts{its}.Name).Data = ts{its}.Data(idx);
        else
            res.(ts{its}.Name).Time = ts{its}.Time;
            res.(ts{its}.Name).Data = ts{its}.Data;
        end
    end
end

function mustBeFunctionHandle(fh)
    if ~isa(fh,'function_handle') && ~ischar(fh) && ~isstring(fh)
        throwAsCaller(error("Must be a function handle"));
    end
end

function emptyFunction
end
