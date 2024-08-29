classdef configSystemOption
    % Configurator of the system options from Fig. 1 of [1]
    % [1] G. Enzner, A. Chinaev, S. Voit, A. Sezgin, 'On Neural-Network
    % Representation of Wireless Self-Interference for Inband Full-Duplex
    % Communications', submitted to IEEE ICASSP-2025.
    % AC, 2024.08.28
    
    methods(Static)
        function [parAmpIn, parChanSI, parSigs] = H(flags, parSigs)
        % Hammerstein system option acc. to Fig 1a) of [1]
            % NL-PA
            parAmpIn.PAG_dB = 20;   % power amplifier gain (PAG)
            % Averaged scale-invariant signal-to-distortion-ratio (SI-SDR)
            parAmpIn.SISDR_dB_desired = 10; % \in [10; 70] dB
            % SISDR_dB = SISDR_dB_desired \pm SISDR_dB_desiredDelta
            if flags.varNL==0
                parAmpIn.SISDR_dB_desiredDelta = 0;
            else
                parAmpIn.SISDR_dB_desiredDelta = 4;
            end
            parAmpIn.type_nl = 1;
            str_nl_vec = {'atan(c*|x|)', 'atan(c*|x|)/(pi/2)', 'atan(c*|x|)/c', 'limiter'};
            parAmpIn.type_nl_str = str_nl_vec{parAmpIn.type_nl};
            % SI channel
            parChanSI.pathGain0_add_dB = 5.8; % for Delta-PDP=7.5dB of h_iSI over h_eSI
            % AWGN parameter
            parSigs.SINR_dB_awgn = 90; % self-interference-to-noise-ratio (SINR) in dB
        end

        function [parChanSI, parAtt, parSigs, parAmpIn] = W(flags, parSigs)
        % Wiener system option acc. to Fig 1b) of [1]
            % SI channel
            parChanSI.pathGain0_add_dB = 5.8; % for Delta-PDP = 7.5dB of h_{iSI}[k] over h_{eSI}[k]
            % Attenuator
            parAtt.PowAttGain_dB = -37; % power attenuation gain -37dB on averaged
            parAtt.factor_PowAttGain = 10^(parAtt.PowAttGain_dB/20); % power attenuation gain
            % AWGN: self-interference-to-noise ration (SINR)
            parSigs.SINR_dB_awgn = 90; % in dB
            % Nonlinear low-noise amplifier (LNA)
            parAmpIn.PAG_dB = 50; % power amplifier gain (PAG) in dB
            % Averaged scale-invariant signal-to-distortion-ratio
            parAmpIn.SISDR_dB_desired = 10; % \in [10; 70] dB
            % SISDR_dB = SISDR_dB_desired \pm SISDR_dB_desiredDelta
            if flags.varNL==0
                parAmpIn.SISDR_dB_desiredDelta = 1;
            else
                parAmpIn.SISDR_dB_desiredDelta = 4;
            end
            parAmpIn.type_nl = 4;
            str_nl_vec = {'atan(c*|x|)', 'atan(c*|x|)/(pi/2)', 'atan(c*|x|)/c', 'limiter'};
            parAmpIn.type_nl_str = str_nl_vec{parAmpIn.type_nl};
        end
    end
end