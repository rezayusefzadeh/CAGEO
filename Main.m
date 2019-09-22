profile off;
profile on -timer real
clear;
clc;
close all;
tstart = tic;

%%
% Thi code is written to find the maximum NPV using PSO-FMM with limited
% search domain and Reservoir Simulator

global NFE;
NFE = 0;
nx = 25; ny = 25;
Perm = 20*(ones(nx,ny));


 CostFunction = @(x) NPV(x);         % Cost function definition

 nVar = 2; %input('Enter number of decision variables: \n');   %number of decision varables

 VarSize = [1 nVar];

 VarMin = 0;     % Lower boundary of variables
 VarMax = 1;     % Upper boundary of variables

%% Fast Marching Method TOF
TimeFunction = @(x, Perm) FMM(x, Perm);  % Time of Flight Function

position = [1 1 1 nx ny 1 nx ny];   % prod well position
nwp = size(position,2)/2;           % number of prod wells

% Getting TOF and Drainage boundary matrix (DBM)
[TOF, DBM] = TimeFunction(position, Perm);
TOF = real(TOF);
figure
imagesc(DBM)
axis image

[m, n] = find(DBM==8);
A = [m, n];

for i = 1:size(A,1)
    if(A(i,2) < ny)
        DBM(A(i,1), A(i,2)+1) = 8;
    end
    if(A(i,2) > 1)
        DBM(A(i,1), A(i,2)-1) = 8;
    end
    
    if(A(i,1) < ny)
        DBM(A(i,1)+1, A(i,2)) = 8;
    end
    
    if(A(i,1) > 1)
        DBM(A(i,1)-1, A(i,2)) = 8;
    end
    
end

figure
imagesc(DBM)
axis image

% Finding gridblocks within and around the drainage boundary
[x, y] = find(DBM==8);
PSO_SearchDomain = [y x];       % Because MATLBAD indexing is different form ECLIPSE
DomainLength = length(PSO_SearchDomain);


%% PSO Parameters

MaxIt = 20;     % Maximum number of iterations
nPop = 5;      % Number of perticles

% Constriction Coefficients
phi1 = 2.05;
phi2 = 2.05;
phi = phi1+phi2;
chi = 2/(phi-2+sqrt(phi^2-4*phi));
w = chi;          % Inertia Weight
wdamp = 1;        % Inertia Weight Damping Ratio
c1 = chi*phi1;    % Personal Learning Coefficient
c2 = chi*phi2;    % Global Learning Coefficient

% Velocity limits
VelMax = 0.1*(VarMax-VarMin);
VelMin = -VelMax;

% Initialization of parameters
empty_partcle.Position = [];
empty_particle.Velocity = [];
empty_particle.Cost = [];
empty_particle.Best.Position = [];
empty_particle.Best.Cost = [];
particle = repmat(empty_particle, nPop, 1);

% These for every PSO Iteraion
BestCost = zeros(MaxIt+1, 1);
Location = zeros(MaxIt+1, nVar);
BHP = zeros(MaxIt+1, 1);

nfe = zeros(MaxIt+1, 1);
tElapsed = zeros(MaxIt+1, 1);
NetPresentValue = zeros(MaxIt+1, 1);

globalBest.Cost = -Inf;

% Assigning initial values for each particle
for i = 1:nPop
    
    % Initial Position
    particle(i).Position = rand(VarSize);

    % Initial Cost
    particle(i).Cost = NPV(particle(i).Position, PSO_SearchDomain, nwp);
        
    % Initial Velocity
    particle(i).Velocity = zeros(VarSize);
    
    % Updating Personal Best
    particle(i).Best.Cost = particle(i).Cost;
    particle(i).Best.Position = particle(i).Position;

    % Updating global best
    if(particle(i).Best.Cost > globalBest.Cost)
        globalBest = particle(i).Best;
    end
     % including inital values in the output
    BestCost(1) = globalBest.Cost;
    for ii = 1:nVar/2
         Location(1, 2*ii-1:2*ii) = PSO_SearchDomain(min(floor(1+(DomainLength).*globalBest.Position(2*ii-1)),(DomainLength)), :);
    end
    nfe(1) = NFE;
    tElapsed(1)=toc(tstart);
    NetPresentValue(1) = BestCost(1);
end
figure
plot(nfe(1), BestCost(1), 'g--*', 'LineWidth', 2);
xlabel('NFE');
ylabel('Net Present Value - $');
hold on

%% Main loop
for it = 1:MaxIt
    for i = 1:nPop
        
        % Updating Velocity
        particle(i).Velocity = w.*particle(i).Velocity...
        + c1.*rand(VarSize).*(particle(i).Best.Position-particle(i).Position)...
        + c2.*rand(VarSize).*(globalBest.Position-particle(i).Position);
    
        % Applying velocity limits
        particle(i).Velocity = max(particle(i).Velocity, VelMin);
        particle(i).Velocity = min(particle(i).Velocity, VelMax);
        
        % Updating Position
        particle(i).Position = particle(i).Position + particle(i).Velocity;
        
        % Velocity mirror effect
        IsOutside = (particle(i).Position > VarMax | particle(i).Position < VarMin);
        particle(i).Velocity(IsOutside) = -particle(i).Velocity(IsOutside);
        
        % Applying position limits
        particle(i).Position = max(particle(i).Position, VarMin);
        particle(i).Position = min(particle(i).Position, VarMax);
               
        % Evaluating cost
        particle(i).Cost = NPV(particle(i).Position, PSO_SearchDomain, nwp);
        
        % Updating Personal best
        if(particle(i).Cost > particle(i).Best.Cost)
            particle(i).Best.Cost = particle(i).Cost;
            particle(i).Best.Position = particle(i).Position;
            
            % Update global best
            if(particle(i).Best.Cost > globalBest.Cost)
                globalBest = particle(i).Best;
            end
        end
    end
    BestCost(it+1) = globalBest.Cost;
    for ii = 1:nVar/2
         Location(it+1, 2*ii-1:2*ii) = PSO_SearchDomain(min(floor(1+(DomainLength).*globalBest.Position(2*ii-1)),(DomainLength)), :);
    end
    nfe(it+1) = NFE;
    
    w = w*wdamp;
    tElapsed(it+1) = toc(tstart);
    NetPresentValue(it+1) = BestCost(it+1);
    % Saving results at every iteration
    %save('HomogenousCaseResults.mat', 'particle', 'globalBest', 'nfe', 'BestCost', 'tElapsed', 'Location');

    plot(nfe(it+1), BestCost(it+1), 'g--*', 'LineWidth', 2);
    xlabel('NFE');
    ylabel('Net Present Value - $');
    hold on
    
end

% now we have best position, so we can obtain the global best position's
% x and y coordinates
globalBest.Position = Location(end, :);

%%
% Plots
%

figure
plot(nfe, BestCost, 'g--*', 'LineWidth', 2);
xlabel('NFE');
ylabel('Net Present Value - $');

figure
imagesc(Perm);
axis image
hold on
for i=1:nVar/2
    plot(Location(end,2*i-1),Location(end,2*i),'s','MarkerSize',9,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor','k')
end
profile viewer

