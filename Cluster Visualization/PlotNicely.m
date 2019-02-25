function y = PlotNicely()
    tifdir = 'K:\jh2363\MPC index\Benchmarking and testing'; % directory
    tiffile = 'BxPC3_BxGR80C_BxGR360C_4methodcomparison.tif'; % file name
    im_name = [tifdir, '\', tiffile];
    masks = 'clusters_overlayed.tif';
    im_num = 15;
    colors = [[230, 25, 75]; [60, 180, 75]; [255, 225, 25]; [0, 130, 200]; [245, 130, 48]; [145, 30, 180]; [70, 240, 240]; [240, 50, 230]; [210, 245, 60]; [250, 190, 190]; [0, 128, 128]; [230, 190, 255]; [170, 110, 40]; [255, 250, 200]; [128, 0, 0]; [170, 255, 195]; [128, 128, 0]; [255, 215, 180]];
    colors = colors/ 255;

    imshow(imread(masks, im_num));
    hold on
    plot(0,0,'Color',colors(1,:),'LineWidth', 2)
    plot(0,0,'Color',colors(2,:),'LineWidth', 2)
    plot(0,0,'Color',colors(3,:),'LineWidth', 2)
    plot(0,0,'Color',colors(4,:),'LineWidth', 2)
    plot(0,0,'Color',colors(5,:),'LineWidth', 2)
    plot(0,0,'Color',colors(6,:),'LineWidth', 2)
    plot(0,0,'Color',colors(7,:),'LineWidth', 2)
    hold off
    legend('cluster 1', 'cluster 2', 'cluster 3', 'cluster 4', 'cluster 5', 'cluster 6', 'cluster 7', 'Location', 'SouthEast')
    %title(sprintf('Clusters in stack image %d', im_num))
    title("Spot clusters on flourescent image")
end