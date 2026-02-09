%% compare_fpga_vs_matlab.m
% Compares red.txt / green.txt / blue.txt from Vivado pixel by pixel
% with MATLAB's red_output.txt / green_output.txt / blue_output.txt files.
clear; clc;

% Image dimensions
IMG_W = 640;
IMG_H = 480;

%% FPGA outputs
R_fpga = read_hex_image_4bit('red.txt'  , IMG_W, IMG_H);
G_fpga = read_hex_image_4bit('green.txt', IMG_W, IMG_H);
B_fpga = read_hex_image_4bit('blue.txt' , IMG_W, IMG_H);

%% MATLAB reference outputs
R_ref = read_hex_image_4bit('red_output.txt'  , IMG_W, IMG_H);
G_ref = read_hex_image_4bit('green_output.txt', IMG_W, IMG_H);
B_ref = read_hex_image_4bit('blue_output.txt' , IMG_W, IMG_H);

%% Numerical differences (in 4-bit domain)
diffR = int16(R_fpga) - int16(R_ref);
diffG = int16(G_fpga) - int16(G_ref);
diffB = int16(B_fpga) - int16(B_ref);

fprintf('RED   channel: number of different pixels = %6d, max |error| = %d\n', ...
        nnz(diffR), max(abs(diffR(:))));
fprintf('GREEN channel: number of different pixels = %6d, max |error| = %d\n', ...
        nnz(diffG), max(abs(diffG(:))));
fprintf('BLUE  channel: number of different pixels = %6d, max |error| = %d\n', ...
        nnz(diffB), max(abs(diffB(:))));

%% Scale images to 8-bit and display (optional)
R8_fpga = uint8(R_fpga * 16);
G8_fpga = uint8(G_fpga * 16);
B8_fpga = uint8(B_fpga * 16);

R8_ref  = uint8(R_ref  * 16);
G8_ref  = uint8(G_ref  * 16);
B8_ref  = uint8(B_ref  * 16);

img_fpga = cat(3, R8_fpga, G8_fpga, B8_fpga);
img_ref  = cat(3, R8_ref , G8_ref , B8_ref );

figure;
subplot(1,2,1);
imshow(img_ref);
title('MATLAB Output');
subplot(1,2,2);
imshow(img_fpga);
title('FPGA Output');

%% Helper function: Read 4-bit hex image
function img = read_hex_image_4bit(fname, W, H)
    % Read the file
    fid = fopen(fname,'r');
    if fid == -1
        error('File could not be opened: %s', fname);
    end
    txt = fread(fid,'*char')';
    fclose(fid);
    
    % Keep only hex characters (0-9, A-F, a-f)
    hexchars = txt(ismember(txt, ['0':'9' 'A':'F' 'a':'f']));
    
    N_expected = W * H;
    N = numel(hexchars);
    
    if N < N_expected
        warning('%s has %d missing hex chars, padding ends with 0.', ...
                fname, N_expected - N);
        % Fill missing parts with 0
        hexchars = [hexchars, repmat('0', 1, N_expected - N)];
    elseif N > N_expected
        warning('%s has %d excess hex chars, truncating ends.', ...
                fname, N - N_expected);
        % Discard excess parts
        hexchars = hexchars(1:N_expected);
    end
    
    % Each pixel is 1 hex digit (0–F)
    vals = uint8(hex2dec(cellstr(hexchars.')));  % N_expected x 1
    
    % W x H -> H x W (row-column)
    img = reshape(vals, W, H).';
end