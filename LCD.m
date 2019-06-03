function varargout = LCD(varargin)
% LCD MATLAB code for LCD.fig
%      LCD, by itself, creates a new LCD or raises the existing
%      singleton*.
%
%      H = LCD returns the handle to a new LCD or the handle to
%      the existing singleton*.
%
%      LCD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LCD.M with the given input arguments.
%
%      LCD('Property','Value',...) creates a new LCD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LCD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LCD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LCD

% Last Modified by GUIDE v2.5 20-Jun-2017 07:06:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LCD_OpeningFcn, ...
                   'gui_OutputFcn',  @LCD_OutputFcn, ...
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


% --- Executes just before LCD is made visible.
function LCD_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LCD (see VARARGIN)

% Choose default command line output for LCD
handles.output = hObject;

handles.output = hObject;
handles.AxesHasAnImage = 0;
handles.ImageHasBeenSegmented = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LCD wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LCD_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start_basiccalculations.
function start_basiccalculations_Callback(hObject, eventdata, handles)
% hObject    handle to start_basiccalculations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global I ims imf  liver seg

%% make pre-processe functions
ims = imresize(I, [512 512]);
imf = rgb2gray(ims);
% waitbar sets
h = waitbar(0,'Please wait...','Name','Image Filtering');
steps = 3;
for i = 1:3
    imf(:,:,i) = medfilt2(ims(:,:,i),[4,5]);
     waitbar(i / steps)
end
close(h);

flt = warndlg('Filter completed.','Filtering');
uiwait(flt);

%% liver segmentation

axes(handles.axes_show);
imshow(imf)
set(handles.imageview_filtered,'enable','on');

%% segmentation message box
set(handles.edit_fromthreshlimit,'enable','off');

h = impoly();

mbsl = warndlg('Cutting Liver may take a few minutes to segment','Liver Cut');
uiwait(mbsl);

m = createMask(h);

lit = get(handles.edit_fromthreshlimit,'String');
lit = checkInputForValidNumber(lit);
if lit == -1
    warndlg('iteration must be in a positive integer range.');
    return;
end

seg = localized_seg(imf, m, lit);  %-- run segmentation

elt = warndlg('Segment completed.','Segmentation');
uiwait(elt);
%% extracted liver
seg(:,:,2) = seg;
seg(:,:,3) = seg(:,:,1);
% 5) Use logical indexing to set area outside of ROI to zero:
liver = imf;
liver(seg == 0) = 0;

%% set button
set(handles.imageview_liver,'enable','on');
set(handles.clustersize,'enable','on');
set(handles.max,'enable','on');
set(handles.tumorstage_run,'enable','on');
set(handles.uselab,'enable','on');
set(handles.clear_variables,'enable','on');


%% --- Executes on button press in load_image.
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global I ims

%% get image
[name,path]=uigetfile('*.jpg','select a input image');
path=strcat(path,name);
I=imread(path);
axes(handles.axes_input);
imshow(I), title('Input image');
ims = imresize(I, [512 512]);
axes(handles.axes_show);
imshow(ims), title('Original image');

%% set button
set(handles.start_basiccalculations,'enable','on');
set(handles.edit_fromthreshlimit,'enable','on');
set(handles.imageview_original,'enable','on');
set(handles.clear_variables,'enable','off');

%% --- Executes on button press in clear_variables.
function clear_variables_Callback(hObject, eventdata, handles)
% hObject    handle to clear_variables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% button enable off 
set(handles.start_basiccalculations,'enable','off');
set(handles.imageview_original,'enable','off');
set(handles.imageview_filtered,'enable','off');
set(handles.imageview_filtered,'enable','off');
set(handles.imageview_liver,'enable','off');
set(handles.imageview_cluster,'enable','off');
set(handles.imageview_tumor,'enable','off');
set(handles.boundary_tumor,'enable','off');
set(handles.tumorstage_run,'enable','off');
set(handles.setas_tumor,'enable','off');
set(handles.uselab,'enable','off');
set(handles.showcluster,'enable','off');
set(handles.popupmenu_area,'enable','off');


%% default string
set(handles.text_connectedtumor, 'string', '----');
set(handles.text_percentage, 'string', '----');
set(handles.text_totalarea, 'string', '----');
set(handles.edit_fromthreshlimit, 'enable', 'off');
set(handles.edit_fromthreshlimit, 'string', '20');
set(handles.clustersize, 'enable', 'off');
set(handles.clustersize, 'string', '7');
set(handles.max, 'enable', 'off');
set(handles.max, 'string', '3');


%% axes

cla(handles.axes_show);
set(handles.axes_show, 'Visible', 'on');
set(handles.axes_show, 'XTick',[],'YTick',[]);
set(handles.axes_show, 'title', 'default');

cla(handles.axes_tumor);
set(handles.axes_tumor, 'Visible', 'on');
set(handles.axes_tumor, 'XTick',[],'YTick',[]);
set(handles.axes_tumor, 'title', 'default');

cla(handles.axes_kmean);
set(handles.axes_kmean, 'Visible', 'on');
set(handles.axes_kmean, 'XTick',[],'YTick',[]);
set(handles.axes_kmean, 'title', 'default');

cla(handles.axes_input);
set(handles.axes_input, 'Visible', 'on');
set(handles.axes_input, 'XTick',[],'YTick',[]);
set(handles.axes_input, 'title', 'default');


function edit_fromthreshlimit_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fromthreshlimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fromthreshlimit as text
%        str2double(get(hObject,'String')) returns contents of edit_fromthreshlimit as a double


% --- Executes during object creation, after setting all properties.
function edit_fromthreshlimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fromthreshlimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in imageview_original.
function imageview_original_Callback(hObject, eventdata, handles)
% hObject    handle to imageview_original (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ims

axes(handles.axes_show);
imshow(ims), title('Original image');

% --- Executes on button press in imageview_liver.
function imageview_liver_Callback(hObject, eventdata, handles)
% hObject    handle to imageview_liver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global liver
   
axes(handles.axes_show);
imshow(liver), title('Liver image');

% --- Executes on button press in imageview_cluster.
function imageview_cluster_Callback(hObject, eventdata, handles)
% hObject    handle to imageview_cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global  coloredLabels

axes(handles.axes_show);
imshow(coloredLabels), title('Clustering image');

% --- Executes on button press in imageview_filtered.
function imageview_filtered_Callback(hObject, eventdata, handles)
% hObject    handle to imageview_filtered (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imf
    
axes(handles.axes_show);
imshow(imf), title('Filter image');


% --- Executes on button press in imageview_tumor.
function imageview_tumor_Callback(hObject, eventdata, handles)
% hObject    handle to imageview_tumor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global extim imf tumorim

el = extim;
el(:,:,2) = el;
el(:,:,3) = el(:,:,1);
% 5) Use logical indexing to set area outside of ROI to zero:
tumorim = imf;
tumorim(el == 0) = 0;
axes(handles.axes_show);
imshow(tumorim), title('Tumor image');


% --- Executes on button press in boundary_tumor.
function boundary_tumor_Callback(hObject, eventdata, handles)
% hObject    handle to boundary_tumor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Bt liver


axes(handles.axes_show);
imshow(liver), title('Boundary image');
hold on
visboundaries(Bt);

% --- Executes on button press in tumorstage_run.
function tumorstage_run_Callback(hObject, eventdata, handles)
% hObject    handle to tumorstage_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global liver
handles.output = hObject;
handles.AxesHasAnImage = 1;

if handles.AxesHasAnImage ~= 1 % if no image is loaded, show error & return. 
    warndlg('You have to select an image.')
    return;
end

clusterSize = get(handles.clustersize,'String');
clusterSize = checkInputForValidNumber(clusterSize);
if clusterSize == -1
    warndlg('Cluster Size must be in a positive integer range.');
    return;
end

maximumIteration = get(handles.max,'String');
maximumIteration = checkInputForValidNumber(maximumIteration);
if maximumIteration == -1
    warndlg('Cluster Size must be in a positive integer range.');
    return;
end

handles.segmentedImages = kMeans(liver, clusterSize, maximumIteration, handles, hObject);
handles.ImageHasBeenSegmented = 1;
guidata(hObject, handles);

set(handles.imageview_cluster,'enable','on');
set(handles.setas_tumor,'enable','on');

function clustersize_Callback(hObject, eventdata, handles)
% hObject    handle to clustersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clustersize as text
%        str2double(get(hObject,'String')) returns contents of clustersize as a double


% --- Executes during object creation, after setting all properties.
function clustersize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clustersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_Callback(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max as text
%        str2double(get(hObject,'String')) returns contents of max as a double


% --- Executes during object creation, after setting all properties.
function max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in showcluster.
function showcluster_Callback(hObject, eventdata, handles)
% hObject    handle to showcluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns showcluster contents as cell array
%        contents{get(hObject,'Value')} returns selected item from showcluster

global cluster pixel_labels

handles.output = hObject;
cluster = get(handles.showcluster, 'Value');
axes(handles.axes_tumor);

if cluster == 1
    coloredLabels = label2rgb(pixel_labels);
    imshow(coloredLabels,[]), title('All Clusters');
else
    titleForImg = sprintf('Cluster : %d', cluster-1);
    imshow(handles.segmentedImages{cluster},[]), title(titleForImg);
        

end


% --- Executes during object creation, after setting all properties.
function showcluster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showcluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uselab.
function uselab_Callback(hObject, eventdata, handles)
% hObject    handle to uselab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uselab


% --- Executes on button press in setas_tumor.
function setas_tumor_Callback(hObject, eventdata, handles)
% hObject    handle to setas_tumor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global extim  Bt  totalpixt liver 

clim = get(handles.showcluster, 'Value');
if clim == 1 || clim == 2
    warndlg('unavailable, please check another no.');
    return;
end
extim = handles.segmentedImages{clim};

%% basic calculations

% tumor area
tim = extim;
[T, n] = bwlabel(tim);
tumor = regionprops(T);
% make a list of all areas
areast = cat(1, tumor(:).Area);
totalpixt = sum(areast);
set(handles.text_totalarea, 'String', totalpixt);

set(handles.text_connectedtumor, 'String', n);

%% tumor percentage
bwl = im2bw(liver);
[L, m] = bwlabel(bwl);
liv = regionprops(L);
% make a list of all areas
areasl = cat(1, liv(:).Area);
totalpixl = sum(areasl);
if totalpixt == 0
    set(handles.text_percentage, 'String', '0');
else
    percent = ((totalpixt / totalpixl) * 100);
    set(handles.text_percentage, 'String', percent);
end


%% set boundary
t_stage = tim;
 [Bt,L,N,D] = bwboundaries(t_stage);
 
 %% set button
set(handles.popupmenu_area,'enable','on');
set(handles.imageview_tumor,'enable','on');
set(handles.boundary_tumor,'enable','on');
guidata(hObject, handles);


%% --- Executes on selection change in popupmenu_area.
function popupmenu_area_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_area contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_area

global totalpixt totalcmt totalmmt

%% set options
calibrationFactor = 21/2100;
totalcmt = (totalpixt * (calibrationFactor ^ 2));
%totalmmt = (totalcmt)^2;
totalmmt = (totalcmt) * 100;
contents = get(hObject,'Value');

%% switch case
switch contents
    case 1
        totalR = totalpixt;
        set(handles.text_totalarea, 'String', totalR);
        drawnow();
    case 2
        totalR = totalcmt;
        set(handles.text_totalarea, 'String', totalR);
    case 3
        totalR = totalmmt; 
        set(handles.text_totalarea, 'String', totalR);
    otherwise
end


%% --- Executes during object creation, after setting all properties.
function popupmenu_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
