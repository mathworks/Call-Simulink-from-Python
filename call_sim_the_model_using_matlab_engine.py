# -*- coding: utf-8 -*-
"""
Example showing how to simulate a Simulink model (called the_model) with different
parameter and external input signal values using the MATLAB Engine API for Python.

The example requires:
    1. MATLAB and Simulink products installed and licensed
    2. MATLAB Engine API installed as a Python package
       https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html

@author: Murali Yeddanapudi
Created on Tue Mar  1 2022
"""
# Install numpy (For example, pip install numpy)
import numpy as np
import matlab.engine

mle = matlab.engine.start_matlab(); # start the matlab engine

# Since we are using MATLAB Engine we do not have to configureForDeployment.
# This allows more flexibility to simulate the model in normal mode, and change
# non-tunable parameters.
configureForDeployment = 0

# Allocate res list to hold the results from 4 calls to sim_the_model
res = [0]*4;

## 1st sim: with default parameter values
res[0] = mle.sim_the_model()

## 2nd sim: with new values for dx2min and dx2max parameters
tunableParams = {
    'dx2min': -3.0, # Specify a new value for dx2min
    'dx2max':  4.0  # Specify a new value for dx2max
    }
res[1] = mle.sim_the_model('TunableParameters',tunableParams,
                           'ConfigureForDeployment',configureForDeployment)

## 3rd sim: with a non zero input signal
# Note that, in the model the input u is sampled at a fixed time interval
# uST (=1) which cannot be changed since the model is compiled for deployment.
# So the time axis for the input values is implicit at 1s (=uST) interval
# u = [0 2 zeros(1,3) -2*ones(1,2) 0];
u = np.concatenate([np.zeros(1), 2*np.ones(1), np.zeros(3), -2*np.ones(2), np.zeros(1)])
# => u(t) = 2 for t in [1,2), -2 for t in [6,8), 0 otherwise
externalInput = matlab.double(u.tolist()) # convert numpy array into matlab array
res[2] = mle.sim_the_model('ExternalInput',externalInput,
                           'ConfigureForDeployment',configureForDeployment)

## 4th sim: with dx2min, dx2max and non-zero input signal
tunableParams = {
    'dx2min': -3.0, # Specify a new value for dx2min
    'dx2max':  4.0  # Specify a new value for dx2max
    }
u = np.concatenate([np.zeros(1), 2*np.ones(1), np.zeros(3), -2*np.ones(2), np.zeros(1)])
externalInput = matlab.double(u.tolist()) # convert numpy array into matlab array
res[3] = mle.sim_the_model('TunableParameters',tunableParams,
                           'ExternalInput',externalInput,
                           'ConfigureForDeployment',configureForDeployment)

## callback into MATLAB to plot the results
mle.plot_results(res, "Results from sim_the_model using MATLAB Engine")

input("Press enter to close the MATLAB figure and exit ...")
mle.quit() # stop the matlab engine
