classdef SIchannel
    % Methods for signal generation
    % [1] G. Enzner, A. Chinaev, S. Voit, A. Sezgin, 'On Neural-Network
    % Representation of Wireless Self-Interference for Inband Full-Duplex
    % Communications', submitted to IEEE ICASSP-2025.
    % AC, 2024.08.28

    methods(Static)
        function [sig_x, tgnChan_info, parChanSI] = adjustApply(sig_z, tgnChannel, parChanSI)
        % Apply SI channel
            tgnChan_info = tgnChannel.info;
            [~, pathGains] = tgnChannel(sig_z); % see stepImpl() in wlan.internal.ChannelBase
            % Two-steps adjustment of chanFiltCoeffs & pathGains acc. to SI channel from [2]
            [chanFiltCoeffsSI, pathGainsSI] = SIchannel.adjust(tgnChan_info, pathGains(1,:), parChanSI.pathGain0_add_dB);
            parChanSI.chanFiltCoeffsSI = chanFiltCoeffsSI; parChanSI.pathGainsSI = pathGainsSI;
            % Filtering of sig_s using the simulated SI channel
            [sig_x, ChanIR] = SIchannel.tgnChannelSI(sig_z, chanFiltCoeffsSI, pathGainsSI);
            parChanSI.ChanIR = ChanIR;
        end

        function [chanFiltCoeffsSI, pathGainsSI] = adjust(tgnChan_info, pathGains_static, pathGain0_add_dB)
        % Adjustment of chanFiltCoeffs & pathGains acc. to SI channel from [1].
            % 1) chanFiltCoeffs modification to chanFiltCoeffsSI
            chanFiltCoeffs = tgnChan_info.ChannelFilterCoefficients;
            chanFiltCoeffsSI = chanFiltCoeffs(:,(tgnChan_info.ChannelFilterDelay+1):end);
            % 2) pathGains modification to pathGainsSI
            pathGainsSI = pathGains_static;
            pathGain1Abs_new = 10^((20*log10(max(abs(pathGainsSI(2:end))))+pathGain0_add_dB)/20);
            pathGainsSI(1) = pathGain1Abs_new*exp(1i*angle(pathGainsSI(1)));
        end

        function [rx_channel, impRespChanSI] = tgnChannelSI(tx, chanFiltCoeffsSI, pathGainsSI)
        % An accumulative impulse response of the SI channel (impRespChanSI) is
        % calculated from the channel filter coefficients (chanFiltCoeffsSI) and
        % path gains (pathGainsSI) available for all transmission paths. Next,
        % impRespChanSI is used for generation of the rx signal from tx signal.
            impRespChanSI = zeros(1, size(chanFiltCoeffsSI,2));
            for pathNumber = 1:length(pathGainsSI)
                impRespChanSI = impRespChanSI + chanFiltCoeffsSI(pathNumber,:)*pathGainsSI(pathNumber);
            end
            rx_channel = filter(impRespChanSI, 1, tx);
        end

        function parChanSI = statsChanSI(parChanSI, PathDelays)
        % Obtain such statistics of the SI channel as RMS of delay spread and the
        % power delay profile (PDP).
            pathGainsSI = parChanSI.pathGainsSI;
            ChanIR = parChanSI.ChanIR;
            Delay_MeanExcess_ns = mean(PathDelays*1e9.*abs(pathGainsSI).^2)/mean(abs(pathGainsSI).^2);
            Delay2_MeanExcess_ns = mean((PathDelays*1e9).^2.*abs(pathGainsSI).^2)/mean(abs(pathGainsSI).^2);
            DelaySpread_RMS_ns = sqrt(Delay2_MeanExcess_ns-Delay_MeanExcess_ns^2);
            PDP_dB = 20*log10(abs(ChanIR)); % power delay profile (PDP)
            parChanSI.DelaySpread_RMS_ns = DelaySpread_RMS_ns;
            parChanSI.PDP_dB = PDP_dB;
        end
    end
end