function RawdataToStl(Raw_data)
%This function is specified to turn the Raw data in the matrix format into Stl
% the steps includes:
%   generating the X and Y matrices
%   apply the decimation
%   smoothing the data
%   scaling: set the scale of the x and y to be 100 and 150 respectively and the scaling of z is in a way that max z point is the mean of the x and y
%   triangulation
%   turn the surface into solid
%   converting the generated solid into Stl file format
%
%
%Input : LCLC, GCGC or NMR data in the matrix or table format
%
%
%Output : the stl file namely 
%
%
data_type = input ('Insert the data type: ', 's');
smoothing_factor = input('the amount of smoothing: ');

[tri] = DataToStl( Raw_data ,smoothing_factor );

file_name = string(data_type) + ".stl";
stlwrite(tri, file_name);
end %RawdataToStl

