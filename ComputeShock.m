function z = ComputeShock(Snw, data)
% ComputeShock  computes the difference between dfds and norm_tangent. 
%   z = ComputeShock(Snw, data)
%   Snw - normalized water saturation. It could be a scaler or vector.
%   data is a structure data type with the following fields:
%   M - mobility ratio
%   nw - corey coefficient for chemical
%   no - corey coefficient for oil
%   Di - negative of the retardation term
%   Dni - normalized Di
%   
%   ComputeShock returns z. z is the difference between the derivative of
%   fractional flow and the normalized tangent function.
%
%   NOTE: The purpose of this function is to determine the value of Snw where
% ComputeShock is equal to 0. This function will be fed to fzero to
% determine Snw where z is 0.

Sw = WaterSaturation(Snw,data);
M = data.M;
nw = data.nw;
no = data.no;
Di = data.Di;
Dni = data.Dni;
fw=1./(1+((1-Snw).^no./(Snw.^nw))/M);  % Fractional flow
dfds1= ComputeDFDS(Snw, data);         % Derivative of fractional flow
norm_tangent = fw./(Snw-Dni);          % Normalized tangent function
z=dfds1-norm_tangent;
