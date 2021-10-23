function PlotFlow(simResult, options)
% PlotFlow  Plots the relative permeability curve, water fractional flow
% curve and saturation profile curve
%   PlotFlow(simResult, options)
%   simResult - result from SimulateFlow.
%   options - optional settings for deciding the color, line width, etc.

defOptions = struct('color_w','b', 'color_s','r','color_c','k','color_o','r','color_ws','m','color_ss','m','color_ob',[56, 142, 60]/255,'secondary',true,'width',2,'font_size',11,...
    'axes1',[],'axes2',[],'axes3',[]);
if nargin == 1
   options = defOptions;
else
    fds = fieldnames(defOptions);
    sz = length(fds);
    for i=1:sz;
        fn = fds{i};
        if ~isfield(options, fn)
            options.(fn) = defOptions.(fn);
        end
    end
end

waterResult = simResult.water;
surfResult = simResult.surfactant;
if isempty(options.axes1) || options.axes1 ~= 0
    permeabilityCurves(waterResult, surfResult, options);
end
if isempty(options.axes2) || options.axes2 ~= 0
    fractionalFlowCurves(simResult, options);
    if isempty(options.axes2) 
        fractionalFlowCurves2(simResult, options, simResult.miscibleFun1);
        fractionalFlowCurves2(simResult, options, simResult.miscibleFun2);
    end
end
if isempty(options.axes3) || options.axes3 ~= 0
    profileCurves(simResult, options);
end
%recoveryCurve(simResult, options);

function permeabilityCurves(waterResult, surfResult, options)
colW = options.color_w;
colS = options.color_s;
colO = options.color_o;
colC = options.color_c;
isSec = options.secondary;
lineW = options.width;
fontSz = options.font_size;
if isempty(options.axes1)
    figure();
else
    axes(options.axes1)
end
Sw = waterResult.Sw;
hold on
plt_ww = performPlot(Sw,waterResult.Krw,'-',lineW,colW);
plt_wo = performPlot(Sw,waterResult.Kro,'-',lineW,colO);
plt_sw = performPlot(Sw,surfResult.Krw,'--',lineW,colW);
plt_so = performPlot(Sw,surfResult.Kro,'--',lineW,colO);
xlabel('Sw, Water Saturation')
ylabel('Relative Permeability')
legend({'Krw','Kro','Krw SF','Kro SF'})
set(gca(),'xlim',[0,1],'ylim',[0,1])
hold off

function fractionalFlowCurves(simResult, options)
colW = options.color_w;
colS = options.color_s;
colO = options.color_o;
colC = options.color_c;
colOB = options.color_ob;
colSS = options.color_ss;

isSec = options.secondary;
lineW = options.width;
fontSz = options.font_size;
waterResult = simResult.water;
surfResult = simResult.surfactant;
if isempty(options.axes2)
    figure();
else
    axes(options.axes2)
end
Sw = waterResult.Sw;
pd = 0.01;
hold on
plt_w = performPlot(Sw,waterResult.fw,'-',lineW,colW);
plt_s = performPlot(Sw,surfResult.fw,'-',lineW,colS);
fc = 1.1;
plt_stan = performPlot([surfResult.Di,surfResult.ER_BT_Sw],[0,surfResult.tangentFun(surfResult.ER_BT_Sw)],'--',1,colS);
if isSec
    plt_BFtan = performPlot([waterResult.Di,simResult.Sw_OB],[0,simResult.fw_OB],'--',1,colW);
    plot(waterResult.Di, 0,'ro','color',colC,'markerfacecolor',colC)
    text(waterResult.Di-pd, 0,'Sw_{iw}','color',colC,'verticalalignment','bottom','horizontalalignment','right','fontsize',fontSz)
else
    plt_BFtan = performPlot([waterResult.Sw_shock,simResult.Sw_OB],[waterResult.fw_shock,simResult.fw_OB],'--',1,colW);
    plot(waterResult.Sw_shock, waterResult.fw_shock,'ro','color',colC,'markerfacecolor',colC)
    text(waterResult.Sw_shock-pd, waterResult.fw_shock,'Sw_{iw}, fw_{iw}','color',colC,'verticalalignment','bottom','horizontalalignment','right','fontsize',fontSz)
end
plot(surfResult.Sw_shock, surfResult.fw_shock,'ro','color',colSS,'markerfacecolor',colSS)
plot(simResult.Sw_OB, simResult.fw_OB,'ro','color',colOB,'markerfacecolor',colOB)

text(surfResult.Sw_shock+pd, surfResult.fw_shock,'Sw_{SS}, fw_{SS}','color',colSS,'verticalalignment','top','fontsize',fontSz)
text(simResult.Sw_OB-pd, simResult.fw_OB,'Sw_{OB}, fw_{OB}','color',colOB,'verticalalignment','bottom','horizontalalignment','right','fontsize',fontSz)

xlabel('Sw, Water Saturation')
ylabel('Water Fractional Flow')
legend([plt_w,plt_s,plt_stan,plt_BFtan],{'Water Flooding','Surfactant Flooding','Tangent Line SF','Shock Water Front'},'location','northwest')
set(gca(),'xlim',[min([0,min(Sw),waterResult.Di,surfResult.Di]),1],'ylim',[0,1])

hold off

function profileCurves(simResult, options)
colW = options.color_w;
colS = options.color_s;
colO = options.color_o;
colC = options.color_c;
colOB = options.color_ob;
colSS = options.color_ss;

isSec = options.secondary;
lineW = options.width;
fontSz = options.font_size;
waterResult = simResult.water;
surfResult = simResult.surfactant;
if isempty(options.axes3)
    figure();
else
    axes(options.axes3)
end
Sw = waterResult.Sw;
pd = 0.01;
hold on
if isSec
    X = simResult.secDistance;
    Y = simResult.secSaturation;
    text(mean(X(end-1:end)), mean(Y(end-1:end))+pd*2, 'Oil Bank','color',colW, 'verticalalignment','bottom','horizontalalignment','center','fontsize',fontSz)
else
    X = simResult.terDistance;
    Y = simResult.terSaturation;
    text(mean(X(end-3:end-2)), mean(Y(end-3:end-2))+pd*2, 'Oil Bank','color',colW, 'verticalalignment','bottom','horizontalalignment','center','fontsize',fontSz)
end
plt_w = performPlot(X,Y,'-',lineW,colW);
plot(X(end-4),Y(end-4),'ro','color',colSS,'markerfacecolor',colSS)
plot(X(end-3),Y(end-3),'ro','color',colOB,'markerfacecolor',colOB)
plot(X(end-2),Y(end-2),'ro','color',colOB,'markerfacecolor',colOB)
plot(X(end-1),Y(end-1),'ro','color',colC,'markerfacecolor',colC)

text(X(end-4)+pd,Y(end-4),'Sw_{DOBb}, Sw_{SS}','color',colSS,'verticalalignment','bottom','fontsize',fontSz)
text(X(end-3)-pd,Y(end-3),'Sw_{DOBb}, Sw_{OB}','color',colOB,'verticalalignment','middle','horizontalalignment','right','fontsize',fontSz)
text(X(end-2)+pd,Y(end-2),'Sw_{DOBf}, Sw_{OB}','color',colOB,'verticalalignment','middle','fontsize',fontSz)
text(X(end-1)-pd,Y(end-1),'Sw_{DOBf}, Sw_{iw}','color',colC,'verticalalignment','middle','horizontalalignment','right','fontsize',fontSz)

ylabel('Sw, Water Saturation')
xlabel('Dimensionless Distance')
set(gca(),'xlim',[0,1],'ylim',[0,1])
hold off

function fractionalFlowCurves2(simResult, options, miscibleFun)
colW = options.color_w;
colS = options.color_s;
colO = options.color_o;
colC = options.color_c;
colOB = options.color_ob;
colSS = options.color_ss;

isSec = options.secondary;
lineW = options.width;
fontSz = options.font_size;
waterResult = simResult.water;
surfResult = simResult.surfactant;
if isempty(options.axes2)
    figure();
else
    axes(options.axes2)
end
Sw = waterResult.Sw;
pd = 0.01;
hold on
plt_w = performPlot(Sw,waterResult.fw,'-',lineW,colW);
plt_s = performPlot(Sw,surfResult.fw,'-',lineW,colS);
fc = 1.1;
plt_stan = performPlot([surfResult.Di,surfResult.ER_BT_Sw],[0,surfResult.tangentFun(surfResult.ER_BT_Sw)],'--',1,colS);
if isSec
    plt_BFtan = performPlot([waterResult.Di,simResult.Sw_OB],[0,simResult.fw_OB],'--',1,colW);
    plot(waterResult.Di, 0,'ro','color',colC,'markerfacecolor',colC)
    text(waterResult.Di-pd, 0,'Sw_{iw}','color',colC,'verticalalignment','bottom','horizontalalignment','right','fontsize',fontSz)
else
    plt_BFtan = performPlot([waterResult.Sw_shock,simResult.Sw_OB],[waterResult.fw_shock,simResult.fw_OB],'--',1,colW);
    plot(waterResult.Sw_shock, waterResult.fw_shock,'ro','color',colC,'markerfacecolor',colC)
    text(waterResult.Sw_shock-pd, waterResult.fw_shock,'Sw_{iw}, fw_{iw}','color',colC,'verticalalignment','bottom','horizontalalignment','right','fontsize',fontSz)
end
plot(surfResult.Sw_shock, surfResult.fw_shock,'ro','color',colSS,'markerfacecolor',colSS)
plot(simResult.Sw_OB, simResult.fw_OB,'ro','color',colOB,'markerfacecolor',colOB)

mergedY = miscibleFun(Sw);

mplt = plot(Sw, mergedY, 'k-', 'linewidth', 2);

text(surfResult.Sw_shock+pd, surfResult.fw_shock,'Sw_{SS}, fw_{SS}','color',colSS,'verticalalignment','top','fontsize',fontSz)
text(simResult.Sw_OB-pd, simResult.fw_OB,'Sw_{OB}, fw_{OB}','color',colOB,'verticalalignment','bottom','horizontalalignment','right','fontsize',fontSz)

A = simResult.merge.A;
B = simResult.merge.B;
C = simResult.merge.C;
text(A(1), A(2),' A ','color','k','verticalalignment','bottom','horizontalalignment','left','fontsize',fontSz)
mergedTitle = 'Modified';
if any(B(2) == mergedY)
    text(B(1), B(2),' B ','color','k','verticalalignment','top','horizontalalignment','center','fontsize',fontSz)
    text(C(1), C(2),' C ','color','k','verticalalignment','bottom','horizontalalignment','center','fontsize',fontSz)
else
    mergedTitle = 'Modified';
    text(C(1), C(2),' B ','color','k','verticalalignment','bottom','horizontalalignment','center','fontsize',fontSz)
end

xlabel('Sw, Water Saturation')
ylabel('Water Fractional Flow')
legend([plt_w,plt_s,mplt,plt_stan,plt_BFtan],{'Water Flooding','Surfactant Flooding', mergedTitle,'Tangent Line SF','Shock Water Front'},'location','northwest')
set(gca(),'xlim',[min([0,min(Sw),waterResult.Di,surfResult.Di]),1],'ylim',[0,1])

hold off

function recoveryCurve(simResult, options)
colW = options.color_w;
colS = options.color_s;
colO = options.color_o;
colC = options.color_c;
colOB = options.color_ob;
colSS = options.color_ss;

isSec = options.secondary;
lineW = options.width;
fontSz = options.font_size;
waterResult = simResult.water;
surfResult = simResult.surfactant;
figure();
Sw = waterResult.Sw;
pd = 0.01;
hold on
X = simResult.t_OBf;
Y = simResult.ER_SF;
plt_w = performPlot(X,Y,'-',lineW,colW);

ylabel('Recovery Factor')
xlabel('Dimensionless Time')
%set(gca(),'xlim',[0,1],'ylim',[0,1])
hold off

function ret = performPlot(X,Y,lstyle,wd,col)
ret = plot(X,Y,['r',lstyle], 'linewidth', wd, 'color',col);



