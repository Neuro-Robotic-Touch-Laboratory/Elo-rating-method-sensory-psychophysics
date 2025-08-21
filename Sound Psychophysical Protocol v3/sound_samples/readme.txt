directory filename format: SampleDuration_Ffreq_Gfreq_G#freq_Afreq_A#freq_Bfreq_Cfreq
sample filename format: SampleDuration_SoundName_FirstToneFreq_SecondToneFreq

In each directory you should find four samples, with the same duration, with waveforms going from 1 to -1.
The samples should be AA# AB AD and AE, with A having the same frequency for all the samples, and the other
tones being coherent, maintaining the ratios.

the noclicks.m matlab source code converts a sound sample generated as a simple pure sinusoid, that produces
clicks at the start and the end of the playing, into a sound sample that doesn't produce clicks.
noclicks_total does the same not for a specified audio sample but for all the audio samples in the folders.
WARNING (do not run this codes on audio samples that have already been converted, you can produce click-free
sounds directly from the labview vi 'soundwave_generator_v02_file_generator_no_clicks.vi' in this project.