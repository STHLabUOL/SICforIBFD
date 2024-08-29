# On Neural-Network Representation of Wireless Self-Interference for Inband Full-Duplex Communications
Gerald Enzner<sup>1</sup>, Aleksej Chinaev<sup>1</sup>, Svantje Voit<sup>1</sup> and Aydin Sezgin<sup>2</sup>
<br></br><sup>1</sup>*[Division Speech Technology and Hearing Aids](https://uol.de/en/speech-technology)*, Carl von Ossietzky Universität Oldenburg, Germany &nbsp;&nbsp; <sup>2</sup>*[Chair of Digital Communication Systems](https://www.dks.ruhr-uni-bochum.de/en/profiles/aydin-sezgin/)*, Ruhr-Universität Bochum, Germany

This repository contains a collection of methods for generating of orthogonal frequency-division multiplex (OFDM) signals used to simulate self-interefence cancellation (SIC) applied to inband full-duplex (IBFD) communications [1].

Two system options (Hammerstein and Wiener) are considered for SIC. The core components required for the simulation are an SI channel and a nonlinear power amplifier. The generated impulse responses of the SI channel show the following power delay profile (PDP)

![Fig2a](https://github.com/user-attachments/assets/c1fe3395-958e-4218-bdeb-96146793b29c)


The amplifier nonlinearities are simulated by two different functions (arctan and limiter) controlled by the parameters $c_f$ and $c_g$, respectively, as defined in [1]. The parameters $c_f$ and $c_g$ are directly related to the scale-invariant signal-to-distortion ratio (SI-SDR), which can be set for signal generation in the range $[10; 70]\,\text{dB}$ according to the following dependencies:

![Fig2b](https://github.com/user-attachments/assets/98a748a8-3aaf-4bcf-8792-a57f4c21f4bf)


While the respective Matlab scripts for data generation are located in the 'Matlab' folder, the 'Data' folder contains the data sets of the experimental evaluation from [1].

Three datasets are generated for Hammerstein (H) and Wiener (W) systems  each, i.e., with variant or invariant SI channel $h_\text{SI}[k]$ and with variant or invariant nonlinearity (NL), labeled as: <br></br>&nbsp;&nbsp; H) ''invNL+invSI'', ''invNL+varSI'', and ''varNL+varSI''<br></br>&nbsp;&nbsp; W) ''invSI+invNL'', ''varSI+invNL'', and ''varSI+varNL''.

Each of the dataset consists of 10 file IDs each representing a time-invariant SI system. The identifier ''inv'' here refers to invariable SI channels or nonlinearities across the data set, while the label ''var'' means a variable SI channel for each file ID based on new path gains for $h_\text{SI}[k]$ or a variable nonlinearity with corresponding $\text{SI-SDR}$ uniformly drawn from the interval $\mathrm{SDR}_0\pm 4\,\mathrm{dB}$.

## References
[1] G. Enzner, A. Chinaev, S. Voit and A. Sezgin: "On Neural-Network Representation of Wireless Self-Interference for Inband Full-Duplex Communications", submitted to IEEE Int. Conf. on Acoust., Speech and Signal Process., 2025.

## Citation
If you use this code or our dataset, please cite our paper:
```
@inproceedings{Enzner2025ibfdcomm,
  title={On Neural-Network Representation of Wireless Self-Interference for Inband Full-Duplex Communications},
  author={Enzner, Gerald and Chinaev, Aleksej and Voit, Svantje and Sezgin, Aydin},
  booktitle={Submitted to IEEE Int. Conf. on Acoust., Speech and Signal Process.},
  month={Apr.},
  year={2025}
}
```
