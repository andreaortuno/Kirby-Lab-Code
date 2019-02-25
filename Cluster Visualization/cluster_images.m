function [masks_clusters] = cluster_images(data, clusters, i_group)
    tifdir = 'K:\jh2363\MPC index\Benchmarking and testing'; % directory
    tiffile = 'BxPC3_BxGR80C_BxGR360C_4methodcomparison.tif'; % file name
    
    all_spots = [double(i_group).' , clusters];
    count = 0;
    spot_num = [];
    %create master matrix to pull all data from
    for i = 1:length(data)
        spot_num = [spot_num, [data{i}{:,2}]];
        for j = 1:length(data{i})
            data{i}{j,4} = all_spots(j+count,1:2);
        end
        count = count + length(data{i});
    end
    all_spots = [all_spots, spot_num.'];
    %all_spots(2,:)
    %make binary masks for all clusters
    masks = cell(length(unique(clusters)),1);
    for i = 1:length(unique(clusters))
        masks{i} = zeros(2048, 2048, length(data));  
    end
    
    
    for i = 1:length(unique(clusters))  
        cluster_spots_indx = clusters == i;
        cluster_spots = all_spots(cluster_spots_indx,:);
        for j = 1:length(cluster_spots)
            pixels2paint = data{cluster_spots(j,1)}{cluster_spots(j,3),3};
            [l,w] = size(pixels2paint);
            for k = 1:l
                masks{i}(pixels2paint(k,1), pixels2paint(k,2), cluster_spots(j,1)) = 1;
            end
        end
    end
    
    masks_clusters = masks;
    
    im_name = [tifdir, '\', tiffile];
    num_images = numel(imfinfo(im_name));
    
    colors = [[230, 25, 75]; [60, 180, 75]; [255, 225, 25]; [0, 130, 200]; [245, 130, 48]; [145, 30, 180]; [70, 240, 240]; [240, 50, 230]; [210, 245, 60]; [250, 190, 190]; [0, 128, 128]; [230, 190, 255]; [170, 110, 40]; [255, 250, 200]; [128, 0, 0]; [170, 255, 195]; [128, 128, 0]; [255, 215, 180]];
    colors = colors/ 255;
    for m = 1:num_images
       image =  adapthisteq(mat2gray(imread(im_name, m)));
       for ii = 1:length(unique(clusters))
           image = imoverlay(image, boundarymask(masks{ii}(:,:,m).'), colors(ii,:));
       end
       if m == 1
           imwrite(image,'clusters_overlayed.tif');
       else
           imwrite(image,'clusters_overlayed.tif','WriteMode','append');
       end
    end
end

