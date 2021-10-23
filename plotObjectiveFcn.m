function plotObjectiveFcn(Siw, Sw, waterData, optimData, surfactantData)
% plotObjectiveFcn  Creates a 3D surface plot of the search space of the
% objective function.
%   plotObjectiveFcn(Siw, Sw, waterData, optimData, surfactantData)
%   Siw - desired connate water saturation
%   Sw - vector of water saturation ranging from 0 to 1
%   waterData - a structure data type that represents input paratemer for water flooding
%   optimData - a structure data type that stores the optimization constraints.
%   surfactantData - a structure data type that represents input paratemer for surfactant flooding
%

nw = linspace(0.1,6,60);
no = linspace(0.1,6,60);
[rangeNw,rangeNo] = meshgrid(nw,no);
rangeFw = zeros(size(rangeNw));
row = size(rangeNw,1);
col = size(rangeNw,2);
for i = 1:row;
    for j = 1:col;
        rangeFw(i,j) = objectiveFcn2([Siw,rangeNw(i,j),rangeNo(i,j)], Sw, waterData, optimData, surfactantData);
    end
end
figure;
surf(rangeNw,rangeNo,rangeFw);
hold on
surf(rangeNw,rangeNo, zeros(size(rangeNw)))

xlabel('nw')
ylabel('no')
zlabel('obj fun')
title(['Siw = ',num2str(Siw)])
hold off
