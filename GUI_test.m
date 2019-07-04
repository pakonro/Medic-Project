function varargout = GUI_test(varargin)
% GUI_TEST MATLAB code for GUI_test.fig
%      GUI_TEST, by itself, creates a new GUI_TEST or raises the existing
%      singleton*.
%
%      H = GUI_TEST returns the handle to a new GUI_TEST or the handle to
%      the existing singleton*.
%
%      GUI_TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TEST.M with the given input arguments.
%
%      GUI_TEST('Property','Value',...) creates a new GUI_TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_test

% Last Modified by GUIDE v2.5 04-Jul-2019 16:21:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_test_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_test_OutputFcn, ...
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


% --- Executes just before GUI_test is made visible.
function GUI_test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_test (see VARARGIN)

% Choose default command line output for GUI_test
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
 

% --- Executes on button press in lookForTimestamp.
function lookForTimestamp_Callback(hObject, eventdata, handles)
% hObject    handle to lookForTimestamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%loads a choosen binary File
[FileNameTime,PathNameTime] = uigetfile('*.bin','Load bin-File');
%Makes a String with the complete path to the file INCLUDING the name used
%in the function "fopen()"
FullPathTIme = strcat(PathNameTime,FileNameTime);
%open the file, read the data
fileID = fopen(FullPathTIme);
timestamps = fread(fileID, Inf, 'uint64');
%calculate the mean time between two A-scans
global xTime
xTime = (timestamps(end) - timestamps(1)) / (size(timestamps, 1)) / 50 / 1000; %seconds per A-scan
%just something to visulize possible "hickups" when recording the
%timestamps
axes(handles.axesTimestamp)
plot (1:10000,timestamps(1:10000))
fclose(fileID);


% --- Executes on button press in Calculate_lamnda.
function Calculate_lamnda_Callback(hObject, eventdata, handles)
% hObject    handle to Calculate_lamnda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global revTime xTime bscanSize
%bscanSize equals Lamda
bscanSize = round(revTime/xTime);
Lamnda_text = num2str(bscanSize);
set(handles.ausgabe_Lamnda,'String',strcat(Lamnda_text,' A-scans per slice'));

% --- Executes on selection change in choose_stepFreq.
function choose_stepFreq_Callback(hObject, eventdata, handles)
% hObject    handle to choose_stepFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns choose_stepFreq contents as cell array
%        contents{get(hObject,'Value')} returns selected item from choose_stepFreq
% a Stepfrequency of 100 Hz of the motor equals 12,5 turns per second 
global revTime
switch get(handles.choose_stepFreq,'Value')   
  case 1 %empty because onlya change in menu is registered
        
  case 2
    revTime = (1/(12.5*70/100));
  case 3
    revTime = (1/12.5);
  otherwise
end 

% --- Executes during object creation, after setting all properties.
function choose_stepFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to choose_stepFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in lookForMat.
function lookForMat_Callback(hObject, eventdata, handles)
% hObject    handle to lookForMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  %if the *.mat is not in this workdirectory use this to locate the
  %filepath
  [FileName,PathName] = uigetfile('*.mat','Load mat-File');
  %Makes a String with the complete path to the file INCLUDING the Filename for
  %"load"
  FullPath = strcat(PathName,FileName);
  global oct_image
  load(FullPath);
  %display in axesSin
  axes(handles.axesSin)
  %loads the File indicated by the path "FullPath" 
  oct_image = mAscans;
  
    % remove line artifact estimated between row 215 - 230
for i = 1:length(oct_image)
    col = oct_image(215:230, i);
    above_mean = mean(col(1:5));
    below_mean = mean(col(11:15));
    col(6:10) = (above_mean + below_mean) / 2;
    oct_image(215:230, i) = col;
end   
    imagesc(oct_image);

% --- Executes on button press in reshape_mat.
function reshape_mat_Callback(hObject, eventdata, handles)
% hObject    handle to reshape_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cscan oct_image bscanSize
%transform the 2D Matrix into a 3D Matrix
start_index = 650001;
end_index = 950000;
bscan_count = floor((end_index - start_index) / bscanSize);
mscan_subset = oct_image(:, start_index:(start_index - 1 + bscan_count * bscanSize));
cscan = reshape(mscan_subset, [512, bscanSize, bscan_count]);
%load the sinnogram slice 100 (randomly choosen) into the first  axes
axes(handles.axesSin)
imagesc(cscan(:,:,100));


% --- Executes on button press in polar_transformation_button.
function polar_transformation_button_Callback(hObject, eventdata, handles)
% hObject    handle to polar_transformation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
       
[file, folder]=uigetfile('*.m','Load *.m-File'); %prompt user to select mfile
run(fullfile(folder,file)); %fun the m-file.

% --- Executes on slider movement.
function slider_slice_Callback(hObject, eventdata, handles)
% hObject    handle to slider_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%obtains the slider value from the slider component
global sliderValue
sliderValue = get(handles.slider_slice,'Value');
%puts the slider value into the edit text component
set(handles.slider_editText,'String', num2str(sliderValue));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_slice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end  
 
% --- Executes on button press in calculate_radius.
function calculate_radius_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fit_elipse.
function fit_elipse_Callback(hObject, eventdata, handles)
% hObject    handle to fit_elipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sliderValue
imgesc(T(:,:,sliderValue))


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  [FileName,PathName] = uigetfile('*.mat','Load mat-File');
  %Makes a String with the complete path to the file INCLUDING the Filename for
  %"load"
  FullPath = strcat(PathName,FileName);
  global T
  load(FullPath);
  %display in axesSin
  axes(handles.axes_cart)
  T = Q;
  
