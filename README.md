# On Neural-Network Representation of Wireless Self-Interference for Inband Full-Duplex Communications
Gerald Enzner<sup>1</sup>, Aleksej Chinaev<sup>1</sup>, Svantje Voit<sup>1</sup> and Aydin Sezgin<sup>2</sup>
<br></br><sup>1</sup>*[Division Speech Technology and Hearing Aids](https://uol.de/en/speech-technology)*, Carl von Ossietzky Universität Oldenburg, Germany &nbsp;&nbsp; <sup>2</sup>*[Chair of Digital Communication Systems](https://www.dks.ruhr-uni-bochum.de/en/profiles/aydin-sezgin/)*, Ruhr-Universität Bochum, Germany

This repository includes collection of methods for generation of the Orthogonal frequency-division multiplex (OFDM) signals used for simulation of the self-interefence cancellation (SIC) applied to inband full-duplex (IBFD) communications [1].

Two system options with SIC are considered: Hammerstein and Wiener. Two core components of both systems are a SI channel and a nonlinear power amplifier. The generated impulse responses of SI channel show the following power delay profile (PDP)

[Fig. 2(a)]

The amplifier nonlinearities are simulated by two different nonlinear functions defined in [1] with the following demendencies between their parameters and scale-invariant signal-to-distortion ratio (SI-SDR)

[Fig. 2(a)]

While the respective Matlab scripts for data generation are placed in the 'Matlab' folder, the 'Data' folder contains the datasets of the experimental evaluation in [1].

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
