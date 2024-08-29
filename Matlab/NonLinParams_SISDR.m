% Produce Fig. 2(b) in [1].
% 
% [1] G. Enzner, A. Chinaev, S. Voit, A. Sezgin, 'On Neural-Network
% Representation of Wireless Self-Interference for Inband Full-Duplex
% Communications', submitted to IEEE ICASSP-2025.
% 
% AC, 2024.08.29

clear variables; clc; close all

SISDR_dB_axis = 6:.5:74;
load('mat_files/sisdr_to_param_atan.mat');
param_NL_vec_atan = param_NL_vec;
param_atan_axis = interp1(SISDR_dB_atan, param_NL_vec, SISDR_dB_axis);
load('mat_files/sisdr_to_param_limiter.mat');
param_NL_vec_limiter = param_NL_vec;
param_limiter_axis = interp1(SISDR_dB_limiter, param_NL_vec, SISDR_dB_axis);
%
figure('Position',[100 100 600 150]);
plot(SISDR_dB_axis, param_atan_axis, 'LineWidth',2); hold on;
plot(SISDR_dB_axis, param_limiter_axis, 'LineWidth',2); grid on;
xlabel('SI-SDR [dB]'); ylabel('cf, cg'); xlim([0 80]); ylim([0 4]);
legend({'arctan','limiter'}, 'location','best');

% matlab2tikz('Fig_ParC_SISDR.tikz');