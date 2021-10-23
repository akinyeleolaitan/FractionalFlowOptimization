function ret = objectiveFcn(X, Sw, waterData, optimData, surfactantData)
% objectiveFcn  The evaluation or cost function to be minimized by an
% optimization
%   ret = objectiveFcn(X, Sw, waterData, optimData, surfactantData)
%   X - a vection of 3 numbers to be optimized. X = [Siw, nw, no]. It is
%   the design variable.
%   Sw - vector of water saturation ranging from 0 to 1
%   waterData - a structure data type that represents input paratemer for water flooding
%   optimData - a structure data type that stores the optimization constraints. The important field in optimData used here is Sw which is the desired water saturation at the oil bank.
%   surfactantData - a structure data type that represents input paratemer for surfactant flooding
%
%   objectiveFcn returns ret. ret is a scaler value that represents the
%   cost at the given design variable.

Siw = X(1);
nw = X(2);
no = X(3);
optimSw = optimData.Sw;  % Water saturation at the desired oil bank
data = waterData;
data.Siw = Siw;
data.nw = nw;
data.no = no;
data.Di = Siw;

allResult = SimulateFlow(Sw, data, surfactantData, optimData.t);
surfResult = allResult.surfactant;
optimFw = surfResult.tangentFun(optimSw);    % Get fw at the oil bank
tempP = ComputeFlowProperty(optimSw, data);
fw = tempP.fw;
ret = 0;
if optimData.includeSwob
    ret = (fw-optimFw).^2;   % compute the squared difference between resulting fw and desired fw 
end
if optimData.includeVelocity
    ret = ret + (optimData.Vob - allResult.secVob).^2;   % Add the squared difference between resulting secondary velocity and desired velocity
end
if optimData.includeArea
    ret = ret + (allResult.secArea - optimData.secArea).^2;
end
if optimData.includeDistance
    ret = ret + sqrt((nw-surfactantData.nw).^2 + (no-surfactantData.no).^2);   % Add the euclidean distance between the [nw, no] of water flooding and [nw, no] of surfactant
end
