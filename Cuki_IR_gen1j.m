% Acoustic guitar IR generator "light" 1.0
% Author: Kien Phan Huy on the 14th of July 2020. Copyright 2020
% Uses the Min Phase response computation from J.O. Smith, 1982-2002
% Uses amodified version of Oct_spectrum from M. Buzzoni, Dec. 2018
% Uses IIR butterworth coefficient computation from Neil Robertson , 12/29/17
% Uses embbeded waitbar Yuanfei (2020). Embedding Waitbar Inside A GUI (https://www.mathworks.com/matlabcentral/fileexchange/47896-embedding-waitbar-inside-a-gui), MATLAB Central File Exchange. Retrieved July 15, 2020. 
% See copyrights for subfunctions and rootine below
function Cuki_IR_gen1i()
  % Creation figure
  dlg = figure('name','Cuki IR generator light v1.0', 'position',[143 129 1024 768], 'menubar','none', 'numbertitle','off');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation axes
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %axes1=axes(dlg,'position',[200,100,640,480])
  %h=plot(dlg,1:10,1:10,'-o')
  ax = axes();
  %set(gca,'position',[0.3   0.15   0.65   0.6])
  set(gca,'units','pixels','position',[305   115   665   430])
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   uicontrol('style','text', 'string','1) Select your configuration:', ...
      'position',[20 740 280 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
    % Creation du menu deroulant
  icfg=uicontrol(dlg,'style','popupmenu', 'string',{'Pickup in CH1, Mic in CH2','Pickup in CH2, Mic in CH1'}, ...
      'position',[300 740 300 30]);  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
  hh=-15; % decalage tout sauf début
  h2=-30; % décalage sous interface audio
  dd=100; % décalage droite interface audio
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
  % Wait bar
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  ax2=axes()
  set(gca,'units','pixels','Position',[450 635+hh+h2 500 20]);
  %ax2=axes(dlg,'Position',[0.45 0.8 0.4 0.03]);
  set(ax2,'Xtick',[],'Ytick',[],'Xlim',[0 1000]);
  box on;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation liste des interface audio  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','2) Choose audio interface+driver:', ...
      'position',[20 710+hh 500 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  nDevices = audiodevinfo(0);
  devinfo = audiodevinfo();
  mot=['liste= {''',devinfo.input(1).Name,''''];
  for i=2:nDevices,
     mot=[mot,',''',devinfo.input(i).Name,''''];
  end
  mot=[mot,'};'];
  eval(mot);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','Input:', ...
      'position',[50 680+hh dd 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation du menu deroulant INPUT
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ai=uicontrol(dlg,'style','popupmenu', 'string',liste, ...
      'position',[20+dd 680+hh 500 30], 'callback', @cbk_popupmenu);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  mot=['liste2= {''',devinfo.output(1).Name,''''];
  for i=2:nDevices,
     mot=[mot,',''',devinfo.output(i).Name,''''];
  end
  mot=[mot,'};'];
  eval(mot);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','Output:', ...
      'position',[50 640+hh dd 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation du menu deroulant OUTPUT
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ao=uicontrol(dlg,'style','popupmenu', 'string',liste2, ...
      'position',[20+dd 640+hh 500 30]);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation liste des frequences d'echantillonage
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','3) Choose Frequency sampling:', ...
      'position',[550+dd 710+hh 250 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fsliste=uicontrol(dlg,'style','popupmenu', 'string',{'44100','48000'}, ...
      'position',[550+dd 680+hh 250 30]);
  bitdepth=uicontrol(dlg,'style','popupmenu', 'string',{'16 bits','24 bits'}, ...
      'position',[550+dd 640+hh 250 30],'value',2);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Record quick, test levels
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','4) Test recording and check levels (optional):', ...
      'position',[20 630+hh+h2 400 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  
  uicontrol(dlg, 'style','pushbutton', 'string','Record 10s', 'position',[20 600+hh+h2 150 30], 'callback',{@record20s, ax,ai,devinfo,fsliste,ax2,bitdepth });
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Record long to make IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','5) Record for IR generation:', ...
      'position',[20 550+hh+h2 220 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  Trec=uicontrol(dlg,'style','popupmenu', 'string',{'1 min','2 min'}, ...
      'position',[150 520+hh+h2 100 30]);
 
  uicontrol(dlg, 'style','pushbutton', 'string','Record', 'position',[20 520+hh+h2 100 30], 'callback',{@record2mn, ax,ai,devinfo,fsliste,Trec,ax2,bitdepth});
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation liste des formats de sortie
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','6) IR file format:', ...
      'position',[20 470+hh+h2 200 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  listfmt={'1024 pts, 16 bits','2048 pts, 16 bits','8096 pts, 16 bits','1024 pts, 24 bits','2048 pts, 24 bits','8096 pts, 24 bits'};
  fsfmt=uicontrol(dlg,'style','popupmenu', 'string',listfmt, ...
      'position',[20 440+hh+h2 200 30],'value',2);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Compute IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','7) Compute IR:', ...
      'position',[20 390+hh+h2 200 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  uicontrol(dlg, 'style','pushbutton', 'string','Compute IR', 'position',[20 360+hh+h2 150 30], 'callback',{@Go, ax,ai,devinfo,fsfmt,icfg,ax2});
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Listen
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','8) Listen:', ...
      'position',[20 310+hh+h2 200 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  uicontrol(dlg, 'style','pushbutton', 'string','Mic', 'position',[20 280+hh+h2 70 30], 'callback',{@Mic,ax,ai,devinfo,fsfmt,icfg,ao});  
  uicontrol(dlg, 'style','pushbutton', 'string','Pickup', 'position',[100 280+hh+h2 70 30], 'callback',{@Pickup,ax,ai,devinfo,fsfmt,icfg,ao});  
  uicontrol(dlg, 'style','pushbutton', 'string','IR', 'position',[180 280+hh+h2 70 30], 'callback',{@IR,ax,ai,devinfo,fsfmt,icfg,ao});  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Save IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol('style','text', 'string','8) Save IR file:', ...
      'position',[20 230+hh+h2 200 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  Svfmt=uicontrol(dlg,'style','popupmenu', 'string',{'Standard','Various flavours','Feedback friendly'}, ...
      'position',[20 200+hh+h2 230 30]);
  if ispc   
      uicontrol(dlg, 'style','pushbutton', 'string','Save', 'position',[20 160+hh+h2 150 30], 'callback',{@Save,ax,ai,devinfo,fsfmt,icfg,listfmt,Svfmt});
  endif
  if ismac
      uicontrol('style','text', 'string','Filename:', ...
      'position',[20 160+hh+h2 72 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');  
      Fnam=uicontrol('style','edit', 'string','IR.wav', ...
      'position',[100 160+hh+h2 150 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');      
      uicontrol(dlg, 'style','pushbutton', 'string','Save', 'position',[20 120+hh+h2 150 30], 'callback',{@Save,ax,ai,devinfo,fsfmt,icfg,listfmt,Svfmt,Fnam});    
  endif  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Close dlg
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol(dlg, 'style','pushbutton', 'string','Close', 'position',[20 20 150 30], 'callback',{@Close,ax,dlg});
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Donate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  uicontrol(dlg, 'style','pushbutton', 'string','Donate', 'position',[200 20 150 30], 'callback',{@Donate,dlg});
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Paypal gift
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uicontrol('style','text', 'string','Copyright: Kien Phan Huy, July 2020', ...
      'position',[730 20 500 30], ...
      'foregroundcolor', 'b', 'backgroundcolor','w', ...
      'fontangle','italic', 'horizontalalignment','left');
  pause(0.1);
  set(dlg,'position',[143 129 1024 768]); % pour Mac

end;

function cbk_popupmenu(hObject, eventdata)
%  menu_itemms = get(h,'string');
%  disp(menu_itemms{get(hObject,'value')})
end

function record20s(hObject, eventdata,ax,ai,devinfo,fsliste,ax2,bitdepth)
%  disp('record')
  indx=get(ai,'value');
  id=devinfo.input(indx).ID;
  channels=2;
  %nbits=24;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  indxfs=get(fsliste,'value');
  if indxfs==1
    fs=44100;
    %display('44100');
  else    
    fs=48000;
    %display('48000');
  endif;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set bitdepth
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  indxbits=get(bitdepth,'value');
  if indxbits==1
    nbits=16;
  else    
    nbits=24;
  endif;  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  recorder = audiorecorder (fs, nbits, channels, id);
  length=10;
  record(recorder);
  frac=0;
  %h = waitbar (frac,'Recording...');
  for i=1:length
    axes(ax2)
    cla
	  rectangle('Position',[0,0,(round(1000*i/length))+1,20],'FaceColor','b'); 
    text(480,10,[num2str(round(100*i/length)),'%']);
     %waitbar (i/length, h);
     pause(1)
  end;
  stop(recorder)
  %close(h)
  
  y = getaudiodata (recorder);
  Nb=size(y,1);
  t=(1:Nb)/fs;
  nnn=1:100:Nb;
  plot(ax,t(nnn),y(nnn,1),t(nnn),y(nnn,2));
  grid on
  hold on
  plot(ax,[t(1) t(Nb)],[0.1 0.1],'Color','k','linewidth',3)
  plot(ax,[t(1) t(Nb)],[-0.1 -0.1],'Color','k','linewidth',3)
  ylim([-1 1])
  hold off
  if max(max(abs(y)))<=0.1
    title('The signal is too weak (within black lines), increase the gain','Color',[1 0 0])
  elseif max(max(abs(y)))>=1
    title('Distortion decteted: decrease the gain','Color',[1 0 0])
  else
    title('Check the signal is not too weak (see black lines)','Color',[0 0 0])
  endif;
  clear recorder

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recording 1 mn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function record2mn(hObject, eventdata,ax,ai,devinfo,fsliste,Trec,ax2,bitdepth)
%  disp('record')
  indx=get(ai,'value');
  id=devinfo.input(indx).ID;
  channels=2;
  %nbits=24;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set frequency sampling
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  indxfs=get(fsliste,'value');
  if indxfs==1
    fs=44100;
    %display('44100');
  else    
    fs=48000;
    %display('48000');
  endif;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set bitdepth
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  indxbits=get(bitdepth,'value');
  if indxbits==1
    nbits=16;
  else    
    nbits=24;
  endif;  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set Rec time
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  T=get(Trec,'value');
  if T==1
    length=1*60;
  else    
    length=2*60;
  endif;

  
  recorder = audiorecorder (fs, nbits, channels, id);
  
  record(recorder);
  frac=0;
  %h = waitbar (frac,'Recording...');
  for i=1:length
     %waitbar (i/length, h);
    axes(ax2)
    cla
	  rectangle('Position',[0,0,(round(1000*i/length))+1,20],'FaceColor','b'); 
    text(480,10,[num2str(round(100*i/length)),'%']);

     pause(1)
  end;
  stop(recorder)
  %close(h)
  
  y = getaudiodata (recorder);
  Nb=size(y,1);
  t=(1:Nb)/fs;
  nnn=1:1000:Nb;
  plot(ax,t(nnn),y(nnn,1),t(nnn),y(nnn,2));
  grid on
  hold on
  plot(ax,[t(1) t(Nb)],[0.1 0.1],'Color','k','linewidth',3)
  plot(ax,[t(1) t(Nb)],[-0.1 -0.1],'Color','k','linewidth',3)
  ylim([-1 1])
  xlim([t(1) t(Nb)])
  xlabel('time(s)')
  ylabel('amplitude (a.u.)')
  hold off
##  if max(max(abs(y)))<=0.1
##    title('The signal is too weak (within black lines), increase the gain','Color',[1 0 0])
##  elseif max(max(abs(y)))>=1
##    title('Distortion decteted: decrease the gain','Color',[1 0 0])
##  else
##    title('Check the signal is not too weak (see black lines)','Color',[0 0 0])
##  endif;
  clear recorder
  handles.y=y;
  handles.fs=fs;
  handles.nbits=nbits;
  guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Go: Compute IR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Go(hObject, eventdata,ax,ai,devinfo,fsfmt,icfg,ax2)
  frac=0;
  %h = waitbar (frac,'Computing...');
  axes(ax2)
  cla
  rectangle('Position',[0,0,(round(1000*0))+1,20],'FaceColor','b'); 
  text(480,10,[num2str(round(100*0)),'%']);
  pause(0.01)                
  handles = guidata(hObject);
  y=handles.y;
  fs=handles.fs;
  nbits=handles.nbits;
  Nb=size(y,1);  

  indxinput=get(icfg,'value');
  if indxinput==1
    MIC=y(:,2); %mic;
    PIC=y(:,1); %pic;    
  else  
    MIC=y(:,1); %mic;
    PIC=y(:,2); %pic;    
  endif   
  Nb=size(y,1);
  indxfmt=get(fsfmt,'value');
  if (indxfmt == 1)||(indxfmt == 4) 
  NbF=1024;     
  endif  
  if (indxfmt == 2)||(indxfmt == 5) 
  NbF=2048;     
  endif  
  if (indxfmt == 3)||(indxfmt == 6) 
  NbF=8096;     
  endif  
  
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
                  axes(ax2)
                  cla
	                rectangle('Position',[0,0,(round(1000*n/Nbmax/3))+1,20],'FaceColor','b'); 
                  text(480,10,[num2str(round(100*n/Nbmax/3)),'%']);
                  pause(0.01)
            %waitbar(n/Nbmax,f,'Processing...');
        end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Post selection Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

NN=size(alice,1);
    for i=1:NN, % POur chaque frequence
        a=alice(i,:);
        
        A=a((abs(a)-mean(a))<2*std(a)); % On ne garde que les echantillons compris dans 2 ecarts types
        
        ALICE(i)=mean(A);
        if isnan(mean(A)),
            %display('Algorithm Failed: Increase the recording length and/or improve the S/N ratio');
            ALICE(i)=1;
        end
        Q(i)=length(A);
        if mod(round(i/NN*100),10)==0
                  %round(n/Nbmax*100)
                  %waitbar (1/3+i/NN/3, h);
                  axes(ax2)
                  cla
	                rectangle('Position',[0,0,(round(1000*(1/3+i/NN/3)))+1,20],'FaceColor','b'); 
                  text(480,10,[num2str(round(100*(1/3+i/NN/3))),'%']);
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
dgain=zeros(31,1);

    
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
    axes(ax2)
    cla
	  rectangle('Position',[0,0,(round(1000*(2/3+qq*0.1)))+1,20],'FaceColor','b'); 
    text(480,10,[num2str(round(100*(2/3+qq*0.1))),'%']);
    pause(0.01)
end;
    
##    figure(2)
##    plot(10*log10(nuX(nn)),s0(nn))
##    hold on
##    plot(10*log10(cf),p-p2)
##    hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IR1=IR1/max(abs(IR1))*0.95;
s1=20*log10(abs(fftshift(fft(IR1)))); % compute the GEQ spectrum
n2=NbF/2+2:NbF;
semilogx(ax,nuX(n2),s1(n2));
%semilogx(nuX(n2),s1(n2));
grid on
xlim([20 22050])
xlabel('frequency (Hz)')
ylabel('dB')


[pks idx] = max(s1);
f_mx=abs(nuX(idx));
hold on
plot(ax,f_mx,pks,'or')
%plot(f_mx,pks,'or')
text(f_mx+50,pks,[num2str(f_mx,'%3.0f'),'Hz']);
hold off

mot=['IR spectrum, feedback frequency is: ',num2str(f_mx,'%3.0f'),'Hz'];
title(mot)

  handles.IR1=IR1; % GEQ IR
  handles.IR2=IR2; % Raw IR
  guidata(hObject,handles);
  %waitbar(1, h);
  axes(ax2)
  %cla
	rectangle('Position',[0,0,(round(1000*(1)))+1,20],'FaceColor','b'); 
  text(480,10,[num2str(round(100*(1))),'%']);
  pause(1)
  %close(h)  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Listen to Mic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mic(hObject, eventdata,ax,ai,devinfo,fsfmt,icfg,ao)
  handles = guidata(hObject);
  y=handles.y;
  fs=handles.fs;
  nbits=handles.nbits;
  Nb=size(y,1);  
  n3=10*fs:20*fs;
  indxinput=get(icfg,'value');
  if indxinput==1
    MIC=y(:,2); %mic;
    PIC=y(:,1); %pic;    
  else  
    MIC=y(:,1); %mic;
    PIC=y(:,2); %pic;    
  endif 

  
  indx=get(ao,'value');
  id=devinfo.output(indx).ID;
  
  player = audioplayer (MIC(n3), fs, nbits, id);
  play(player);
  %soundsc(MIC(n3),fs,nbits);
  pause(10.5)
  clear player;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Listen to Pickup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pickup(hObject, eventdata,ax,ai,devinfo,fsfmt,icfg,ao)
  handles = guidata(hObject);
  y=handles.y;
  fs=handles.fs;
  nbits=handles.nbits;
  Nb=size(y,1);  
  n3=10*fs:20*fs;
  indxinput=get(icfg,'value');
  if indxinput==1
    MIC=y(:,2); %mic;
    PIC=y(:,1); %pic;    
  else  
    MIC=y(:,1); %mic;
    PIC=y(:,2); %pic;    
  endif 
  %soundsc(PIC(n3),fs,nbits);
  indx=get(ao,'value');
  id=devinfo.output(indx).ID;
  player = audioplayer (PIC(n3), fs, nbits, id);
  play(player);
  pause(10.5)
  clear player;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Listen to IR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function IR(hObject, eventdata,ax,ai,devinfo,fsfmt,icfg,ao)
  handles = guidata(hObject);
  y=handles.y;
  fs=handles.fs;
  nbits=handles.nbits;
  IRGEQ=handles.IR1;
  Nb=size(y,1);  
  n3=10*fs:20*fs;
  indxinput=get(icfg,'value');
  if indxinput==1
    MIC=y(:,2); %mic;
    PIC=y(:,1); %pic;    
  else  
    MIC=y(:,1); %mic;
    PIC=y(:,2); %pic;    
  endif 
  PS=conv(PIC(n3),IRGEQ,'same');
  PS=PS/max(abs(PS))*max(abs(PIC(n3)));
  %soundsc(PS,fs,nbits);
  indx=get(ao,'value');
  id=devinfo.output(indx).ID;
  player = audioplayer (PS, fs, nbits, id);
  play(player);
  pause(10.5) 
  clear player;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save IR file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save(hObject, eventdata,ax,ai,devinfo,fsfmt,icfg,listfmt,Svfmt,Fnam)
  
  handles = guidata(hObject);
  rawIR=handles.IR2;
  IRGEQ=handles.IR1;
  fs=handles.fs;
  nbits=handles.nbits;
  Nb=size(IRGEQ,1);  

  
  indxfmt=get(fsfmt,'value');
  if (indxfmt <= 3)
    nbits=16;
  else
    nbits=24;    
  endif  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Standard
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ispc
    [filename, pathname] = uiputfile('*.wav', 'Save as','IR_std.wav');
    Fname=[pathname,filename];
    audiowrite(Fname,IRGEQ/max(abs(IRGEQ))*0.95,fs,'BitsPerSample',nbits);
  end
  if ismac
    Fname=get(Fnam,'string');
    audiowrite(Fname,IRGEQ/max(abs(IRGEQ))*0.95,fs,'BitsPerSample',nbits);  
  end  
  Fname2=[Fname(1:end-4),'.jpg'];
  print(gcf,Fname2,'-djpeg','-r300');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Options
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  SAVEfmt=get(Svfmt,'value');
  if SAVEfmt==2
    % Raw
    Fname2=[Fname(1:end-4),'_raw.wav'];
    audiowrite(Fname2,rawIR/max(abs(rawIR))*0.95,fs,'BitsPerSample',nbits);
    % GEQ+Blend
    IR0=zeros(Nb,1);
    IR0(1)=1;
    IRblend=(IR0+IRGEQ)/2;
    Fname2=[Fname(1:end-4),'_Bld.wav'];
    audiowrite(Fname2,IRblend/max(abs(IRblend))*0.95,fs,'BitsPerSample',nbits);
    % Minimum Phase
    s=fft(IRGEQ);
    sm = exp( fft( fold( ifft( log( clipdb(s,-100) )))));
    IRmph=real(ifft(sm));
    Fname2=[Fname(1:end-4),'_MPh.wav'];
    audiowrite(Fname2,IRmph/max(abs(IRmph))*0.95,fs,'BitsPerSample',nbits);
  end; 
  if SAVEfmt==3 % Feedback friendly
    y=handles.y;
    fs=handles.fs;
    %nbits=handles.nbits;
    Nb=size(y,1);  
    FS=fs;
    indxinput=get(icfg,'value');
    if indxinput==1
      MIC=y(:,2); %mic;
      PIC=y(:,1); %pic;    
    else  
      MIC=y(:,1); %mic;
      PIC=y(:,2); %pic;    
    endif 
  nn=(10*FS+1:20*FS);
  MS=MIC(nn,1);
  PS=PIC(nn,1);
  
  
  % COmpute Feedback frequency
  NbF=Nb;
  dnuX=FS/NbF;
  nuX=(-NbF/2:NbF/2-1)*dnuX;
  
  s1=20*log10(abs(fftshift(fft(IRGEQ)))); % compute the GEQ spectrum
  
  n800=(abs(nuX)<800);
  nuX2=nuX(n800);
  s12=s1(n800);
  [pks idx] = max(s12);
  f_mx=abs(nuX2(idx))
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % generate PEQ
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  g=-6; % -6dB à la resonance
  Q=3;
  fc=f_mx;
  
  
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
  IRX=filter(b,a,IRGEQ); % FIltre IR
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % generate Shelf EQ
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    g=-1; % -1dB en shelf
    fc=1000;

    g=10^(g/20);
    if g >= 1
        a1=-0.5*tan(pi*(fc/fs-0.25));
    else
        a1=-0.5*tan(pi*(fc/fs*g-0.25));
    end
    b0t=0.25+0.5*a1;
    b2=0;
    a2=0;
    b0=0.5+(g-1)*b0t;
    b1=-a1-(g-1)*b0t;

    % SOS Form
    b=2*[b0 b1 b2];
    a=[1 -2*a1 -2*a2];
    IRX1=filter(b,a,IRX); % FIltre IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    g=-2; % -1dB en shelf
    fc=1000;

    g=10^(g/20);
    if g >= 1
        a1=-0.5*tan(pi*(fc/fs-0.25));
    else
        a1=-0.5*tan(pi*(fc/fs*g-0.25));
    end
    b0t=0.25+0.5*a1;
    b2=0;
    a2=0;
    b0=0.5+(g-1)*b0t;
    b1=-a1-(g-1)*b0t;

    % SOS Form
    b=2*[b0 b1 b2];
    a=[1 -2*a1 -2*a2];
    IRX2=filter(b,a,IRX); % FIltre IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    g=-3; % -1dB en shelf
    fc=1000;

    g=10^(g/20);
    if g >= 1
        a1=-0.5*tan(pi*(fc/fs-0.25));
    else
        a1=-0.5*tan(pi*(fc/fs*g-0.25));
    end
    b0t=0.25+0.5*a1;
    b2=0;
    a2=0;
    b0=0.5+(g-1)*b0t;
    b1=-a1-(g-1)*b0t;

    % SOS Form
    b=2*[b0 b1 b2];
    a=[1 -2*a1 -2*a2];
    IRX3=filter(b,a,IRX); % FIltre IR  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    g=-4; % -1dB en shelf
    fc=1000;

    g=10^(g/20);
    if g >= 1
        a1=-0.5*tan(pi*(fc/fs-0.25));
    else
        a1=-0.5*tan(pi*(fc/fs*g-0.25));
    end
    b0t=0.25+0.5*a1;
    b2=0;
    a2=0;
    b0=0.5+(g-1)*b0t;
    b1=-a1-(g-1)*b0t;

    % SOS Form
    b=2*[b0 b1 b2];
    a=[1 -2*a1 -2*a2];
    IRX4=filter(b,a,IRX); % FIltre IR  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute brightness Boost
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate Octave spectrum (Pic convolved & Pic convolved + EQ)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    %pkg load signal;
    PS0=conv(PIC(nn,1),IRGEQ,'same');
    PS1=conv(PIC(nn,1),IRX1,'same');
    PS2=conv(PIC(nn,1),IRX2,'same');
    PS3=conv(PIC(nn,1),IRX3,'same');
    PS4=conv(PIC(nn,1),IRX4,'same');
    
    [p,cf,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS0/max(abs(PS0)),FS,3,1,1,0);
    [p21,cf21,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS1/max(abs(PS1)),FS,3,1,1,0);
    [p22,cf22,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS2/max(abs(PS2)),FS,3,1,1,0);
    [p23,cf23,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS3/max(abs(PS3)),FS,3,1,1,0);
    [p24,cf24,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS4/max(abs(PS4)),FS,3,1,1,0);
    OSC0=sum(cf.*abs(p))/sum(abs(p));
    OSC1=sum(cf21.*abs(p21))/sum(abs(p21));
    OSC2=sum(cf22.*abs(p22))/sum(abs(p22));
    OSC3=sum(cf23.*abs(p23))/sum(abs(p23));
    OSC4=sum(cf24.*abs(p24))/sum(abs(p24));
    
    osc0=[OSC0 OSC0 OSC0 OSC0];
    osc=[OSC1 OSC2 OSC3 OSC4];
    [w, iw] = min(abs(osc-osc0));
    Fname2=[Fname(1:end-4),'_Fbk.wav'];
    if (iw==1)
      audiowrite(Fname2,IRX1/max(abs(IRX1))*0.95,fs,'BitsPerSample',nbits);
    end
    if (iw ==2)
      audiowrite(Fname2,IRX2/max(abs(IRX2))*0.95,fs,'BitsPerSample',nbits);    
    end
    if (iw ==3)
      audiowrite(Fname2,IRX3/max(abs(IRX3))*0.95,fs,'BitsPerSample',nbits);    
    end
    if (iw ==4)
      audiowrite(Fname2,IRX4/max(abs(IRX4))*0.95,fs,'BitsPerSample',nbits);    
    end
    


  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close app
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close(hObject, eventdata,ax,dlg)
  close(dlg)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Donate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Donate(hObject, eventdata,ax,dlg)
  if ispc
    system('start "" "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=kien.phanhuy%40free.fr&currency_code=USD&source=url"');
  end;
  if ismac
    system('open "" "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=kien.phanhuy%40free.fr&currency_code=USD&source=url"');
  end;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub-function from J. O Smith
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rw] = fold(r) 
% [rw] = fold(r) 
% Fold left wing of vector in "FFT buffer format" 
% onto right wing 
% J.O. Smith, 1982-2002
  
   [m,n] = size(r);
   if m*n ~= m+n-1
     error('fold.m: input must be a vector'); 
   end
   flipped = 0;
   if (m > n)
     n = m;
     r = r.';
     flipped = 1;
   end
   if n < 3, rw = r; return; 
   elseif mod(n,2)==1
       nt = (n+1)/2; 
       rw = [ r(1), r(2:nt) + conj(r(n:-1:nt+1)), ...
             0*ones(1,n-nt) ]; 
   else 
       nt = n/2; 
       rf = [r(2:nt),0]; 
       rf = rf + conj(r(n:-1:nt+1)); 
       rw = [ r(1) , rf , 0*ones(1,n-nt-1) ]; 
   end 

   if flipped
     rw = rw.';
   end
end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   function [clipped] = clipdb(s,cutoff)
% [clipped] = clipdb(s,cutoff)

% Clip magnitude of s at its maximum + cutoff in dB.
% Example: clip(s,-100) makes sure the minimum magnitude
% of s is not more than 100dB below its maximum magnitude.
% If s is zero, nothing is done.

clipped = s;
as = abs(s);
mas = max(as(:));
if mas==0, return; end
if cutoff >= 0, return; end
thresh = mas*10^(cutoff/20); % db to linear
toosmall = find(as < thresh);
clipped = s;
clipped(toosmall) = thresh;
end

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