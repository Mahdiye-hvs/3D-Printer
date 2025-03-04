
%Specify the directory
cd("E:\U of A\James Project -3D printer\3D_Printer_Project\LC×LC");

%extracting the data
mat_format = open('RPLCxHILIC.mat'); %data is a 1×1 struct format with 2 fields
Raw_data = mat_format.WheatFlagLeaf_RPLCxHILIC(); %extracting the feild

%calculating the dimension of data
TotalNumData = numel(Raw_data); %How many datapoints is available totally
SndDim = height (Raw_data);
FirstDim = TotalNumData / SndDim ;
Z = reshape ( Raw_data , [SndDim , FirstDim]); %the Zdata in this data set is just like the Raw_data, but I wanted to make the code completely with all steps

%Extracting the X and Y coordinates
[X , Y] = meshgrid(1:size(Z ,2) , 1:size(Z,1));

%Smoothing using guassian fikter
smoothing_factor = 1.4;
Z_smoothed = imgaussfilt (Z , smoothing_factor);

%Scaling
%There is no need for scaling the X and Y coordinates
Max_height = max(Z_smoothed(:)); %Finding the maximum value of the Z in the matrix
scale_factor = ((size(X,1) + size(Y,2))/2) / Max_height ; %defining a scale factor to multiply all the Z and height to it (this transform the highest point of the graph to be mean of the X and Y size)%This make the printing easily 
Z_scaled = Z_smoothed * scale_factor ; %scale all the Z data 

%generate triangulated data from vertices
vertices = [X(:) , Y(:) , Z_scaled(:)] ; %convert all x , y and z into 3 seperately vectors and stack them together
faces = delaunay(vertices(:, 1), vertices(:, 2)); %generating triangulated faces, using extracted X and Y from vertices(assume that vertices are 3 collumn data and the 1st and 2nd column are X and Y)

%Convert the surface into solid object
[Solid_faces , Solid_vertices] = surf2solid(faces , vertices , 'elevation' , min(Z_scaled(:)) - 2); % using faces and vertices to define triangule connection
%turn the connection and surface into a solid object which extend the solid
%5 blocks further down from min surface(zero in this case)

figure;
patch('Faces', Solid_faces, 'Vertices', Solid_vertices,'FaceColor', 'cyan', 'EdgeColor', 'none');
axis vis3d;
view(3);
camlight;
lighting gouraud;
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Solid Volume');

% Create a triangulation object from decimated solid 
tri_object = triangulation(Solid_faces, Solid_vertices); %needed for exporting data to stl format

% Write the decimated triangulation object to an STL file
stlwrite(tri_object, 'LC×LC_StlFormat.stl');
