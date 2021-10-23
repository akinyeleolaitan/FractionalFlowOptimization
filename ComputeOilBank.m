function result = ComputeOilBank(Sw,waterResult, surfResult)
% ComputeOilBank    Computes the difference between the fractional flow of
% water flooding and the tangent line of surfactant flooding.
%   result = ComputeOilBank(Sw,waterResult, surfResult)
%   Sw - scaler or vector water saturation
%   waterResult - the output of ComputeAllProperty for water flooding
%   surfResult - the output of ComputeAllProperty for surfactant flooding
%
%   ComputeOilBank returns result. result is the difference between fw and
%   tangentLine. fw is the fractional flow from water flooding while
%   tangentLine is the straight line that runs through the initial
%   condition and shock location of surfactant flooding.
%
%   NOTE: The purpose of this function is to determine the value of Sw
%   where the tangent line of the surfactant flooding intersect the
%   fractional flow of water flooding. This function is passed as input to
%   fzero to determine the water saturation at oil bank.

Snw = NormWaterSaturation(Sw, waterResult);
fw=1./(1+((1-Snw).^waterResult.no./(Snw.^waterResult.nw))/waterResult.M);
tangent = surfResult.maxTangent;
tangentLine = Sw.*tangent - tangent*surfResult.Di;
if fw < 0.03 || fw >= 0.97
    result = 1;
else
    result = fw - tangentLine;
end

