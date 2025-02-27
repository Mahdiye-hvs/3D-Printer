%%Since the data has negative peaks, for better printing, we have seperated
%%the positive and negative parts

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

%Scaling Z matrix(the height)
Z= Z * 3.3*10^-6;

%Filtering Z data
Z_pos = Z;
Z_pos(Z_pos <0) = 0;

%generating X and Y matrix
[X, Y] = meshgrid(1:size(Z_pos, 2), 1:size(Z_pos , 1));

%Scaling X and Y data
X = X / 15; %Scaling X data(b can be different based on the data size)
Y = Y / 10; %Scaling Y data(b can be different based on the data size)

%Lowering the number of data by decimation
decimationFactor = 3;
Y_pos = Y(1:decimationFactor:end, :);
X_pos = X(1:decimationFactor:end, :);
Z_pos = Z_pos(1:decimationFactor:end, :);

%apply smoothing
Z_smoothed = imgaussfilt(Z_pos, 8);

% Flatten for triangulation
vertices_pos = [X_pos(:), Y_pos(:), Z_smoothed(:)];
valid_indices_pos = all(isfinite(vertices_pos), 2);
vertices_pos = vertices_pos(valid_indices_pos, :);

% Generate Delaunay triangulation for positive data
faces_pos = delaunay(vertices_pos(:, 1), vertices_pos(:, 2));

% Create a solid volume from positive data
[F_solid_pos, V_solid_pos] = surf2solid(faces_pos, vertices_pos, 'elevation', -2); %-2 is theheight of solid bottom(can be changed based on the data)

% Save STL file for positive peaks
tri_pos = triangulation(F_solid_pos, V_solid_pos);
stlwrite(tri_pos, '3DNMR_Positive.stl');