function [TFL, DBM]=FMM(x, Perm)

    tic
    nx=25;ny=25;nz=1;
 
   
    %.... Number of wells
    nwd=numel(x)/2;

    %...Import Source Points 3D
%     for i=1:nwd
%         for j = 1:nz
%             WellLocation(nz*(i-1)+j,:)=[x(2*i-1:2*i) j];
%         end
%     end

    % 2 dimensinal
    WellLocation=zeros(nwd,2);
    for i=1:nwd
        WellLocation(i,:)=x(2*i-1:2*i);
    end


    %... Reservoir Data
    ct=2.5E-6;                      %.... Total Compressibility Value
    mio=2;                     %.... Viscosity
    dx=250;dy=250;                  %.... Block Length

    Poro=0.15.*ones(ny,nx,nz);
    % Perm=5.*ones(nx,ny);

    %... Calculation of Hydraulic Diffusivity Value
    HDV=(1/dx)*sqrt(Perm./(3792.*mio*ct.*Poro));

    %.... Run Kroon Code to find time of flight
    TFL=msfm(HDV, WellLocation', true, false);
    
    DBM = FDK(nwd, TFL);
end
