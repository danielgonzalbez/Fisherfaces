function varargout = faces(varargin)
% FACES MATLAB code for faces.fig
%      FACES, by itself, creates a new FACES or raises the existing
%      singleton*.
%
%      H = FACES returns the handle to a new FACES or the handle to
%      the existing singleton*.
%
%      FACES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACES.M with the given input arguments.
%
%      FACES('Property','Value',...) creates a new FACES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before faces_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to faces_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help faces

% Last Modified by GUIDE v2.5 28-Dec-2022 09:56:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @faces_OpeningFcn, ...
                   'gui_OutputFcn',  @faces_OutputFcn, ...
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
end

% --- Executes just before faces is made visible.
function faces_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to faces (see VARARGIN)
    % Choose default command line output for faces
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);

    fig = uifigure;
    message = {'Initializing the system. It may take a few minutes. This message will be automatically closed when the process finishes.'};
    uialert(fig,message,'Warning', 'icon', 'info');
    pause(7);
    
    % Set up all bottons
    set(hObject, 'Color', [0.8, 0.8, 0.8]);

    set(handles.select_image, 'String', 'Select image');
    set(handles.select_image, 'FontName', 'Verdana');
    set(handles.select_image, 'FontSize', 12);

    set(handles.select_random, 'String', 'Select random image');
    set(handles.select_random, 'FontName', 'Verdana');
    set(handles.select_random, 'FontSize', 12);

    set(handles.identify, 'String', 'Identify subject');
    set(handles.identify, 'FontName', 'Verdana');
    set(handles.identify, 'FontSize', 12);

    set(handles.save_image, 'String', 'Add images of the subject:');
    set(handles.save_image, 'FontName', 'Verdana');
    set(handles.save_image, 'FontSize', 12);

    set(handles.text_pred, 'String', ''); % In the beginning, no prediction.
    set(handles.text_pred, 'FontName', 'Verdana');
    set(handles.text_pred, 'FontSize', 14);
    set(handles.text_pred, 'BackgroundColor', [0.8 0.8 0.8]);

    set(handles.title, 'String', 'FACIAL RECOGNITION SYSTEM');
    set(handles.title, 'FontName', 'Verdana');
    set(handles.title, 'FontSize', 20);
    set(handles.title, 'FontWeight', 'bold');
    set(handles.title, 'BackgroundColor', [0.8 0.8 0.8]);


    set(handles.text_slider, 'String', 'Level of significance: 2000');
    set(handles.text_slider, 'FontName', 'Verdana');
    set(handles.text_slider, 'FontSize', 12);
    set(handles.text_slider, 'BackgroundColor', [0.8 0.8 0.8]);

    set(handles.help_button, 'String', 'Help');
    set(handles.help_button, 'FontName', 'Verdana');
    set(handles.help_button, 'FontSize', 12);
    
    set(handles.close_button, 'String', 'Close');
    set(handles.close_button, 'FontName', 'Verdana');
    set(handles.close_button, 'FontSize', 12);

    handles.threshold = 2000;
    [handles.X_train, handles.X_test, handles.y_train, handles.y_rev] = read_images();
    handles.eigvecs_pca = pca(handles); % 6400 x n_factors    
    eigvecs_lda = lda(handles); % n_factors x n_factors_lda, don't need to save it in handles
    handles.eigvecs = handles.eigvecs_pca * eigvecs_lda; % 6400 x n_factors_lda (number of fisherfaces);
    handles.weights_train = handles.eigvecs' * handles.X_train; % n_factors_lda x n
    close(fig);
    guidata(hObject, handles);
end

% UIWAIT makes faces wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = faces_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in select_image.
function select_image_Callback(hObject, eventdata, handles)
% hObject    handle to select_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [filename, path] = uigetfile( '*.jpg; *JPG; *.png; *.PNG');
    switch class(filename) 
        case 'double' % if there is no selection, the filename is a double = 0
            return
        otherwise
            matrix = imread(strcat(path, filename));
            matrix = rgb2gray(matrix);
            matrix = imresize(matrix, [80 80]);
            axes(handles.axes1);
            imshow(uint8(matrix));
            handles.current_img = double(reshape(matrix, 80*80, 1)); % flatten the image, transform it to double and save it
            guidata(hObject, handles);
    end
end

% --- Executes on button press in select_random.
function select_random_Callback(hObject, eventdata, handles)
% hObject    handle to select_random (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    test_idx = randi([1 size(handles.X_test,2)], 1, 1);
    handles.current_img = handles.X_test(:,test_idx); % save it in case it has to be identified
    axes(handles.axes1);
    imshow(uint8(reshape(handles.X_test(:,test_idx), 80, 80))); % in handles: X_test is of type double
    guidata(hObject, handles);
end

% --- Executes on button press in identify.
function identify_Callback(hObject, eventdata, handles)
% hObject    handle to identify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    X_test = handles.current_img;
    weights_test = handles.eigvecs' * X_test; % n_factors_lda x n_test_images
    [m, idx] = min(sqrt(sum((handles.weights_train - weights_test).^2,1)));
    if m < handles.threshold
        pred = handles.y_rev(idx);
        axes(handles.axes2);
        imshow(uint8(reshape(handles.X_train(:,idx), 80, 80)));
        set(handles.text_pred, 'String', ['Subject: ' num2str(pred)]);
    else
        axis off;
        axes(handles.axes2);
        imshow(uint8(zeros(80, 80)));
        set(handles.text_pred, 'String', 'No match found');
    end
end

% --- Executes on button press in save_image.
function save_image_Callback(hObject, eventdata, handles)
% hObject    handle to save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    subj = get(handles.list_ids, 'Value'); % returns a number
    [filenames, path] = uigetfile( '*.jpg; *JPG; *.png; *.PNG', 'MultiSelect', 'on');
    switch class(filenames)
        case 'double'
            return % if there is no selection, a 0 is returned -> exit the function
        case 'char' % one image selected
            n = 1;
        case 'cell' % multiple images selected
            n = size(filenames, 2);
    end
    fig = uifigure;
    message = {'Saving the images... This message will be automatically closed when the process is finished.'};
    uialert(fig,message,'Warning', 'icon', 'info');
    pause(3); % to give time to the message to be displayed
    n_im = size(handles.X_train, 2);
    for i = 1:n
        if n > 1
            matrix = imread(strcat(path, filenames{i}));
        else
            matrix = imread(strcat(path, filenames));
        end
        matrix = rgb2gray(matrix);
        matrix = imresize(matrix, [80 80]);
        flat_matrix = double(reshape(matrix, 80*80, 1));
        handles.X_train = [handles.X_train flat_matrix];
    end
    if subj > size(handles.y_train, 1) % New subject
        handles.y_train{subj} = n_im + (1:n);
        set(handles.list_ids, 'String', split(strcat(num2str(1:subj), ' New'))); 
    else
        handles.y_train{subj} = [handles.y_train{subj} n_im + (1:n)];
    end
    handles.y_rev = [handles.y_rev' repelem(subj, n)]';
    guidata(hObject, handles);
    
    handles.eigvecs_pca = pca(handles); % 6400 x n_factors    
    eigvecs_lda = lda(handles); % n_factors x n_factors_lda, no need to save them in handles
    handles.eigvecs = handles.eigvecs_pca * eigvecs_lda; % 6400 x n_factors_lda (number of fisherfaces);
    handles.weights_train = handles.eigvecs' * handles.X_train; % n_factors_lda x n
    close(fig); 
    guidata(hObject, handles);
end

function eigvecs = compute_eigvecs(A)
    [eigvecs, eigvals] = eig(A); % eigenvalues are not sorted
    eigvals = diag(eigvals);
    [eigvals, idx] = sort(eigvals, 'descend');
    eigvecs = eigvecs(:, idx);
    eigvals = eigvals(idx);
    var = 0;
    total_var = sum(eigvals);
    n_factors = 1;
    while var < 0.95 * total_var
        var = var + eigvals(n_factors);
        n_factors = n_factors + 1;
    end
    eigvecs = eigvecs(:, 1:n_factors);
end



function eigvecs_lda = lda(handles)
    X = handles.X_train;
    y = handles.y_train;
    eigvecs_pca = handles.eigvecs_pca;
    Sb = zeros(80*80, 80*80); % scatter between classes
    n_classes = size(y, 1);
    mean_global = mean(X, 2);
    Sw = zeros(80*80, 80*80); % scatter within classes
    for i = 1:n_classes
        mean_class = mean(X(:, y{i}), 2);
        Sb = Sb + size(y{i},2) * (mean_class - mean_global) * (mean_class - mean_global)';
        Sw = Sw + (X(:, y{i}) - mean_class) * (X(:, y{i}) - mean_class)';
    end
    Sw = eigvecs_pca' * Sw * eigvecs_pca;
    Sb = eigvecs_pca' * Sb * eigvecs_pca;
    eigvecs_lda = compute_eigvecs(Sb/Sw);   
end


function eigvecs_pca = pca(handles)
    X = handles.X_train;
    n = size(X,2);
    C = 1/n * (X -mean(X,2)) * (X-mean(X,2))'; % covariance matrix of the centered data
    eigvecs_pca = compute_eigvecs(C);
end

function [images_train, images_test, y, y_rev] = read_images()
    % Read images from archive and store them in two matrices (test and train)
    files = dir('data/subject*');
    L = length(files);
    n_ind = L/11; % number of individuals in the dataset
    images_train = zeros(80*80, L-n_ind); % preallocate: each column is an image
    y = cell(n_ind, 1); % position i contains the indexes of class i
    y_rev = zeros(L-n_ind,1); % position i contains the class of i
    images_test = zeros(80*80, n_ind); % preallocate: each column is an image
    test_idx = randi([1 11], 1, n_ind); % indexes of the test set
    k = 1;
    train_idx = 1;
    for i = 1:n_ind
        idx = test_idx(i); % index j of the test image of the individual i
        for j = 1:11
            matrix = imread(strcat('data/' , files(k).name));
            matrix = imresize(matrix, [80 80]);
            flat_mat = reshape(matrix, 80*80, 1);
            switch j
                case idx
                    images_test(:,i) = flat_mat;
                otherwise
                    images_train(:,train_idx) = flat_mat;
                    y{i} = [y{i}, train_idx];
                    y_rev(train_idx) = i;
                    train_idx = train_idx + 1;
            end
            k = k + 1;
        end
    end
end




% --- Executes on selection change in list_ids.
function list_ids_Callback(hObject, eventdata, handles)
% hObject    handle to list_ids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_ids contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_ids
end
% --- Executes during object creation, after setting all properties.
function list_ids_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_ids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set(hObject, 'String', split(strcat(num2str(1:15), ' New'))); 
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on slider movement.
function threshold_slider_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.threshold = round(get(hObject, 'Value'));
    set(handles.text_slider, 'String', "Level of significance: " + num2str(handles.threshold));
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function threshold_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

    set(hObject, 'Min', 500);
    set(hObject, 'Max', 4000);
    set(hObject, 'Value', 2000);
    set(hObject, 'SliderStep', [1/(4000-500) 10/(4000-500)]);
end


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    msg1 = ['This is a facial recognition system.'];
    msg2 = [newline newline 'In the beginning, there are 10 images of 15 subjects.'];
    msg3 = [newline newline 'You can select a random image from a set of 15 images (1 of each of the subjectes registered) to be identified.'];
    msg4 = [newline newline 'You can try to identify an own image, but take into account it will be processed as an 80x80 grayscale picture.'];
    msg5 = [newline newline 'You can add to the database many images of the same subject at once. Make sure you do it with the correct ID of the subject selected.'];
    msg6 = [newline newline 'You can change the level of similarity that the system requires to find a match.'];
    help_box = msgbox(strcat(msg1, msg2, msg3,msg4,msg5,msg6), "Help", "help");
    set(help_box,'Position',[600.0000  500.0000  600.5000   300.2500])
    set(help_box,'Color',[0.8, 0.8, 0.8])

    th = findall(help_box, 'Type', 'Text');   
    th.FontSize = 12;
    th.FontName = "Verdana";
end


% --- Executes on button press in close_button.
function close_button_Callback(hObject, eventdata, handles)
% hObject    handle to close_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close all;
end
