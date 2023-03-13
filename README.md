Simulate a Simulink<sup>&reg;</sup> model from Python<sup>&reg;</sup> code

This example illustrates two ways to simulate a Simulink model via a wrapper MATLAB<sup>&reg;</sup> function from Python. 
 
The first approach uses the MATLAB Engine API for Python to call the wrapper function multiple times passing in different parameters and external input signals. 
 
The second approach uses MATLAB Compiler SDK<sup>&trade;</sup> and Simulink Compiler<sup>&trade;</sup> to first build a Python package around the wrapper function. We can then call this package to run the warpper function multiple times passing in different parameters and external input signals.  

This example includes the following files:

* the_model.slx: the Simulink model we will simulate in the example;
* sim_the_model.m: the wrapper MATLAB function to simulate a Simulink model with the specified parameter and input signal values;
* call_sim_the_model.m: MATLAB script used to call the sim_them_model multiple times in MATLAB with different inputs and parameters; 
* plot_results.m: MATLAB script used by call_sim_the_model to plot the results;
* call_sim_the_model_using_matlab_runtime.py: Python script to call sim_the_model packaged function multiple times and plot the results;
* call_sim_the_model_using_matlab_engine.py: Python script that uses MATLAB Engine API to call sim_the_model.m multiple time and plot the results;
* CallingSimFromPython.pptx: complementary presentation slides describing the demo structure and setup

The model the_model.slx and the wrapper MATLAB function sim_the_model.m illustrate implementation choices that make data marshaling between Python and sim command in MATLAB relatively straight forward and can be used with any Simulink model. These are:

* Parameterizing the Simulink model using workspace variables makes it easy run sim with new parameter values passed in from Python.
* Labeling the logged signals in the model with valid identifiers, makes it easy to pack the results into a MATLAB struct and return to Python.
* Extracting the time and data values as numeric vectors from sim command output and returning these to Python makes data marshaling relatively easy. 



This example has been tested with MATLAB R2022b and Python 3.8. The following MathWorks products are needed for using this example:

* MATLAB; 
* Simulink; 
* MATLAB Compiler<sup>&trade;</sup>; 
* MATLAB Compiler SDK; 
* Simulink Compiler; 
 



