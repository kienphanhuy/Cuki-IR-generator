% Cuki IR light algorithm without Graphic User interface or recording interface
% To be used as
%  IRgen2('filename.wav')
% filename must be a stereo file with a recording of the acoustic guitar (around 1-3 min) 
% Left: Pickup track
% Right: Microphone track

function IRgen2(filename)
% Pickup left
% Mic right
close all
%[filename, pathname] = uigetfile({'*.wav','wav files'}, 'Choose a y file');
  %Fname='rec24_48000GtL_MicR_.wav';
  %[y,FS]=audioread([pathname,filename]);
  [y,FS]=audioread(filename);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set bitdepth
  %%%%%%%%%%%%%%%%%%%%%%%%%%%

  
##  handles.nbits=nbits;  
##  handles.y=y;
##  handles.fs=FS;
##  guidata(hObject,handles);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    frac=0;
  %h = waitbar (frac,'Computing...');
  %axes(ax2)
  %cla
  rectangle('Position',[0,0,(round(1000*0))+1,1],'FaceColor','b'); 
  xlim([0 100])
  ylim([0 1])
  text(480,10,[num2str(round(100*0)),'%']);
  %pause(0.01)                
  %handles = guidata(hObject);
  %y=handles.y;
  fs=FS; %handles.fs;
  %nbits=handles.nbits;
  nbits=24;
  Nb=size(y,1);  

  %indxinput=get(icfg,'value');
  %if indxinput==1
    MIC=y(:,2); %mic;
    PIC=y(:,1); %pic;    
##  else  
##    MIC=y(:,1); %mic;
##    PIC=y(:,2); %pic;    
##  endif   
  Nb=size(y,1);
##  indxfmt=get(fsfmt,'value');
##  if (indxfmt == 1)||(indxfmt == 4) 
##  NbF=1024;     
##  endif  
##  if (indxfmt == 2)||(indxfmt == 5) 
  NbF=2048;     
##  endif  
##  if (indxfmt == 3)||(indxfmt == 6) 
##  NbF=8096;     
##  endif  
  
  Nbuff=fs;
  Nbmax=floor(Nb/Nbuff)-10;
  FS=fs;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIR calculaiton
FIR1 =zeros(NbF,1);
clear alice;

for n=1:Nbmax, % 200
        q=n;
        i=2*FS;
        i=i+n*Nbuff;
        
%        window = (.42-.5*cos(2*pi*(0:Nbuff-1)/(Nbuff-1))+.08*cos(4*pi*(0:Nbuff-1)/(Nbuff-1)))';
%        FIR=fft(MIC(i:i+Nbuff-1).*window,NbF)./fft(PIC(i:i+Nbuff-1).*window,NbF);
        FIR=fft(MIC(i:i+Nbuff-1),NbF)./fft(PIC(i:i+Nbuff-1),NbF);
        IR=zeros(Nbuff,1);
        IR(1:NbF)=real(ifft(FIR));
        IR=IR/max(abs(IR));

        if ((max(isinf(FIR))==1)||(max(isnan(FIR))==1))
            IR=zeros(Nbuff,1);
            IR(1)=1;
            FIR=fft(IR,NbF);
            display('NaN or Inf');
        end;    

        
        alice(1:NbF,q)=FIR;
        FIR1=FIR1+FIR;
        if mod(round(n/Nbmax*100),10)==0
                  %round(n/Nbmax*100)
                  %waitbar (n/Nbmax/3, h);
                  %axes(ax2)
                  %cla
	                rectangle('Position',[0,0,(round(100*n/Nbmax)),1],'FaceColor','b'); 
                  text(480,10,[num2str(round(100*n/Nbmax)),'%']);
                  xlim([0 100])
                  ylim([0 1]) 
                  pause(0.01)
                  title('Processing 1/3....')
            %waitbar(n/Nbmax,f,'Processing...');
        end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Post selection Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

NN=size(alice,1);
    for i=1:NN, % POur chaque frequence
        a=alice(i,:);
        
        A=a(abs(abs(a)-mean(a))<2*std(a)); % On ne garde que les echantillons compris dans 2 ecarts types
        
        ALICE(i)=mean(A);
        if isnan(mean(A)),
            %display('Algorithm Failed: Increase the recording length and/or improve the S/N ratio');
            ALICE(i)=1;
        end
        Q(i)=length(A);
        if mod(round(i/NN*100),10)==0
                  %round(n/Nbmax*100)
                  %waitbar (1/3+i/NN/3, h);
                  %axes(ax2)
                  cla
                  rectangle('Position',[0,0,(round(100*i/NN)),1],'FaceColor','b'); 
                  text(480,10,[num2str(round(100*i/NN)),'%']);
                  xlim([0 100])
                  ylim([0 1]) 
                  %text(480,10,[num2str(round(100*(1/3+i/NN/3))),'%']);
                  title('Processing 2/3....')
                  pause(0.01)
            %waitbar(n/Nbmax,f,'Processing...');
        end;
    end;
dnuX=FS/NbF;
nuX=(-NbF/2:NbF/2-1)*dnuX;
nn=NbF/2+1:NbF;

window = (.42-.5*cos(2*pi*(0:2*NbF-1)/(2*NbF-1))+.08*cos(4*pi*(0:2*NbF-1)/(2*NbF-1)))';
blackmanwin=window(NbF+1:end);
ir2=ifft(ALICE);
ir2=ir2.*blackmanwin';
ir2=ir2/max(abs(ir2))*0.95;
IR2(1:NbF,1)=real(ir2);% raw IR generated

%plot(IR2)
IR0=IR2;
nn=(10*FS+1:20*FS);
MS=MIC(nn,1);
PS=PIC(nn,1);

%waitbar(0.6, h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Two Octave spectrum (Mic & Pic convolved)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%pkg load signal;
PS=conv(PIC(nn,1),IR0,'same');

[p,cf,overall_lev,overall_levA,sfilt] = oct_spectrum2(MS/max(abs(MS)),FS,3,1,1,0);
[p2,cf2,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS/max(abs(PS)),FS,3,1,1,0);

pp=[p+100;p2+100];

##figure(10)
##c=bar(log10(cf),pp')
##%c=bar(log10(cf),p+100)
##grid on
##legend('Mic','Convolved Pickup')
## xlabel('Frequency 10^n (Hz)')
##ylabel('dB')
##figure(3)
##plot(10*log10(cf),p-p2)

g0=p-p2; % SB-SB2;    
%dgain=zeros(31,1); % il est là le problème
dgain=zeros(length(cf),1); % il est là le problème


for qq=1:3, % iteration GEQ fit
    IRX=zeros(NbF,1);
    IRX(1)=1;
    IR1=IR0;
    
    for i=1:length(p) % Browse each frequency of the octave spectrum
        g=g0(i)+dgain(i); % dgain terme correctif GEQ fit
        Q=4;
        fc=cf(i);
        
        
        % IIR coefficient calculation
        g=10^(g/20);
        t0=2*pi*fc/fs;
        if g >= 1
            beta=t0/(2*Q);
        else
            beta=t0/(2*g*Q);
        endif
        a2=-0.5*(1-beta)/(1+beta);
        a1=(0.5-a2)*cos(t0);
        b0=(g-1)*(0.25+0.5*a2)+0.5;
        b1=-a1;
        b2=-(g-1)*(0.25+0.5*a2)-a2;
        
        % SOS Form
        b=2*[b0 b1 b2];
        a=[1 -2*a1 -2*a2];
        IRX=filter(b,a,IRX); % test
        IR1=filter(b,a,IR1); % final
        
        mot=['b',num2str(i,'%02d'),'=b;'];
        eval(mot);
        mot=['a',num2str(i,'%02d'),'=a;'];
        eval(mot);

    end;
    
    
    dnuX=FS/NbF;
    nuX=(-NbF/2:NbF/2-1)*dnuX;
    nn=NbF/2+1:NbF;
    s0=20*log10(abs(fftshift(fft(IRX)))); % compute the GEQ spectrum
    
##    figure(1)  
##    plot(10*log10(nuX(nn)),s0(nn))
    
    
    dxx=(nuX(2)-nuX(1))/2;
    for i=1:length(cf)
        n=(abs(nuX-cf(i))<dxx);
        gainGEQ(i)=s0(n); % compute the GEQ spectrum at the octave frequencies
    end;
    
##    %cl=lines(qq+1);
##    figure(3)
##    hold on
##    %plot(10*log10(cf),gainGEQ,'o-')
##    plot(10*log10(nuX(nn)),s0(nn))
##    hold off
    
    dgain=dgain-(gainGEQ'-g0')/2;

    %waitbar(2/3+qq*0.1, h);
##    axes(ax2)
    cla
	  rectangle('Position',[0,0,(round(100*(qq/3)))+1,1],'FaceColor','b'); 
    %text(480,10,[num2str(round(100*(2/3+qq*0.1))),'%']);
    xlim([0 100])
                  ylim([0 1]) 
    title('Processing 3/3 ...')
    pause(0.01)
end;
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IR1=IR1/max(abs(IR1))*0.95;
s1=20*log10(abs(fftshift(fft(IR1)))); % compute the GEQ spectrum
n2=NbF/2+2:NbF;
figure
semilogx(nuX(n2),s1(n2));
%semilogx(nuX(n2),s1(n2));
grid on
xlim([20 22050])
xlabel('frequency (Hz)')
ylabel('dB')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  handles.IR1=IR1; % GEQ IR
%  handles.IR2=IR2; % Raw IR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save IR file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function Save(hObject, eventdata,ax,ai,devinfo,fsfmt,icfg,listfmt,Svfmt,Fnam)
  
  %handles = guidata(hObject);
  rawIR=IR2;
  IRGEQ=IR1;
  Nb=size(IRGEQ,1);  

  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Standard
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    Fname=['IR_',filename(1:end-4),'_M.wav'];
    audiowrite(Fname,IRGEQ/max(abs(IRGEQ))*0.95,fs,'BitsPerSample',nbits);
    
    Fname=['IR_',filename(1:end-4),'_Std.wav'];
    audiowrite(Fname,rawIR/max(abs(rawIR))*0.95,fs,'BitsPerSample',nbits);
  Fname2=['IR_',filename(1:end-4),'.jpg'];
    print(gcf,Fname2,'-djpeg','-r300');
  
    % raw+Blend
    IR0=zeros(Nb,1);
    IR0(1)=1;
    IRblend=(IR0+rawIR)/2;    
    Fname2=['IR_',filename(1:end-4),'_Bld.wav'];
    audiowrite(Fname2,IRblend/max(abs(IRblend))*0.95,fs,'BitsPerSample',nbits);
    
##  figure
##  plot(IRGEQ)
##  grid on


end;  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub-function from J. O Smith
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##function [rw] = fold(r) 
##% [rw] = fold(r) 
##% Fold left wing of vector in "FFT buffer format" 
##% onto right wing 
##% J.O. Smith, 1982-2002
##  
##   [m,n] = size(r);
##   if m*n ~= m+n-1
##     error('fold.m: input must be a vector'); 
##   end
##   flipped = 0;
##   if (m > n)
##     n = m;
##     r = r.';
##     flipped = 1;
##   end
##   if n < 3, rw = r; return; 
##   elseif mod(n,2)==1
##       nt = (n+1)/2; 
##       rw = [ r(1), r(2:nt) + conj(r(n:-1:nt+1)), ...
##             0*ones(1,n-nt) ]; 
##   else 
##       nt = n/2; 
##       rf = [r(2:nt),0]; 
##       rf = rf + conj(r(n:-1:nt+1)); 
##       rw = [ r(1) , rf , 0*ones(1,n-nt-1) ]; 
##   end 
##
##   if flipped
##     rw = rw.';
##   end
##end   
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
##   function [clipped] = clipdb(s,cutoff)
##% [clipped] = clipdb(s,cutoff)
##
##% Clip magnitude of s at its maximum + cutoff in dB.
##% Example: clip(s,-100) makes sure the minimum magnitude
##% of s is not more than 100dB below its maximum magnitude.
##% If s is zero, nothing is done.
##
##clipped = s;
##as = abs(s);
##mas = max(as(:));
##if mas==0, return; end
##if cutoff >= 0, return; end
##thresh = mas*10^(cutoff/20); % db to linear
##toosmall = find(as < thresh);
##clipped = s;
##clipped(toosmall) = thresh;
##end

%% OCTAVE SPECTRUM
%   Computation of octave spectrum and its overall level with dB-A weighting
%   In compliance with specification for octave-band and fractional-octave band
%   analog and digital filters ANSI S1.11-2004   
%
%   INPUTS
%   s = input signal
%   fs = sampling frequency
%   b = octave ratio reccomended 1 or 3
%   dbRef = standard reference for decibel scale calculation, default value: 1
%   weightFlag = A-weighting [0,1], default value: 1
%   plotFlag = generate octave diagram [0,1], default value: 1
%
%   INPUTS
%   S = octave spectrum (dB)
%   fm = midband frequency
%   overall_lev = overall level
%   overall_levA = weighted overall level
%   sfilt = third-octave filtered signals
%
% M. Buzzoni
% Dec. 2018
% Mod by Kien Phan Huy
function [S,fm,overall_lev,overall_levA,sfilt] = oct_spectrum2(s,fs,b,dbRef,weightFlag,plotFlag);

if nargin < 3
  b = 3;
  dbRef = 1;
  weightFlag = 1;
  plotFlag = 1;
end

if nargin < 4
  dbRef = 1;
  weightFlag = 1;
  plotFlag = 1;
end

if nargin < 5
  weightFlag = 1;
  plotFlag = 1;
end

if nargin < 6
  weightFlag = 1;
end

s = s(:)';
L = length(s);
G = 10^(3/10); % octave ratio, base 10
fr = 1000; % reference frequency
x = 1:43; % band number
Gstar = G.^((x - 30)/b);
fm = Gstar.*fr; % midband frequency
f2 = G.^(+1/(2*b)).*fm;  % upper bandedge freq.

ind2cut = or(f2 < 20, f2 > fs/2); % check for exceeding frequency bins
fm(ind2cut) = [];
f2(ind2cut) = [];
x(ind2cut) = [];
f1 = G.^(-1/(2*b)).*fm; % lower bandedge freq. 

Br = (f2 - f1)./fm; % normalized reference bandwidth
sfilt = zeros(length(x),L); % initialization of third-octave filtered signals

overall_lev = 10.*log10((rms2(s)./dbRef).^2); % overall level

if weightFlag == 1
% weighting function
ff = (0:L-1)*fs/L;
ff = ff(1:(floor(L/2)+1));
num = (3.5041384*10^16) * ff.^8;
den = (20.598997^2 + ff.^2).^2 .* (107.65265^2 + ff.^2) .* (737.86223^2 + ff.^2) .* (12194.217^2 + ff.^2).^2;
alphaA = num./den; alphaA = [alphaA fliplr(alphaA(2:end - 1))];
s = real(ifft(fft(s) .* alphaA)); % A-weighted signal
end

% filtering
for k = 1:length(x)
  %[B, A] = butter (2,[f1(k) f2(k)]./(fs/2));
  [B,A]= bp_synth(2,(f1(k)+f2(k))/2,abs(f1(k)-f2(k)),fs);
  sfilt(k,:) = filter(B,A,s);
end

% octave spectrum
S = 10.*log10((rms2(sfilt') ./dbRef).^ 2); % band levels in dB or dBA

% weighted overall level
if weightFlag == 1
  overall_levA = 10*log10(sum(10.^(S/10)));
else
  overall_levA = 0;
end

% plot
Smin = min(S);
if plotFlag == 1
  figure('Position',[40 40 1400 500])
  h = bar([S Smin - 5 Smin - 5],'b','BaseValue',Smin - 3,'barwidth',.3);
  
  if weightFlag == 1
    hold on, bar(length(S)+1,overall_levA,'g','BaseValue',Smin - 3,'barwidth',.3)
  end
  
  hold on, bar(length(S)+2,overall_lev,'r','BaseValue',Smin - 3,'barwidth',.3)
  ylim([Smin - 3 max([overall_lev overall_levA S]) .* 1.1])
  xlim([0 length(S)+4])
  
  if b == 3
    title(['third-octave spectrum'])
  elseif b == 1
    title(['octave spectrum'])
  else
    title(['1/' num2str(b) ' octave spectrum'])
  end
  
  xlabel('midband frequency (Hz)')

  if weightFlag == 1
    ylabel('dBA')
  else
    ylabel('dB')
  end
  
  xticks(1:length(S) + 2)
  xticklabels(round(fm))
  box off
  set (gca, 'ygrid', 'on');
  
  if weightFlag == 1
    hleg = legend('octave levels','overall (A)','overall','location','eastoutside');
  else
    hleg = legend('octave levels','overall','location','eastoutside');
  end
  
  yticks(floor(Smin - 3 ):3:(max([overall_lev overall_levA S]) .* 1.1))
end
endfunction

% RMS function
function rms=rms2(x)
  N=length(x);
  rms=sqrt(1/N*sum(x.^2));
endfunction

%function [b,a]= bp_synth(N,fcenter,bw,fs)      12/29/17 neil robertson
% Synthesize IIR Butterworth Bandpass Filters
%
% N= order of prototype LPF
% fcenter= center frequency, Hz
% bw= -3 dB bandwidth, Hz
% fs= sample frequency, Hz
% [b,a]= vector of filter coefficients
% https://www.dsprelated.com/showarticle/1128.php
function [b,a]= bp_synth(N,fcenter,bw,fs)
f1= fcenter- bw/2;            % Hz lower -3 dB frequency
f2= fcenter+ bw/2;            % Hz upper -3 dB frequency
if f2>=fs/2;
   error('fcenter+ bw/2 must be less than fs/2')
end
if f1<=0
   error('fcenter- bw/2 must be greater than 0')
end
% find poles of butterworth lpf with Wc = 1 rad/s
k= 1:N;
theta= (2*k -1)*pi/(2*N);
p_lp= -sin(theta) + j*cos(theta);    
% pre-warp f0, f1, and f2
F1= fs/pi * tan(pi*f1/fs);
F2= fs/pi * tan(pi*f2/fs);
BW_hz= F2-F1;              % Hz prewarped -3 dB bandwidth
F0= sqrt(F1*F2);           % Hz geometric mean frequency
% transform poles for bpf centered at W0
% note:  alpha and beta are vectors of length N; pa is a vector of length 2N
alpha= BW_hz/F0 * 1/2*p_lp;
beta= sqrt(1- (BW_hz/F0*p_lp/2).^2);
pa= 2*pi*F0*[alpha+j*beta  alpha-j*beta];
% find poles and zeros of digital filter
p= (1 + pa/(2*fs))./(1 - pa/(2*fs));      % bilinear transform
q= [-ones(1,N) ones(1,N)];                % N zeros at z= -1 (f= fs/2) and z= 1 (f = 0)
% convert poles and zeros to numerator and denominator polynomials
a= poly(p);
a= real(a);
b= poly(q);
% scale coeffs so that amplitude is 1.0 at f0
f0= sqrt(f1*f2);
h= freqz(b,a,[f0 f0],fs);
K= 1/abs(h(1));
b= K*b;
endfunction



  
##Copyright (c) 2019, Marco Buzzoni
##All rights reserved.
##
##Redistribution and use in source and binary forms, with or without
##modification, are permitted provided that the following conditions are met:
##
##* Redistributions of source code must retain the above copyright notice, this
##  list of conditions and the following disclaimer.
##
##* Redistributions in binary form must reproduce the above copyright notice,
##  this list of conditions and the following disclaimer in the documentation
##  and/or other materials provided with the distribution
##* Neither the name of Università degli Studi di Ferrara nor the names of its
##  contributors may be used to endorse or promote products derived from this
##  software without specific prior written permission.
##THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
##AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
##IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
##FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
##DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
##SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
##CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
##OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
##
##``Introduction to Digital Filters with Audio Applications'', by Julius O. Smith III, (September 2007 Edition).
##Copyright © 2020-05-11 by Julius O. Smith III
##Center for Computer Research in Music and Acoustics (CCRMA),   Stanford University
##
##Copyright (c) 2014, Yuanfei
##All rights reserved.
##
##Redistribution and use in source and binary forms, with or without
##modification, are permitted provided that the following conditions are met:
##
##* Redistributions of source code must retain the above copyright notice, this
##  list of conditions and the following disclaimer.
##
##* Redistributions in binary form must reproduce the above copyright notice,
##  this list of conditions and the following disclaimer in the documentation
##  and/or other materials provided with the distribution
##* Neither the name of  nor the names of its
##  contributors may be used to endorse or promote products derived from this
##  software without specific prior written permission.
##THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
##AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
##IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
##FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
##DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
##SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
##CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
##OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.