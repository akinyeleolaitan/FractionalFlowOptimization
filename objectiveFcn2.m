function ret = objectiveFcn2(X, Sw, waterData, optimData, surfactantData)
% This is similar to objectiveFcn. It deters in two aspects - the euclidean
% distance is not add and the value from the velocity term is clipped to
% not exceed 3.
% This function is designed for exploring the search space of the objective
% function.

Siw = X(1);
nw = X(2);
no = X(3);
optimSw = optimData.Sw;
data = waterData;
data.Siw = Siw;
data.nw = nw;
data.no = no;
data.Di = Siw;

allResult = SimulateFlow(Sw, data, surfactantData, optimData.t);
surfResult = allResult.surfactant;
optimFw = surfResult.tangentFun(optimSw);
tempP = ComputeFlowProperty(optimSw, data);
fw = tempP.fw;
ret = (fw-optimFw).^2;

if optimData.includeVelocity
    ret = ret + min([2, (optimData.Vob - allResult.secVob).^2]);   % Add the squared difference between resulting secondary velocity and desired velocity
end
if optimData.includeArea
    ret = ret + (allResult.secArea - optimData.secArea).^2
end
