classdef utils
    % Some functions useful for signal generation
    % AC, 2024.08.28
    
    methods(Static)
        function checkMakeFolders(folders)
        % Check and make folders for datasets, if not available
            if ~isfolder(folders.data); mkdir(folders.data); end
            if ~isfolder([folders.data '/' folders.dataset]); mkdir([folders.data '/' folders.dataset]); end
            if ~isfolder([folders.data '/' folders.dataset '/' folders.datasets_str{1}])
                mkdir([folders.data '/' folders.dataset '/' folders.datasets_str{1}]);
            end
            if ~isfolder([folders.data '/' folders.dataset '/' folders.datasets_str{2}])
                mkdir([folders.data '/' folders.dataset '/' folders.datasets_str{2}]);
            end
        end

        function cfgHT = createCfgHT()
        % Create a format configuration object for a HT (High Throughput, HT) transmission
            cfgHT = wlanHTConfig;             % filter signal through 802.11n multipath fading channel
            cfgHT.ChannelBandwidth = 'CBW20'; % 20 MHz channel bandwidth
            cfgHT.NumTransmitAntennas = 1;    % number of transmit antennas
            cfgHT.NumSpaceTimeStreams = 1;    % number of space-time streams
            % Physical layer convergence procedure (PLCP) service data unit (PSDU)
            cfgHT.PSDULength = 1000;          % PSDU length in bytes (1000 -> 3200 complex-valued doubles)
            % Modulation and Coding Scheme (MCS)
            cfgHT.MCS = 7;                    % 7 -> 64-QAM rate-5/6 for NumSpaceTimeStreams = 1
            cfgHT.ChannelCoding = 'BCC';      % Binary convolutional coding 'BCC'
            % ofdmInfo = wlanHTOFDMInfo('HT-Data',cfgHT); % Get the OFDM info
        end

        function tgnChannel = createTGnChannel(cfgHT)
        % Create and configure the HT task group (TG) n-channel
            tgnChannel = wlanTGnChannel;
            tgnChannel.DelayProfile = 'Model-C';        % channel model
            tgnChannel.NumTransmitAntennas = cfgHT.NumTransmitAntennas;
            tgnChannel.NumReceiveAntennas = 1;
            tgnChannel.TransmitReceiveDistance = 0.5;   % Distance in meters
            tgnChannel.LargeScaleFadingEffect = 'Pathloss';
            tgnChannel.NormalizeChannelOutputs = false;
            tgnChannel.PathGainsOutputPort = 1;         % for [~, pathGains] = tgnChannel(tx);
            tgnChannel.NormalizePathGains = false;
            tgnChannel.EnvironmentalSpeed = 0;          % static (timeinvariant) Fading
        end

        function [tgnChan_info, parSigs] = getTGnInfosParams(cfgHT, tgnChannel)
        % Get tgnChanel infos and some variables for generation of OFDM signals
            tgnChan_info = tgnChannel.info;
            tx_PSDU = randi([0 1],cfgHT.PSDULength*8,1); % PSDULength in bits
            parSigs.PackLenTxWG_smp = size(wlanWaveformGenerator(tx_PSDU,cfgHT),1);
            parSigs.NumTrailingZeros = size(tgnChan_info.ChannelFilterCoefficients,2)-1;
        end
    end
end