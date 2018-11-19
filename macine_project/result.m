function varargout = GUI(varargin)
% GUI M-file for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 29-May-2015 00:43:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in CALCULATE.
function CALCULATE_Callback(hObject, eventdata, handles)
% hObject    handle to CALCULATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Given Data
%load('core_type.mat','Writable',isWritable);
%load('D.mat');
%load('E.mat');
%load('F.mat');
%load('G.mat');
%load('core_volume.mat');

%global core_type;
%global D;
%global E;
%global F;
%global G;
%global core_volume;

rated_Kva = 225000;
rated_Vp = 11000;
rated_Vs = 415;
frequency = 50;
maximun_loss = .02;

%%Input data

contents = get(handles.CORE_TYPE,'Value');
core_type = 1;
switch contents
    case 1
        core_type = 1;
    case 2
        core_type = 2;
    otherwise
end
    
contents = get(handles.CORE_MATERIAL,'Value');
core_material = 1;
switch contents
    case 1
        core_material = 1;
    case 2
        core_material = 2;
    
    otherwise
end

contents = get(handles.COIL_CONNECTION,'Value');
coil_connection = 1;
switch contents
    case 1
        coil_connection = 1;
    case 2
        coil_connection = 2;
    case 3
        coil_connection = 3;
    case 4
        coil_connection = 4;
        otherwise
end

%% some variable

%values used for iteration 
x = 1;
y = 1;
z = 1;
p = 1;
q = 1;

%tables
load('core_dimension.mat');
load('AWG.mat');

%unit conversion
cm = 10^-2;
cm_squared = 10^-4;
mm = 10^-3;
mm_squared = 10^-6;

%two constant
utilization_factor = .73; %S1=.961,S2=.9,S3=.907,S4=.929 
waveform_coeff = 4.44;



while 1

%% CORE LOSS CALCULATION

if core_material == 1
    
%core matrial :-  M6 CRGO
saturation_flux = 2.035;
core_density = 7650;
hysteresis_coeff = 1.54;
steinmetz_exp = 1.9;

%possible flux densities in tesla
B = [1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8];

%watt per kg for each of the flux densities
watt_kg = [.437 .525 .622 .730 .855 1.000 1.180 1.427 1.800];

else
    
%core matrial :-  Orthonol
saturation_flux = 1.5; % mean of 1.42 and 1.58
core_density = 8730;
hysteresis_coeff = .68;
steinmetz_exp = 1.5;

%possible flux densities in tesla
B = [.90 .95 1.00 1.05 1.10 1.15 1.20 1.25 1.3];

%watt per kg for each of the flux densities
watt_kg = [.174 .188 .202 .217 .232 .247 .263 .279 .295];
end


%%assuming core dimension 

p_max = length(core_dimension);
D = core_dimension(p,1)*cm;
E = core_dimension(p,2)*cm;
F = core_dimension(p,3)*cm;
G = core_dimension(p,4)*cm;



%%calculating core volume

if core_type == 1
    core_volume = 3*((G+2*F)*E*D) + 4*(F*F*D); %core_type
else
    core_volume = 5*((G+2*F)*E*D) + 8*(F*F*D); %shell_type
end



%%calculating core weight

%core density is in kg per cubic meter
core_weight = core_density*core_volume;



%%core loss calculation

z_max = length(watt_kg);
z = z_max;
CORE_LOSS = watt_kg(z)*core_weight;



%%some area terms

MLT = core_dimension(p,5)*cm;
iron_area = core_dimension(p,6)*cm_squared;
window_area = core_dimension(p,7)*cm_squared;
area_product = core_dimension(p,8)*cm_squared*cm_squared;
core_geometry = core_dimension(p,9)*cm_squared*cm_squared*cm;




%% HYSTERESIS LOSS AND EDDY CURRENT LOSS

HYSTERESIS_LOSS = hysteresis_coeff*(B(z)^steinmetz_exp)*frequency;
EDDY_LOSS = CORE_LOSS - HYSTERESIS_LOSS;







%% COPPER LOSS CALCULATION
%resistivity = 1.72*10^-8 ohm meter

%%calculating currents and voltages of phase and line
    
Vp_line = rated_Vp;
Vs_line = rated_Vs;

if coil_connection == 1

Vp_phase = Vp_line;
Vs_phase = Vs_line;

Ip_phase = rated_Kva/(3*Vp_phase);
Is_phase = rated_Kva/(3*Vs_phase);

Ip_line = Ip_phase*sqrt(3);
Is_line = Is_phase*sqrt(3);

elseif coil_connection == 2
    
Vp_phase = Vp_line/sqrt(3);
Vs_phase = Vs_line/sqrt(3);

Ip_phase = rated_Kva/(3*Vp_phase);
Is_phase = rated_Kva/(3*Vs_phase);

Ip_line = Ip_phase;
Is_line = Is_phase;

elseif coil_connection == 3
 
Vp_phase = Vp_line;
Vs_phase = Vs_line/sqrt(3);

Ip_phase = rated_Kva/(3*Vp_phase);
Is_phase = rated_Kva/(3*Vs_phase);

Ip_line = Ip_phase*sqrt(3);
Is_line = Is_phase;

else    

Vp_phase = Vp_line/sqrt(3);
Vs_phase = Vs_line;

Ip_phase = rated_Kva/(3*Vp_phase);
Is_phase = rated_Kva/(3*Vs_phase);

Ip_line = Ip_phase;
Is_line = Is_phase*sqrt(3);
end


%%calculating ampere-turns
 
wind_turn_Np = (Vp_phase)/(waveform_coeff*frequency*B(z)*iron_area);
wind_turn_Ns = wind_turn_Np*Vs_phase/Vp_phase;

%%calculaing Length of the windings

wind_length_Lp = MLT*wind_turn_Np;
wind_length_Ls = MLT*wind_turn_Ns;

%%calculating bare wire area

%utilizaton factor for each of the windings is half of the total factor
bare_wire_area_p = (window_area*utilization_factor)/(8*wind_turn_Np);
bare_wire_area_s = (window_area*utilization_factor)/(8*wind_turn_Ns);


%%getting a cross-sectional area of the windings

%checking a match with ampacity and rated_current
x_max = length(AWG);
for i = x_max:-1:1
    if( AWG(i,3) > Ip_phase )
        break
    end
end
x = i-1;

y_max = length(AWG);
for i = y_max:-1:1
    if( AWG(i,3) > Is_phase )
        break
    end
end
y = i-1;

%increasing wire area to maximum comparing with maximum bare wire area
for i = x:-1:1
    if( AWG(i,1)*mm_squared > bare_wire_area_p )
        break
    end
end
x = i-1;

for i = y:-1:1
    if( AWG(i,1)*mm_squared > bare_wire_area_s )
        break
    end
end
y = i-1;

%storing the optimized area
wind_area_Ap = AWG(x+1,1)*mm_squared;
wind_area_As = AWG(y+1,1)*mm_squared;

%%caculating resistance

resistivity = 1.72*10^-8;
Rp = resistivity*wind_length_Lp/wind_area_Ap;
Rs = resistivity*wind_length_Ls/wind_area_As;

%%calculating copper loss 

Copper_Loss_p = 3*Ip_phase^2*Rp;
Copper_Loss_s = 3*Is_phase^2*Rs;

COPPER_LOSS = Copper_Loss_p + Copper_Loss_s;




%% EFFICIENCY CALCULATION & ITERATION CONDITION

total_loss = CORE_LOSS + COPPER_LOSS;

Pin = 3*(Vp_phase*Ip_phase);
Pout = 3*(Vs_phase*Is_phase); %efficiency is considered 100%
efficiency = ( (Pin-total_loss) / Pin ) * 100;



%% CALCULATING REGULATION

%assuming leakage reactance is negligible and power factor is unity;
REGULATION = ( (COPPER_LOSS)/(Pout) )*100;




%% POWER HANDLING CAPABILITY OF CORE

%%current density

%(1/750) amp/cir. mils is conservative; (1/500) amp/cir. mils is aggressive.
%rule of thumb is applied
current_density = 3*10^6;

apparant_power = (area_product*waveform_coeff*utilization_factor*saturation_flux*current_density*frequency);




%% SOME OUTPUT TERMS

MAXIMUM_FLUX_DENSITY = B(z);
WATT_KG = watt_kg(z);
OPTIMIZED_LOSS = total_loss;
PRIMARY_RESISTANCE_Rp = Rp;
SECONDARY_RESISTANCE_Rs = Rs;

%%AWG and wire size

temp = AWG(x,4);

if( x < 20 )
    AWG_P = sprintf('1/%d',temp);
else
    AWG_P = sprintf('%d',temp);
end   

BARE_WIRE_AREA_P = AWG(x,1);
OPTIMIZED_WIND_AREA_P = ( pi*(AWG(x,5)^2) )/4; 

temp = AWG(y,4);

if( y < 20 )
    AWG_S = sprintf('1/%d',temp);
else
    AWG_S = sprintf('%d',temp);
end   

BARE_WIRE_AREA_S = AWG(y,1);
OPTIMIZED_WIND_AREA_S = ( pi*(AWG(y,5)^2) )/4;



%% updating iteration parameter

if apparant_power <= (Pin+Pout) 
    p = p+1;
else
    break
end

if p > p_max
    break
end


end

%% output
set(handles.AWG_P,'string',num2str(AWG_P));
set(handles.AWG_S,'string',num2str(AWG_S));
set(handles.BARE_WIRE_AREA_P,'string',num2str(BARE_WIRE_AREA_P));
set(handles.BARE_WIRE_AREA_S,'string',num2str(BARE_WIRE_AREA_S));
set(handles.OPTIMIZED_WIND_AREA_P,'string',num2str(OPTIMIZED_WIND_AREA_P));
set(handles.OPTIMIZED_WIND_AREA_S,'string',num2str(OPTIMIZED_WIND_AREA_S));
set(handles.MAXIMUM_FUX_DENSITY,'string',num2str(B(z)));
set(handles.WATT_KG,'string',num2str(watt_kg(z)));
set(handles.CORE_LOSS,'string',num2str(CORE_LOSS));
set(handles.HYSTERESIS_LOSS,'string',num2str(HYSTERESIS_LOSS));
set(handles.EDDY_LOSS,'string',num2str(EDDY_LOSS));
set(handles.COPPER_LOSS,'string',num2str(COPPER_LOSS));
set(handles.PRIMARY_RESISTANCE,'string',num2str(PRIMARY_RESISTANCE_Rp));
set(handles.SECONDARY_RESISTANCE,'string',num2str(SECONDARY_RESISTANCE_Rs));
set(handles.OPTIMIZED_LOSS,'string',num2str(OPTIMIZED_LOSS));
set(handles.REGULATION,'string',num2str(REGULATION));
set(handles.efficiency,'string',num2str(efficiency));


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in CORE_TYPE.
function CORE_TYPE_Callback(hObject, eventdata, handles)
% hObject    handle to CORE_TYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CORE_TYPE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CORE_TYPE


% --- Executes during object creation, after setting all properties.
function CORE_TYPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CORE_TYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CORE_MATERIAL.
function CORE_MATERIAL_Callback(hObject, eventdata, handles)
% hObject    handle to CORE_MATERIAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CORE_MATERIAL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CORE_MATERIAL


% --- Executes during object creation, after setting all properties.
function CORE_MATERIAL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CORE_MATERIAL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in COIL_CONNECTION.
function COIL_CONNECTION_Callback(hObject, eventdata, handles)
% hObject    handle to COIL_CONNECTION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns COIL_CONNECTION contents as cell array
%        contents{get(hObject,'Value')} returns selected item from COIL_CONNECTION


% --- Executes during object creation, after setting all properties.
function COIL_CONNECTION_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COIL_CONNECTION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CORE_LOSS_Callback(hObject, eventdata, handles)
% hObject    handle to CORE_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CORE_LOSS as text
%        str2double(get(hObject,'String')) returns contents of CORE_LOSS as a double


% --- Executes during object creation, after setting all properties.
function CORE_LOSS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CORE_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HYSTERESIS_LOSS_Callback(hObject, eventdata, handles)
% hObject    handle to HYSTERESIS_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HYSTERESIS_LOSS as text
%        str2double(get(hObject,'String')) returns contents of HYSTERESIS_LOSS as a double


% --- Executes during object creation, after setting all properties.
function HYSTERESIS_LOSS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HYSTERESIS_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EDDY_LOSS_Callback(hObject, eventdata, handles)
% hObject    handle to EDDY_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EDDY_LOSS as text
%        str2double(get(hObject,'String')) returns contents of EDDY_LOSS as a double


% --- Executes during object creation, after setting all properties.
function EDDY_LOSS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EDDY_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AWG_P_Callback(hObject, eventdata, handles)
% hObject    handle to AWG_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AWG_P as text
%        str2double(get(hObject,'String')) returns contents of AWG_P as a double


% --- Executes during object creation, after setting all properties.
function AWG_P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AWG_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AWG_S_Callback(hObject, eventdata, handles)
% hObject    handle to AWG_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AWG_S as text
%        str2double(get(hObject,'String')) returns contents of AWG_S as a double


% --- Executes during object creation, after setting all properties.
function AWG_S_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AWG_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BARE_WIRE_AREA_P_Callback(hObject, eventdata, handles)
% hObject    handle to BARE_WIRE_AREA_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BARE_WIRE_AREA_P as text
%        str2double(get(hObject,'String')) returns contents of BARE_WIRE_AREA_P as a double


% --- Executes during object creation, after setting all properties.
function BARE_WIRE_AREA_P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BARE_WIRE_AREA_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BARE_WIRE_AREA_S_Callback(hObject, eventdata, handles)
% hObject    handle to BARE_WIRE_AREA_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BARE_WIRE_AREA_S as text
%        str2double(get(hObject,'String')) returns contents of BARE_WIRE_AREA_S as a double


% --- Executes during object creation, after setting all properties.
function BARE_WIRE_AREA_S_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BARE_WIRE_AREA_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OPTIMIZED_WIND_AREA_P_Callback(hObject, eventdata, handles)
% hObject    handle to OPTIMIZED_WIND_AREA_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPTIMIZED_WIND_AREA_P as text
%        str2double(get(hObject,'String')) returns contents of OPTIMIZED_WIND_AREA_P as a double


% --- Executes during object creation, after setting all properties.
function OPTIMIZED_WIND_AREA_P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OPTIMIZED_WIND_AREA_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OPTIMIZED_WIND_AREA_S_Callback(hObject, eventdata, handles)
% hObject    handle to OPTIMIZED_WIND_AREA_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPTIMIZED_WIND_AREA_S as text
%        str2double(get(hObject,'String')) returns contents of OPTIMIZED_WIND_AREA_S as a double


% --- Executes during object creation, after setting all properties.
function OPTIMIZED_WIND_AREA_S_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OPTIMIZED_WIND_AREA_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function REGULATION_Callback(hObject, eventdata, handles)
% hObject    handle to REGULATION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REGULATION as text
%        str2double(get(hObject,'String')) returns contents of REGULATION as a double


% --- Executes during object creation, after setting all properties.
function REGULATION_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REGULATION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function efficiency_Callback(hObject, eventdata, handles)
% hObject    handle to efficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of efficiency as text
%        str2double(get(hObject,'String')) returns contents of efficiency as a double


% --- Executes during object creation, after setting all properties.
function efficiency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to efficiency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MAXIMUM_FUX_DENSITY_Callback(hObject, eventdata, handles)
% hObject    handle to MAXIMUM_FUX_DENSITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MAXIMUM_FUX_DENSITY as text
%        str2double(get(hObject,'String')) returns contents of MAXIMUM_FUX_DENSITY as a double


% --- Executes during object creation, after setting all properties.
function MAXIMUM_FUX_DENSITY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAXIMUM_FUX_DENSITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WATT_KG_Callback(hObject, eventdata, handles)
% hObject    handle to WATT_KG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WATT_KG as text
%        str2double(get(hObject,'String')) returns contents of WATT_KG as a double


% --- Executes during object creation, after setting all properties.
function WATT_KG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WATT_KG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CORE_DIMENSION.
function CORE_DIMENSION_Callback(hObject, eventdata, handles)
% hObject    handle to CORE_DIMENSION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function OPTIMIZED_LOSS_Callback(hObject, eventdata, handles)
% hObject    handle to OPTIMIZED_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OPTIMIZED_LOSS as text
%        str2double(get(hObject,'String')) returns contents of OPTIMIZED_LOSS as a double


% --- Executes during object creation, after setting all properties.
function OPTIMIZED_LOSS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OPTIMIZED_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function COPPER_LOSS_Callback(hObject, eventdata, handles)
% hObject    handle to COPPER_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of COPPER_LOSS as text
%        str2double(get(hObject,'String')) returns contents of COPPER_LOSS as a double


% --- Executes during object creation, after setting all properties.
function COPPER_LOSS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COPPER_LOSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PRIMARY_RESISTANCE_Callback(hObject, eventdata, handles)
% hObject    handle to PRIMARY_RESISTANCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PRIMARY_RESISTANCE as text
%        str2double(get(hObject,'String')) returns contents of PRIMARY_RESISTANCE as a double


% --- Executes during object creation, after setting all properties.
function PRIMARY_RESISTANCE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PRIMARY_RESISTANCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SECONDARY_RESISTANCE_Callback(hObject, eventdata, handles)
% hObject    handle to SECONDARY_RESISTANCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SECONDARY_RESISTANCE as text
%        str2double(get(hObject,'String')) returns contents of SECONDARY_RESISTANCE as a double


% --- Executes during object creation, after setting all properties.
function SECONDARY_RESISTANCE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECONDARY_RESISTANCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in CLEAR.
function CLEAR_Callback(hObject, eventdata, handles)
% hObject    handle to CLEAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.AWG_P,'string',num2str(''));
set(handles.AWG_S,'string',num2str(''));
set(handles.BARE_WIRE_AREA_P,'string',num2str(''));
set(handles.BARE_WIRE_AREA_S,'string',num2str(''));
set(handles.OPTIMIZED_WIND_AREA_P,'string',num2str(''));
set(handles.OPTIMIZED_WIND_AREA_S,'string',num2str(''));
set(handles.MAXIMUM_FUX_DENSITY,'string',num2str(''));
set(handles.WATT_KG,'string',num2str(''));
set(handles.CORE_LOSS,'string',num2str(''));
set(handles.HYSTERESIS_LOSS,'string',num2str(''));
set(handles.EDDY_LOSS,'string',num2str(''));
set(handles.COPPER_LOSS,'string',num2str(''));
set(handles.PRIMARY_RESISTANCE,'string',num2str(''));
set(handles.SECONDARY_RESISTANCE,'string',num2str(''));
set(handles.OPTIMIZED_LOSS,'string',num2str(''));
set(handles.REGULATION,'string',num2str(''));
set(handles.efficiency,'string',num2str(''));
