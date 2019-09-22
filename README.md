# First Order Fast Marching Method
Instructions to use the Fast Marching Method

Title: New Efficient Method for Injection Well Location Optimization using Fast Marching Method

Paper Authors: Reza Yusefzadeh, Mohammad Sharifi, Yousef Rafiei

Email: reza_yusef@yahoo.com

Files included:

1- Main.m: Main file to be run. Time of Flight of the production wells located at the corners is calculated in the Fast Marching Method section. Then the drainage boundary is calculated and stored in DMB matrix. PSO parameters are set in the PSO Parameteres section and the particles are initiated. Then, the algorithm continues in the Main Loop section.
2- FMM.m: The function which gets the permeability distribution of the model and calculates the velocity function (Line 33) and passes the velocity function and well location to msfm.m function which calculates the diffusive time of flight based of the model's dimension.
3- FDK.m: Maps Time of Flight to the FDKK.m to calculate the drainage boundary matrix (DBM)
4- FDKK.m: This function estimates the drainage boundary.
5- functions and shortpaths folders: A connection between C programming language and MATLAB is made using files provided in these folders. This is done to accelerate the computations
6- NPV.m: This function gets the injection well location and passes it to Eclipse.m function and then gets the result to calculate the NPV value.
7- Eclipse.m: This function gets the well location and writes it to "sched.dat" file and then calls Eclipse software (Line 47). In the end, this function reads the required parameters from ".RSM" file and returns them to NPV.m function to calculate the Net Present Value.

Note: Number of wells is determined based on the entries as the well locations in the variable x.


Output files:
This output file is provided to check the calculated drianage boundary of the synthetic homogeneous case using FMM
1- "Homogeneous Drainage Boundary of the Producers.fig"

Software Requirements:
		Octave 4.4.1 or MATLAB R2013a or higher versions to run these files.
