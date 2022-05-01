% Acoustic guitar IR generator "light" 1.1
% Author: Kien Phan Huy on the 14th of July 2020. Copyright 2020
% Uses the Min Phase response computation from J.O. Smith, 1982-2002
% Uses amodified versiona of Oct_spectrum from M. Buzzoni, Dec. 2018
% Uses IIR butterworth coefficient computation from Neil Robertson , 12/29/17
% Uses embbeded waitbar Yuanfei (2020). Embedding Waitbar Inside A GUI (https://www.mathworks.com/matlabcentral/fileexchange/47896-embedding-waitbar-inside-a-gui), MATLAB Central File Exchange. Retrieved July 15, 2020.
% See copyrights for subfunctions and roaotine below
function Cuki_IR_gen1t();

  ####################
  #  User Variables  #
  ####################
  default_samplingrate = 2;            ## 1 = 44100kHz, 2 = 48000kHz
  default_bitdepth = 2;                ## 1 = 16 bit, 2 = 24 bit
  default_recordtime = 2;              ## 1 = 30 Sec, 2 = 1 min, 3 = 2 min
  default_saveoption = 1;              ## 1-Standard(std+itp), 2-Various(std+itp+others), 3-+FB friendly, 4-JF45, 5-Single(only std)
  default_IRformat = 2;               ## 1 = 1024@16bit, 2 = 2048@16bit, 3 = 8096@16bit, 4 = 1024@24bit, 5 = 2048@24bit, 6 = 8096@24bit
  default_outputLevel = 5;            ## 1 = 0.5, 2 = 0.6, 3 = 0.7, 4 = 0.8, 5 = 0.95 - IR output level multiplier
  enable_outputLevel = 'off';        ## on/off - enables or disables the outputLevel correction option drop-down menu
  enable_saveRecButton = 'off';       ## on/off - enables or disables the saveRecButton
  enable_loadButton = 'on';           ## on/off - enables or disables to Load File button
  textFontName = "default";            ## default,times,arial,consolas,etc
  textFontSize = 10;                 ## 10 is the default, but might be scaled, check the variable below
  textFontScaling = 'yes';           ## [yes/no] increase the font size with 1, if resolution is higher than FHD, or decrease with 1 if its lower
  textFontAngle = "normal";           ## italic,normal
  textFontWeight = "bold";            ## bold,normal
  buttonsFontName = "default";        ## default,times,arial,consolas,etc
  buttonsFontSize = 11;               ## 10 is the default
  popupsFontName = "default";        ## default,times,arial,consolas,etc
  popupsFontSize = 11;               ## 10 is the default
  loadBarColor = [122,200,22]./255;    ## you can use [R,G,B] values
  loadBarFontSize = 11;                  ## 10 is the default
  chartLabelsFontsize = 12;      ## 10 is the default - too small
  chartTitleFontsize = 20;       ## 10 is the default - too small
  chartPicColor = [144,148,151]./255; ## [R,G,B] value
  chartMicColor = [23,165,137]./255;  ## [R,G,B] value
  chartIRColor = [165,105,189]./255;   ## [R,G,B] value
  chartRecBarsColor = [214,137,22]./255;  ## [R,G,B] value

  ###################
  ##  Themes      ###
  ###################
  myTheme = 1;   ## 1-Dark(white over black), 2-Light(black over white), 3-Custom
  ### Feel free to set your own colors :)  ###
  ### Please note that this colors are only used when myTheme = 3 (Custom) ###
  customThemefgColor = [122,222,222]./255;     ## k-black, w-white, but you can use [R,G,B] values as well
  customThemebgColor = [78,52,46]./255;     ## k-black, w-white, but you can use [R,G,B] values as well
  customThemeTextColor = [241,196,15]./255;  ## same as above
  ### Default dark/light theme colors ###
  darkThemeTextColor = [201,130,79]./255;  ## Please don't chnage this, it was carefully selected!
  lightThemeTextColor = [66,132,44]./255; ## Please don't chnage this, it was carefully selected!
  fgColor = ''
  bgColor = ''

  ######################
  #  System variables  #
  # Don't change these #
  ######################
  interrupt = false
  y=0
  fs=0
  nbits=0
  PIC = 0
  MIC = 0
  IR1 = 0
  IR2 = 0
  player = ''
  recorder = ''
  my_screenSize = get(0, 'screensize');
  my_screenSize = my_screenSize(3:4);
  PositionSize = [ my_screenSize/4 my_screenSize/2 ];
  mainWidth = PositionSize(3); ## Screen half width
  mainHeight = PositionSize(4); ## Screen half height
  mainBorder = mainWidth/64;
  ItemWidth = mainWidth/20;
  itemHeight = mainHeight/24;
  if strcmpi(textFontScaling, 'yes')
    if my_screenSize(1) > 1920
      textFontSize += 1;
      loadBarFontSize += 1;
    elseif my_screenSize(1) < 1920
      textFontSize -= 1;
      loadBarFontSize -= 1;
    endif;
  endif;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Position ui controlsr
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  u1=[ItemWidth*5.2 itemHeight*3 ItemWidth*14 ItemWidth*6.5]; ## Main axes
  u2=[mainBorder mainHeight-itemHeight ItemWidth*5 itemHeight]; ## Select your configuration:
  u3=[ItemWidth*5 mainHeight-itemHeight ItemWidth*5 itemHeight]; ## Pickup/Mic drop down menu
  u4=[u1(1)+ItemWidth*2 u1(2)+u1(4)+itemHeight*1.5 ItemWidth*11 itemHeight*0.7]; ## Loading bar axes
  u5=[mainBorder u2(2)-itemHeight ItemWidth*8 itemHeight]; ## Select audio interface:
  u6=[ItemWidth*0.8 u5(2)-itemHeight*1.1 ItemWidth*1.5 itemHeight]; ## Input:
  u7=[ItemWidth*2 u5(2)-itemHeight*1.1 ItemWidth*8 itemHeight]; ## Input drop down
  u8=[ItemWidth*0.8 u6(2)-itemHeight*1.1 ItemWidth*1.5 itemHeight]; ## Output:
  u9=[ItemWidth*2 u6(2)-itemHeight*1.1 ItemWidth*8 itemHeight]; ## Output drop down
  u10=[ItemWidth*10.5 u2(2)-itemHeight ItemWidth*5 itemHeight]; ## Frequency sampling rate/bitdepth:
  u11=[ItemWidth*10.5 u10(2)-itemHeight*1.1 ItemWidth*4 itemHeight]; ## Frequency sampling rate drop down
  u12=[ItemWidth*10.5 u11(2)-itemHeight*1.1 ItemWidth*4 itemHeight]; ## Frequency sample bitdepth drop down
  u13=[mainBorder u9(2)-itemHeight*1.5 ItemWidth*6.4 itemHeight]; ## Test recording and check levels:
  u14=[mainBorder u13(2)-itemHeight ItemWidth*2 itemHeight]; ## Record 5s
  u15=[mainBorder u14(2)-itemHeight*1.5 ItemWidth*4.4 itemHeight]; ## Record for IR generation:
  u16=[ItemWidth*2 u15(2)-itemHeight ItemWidth*1.5 itemHeight]; ## Record for IR generation drop down
  u17=[mainBorder u15(2)-itemHeight ItemWidth*1.5 itemHeight]; ## Record for IR generation button
  u18=[mainBorder u17(2)-itemHeight*1.5 ItemWidth*3 itemHeight]; ## IR file format:
  u19=[mainBorder u18(2)-itemHeight ItemWidth*3 itemHeight]; ## IR file format drop down
  u20=[mainBorder u19(2)-itemHeight*1.5 ItemWidth*3 itemHeight]; ## Compute IR:
  u21=[mainBorder u20(2)-itemHeight ItemWidth*2 itemHeight]; ## Compute IR button
  u22=[mainBorder u21(2)-itemHeight*1.5 ItemWidth*3 itemHeight]; ## Listen:
  u23=[mainBorder u22(2)-itemHeight ItemWidth itemHeight]; ## Listen Mic button
  u24=[ItemWidth*1.4 u22(2)-itemHeight ItemWidth itemHeight]; ## Listen Pickup button
  u25=[ItemWidth*2.5 u22(2)-itemHeight ItemWidth itemHeight]; ## Listen IR button
  u26=[mainBorder u25(2)-itemHeight*1.5 ItemWidth*3 itemHeight]; ## Save IR file:
  u27=[mainBorder u26(2)-itemHeight ItemWidth*4 itemHeight]; ## Save IR file format drop down
  u28=[mainBorder u27(2)-itemHeight*1.1 ItemWidth*2 itemHeight]; ## Save IR file button (PC version)
  u29=[mainBorder u27(2)-itemHeight*1.1 ItemWidth*1.5 itemHeight]; ## MAC File name
  u30=[ItemWidth*2 u27(2)-itemHeight*1.1 ItemWidth*2.5 itemHeight]; ## MAC file name edit box
  u31=[mainBorder u30(2)-itemHeight ItemWidth*2 itemHeight]; ## MAC Save IR button
  u32=[mainBorder itemHeight*0.6 ItemWidth*2 itemHeight]; ## Close button
  u33=[ItemWidth*2.5 itemHeight*0.6 ItemWidth*2 itemHeight]; ## Donate button
  u34=[mainWidth/2 itemHeight*0.6 ItemWidth*textFontSize/1.4 itemHeight]; ## Copyright label
  u35=[mainWidth-ItemWidth*4 mainHeight-itemHeight*1.2 ItemWidth*2 itemHeight]; ## Load File button
  u36=[ItemWidth*2.5 u13(2)-itemHeight ItemWidth*2 itemHeight]; ## Record 10s
  u37=[mainWidth-ItemWidth*1.6 mainHeight-itemHeight*1.2 ItemWidth*1.5 itemHeight]; ## Theme
  u38=[u35(1) u35(2)-itemHeight ItemWidth*4 itemHeight]; ## Load File info
  u39=[ItemWidth*3.6 u15(2)-itemHeight ItemWidth*1 itemHeight]; ## Save recording
  u40=[mainBorder+ItemWidth*2.2 u27(2)-itemHeight*1.1 ItemWidth*1.3 itemHeight]; ## Save file output level correction


 ## Let's put this positions in an array
 for i=1:40
   itemPosition{i} = eval(['u',num2str(i)])./[ PositionSize(3:4) PositionSize(3:4) ];
 endfor

 ### Creating some arrays where we will store the ui elements
 ui_textArray = {};
 ui_buttonArray = {};
 ui_popupmenuArray = {};
 buttonState = {};

  #############################
  ## UI generation section ####
  #############################

  % Creation figure
  dlg = figure('name','Cuki IR generator light v1.1', 'position', PositionSize, 'menubar','none', ...
            'numbertitle', 'off', 'DefaultUicontrolUnits', 'normalized');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation axes
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %axes1=axes(dlg,'position',[200,100,640,480])
  %h=plot(dlg,1:10,1:10,'-o')
  ax = axes('NextPlot', 'add');
  set(ax,'position', itemPosition{1}, 'fontsize', chartLabelsFontsize, 'xminorgrid', 'on', 'yminorgrid', 'on')
  ##############################################################
  ### Audio input configuration                             ####
  ### Mic and pickup signals on which channel - 1/L or 2/R  ####
  ##############################################################
  ui_selectConfig = uicontrol('visible', 'off', 'style','text', 'string','1) Select your configuration:', ...
      'position', itemPosition{2});
      ui_textArray{end+1} = ui_selectConfig;
  ui_icfg = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',{'Pickup in CH1/L, Mic in CH2/R','Pickup in CH2/R, Mic in CH1/L'}, ...
      'position', itemPosition{3}, 'callback',@ui_setiCfg);
      ui_popupmenuArray{end+1} = ui_icfg;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Wait bar
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ax2=axes('NextPlot', 'add');
  set(ax2,'Position', itemPosition{4});
  set(ax2,'Xtick',[],'Ytick',[],'Xlim', [0 1000], 'box', 'on');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation liste des interface audio
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_selectInterface = uicontrol('visible', 'off', 'style','text', 'string','2) Choose audio interface+driver:', ...
      'position', itemPosition{5});
      ui_textArray{end+1} = ui_selectInterface;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  nDevices = audiodevinfo(0);
  devinfo = audiodevinfo();
  mot=['liste= {''',devinfo.input(1).Name,''''];
  for i=2:size(devinfo.input,2),
     mot=[mot,',''',devinfo.input(i).Name,''''];
  end
  mot=[mot,'};'];
  eval(mot);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_inputdevice = uicontrol('visible', 'off', 'style','text', 'string','Input:', ...
      'position', itemPosition{6});
       ui_textArray{end+1} = ui_inputdevice;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation du menu deroulant INPUT
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ai = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',liste, ...
      'position', itemPosition{7}, 'callback', @cbk_popupmenu);
      ui_popupmenuArray{end+1} = ai;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  mot=['liste2= {''',devinfo.output(1).Name,''''];
  for i=2:size(devinfo.output,2),
     mot=[mot,',''',devinfo.output(i).Name,''''];
  end
  mot=[mot,'};'];
  eval(mot);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
  ui_outputDevice = uicontrol('visible', 'off', 'style','text', 'string','Output:', ...
      'position', itemPosition{8});
      ui_textArray{end+1} = ui_outputDevice;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation du menu deroulant OUTPUT
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ao = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',liste2, ...
      'position', itemPosition{9});
      ui_popupmenuArray{end+1} = ao;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation liste des frequences d'echantillonage
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_samplingRateDepth = uicontrol('visible', 'off', 'style','text', 'string','3) Choose Frequency sampling:', ...
      'position', itemPosition{10});
      ui_textArray{end+1} = ui_samplingRateDepth;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_fsliste = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',{'44100 Hz','48000 Hz'}, ...
      'position', itemPosition{11},'value', default_samplingrate);
      ui_popupmenuArray{end+1} = ui_fsliste;
  ui_bitdepth = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',{'16 bit','24 bit'}, ...
      'position', itemPosition{12},'value', default_bitdepth);
      ui_popupmenuArray{end+1} = ui_bitdepth;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Record quick, test levels
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_testRecording = uicontrol('visible', 'off', 'style','text', 'string','4) Test recording/check levels (optional):', ...
      'position', itemPosition{13});
      ui_textArray{end+1} = ui_testRecording;

  ui_rec5 = uicontrol(dlg, 'visible', 'off', 'style','togglebutton','string','Record 5s', 'tag', 'test', ...
  'position', itemPosition{14}, 'callback',{@record_audio, 5});
      ui_buttonArray{end+1} = ui_rec5;
  ui_rec10 = uicontrol(dlg, 'visible', 'off', 'style','togglebutton','string','Record 10s', 'tag', 'test', ...
  'position', itemPosition{36}, 'callback',{@record_audio, 10});
      ui_buttonArray{end+1} = ui_rec10;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Record long to make IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_recIR = uicontrol('visible', 'off', 'style','text', 'string','5) Record for IR generation:', ...
      'position', itemPosition{15});
      ui_textArray{end+1} = ui_recIR;
  ui_Trec = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',{'30 sec','1 min','2 min'}, ...
      'position', itemPosition{16}, 'value', default_recordtime);
      ui_popupmenuArray{end+1} = ui_Trec;

  ui_recIRbutton = uicontrol(dlg, 'visible', 'off', 'style','togglebutton', 'string','Record', 'tag', 'real', 'position', itemPosition{17}, ...
      'callback',{@record_audio, ui_Trec});
      ui_buttonArray{end+1} = ui_recIRbutton;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creation liste des formats de sortie
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_IRfileFormat = uicontrol('visible', 'off', 'style','text', 'string','6) IR file format:', ...
      'position', itemPosition{18});
      ui_textArray{end+1} = ui_IRfileFormat;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  listfmt = {'1024 pts, 16 bits','2048 pts, 16 bits','8096 pts, 16 bits','1024 pts, 24 bits','2048 pts, 24 bits','8096 pts, 24 bits'};
  ui_fsfmt = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string', listfmt, ...
      'position', itemPosition{19},'value', default_IRformat);
      ui_popupmenuArray{end+1} = ui_fsfmt;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Compute IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_computeIRtext = uicontrol('visible', 'off', 'style','text', 'string','7) Compute IR:', ...
      'position', itemPosition{20});
      ui_textArray{end+1} = ui_computeIRtext;
  ui_computeIRbutton = uicontrol(dlg, 'enable', 'off', 'visible', 'off', 'style','pushbutton', 'string','Compute IR', 'position', itemPosition{21}, ...
  'callback',@Go);
      ui_buttonArray{end+1} = ui_computeIRbutton;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Listen
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_listen = uicontrol('visible', 'off', 'style','text', 'string','8) Listen:', ...
      'position', itemPosition{22});
      ui_textArray{end+1} = ui_listen;
  ui_ListenMicButton = uicontrol(dlg, 'enable', 'off', 'visible', 'off', 'style','togglebutton', 'string','Mic', 'position', itemPosition{23}, ...
  'callback',@Mic);
      ui_buttonArray{end+1} = ui_ListenMicButton;
  ui_ListenPicButton = uicontrol(dlg, 'enable', 'off', 'visible', 'off', 'style','togglebutton', 'string','Pickup', 'position', itemPosition{24}, ...
  'callback',@Pickup);
      ui_buttonArray{end+1} = ui_ListenPicButton;
  ui_ListenIRButton = uicontrol(dlg, 'enable', 'off', 'visible', 'off', 'style','togglebutton', 'string','IR', 'position', itemPosition{25}, ...
  'callback',@IR);
      ui_buttonArray{end+1} = ui_ListenIRButton;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Save IR
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_saveIR = uicontrol('visible', 'off', 'style','text', 'string','8) Save IR file:', ...
      'position', itemPosition{26});
      ui_textArray{end+1} = ui_saveIR;
  Svfmt = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',{'Standard','Various flavours','Feedback friendly','JF45 Copyright: Jon Fields', 'Single'}, ...
      'position', itemPosition{27}, 'value', default_saveoption);
      ui_popupmenuArray{end+1} = Svfmt;
  if ispc
      ui_PCsaveButton = uicontrol(dlg, 'enable', 'off', 'visible', 'off', 'style','pushbutton', 'string','Save', 'position', itemPosition{28}, ...
      'callback',@Save);
      ui_buttonArray{end+1} = ui_PCsaveButton;
  endif
  if ismac
      ui_macFilename = uicontrol('visible', 'off', 'style','text', 'string','Filename:', ...
          'position', itemPosition{29});
          ui_textArray{end+1} = ui_macFilename;
      Fnam = uicontrol('visible', 'off', 'style','edit', 'string','IR.wav', ...
          'position', itemPosition{30});
      ui_macSaveButton = uicontrol(dlg, 'visible', 'off', 'style','pushbutton', 'string','Save', 'position', itemPosition{31}, ...
          'callback',@ui_Save);
      ui_buttonArray{end+1} = ui_macSaveButton;
  endif
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Close dlg
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_close = uicontrol(dlg, 'visible', 'off', 'style','pushbutton', 'string','Close','tag','alwayson', 'position', itemPosition{32}, 'callback',@Close);
      ui_buttonArray{end+1} = ui_close;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Donate
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_donate = uicontrol(dlg, 'visible', 'off', 'style','pushbutton', 'string','Donate','tag','alwayson', 'position', itemPosition{33}, 'callback',@Donate);
      ui_buttonArray{end+1} = ui_donate;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Copyright label
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ui_copyright = uicontrol('visible', 'off', 'style','text', 'string','Copyright: Kien Phan Huy, July 2022', ...
       'position', itemPosition{34});
      ui_textArray{end+1} = ui_copyright;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load file (Load file button)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_loadButton = uicontrol(dlg, 'visible', 'off', 'style','pushbutton', 'string','Load File', 'position', itemPosition{35}, 'callback', @Load);
      ui_buttonArray{end+1} = ui_loadButton;
  ui_loadInfo = uicontrol('visible', 'off', 'style','text', ...
       'position', itemPosition{38});
      ui_textArray{end+1} = ui_loadInfo;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Theme
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_theme = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',{'Dark', 'Light', 'Custom'}, ...
      'position', itemPosition{37},'value', myTheme, 'callback', @ui_changeTheme);
      ui_popupmenuArray{end+1} = ui_theme;
##  pause(0.1);
##  set(dlg,'position',[143 129 1024 768]); % pour Mac

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Save recording button
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ui_saveRecButton = uicontrol(dlg, 'enable', 'off', 'visible', 'off', 'style','pushbutton', 'string','Save', 'position', itemPosition{39}, 'callback', @save_recording);
      ui_buttonArray{end+1} = ui_saveRecButton;

  ###############################
  ##   Output level correction ##
  ###############################
   ui_outputLevel = uicontrol(dlg,'visible', 'off', 'style','popupmenu', 'string',{'0.5','0.6','0.7','0.8','0.95'}, ...
    'position', itemPosition{40}, 'value', default_outputLevel);
    ui_popupmenuArray{end+1} = ui_outputLevel;

##########################
# Set the theme function #
##########################

  ui_changeTheme(ui_theme)

  function ui_changeTheme(hObject,eventdata)
        switch get(hObject, 'value')
        case 1
          fgColor = 'w';
          bgColor = 'k';
          textColor = darkThemeTextColor;
        case 2
          fgColor = 'k';
          bgColor = 'w';
          textColor = lightThemeTextColor;
        case 3
          fgColor = customThemefgColor;
          bgColor = customThemebgColor;
          textColor = customThemeTextColor;
        endswitch;
        set(dlg,'color', bgColor);
        set(ax,'color', bgColor,'xcolor', fgColor, 'ycolor', fgColor);
        for i = 1:length(ui_textArray)
           set(ui_textArray{i}, 'visible', 'on', 'foregroundcolor', textColor, 'backgroundcolor', bgColor, ...
           'fontangle', textFontAngle, 'horizontalalignment','left', 'fontname', textFontName, ...
           'fontsize', textFontSize, 'fontweight', textFontWeight, 'units','normalized');
        endfor;
        for i = 1:length(ui_popupmenuArray)
           set(ui_popupmenuArray{i}, 'visible', 'on', 'fontname', popupsFontName, 'fontsize', popupsFontSize, 'units', 'normalized')
        endfor;
        for i = 1:length(ui_buttonArray)
          set(ui_buttonArray{i}, 'visible', 'on', 'fontname', buttonsFontName, 'fontsize', buttonsFontSize, 'units', 'normalized')
        endfor
        #### dynamic ui elements based on environment configuration###
        set(ui_loadInfo, 'fontsize', textFontSize-2)
        set(ui_saveRecButton, 'visible', enable_saveRecButton);
        set(ui_outputLevel, 'visible', enable_outputLevel);
        set(ui_loadButton, 'visible', enable_loadButton);
        if ismac
          set(ui_saveRecButton, 'visible', 'off');
          set(ui_outputLevel, 'visible', 'off');
        endif
  end;

########################################
# Set the input configuration function #
########################################

  ui_setiCfg(ui_icfg)

  function ui_setiCfg(hObject,eventdata)
      if get(hObject, 'value') == 1
         PIC=1;
         MIC=2;
      else
         PIC=2;
         MIC=1;
      endif
   end;


########################################
## The real function start from here ###
########################################

function resetButtons()
  if ispc
    IRsavebutton = ui_PCsaveButton;
  endif
  if ismac
    IRsavebutton = ui_macSaveButton;
  endif
  set(ui_loadInfo, 'string', '')
  set(ui_ListenMicButton, 'enable', 'off')
  set(ui_ListenPicButton, 'enable', 'off')
  set(ui_ListenIRButton, 'enable', 'off')
  set(ui_computeIRbutton, 'enable', 'off')
  set(ui_saveRecButton, 'enable', 'off')
  set(IRsavebutton, 'enable', 'off')
  set(ui_rec5, 'enable', 'on')
  set(ui_rec10, 'enable', 'on')
  set(ui_recIRbutton, 'enable', 'on')
  set(ui_loadButton, 'enable', 'on')
endfunction

#####################
## Disable buttons ###
#####################

function disableButtons(hObject)
  for i = 1:length(ui_buttonArray)
    if !strcmp(get(ui_buttonArray{i},'tag'), "alwayson")
      buttonState{i} = get(ui_buttonArray{i},'enable');
      if ui_buttonArray{i} != hObject
        set(ui_buttonArray{i}, 'enable', 'off');
      endif
    endif
  endfor
endfunction

######################
## Enable buttons ###
######################

function enableButtons()
  for i = 1:length(ui_buttonArray)
    if !strcmp(get(ui_buttonArray{i},'tag'), "alwayson")
      set(ui_buttonArray{i}, 'enable', buttonState{i});
    endif
  endfor
endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save recording file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_recording(hObject,eventdata)
    if ispc
      [filename, pathname] = uiputfile('*.wav', 'Save as','REC.wav');
      Fname=[pathname,filename];
      audiowrite(Fname,y,fs,'BitsPerSample',nbits);
    end
endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load(hObject,eventdata)
  if ispc
    IRsavebutton = ui_PCsaveButton;
  endif
  if ismac
    IRsavebutton = ui_macSaveButton;
  endif
  ### Disable all relative ui elements
  set(ui_loadInfo, 'string', '')
  set(ui_ListenMicButton, 'enable', 'off')
  set(ui_ListenPicButton, 'enable', 'off')
  set(ui_ListenIRButton, 'enable', 'off')
  set(ui_computeIRbutton, 'enable', 'off')
  set(ui_saveRecButton, 'enable', 'off')
  set(IRsavebutton, 'enable', 'off')
  disableButtons('dummy')

  [filename, pathname] = uigetfile({'*.wav','wav files'}, 'Choose a wav file, L/Pickup, R/Mic');

  if filename == 0
    cla(ax);
    title(ax,'No file selected!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize);
    rectangle(ax2,'Position',[0,0,(round(1000))+1,20],'FaceColor',[1 0 0]);
    text(ax2,480,10,[num2str(round(100)),'%'],'fontsize', loadBarFontSize);
    enableButtons()
    return
  endif

  loading_bar(20,'Loading file...Please wait!',0.005,1)

  try
      [y,fs]=audioread([pathname,filename]);
      fileinfo = audioinfo([pathname,filename])
  catch
      title(ax,'Error loading file: unsupported format!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
      rectangle(ax2,'Position',[0,0,(round(1000))+1,20],'FaceColor',[1 0 0]);
      text(ax2,480,10,[num2str(round(100)),'%'],'fontsize', loadBarFontSize);
      enableButtons()
      return
  end_try_catch
  if getfield(fileinfo, 'NumChannels') < 2
      title(ax,'Error loading file: needs to be stereo!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
      rectangle(ax2,'Position',[0,0,(round(1000))+1,20],'FaceColor',[1 0 0]);
      text(ax2,480,10,[num2str(round(100)),'%'],'fontsize', loadBarFontSize);
      enableButtons()
      return
  end
  if getfield(fileinfo, 'Duration') < 30
      title(ax,'Error loading file: needs to be longer than 30 sec!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
      rectangle(ax2,'Position',[0,0,(round(1000))+1,20],'FaceColor',[1 0 0]);
      text(ax2,480,10,[num2str(round(100)),'%'],'fontsize', loadBarFontSize);
      enableButtons()
      return
  end

  % Set bitdepth and duration
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  nbits = getfield(fileinfo, 'BitsPerSample');
  length = getfield(fileinfo, 'Duration');

  Nb=size(y,1);
  t=(1:Nb)/fs;
  nnn=1:1000:Nb;

  set(ui_loadInfo, 'string', filename)
  cla(ax)
  title(ax,'File loaded successfully! Generating graph...','Color',loadBarColor,'fontname','Consolas','fontsize', chartTitleFontsize)
  pause(0.7)

  audio_plot(t,nnn,length)

  enableButtons()

  set(ui_ListenMicButton, 'enable', 'on')
  set(ui_ListenPicButton, 'enable', 'on')

  if audio_verify(hObject,5)
    set(ui_computeIRbutton, 'enable', 'on')
  endif

end;

function cbk_popupmenu(hObject, eventdata)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recording of Guitar and Microphone
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function record_audio(hObject,eventdata,Trec)
  if get(hObject,'value') == 1
      ## Disable all relative ui elements
      resetButtons()
      disableButtons(hObject)

      rectype = get(hObject, 'tag');
      if Trec < 0
        Trec = get(Trec, 'value');
      endif
      switch Trec
        case 1
          length=30;
        case 2
          length=60;
        case 3
          length=120;
        case 5
          length=5;
        otherwise
          length=10;
      endswitch

      indx=get(ai,'value');
      id=devinfo.input(indx).ID;
      channels=2;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Set frequency sampling
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      if get(ui_fsliste,'value')==1
        fs=44100;
      else
        fs=48000;
      endif;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Set bitdepth
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      if get(ui_bitdepth,'value')==1
        nbits=16;
      else
        nbits=24;
      endif;

      recorder = audiorecorder (fs, nbits, channels, id);
      record(recorder);

      loading_bar(length,'Recording...Please wait!',1,1)

      stop(recorder)
      enableButtons()
      if interrupt
        interrupt = false;
        title(ax,'Recording aborted!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
        return
      endif

      y = getaudiodata(recorder);
      clear recorder
      Nb=size(y,1);
      t=(1:Nb)/fs;
      nnn=1:1000:Nb;

      loading_bar(1,'Recording finished!',0,1)

      audio_plot(t,nnn,length)
      audio_ok = audio_verify(hObject,3);

      if rectype == 'real'
        set(ui_ListenMicButton, 'enable', 'on')
        set(ui_ListenPicButton, 'enable', 'on')
        if ispc
             set(ui_saveRecButton, 'enable', 'on')
        endif
        if audio_ok
            set(ui_computeIRbutton, 'enable', 'on')
        endif
      endif

      set(hObject,'value',0);
  else
      interrupt = true;
  endif
end

#################################
##        Loading bar          ##
#################################

   function loading_bar(steps,graphTitle,interval,clearGraph)
     if clearGraph == 1
       cla(ax)
     endif
     title(ax,graphTitle,'Color',loadBarColor,'fontname','Consolas','fontsize',chartTitleFontsize,'Interpreter', 'none')
     axes(ax2)
     for i=1:steps
       if interrupt
           rectangle('Position',[0,0,(round(1000*(i-1)/(steps)))+1,20],'FaceColor',[1 0 0]);
           text(480,10,[num2str(round(100*(i-1)/(steps))),'%'],'fontsize', loadBarFontSize);
           return
       endif
       cla
       rectangle('Position',[0,0,(round(1000*i/steps))+1,20],'FaceColor',loadBarColor);
       text(480,10,[num2str(round(100*i/steps)),'%'],'fontsize', loadBarFontSize);
       pause(interval)
     end;
   end

###############################
# Audio signal chart plotting #
###############################

function audio_plot(t,nnn,length)
    axes(ax)
    cla
    set(ax, 'XScale', 'linear')
    xticks('auto')
    xticklabels('auto')
    xlim([0 length])
    ylim([-0.5 0.5])
    xlabel('time(s)')
    ylabel('amplitude (a.u.)')
    plot(xlim,[0.1 0.1],'Color', chartRecBarsColor,'linewidth',2)
    plot(xlim,[-0.1 -0.1],'Color', chartRecBarsColor,'linewidth',2)
    plot([length/50 length/20],[-0.4 -0.4],'Color', chartPicColor,'linewidth',2)
    text(length/18,-0.4,"Pickup",'Color', chartPicColor, 'fontsize', chartLabelsFontsize)
    plot([length/50 length/20],[-0.45 -0.45],'Color', chartMicColor,'linewidth',2)
    text(length/18,-0.45,"Microphone",'Color', chartMicColor, 'fontsize', chartLabelsFontsize)
    plot(t(nnn),y(nnn,1),'color',chartPicColor,t(nnn),y(nnn,2),'color',chartMicColor');
end

###############################
# Audio signal verification  ##
###############################
function audio_ok = audio_verify(hObject,mictopicdelta)

    mic_signal_strength = max(max(abs(y(:,MIC))));
    pic_signal_strength = max(max(abs(y(:,PIC))));
    if pic_signal_strength >= 1
        title('Pickup signal is too loud: decrease the volume!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
        audio_ok = false;
        return
    endif
    if mic_signal_strength >= 1
        title('Microphone signal is too loud: decrease the volume!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
        audio_ok = false;
        return
    endif
    if pic_signal_strength <= 0.1
        title('Pickup signal is too weak: increase the volume!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
        audio_ok = false;
        return
    endif
    if mic_signal_strength <= 0.1
        title('Microphone signal is too weak: increase the volume!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
        audio_ok = false;
        return
    endif
    if pic_signal_strength/mic_signal_strength < 1/mictopicdelta || pic_signal_strength/mic_signal_strength > mictopicdelta
        title('Huge difference in volume! Balance the signals!','Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
        audio_ok = false;
        return
    endif

    if (pic_signal_strength+mic_signal_strength)/2 <= 0.25
        title('The signals are decent, but you might increase them!','Color',[0.9290 0.6940 0.1250],'fontname','Consolas','fontsize',chartTitleFontsize)
    else
        title('The signals are Perfect!','Color',[0.4660 0.6740 0.1880],'fontname','Consolas','fontsize',chartTitleFontsize)
    endif
    audio_ok = true;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Go: Compute IR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Go(hObject,eventdata)
  if ispc
    IRsavebutton = ui_PCsaveButton;
  endif
  if ismac
    IRsavebutton = ui_macSaveButton;
  endif
  set(ui_ListenIRButton, 'enable', 'off');
  set(IRsavebutton, 'enable', 'off');
  disableButtons('dummy')
  title(ax,'Generating IR...Please wait!','Color',loadBarColor,'fontname','Consolas','fontsize',chartTitleFontsize)
  axes(ax2)
  cla
  rectangle('Position',[0,0,(round(1000*0))+1,20],'FaceColor',loadBarColor);
  text(480,10,[num2str(round(100*0)),'%'],'fontsize', loadBarFontSize);
  pause(0.01)
  Nb=size(y,1);
  Nb=size(y,1);
  indxfmt=get(ui_fsfmt,'value');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIR calculaiton
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FIR1 =zeros(NbF,1);
clear alice;

for n=1:Nbmax, % 200
        q=n;
        i=2*fs;
        i=i+n*Nbuff;

%        window = (.42-.5*cos(2*pi*(0:Nbuff-1)/(Nbuff-1))+.08*cos(4*pi*(0:Nbuff-1)/(Nbuff-1)))';
%        FIR=fft(y(:,MIC)(i:i+Nbuff-1).*window,NbF)./fft(PIC(i:i+Nbuff-1).*window,NbF);
        FIR=fft(y(:,MIC)(i:i+Nbuff-1),NbF)./fft(y(:,PIC)(i:i+Nbuff-1),NbF);
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
	                rectangle('Position',[0,0,(round(1000*n/Nbmax/3))+1,20],'FaceColor',loadBarColor);
                  text(480,10,[num2str(round(100*n/Nbmax/3)),'%'],'fontsize', loadBarFontSize);
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

        A=a(abs(abs(a)-mean(a))<2*std(a)); % On ne garde que les echantillons compris dans 2 ecarts types

        try
          ALICE(i)=mean(A);
        catch
          sadface("Algorithm Failed: Increase the recording length and/or improve the S/N ratio")
          return
        end
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
	                rectangle('Position',[0,0,(round(1000*(1/3+i/NN/3)))+1,20],'FaceColor',loadBarColor);
                  text(480,10,[num2str(round(100*(1/3+i/NN/3))),'%'],'fontsize', loadBarFontSize);
                  pause(0.01)
            %waitbar(n/Nbmax,f,'Processing...');
        end;
    end;
dnuX=fs/NbF;
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
nn=(10*fs+1:20*fs);
try
  MS=y(:,MIC)(nn,1);
  PS=y(:,PIC)(nn,1);
catch
 sadface("Algorithm Failed: Unknown reason!")
 return
end

%waitbar(0.6, h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Two Octave spectrum (Mic & Pic convolved)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%pkg load signal;
PS=conv(y(:,PIC)(nn,1),IR0,'same');

[p,cf,overall_lev,overall_levA,sfilt] = oct_spectrum2(MS/max(abs(MS)),fs,3,1,1,0);
[p2,cf2,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS/max(abs(PS)),fs,3,1,1,0);

pp=[p+100;p2+100];

g0=p-p2; % SB-SB2;
%dgain=zeros(31,1); % il est l� le probl�me
dgain=zeros(length(cf),1); % il est l� le probl�me

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

###########################################################################
##   This section seems  was used while the algorithm was developed      ##
##   Unfortunately after moving this function as a subfunction of the    ##
##   main one, the eval function is working only with predefined vars    ##
##   Since it is not really used, I won't bother to find a way to fix it ##
###########################################################################
##        mot=['b',num2str(i,'%02d'),'=b;'];
##        eval(mot);
##        mot=['a',num2str(i,'%02d'),'=a;'];
##        eval(mot);

    end;

    dnuX=fs/NbF;
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
	  rectangle('Position',[0,0,(round(1000*(2/3+qq*0.1)))+1,20],'FaceColor',loadBarColor);
    text(480,10,[num2str(round(100*(2/3+qq*0.1))),'%'],'fontsize', loadBarFontSize);
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

  n800=(abs(nuX)<800);
  nuX2=nuX(n800);
  s12=s1(n800);
  [pks idx] = max(s12);
  f_mx=abs(nuX2(idx))

%[pks idx] = max(s1);
%f_mx=abs(nuX(idx));

### Drawing time ###
axes(ax)
cla
semilogx(nuX(n2),s1(n2),'color', chartIRColor);
xticks([20 50 100 200 400 800 1600 3200 6400 12000 20000])
xticklabels({'20Hz','50Hz','100Hz','200Hz','400Hz','800Hz','1.6kHz','3.2kHz','6.4kHz','12kHz','20kHz'})
ylim('auto')
xlim([20 22050])
xlabel('frequency (Hz)')
ylabel('dB')
plot(xlim,[0 0],'Color',fgColor,'linewidth',1,'linestyle',':')
plot(f_mx,pks,'or')
text(f_mx+50,pks,[num2str(f_mx,'%3.0f'),'Hz'],'color', 'r', 'fontsize', chartLabelsFontsize);

mot=['IR spectrum, feedback frequency is: ',num2str(f_mx,'%3.0f'),'Hz'];
title(mot,'Color', chartIRColor,'fontname','Consolas','fontsize',chartTitleFontsize)


  axes(ax2)
  %cla
	rectangle('Position',[0,0,(round(1000*(1)))+1,20],'FaceColor',loadBarColor);
  text(480,10,[num2str(round(100*(1))),'%'],'fontsize', loadBarFontSize);

  enableButtons()
  set(ui_ListenIRButton, 'enable', 'on')
  set(IRsavebutton, 'enable', 'on')

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Listen to Mic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Mic(hObject, eventdata)
    if get(hObject,'value') == 1
      disableButtons(hObject)

      Nb=size(y,1);
      n3=10*fs:20*fs;
      indx=get(ao,'value');
      id=devinfo.output(indx).ID;

      player = audioplayer (y(:,MIC)(n3), fs, nbits, id);
      play(player);
      while(isplaying(player))
        pause(0.5)
      endwhile
      clear player;
      set(hObject,'value',0);
      enableButtons()
    else
      stop(player)
    endif
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Listen to Pickup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pickup(hObject,eventdata)
    if get(hObject,'value') == 1
      disableButtons(hObject)

      Nb=size(y,1);
      n3=10*fs:20*fs;
      indx=get(ao,'value');
      id=devinfo.output(indx).ID;

      player = audioplayer (y(:,PIC)(n3), fs, nbits, id);
      play(player);
      while(isplaying(player))
        pause(0.5)
      endwhile
      clear player;
      set(hObject,'value',0);
      enableButtons()
    else
      stop(player)
    endif
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Listen to IR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function IR(hObject,eventdata)
    if get(hObject,'value') == 1
      disableButtons(hObject)

      IRGEQ=IR1;
      Nb=size(y,1);
      n3=10*fs:20*fs;

      PS=conv(y(:,PIC)(n3),IRGEQ,'same');
      PS=PS/max(abs(PS))*max(abs(y(:,PIC)(n3)));
      %soundsc(PS,fs,nbits);
      indx=get(ao,'value');
      id=devinfo.output(indx).ID;

      player = audioplayer (PS, fs, nbits, id);
      play(player);
      while(isplaying(player))
        pause(0.5)
      endwhile
      clear player;
      set(hObject,'value',0);
      enableButtons()
    else
      stop(player)
    endif
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save IR file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save(hObject,eventdata)
  disableButtons('dummy')
  switch get(ui_outputLevel, 'value')
    case 1
      outLevel = 0.5
    case 2
      outLevel = 0.6
    case 3
      outLevel = 0.7
    case 4
      outLevel = 0.8
    otherwise
      outLevel = 0.95
  endswitch

  rawIR=IR2;
  IRGEQ=IR1;
  Nb=size(IRGEQ,1);

  indxfmt=get(ui_fsfmt,'value');
  if (indxfmt <= 3)
    nbits=16;
  else
    nbits=24;
  endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SMooth the high end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NbF=Nb;
dnuX1=fs/NbF;
nuX1=(-NbF/2:NbF/2-1)*dnuX1;

wi = fs/2/1e4*logspace(1,4,NbF);
w=sort([-wi,0,wi],2);

s=fftshift(fft(IRGEQ));
ss=interp1(nuX1,s,w); % On interpole sur une grille/echelle log en frequence (perte d'info dans le haut du spectre

##figure
##plot(nuX1,abs(s),w,abs(ss))
##grid on
##title('amplitude')
##
##figure
##plot(nuX1,abs(s),w,abs(ss))
##grid on
##title('phase')

snew=interp1(w,ss,nuX1); % On retourne sur une grille lineaire
%snew=interp1(w,ss,nuX1,'spline');

% On vire les NaN
for i=1:length(IRGEQ)
    if isnan(snew(i))
        snew(i)=s(i);
    end;
end;

##s1new=20*log10(abs(snew));
##
##figure(1)
##%hold on
##plot(nuX1,s1,nuX1,s1new);
##grid on
##set(gca,'Xscale','log')
##xlim([20 20e3])
##ylim([-60 40])
##xlabel('Frequency (Hz)')
##ylabel('dB')
##%hold off

yy=real(ifft(ifftshift(snew)));
%IR0old=IR0;
IRITP=yy/max(abs(yy))*0.95;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % STD version
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ispc
    [filename, pathname] = uiputfile('*.wav', 'Save as','IR.wav');
    Fname=[pathname,filename];
    if filename == 0
      enableButtons()
      return
    endif
    audiowrite(Fname,IRGEQ/max(abs(IRGEQ))*outLevel,fs,'BitsPerSample',nbits);
  end
  if ismac
    Fname=get(Fnam,'string');
    if Fname == ''
      enableButtons()
      return
    endif
    audiowrite(Fname,IRGEQ/max(abs(IRGEQ))*outLevel,fs,'BitsPerSample',nbits);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % IMAGE generation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Fname=[Fname(1:end-4),'.jpg'];
  set(ax, 'units', 'pixels');
  rect_ax = get(ax, 'position') + [ -50 -50 70 100 ];
  set(ax, 'units', 'normalized');
  set(ax2, 'visible', 'off');
  cla(ax2);
  imwrite(getframe(gcf,rect_ax).cdata, Fname, 'Quality', 100);
  set(ax2, 'visible', 'on')
  display(filename)
  loading_bar(1,['IR saved successfully as ', filename, '!'],0,0)
##  print(gcf,Fname2,'-jpg','-r300');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ITP version
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  SAVEfmt=get(Svfmt,'value');
  if SAVEfmt < 5
    if ispc
      filename = [filename(1:end-4),'_itp.wav']
      Fname2=[pathname,filename];
      audiowrite(Fname2,IRITP/max(abs(IRITP))*outLevel,fs,'BitsPerSample',nbits);
    end
    if ismac
      Fname2=[Fname(1:end-4),'_ITP.wav'];
      audiowrite(Fname2,IRITP/max(abs(IRITP))*outLevel,fs,'BitsPerSample',nbits);
    end
  endif
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Options
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if SAVEfmt==2
    % Raw
    Fname2=[Fname(1:end-4),'_raw.wav'];
    audiowrite(Fname2,rawIR/max(abs(rawIR))*outLevel,fs,'BitsPerSample',nbits);
    % GEQ+Blend
    IR0=zeros(Nb,1);
    IR0(1)=1;
    IRblend=(IR0+IRGEQ)/2;
    Fname2=[Fname(1:end-4),'_Bld.wav'];
    audiowrite(Fname2,IRblend/max(abs(IRblend))*outLevel,fs,'BitsPerSample',nbits);
    % Minimum Phase
    s=fft(IRGEQ);
    sm = exp( fft( fold( ifft( log( clipdb(s,-100) )))));
    IRmph=real(ifft(sm));
    Fname2=[Fname(1:end-4),'_MPh.wav'];
    audiowrite(Fname2,IRmph/max(abs(IRmph))*outLevel,fs,'BitsPerSample',nbits);
  end;
  if SAVEfmt==3 % Feedback friendly

    Nb=size(y,1);

  nn=(10*fs+1:20*fs);
  MS=y(:,MIC)(nn,1);
  PS=y(:,PIC)(nn,1);

  % COmpute Feedback frequency
  NbF=Nb;
  dnuX=fs/NbF;
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
  g=-6; % -6dB � la resonance
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
    PS0=conv(y(:,PIC)(nn,1),IRGEQ,'same');
    PS1=conv(y(:,PIC)(nn,1),IRX1,'same');
    PS2=conv(y(:,PIC)(nn,1),IRX2,'same');
    PS3=conv(y(:,PIC)(nn,1),IRX3,'same');
    PS4=conv(y(:,PIC)(nn,1),IRX4,'same');

    [p,cf,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS0/max(abs(PS0)),fs,3,1,1,0);
    [p21,cf21,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS1/max(abs(PS1)),fs,3,1,1,0);
    [p22,cf22,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS2/max(abs(PS2)),fs,3,1,1,0);
    [p23,cf23,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS3/max(abs(PS3)),fs,3,1,1,0);
    [p24,cf24,overall_lev,overall_levA,sfilt] = oct_spectrum2(PS4/max(abs(PS4)),fs,3,1,1,0);
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
      audiowrite(Fname2,IRX1/max(abs(IRX1))*outLevel,fs,'BitsPerSample',nbits);
    end
    if (iw ==2)
      audiowrite(Fname2,IRX2/max(abs(IRX2))*outLevel,fs,'BitsPerSample',nbits);
    end
    if (iw ==3)
      audiowrite(Fname2,IRX3/max(abs(IRX3))*outLevel,fs,'BitsPerSample',nbits);
    end
    if (iw ==4)
      audiowrite(Fname2,IRX4/max(abs(IRX4))*outLevel,fs,'BitsPerSample',nbits);
    end

  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JF45 BEGINING OF Jon Fields Algorithm Copyright Jon Fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if SAVEfmt==4 % JF45

    Nb=size(y,1);

    MS=y(:,MIC)(:,1);
    PS=y(:,PIC)(:,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # IR generation:
      ss = (2^17); # ~3 second segment size for analysis
      nstep = 2; # segment step ~6 seconds
      nstart = 3; # index into .wav in segments, ~6 seconds
      nlast = 17; # up to 8 segments checked
      count = 0; # initialize good segment count
      nzcount = 0; # initialize near zero count
      accirfftnnz = zeros(ss,1); # initialize no near zero IR
      # Blackman window function:
      window = (.42-.5*cos(2*pi*(0:ss-1)/(ss-1))+.08*cos(4*pi*(0:ss-1)/(ss-1)))';
      for n = nstart:nstep:nlast # process segments
        start = (((n-1) * ss) + 1);
        finish = (n * ss);
        # load segment from wav file
        %[s,fs] = audioread([input,'.wav'],[start, finish]);
        s=y(start:finish,:);
        smax = max(max(s));
        clip = (smax > 0.999); # check for clipping
        toolow = (smax < 0.178); # 15 dB down
        # calculate per segment IR
        if (clip == 0 && toolow == 0 && count < 4)
          pickup = PS(start:finish) .* window;
          microphone = MS(start:finish) .* window;
          pupfft = fft(pickup);
          micfft = fft(microphone);
          pupfftnnz = pupfft;
          micfftnnz = micfft;
          nearzero = 10^(-65/20)*abs(max(pupfft)); # -65dB
          for m = 1:1:ss
            # check and fix  near zeros in pickup FFT
            if (abs(pupfft(m)) < nearzero)
              nzcount = nzcount + 1; # Count near 0s
              pupfftnnz(m) = 1; # erase near zero
              micfftnnz(m) = 1; # erase near zero
            end
          end
          # IR=FFT(mic)/FFT(PUP)
          irfftnnz = micfftnnz ./ pupfftnnz;
          # accumulate IRs
          accirfftnnz = accirfftnnz + irfftnnz;
          count = count + 1; # increment segment count
        end
      end
      if(count==0)
      ['Zero Segments Processed due to Clip/Min errors']
      return;
    end
    irnnz = ifft(accirfftnnz/count); # calc IR
    ir2048nnz = irnnz(1:2048); # truncate to 2048
    avgnzcount = nzcount / (count*2);
%    ['Processed Segments = ',num2str(count)]
%    ['Average Near Zero per Segment = ',num2str(avgnzcount)]
%    filename = ['jf45ir',input,'.wav'];
%    audiowrite(filename,ir2048nnz,fs); # write IR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF Jon Fields Algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Fname2=[Fname(1:end-4),'_JF45.wav'];
    audiowrite(Fname2,ir2048nnz/max(abs(ir2048nnz))*outLevel,fs,'BitsPerSample',nbits);
  end;
  enableButtons()
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close app
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close(hObject, eventdata)
  close(dlg)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Donate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Donate(hObject, eventdata)
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

  function sadface(error_reason)
      axes(ax)
      cla
      set(ax,'XScale', 'linear','xlim',[-2 2],'ylim',[-1 2])
      title(error_reason,'Color',[1 0 0],'fontname','Consolas','fontsize',chartTitleFontsize)
      text(0,1.7,"Please try again!",'color',fgColor,'fontname','Consolas','fontsize',40,'fontweight','bold','horizontalalignment','center');
      plot(-0.6,1,'o','color',fgColor,"markersize", 24, 'linewidth', 2)
      plot(-0.62,0.95,'.','color',fgColor,"markersize", 12, 'linewidth', 1)
      plot(0.6,1,'o','color',fgColor,"markersize", 24, 'linewidth', 2)
      plot(0.58,0.95,'.','color',fgColor,"markersize", 12, 'linewidth', 1)
      plot(-0.6,0.7,'^','color',fgColor,"markersize", 8, 'linewidth', 1)
      plot(0,0.5,'x','color',fgColor,"markersize", 10, 'linewidth', 2)
      sadx = -1 : 0.01 : 1
      sady = (sadx.^2)*-0.5
      plot(sadx, sady,'color',fgColor,'linewidth',2)
      enableButtons()
   endfunction

end;

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
##* Neither the name of Universit� degli Studi di Ferrara nor the names of its
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
##Copyright � 2020-05-11 by Julius O. Smith III
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
