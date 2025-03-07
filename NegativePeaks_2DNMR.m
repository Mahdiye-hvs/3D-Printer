%%Since the data has negative peaks, for better printing, we have seperated
%%the positive and negative parts
% the elevated bottom generated by the surf2solid Fun should be in the reverse direction of the peaks

% Set directory
cd("Y:\Mahdiye\3D-Printer\2DNMR_3DPrinter");

% Reading and extracting data
Raw_Data = readtable("Menthyl-Anthranilate.txt", 'VariableNamingRule', 'preserve');

% Define matrix dimensions
ROWS = 1024;
COLUMNS = 2048;

% Convert data table to array type
Array_Raw_Data = table2array(Raw_Data(1:ROWS * COLUMNS, 1));

% Reshape into a 2D matrix
Z = reshape(Array_Raw_Data, [ROWS, COLUMNS]);

%scaling the Z matrix
Z= Z * 3.3*10^-6;

%Isolating Negative Z
Z_neg = Z;
Z_neg(Z_neg > 0) = 0; 

%generating X and Y matrix
[X, Y] = meshgrid(1:size(Z_neg, 2), 1:size(Z_neg , 1));

%Scaling X and Y data
X = X / 15; %Scaling X data(b can be different based on the data size)
Y = Y / 10; %Scaling Y data(b can be different based on the data size)

%Apply Decimation
decimationFactor = 3;
Y_neg = Y(1:decimationFactor:end, :);
X_neg = X(1:decimationFactor:end, :);
Z_neg = Z_neg(1:decimationFactor:end, :);

%Smoothing the Z matrix
Z_neg = imgaussfilt(Z_neg, 6);

% Flatten for triangulation
vertices_neg = [X_neg(:), Y_neg(:), Z_neg(:)];
valid_indices_neg = all(isfinite(vertices_neg), 2);
vertices_neg = vertices_neg(valid_indices_neg, :);

% Generate Delaunay triangulation for negative data
faces_neg = delaunay(vertices_neg(:, 1), vertices_neg(:, 2));

% Create a solid volume from negative data
[F_solid_neg, V_solid_neg] = surf2solid(faces_neg, vertices_neg, 'elevation', 2); %2 is theheight of solid bottom(can be changed based on the data)

% Save STL file for negative peaks
tri_neg = triangulation(F_solid_neg, V_solid_neg);
stlwrite(tri_neg, '3DNMR_Negative.stl');



