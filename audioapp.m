classdef audioapp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        SpectralCentroidButton  matlab.ui.control.Button
        SpectralSlopeButton     matlab.ui.control.Button
        AudioAnalysisAppLabel   matlab.ui.control.Label
        SpectralEntropyButton   matlab.ui.control.Button
        pitch                   matlab.ui.control.Button
        melcepstral             matlab.ui.control.Button
        gtcc                    matlab.ui.control.Button
        mfcc                    matlab.ui.control.Button
        file                    matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: file
        function fileButtonPushed(app, event)
            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);
            [sample_data, fs] = audioread(fullpathname);
            
            
            time = (0:size(sample_data,1)-1)/fs;
            plot(time, sample_data(:,1));
                                    
            
            ylabel('Amplitude')
            xlabel('Time (s)')
            title('Audio Signal')

        end

        % Button pushed function: mfcc
        function mfccButtonPushed(app, event)
            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);
            [audioIn, fs] = audioread(fullpathname);

            twoStart = 110e3;
            twoStop = 135e3;
            audioIn = audioIn(twoStart:twoStop);
            timeVector = linspace((twoStart/fs),(twoStop/fs),numel(audioIn));

            [audioIn,fs] = audioread(fullpathname);
            [coeffs,delta,deltaDelta,loc] = mfcc(audioIn,fs);

            win = hann(1024,"periodic");
            S = stft(audioIn,"Window",win,"OverlapLength",512,"Centered",false);

%             coeffs = mfcc(S,fs,"LogEnergy","Ignore");
%             nbins = 60;
%             coefficientToAnalyze = 4;
%             
%             histogram(coeffs(:,coefficientToAnalyze+1),nbins,"Normalization","pdf")
%             title(sprintf("Coefficient %d",coefficientToAnalyze))

            
            t = linspace(0,size(audioIn,1)/fs,size(audioIn,1));
            subplot(2,1,1)
            plot(t,audioIn)
            ylabel('Amplitude')
            
            t = linspace(0,size(audioIn,1)/fs,size(S,1));
            subplot(2,1,2)
            plot(t,S)
            xlabel('Time (s)')
            ylabel('mfcc')
  


        end

        % Button pushed function: SpectralEntropyButton
        function SpectralEntropyButtonPushed(app, event)
            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);
            [audioIn, fs] = audioread(fullpathname);
            
            
            time = (0:size(audioIn,1)-1)/fs;
            plot(time, audioIn(:,1));
                                    
            twoStart = 110e3;
            twoStop = 135e3;
            sample_data = audioIn(twoStart:twoStop);
            timeVector = linspace((twoStart/fs),(twoStop/fs),numel(audioIn));
            
            sound(sample_data,fs)
            
            entropy = spectralEntropy(audioIn,fs);
            
            t = linspace(0,size(audioIn,1)/fs,size(audioIn,1));
            subplot(2,1,1)
            plot(t,audioIn)
            ylabel('Amplitude')
            
            t = linspace(0,size(audioIn,1)/fs,size(entropy,1));
            subplot(2,1,2)
            plot(t,entropy)
            xlabel('Time (s)')
            ylabel('Entropy')


        end

        % Button pushed function: pitch
        function pitchButtonPushed(app, event)

            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);
            [x,fs] = audioread(fullpathname);
        
            


            f0 = pitch(x,fs);
            t = (0:size(x,1)-1)/fs;
            
            winLength = round(0.05*fs);
            overlapLength = round(0.045*fs);
            [f0,idx] = pitch(x,fs,'Method','SRH','WindowLength',winLength,'OverlapLength',overlapLength);
            tf0 = idx/fs;
            sound(x,fs)
            
            hr = harmonicRatio(x,fs,"Window",hamming(winLength,'periodic'),"OverlapLength",overlapLength);
            
            figure
            tiledlayout(3,1)
            
            nexttile
            plot(t,x)
            ylabel('Amplitude')
            title('Audio Signal')
            axis tight
            
            nexttile
            plot(tf0,f0)
            ylabel('Pitch (Hz)')
            title('Pitch Estimations')
            axis tight
            
            nexttile
            plot(tf0,hr)
            xlabel('Time (s)')
            ylabel('Ratio')
            title('Harmonic Ratio')
            axis tight

            

        end

        % Button pushed function: SpectralSlopeButton
        function SpectralSlopeButtonPushed(app, event)
            
            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);
            
            [x,xFs] = audioread(fullpathname);
            x = x./max(x);
            
            
            xSlope = spectralSlope(x,xFs);
            t = linspace(0,size(x,1)/xFs,size(xSlope,1));
            subplot(2,1,1)
            spectrogram(x,round(xFs*0.05),round(xFs*0.04),round(xFs*0.05),xFs,'yaxis','power')
            
            subplot(2,1,2)
            plot(t,xSlope)
            title('Spectral Slope')
            ylabel('Slope')
            xlabel('Time (s)')

        end

        % Button pushed function: SpectralCentroidButton
        function SpectralCentroidButtonPushed(app, event)
            
            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);

            [audio,fs] = audioread(fullpathname);
            
            centroid = spectralCentroid(audio,fs);
            
            subplot(2,1,1)
            t = linspace(0,size(audio,1)/fs,size(audio,1));
            plot(t,audio)
            ylabel('Amplitude')
            
            subplot(2,1,2)
            t = linspace(0,size(audio,1)/fs,size(centroid,1));
            plot(t,centroid)
            title('Spectral Centroid')
            xlabel('Time (s)')
            ylabel('Centroid (Hz)')

        end

        % Button pushed function: melcepstral
        function melcepstralButtonPushed(app, event)
            
            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);

            [audioIn,fs] = audioread(fullpathname);

            windowLength = round(0.03*fs);
            overlapLength = round(0.015*fs);
            S = stft(audioIn,"Window",hann(windowLength,"periodic"),"OverlapLength",overlapLength,"FrequencyRange","onesided");
            S = abs(S);

            filterBank = designAuditoryFilterBank(fs,'FFTLength',windowLength);
            melSpec = filterBank*S;

            melcc = cepstralCoefficients(melSpec);
%             load handel.mat
%             cqt(y,'SamplingFrequency',Fs)
%             minFreq = Fs/length(y);
%             maxFreq = 2000;
%             figure
%             cqt(y,'SamplingFrequency',Fs,'BinsPerOctave',48,'FrequencyLimits',[minFreq maxFreq])
% 
%             numFilters = 20;
%             
%             filterbankStart = 62.5;
%             filterbankEnd = 8000;
%             
%             numBandEdges = numFilters + 2;
%             NFFT = 1024;
%             filterBank = zeros(numFilters,NFFT);
%             
%             bandEdges = logspace(log10(filterbankStart),log10(filterbankEnd),numBandEdges);
%             bandEdgesBins = round((bandEdges/fs)*NFFT) + 1;
%             
%             for ii = 1:numFilters
%                  filt = triang(bandEdgesBins(ii+2)-bandEdgesBins(ii));
%                  leftPad = bandEdgesBins(ii);
%                  rightPad = NFFT - numel(filt) - leftPad;
%                  filterBank(ii,:) = [zeros(1,leftPad),filt',zeros(1,rightPad)];
%             end
%             frequencyVector = (fs/NFFT)*(0:NFFT-1);


            t = linspace(0,size(audioIn,1)/fs,size(audioIn,1));
            subplot(2,1,1)
            plot(t,audioIn)
            ylabel('Amplitude')
            
            subplot(2,1,2)
            t = linspace(0,size(melcc,1)/fs,size(melcc,1));
            plot(t,melcc)
            title('Mel Cepstral Coeffient')
            xlabel('Time (s)')
            ylabel('Centroid (Hz)')

        end

        % Button pushed function: gtcc
        function gtccButtonPushed(app, event)
            handles.output = app;
            [filename pathname] = uigetfile({'*.wav'},'File Selector')
            fullpathname = strcat(pathname, filename);

            [audioIn,fs] = audioread(fullpathname);

            win = hann(1024,"periodic");
            S = stft(audioIn,"Window",win,"OverlapLength",512,"Centered",false);

            coeffs = gtcc(S,fs,"LogEnergy","Ignore");
            
            nbins = 60;
            coefficientToAnalyze = 4;
            
            histogram(coeffs(:,coefficientToAnalyze+1),nbins,'Normalization','pdf')
            title(sprintf("Coefficient %d",coefficientToAnalyze))
                        
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 400 400];
            app.UIFigure.Name = 'MATLAB App';

            % Create file
            app.file = uibutton(app.UIFigure, 'push');
            app.file.ButtonPushedFcn = createCallbackFcn(app, @fileButtonPushed, true);
            app.file.Position = [117 309 169 22];
            app.file.Text = 'Open Audio File';

            % Create mfcc
            app.mfcc = uibutton(app.UIFigure, 'push');
            app.mfcc.ButtonPushedFcn = createCallbackFcn(app, @mfccButtonPushed, true);
            app.mfcc.Position = [39 120 100 22];
            app.mfcc.Text = 'MFCC ';

            % Create gtcc
            app.gtcc = uibutton(app.UIFigure, 'push');
            app.gtcc.ButtonPushedFcn = createCallbackFcn(app, @gtccButtonPushed, true);
            app.gtcc.Position = [244 120 100 22];
            app.gtcc.Text = 'GTCC ';

            % Create melcepstral
            app.melcepstral = uibutton(app.UIFigure, 'push');
            app.melcepstral.ButtonPushedFcn = createCallbackFcn(app, @melcepstralButtonPushed, true);
            app.melcepstral.Position = [224 180 140 22];
            app.melcepstral.Text = 'Mel Cepstral Coeffients';

            % Create pitch
            app.pitch = uibutton(app.UIFigure, 'push');
            app.pitch.ButtonPushedFcn = createCallbackFcn(app, @pitchButtonPushed, true);
            app.pitch.Position = [143 61 100 22];
            app.pitch.Text = 'Calculate Pitch';

            % Create SpectralEntropyButton
            app.SpectralEntropyButton = uibutton(app.UIFigure, 'push');
            app.SpectralEntropyButton.ButtonPushedFcn = createCallbackFcn(app, @SpectralEntropyButtonPushed, true);
            app.SpectralEntropyButton.Position = [35 241 108 22];
            app.SpectralEntropyButton.Text = ' Spectral Entropy';

            % Create AudioAnalysisAppLabel
            app.AudioAnalysisAppLabel = uilabel(app.UIFigure);
            app.AudioAnalysisAppLabel.HorizontalAlignment = 'center';
            app.AudioAnalysisAppLabel.FontWeight = 'bold';
            app.AudioAnalysisAppLabel.Position = [143 359 118 22];
            app.AudioAnalysisAppLabel.Text = 'Audio Analysis App';

            % Create SpectralSlopeButton
            app.SpectralSlopeButton = uibutton(app.UIFigure, 'push');
            app.SpectralSlopeButton.ButtonPushedFcn = createCallbackFcn(app, @SpectralSlopeButtonPushed, true);
            app.SpectralSlopeButton.Position = [244 241 100 22];
            app.SpectralSlopeButton.Text = 'Spectral Slope';

            % Create SpectralCentroidButton
            app.SpectralCentroidButton = uibutton(app.UIFigure, 'push');
            app.SpectralCentroidButton.ButtonPushedFcn = createCallbackFcn(app, @SpectralCentroidButtonPushed, true);
            app.SpectralCentroidButton.Position = [36 180 108 22];
            app.SpectralCentroidButton.Text = 'Spectral Centroid';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = audioapp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end