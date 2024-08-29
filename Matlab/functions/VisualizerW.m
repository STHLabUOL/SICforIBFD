classdef VisualizerW
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        pow_z_dB_vec
        pow_za_dB_vec
        pow_x_dB_vec
        pow_yH_dB_vec
        pow_yW_dB_vec
        %
        nl2_nonLinPar_vec
        nl2_linFactor_vec
        nl2_SISDR_yW_dB_vec
        %
        DS_RMS_ns_vec
        PDP_dB_vec
    end

    methods
        function obj = VisualizerW(NumFiles)
            % Initialization of Visualizer
            obj.pow_z_dB_vec = zeros(1, NumFiles);
            obj.pow_za_dB_vec = zeros(1, NumFiles);
            obj.pow_x_dB_vec = zeros(1, NumFiles);
            obj.pow_yH_dB_vec = zeros(1, NumFiles);
            obj.pow_yW_dB_vec = zeros(1, NumFiles);
            %
            obj.nl2_nonLinPar_vec = zeros(1, NumFiles);
            obj.nl2_linFactor_vec = zeros(1, NumFiles);
            obj.nl2_SISDR_yW_dB_vec = zeros(1, NumFiles);
            %
            obj.DS_RMS_ns_vec = zeros(1, NumFiles);
            obj.PDP_dB_vec = zeros(NumFiles, 12);
        end

        function obj = fill(obj, idx_file, parSigs, parLowNoiAmpl, parChanSI)
            % Fill the properties with meaningful variables
            obj.pow_z_dB_vec(idx_file+1) = parSigs.pow_z_dB;
            obj.pow_za_dB_vec(idx_file+1) = parSigs.pow_za_dB;
            obj.pow_x_dB_vec(idx_file+1) = parSigs.pow_x_dB;
            obj.pow_yH_dB_vec(idx_file+1) = parSigs.pow_yH_dB;
            obj.pow_yW_dB_vec(idx_file+1) = parSigs.pow_yW_dB;
            %
            obj.nl2_nonLinPar_vec(idx_file+1) = parLowNoiAmpl.parAmpOut.param_NL;
            obj.nl2_linFactor_vec(idx_file+1) = parLowNoiAmpl.parAmpOut.factor_lin_global;
            obj.nl2_SISDR_yW_dB_vec(idx_file+1) = parLowNoiAmpl.parAmpOut.SISDR_OutIn_dB;
            %
            obj.PDP_dB_vec(idx_file+1,:) = parChanSI.PDP_dB;
            obj.DS_RMS_ns_vec(idx_file+1) = parChanSI.DelaySpread_RMS_ns;
        end

        function h_fig = plot(obj, datasets_str, idx_datasets, folders, parAmpIn, parSigs)
        % Visualize the statistics of the generated signals
            h_fig = figure('Name',['statistics of ' datasets_str{idx_datasets} ' dataset ' folders.dataset], ...
                    'Position', [100*idx_datasets 100*idx_datasets 1300 500]);
            % 
            subplot(3,1,1);
            histogram(obj.pow_z_dB_vec, 20, 'EdgeColor','none'); hold on; histogram(obj.pow_za_dB_vec, 20, 'EdgeColor','none');
            histogram(obj.pow_x_dB_vec, 20, 'EdgeColor','none'); grid on; histogram(obj.pow_yH_dB_vec, 20, 'EdgeColor','none');
            histogram(obj.pow_yW_dB_vec, 20, 'EdgeColor','none');
            xlabel('signal power [dB]');
            legend({['mean(pow-z)=' num2str(mean(obj.pow_z_dB_vec),'%5.2f') 'dB & std(pow-z) = ' num2str(std(obj.pow_z_dB_vec),'%5.2f') 'dB'],...
                ['mean(pow-za)=' num2str(mean(obj.pow_za_dB_vec),'%5.2f') 'dB & std(pow-za) = ' num2str(std(obj.pow_za_dB_vec),'%5.2f') 'dB'],...
                ['mean(pow-x)=' num2str(mean(obj.pow_x_dB_vec),'%5.2f') 'dB & std(pow-x) = ' num2str(std(obj.pow_x_dB_vec),'%5.2f') 'dB'],...
                ['mean(pow-yH)=' num2str(mean(obj.pow_yH_dB_vec),'%5.2f') 'dB & std(pow-yH) = ' num2str(std(obj.pow_yH_dB_vec),'%5.2f') 'dB'],...
                ['mean(pow-yW)=' num2str(mean(obj.pow_yW_dB_vec),'%5.2f') 'dB & std(pow-yW) = ' num2str(std(obj.pow_yW_dB_vec),'%5.2f') 'dB']});
            str_title = [datasets_str{idx_datasets} ' dataset: PAG = ' num2str(parAmpIn.PAG_dB) 'dB'];
            str_title = [str_title ' & AWGN-SINR = ' num2str(parSigs.SINR_dB_awgn,'%5.2f') 'dB'];
            title(str_title);
            annotation('textbox', [0.15, 0.675, 0.1, 0.1], 'String', ['DelaySpread-RMS [ns]: ' ...
                num2str(obj.DS_RMS_ns_vec,'%5.2f ') ' => mean = ' num2str(mean(obj.DS_RMS_ns_vec),'%5.2f') ...
                ' in [' num2str(min(obj.DS_RMS_ns_vec),'%5.2f') ', ' num2str(max(obj.DS_RMS_ns_vec),'%5.2f') ']'], 'FontSize',8);
            annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', ['IR-PowDelayProf. [dB]: ' ...
                num2str(mean(obj.PDP_dB_vec),'%5.2f ')], 'FontSize',8);
            % 
            subplot(3,1,2);
            parNL_const = obj.nl2_nonLinPar_vec(1);
            parNL_rmse = sqrt(mean((obj.nl2_nonLinPar_vec-parNL_const).^2));
            histogram(obj.nl2_linFactor_vec, 20); grid on; xlabel('linear factor a of NL-LNA');
            title(['NL-LNA = ' parAmpIn.type_nl_str ' with c = ' num2str(parNL_const) ...
                ' & RMSE(c) = ' num2str(parNL_rmse)]);
            legend({['mean(a) = ' num2str(mean(obj.nl2_linFactor_vec)) ' & std(a) = ' ...
                num2str(std(obj.nl2_linFactor_vec))]}, 'Location','south');
            % 
            subplot(3,1,3);
            histogram(obj.nl2_SISDR_yW_dB_vec, 20); grid on; xlabel('SI-SDR of NL-LNA output sig-yW [dB]');
            title(['SI-SDR=' num2str(parAmpIn.SISDR_dB_desired) 'dB (target for invNL & mean for varNL)']);
            legend({['mean(SI-SDR)=' num2str(mean(obj.nl2_SISDR_yW_dB_vec)) 'dB & std(SI-SDR)=' ...
                num2str(std(obj.nl2_SISDR_yW_dB_vec)) 'dB']}, 'Location','south');
        end
    end
end