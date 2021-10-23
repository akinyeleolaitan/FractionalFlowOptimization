function ret = ComputeFlowProperty(Sw, data)
% ComputeFlowProperty    Computes Mobility, normalized water saturation,
%   relative permeability and fractional flow of a given chemical flooding
%   ret = ComputeFlowProperty(Sw, data)
%   Sw is a vector of water saturation ranging from 0 to 1
%   data is a structure data type that contains all the fixed parameters of
%   the chemical flooding. data must contain the following fields: 
%   Siw - connate water
%   Sor - residual oil saturation
%   Krw0 - end-point relative permeability of chemical
%   Kro0 - end-point relative permeability of oil
%   nw - corey coefficient of chemical
%   no - corey coefficient of oil
%   uw - viscosity of chemical
%   uo - viscosity of oil
%
%   ComputeFlowProperty returns ret. ret is a structure data type that
%   contains all the input parameter as well as the following fields:
%   M - mobility ratio
%   Snw - normalized water saturation
%   Sno - normalized oil saturation
%   Krw - relative permeability of chemical
%   Kro - relative permeability of oil
%   fw - fractional flow of chemical phase
%   fo - fractional flow of oil phase

Siw = data.Siw;
Sor = data.Sor;
Krw0 = data.Krw0;
Kro0 = data.Kro0;
nw = data.nw;
no = data.no;
uw = data.uw;
uo = data.uo;

M = Krw0 * uo/(Kro0*uw);
Snw = (Sw-Siw)/(1 - Siw - Sor);
Snw(Snw<=0) = eps;
Snw(Snw>=1) = 1 - eps;
Sno = 1 - Snw;
Krw = Krw0*Snw.^nw;
Kro = Kro0*Sno.^no;
fw = 1./(1 + Kro*uw./(Krw*uo));
fo = 1 - fw;

ret = data;
ret.M = M;
ret.Snw = Snw;
ret.Sno = Sno;
ret.Krw = Krw;
ret.Kro = Kro;
ret.fw = fw;
ret.fo = fo;

