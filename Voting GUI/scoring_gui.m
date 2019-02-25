function varargout = scoring_gui(varargin)
% SCORING_GUI MATLAB code for scoring_gui.fig
%      SCORING_GUI, is a script that overlays two different binary masks on
%      an user selected background for comparisson. 
%      
%      The user selects three different files. The first one is a stack of
%      images that will be displayed as background. The second and third
%      images are two binary masks to compare.
%      
%      The user then selects what mask best describes the feature they are
%      looking for. Once a selection is made, the user can display a bar
%      graph with the frequency in which each masks was selected, by
%      clicking on display result. In addition a variable "Masks_Selected"
%      is stored. This variable is an array that specifies the mask that
%      was selected for each specific image.
%      
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% Last Modified by GUIDE v2.5 22-Aug-2018 19:54:51


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scoring_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @scoring_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && isempty(strfind(varargin{1},'.tif'))
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before scoring_gui is made visible.
function scoring_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scoring_gui (see VARARGIN)

if numel(varargin)>0 % if running GUI from Main.m
    bkg_filename = 'BxPC3_BxGR80C_BxGR360C_4methodcomparison.tif' ;
    bkg_path = cd ;
    mask1_filename = varargin{1};
    mask1_path = cd ;
    mask2_filename = varargin{2};
    mask2_path = cd ;
else
    [bkg_filename,bkg_path] = uigetfile('.tif','Select Background file');
    [mask1_filename,mask1_path] = uigetfile('.tif','Select Mask 1 file');
    [mask2_filename,mask2_path] = uigetfile('.tif','Select Mask 2 file');
end

handles.num_images = numel(imfinfo( fullfile(bkg_path, bkg_filename) ));
indx = 1:handles.num_images;
handles.image_idx = indx(randperm(length(indx)));
handles.k = 1;
handles.colors = ['g', 'r'];
handles.colors = handles.colors(randperm(length(handles.colors)));

handles.bkg_name = fullfile(bkg_path, bkg_filename);
handles.mask1_name = fullfile(mask1_path, mask1_filename);
handles.mask2_name = fullfile(mask2_path, mask2_filename);
handles.results = zeros(1, handles.num_images);

[img2display] = masks_selection(hObject, eventdata, handles);
axes(handles.image_display);
imshow(img2display);
% Choose default command line output for scoring_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes scoring_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = scoring_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_red.
function button_red_Callback(hObject, eventdata, handles)
% hObject    handle to button_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
red_pos = find(handles.colors == 'r');

handles.results(handles.image_idx(handles.k)) = red_pos;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in button_green.
function button_green_Callback(hObject, eventdata, handles)
% hObject    handle to button_green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
green_pos = find(handles.colors == 'g');

handles.results(handles.image_idx(handles.k)) = green_pos;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in red_radio.
function red_radio_Callback(hObject, eventdata, handles)
% hObject    handle to red_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old_xlim = handles.image_display.XLim;
old_ylim = handles.image_display.YLim;

[img2display] = masks_selection(hObject, eventdata, handles);
axes(handles.image_display);
imshow(img2display);

zoom RESET
handles.image_display.XLim = old_xlim;
handles.image_display.YLim = old_ylim;

% Hint: get(hObject,'Value') returns toggle state of red_radio
guidata(hObject, handles);


% --- Executes on button press in green_radio.
function green_radio_Callback(hObject, eventdata, handles)
% hObject    handle to green_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old_xlim = handles.image_display.XLim;
old_ylim = handles.image_display.YLim;

[img2display] = masks_selection(hObject, eventdata, handles);
axes(handles.image_display);
imshow(img2display);

zoom RESET
handles.image_display.XLim = old_xlim;
handles.image_display.YLim = old_ylim;

% Hint: get(hObject,'Value') returns toggle state of green_radio
guidata(hObject, handles);


%Function to check what masks to display
function [img2display] = masks_selection(hObject, eventdata, handles)

bkg_image = adapthisteq(mat2gray(imread(handles.bkg_name, handles.image_idx(handles.k))));
mask1 = imread(handles.mask1_name, handles.image_idx(handles.k));
mask2 = imread(handles.mask2_name, handles.image_idx(handles.k));

%creates cell array with masks
masks = {mask1, mask2};

%create a cell array with specifications for each color 
color_map = containers.Map({'r', 'g'},{'autumn', 'summer'});
brighten(0.8);

%randomize which mask is which color
random_order = [1,2];
random_order = random_order(randperm(length([1,2])));

[img2display] = bkg_image;

%get radio buttons status in order to determine which masks to display.
radio_status = [[get(handles.red_radio, 'Value'), get(handles.green_radio, 'Value')], 
    [find(handles.colors == 'r'), find(handles.colors == 'g')]];
for i = 1:2
    indx = find(radio_status(2,:) == random_order(i));
    if radio_status(1, indx) == 1
        % 'labeloverlay' introduced in Matlab R2017b
        if verLessThan('matlab', '9.3') && ~isempty(which('imOverlay'))
            % imoverlay burns the colors to the background image (no
            % transparency)
            [img2display] = imOverlay(img2display, masks{random_order(i)}, handles.colors(random_order(i)));
        elseif verLessThan('matlab', '9.3') && isempty(which('imOverlay'))
            err = strcat('Your Matlab does not contain the functions required for image overlays. ', ...
                'Either update Matlab to at least R2017b or download imOverlay from File Exchange ', ...
                '(https://www.mathworks.com/matlabcentral/fileexchange/28827-imoverlay)');
            error(err);
        else
            %display the masks on top of the background image transparently
            if nnz(masks{random_order(i)})~=0 %|| ~isempty(masks{random_order(i)}) % breaks when nothing was segmented
                [img2display] = labeloverlay(img2display, bwperim(masks{random_order(i)}), ...
                    'Colormap', color_map(handles.colors(random_order(i))), 'Transparency', .3);
            end
        end
    end
end

image_pos = sprintf('Image %d of %d', handles.k, handles.num_images);
set(handles.text1, 'String', image_pos);

guidata(hObject, handles);

% --- Executes on button press in back_button.
function back_button_Callback(hObject, eventdata, handles)
% hObject    handle to back_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.k ~= 1
    handles.k = handles.k - 1;
    handles.colors = handles.colors(randperm(length(handles.colors)));
    [img2display] = masks_selection(hObject, eventdata, handles);
    axes(handles.image_display);
    imshow(img2display);
elseif handles.k == 1
    msgbox('There are no more images to display.')
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in result_button.
function result_button_Callback(hObject, eventdata, handles)
% hObject    handle to result_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','Masks_Selected', handles.results)
figure
hold on
title('Masks Selected')
ylabel('Times selected')
bar(categorical({'mask 1', 'mask 2'}), [sum(handles.results == 1), sum(handles.results == 2)])
hold off
guidata(hObject, handles);

% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.results(handles.image_idx(handles.k)) == 0
    msgbox('You have not selected a mask')
elseif handles.k ~= handles.num_images
    handles.k = handles.k + 1;
    handles.colors = handles.colors(randperm(length(handles.colors)));
    [img2display] = masks_selection(hObject, eventdata, handles);
    axes(handles.image_display);
    imshow(img2display);
elseif handles.k == handles.num_images 
    msgbox('There are no more images to display.')
end
% Update handles structure
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','Masks_Selected', handles.results)

% Hint: delete(hObject) closes the figure
delete(hObject);
