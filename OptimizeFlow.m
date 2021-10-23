function [optimWaterData, optimVar, obf, simResult] = OptimizeFlow(waterData, surfactantData, optimData, options)
% OptimizeFlow  Determines the value of Siw, nw and no that yields the
% desired Sw_OB and secondary velocity. It also satisfies the constraint that the resulting
% [nw, no] from the water flooding is closest to [nw, no] from surfactant flooding. 
%
%   [optimWaterData, optimVar, obf, simResult] = OptimizeFlow(waterData, surfactantData, optimData, options)
%   waterData - a structure data type that represents input paratemer for water flooding
%   optimData - a structure data type that stores the optimization constraints.
%   surfactantData - a structure data type that represents input paratemer for surfactant flooding
%   options - optional settings for the optimization algorithm
%
%   OptimizeFlow returns 4 outputs:
%   optimWaterData - is a copy of water data updated with the optimum Siw,
%   nw and no
%   optimVar - is the optimum design variables - Siw, nw and no
%   obf - is the value of the objective function at the optimum design
%   variable
%   simResult - is the result of SimulateFlow at the optimum design
%   variable


if nargin < 4
   options = struct('Display','iter'); 
end
Sw = linspace(0,1,4000);

surfResult = ComputeAllProperty(Sw,surfactantData);  % Compute the flow property of surfactant flooding
optimSw = optimData.Sw;    % Desired Sw_OB
optimNw = optimData.nw;    % nw constraint
optimNo = optimData.no;    % no constraint
optimSiw = optimData.Siw;  % Siw constraint

optimFw = surfResult.maxTangent*optimSw - surfResult.maxTangent*surfResult.Di;   % fw at the desired Sw_OB
optimVar0 = randomStartPoint(optimData, 1);       % Initialize the design variable to be optimized
fun = @(X)objectiveFcn(X, Sw, waterData, optimData, surfactantData);   % define an anonymous function for use by the optimization algorithm
bounds = [optimSiw;optimNw;optimNo];       % set the boundaries of the design variables
lb = bounds(:,1);
ub = bounds(:,2);
nonlcon = @(X)constraintFcn(X, Sw, waterData, optimData, surfactantData);   % define the constraint function

[optimVar,obf] = fmincon(fun,optimVar0,[],[],[],[],lb,ub,nonlcon, options);   % optimize the design variables
%[optimVar,obf] = ga(fun,3,[],[],[],[],lb,ub,nonlcon);
optimWaterData = waterData;
optimWaterData.Siw = optimVar(1);
optimWaterData.nw = optimVar(2);
optimWaterData.no = optimVar(3);
optimWaterData.Di = optimVar(1);

simResult =  SimulateFlow(Sw, optimWaterData, surfactantData, 0.2);

PlotFlow(simResult)
disp(['Optimum Siw: ',num2str(optimVar(1))])
disp(['Optimum nw: ',num2str(optimVar(2))])
disp(['Optimum no: ',num2str(optimVar(3))])
disp(['Min Point: ', num2str(obf)])

function X = randomStartPoint(optimData, ct)
optimNw = optimData.nw;
optimNo = optimData.no;
optimSiw = optimData.Siw;
X = zeros(3,1);
X(1,:) = 0.2;
X(2,:) = 0.1*(optimNw(2)-optimNw(1))*rand(1,ct) + optimNw(1);
X(3,:) = 0.1*(optimNo(2)-optimNo(1))*rand(1,ct) + optimNo(1);


function [c, ceq] = constraintFcn(X, Sw, waterData, optimData, surfactantData)
Siw = X(1);
nw = X(2);
no = X(3);
optimSw = optimData.Sw;
data = waterData;
data.Siw = Siw;
data.nw = nw;
data.no = no;
data.Di = Siw;
%surfactantData.Siw = Siw;
allResult = SimulateFlow(Sw, data, surfactantData, 0.2);
surfResult = allResult.surfactant;
optimFw = surfResult.tangentFun(optimSw);
tempP = ComputeFlowProperty(optimSw, data);
fw = tempP.fw;
c = [];
ceq = [];
if optimData.includeSwob
    ceq = [ceq; fw-optimFw];
end
if optimData.includeArea
    ceq = [ceq;allResult.secArea - optimData.secArea];
end
if optimData.includeVelocity
    ceq = [ceq; allResult.secVob - optimData.Vob];
end

