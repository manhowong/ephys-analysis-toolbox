groups = [70,78,72, 3,9,14, 1,7,11];

quickStat = table;

for i = 1:length(groups)
    quickStat.name(i) = summary.freq{1}.Properties.RowNames(groups(i));
    quickStat.Recording_n(i) = summary.freq{1}.nOfRecording{groups(i)};
    quickStat.Animal_n(i) = summary.freq{1}.nOfAnimal{groups(i)};
    quickStat.Freq_mean(i) = summary.freq{1}.groupMean{groups(i)};
    quickStat.Freq_median(i) = summary.freq{1}.groupMedian{groups(i)};
    quickStat.Freq_sem(i) = summary.freq{1}.groupSEM{groups(i)};
    quickStat.Ampl_mean(i) = summary.Amplitude{1}.groupMean{groups(i)};
    quickStat.Ampl_median(i) = summary.Amplitude{1}.groupMedian{groups(i)};
    quickStat.Ampl_sem(i) = summary.Amplitude{1}.groupSEM{groups(i)};
end

quickStat