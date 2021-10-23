function result = SimulateFlow(Sw,waterData, surfactantData, t, tilt)
% SimulateFlow  Computes properties of water and surfactant flooding.
% Determines the water saturation at the shock location and also at the oil
% bank.
if nargin == 4
    tilt = 1;
end
waterResult = ComputeAllProperty(Sw, waterData);      % Computes water flooding property
surfResult = ComputeAllProperty(Sw, surfactantData);   % Computes surfactant flooding property
result.water = waterResult;
result.surfactant = surfResult;

Sw_OB = fzero(@(x)ComputeOilBank(x,waterResult, surfResult), 0.6);   % Determines the water saturation at the oil bank
result.Sw_OB = Sw_OB;
result.Snw_OB = NormWaterSaturation(Sw_OB,waterData);        % Determines the normalized water saturation at oil bank
tempP = ComputeFlowProperty(Sw_OB, waterData);
result.fw_OB = tempP.fw;          % Get the water fractional flow at the oil bank

%% Determining the saturation profile
Sw_spots = [surfResult.Sw_shock, result.Sw_OB, waterResult.Di, waterResult.Sw_shock];
Snw_spots = NormWaterSaturation(Sw_spots, surfResult);
dfds_spots = ComputeDFDS(Snw_spots, surfResult);
dfds_spots(2) = result.fw_OB/(result.Sw_OB - waterData.Siw);
dfds_spots(4) = (waterResult.fw_shock-result.fw_OB)/(waterResult.Sw_shock - result.Sw_OB);
dfds_spots(isnan(dfds_spots)) = 0;

result.Sw_spots = Sw_spots;
result.Snw_spots = Snw_spots;
result.dfds_spots = dfds_spots;

Sw1 = fliplr(Sw(Sw>= Sw_spots(1)));
Sw1 = [Sw1,Sw_spots(1)];
distance1 = t*ComputeDFDS(NormWaterSaturation(Sw1, surfResult), surfResult);
distance2 = t * dfds_spots;

secDistance = [0, distance1, distance1(end),distance2(2)+distance1(end),distance2(2)+distance1(end),1];
secSaturation = [1, Sw1, Sw_spots(2), Sw_spots(2), Sw_spots(3), Sw_spots(3)];
secArea = 0;
for i = 2:length(secDistance);
    secArea = secArea + (secSaturation(i) + secSaturation(i-1))*0.5*(secDistance(i) - secDistance(i-1));
end
if isnan(secArea)
    secArea = 0;
end

result.secDistance = secDistance;
result.secSaturation = secSaturation;
result.secArea = secArea;
result.secVob = dfds_spots(2);  % Velocity of secondary flow
result.terVob = dfds_spots(4);  % Velocity of tertiary flow

terDistance = [0, distance1, distance1(end),distance2(4)+distance1(end),distance2(4)+distance1(end),1];
terSaturation = [1, Sw1, Sw_spots(2), Sw_spots(2), Sw_spots(4), Sw_spots(4)];

terArea = 0;
for i = 2:length(terDistance);
    terArea = terArea + (terSaturation(i) + terSaturation(i-1))*0.5*(terDistance(i) - terDistance(i-1));
end

result.terDistance = terDistance;
result.terSaturation = terSaturation;
result.terArea = terArea;

aboveOB = Sw>Sw_OB;
t_OBb1 = 1./result.surfactant.dfds(aboveOB);
t_OBf = [0,1/result.secVob,1/result.surfactant.dfds_shock,t_OBb1];
ER_SF1 = Sw(aboveOB) - result.surfactant.Siw - (result.surfactant.fw(aboveOB)-1)./result.surfactant.dfds(aboveOB);
ER_SF = [0, 0, (result.fw_OB)*(t_OBf(3)-t_OBf(2)), ER_SF1];

result.t_OBf = t_OBf;
result.ER_SF = ER_SF;

result.merge = struct();
A = [result.Sw_OB*tilt + waterData.Siw*(1-tilt), 0];
B = [surfResult.Sw_shock, result.fw_OB];
C = [surfResult.ER_BT_Sw, 1];
result.merge.A = A;
result.merge.B = B;
result.merge.C = C;
mergeX = [0, A(1),result.Sw_OB, B(1), B(1), C(1)];
mergeY = [0, A(2), result.fw_OB, B(2), surfResult.fw_shock, C(2)];
result.merge.X = mergeX;
result.merge.Y = mergeY;
result.miscibleFun1 = @(x)miscibleMerge1(x, mergeX, mergeY);
result.miscibleFun2 = @(x)miscibleMerge2(x, mergeX, mergeY);

function ret = miscibleMerge1(Sw, mergeX, mergeY)
ret = zeros(size(Sw));
sz = length(Sw);

for i=1:sz;
    x = Sw(i);
    if x < mergeX(2)
        ret(i) = 0;
    elseif x < mergeX(3)
        ret(i) = valueAt(mergeX(2), mergeY(2), mergeX(3), mergeY(3),x);
    elseif x < mergeX(4)
        ret(i) = mergeY(3);
    elseif x == mergeX(4)
        ret(i) = mergeY(5);
    else
        m = (mergeY(end)-mergeY(end-1))/(mergeX(end)-mergeX(end-1));
        ret(i) = min([1, m*(x-mergeX(end-1)) + mergeY(end-1)]);
    end
end

function ret = miscibleMerge2(Sw, mergeX, mergeY)
ret = zeros(size(Sw));
sz = length(Sw);

for i=1:sz;
    x = Sw(i);
    if x <= mergeX(2)
        ret(i) = 0;
    elseif x < mergeX(3)
        ret(i) = valueAt(mergeX(2), mergeY(2), mergeX(3), mergeY(3),x);
    else
        m = (mergeY(end-1)-mergeY(3))/(mergeX(end-1)-mergeX(3));
        ret(i) = min([1, m*(x-mergeX(3)) + mergeY(3)]);
    end
end


function y = valueAt(x1, y1, x2, y2, x)
if x1 == x2
    y = y2;
    return
end
m = (y2-y1)/(x2-x1);
y = min([1, m*(x-x1) + y1]);
