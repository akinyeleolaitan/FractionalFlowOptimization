function ret = NormWaterSaturation(Sw, data)
% This function computes normalized water saturation given water saturation

Siw = data.Siw;
Sor = data.Sor;
ret = (Sw - Siw)./(1 - Sor - Siw);
ret(ret<=0) = eps;
ret(ret>=1) = 1 - eps;