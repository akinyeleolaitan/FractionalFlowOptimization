function flowP = ComputeAllProperty(Sw, data)
% ComputeAllProperty    Computes all the properties associated with a single flooding
%   flowP = ComputeAllProperty(Sw, data)
%   Sw is a vector of water saturation ranging from 0 to 1
%   data is a structure data type that contains all the fixed property of
%   the chemical flooding. data must contain the following fields: 
%   Siw - connate water
%   Sor - residual oil saturation
%   Krw0 - end-point relative permeability of chemical
%   Kro0 - end-point relative permeability of oil
%   nw - corey coefficient of chemical
%   no - corey coefficient of oil
%   uw - viscosity of chemical
%   uo - viscosity of oil
%   Di - negative of the retardation term
%   
%   ComputeAllProperty returns flowP. flowP is a structure data type that
%   contains all the variables in data in addition to the following fields:
%   M - mobility ratio
%   Snw - normalized water saturation
%   Sno - normalized oil saturation
%   Krw - relative permeability of chemical
%   Kro - relative permeability of oil
%   fw - fractional flow of chemical phase
%   fo - fractional flow of oil phase
%   dfds - derivative of fw with respect to Snw
%   Snw_shock - normalized water saturation at the location of shock
%   Sw_shock - water saturation at the location of shock
%   fw_shock - fractional flow at the location of shock
%   dfds_shock - derivative of fw at the location of shock
%   ER_BT_Snw - Recovery efficiency as a function of Snw
%   ER_BT_Sw - Recovery efficiency as a function of Sw
%   tangent - slope of tangent line from initial condition to Sw.
%   norm_tangent - slope of tangent line from initial condition to Snw
%   maxNormTangent - value of norm_tangent at the shock location
%   tangentFun - an anonymous function that computes the value of fw for
%   any Sw on the tangent line that runs through shock location from
%   initial condition
%
% NOTE: The shock location is the value of Sw where dfds is equal to
% norm_tangent.


%% Extracting fixed parameter from data
Siw = data.Siw;
Sor = data.Sor;
Krw0 = data.Krw0;
Kro0 = data.Kro0;
nw = data.nw;
no = data.no;
uw = data.uw;
uo = data.uo;
Di = data.Di;
Dni = (Di - Siw)/(1 - Sor - Siw); % Normalizing Di
data.Dni = Dni;

%% Compute relative permeability and fractional flow
flowP = ComputeFlowProperty(Sw, data);
flowP.Sw = Sw;

M = flowP.M;
Snw = flowP.Snw;
Sno = flowP.Sno;
Krw = flowP.Krw;
Kro = flowP.Kro;
fw = flowP.fw;
fo = flowP.fo;

dfds = ComputeDFDS(Snw, flowP); % Compute the derivative of fw with respect to Snw
norm_tangent = fw./(Snw-Dni);
tangent = fw./(Sw-Di);

% Check if the tangent diverges or if the tangent is constant
if any(max(dfds) == dfds(end-2:end)) || (max(dfds) - min(dfds)) < 0.001
    Snw_shock = NormWaterSaturation(1,flowP); % If any of the above conditions hold, make the shock location to be Sw = 1
else
    Snw_shock=fzero(@(x)ComputeShock(x, flowP),0.8); % Solve for Snw_shock where the difference between dfds and norm_tangent is 0
end

%% Determine properties at shock location
Sw_shock= WaterSaturation(Snw_shock,flowP);
tempFP = ComputeFlowProperty(Sw_shock, flowP);
fw_shock = tempFP.fw;
dfds_shock= ComputeDFDS(Snw_shock, flowP);

ER_BT_Snw=Snw_shock-(fw_shock-1)/dfds_shock;
ER_BT_Sw= Sw_shock-(fw_shock-1)/dfds_shock;
maxTangent = fw_shock/(Sw_shock - Di);
maxNormTangent = fw_shock/(Snw_shock - Dni);

%% Add computed properties to result to be returned
flowP.dfds = dfds;
flowP.Snw_shock = Snw_shock;
flowP.Sw_shock = Sw_shock;
flowP.fw_shock = fw_shock;
flowP.dfds_shock = dfds_shock;
flowP.ER_BT_Snw = ER_BT_Snw;
flowP.ER_BT_Sw = ER_BT_Sw;
flowP.tangent = tangent;
flowP.norm_tangent = norm_tangent;
flowP.maxTangent = maxTangent;
flowP.maxNormTangent = maxNormTangent;
flowP.tangentFun = @(sw)maxTangent*sw - maxTangent*Di;

