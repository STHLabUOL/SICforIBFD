classdef Nonlinearity
    % Apply nonlinearity
    methods(Static)
        function [x_out_PA, parPowAmpl, x_norm] = applyAmplifier(x_in_PA, parPowAmpl)
        % Assuming a power amplifier with only non-linear AM/AM modulation, four
        % different modulation functions are implemented depending on the chosen
        % type_nl parameter: 1: 'atan(c*|x|)', 2: 'atan(c*|x|)/(pi/2)',
        % 3: 'atan(c*|x|)/c' and 4: 'soft limiter model'.
            x_in_PA = x_in_PA';
            ParInAmplifier = parPowAmpl.parAmpIn;
            % set input parameters
            PAG_dB = ParInAmplifier.PAG_dB;
            SISDR_dB = ParInAmplifier.SISDR_dB;
            type_nl = ParInAmplifier.type_nl;
            
            pow_x_in_PA_dB = 10*log10(mean(power(abs(x_in_PA),2))); % check pow_x_in
            
            % 0) ideal PA with a power amplifier gain (PAG) 10*log10(Px-out/Px-in) [dB]
            factor_PA = 10^(PAG_dB/20);
            x = factor_PA*x_in_PA; % pow(x) = 2*factor_PA^2
            
            % 1) normalize x->x_norm to pow(x_norm) = 1
            [x_norm, factor_norm, pow_x, ~] = Nonlinearity.normalizeSignal(x, 1);
            clear x
            % pow_x_dB = 10*log10(pow_x);
            
            % 1) -> 2) obtain a polar representation of complex-valued x_norm
            % x_norm_abs = abs(x_norm);
            % x_norm_cmp_exp = x_norm./x_norm_abs; % x_norm_cmp_exp = exp(i*x_phase);
            
            % 2) add a non-linearity (different types possible) to the magnitude of x_norm
            % load sisdr_to_param.mat % with SISDR_dB_atan, SISDR_dB_limiter & param_NL_vec
            if type_nl<=3
                load('mat_files/sisdr_to_param_atan.mat') % with SISDR_dB_atan & param_NL_vec
                param_NL = interp1(SISDR_dB_atan, param_NL_vec, SISDR_dB);
            elseif type_nl==4
                load('mat_files/sisdr_to_param_limiter.mat') % with SISDR_dB_limiter & param_NL_vec
                param_NL = interp1(SISDR_dB_limiter, param_NL_vec, SISDR_dB);
            end
            x_norm_abs_PA = Nonlinearity.addNonLinearity(abs(x_norm), type_nl, param_NL);
            
            % 2) -> 3) obtain a cartesian representation of complex-valued x_norm_PA
            % x_norm_PA = x_norm_abs_PA.*x_norm./abs(x_norm); % problems with 0-division
            x_norm_PA = x_norm_abs_PA.*exp(1i*angle(x_norm)); % angle(0) = 0
            clear x_norm_abs_PA
            
            % 2a) check SI-SDR in the normalized domain (in x_norm_PA regarding to x_norm)
            [factor_lin_norm, ~] = Nonlinearity.splitSignalLinNL(x_norm, x_norm_PA);
            % clear x_norm
            
            % 3) renormalize signal x_norm_PA -> x_out_PA to pow(x_out_PA) = pow(x)
            [x_out_PA, factor_renorm, ~, pow_x_out_PA] = Nonlinearity.normalizeSignal(x_norm_PA, pow_x);
            clear x_norm_PA
            pow_x_out_PA_dB = 10*log10(pow_x_out_PA);
            SNR_OutIn_dB = pow_x_out_PA_dB - pow_x_in_PA_dB;
            
            % 3a) check input-output SI-SDR (in x_out_PA regarding to x_in_PA)
            factors_product = factor_PA*factor_norm*factor_lin_norm*factor_renorm;
            [factor_lin_global, SISDR_OutIn_dB] = Nonlinearity.splitSignalLinNL(x_in_PA, x_out_PA);
            
            % set output parameters
            ParOutAmplifier.factors.PA = factor_PA;
            ParOutAmplifier.factors.norm = factor_norm;
            ParOutAmplifier.factors.lin_norm = factor_lin_norm;
            ParOutAmplifier.factors.renorm = factor_renorm;
            ParOutAmplifier.factors_product = factors_product;
            ParOutAmplifier.factor_lin_global = factor_lin_global;
            %
            ParOutAmplifier.param_NL = param_NL;
            ParOutAmplifier.SNR_OutIn_dB = SNR_OutIn_dB;
            ParOutAmplifier.SISDR_OutIn_dB = SISDR_OutIn_dB;
            %
            x_out_PA = x_out_PA';
            parPowAmpl.parAmpOut = ParOutAmplifier;
        end

        function [x_norm, factor, pow_in, pow_out_measured] = normalizeSignal(x, pow_out_desired)
        % Normalization of the input signal to pow(x_norm) = 1.
            pow_in = mean(power(abs(x),2));
            factor = sqrt(pow_out_desired/pow_in);
            x_norm = factor*x;
            pow_out_measured = mean(power(abs(x_norm),2));
        end

        function x_norm_abs_PA = addNonLinearity(x_norm_abs, type_nl, param_NL)
        % Simulation of a non-linear input-output mapping for different types of
        % non-linearyties:
        % type_nl - 1 'atan(c*|x|)', 2 'atan(c*|x|)/(pi/2)', 3 'atan(c*|x|)/c' [2]
        %           and 4 'soft limiter model' acc. to eqs. (22)-(24) in [3]
        % [2] Enzner, 'From Acoustic Nonlinearity to Adaptive Nonlinear
        % System Identification', 2012
        % [3] Tellado, Hoo, Cioffi, 'ML Detection of Nonlinearity Distorted
        % Multicarier Symbols by Iterative Decoding', 2003
            switch type_nl
                case 1 % 'atan(c*|x|)'
                    x_norm_abs_PA = atan(param_NL*x_norm_abs);
                case 2 % 'atan(c*|x|)/(pi/2)'
                    x_norm_abs_PA = atan(param_NL*x_norm_abs)/(pi/2);
                case 3 % 'atan(c*|x|)/c' as in [2]
                    x_norm_abs_PA = atan(param_NL*x_norm_abs)/param_NL;
                case 4 % soft limiter model acc. to eqs. (22)-(24) in [3]
                    x_norm_abs_PA = x_norm_abs;
                    for idx_n = 1:length(x_norm_abs)
                        if x_norm_abs(idx_n)>param_NL
                            x_norm_abs_PA(idx_n) = param_NL;
                        end
                    end
                otherwise
                    warning('Please select a suitable type of non-linearity!')
            end
        end

        function [factor_norm_lin, SISDR_norm_dB] = splitSignalLinNL(x_norm, x_norm_PA)
        % Calculate SI-SDR via splitting of
        % x_norm_PA = x_norm_PA_lin + x_norm_PA_nonlin
        % into a linear x_norm_PA_lin & a non-linear part x_norm_PA_nonlin
        % least-squares estimate (why real-valued?)
        % 
        % [4] Le Roux, Wisdom, Erdogan, Hershey, 'SDR - half-baked or well done?',
        % ICASSP, 2019.
        
            factor_norm_lin = real((x_norm_PA*x_norm')/(x_norm*x_norm'));
            x_norm_PA_lin = factor_norm_lin*x_norm;
            clear x_norm
            % x_norm_PA_nonlin = x_norm_PA - x_norm_PA_lin;
            % denominator of eq. (3) in [4]
            x_norm_PA_nonlin = x_norm_PA_lin - x_norm_PA;
            %
            pow_x_norm_PA_lin = mean(power(abs(x_norm_PA_lin),2));
            pow_x_norm_PA_nonlin = mean(power(abs(x_norm_PA_nonlin),2));
            % eq. (3) in [4]
            SISDR_norm_dB = 10*log10(pow_x_norm_PA_lin/pow_x_norm_PA_nonlin);
        end
    end
end