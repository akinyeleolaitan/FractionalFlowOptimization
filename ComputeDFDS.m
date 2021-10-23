function dfds = ComputeDFDS(Snw, data)
% ComputeDFDS    Computes the derivative of fractional flow of chemical
% phase with respect to normalized water saturation.
%   dfds = ComputeDFDS(Snw, data)
%   Snw is a vector of normalized water saturation
%   data is a structure data type that contains all the fixed parameter of
%   the chemical flooding. data must contain the following fields: 
%   M - mobility ratio
%   nw - corey coefficient of chemical
%   no - corey coefficient of oil
%
%   ComputeFlowProperty returns dfds. dfds is a vector of derivatives of fw
%   with respect to Snw

M = data.M;
nw = data.nw;
no = data.no;
fw=1./(1+((1-Snw).^no./(Snw.^nw))/M);
dfds=((fw.^2)/M).*(((1-Snw).^no)./(Snw).^nw).*(no./(1-Snw)+nw./(Snw));

