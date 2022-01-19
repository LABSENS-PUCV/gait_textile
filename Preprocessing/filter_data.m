function filtered = filter_data(datos)
    sz = size(datos);
    filtered = [datos(:,1)];
    %Butterworth Lowpass Filter Parameters
    fc = 20;
    fs = 80;
    N = 5;
    [b,a] = butter(N,fc/(fs/2),'low');  %Creating the butterworth filter
    %freqz(b,a)
    for j = 2:sz(2)
        filt_med = medfilt1(datos(:,j),3); %Median Filter       
        filt_but = filter(b,a, datos(:,j));   %Applying butterworth filter
        filtered = [filtered filt_med]; 
    end
end