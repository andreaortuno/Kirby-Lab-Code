% Extract features from image stack
% copied from extract_features_from_objects_20161016.m
% 
% see pseudocode_outline for where in analysis this function should be run
% 
% Versioning::
% 20181016: initial version

function extract_features_from_objects()

% Binary image stack info
img_info.bwdir = 'K:\jh2363\MPC index\Benchmarking and testing\Custom MATLAB\method comparison data';% directory
img_info.bwfile = 'JACK_BxPC3_BxGR80C_BxGR360C_4methodcomparison_hdome-sauvola_kmeans20_h0-10_sw25_st0-005_stack'; % file name
[BWstack] = get_image_stack_info(img_info.bwdir,img_info.bwfile);

% Intensity image stack info (images should be 16-bit unsigned integers)
img_info.intdir = 'K:\jh2363\MPC index\Benchmarking and testing'; % directory
img_info.intfile = 'BxPC3_BxGR80C_BxGR360C_4methodcomparison'; % file name
[INTstack] = get_image_stack_info(img_info.intdir,img_info.intfile);

% Load image stacks and extract features from each object
[starting_features , data_andrea] = load_images_extract_features( BWstack, INTstack, {'Haralick','GaussCorr','HausDist','Morphological', 'Intensity', 'GradientIntensity'});

% Throw error if any features have 0 variance
if any( var(starting_features.values)==0 )
    novar_names = starting_features.names( var(starting_features.values)==0 );
    strErr = sprintf('Some features have ZERO variance: %s \n', novar_names);
    error(strErr);
end

% Save the starting feature
save_dir = 'K:\aio23';
save_name = sprintf('extracted_features_from_objects_%s.mat',date);
save(fullfile(save_dir,save_name), 'starting_features', 'img_info', 'data_andrea');

end


function [ImStack] = get_image_stack_info(lookdir, lookstack)

file_list = dir( fullfile(lookdir,'*.tif') ); % list of tifs in dir
tif_list  = file_list( ~cellfun('isempty', regexp( {file_list.name}, lookstack )) ) ; % finds files of interest
if length(tif_list)>1, 
    error('More than 1 tif with string ''%s''',lookstack); 
end
ImStack.filename = fullfile(lookdir, tif_list.name) ;
ImStack.info = imfinfo( ImStack.filename );

end


function [features, andrea_data] = load_images_extract_features(bw_stack, int_stack, feature_list)
BWinfo = bw_stack.info;
INTinfo = int_stack.info;

if [numel(BWinfo(1)), BWinfo(1).Width, BWinfo(1).Height] ~= ...
        [numel(INTinfo(1)), INTinfo(1).Width, INTinfo(1).Height]
    error('Stacks not same slices or image sizes');
end

tic
num_images = numel(BWinfo);
feature_values = cell(1,num_images);
spots_indexes = cell(1,num_images);
object_thumbnails = cell(size(feature_values));
object_outlines = cell(size(feature_values));
for ii=1:num_images
    % load images
    binary_map = imread( bw_stack.filename, ii, 'Info', BWinfo );
    if ~any(binary_map(:))
        disp('No objects found');
        continue
    end
    intensity_map = imread( int_stack.filename, ii, 'Info', INTinfo );
    intensity_map = RescaleImage( intensity_map, 2^INTinfo(1).BitDepth-1 );
    % extract features
    [feature_values{ii}, temp_names, object_thumbnails{ii}, object_outlines{ii}, spots_indexes{ii}] = ...
        extract_features_from_spots_20181013( binary_map, intensity_map, feature_list, bw_stack.filename) ;

    fprintf('Extracted features: image %1.0f of %3.0f, time = %3.1f \n', ii, num_images, toc );
end
% label samples as belonging to an image
features.image_group = uint16( cell2mat(arrayfun(@(x,y) repmat(x,y,1), 1:length(feature_values), cellfun('size', feature_values, 1), 'Uni',false)'))';
features.values = cell2mat( reshape(feature_values,[],1) ) ;
features.thumbnails = [object_thumbnails{:}] ;
features.outlines = [object_outlines{:}] ;
features.names = temp_names ;

andrea_data = spots_indexes ;

feat_timer=toc;
fprintf( 'time to extract %2.0f features from all spots = %3.1f sec \ntime per spot = %1.4f sec \n', ...
    size(features.values,2), feat_timer, feat_timer/size(features.values,1));


end

%% rescale image to floating point range [0 1]

function [I]   = RescaleImage( I, varargin )

I   = double(I);
I   = I - min(I(:)) ;

if nargin<2
    plotopt = 'noplot';
    max_val = max(I(:)) ;
elseif ischar(varargin{1})
    plotopt     = varargin{1};
    strTitle    = varargin{2};
    max_val = max(I(:)) ;
else
    plotopt = 'noplot';
    max_val = varargin{1} - min(I(:));
end


I   = I ./ max_val ;

if strcmp(plotopt,'plot')
    figure, imshow(I,[]); title(strTitle); 
end

end