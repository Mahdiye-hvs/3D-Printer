%%GC×GC Data (Century Mix)
%each spectrums of the data should be summed
%%
% Change directory
cd("Y:\Mahdiye\3D-Printer\New Data");

% Read the CSV file with original column headers preserved
Raw_data = readtable('Mixture_Data.csv', 'VariableNamingRule', 'preserve');

% Calculates the sum of fourth_column(Area), grouped by unique values in first_column(Sppectrum)
first_column = Raw_data{:, 1};  % Extract the first column(Spectrum) 
fourth_column = Raw_data{:, 6}; % Extract the sixth column(Area) 
Sum_data = groupsummary(table(first_column, fourth_column), "first_column", "sum", "fourth_column");

%Reshaping data 
%200: acquisition rate (spectra per second)
% 4 : modulation time (second)
%Tot acqcisition num = 464000(800×580 = 1st acq num × 2nd acq num)
%snd dim = 580
Second_Dim = 200 * 4; 
totalNumAcq = height(Sum_data(1:464000, :)); %Selects and counts the first 464,000 rows from Sum_data as total acq data
First_Dim = totalNumAcq / Second_Dim; 
Sum_data_array = table2array(Sum_data(1:464000, 3)); %Converting the table format to array
Z = reshape(Sum_data_array, [Second_Dim, First_Dim]);

%Extracting relative X and Y from Z matrix
[X, Y] = meshgrid(1:size(Z, 2), 1:size(Z, 1));

% Apply Gaussian smoothing
Z = imgaussfilt(Z, 6);

%Apply Scaling 
%note : For making sure that the scaling and smoothing is working, It's better to check after scaling(in this case Log did'nt work at all
scaleFactor = 0.3; %Can be varied
X = X * scaleFactor;
Z = Z * 0.00000648;
Y= Y * scaleFactor;


% Apply decimation along axis
decimationFactor = 2; % Retain every 2nd row in Y-axis
Y = Y(1:decimationFactor:end, :); % Decimate Y-axis
Z = Z(1:decimationFactor:end, :); % Decimate Z values
X = X(1:decimationFactor:end, :); % Decimate X-axis to match Y

% Flatten decimated matrices for triangulation
vertices = [X(:), Y(:), Z(:)];

%Remove rows with NaN or Inf in the decimated vertices
valid_indices = all(isfinite(vertices), 2); % Check for finite values
vertices = vertices(valid_indices, :); % Keep only valid rows

% Generate Delaunay triangulation for faces on decimated data
faces = delaunay(vertices(:, 1), vertices(:, 2));

% Use surf2solid to create the solid volume from decimated data
[F_solid, V_solid] = surf2solid(faces, vertices, ...
    'elevation', min(Z(:)) - 10); %-10: Extends the solid 10 units below the lowest Z-value( ensures the solid volume has a flat bottom)

% Plot the solid volume from decimated data
figure;
patch('Faces', F_solid, 'Vertices', V_solid, ...
      'FaceColor', 'magenta', 'EdgeColor', 'none');
axis vis3d;
view(3);
camlight;
lighting gouraud;
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Solid Surface');

% Create a triangulation object from decimated solid
tri = triangulation(F_solid, V_solid);

% Write the decimated triangulation object to an STL file
stlwrite(tri, 'GC×GC_Stl_Format.stl');


