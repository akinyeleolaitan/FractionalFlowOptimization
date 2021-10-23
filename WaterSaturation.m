function ret = WaterSaturation(Snw, data)
% This function computes water saturation given normalized water saturation

Siw = data.Siw;
Sor = data.Sor;
ret = Siw + Snw.*(1 - Sor - Siw);
