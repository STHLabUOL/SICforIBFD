classdef VisualizerH
    % Class for visualization of generated data used in [1]
    % [1] G. Enzner, A. Chinaev, S. Voit, A. Sezgin, 'On Neural-Network
    % Representation of Wireless Self-Interference for Inband Full-Duplex
    % Communications', submitted to IEEE ICASSP-2025.
    
    properties
        pow_s_dB_vec
        pow_z_dB_vec
        pow_x_dB_vec
        pow_yH_dB_vec
        %
        nl1_nonLinPar_vec
        nl1_linFactor_vec
        nl1_SISDR_z_dB_vec
        %
        DS_RMS_ns_vec
        PDP_dB_vec
        SampleRate
    end

    methods
        function obj = VisualizerH(NumFiles, SampleRate)
            % Initialization of Visualizer
            obj.pow_s_dB_vec = zeros(1, NumFiles);
            obj.pow_z_dB_vec = zeros(1, NumFiles);
            obj.pow_x_dB_vec = zeros(1, NumFiles);
            obj.pow_yH_dB_vec = zeros(1, NumFiles);
            %
            obj.nl1_nonLinPar_vec = zeros(1, NumFiles);
            obj.nl1_linFactor_vec = zeros(1, NumFiles);
            obj.nl1_SISDR_z_dB_vec = zeros(1, NumFiles);
            %
            obj.DS_RMS_ns_vec = zeros(1, NumFiles);
            obj.PDP_dB_vec = zeros(NumFiles, 12);
            obj.SampleRate = SampleRate;
        end

        function obj = fill(obj, idx_file, parSigs, parPowAmpl, parChanSI)
            % Fill the property vectors with meaningful variables
            obj.pow_s_dB_vec(idx_file+1) = parSigs.pow_s_dB;
            obj.pow_z_dB_vec(idx_file+1) = parSigs.pow_z_dB;
            obj.pow_x_dB_vec(idx_file+1) = parSigs.pow_x_dB;
            obj.pow_yH_dB_vec(idx_file+1) = parSigs.pow_yH_dB;
            %
            obj.nl1_nonLinPar_vec(idx_file+1) = parPowAmpl.parAmpOut.param_NL;
            obj.nl1_linFactor_vec(idx_file+1) = parPowAmpl.parAmpOut.factor_lin_global;
            obj.nl1_SISDR_z_dB_vec(idx_file+1) = parPowAmpl.parAmpOut.SISDR_OutIn_dB;
            %
            obj.PDP_dB_vec(idx_file+1,:) = parChanSI.PDP_dB;
            obj.DS_RMS_ns_vec(idx_file+1) = parChanSI.DelaySpread_RMS_ns;
        end

        function h_fig = plot(obj, datasets_str, idx_datasets, folders, parAmpIn, parSigs)
        % Visualize the statistics of the generated signals
            disp(['DelaySpread-RMS [ns]: ' num2str(obj.DS_RMS_ns_vec,'%5.2f ') ...
                ' => mean = ' num2str(mean(obj.DS_RMS_ns_vec),'%5.2f')]);
            disp(['IR-PowDelayProf. [dB]: ' num2str(mean(obj.PDP_dB_vec),'%5.2f ')]);
        
            %% Plot a figure with conrtol variables to analyse the generated data
            h_fig = figure('Name',['statistics of ' datasets_str{idx_datasets} ' dataset ' folders.dataset], ...
                'Position', [100*idx_datasets 100*idx_datasets 1300 500]);
            %
            subplot(3,1,1);
            histogram(obj.pow_s_dB_vec, 20, 'EdgeColor','none'); hold on; histogram(obj.pow_z_dB_vec, 20, ...
                'EdgeColor','none');
            histogram(obj.pow_x_dB_vec, 20, 'EdgeColor','none'); grid on; histogram(obj.pow_yH_dB_vec, 20, ...
                'EdgeColor','none');
            xlabel('signal power [dB]');
            legend({['mean-pow(s)=' num2str(mean(obj.pow_s_dB_vec),'%5.2f') 'dB & std(pow-s) = ' num2str(std(obj.pow_s_dB_vec),'%5.2f') 'dB'],...
                ['mean-pow(z)=' num2str(mean(obj.pow_z_dB_vec),'%5.2f') 'dB & std(pow-z) = ' num2str(std(obj.pow_z_dB_vec),'%5.2f') 'dB'],...
                ['mean-pow(x)=' num2str(mean(obj.pow_x_dB_vec),'%5.2f') 'dB & std(pow-x) = ' num2str(std(obj.pow_x_dB_vec),'%5.2f') 'dB'],...
                ['mean-pow(yH)=' num2str(mean(obj.pow_yH_dB_vec),'%5.2f') 'dB & std(pow-yH) = ' num2str(std(obj.pow_yH_dB_vec),'%5.2f') 'dB']});
            title([datasets_str{idx_datasets} ' dataset: Pow-Ampl-Ga (PAG) = '...
                num2str(parAmpIn.PAG_dB) 'dB' ' & AWGN-SINR = ' num2str(parSigs.SINR_dB_awgn,'%5.2f')]);
            annotation('textbox', [0.15, 0.675, 0.1, 0.1], 'String', ['DelaySpread-RMS [ns]: ' ...
                num2str(obj.DS_RMS_ns_vec,'%5.2f ') ' => mean = ' num2str(mean(obj.DS_RMS_ns_vec),'%5.2f') ...
                ' in [' num2str(min(obj.DS_RMS_ns_vec),'%5.2f') ', ' num2str(max(obj.DS_RMS_ns_vec),'%5.2f') ']'], ...
                'FontSize',8);
            annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', ['IR-PowDelayProf. [dB]: ' ...
                num2str(mean(obj.PDP_dB_vec),'%5.2f ')], 'FontSize',8);
            % 
            subplot(3,1,2);
            parNL_const = obj.nl1_nonLinPar_vec(1);
            parNL_rmse = sqrt(mean((obj.nl1_nonLinPar_vec-parNL_const).^2));
            histogram(obj.nl1_linFactor_vec, 20); grid on; xlabel('linear factor a of NL-PA');
            title(['NL-PA = ' parAmpIn.type_nl_str ' with c = ' num2str(parNL_const) ' & RMSE(c) = ' ...
                num2str(parNL_rmse)]);
            legend({['mean(a) = ' num2str(mean(obj.nl1_linFactor_vec)) ' & std(a) = ' ...
                num2str(std(obj.nl1_linFactor_vec))]}, 'Location','south');
            % 
            subplot(3,1,3);
            histogram(obj.nl1_SISDR_z_dB_vec, 20); grid on; xlabel('SI-SDR of NL-PA output sig-z [dB]');
            title(['SI-SDR=' num2str(parAmpIn.SISDR_dB_desired) 'dB (target for invNL & mean for varNL)']);
            legend({['mean(SI-SDR)=' num2str(mean(obj.nl1_SISDR_z_dB_vec)) 'dB & std(SI-SDR)=' ...
                num2str(std(obj.nl1_SISDR_z_dB_vec)) 'dB']}, 'Location','south');

            %% Fig. 2(a) in [1]
            ChanIRdelay_ns = (0:length(obj.PDP_dB_vec(1,:))-1)/obj.SampleRate*1e9;
            figure('Position',[200 50 600 150]);
            errorbar(ChanIRdelay_ns, mean(obj.PDP_dB_vec), std(obj.PDP_dB_vec), 'LineWidth',2);
            xlim([min(ChanIRdelay_ns) max(ChanIRdelay_ns)]); grid on;
            xlabel('filter delay [ns]'); ylabel('PDP [dB]');
            ax=gca; ax.FontSize = 10;
        end
    end
end