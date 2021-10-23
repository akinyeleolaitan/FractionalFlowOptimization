function varargout = OptimizationGUI(varargin)
% OPTIMIZATIONGUI MATLAB code for OptimizationGUI.fig
%      OPTIMIZATIONGUI, by itself, creates a new OPTIMIZATIONGUI or raises the existing
%      singleton*.
%
%      H = OPTIMIZATIONGUI returns the handle to a new OPTIMIZATIONGUI or the handle to
%      the existing singleton*.
%
%      OPTIMIZATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIMIZATIONGUI.M with the given input arguments.
%
%      OPTIMIZATIONGUI('Property','Value',...) creates a new OPTIMIZATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OptimizationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OptimizationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OptimizationGUI

% Last Modified by GUIDE v2.5 11-Oct-2021 22:49:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OptimizationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @OptimizationGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before OptimizationGUI is made visible.
function OptimizationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OptimizationGUI (see VARARGIN)

% Choose default command line output for OptimizationGUI
if nargin == 4
    prevH = varargin{1};
    handles.waterData = prevH.waterData;
    handles.surfData = prevH.surfData;
    handles.secArea = prevH.simResult.secArea;
    handles.t = prevH.t;
    handles.Sw = linspace(0,1,1000);
    handles.optimData = struct('Sw',0.4,'nw',[1,6],'no',[1,6],'Siw',[0.1,0.5],'Vob',2.4,'secArea',handles.secArea,'includeVelocity',1,'includeArea',1,'includeDistance',1,'t',handles.t, 'includeSwob', 1);
    handles.simResult = SimulateFlow(handles.Sw,handles.waterData,handles.surfData, handles.t); 
    SetResultOnView(handles);
end
handles.optimOptions = struct('Algorithm','interior-point','ConstraintTolerance',1e-6,'Display','iter','FunctionTolerance',1e-6,'MaxFunctionEvaluations',3000,'MaxIterations',400);
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OptimizationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OptimizationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function siwSlider_Callback(hObject, eventdata, handles)
% hObject    handle to siwSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.waterData.Siw = get(hObject,'value');
handles.simResult = SimulateFlow(handles.Sw,handles.waterData,handles.surfData, handles.t);
SetResultOnView(handles)
guidata(hObject, handles)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function siwSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to siwSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function nwSlider_Callback(hObject, eventdata, handles)
handles.waterData.nw = get(hObject,'value');
handles.simResult = SimulateFlow(handles.Sw,handles.waterData,handles.surfData, handles.t); 
SetResultOnView(handles)
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function nwSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nwSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function noSlider_Callback(hObject, eventdata, handles)
handles.waterData.no = get(hObject,'value');
handles.simResult = SimulateFlow(handles.Sw,handles.waterData,handles.surfData, handles.t); 
SetResultOnView(handles)
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function noSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function swobEdit_Callback(hObject, eventdata, handles)
if isempty(get(hObject,'string'))
   return
else
    handles.optimData.Sw = str2num(get(hObject,'string'));
end

SetResultOnView(handles)
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function swobEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swobEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function velocityEdit_Callback(hObject, eventdata, handles)
if isempty(get(hObject,'string'))
   return
else
    handles.optimData.Vob = str2num(get(hObject,'string'));
end

SetResultOnView(handles)
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function velocityEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to velocityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optimizeBtn.
function optimizeBtn_Callback(hObject, eventdata, handles)
waterData = handles.waterData;
surfData = handles.surfData;
optimData = handles.optimData;

[optimWaterData, optimVar, obf, simResult] = OptimizeFlow(waterData, surfData, optimData, handles.optimOptions);
handles.optimVar = optimVar;
handles.obf = obf;
handles.waterData = optimWaterData;
handles.simResult = simResult;
SetResultOnView(handles)
guidata(hObject, handles);

function SetResultOnView(handles, varargin)
set(handles.siwText,'string', ['Siw = ',num2str(handles.waterData.Siw)])

set(handles.nwText,'string', ['nw = ',num2str(handles.waterData.nw)])
set(handles.noText,'string', ['no = ',num2str(handles.waterData.no)])
set(handles.swobEdit,'string', num2str(handles.optimData.Sw))
set(handles.velocityEdit,'string', num2str(handles.optimData.Vob))
set(handles.desiredAreaText,'string', ['Desired Area: ', num2str(handles.secArea)])

if isfield(handles, 'simResult')
    set(handles.resswobText, 'string', ['Resulting Sw_OB: ',num2str(handles.simResult.Sw_OB)])
    set(handles.resVelText, 'string', ['Resulting Velocity: ',num2str(handles.simResult.secVob)])
    set(handles.resultingAreaText,'string', ['Resulting Area: ', num2str(handles.simResult.secArea)])
end
cla(handles.axes1)
cla(handles.axes2)

options = struct('axes1', handles.axes1, 'axes2',handles.axes2,'axes3',0,'font_size',8);
axes(handles.axes2);
sw = handles.optimData.Sw;
fw = handles.simResult.surfactant.tangentFun(sw);
plot(sw,fw,'ro','markersize',8,'markerfacecolor',[255, 165, 0]/255)
PlotFlow(handles.simResult, options)
set(handles.axes1, 'xcolor','w', 'ycolor','w')
set(handles.axes2, 'xcolor','w', 'ycolor','w')


% --- Executes on key press with focus on swobEdit and none of its controls.
function swobEdit_KeyPressFcn(hObject, eventdata, handles)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
options = handles.optimOptions;
defVals = {num2str(options.MaxIterations), num2str(options.ConstraintTolerance), num2str(options.FunctionTolerance)};
ret = inputdlg({'Max Iterations','Constraint Tolerance', 'Function Tolerance'}, 'Optimization Options', [1,50;1,50;1,50],defVals);
if isempty(ret) 
   return
end
options.MaxIterations = str2num(ret{1});
options.ConstraintTolerance = str2num(ret{2});
options.FunctionTolerance = str2num(ret{3});
handles.optimOptions = options;

guidata(hObject, handles)
% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
handles = setOptimizationMethod(hObject, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
handles = setOptimizationMethod(hObject, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
handles = setOptimizationMethod(hObject, handles);
guidata(hObject, handles);


function handles = setOptimizationMethod(hObject, handles)
pmenu = get(hObject,'parent');
children = get(pmenu, 'children');
for c = children;
    set(c, 'checked','off')
end
set(hObject, 'checked','on')
handles.optimOptions.Algorithm = get(hObject,'label');


% --- Executes on button press in searchSpaceBtn.
function searchSpaceBtn_Callback(hObject, eventdata, handles)
ret = inputdlg({'Enter Siw'}, 'Provide Siw',[1,40]);
if isempty(ret)
   return 
end
Siw = str2double(ret{1});
plotObjectiveFcn(Siw, handles.Sw, handles.waterData, handles.optimData, handles.surfData);


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setConstrainOption(hObject, handles, 'includeVelocity')

% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setConstrainOption(hObject, handles, 'includeArea')


% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setConstrainOption(hObject, handles, 'includeDistance')

function setConstrainOption(hObject, handles, fname)
if strcmpi(get(hObject,'checked'), 'on')
   set(hObject,'checked','off')
else
    set(hObject,'checked','on')
end
handles.optimData.(fname) = strcmpi(get(hObject,'checked'), 'on');
guidata(hObject,handles)


% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
setConstrainOption(hObject, handles, 'includeSwob')


% --------------------------------------------------------------------
function mobilityMenu_Callback(hObject, eventdata, handles)
ret = inputdlg({'Enter Mobility Ratio','Enter Ko0'}, 'Provide Mobility Ratio',[1,40;1,40],{num2str(handles.simResult.water.M),num2str(handles.simResult.water.Kro0)});
if isempty(ret)
   return 
end
M = str2double(ret{1});
Kro0 = str2double(ret{2});
handles.waterData.Kro0 = Kro0;
uo = handles.waterData.uo;
uw = handles.waterData.uw;
Krw0 = M*Kro0*uw/uo;
handles.waterData.Krw0 = Krw0;
handles.simResult = SimulateFlow(handles.Sw,handles.waterData,handles.surfData, handles.t); 
SetResultOnView(handles)
guidata(hObject, handles)
