function NPV  = NPV(x, varargin)
    global NFE
    if isempty(NFE)
        NFE=0;
    end
    
    NFE=NFE+1;
    nx = 25; ny = 25;
    if(~isempty(varargin))
        SD = varargin{1};
        nx = numel(SD(:,1));
        ny = numel(SD(1,:));
    end
    
% %     Objective function should be prepared to receive a set of points
% %     
% %     From Optimization Algorithm we get x
% %     x is between 0 and 1
    nwi = numel(x)/2;   % Injection well number
    if(nwi>1)
        for i=1:nwi
            if(mod(i,2) ~= 0)
                x(i:2:end) = min(floor(1+(nx).*x(i:2:end)), nx);
            else
                x(i:2:end) = min(floor(1+(ny).*x(i:2:end)), ny);
            end
        end
    else
        x(1) = min(floor(1+(nx)*x(1)), nx);
        x(2) = min(floor(1+(nx)*x(2)), ny);
    end
    
%     Selecting a row from Search Domain
    k = SD(x(1), :);
    
    for i=1:nwi
        ECLDATA.CompLoc(i,1:2) = k(2*i-1:2*i);
        ECLDATA.WHLoc(i,:) = k(2*i-1:2*i);
    end

    ECLDATA.CompLoc(:, 3:4) = 1;   %Completeion layers
    %... here we have a pattern , and the center of pattern is goal point
    %.. this point cannot be at corner 
    % 
    %k(1,1)=min(floor(1+(M).*x(1)),(M));
    %k(1,2)=min(floor(1+(M).*x(2)),(M));

    ECLDATA=Eclipse(ECLDATA);

    Qopcum=ECLDATA.Qop;    % This is FGPT
    Qwpcum=ECLDATA.Qwp;    % This FWPT
    Qwicum=ECLDATA.Qwi;   % This is cumulative  FWIT
    Qopcum=Qopcum';
    Qwpcum=Qwpcum';
    Qwicum=Qwicum';

    Qop=Qopcum;Qwp=Qwpcum; Qwi=Qwicum;
    %now we want to obtain rate from cumulative prod
    for i=2:numel(Qopcum)
        Qop(i)=Qop(i)-Qopcum(i-1);
        Qwp(i)=Qwp(i)-Qwpcum(i-1);
        Qwi(i)=Qwi(i)-Qwicum(i-1);                 % Water injected STB at every time step
    end

    t=ECLDATA.Time;
    t=(t');


    % Simplified form of NPV
    Nwell=numel(x)/2; % number of wells (6production wells)
    % Economic Parameters :
    Cwtop=5e7 ;          % Cost to drill main bore to the top of reservoir ($)
    % Cjunc=1.5e6;        % Junction cost of lateral ($)
    Cdrill=1000;         % Drilling Cost ($/ft)
    Po=80;                % Oil price ($/STB)
    Pg=240*0.3048^3;      % gas price ($/MScf)
    Pwi=8;               % Water injected cost ($/STB)
    Pwp=10;               % Water Produced cost ($/STB)
    r=0.1;                % Discount Rate
    Lwmain=8917;            % Length of the main bore (m)/0.3048=ft 

    % Capital Expenditure (total cost of Drill& Complete well) ($)
    Ccapex=Nwell*(Cwtop +(Lwmain).*Cdrill);

    Qgp=0;
    Rt=Po.*Qop+Pg.*Qgp;    % Renevue  at time t
    Et=Pwp.*Qwp+Pwi.*Qwi;
    CFt=Rt-Et;               % Cash Flow at time t

    %%This is Net Present Value: (Revenue - Cost)/discount - capex
    NPV=(sum(CFt./(1+r).^t)-Ccapex);

return

