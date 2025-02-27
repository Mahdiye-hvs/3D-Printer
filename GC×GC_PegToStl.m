%% 2D GC×GC Data

%% Set up a directory
cd('Y:\Mahdiye\3D-Printer\GC GC1')

%Turning PEG into readable data 
%Extracting the properties of the data
[pegstruct] = LoadPEG('20221028_RTG_ALKANES_1 (1).peg', 1)

%Define the dimension of the data for visualising
% Reshaping the data based on acquisition counts in the first and second dimensions
sndDimAcqCount = pegstruct.dataRate * pegstruct.modTime; %How many acquistion in the 2nd dimension?
totalNumAcq = size(pegstruct.tic, 1); %How many acq in total?
firstDimAcqCount = totalNumAcq/sndDimAcqCount; %How many modulations?
ticMatrix = reshape(pegstruct.tic, [sndDimAcqCount, firstDimAcqCount]); % Reshape vector into matrix with 2nd dim rows and 1st dime column

%Extraacting X and Y matrix out of Z
Z = ticMatrix;
[X, Y] = meshgrid(1:size(Z, 2), 1:size(Z, 1));

%Apply Scaling %Based on the size of each data would be variables
scaleFactor = 0.5;
X = X * scaleFactor;
Z = Z * scaleFactor;
Y= Y * 1.4;

% Apply Gaussian smoothing
Smoothing_Factor = 4; %Based on the data would be variable
Z = imgaussfilt(Z, Smoothing_Factor);

% Scale with logarithmic transformation
Z = log10(Z + 1);
Z = Z * 250 ;

%Set uo starting point of Z to zero
Z_min = min(Z(:));
Z_scaled = Z - Z_min;

% Find the maximum Z value and its location for removing column bleed
[max_Z, max_idx] = max(Z_scaled(:)); % Find the max value in Z_scaled
[row_max, col_max] = ind2sub(size(Z_scaled), max_idx); % Convert to row and column indices
x_max = X(1, col_max); % X-coordinate of the max Z
y_max = Y(row_max, 1); % Y-coordinate of the max Z
y_threshold = y_max + 40; % % Define the range for removal with extension of 40(can be different based on the data)
mask_remove = (Y <= y_threshold); % Create a mask to identify the region to remove
Z_scaled(mask_remove) = NaN; % Remove the data by setting the Z values to NaN

%Scaling for final printing
X= X * 0.25;
Y= Y * 0.25;

% Apply Gaussian smoothing
Smoothing_Factor = 4; %Based on the data would be variable
Z = imgaussfilt(Z, Smoothing_Factor);

% Apply decimation along Y-axis
decimationFactor = 2; % Retain every 2nd row in Y-axis
Y_decimated = Y(1:decimationFactor:end, :); % Decimate Y-axis
Z_decimated = Z_scaled(1:decimationFactor:end, :); % Decimate Z values
X_decimated = X(1:decimationFactor:end, :); % Decimate X-axis to match Y

% Flatten decimated matrices for triangulation
vertices_decimated = [X_decimated(:), Y_decimated(:), Z_decimated(:)];

% Remove rows with NaN or Inf in the decimated vertices
valid_indices = all(isfinite(vertices_decimated), 2); % Check for finite values
vertices_decimated = vertices_decimated(valid_indices, :); % Keep only valid rows

% Generate Delaunay triangulation for faces on decimated data
faces_decimated = delaunay(vertices_decimated(:, 1), vertices_decimated(:, 2));

% Use surf2solid to create the solid volume from decimated data
[F_solid_decimated, V_solid_decimated] = surf2solid(faces_decimated, vertices_decimated, ...
    'elevation', min(Z_decimated(:)) - 5);  %-5 is the base elevation(can be changed based on the data)

% Plot the solid volume from decimated data
figure;
patch('Faces', F_solid_decimated, 'Vertices', V_solid_decimated, ...
      'FaceColor', 'magenta', 'EdgeColor', 'none');
axis vis3d;
view(3);
camlight;
lighting gouraud;
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Decimated Solid Volume');

% Create a triangulation object from decimated solid
tri_decimated = triangulation(F_solid_decimated, V_solid_decimated);

% Write the decimated triangulation object to an STL file
stlwrite(tri_decimated, 'GC×GC_StlFormat.stl');