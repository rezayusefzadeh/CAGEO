# First Order Fast Marching Method
Instructions to use the Fast Marching Method by M. S. Hassouna

Title: New Efficient Method for Injection Well Location Optimization using Fast Marching Method

Paper Authors: Reza Yusefzadeh, Mohammad Sharifi, Yousef Rafiei

Email: reza_yusef@yahoo.com

Code developer: M. Sabry Hassouna et Al.

Files included:

1- main.m: Main file to be run. Well locations are specified here. TOF is the diffusive time of fligh
2- FMM.m: It is function loading permeability map at line 39. Specify rock and fluid properties in Reservoir data section. DBM indicates the drainage boundary(line 65).
3- FDK.m: Maps Time of Flight to the FDKK.m to calculate the drainage boundary (DBM)
4- Perm-het-syn.txt: Conatains the heterogenous permeability values included as test data.
5- FDKK.m: This function estimates the drainage boundary.
6- functions and shortpaths folders: A connection between C programming language and Octave or MATLAB is made using files provided in these folders. This is done to accelerate 
   the computations


Note: Number of wells is determined based on the entries as the well locations in the variable x.


Output files:
This output file is provided to check the calculated drianage boundary of the synthetic heterogeneous case using FMM
1- "Heteroegenous synthetic case drainage boundary.fig"

Software Requirements:
		Octave 4.4.1 or MATLAB R2013a or higher versions to run these files.
		Note: we have used Octave but there is no difference if you use MATLAB
