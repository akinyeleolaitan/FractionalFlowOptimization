function varargout = FractionFlowCEOR(varargin)
% FRACTIONFLOWCEOR MATLAB code for FractionFlowCEOR.fig
%      FRACTIONFLOWCEOR, by itself, creates a new FRACTIONFLOWCEOR or raises the existing
%      singleton*.
%
%      H = FRACTIONFLOWCEOR returns the handle to a new FRACTIONFLOWCEOR or the handle to
%      the existing singleton*.
%
%      FRACTIONFLOWCEOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRACTIONFLOWCEOR.M with the given input arguments.
%
%      FRACTIONFLOWCEOR('Property','Value',...) creates a new FRACTIONFLOWCEOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FractionFlowCEOR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FractionFlowCEOR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FractionFlowCEOR

% Last Modified by GUIDE v2.5 12-Oct-2021 00:10:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FractionFlowCEOR_OpeningFcn, ...
                   'gui_OutputFcn',  @FractionFlowCEOR_OutputFcn, ...
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


% --- Executes just before FractionFlowCEOR is made visible.
function FractionFlowCEOR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FractionFlowCEOR (see VARARGIN)

% Choose default command line output for FractionFlowCEOR
handles.output = hObject;
handles.swLength = 2000;
handles.t = 0.2;
waterData = struct('Siw',0.15,'Sor',0.24,'Krw0',0.14,'Kro0',0.4,'nw',4,'no',2,'uw',0.5,'uo',5,'Di',0.15);
surfData = struct('Siw',0.15,'Sor',0.10,'Krw0',0.4,'Kro0',1,'nw',4,'no',1.5,'uw',0.5,'uo',5,'Di',0);
handles.waterData = waterData;
handles.surfData = surfData;
handles.secondary = true;
handles.tilt = 1;
SetDataTable(handles);
handles.simResult = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FractionFlowCEOR wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FractionFlowCEOR_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function SetDataTable(handles)
set(handles.waterDataTable,'data',StructToCell(handles.waterData));
set(handles.surfDataTable,'data',StructToCell(handles.surfData));


function ndata = StructToCell(data)
fnames = fieldnames(data);
sz = length(fnames);
ndata{sz,2} = [];
for i = 1:sz;
    fn = fnames{i};
    ndata{i,1} = fn;
    ndata{i,2} = data.(fn);
end

function ndata = CellToStruct(data)
sz = size(data, 1);
ndata = struct();
for i = 1:sz;
    fn = data{i,1};
    ndata.(fn) = data{i,2};
end

% --- Executes on button press in generateBtn.
function generateBtn_Callback(hObject, eventdata, handles)
% hObject    handle to generateBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function swEdit_Callback(hObject, eventdata, handles)
% hObject    handle to swEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swEdit as text
%        str2double(get(hObject,'String')) returns contents of swEdit as a double


% --- Executes during object creation, after setting all properties.
function swEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function handles = SetInputData(handles)
handles.waterData = CellToStruct(get(handles.waterDataTable,'data'));
handles.surfData = CellToStruct(get(handles.surfDataTable,'data'));
handles.swLength = str2double(get(handles.swEdit,'string'));
handles.Sw = linspace(0,1, handles.swLength);
handles.t = str2double(get(handles.tEdit,'string'));
handles.tilt = str2double(get(handles.tiltEdit,'string'));

function ret = MakeResultData(data, simResult)
header = {'Sw','Snw','Krw','Kro','fw','fo','dfds','Miscible Merged 1','Miscible Merged 2'};
sz = length(header);
ret = zeros(length(data.Snw),sz);
for i = 1:sz-2;
    fn = header{i};
    ret(:,i) = data.(fn)';
end
ret(:,end-1) = simResult.miscibleFun1(data.Sw);
ret(:,end) = simResult.miscibleFun2(data.Sw);
ret = [header; num2cell(ret)];

function SetResultData(simData, tabH, simResult)
data = MakeResultData(simData, simResult);
set(tabH, 'data', data(2:end,:),'columnname',data(1,:));

function ret = MakeMiscellData(simResult)
ret = {'Sw_shock',simResult.water.Sw_shock;
    'fw_shock',simResult.water.fw_shock;
    'Sw_s_shock',simResult.surfactant.Sw_shock;
    'fw_s_shock',simResult.surfactant.fw_shock;
    'Sw_OB',simResult.Sw_OB;
    'fw_OB',simResult.fw_OB;
    'M_water', simResult.water.M;
    'M_surf', simResult.surfactant.M;
    'Secondary Vob',simResult.secVob;
    'Tertiary Vob',simResult.terVob;
    'ER_BT_Sw_water', simResult.water.ER_BT_Sw;
    'ER_BT_Sw_surf', simResult.surfactant.ER_BT_Sw;
    'maxTangent_water',simResult.water.maxTangent;
    'maxTangent_surf',simResult.surfactant.maxTangent;
    'Area Secondary Profile',simResult.secArea;
    'Area Tertiary profile',simResult.terArea;
    };

% --- Executes on button press in computeBtn.
function computeBtn_Callback(hObject, eventdata, handles)
handles = SetInputData(handles);
waterData = handles.waterData;
surfData = handles.surfData;
swLength = handles.swLength;
Sw = handles.Sw;
t = handles.t;
result = SimulateFlow(Sw,waterData, surfData, t, handles.tilt);
handles.simResult = result;
PlotFlow(result, struct('secondary', handles.secondary));
SetResultData(result.water, handles.waterResultTable, result)
SetResultData(result.surfactant, handles.surfResultTable, result);
set(handles.misResultTable, 'data', MakeMiscellData(result))
set(handles.profileResultTable, 'data',[result.secDistance',result.secSaturation'])


guidata(hObject,handles)

% --- Executes on button press in optimizeBtn.
function optimizeBtn_Callback(hObject, eventdata, handles)
OptimizationGUI(handles);




function tEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tEdit as text
%        str2double(get(hObject,'String')) returns contents of tEdit as a double


% --- Executes during object creation, after setting all properties.
function tEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exportResultBtn.
function exportResultBtn_Callback(hObject, eventdata, handles)
simResult = handles.simResult;
if isempty(simResult)
    return
end

filename = inputdlg({'File name'},'Export File Name', [1 50], {'results'});
if isempty(filename)
    return
end
filename = [filename{1},'.xlsx'];
waterResult = MakeResultData(simResult.water, simResult);
surfResult = MakeResultData(simResult.surfactant, simResult);
xlswrite(filename, waterResult,'water_result');
xlswrite(filename, surfResult,'surf_result');
profileResult = [{'Distance','Water Saturation'};num2cell([simResult.secDistance',simResult.secSaturation'])];
xlswrite(filename, profileResult,'profile_result');
xlswrite(filename, MakeMiscellData(simResult),'misc_result');

msgbox('Export Successful', 'Export','modal');


% --- Executes on selection change in secPopupmenu.
function secPopupmenu_Callback(hObject, eventdata, handles)
handles.secondary = get(hObject, 'value') == 1;
guidata(hObject, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns secPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from secPopupmenu


% --- Executes during object creation, after setting all properties.
function secPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tiltEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tiltEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tiltEdit as text
%        str2double(get(hObject,'String')) returns contents of tiltEdit as a double


% --- Executes during object creation, after setting all properties.
function tiltEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tiltEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function shockFrontMenu_Callback(hObject, eventdata, handles)

simResult = handles.simResult;
waterResult = simResult.water;
plotFront(waterResult);

function plotFront(result)
fw = result.fw;
dfds = result.dfds;
Sw = result.Snw;
tangent = result.norm_tangent;
figure;
ax = gca();
plot(ax, Sw,dfds, '-r','linewidth',2);
hold on
plot(ax, Sw, tangent, '-b', 'linewidth', 2);
plot(ax, Sw, fw, '-k', 'linewidth', 2);
mx = max(tangent);
Ss = result.Snw_shock;
plot(ax,[Ss,Ss],[0,mx],'--m','linewidth',2);
xlabel('S_{nw}')
legend({'Derivative of f_{w}', 'Tangent','f_{w}'})
hold off

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
surfResult = handles.simResult.surfactant;
plotFront(surfResult);


