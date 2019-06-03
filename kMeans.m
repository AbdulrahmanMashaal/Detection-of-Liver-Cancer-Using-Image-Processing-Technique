function segmented_images = kMeans(img, clusterSize, maxIt, handles, hObject)
set(handles.showcluster,'value',1);
set(handles.showcluster,'enable','off');
use_lab = get(handles.uselab, 'Value');
image_is_in_gray_scale = size(img, 3);

nrows = size(img,1);
ncols = size(img,2);
if image_is_in_gray_scale == 1
    ab = double(img(:));
    ab = reshape(ab,nrows*ncols,1);
else %if image is not on grayscale
    ab = double(img(:,:,:));
     if use_lab %if CIELAB usage is enabled
        cform = makecform('srgb2lab');
        img = applycform(img,cform);
        ab = double(img(:,:,:));
        ab = reshape(ab,nrows*ncols,3);
    else
        ab = reshape(ab,nrows*ncols,3);
     end
end
global pixel_labels coloredLabels
cluster_idx = kmeans(ab,clusterSize,'distance','sqEuclidean', ...
                                      'Replicates',maxIt);
pixel_labels = reshape(cluster_idx,nrows,ncols);
axes(handles.axes_kmean);
coloredLabels = label2rgb(pixel_labels);
imshow(coloredLabels,[]), title('All Clusters');
segmented_images = cell(1, clusterSize+1); % +1 is to piggyback clusteridx
segmented_images{1} = pixel_labels;

for k = 1:clusterSize
    segmented_images{k+1} = reshape(cluster_idx==k,nrows,ncols);
end
set(handles.showcluster,'string',{'All Clusters';1:clusterSize});
set(handles.showcluster,'enable','on');
guidata(hObject, handles);