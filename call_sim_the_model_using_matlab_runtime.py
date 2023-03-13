# -*- coding: utf-8 -*-
"""
Example showing how call a python package to simulate a Simulink
model (called the_model) with different tunable parameter and
external input signal values.

To run this script, you need the following prerequisites:
    1. Install the MATLAB Runtime (R2021b or later) 
       https://www.mathworks.com/products/compiler/matlab-runtime.html

    2. Install "sim_the_model" python package. See instructions below.
    
Notes:
1. Run build_python_package_around_sim_the_model.m script in MATLAB
   (R2021b or later) to create sim_the_model_python_package. This
   script requires the following products:
    - MATLAB
    - Simulink
    - MATLAB Compiler
    - Simulink Compiler
    - MATLAB Compiler SDK

   After your run the script, follow the instructions displayed on the
   MATLAB command window to install the sim_the_model_python_package

2. sim_the_model_python_package is a wrapper to run sim_the_model.m
   MATLAB function using deployed version of the Simulink model
   (the_model) and the MATLAB Runtime

3. Both MATLAB Runtime, and sim_the_model_python_package (once it is
   built) can be distributed freely and do not require licenses.

By: Murali Yeddanapudi on 01-Mar-2022
"""

import matlab
import numpy as np

# Specify the path to sim_the_model_python_package. Note that build_python_package_around_sim_the_model.m
# script installs the python package in this location. If you change it, then you need to update the
# code here, or remove it altogether if you install sim_the_model package in a location on the python
# search path.
import sys
sys.path.append(".\\sim_the_model_python_package\\Lib\\site-packages")
import sim_the_model

# initialize sim_the_model package
mlr = sim_the_model.initialize()

# Allocate res list to hold the results from 4 calls to sim_the_model
res = [0]*4;

## 1st sim: with default parameter values
res[0] = mlr.sim_the_model()

## 2nd sim: with new values for dx2min and dx2max parameters
tunableParams = {
    'dx2min': -3.0, # Specify a new value for dx2min
    'dx2max':  4.0  # Specify a new value for dx2max
    }
res[1] = mlr.sim_the_model('TunableParameters',tunableParams)

## 3rd sim: with a non zero input signal
# Note that, in the model the input u is sampled at a fixed time interval
# uST (=1) which cannot be changed since the model is compiled for deployment.
# So the time axis for the input values is implicit at 1s (=uST) interval
# u = [0 2 zeros(1,3) -2*ones(1,2) 0];
u = np.concatenate([np.zeros(1), 2*np.ones(1), np.zeros(3), -2*np.ones(2), np.zeros(1)])
# => u(t) = 2 for t in [1,2), -2 for t in [6,8), 0 otherwise
externalInput = matlab.double(u.tolist()) # convert numpy array into matlab array
res[2] = mlr.sim_the_model('ExternalInput',externalInput)

## 4th sim: with dx2min, dx2max and non-zero input signal
tunableParams = {
    'dx2min': -3.0, # Specify a new value for dx2min
    'dx2max':  4.0  # Specify a new value for dx2max
    }
u = np.concatenate([np.zeros(1), 2*np.ones(1), np.zeros(3), -2*np.ones(2), np.zeros(1)])
externalInput = matlab.double(u.tolist()) # convert numpy array into matlab array
res[3] = mlr.sim_the_model('TunableParameters',tunableParams,'ExternalInput',externalInput)

## Plot the results
# TODO: Replace this code using plotly
import matplotlib.pyplot as plt
cols = plt.rcParams['axes.prop_cycle'].by_key()['color']
fig, ax = plt.subplots(1,1,sharex=True)
ax.plot(res[0]['x1']['Time'], res[0]['x1']['Data'], color=cols[0], label="x1 from 1st sim with default setting")
ax.plot(res[1]['x1']['Time'], res[1]['x1']['Data'], color=cols[1], label="x1 from 2nd sim with limits on dx2")
ax.plot(res[2]['x1']['Time'], res[2]['x1']['Data'], color=cols[2], label="x1 from 3rd sim with input u")
ax.plot(res[3]['x1']['Time'], res[3]['x1']['Data'], color=cols[3], label="x1 from 4th sim with limits on dx2 and input u")
ax.step(res[3]['u']['Time'], res[3]['u']['Data'], where='post', color=cols[4], label="input u in 3rd and 4th sims")
ax.grid(); ax.set_ylim([-4, 3])
lg = ax.legend(fontsize='x-small'); lg.set_draggable(True)
ax.set_title("Results from sim_the_model using MATLAB Runtime")
plt.show()

mlr.terminate() # stop the MATLAB Runtime
