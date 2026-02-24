function rubat()
% RUBAT Studio  (v4.0)
% copyright: 2026 Ravi Umadi

% vTag: 6554779

% Requirements:

% 'MATLAB'
% 'Signal Processing Toolbox'
% 'DSP System Toolbox'
% 'Audio Toolbox'

try, delete(timerfindall); catch, end %#ok<TNMLP>

%% ─── FONT ────────────────────────────────────────────────────────────────
FONT = resolveFont({'Lato','Calibri','Segoe UI','Helvetica Neue','Arial'});

%% ─── COLOURS ─────────────────────────────────────────────────────────────
C.bg        = [0.12 0.13 0.15]; % overall figure background, color: #1E2126
C.surface   = [0.17 0.18 0.21]; % panel background, color: #2B2E34 
C.border    = [0.25 0.27 0.31]; % panel borders, color: #40444A
C.accent    = [0.20 0.60 0.90]; % general accent (buttons, highlights), color: #3399E6
C.accentHot = [0.95 0.35 0.25]; % hot accent (record button, errors), color: #F25A3C
C.accentGo  = [0.18 0.72 0.44]; % go accent (start button), color: #2EB86C
C.txt       = [0.92 0.93 0.95]; % main text, color: #EBEEF0
C.txtDim    = [0.55 0.57 0.62]; % dimmed text, color: #8C9096
C.disabled  = [0.20 0.21 0.24]; % disabled controls, color: #33363D

%% ─── STATE ───────────────────────────────────────────────────────────────
S = struct();

% Defaults
S.fsRequested  = 192000;   S.fsActual = 192000;
S.frameLength  = 4096;     % selected from dropdown
S.maxInCh      = 0;        S.inChMask = true(1,1); S.inChIdx = 1;
S.maxOutCh     = 0;        S.outChMask= true(1,2); S.outChIdx= [1 2];
S.waveChan=1; S.specChan1=1; S.specChan2=1;

S.preTrigSec=3.0; S.postTrigSec=2.0; S.ringMaxSec=20.0;

% Default destination: ~/Documents/RUBAT/Rec/YYYYMMDD/
S.destFolder = localDefaultDestFolder();
S.suffix="";

S.recMode="Tap"; S.tapCapturing=false; S.tapNeeded=0; S.tapData=[];
S.contRecording=false; S.wavW=[]; S.contFileName="";

% Auto-recording state
S.autoEnabled = false;                 % armed or not
S.autoThrDb   = 70;                    % dB (SPL if calibrated, else relative)
S.autoMinPeaks= 2;                     % required events within last preTrig window
S.autoCalibPaPerUnit = 0;              % Pa per unit (0 => no absolute calibration)
S.autoIpiSec  = 0.003;                 % event grouping gap (sec) lightweight
S.autoEventSamples = zeros(0,1,'int64');
S.sampleCounter = int64(0);            % absolute sample counter (input Fs domain)
S.autoCooldownSamp = int64(0);         % cooldown after trigger
S.autoCooldownSec  = 0.25;             % avoid immediate re-trigger

% Monitoring params (monitor path only)
S.outMode = "Off";                 % Off / Passthrough / Heterodyne
S.hetCarrierHz=45000;
S.mixToBoth=false;
S.monitorGain = 1.0;              % software monitor gain only
S.outFsReq=48000; S.outFsActual=48000;
S.hetPhase=0;

% NEW: explicit monitor channel selection (input channels listened to in L/R)
S.monLeftChan  = 1;
S.monRightChan = 2;

% Bit depth (UI + attempt open)
S.inBitDepthReq  = "32-bit float";
S.outBitDepthReq = "32-bit float";
S.inBitDepthActual  = "";
S.outBitDepthActual = "";

% Resample params (precomputed once per START)
S.useResample = false;
S.rsP = 1; S.rsQ = 1;

% Buffers / runtime
S.ring=[]; S.ringWriteIdx=1; S.ringFilled=0;

% Wave display (now in dB SPL)
S.waveDispSec=3.0;
S.wavePlotFs=8000;
S.waveDecim=1;
S.waveBufDb=[];
S.waveIdx=1;

% Spectrogram
S.specWin=1024; S.specOLap=0; S.specNFFT=2048; S.specDispSec=3.0;
S.specMaxHz=[]; S.specHop=[]; S.specCols=[]; S.specFreq=[];
S.specWinVec=[]; S.specBuf1=[]; S.specBuf2=[]; S.specColIdx1=1; S.specColIdx2=1;

S.uiFps=15; S.lastUiTic=tic; S.isRunning=false;
S.frameDur=0; S.lastDt=0; S.dropEvents=0; S.reader=[]; S.writer=[];
S.showVisuals=true;
S.lastShowVisuals=true;  % tracks previous state to detect transitions
S.lastCalibActive=false;   % tracks calibration state for wave axes update
S.lastSpecYTop=0;          % tracks last spectrogram Y ceiling to avoid redundant YLim sets

% Output framing / writer expectations
S.outFrameSize = [];      % fixed write size
S.outNumChannels = 2;
S.outBuffer = zeros(0,2);

% Device registries
S.inDevRegistry =struct('label',{'Default'},'tbName',{'Default'},'devid',{-1});
S.outDevRegistry=struct('label',{'Default'},'tbName',{'Default'},'devid',{-1});

% Per-device supported lists
S.fsInList   = {'44100','48000','88200','96000','176400','192000','352800','384000','705600','768000'};
S.fsOutList  = {'44100','48000','88200','96000','176400','192000','352800','384000','705600','768000'};
S.bitsInList = {'16','24','32'};         % displayed as numbers; mapped internally
S.bitsOutList= {'16','24','32'};

% Standard frame sizes (buffer)
S.frameList = {'256','512','1024','2048','4096','8192','16384'};

S.infoLines={};

% Duplex not used (kept for future)
S.duplex = [];
S.useDuplex = false;

% Writer lifecycle state (set at START, used by applyWriterState during run)
S.outRunID            = -1;     % device ID opened at START
S.sameDeviceRun       = false;  % same-device flag used at START
S.writerFailedThisRun = false;  % set on first mid-run open failure; prevents repeated PortAudio thrashing

%% ─── FIGURE ──────────────────────────────────────────────────────────────
fig = uifigure('Name','RUBAT Studio by Sounds and Senses Lab','Position',[10 10 1500 980],'Color',C.bg);
applyFontToFig(fig,FONT);
fig.KeyPressFcn = @onKeyPress;

rootGL = uigridlayout(fig,[1 2]);
rootGL.ColumnWidth={520,'1x'}; rootGL.RowHeight={'1x'};
rootGL.Padding=[10 10 10 10]; rootGL.ColumnSpacing=12;
rootGL.BackgroundColor=C.bg;


leftWrap=uipanel(rootGL,'Title','','BackgroundColor',C.bg,'BorderType','none');
leftWrap.Layout.Row=1; leftWrap.Layout.Column=1; leftWrap.Scrollable='on';

leftGL=uigridlayout(leftWrap,[6 1]);
leftGL.RowHeight   ={120, 170, 190, 150, 220, 60}; % Dev, Ch, Mon, Rec, Run, Resources
leftGL.ColumnWidth={'1x'}; leftGL.Padding=[4 4 4 4];
leftGL.RowSpacing=8; leftGL.BackgroundColor=C.bg;
leftGL.Scrollable = 'on';

rightGL=uigridlayout(rootGL,[3 1]);
rightGL.Layout.Row=1; rightGL.Layout.Column=2;
rightGL.RowHeight={'1.1x','1x','1x'}; rightGL.ColumnWidth={'1x'};
rightGL.RowSpacing=10; rightGL.BackgroundColor=C.bg;

axWave =uiaxes(rightGL); axWave.Layout.Row=1;
axSpec1=uiaxes(rightGL); axSpec1.Layout.Row=2;
axSpec2=uiaxes(rightGL); axSpec2.Layout.Row=3;

styleAxes(axWave, 'Waveform (dBFS)', 'Time (s)', 'Level (dBFS)', C, FONT);
axWave.YGrid    = 'on';
axWave.YLimMode = 'manual';
axWave.YLim     = [-120 0];
axWave.YTick    = -120:10:0;
styleAxes(axSpec1,'Spectrogram CH A',  'Time (s)','Freq (kHz)', C,FONT);
styleAxes(axSpec2,'Spectrogram CH B',  'Time (s)','Freq (kHz)', C,FONT);

axWave.XLim=[0 S.waveDispSec];

waveLine=plot(axWave,nan,nan,'-','Color',C.accent,'LineWidth',1.2);

img1=image(axSpec1,'XData',[0 1],'YData',[0 1],...
    'CData',zeros(2,2,'single')-120,'CDataMapping','scaled'); axis(axSpec1,'xy');
img2=image(axSpec2,'XData',[0 1],'YData',[0 1],...
    'CData',zeros(2,2,'single')-120,'CDataMapping','scaled'); axis(axSpec2,'xy');

% Greyscale spectrogram (black->white)
clim(axSpec1,[-120 0]); clim(axSpec2,[-120 0]);
axSpec1.Color = [0 0 0]; axSpec2.Color = [0 0 0];
axSpec1.XColor = C.txtDim; axSpec1.YColor = C.txtDim;
axSpec2.XColor = C.txtDim; axSpec2.YColor = C.txtDim;
colormap(axSpec1, gray(256));
colormap(axSpec2, gray(256));

%% ════════════════════════════════════════════════════════════════════════
%% PANEL 1 — Device Selection
%% ════════════════════════════════════════════════════════════════════════
pDev=makePanel(leftGL,'Device Selection',1,C,FONT);

dg=uigridlayout(pDev,[3 5]);
dg.RowHeight={18, 28, 28};
dg.ColumnWidth={'0.3x','1.5x','1x','0.65x','1x'};
dg.Padding=[12 8 12 8]; dg.RowSpacing=4; dg.ColumnSpacing=6;
dg.BackgroundColor=C.surface;
dg.Scrollable = 'on';

mkLabel(dg,'I/O',1,1,FONT,C);
mkLabel(dg,'Device',1,2,FONT,C);
mkLabel(dg,'Sample rate',1,3,FONT,C);
mkLabel(dg,'Bit depth',1,4,FONT,C);
mkLabel(dg,'Frame size',1,5,FONT,C);

lbInLabel=uilabel(dg,'Text','▶ IN','FontName',FONT,'FontSize',9,...
    'FontWeight','bold','FontColor',C.accentGo,'BackgroundColor','none',...
    'HorizontalAlignment','left');
lbInLabel.Layout.Row=2; lbInLabel.Layout.Column=1;

ddIn =mkDropdown(dg,{'— Select input —'},'— Select input —',2,2,FONT,C);
ddFsIn =mkDropdown(dg,S.fsInList,'192000',2,3,FONT,C);
ddBitsIn=mkDropdown(dg,S.bitsInList,'32',2,4,FONT,C);
ddFrame=mkDropdown(dg,S.frameList,num2str(S.frameLength),2,5,FONT,C);

lbOutLabel=uilabel(dg,'Text','▶ OUT','FontName',FONT,'FontSize',9,...
    'FontWeight','bold','FontColor',C.accentHot,'BackgroundColor','none',...
    'HorizontalAlignment','left');
lbOutLabel.Layout.Row=3; lbOutLabel.Layout.Column=1;

ddOut=mkDropdown(dg,{'(none)'},'(none)',3,2,FONT,C);
ddFsOut=mkDropdown(dg,S.fsOutList,'48000',3,3,FONT,C);
ddBitsOut=mkDropdown(dg,S.bitsOutList,'32',3,4,FONT,C);

btnRefresh=uibutton(dg,'Text','↺  Refresh',...
    'BackgroundColor',[0.18 0.38 0.60],'FontColor',C.txt,...
    'FontName',FONT,'FontSize',10,'FontWeight','bold');
btnRefresh.Layout.Row=3; btnRefresh.Layout.Column=5;

%% ════════════════════════════════════════════════════════════════════════
%% PANEL 2 — Channel Selection
%% ════════════════════════════════════════════════════════════════════════
pCh=makePanel(leftGL,'Channel Selection',2,C,FONT);
chOuterGL=uigridlayout(pCh,[3 1]);
chOuterGL.RowHeight={20,26,'1x'}; chOuterGL.ColumnWidth={'1x'};
chOuterGL.Padding=[8 6 8 6]; chOuterGL.RowSpacing=4;
chOuterGL.BackgroundColor=C.surface;

lbChStatus=uilabel(chOuterGL,'Text','Click ↺ Refresh to probe devices',...
    'FontName',FONT,'FontSize',10,'FontAngle','italic',...
    'FontColor',C.txtDim,'BackgroundColor','none');
lbChStatus.Layout.Row=1; lbChStatus.Layout.Column=1;

tabBtnGL=uigridlayout(chOuterGL,[1 3]);
tabBtnGL.Layout.Row=2; tabBtnGL.Layout.Column=1;
tabBtnGL.ColumnWidth={'1x','1x','1x'}; tabBtnGL.RowHeight={'1x'};
tabBtnGL.Padding=[0 0 0 0]; tabBtnGL.ColumnSpacing=4;
tabBtnGL.BackgroundColor=C.surface;

btnTabIn=uibutton(tabBtnGL,'Text','▶ Input channels',...
    'FontName',FONT,'FontSize',10,'FontWeight','bold',...
    'BackgroundColor',C.accent,'FontColor',[0 0 0]);
btnTabIn.Layout.Row=1; btnTabIn.Layout.Column=1;

btnTabOut=uibutton(tabBtnGL,'Text','Output channels',...
    'FontName',FONT,'FontSize',10,...
    'BackgroundColor',[0.22 0.24 0.28],'FontColor',C.txtDim);
btnTabOut.Layout.Row=1; btnTabOut.Layout.Column=2;

btnRefreshCh=uibutton(tabBtnGL,'Text','↺ Recheck',...
    'FontName',FONT,'FontSize',10,...
    'BackgroundColor',[0.18 0.38 0.60],'FontColor',C.txt);
btnRefreshCh.Layout.Row=1; btnRefreshCh.Layout.Column=3;

chPanelHost=uipanel(chOuterGL,'Title','','BorderType','none',...
    'BackgroundColor',C.surface,'AutoResizeChildren','off');
chPanelHost.Layout.Row=3; chPanelHost.Layout.Column=1;

inBoxPanel=uipanel(chPanelHost,'Title','','BorderType','none',...
    'BackgroundColor',C.surface,'Scrollable','on',...
    'Units','normalized','Position',[0 0 1 1],'Visible','on');
outBoxPanel=uipanel(chPanelHost,'Title','','BorderType','none',...
    'BackgroundColor',C.surface,'Scrollable','on',...
    'Units','normalized','Position',[0 0 1 1],'Visible','off');

%% ════════════════════════════════════════════════════════════════════════
%% PANEL 3 — Monitoring & Display  (old layout + ONLY add Mon L / Mon R)
%% ════════════════════════════════════════════════════════════════════════
pMon = makePanel(leftGL,'Monitoring & Display',3,C,FONT);

mg = uigridlayout(pMon,[6 8]);
mg.RowHeight    = {18, 26, 18, 26, 18, 26};
%                  lbl  dd   lbl  sl   lbl  misc-ctrls
mg.ColumnWidth  = {'0.5x','0.5x','0.5x','0.5x', '0.5x','0.5x','0.5x','0.5x'};
mg.Padding      = [12 8 12 8];
mg.RowSpacing   = 4;
mg.ColumnSpacing = 6;
mg.BackgroundColor = C.surface;

% ── Row 1: dropdown labels ───────────────────────────────────────────
mkLabel(mg,'Output mode', 1,[1 2],FONT,C);
mkLabel(mg,'Waveform CH', 1,[3 4],FONT,C);
mkLabel(mg,'Spec A CH',   1,[5 6],FONT,C);
mkLabel(mg,'Spec B CH',   1,[7 8],FONT,C);

% ── Row 2: dropdowns ─────────────────────────────────────────────────
ddOutMode = mkDropdown(mg,{'Off','Passthrough','Heterodyne'},char(S.outMode),2,[1 2],FONT,C);
ddWave    = mkDropdown(mg,{'—'},'—',2,[3 4],FONT,C);
ddSpec1   = mkDropdown(mg,{'—'},'—',2,[5 6],FONT,C);
ddSpec2   = mkDropdown(mg,{'—'},'—',2,[7 8],FONT,C);

% ── Row 3: slider labels ─────────────────────────────────────────────
mkLabel(mg,'Carrier Freq.',  5,[1 2],FONT,C);
lbCarVal = uilabel(mg,'Text',sprintf('%d Hz',S.hetCarrierHz),...
    'FontName',FONT,'FontSize',10,'FontWeight','bold',...
    'FontColor',C.accent,'VerticalAlignment','bottom', ...
    'HorizontalAlignment','left','BackgroundColor','none');
lbCarVal.Layout.Row = 5; lbCarVal.Layout.Column = 4;

mkLabel(mg,'Monitor gain',5,[5 6],FONT,C);

% ── Row 4: sliders ───────────────────────────────────────────────────
slCar = uislider(mg,'Limits',[1000 96000],'Value',min(S.hetCarrierHz,96000),...
    'MajorTicks',[],'MinorTicks',[],'FontColor',C.accent);
slCar.Layout.Row = 6; slCar.Layout.Column = [1 4];

slMonGain = uislider(mg,'Limits',[0 4],'Value',S.monitorGain,...
    'MajorTicks',[],'MinorTicks',[],'FontColor',C.accent);
slMonGain.Layout.Row = 6; slMonGain.Layout.Column = [5 8];

% ── Row 5: misc labels ───────────────────────────────────────────────
% mkLabel(mg,'         Mix L+R', 3,1,FONT,C); 
mkLabel(mg,'Spec Ymax',        3,3,FONT,C);
mkLabel(mg,'UI FPS',           3,4,FONT,C);
mkLabel(mg,'Mon. Left',        3,[5 6],FONT,C);
mkLabel(mg,'Mon. Right',           3,[7 8],FONT,C);
% ── Row 6: misc controls ─────────────────────────────────────────────
cbMix     = mkCheckbox(mg,' Mix L+R',  S.mixToBoth,   4, 1, FONT, C);
cbVisuals = mkCheckbox(mg,' Visuals',  S.showVisuals, 4, 2, FONT, C);

edSpecMax = uieditfield(mg,'numeric','Limits',[0 500000],'Value',0,...
    'FontName',FONT,'FontSize',10,'BackgroundColor',C.surface,'FontColor',C.txt);
edSpecMax.Layout.Row = 4; edSpecMax.Layout.Column = 3;

edUiFps = uieditfield(mg,'numeric','Limits',[1 60],'RoundFractionalValues','on',...
    'Value',S.uiFps,'FontName',FONT,'FontSize',10,...
    'BackgroundColor',C.surface,'FontColor',C.txt);          % (kept exactly as your old panel)
edUiFps.Layout.Row = 4; edUiFps.Layout.Column = 4;

% ── NEW: add ONLY these two dropdowns in the empty bottom-right slots ──
ddMonL = mkDropdown(mg,{'CH 1'},'CH 1',4,[5 6],FONT,C);
ddMonR = mkDropdown(mg,{'CH 2'},'CH 2',4,[7 8],FONT,C);

%% ════════════════════════════════════════════════════════════════════════
%% PANEL 4 — Recording
%% ════════════════════════════════════════════════════════════════════════
pRec = makePanel(leftGL,'Recording',4,C,FONT);

rg = uigridlayout(pRec,[5 9]);
rg.RowHeight   = {18, 26, 10, 28, 18};
rg.ColumnWidth = {'1x','0.7x','0.7x','0.7x','0.7x','0.7x','0.7x','1x'};
rg.Padding     = [12 8 12 8];
rg.RowSpacing  = 4;
rg.ColumnSpacing = 8;
rg.BackgroundColor = C.surface;

mkLabel(rg,'Mode',        1,1,FONT,C);
mkLabel(rg,'Pre (s)',     1,2,FONT,C);
mkLabel(rg,'Post (s)',    1,3,FONT,C);
mkLabel(rg,'Ring (s)',    1,4,FONT,C);
mkLabel(rg,'Thr (dB)',    1,5,FONT,C);
mkLabel(rg,'Peaks',       1,6,FONT,C);
mkLabel(rg,'Cal (Pa/u)',  1,7,FONT,C);
mkLabel(rg,'File Suffix', 1,8,FONT,C);

ddRecMode  = mkDropdown(rg,{'Tap','Continuous','Auto'},'Tap',2,1,FONT,C);
edPre      = mkNumField(rg,[0 120],   S.preTrigSec,  2,2,FONT,C);
edPost     = mkNumField(rg,[0 600],   S.postTrigSec, 2,3,FONT,C);
edRing     = mkNumField(rg,[1 600],   S.ringMaxSec,  2,4,FONT,C);
edThrDb    = mkNumField(rg,[-120 140], S.autoThrDb,   2,5,FONT,C);
edMinPeaks = mkNumField(rg,[1 999],   S.autoMinPeaks,2,6,FONT,C);
edMinPeaks.RoundFractionalValues = 'on';
edCalib    = mkNumField(rg,[0 1e9],   S.autoCalibPaPerUnit, 2,7,FONT,C); % ALWAYS AVAILABLE
edSuffix   = uieditfield(rg,'text','Value','',...
    'FontName',FONT,'FontSize',10,'BackgroundColor',C.surface,'FontColor',C.txt);
edSuffix.Layout.Row = 2; edSuffix.Layout.Column = 8;

btnFolder = uibutton(rg,'Text','📁  Choose folder',...
    'BackgroundColor',[0.20 0.22 0.26],'FontColor',C.txt,...
    'FontName',FONT,'FontSize',10);
btnFolder.Layout.Row = 4; btnFolder.Layout.Column = [1 4];

btnRecord = uibutton(rg,'Text','⏺  RECORD',...
    'BackgroundColor',C.accentHot,'FontColor',[1 1 1],...
    'FontName',FONT,'FontSize',10,'FontWeight','bold');
btnRecord.Layout.Row = 4; btnRecord.Layout.Column = [5 8];
btnRecord.Enable = 'off';

lblRecState = uilabel(rg,'Text','Recording: off',...
    'FontName',FONT,'FontSize',9,'FontWeight','bold',...
    'FontColor',C.txtDim,'BackgroundColor','none');
lblRecState.Layout.Row = 5; lblRecState.Layout.Column = [5 8];

lblDest = uilabel(rg,'Text',['Dest: ' S.destFolder],...
    'FontName',FONT,'FontSize',9,'FontAngle','italic',...
    'FontColor',C.txtDim,'BackgroundColor','none');
lblDest.Layout.Row = 5; lblDest.Layout.Column = [1 4];

%% ════════════════════════════════════════════════════════════════════════
%% PANEL 5 — Run Control
%% ════════════════════════════════════════════════════════════════════════
pRun=makePanel(leftGL,'Run Control',5,C,FONT);
rng=uigridlayout(pRun,[5 2]);
rng.RowHeight={36,20,18,18,'1x'}; rng.ColumnWidth={'1x','1x'};
rng.Padding=[12 8 12 8]; rng.RowSpacing=6; rng.BackgroundColor=C.surface;
pRun.Scrollable = 'on';
rng.RowSpacing = 4;
rng.ColumnSpacing = 6;
btnStart=uibutton(rng,'Text','▶  START',...
    'BackgroundColor',C.accentGo,'FontColor',[1 1 1],...
    'FontName',FONT,'FontSize',13,'FontWeight','bold');
btnStart.Layout.Row=1; btnStart.Layout.Column=1;

btnStop=uibutton(rng,'Text','■  STOP',...
    'BackgroundColor',[1 1 0.8],'FontColor',C.accentHot,...
    'FontName',FONT,'FontSize',13);
btnStop.Layout.Row=1; btnStop.Layout.Column=2; btnStop.Enable='off';

lblStatus=uilabel(rng,'Text','Status: idle',...
    'FontName',FONT,'FontSize',10,'FontWeight','bold','FontColor',C.accent,...
    'BackgroundColor','none');
lblStatus.Layout.Row=2; lblStatus.Layout.Column=[1 2];

lblDeviceInfo=uilabel(rng,'Text','No device probed yet',...
    'FontName',FONT,'FontSize',9,'FontAngle','italic','FontColor',C.txtDim,...
    'BackgroundColor','none');
lblDeviceInfo.Layout.Row=[3 4]; lblDeviceInfo.Layout.Column=[1 2];
lblDeviceInfo.WordWrap = 'on';

taInfo = uihtml(rng, 'HTMLSource', localBuildLogHtml({}));
taInfo.Layout.Row = 5; taInfo.Layout.Column = [1 2];

%% ════════════════════════════════════════════════════════════════════════
%% PANEL 6 — Resources
%% ════════════════════════════════════════════════════════════════════════
pRes = makePanel(leftGL,'Resources',6,C,FONT);
resGL = uigridlayout(pRes,[1 2]);
resGL.RowHeight    = {20};
resGL.ColumnWidth  = {'1x', '1x'};
resGL.Padding      = [12 8 12 8];
resGL.RowSpacing   = 4;
resGL.ColumnSpacing = 8;
resGL.BackgroundColor = C.surface;

% mkLabel(resGL,'Link', 1, 1, FONT, C);

RES_LINKS = { ...
    'RUBAT Documentation',       'https://rubat.biosonix.io/?utm_source=rubatapp&utm_medium=app&utm_campaign=resources&utm_content=rubat_documentation',
    'Sounds & Senses Lab',        'https://biosonix.io?utm_source=rubatapp&utm_medium=app&utm_campaign=resources&utm_content=sounds_senses_lab'; ...
    'Papers',                   'https://www.biorxiv.org/search/author1%3ARavi%2BUmadi%2B'; ...
    'GitHub Repository',         'https://github.com/raviumadi/RUBAT-Recorder'; ...
    ;};

ddResLinks = mkDropdown(resGL, RES_LINKS(:,1)', RES_LINKS{1,1}, 1, 1, FONT, C);

btnOpenLink = uibutton(resGL, 'Text', '⬡  Open', ...
    'BackgroundColor', [0.18 0.38 0.60], 'FontColor', C.txt, ...
    'FontName', FONT, 'FontSize', 10, 'FontWeight', 'bold');
btnOpenLink.Layout.Row = 1; btnOpenLink.Layout.Column = 2;

%% ─── TOOLTIPS ────────────────────────────────────────────────────────────
addTip(ddIn,       'Select the audio input device (microphone / ADC)');
addTip(ddOut,      'Select the audio output device for monitoring');
addTip(ddFsIn,     'Input sample rate (device-specific list)');
addTip(ddFsOut,    'Output sample rate (device-specific list)');
addTip(ddBitsIn,   'Input bit depth (device-specific list where available)');
addTip(ddBitsOut,  'Output bit depth (device-specific list where available)');
addTip(ddFrame,    'Frame/buffer size in samples — smaller = lower latency');

addTip(btnRefresh, 'Re-enumerate all audio devices and probe each one for confirmed sample rates and bit depths (may take a few seconds)');
addTip(btnTabIn,   'Show input channel checkboxes');
addTip(btnTabOut,  'Show output channel checkboxes');
addTip(btnRefreshCh,'Re-probe current devices and rebuild channel lists');

addTip(ddOutMode,  'Monitoring output: Off / Passthrough / Heterodyne (changes apply instantly)');
addTip(cbMix,      'Mix all monitor channels to both L and R outputs');
addTip(cbVisuals,  'Show/hide live waveform and spectrogram plots (disable to reduce CPU load)');
addTip(slMonGain,  'Software monitor gain (monitor only). Recording remains raw mic level.');
addTip(slCar,      'Heterodyne carrier frequency');

addTip(ddMonL,     'Monitoring left ear input channel (used when Mix is OFF)');
addTip(ddMonR,     'Monitoring right ear input channel (used when Mix is OFF)');

addTip(edSpecMax,  'Spectrogram upper frequency limit (0 = Fs/2)');
addTip(edUiFps,    'Plot refresh rate (UI updates per second). Max useful FPS = Fs ÷ FrameSize (e.g. 192000÷4096 ≈ 46 fps). Setting higher has no extra benefit.');
addTip(ddWave,     'Waveform channel (also used for Auto trigger)');
addTip(ddSpec1,    'Spectrogram A channel');
addTip(ddSpec2,    'Spectrogram B channel');

addTip(ddRecMode,  'Tap = one-shot clip. Continuous = stream until stopped. Auto = threshold-triggered tap.');
addTip(edPre,      'Pre-trigger capture seconds (from ring buffer)');
addTip(edPost,     'Post-trigger capture seconds (tap mode; disabled in Continuous)');
addTip(edRing,     'Ring buffer length in seconds (disabled in Continuous)');
addTip(edSuffix,   'Optional suffix appended to saved filenames');

addTip(edThrDb,    'Auto threshold in dB. If calibrated: dB SPL re 20 µPa; else relative dB.');
addTip(edMinPeaks, 'Number of threshold events within last pre-trigger window required to trigger.');
addTip(edCalib,    'Calibration: Pa per input unit. If >0, waveform shows dB SPL and Auto threshold uses SPL.');

addTip(btnFolder,  'Browse for destination folder');
addTip(btnRecord,  'Tap: capture clip. Continuous: start/stop streaming. Auto: arm/disarm.');
addTip(btnStart,   'Open devices and start capture / monitoring loop (shortcut: s)');
addTip(btnStop,    'Stop capture and release audio devices (shortcut: S)');
addTip(ddResLinks, 'Select a resource link to open in browser');
addTip(btnOpenLink,'Open the selected resource link in the system browser');

%% ─── CALLBACKS ──────────────────────────────────────────────────────────
ddIn.ValueChangedFcn      = @(~,~) onInputDeviceChanged();
ddOut.ValueChangedFcn     = @(~,~) onOutputDeviceChanged();
ddFsIn.ValueChangedFcn    = @(~,~) onInputDeviceChanged();
ddFsOut.ValueChangedFcn   = @(~,~) onOutputDeviceChanged();
ddBitsIn.ValueChangedFcn  = @(~,~) onInputDeviceChanged();
ddBitsOut.ValueChangedFcn = @(~,~) onOutputDeviceChanged();
ddFrame.ValueChangedFcn   = @(~,~) onFrameChanged();

btnRefresh.ButtonPushedFcn   = @onRefreshDevices;
btnRefreshCh.ButtonPushedFcn = @onRefreshChannels;
btnTabIn.ButtonPushedFcn     = @(~,~) switchChTab('in');
btnTabOut.ButtonPushedFcn    = @(~,~) switchChTab('out');
btnFolder.ButtonPushedFcn    = @onChooseFolder;
btnStart.ButtonPushedFcn     = @onStart;
btnStop.ButtonPushedFcn      = @onStopStream;
btnRecord.ButtonPushedFcn    = @onRecordPressed;

ddWave.ValueChangedFcn   = @setChannelSelections;
ddSpec1.ValueChangedFcn  = @setChannelSelections;
ddSpec2.ValueChangedFcn  = @setChannelSelections;

ddOutMode.ValueChangedFcn = @(~,~) setMonitoringParams();
cbMix.ValueChangedFcn     = @(~,~) setMonitoringParams();
slCar.ValueChangedFcn     = @(~,~) setMonitoringParams();
slMonGain.ValueChangedFcn = @(~,~) setMonitoringParams();
ddMonL.ValueChangedFcn    = @(~,~) setMonitoringParams();
ddMonR.ValueChangedFcn    = @(~,~) setMonitoringParams();

edSpecMax.ValueChangedFcn = @setSpecParams;
edUiFps.ValueChangedFcn   = @setVisualParams;
cbVisuals.ValueChangedFcn = @setVisualParams;

ddRecMode.ValueChangedFcn   = @setRecParams;
edPre.ValueChangedFcn       = @setRecParams;
edPost.ValueChangedFcn      = @setRecParams;
edRing.ValueChangedFcn      = @setRecParams;
edSuffix.ValueChangedFcn    = @setRecParams;
edThrDb.ValueChangedFcn     = @setRecParams;
edMinPeaks.ValueChangedFcn  = @setRecParams;
edCalib.ValueChangedFcn     = @setRecParams;

fig.CloseRequestFcn      = @onClose;
btnOpenLink.ButtonPushedFcn = @onOpenLink;

% Init
setRecParams(); setSpecParams(); setVisualParams();
setMonitoringParams();
updateOutputControls(false);   % output optional: disable monitoring controls until a device is chosen
refreshDeviceRegistries();     % populate device dropdowns at launch (no probing)

%% ════════════════════════════════════════════════════════════════════════
%% NESTED FUNCTIONS
%% ════════════════════════════════════════════════════════════════════════

    function onKeyPress(~,evt)
        try
            ch = "";
            try, ch = string(evt.Character); catch, end
            % Fallback: use Key name when Character is empty (modifier-only events)
            if strlength(ch) == 0
                try, ch = string(evt.Key); catch, end
            end
        catch
            return;
        end
        if strlength(ch) == 0, return; end

        % Start: 's'
        if ch=="s"
            if strcmp(btnStart.Enable,'on')
                onStart();
            end
            return;
        end

        % Stop: capital 'S'
        if ch=="S"
            if strcmp(btnStop.Enable,'on')
                onStopStream();
            end
            return;
        end

        % Rec: 't'
        if ch=="t"
            if strcmp(btnRecord.Enable,'on')
                onRecordPressed();
            end
            return;
        end

        % Stop continuous recording: 'x'
        if ch=="x"
            if S.isRunning && S.contRecording
                try
                    toggleContinuousRecord();
                catch
                end
            end
            return;
        end
    end

    function idx = getDevIdx(ddValue)
        tok=regexp(char(ddValue),'^#(\d+):','tokens','once');
        if isempty(tok), idx=1; else, idx=str2double(tok{1}); end
    end
    function id = getInDevID(v)
        i=max(1,min(getDevIdx(v),numel(S.inDevRegistry)));
        id=S.inDevRegistry(i).devid;
    end
    function id = getOutDevID(v)
        i=max(1,min(getDevIdx(v),numel(S.outDevRegistry)));
        id=S.outDevRegistry(i).devid;
    end
    function labels = makeLabels(reg)
        labels=arrayfun(@(i)sprintf('#%d: %s',i,reg(i).label),...
            1:numel(reg),'UniformOutput',false);
    end

    function logInfo(msg)
        ts = char(datetime('now','Format','HH:mm:ss.SSS'));
        S.infoLines{end+1} = sprintf('[%s] %s', ts, msg);
        if numel(S.infoLines) > 400, S.infoLines = S.infoLines(end-399:end); end
        try, taInfo.HTMLSource = localBuildLogHtml(S.infoLines); catch, end
    end

    function onFrameChanged()
        if S.isRunning, return; end
        S.frameLength = max(256, round(str2double(ddFrame.Value)));
        logInfo(sprintf(['Frame size ' char(8594) ' %d samples'], S.frameLength));
        % Do NOT re-probe input or output here.  Frame size does not change
        % the supported channels or sample rates — those depend on the
        % physical device, not the buffer length.  The new frame size is
        % picked up at START (onStart re-reads ddFrame.Value).
        %
        % Re-probing the input via localOpenReader thrashes the PortAudio
        % handle (128→64→..→N open/fail/close cycles), leaving a dirty
        % device state.  When the same physical device is also the output,
        % the subsequent writer open at START then fails with
        % "PortAudio Error: Invalid number of channels" because Core Audio
        % has not fully flushed the stale per-device config from the probe.
    end

%% ── Device registry + dynamic Fs/bit lists ────────────────────────────
    function refreshDeviceRegistries()
        [inReg, outReg] = localEnumerateDevicesStrict();

        % On macOS/Core Audio, MATLAB cannot detect hardware-native sample rates
        % (PortAudio runs in shared mode; Core Audio transparently resamples all
        % streams and reports the requested rate back). The Fs dropdown shows the
        % full PortAudio-working list (44.1 kHz – 384 kHz). Select the rate your
        % interface is clocked at in its own mixer app (RME TotalMix, etc.).
        % Channel count is discovered reliably when a device is selected.
        [fixedFs, fixedBits] = localCapsFromEntry([]);
        for k = 1:numel(inReg)
            inReg(k).confirmedFs   = fixedFs;
            inReg(k).confirmedBits = fixedBits;
        end
        for k = 1:numel(outReg)
            outReg(k).confirmedFs   = fixedFs;
            outReg(k).confirmedBits = fixedBits;
        end

        S.inDevRegistry  = inReg;
        S.outDevRegistry = outReg;

        SELECT_IN = '— Select input —';
        NONE_OUT  = '(none)';
        inL  = [{SELECT_IN}  makeLabels(inReg)];
        outL = [{NONE_OUT}   makeLabels(outReg)];

        curIn  = ddIn.Value;  curOut = ddOut.Value;
        ddIn.Items  = inL;
        ddOut.Items = outL;

        if strcmp(curIn, SELECT_IN) || ~any(strcmp(inL, curIn))
            ddIn.Value = SELECT_IN;
        else
            ddIn.Value = curIn;
        end
        if strcmp(curOut, NONE_OUT) || ~any(strcmp(outL, curOut))
            ddOut.Value = NONE_OUT;
        else
            ddOut.Value = curOut;
        end

        if ~isvalid(fig), return; end

        if ~strcmp(ddIn.Value, SELECT_IN)
            localUpdateDropdownsForSelection('in');
        end
        if ~strcmp(ddOut.Value, NONE_OUT)
            localUpdateDropdownsForSelection('out');
        end

        logInfo(sprintf('Found %d input / %d output device(s).', numel(inReg)-1, numel(outReg)-1));
        logInfo('Note (macOS): Fs list shows all PortAudio-working rates (44.1–384 kHz). Select the rate your interface is clocked at in its device mixer app. Channel count is probed when you select a device.');
        safeStatus('Status: idle');
    end

    function safeStatus(msg)
        if isvalid(fig)
            lblStatus.Text = msg;
            drawnow;
        end
    end

    function localUpdateDropdownsForSelection(which)
        % Cache is always pre-filled by refreshDeviceRegistries (fixed list).
        if strcmpi(which, 'in')
            idx = max(1, min(getDevIdx(ddIn.Value), numel(S.inDevRegistry)));
            reg = S.inDevRegistry(idx);

            S.fsInList   = reg.confirmedFs;
            ddFsIn.Items = reg.confirmedFs;
            if ~any(strcmp(ddFsIn.Items, ddFsIn.Value))
                ddFsIn.Value = ddFsIn.Items{end}; % default to highest
            end

            S.bitsInList   = reg.confirmedBits;
            ddBitsIn.Items = reg.confirmedBits;
            if ~any(strcmp(ddBitsIn.Items, ddBitsIn.Value))
                ddBitsIn.Value = ddBitsIn.Items{end};
            end

        else
            idx = max(1, min(getDevIdx(ddOut.Value), numel(S.outDevRegistry)));
            reg = S.outDevRegistry(idx);

            S.fsOutList   = reg.confirmedFs;
            ddFsOut.Items = reg.confirmedFs;
            if ~any(strcmp(ddFsOut.Items, ddFsOut.Value))
                ddFsOut.Value = ddFsOut.Items{1}; % default to lowest (safe for output)
            end

            S.bitsOutList   = reg.confirmedBits;
            ddBitsOut.Items = reg.confirmedBits;
            if ~any(strcmp(ddBitsOut.Items, ddBitsOut.Value))
                ddBitsOut.Value = ddBitsOut.Items{end};
            end
        end
    end

%% ── Fake-tab ─────────────────────────────────────────────────────────
    function switchChTab(which)
        logInfo(sprintf('Channel tab %s %s', char(8594), upper(which)));
        if strcmp(which,'in')
            inBoxPanel.Visible='on'; outBoxPanel.Visible='off';
            btnTabIn.Text='▶ Input channels';
            btnTabIn.BackgroundColor=C.accent; btnTabIn.FontColor=[0 0 0];
            btnTabOut.Text='Output channels';
            btnTabOut.BackgroundColor=[0.22 0.24 0.28]; btnTabOut.FontColor=C.txtDim;
        else
            inBoxPanel.Visible='off'; outBoxPanel.Visible='on';
            btnTabOut.Text='▶ Output channels';
            btnTabOut.BackgroundColor=C.accent; btnTabOut.FontColor=[0 0 0];
            btnTabIn.Text='Input channels';
            btnTabIn.BackgroundColor=[0.22 0.24 0.28]; btnTabIn.FontColor=C.txtDim;
        end
    end

    function onRefreshChannels(~,~)
        if S.isRunning
            logInfo('Refresh channels blocked while running.');
            return;
        end
        lblStatus.Text = 'Status: refreshing channels…'; drawnow;
        logInfo('--- Refresh channels ---');
        onInputDeviceChanged();
        onOutputDeviceChanged();
    end

    function onRefreshDevices(~,~)
        if S.isRunning
            logInfo('Refresh blocked while running.');
            return;
        end
        lblStatus.Text = 'Status: refreshing devices…'; drawnow;
        logInfo('--- Refresh device list ---');
        delete(inBoxPanel.Children);
        delete(outBoxPanel.Children);
        S.maxInCh=0; S.maxOutCh=0;
        lbChStatus.Text='Refreshing device list…'; drawnow;

        % Force MATLAB to re-enumerate PortAudio devices.
        % audiodevinfo is a MEX that caches the device list; clearing it
        % forces PortAudio Pa_Terminate/Pa_Initialize on the next call,
        % so hot-plugged and unplugged devices are discovered.
        try, clear audiodevinfo; catch, end  %#ok<CLMEX>

        refreshDeviceRegistries();
        logInfo(sprintf('Found: %d input / %d output devices',...
            numel(S.inDevRegistry),numel(S.outDevRegistry)));
        onInputDeviceChanged();
        onOutputDeviceChanged();
    end

%% ── Input probe ──────────────────────────────────────────────────────
    function onInputDeviceChanged(~,~)
        if S.isRunning, return; end
        if strcmp(ddIn.Value,'— Select input —'), return; end   % sentinel — nothing chosen yet

        % Reset channel mask so rebuildCheckboxes treats this as a fresh device
        S.maxInCh = 0;
        S.inChMask = false(1,64);
        delete(inBoxPanel.Children);

        localUpdateDropdownsForSelection('in');

        devID    = getInDevID(ddIn.Value);
        fsReq    = str2double(ddFsIn.Value);
        frameLen = max(256, round(str2double(ddFrame.Value)));

        S.inBitDepthReq = localBitDepthString(ddBitsIn.Value);

        lblStatus.Text=sprintf('Status: probing %s …',ddIn.Value); drawnow;
        logInfo(sprintf('Probing input: %s  Fs=%d Bits=%s Frame=%d',ddIn.Value,fsReq,S.inBitDepthReq,frameLen));

        try
            [tmpR,fsAct,nChAct,usedName,bitAct,att]=localOpenReader(devID,fsReq,frameLen,128,S.inBitDepthReq);
            try, release(tmpR); catch, end
            for k=1:numel(att), logInfo(att{k}); end

            S.fsActual=fsAct;
            S.maxInCh=nChAct;
            S.inBitDepthActual = string(bitAct);

            localEnforceSameDeviceOutputFs();

            newMax=floor(fsAct/2);
            slCar.Limits=[1000 newMax];
            if S.hetCarrierHz>newMax
                S.hetCarrierHz=newMax; slCar.Value=newMax;
                lbCarVal.Text=sprintf('%d Hz',newMax);
            end

            rebuildInCheckboxes(); updateDisplayDropdowns();

            lbChStatus.Text=sprintf('%d input  |  %d output  channels detected',...
                S.maxInCh,S.maxOutCh);

            infoTxt=sprintf('In: %s | "%s" | Fs=%d | Ch=%d | Bits=%s',...
                ddIn.Value,usedName,S.fsActual,S.maxInCh,S.inBitDepthActual);
            lblDeviceInfo.Text=infoTxt; logInfo(infoTxt);
            lblStatus.Text='Status: idle';
        catch ME
            S.maxInCh=0;
            delete(inBoxPanel.Children);
            lbChStatus.Text='Input probe failed — device unavailable';
            msg=sprintf('Input probe FAILED: %s',ME.message);
            lblDeviceInfo.Text=msg; lblStatus.Text='Status: probe failed';
            logInfo(msg);
            logInfo('Tip: if the device was disconnected, press Refresh to re-scan.');
        end
    end

    function localEnforceSameDeviceOutputFs()
        if strcmp(ddOut.Value,'(none)'), return; end  % no output selected
        try
            inName  = resolveInputName(getInDevID(ddIn.Value));
            outName = resolveOutputName(getOutDevID(ddOut.Value));
            if strcmpi(strtrim(inName), strtrim(outName))
                localUpdateDropdownsForSelection('out');
                target = num2str(S.fsActual);
                if any(strcmp(ddFsOut.Items, target))
                    ddFsOut.Value = target;
                    logInfo(sprintf('Same-device lock: forcing output Fs to match input (%s Hz)', target));
                else
                    vals = str2double(ddFsOut.Items);
                    [~,ix] = min(abs(vals - S.fsActual));
                    ddFsOut.Value = ddFsOut.Items{ix};
                    logInfo(sprintf('Same-device lock: output Fs list lacks %d; using nearest %s Hz', S.fsActual, ddFsOut.Value));
                end
            end
        catch
        end
    end

%% ── Output probe ─────────────────────────────────────────────────────
    function onOutputDeviceChanged(~,~)
        if S.isRunning, return; end
        if strcmp(ddOut.Value,'(none)')
            updateOutputControls(false);   % no output device — disable monitoring UI
            S.maxOutCh = 0;
            delete(outBoxPanel.Children);
            lbChStatus.Text=sprintf('%d input  |  no output (monitoring off)',S.maxInCh);
            return;
        end
        updateOutputControls(true);
        localUpdateDropdownsForSelection('out');   % update Fs/bits dropdowns from cache

        % Reset channel mask so rebuildOutCheckboxes treats this as a fresh device
        S.maxOutCh = 0;
        S.outChMask = false(1,64);
        delete(outBoxPanel.Children);

        devID     = getOutDevID(ddOut.Value);
        outFsReq  = str2double(ddFsOut.Value);
        frameLen  = max(256, round(str2double(ddFrame.Value)));

        S.outBitDepthReq = localBitDepthString(ddBitsOut.Value);

        localEnforceSameDeviceOutputFs();
        outFsReq = str2double(ddFsOut.Value);

        lblStatus.Text = sprintf('Status: probing %s …', ddOut.Value); drawnow;
        logInfo(sprintf('Probing output: %s  Fs=%d Bits=%s Frame=%d',ddOut.Value,outFsReq,S.outBitDepthReq,frameLen));

        [ok,usedName,att]=localProbeWriter(devID,outFsReq,S.outBitDepthReq,frameLen);
        for k=1:numel(att), logInfo(att{k}); end

        if ~ok
            S.maxOutCh=0; delete(outBoxPanel.Children);
            lbChStatus.Text=sprintf('%d input  |  output probe failed',S.maxInCh);
            lblStatus.Text = 'Status: output probe failed';
            logInfo(sprintf('Output probe FAILED for "%s"',ddOut.Value));
            existing=regexprep(lblDeviceInfo.Text,'\s*\|\s*Out:.*$','');
            lblDeviceInfo.Text=sprintf('%s | Out: unavailable',existing);
            return;
        end

        S.maxOutCh = localProbeOutputChannels(devID, resolveOutputName(devID), outFsReq);
        logInfo(sprintf('Output channel probe: %d channels found', S.maxOutCh));

        rebuildOutCheckboxes();

        lbChStatus.Text=sprintf('%d input  |  %d output  channels detected',...
            S.maxInCh,S.maxOutCh);
        logInfo(sprintf('Out: %s | "%s"',ddOut.Value,usedName));

        existing=regexprep(lblDeviceInfo.Text,'\s*\|\s*Out:.*$','');
        lblDeviceInfo.Text=sprintf('%s | Out: %s',existing,usedName);
        lblStatus.Text = 'Status: idle';
    end

%% ── Channel grids ────────────────────────────────────────────────────
    function rebuildInCheckboxes()
        MAXCH = 64;
        oldMask = S.inChMask;
        freshProbe = ~any(oldMask);   % all false means first-time probe for this device
        newMask = false(1, MAXCH);

        if freshProbe && S.maxInCh >= 1
            % Default: first 2 channels (or 1 if mono device)
            newMask(1) = true;
            if S.maxInCh >= 2, newMask(2) = true; end
        else
            n = min(numel(oldMask), S.maxInCh);
            if n > 0, newMask(1:n) = oldMask(1:n); end
            if S.maxInCh < MAXCH, newMask(S.maxInCh+1:end) = false; end
        end

        S.inChMask = newMask;
        buildCheckboxGrid(inBoxPanel, S.maxInCh, S.inChMask, @onInChChanged);
        updateInChIndices();
    end

    function rebuildOutCheckboxes()
        MAXCH = 64;
        oldMask = S.outChMask;
        freshProbe = ~any(oldMask);   % all false means first-time probe for this device
        newMask = false(1, MAXCH);

        if freshProbe && S.maxOutCh >= 1
            newMask(1) = true;
            if S.maxOutCh >= 2, newMask(2) = true; end
        else
            n = min(numel(oldMask), S.maxOutCh);
            if n > 0, newMask(1:n) = oldMask(1:n); end
            if S.maxOutCh < MAXCH, newMask(S.maxOutCh+1:end) = false; end
        end

        S.outChMask = newMask;
        buildCheckboxGrid(outBoxPanel, S.maxOutCh, S.outChMask, @onOutChChanged);
        updateOutChIndices();
    end

    function buildCheckboxGrid(parentPanel,nCh,mask,cbFcn)
        delete(parentPanel.Children);

        MAXCH = 64;          % always show 1..64
        nCols = 16;
        nRows = ceil(MAXCH/nCols);

        if isempty(mask), mask = false(1,MAXCH); end
        if numel(mask) < MAXCH, mask(end+1:MAXCH) = false; end
        mask = logical(mask(1:MAXCH));

        g = uigridlayout(parentPanel,[nRows,nCols]);
        g.RowHeight    = repmat({18},1,nRows);
        g.ColumnWidth  = repmat({'1x'},1,nCols);
        g.Padding      = [4 4 4 4];
        g.RowSpacing   = 2;
        g.ColumnSpacing= 4;
        g.BackgroundColor = C.surface;

        for k = 1:MAXCH
            rr = ceil(k/nCols);
            cc = mod(k-1,nCols) + 1;

            isAvail = (k <= nCh);

            cb = uicheckbox(g, ...
                'Text', sprintf('%d',k), ...
                'Value', isAvail && mask(k), ...
                'Tag', sprintf('ch%d',k), ...
                'FontName', FONT, ...
                'FontSize', 8);

            cb.Layout.Row = rr;
            cb.Layout.Column = cc;

            if isAvail
                cb.Enable    = 'on';
                cb.FontColor = C.txt;
                cb.ValueChangedFcn = @(src,~) cbFcn(k,src.Value);
                cb.Tooltip = sprintf('Channel %d (available)', k);
            else
                cb.Enable    = 'off';
                cb.FontColor = C.txtDim;
                cb.Value     = false;
                cb.Tooltip = sprintf('Channel %d (not available on this device)', k);
            end
        end

        drawnow;
    end

    function onInChChanged(k,val)
        if k>=1&&k<=numel(S.inChMask), S.inChMask(k)=logical(val); end
        updateInChIndices(); updateDisplayDropdowns();
        logInfo(sprintf('Input CH %d → %s',k,onoffStr(val)));
    end

    function onOutChChanged(k,val)
        if k>=1&&k<=numel(S.outChMask), S.outChMask(k)=logical(val); end
        updateOutChIndices();
        setMonitoringParams(); % real-time gating update
        logInfo(sprintf('Output CH %d → %s',k,onoffStr(val)));
    end

    function updateInChIndices()
        idx=find(S.inChMask);
        if isempty(idx), S.inChMask(1)=true; idx=1; retickFirst(inBoxPanel); end
        S.inChIdx=idx(:)';
    end

    function updateOutChIndices()
        idx=find(S.outChMask);
        if isempty(idx), S.outChMask(1)=true; idx=1; retickFirst(outBoxPanel); end
        S.outChIdx=idx(:)';
        setMonitoringParams(); % real-time gating update
    end

    function retickFirst(pp)
        try
            g=pp.Children(1); kids=g.Children;
            for i=1:numel(kids)
                if isa(kids(i),'matlab.ui.control.CheckBox')&&strcmp(kids(i).Tag,'ch1')
                    kids(i).Value=true;
                end
            end
        catch, end
    end
    function s=onoffStr(v), if v, s='ON'; else, s='OFF'; end, end %#ok<INUSD>

%% ── Display dropdowns ────────────────────────────────────────────────
    function updateDisplayDropdowns()
        if isempty(S.inChIdx)
            items={'—'}; fallback='—';
        else
            items=arrayfun(@(c)sprintf('CH %d',c),S.inChIdx,'UniformOutput',false);
            fallback=items{1};
        end

        % Determine whether this is a fresh device probe (all display
        % dropdowns still show the sentinel '—' or the previous selection
        % no longer exists in the new item list).
        freshProbe = strcmp(ddWave.Value,'—') || ~any(strcmp(items, ddWave.Value));

        prevW=ddWave.Value; prevA=ddSpec1.Value; prevB=ddSpec2.Value;
        ddWave.Items=items; ddSpec1.Items=items; ddSpec2.Items=items;

        if freshProbe && numel(items) >= 2
            % Default wave=CH1, specA=CH1, specB=CH2
            ddWave.Value  = items{1};
            ddSpec1.Value = items{1};
            ddSpec2.Value = items{2};
        else
            ddWave.Value =pickItem(items,prevW,fallback);
            ddSpec1.Value=pickItem(items,prevA,fallback);
            ddSpec2.Value=pickItem(items,prevB,fallback);
        end

        % Monitoring L/R dropdowns follow the same set
        try
            prevL = ddMonL.Value; prevR = ddMonR.Value;
            ddMonL.Items = items; ddMonR.Items = items;

            if freshProbe && numel(items) >= 2
                ddMonL.Value = items{1};
                ddMonR.Value = items{2};
            else
                defL = fallback;
                defR = fallback;
                if numel(items) >= 2, defR = items{2}; end
                ddMonL.Value = pickItem(items,prevL,defL);
                ddMonR.Value = pickItem(items,prevR,defR);
            end
        catch
        end

        setChannelSelections();
        setMonitoringParams();
    end

    function v=pickItem(items,prev,fallback)
        if any(strcmp(items,prev)), v=prev; else, v=fallback; end
    end

    function setChannelSelections(~,~)
        S.waveChan =parseChLabel(ddWave.Value);
        S.specChan1=parseChLabel(ddSpec1.Value);
        S.specChan2=parseChLabel(ddSpec2.Value);
        logInfo(sprintf('Display channels: wave=CH%d specA=CH%d specB=CH%d', ...
            S.waveChan, S.specChan1, S.specChan2));
    end

    function ch=parseChLabel(s)
        tok=regexp(char(s),'(\d+)','tokens','once');
        if isempty(tok), ch=1; else, ch=str2double(tok{1}); end
    end

%% ── Param setters ────────────────────────────────────────────────────
    function setRecParams(~,~)
        newMode = string(ddRecMode.Value);

        % Auto-stop Continuous recording if a different mode is chosen
        if S.isRunning && S.contRecording && newMode ~= "Continuous"
            try, toggleContinuousRecord(); catch, end
            logInfo('Continuous recording stopped: rec mode changed.');
        end

        % Auto-disarm Auto if a different mode is chosen
        if S.isRunning && S.autoEnabled && newMode ~= "Auto"
            S.autoEnabled = false;
            lblRecState.Text = 'REC: off (auto disarmed — mode changed)';
            logInfo('AUTO disarmed: rec mode changed.');
        end

        S.recMode    = newMode;
        S.preTrigSec =edPre.Value;
        S.postTrigSec=edPost.Value;
        S.ringMaxSec =max(edRing.Value,S.preTrigSec+0.5);
        edRing.Value =S.ringMaxSec;
        S.suffix     =string(edSuffix.Value);

        % Calibration ALWAYS available (used for waveform + auto)
        S.autoCalibPaPerUnit = edCalib.Value;

        % Auto params
        S.autoThrDb   = edThrDb.Value;
        S.autoMinPeaks= max(1, round(edMinPeaks.Value));

        logInfo(sprintf('Rec params: mode=%s pre=%.2f post=%.2f ring=%.1f suffix="%s" cal=%.4g thr=%.1f peaks=%d', ...
            S.recMode, S.preTrigSec, S.postTrigSec, S.ringMaxSec, ...
            S.suffix, S.autoCalibPaPerUnit, S.autoThrDb, S.autoMinPeaks));

        updateAutoControlsEnable();
        updateRecButton();
        localWavePushToPlot(waveLine, axWave);
    end

    function updateAutoControlsEnable()
        isAuto = (string(ddRecMode.Value)=="Auto");
        isCont = (string(ddRecMode.Value)=="Continuous");

        % Calibration always available
        edCalib.Enable = 'on';

        % Auto-only fields
        edThrDb.Enable    = onoffToEnable(isAuto);
        edMinPeaks.Enable = onoffToEnable(isAuto);

        % Continuous mode: grey out Post and Ring
        edPost.Enable = onoffToEnable(~isCont);
        edRing.Enable = onoffToEnable(~isCont);
    end

    function e = onoffToEnable(tf)
        if tf, e='on'; else, e='off'; end
    end

    function updateRecButton()
        % - Disabled before START
        % - In Auto mode: acts as ARM/DISARM
        if ~S.isRunning
            btnRecord.Enable = 'off';
            btnRecord.Text   = '⏺  RECORD';
            btnRecord.BackgroundColor = C.disabled;
            ddRecMode.Enable = 'on';   % always editable when not running
            return;
        end

        btnRecord.Enable='on';

        if S.recMode=="Tap"
            btnRecord.Text='⏺  REC. TAP';
            btnRecord.BackgroundColor=C.accentHot;

        elseif S.recMode=="Continuous"
            if S.contRecording
                btnRecord.Text='⏹  STOP REC.';
                btnRecord.BackgroundColor=[0.55 0.15 0.65];
            else
                btnRecord.Text='⏺  REC. Continuous';
                btnRecord.BackgroundColor=C.accentHot;
            end

        else % Auto
            if S.autoEnabled
                btnRecord.Text='⏹  DISARM Auto';
                btnRecord.BackgroundColor=[0.55 0.15 0.65];
            else
                btnRecord.Text='⏺  ARM Auto';
                btnRecord.BackgroundColor=C.accentHot;
            end
        end

        % Grey out rec-mode dropdown while an exclusive mode is active
        % (avoids mid-stream conflicts between Continuous / Auto)
        if S.contRecording || S.autoEnabled
            ddRecMode.Enable = 'off';
        else
            ddRecMode.Enable = 'on';
        end
    end

    function setSpecParams(~,~)
        v=edSpecMax.Value;
        if isempty(v)||v<=0, S.specMaxHz=[]; else, S.specMaxHz=v; end
        if isempty(S.specMaxHz)
            logInfo(sprintf('Spec max freq %s auto (Nyquist)', char(8594)));
        else
            logInfo(sprintf('Spec max freq %s %d Hz', char(8594), S.specMaxHz));
        end
    end

    function setVisualParams(~,~)
        S.uiFps = max(1, round(edUiFps.Value));
        try, S.showVisuals = cbVisuals.Value; catch, end
        logInfo(sprintf('Visuals %s %s  FPS=%d', char(8594), ...
            tern(S.showVisuals, 'ON', 'OFF'), S.uiFps));
        % Cap FPS to the audio frame rate — higher values offer no benefit
        if S.isRunning && S.frameDur > 0
            maxFps = floor(1 / S.frameDur);
            if S.uiFps > maxFps
                S.uiFps = maxFps;
                try, edUiFps.Value = maxFps; catch, end
                logInfo(sprintf('UI FPS capped to %d (audio frame rate limit).', maxFps));
            end
        end
    end

    function setMonitoringParams(~,~)
        S.outMode     = string(ddOutMode.Value);
        S.mixToBoth   = cbMix.Value;
        S.monitorGain = slMonGain.Value;

        S.hetCarrierHz = round(slCar.Value);
        lbCarVal.Text  = sprintf('%d Hz', S.hetCarrierHz);

        % NEW: monitor L/R channel selections (input channels)
        try
            S.monLeftChan  = parseChLabel(ddMonL.Value);
            S.monRightChan = parseChLabel(ddMonR.Value);
        catch
        end

        if S.outMode=="Heterodyne"
            slCar.Enable='on';
            cbMix.Enable='on';
            slMonGain.Enable='on';
        elseif S.outMode=="Passthrough"
            slCar.Enable='off';
            cbMix.Enable='on'; % still meaningful in passthrough (mixing)
            slMonGain.Enable='on';
        else
            slCar.Enable='off';
            cbMix.Enable='off';
            slMonGain.Enable='off';
        end

        logInfo(sprintf('Monitoring → mode=%s mix=%s gain=%.2f carrier=%d monL=%d monR=%d outSel=[%s]',...
            S.outMode, onoffStr(S.mixToBoth), S.monitorGain, S.hetCarrierHz, ...
            S.monLeftChan, S.monRightChan, localIdxToStr(S.outChIdx)));

        applyWriterState();   % open/close writer if mode changed during run
    end

    function applyWriterState()
        % Open or release the audio writer if output mode changes mid-run.
        % Does nothing when not running or when output device is (none).
        if ~S.isRunning || strcmp(ddOut.Value,'(none)'), return; end

        % For same-device setups the writer was opened at START alongside the
        % reader with matching frame sizes.  PortAudio does not allow opening
        % or releasing the output stream independently mid-run on the same
        % physical device, so we leave the handle alone.  The captureLoop
        % switch statement handles routing (Off = no writes).
        if S.sameDeviceRun, return; end

        needWriter = (S.outMode ~= "Off");
        hasWriter  = ~isempty(S.writer);
        if needWriter && ~hasWriter
            % Do not retry after a failure — repeated failed opens thrash
            % PortAudio's internal state and can corrupt the device for
            % the remainder of the session until a device-list refresh.
            if S.writerFailedThisRun
                return;
            end
            try
                [S.writer, ~, ~, nChMid, att, ~] = localOpenWriterRobust(S.outRunID, ...
                    S.outFsActual, S.outFrameSize, S.sameDeviceRun, S.outBitDepthReq, S.outNumChannels);
                if nChMid ~= S.outNumChannels
                    logInfo(sprintf('Output channels reduced mid-run: requested %d, got %d', S.outNumChannels, nChMid));
                    S.outNumChannels = nChMid;
                    S.outBuffer = zeros(0, max(2, double(S.outNumChannels)));
                end
                for k = 1:numel(att), logInfo(att{k}); end
                logInfo(sprintf('Writer opened mid-run: mode=%s', S.outMode));
            catch ME
                S.writerFailedThisRun = true;   % block further attempts this run
                logInfo(sprintf('Writer open FAILED mid-run: %s  (stop & restart to retry)', ME.message));
            end
        elseif ~needWriter && hasWriter
            try, release(S.writer); catch, end
            S.writer = [];
            S.outBuffer = zeros(0, max(2, double(S.outNumChannels)));
            S.writerFailedThisRun = false;   % releasing clears the fault flag
            logInfo('Writer released mid-run (mode → Off).');
        end
    end

    function onChooseFolder(~,~)
        p=uigetdir(S.destFolder,'Choose destination folder');
        if isequal(p,0), return; end
        S.destFolder=p; lblDest.Text=['Dest: ' S.destFolder];
        logInfo(sprintf('Destination: %s',S.destFolder));
    end

%% ── START / STOP ─────────────────────────────────────────────────────
    function setDevicePanelEnabled(tf)
        % Disable complete device selection panel after START
        try
            kids = allchild(pDev);
            set(kids,'Enable', tern(tf,'on','off'));
            if ~tf
                pDev.BackgroundColor = C.disabled;
            else
                pDev.BackgroundColor = C.surface;
            end
        catch
        end
    end

    function updateOutputControls(tf)
        % Enable or disable monitoring controls that require an output device
        enStr = tern(tf,'on','off');
        try, ddOutMode.Enable  = enStr; catch, end
        try, slMonGain.Enable  = enStr; catch, end
        try, btnTabOut.Enable  = enStr; catch, end
        if ~tf
            % Force output off so captureLoop does not try to write
            try, ddOutMode.Value = 'Off'; catch, end
        end
        % Let setMonitoringParams govern cbMix / slCar based on current mode
        setMonitoringParams();
    end

    function s = tern(tf,a,b)
        if tf, s=a; else, s=b; end
    end

    function onStart(~,~)
        if S.isRunning, return; end

        btnStart.Enable='off'; btnStop.Enable='on';
        lblStatus.Text='Status: opening devices…'; drawnow;

        % Refresh params
        S.fsRequested = str2double(ddFsIn.Value);
        S.frameLength = max(256, round(str2double(ddFrame.Value)));
        S.outFsReq    = str2double(ddFsOut.Value);

        S.inBitDepthReq  = localBitDepthString(ddBitsIn.Value);
        S.outBitDepthReq = localBitDepthString(ddBitsOut.Value);

        inID  = getInDevID(ddIn.Value);
        outID = getOutDevID(ddOut.Value);

        logInfo('--- START ---');

        inName     = resolveInputName(inID);
        noOutput   = strcmp(ddOut.Value,'(none)');   % optional output
        if noOutput
            outName    = '(none)';
            sameDevice = false;
        else
            outName    = resolveOutputName(outID);
            sameDevice = strcmpi(strtrim(inName), strtrim(outName));
        end

        % Save for mid-run writer lifecycle management
        S.outRunID            = outID;
        S.sameDeviceRun       = sameDevice;
        S.writerFailedThisRun = false;   % reset on each new START

        if sameDevice
            localEnforceSameDeviceOutputFs();
            S.outFsReq = str2double(ddFsOut.Value);
        end

        S.reader    = [];
        S.writer    = [];
        S.useDuplex = false;

        % Open reader — use the already-known channel count so the reader
        % opens on the first try.  Passing 128 forces localOpenReader to
        % attempt 128→64→…→12, each failed open/close cycle leaving stale
        % PortAudio state that then prevents the writer from opening on
        % the same physical device ("Invalid number of channels").
        nChStart = S.maxInCh;
        if nChStart < 1, nChStart = 128; end   % safety: never probed → full scan
        try
            [S.reader, S.fsActual, S.maxInCh, usedInName, bitAct, att] = ...
                localOpenReader(inID, S.fsRequested, S.frameLength, nChStart, S.inBitDepthReq);
            S.inBitDepthActual = string(bitAct);
            for k=1:numel(att), logInfo(att{k}); end
        catch ME
            logInfo(sprintf('INPUT FAIL: %s', ME.message));
            uialert(fig, ME.message, 'Audio input failed');
            btnStart.Enable='on'; btnStop.Enable='off';
            lblStatus.Text='Status: idle';
            return;
        end

        % Sync the input dropdown to show the device actually opened.
        % This matters when the user never changed the dropdown (still shows
        % '— Select input —') or when the toolbox fell back to a different device.
        try
            matchLbl = '';
            for ri = 1:numel(S.inDevRegistry)
                if strcmpi(S.inDevRegistry(ri).tbName, usedInName) || ...
                   strcmpi(S.inDevRegistry(ri).label, usedInName)
                    matchLbl = sprintf('#%d: %s', ri, S.inDevRegistry(ri).label);
                    break;
                end
            end
            if isempty(matchLbl)
                matchLbl = usedInName;   % fallback: use raw name
            end
            if ~any(strcmp(ddIn.Items, matchLbl))
                ddIn.Items{end+1} = matchLbl;
            end
            if ~strcmp(ddIn.Value, matchLbl)
                ddIn.ValueChangedFcn = [];                          % suppress re-probe
                ddIn.Value           = matchLbl;
                ddIn.ValueChangedFcn = @(~,~) onInputDeviceChanged();
            end
        catch
        end

        S.outFsActual = S.outFsReq;

        [S.useResample, S.rsP, S.rsQ] = localSetupResampler(S.fsActual, S.outFsActual);
        if S.fsActual == S.outFsActual
            logInfo('Resampling: not needed (input Fs == output Fs).');
        elseif S.useResample
            logInfo(sprintf('Resampling enabled: %d → %d Hz (p/q=%d/%d)', S.fsActual, S.outFsActual, S.rsP, S.rsQ));
        else
            logInfo('Resampling unavailable. Using integer decimation fallback (may sound rough).');
        end

        S.outFrameSize = max(128, round(S.frameLength * (S.outFsActual / S.fsActual)));

        % Open writer robustly.
        % Same-device (Babyface-style): reader and writer MUST be opened together
        % because PortAudio commits a single shared buffer size for the physical
        % device.  Opening the writer mid-run after a frame-size change causes
        % "Internal PortAudio error" because the cached frame expectation does
        % not match.  Solution: always open at START for same-device; when mode
        % is Off the captureLoop writes silence every frame to keep the driver
        % clock ticking (starving the output buffer blocks the reader too).
        % Separate-device: writer is opened lazily mid-run by applyWriterState,
        % so we skip here when mode=Off.
        usedOutName = '(none)'; bitOutAct = '';
        % outNumChannels: full device width so one-to-one routing works
        S.outNumChannels = max(2, S.maxOutCh);

        openWriterNow = ~strcmp(ddOut.Value,'(none)') && (sameDevice || S.outMode ~= "Off");
        if openWriterNow
            % Same device: let Core Audio fully settle after the reader
            % open before touching the output side of the same interface.
            if sameDevice, pause(0.20); end
            try
                [S.writer, usedOutName, bitOutAct, nChOut, att, fallbackUsed] = ...
                    localOpenWriterRobust(outID, S.outFsActual, S.outFrameSize, sameDevice, S.outBitDepthReq, S.outNumChannels);
                S.outBitDepthActual = string(bitOutAct);
                if nChOut ~= S.outNumChannels
                    logInfo(sprintf('Output channels reduced: requested %d, got %d', S.outNumChannels, nChOut));
                    S.outNumChannels = nChOut;
                end
                for k=1:numel(att), logInfo(att{k}); end

                if fallbackUsed
                    % Match usedOutName against the registry to get the
                    % correct dropdown label, then update the UI silently.
                    try
                        matchLbl = '';
                        for ri = 1:numel(S.outDevRegistry)
                            if strcmpi(S.outDevRegistry(ri).tbName, usedOutName) || ...
                               strcmpi(S.outDevRegistry(ri).label, usedOutName)
                                matchLbl = sprintf('#%d: %s', ri, S.outDevRegistry(ri).label);
                                break;
                            end
                        end
                        if isempty(matchLbl), matchLbl = usedOutName; end
                        if ~any(strcmp(ddOut.Items, matchLbl))
                            ddOut.Items{end+1} = matchLbl;
                        end
                        if ~strcmp(ddOut.Value, matchLbl)
                            ddOut.ValueChangedFcn = [];
                            ddOut.Value           = matchLbl;
                            ddOut.ValueChangedFcn = @(~,~) onOutputDeviceChanged();
                        end
                        localUpdateDropdownsForSelection('out');
                    catch
                    end
                    logInfo(sprintf('WARNING: Output device fell back to "%s" (Default). UI updated.', usedOutName));
                end
            catch ME
                logInfo(sprintf('OUTPUT FAIL: %s', ME.message));
                uialert(fig, ME.message, 'Audio output failed');
                try, release(S.reader); catch, end
                btnStart.Enable='on'; btnStop.Enable='off';
                lblStatus.Text='Status: idle';
                return;
            end
        else
            S.writer = [];   % no output OR (separate-device + mode=Off)
            S.outBitDepthActual = '';
            if strcmp(ddOut.Value,'(none)')
                logInfo('Output device: none — monitoring disabled for this run.');
            else
                logInfo('Output mode is Off — writer deferred (separate-device; will open mid-run if mode changes).');
            end
        end

        S.outBuffer = zeros(0, S.outNumChannels);

        logInfo(sprintf('Streams opened: In="%s" Fs=%d Ch=%d Bits=%s | Out="%s" Fs=%d Bits=%s', ...
            usedInName, S.fsActual, S.maxInCh, S.inBitDepthActual, usedOutName, S.outFsActual, S.outBitDepthActual));

        S.frameDur = S.frameLength / S.fsActual;

        % Create default destination folder if missing
        try
            if ~isfolder(S.destFolder), mkdir(S.destFolder); end
        catch
        end
        lblDest.Text = ['Dest: ' S.destFolder];

        % Initialise ring buffer
        ringSamples = max(1, round(S.ringMaxSec * S.fsActual));
        S.ring = zeros(ringSamples, max(1,double(S.maxInCh)), 'single');
        S.ringWriteIdx = 1; S.ringFilled = 0;

        % Waveform display buffer (dBFS or SPL)
        S.waveDecim  = max(1, round(S.fsActual / S.wavePlotFs));
        S.wavePlotFs = round(S.fsActual / S.waveDecim);
        waveN = max(200, round(S.waveDispSec * S.wavePlotFs));
        S.waveBufDb = -120 * ones(waveN,1,'single');
        S.waveIdx   = 1;

        % Set waveform XData and axes limits ONCE — never touched again per-tick
        waveX = (0:waveN-1)' / S.wavePlotFs;
        waveLine.XData = waveX;
        waveLine.YData = S.waveBufDb;
        S.lastCalibActive = (S.autoCalibPaPerUnit > 0);
        axWave.XLim = [0 S.waveDispSec];
        if S.lastCalibActive
            axWave.YLim = [0 140];
            axWave.YLabel.String = 'SPL (dB re 20 \muPa)';
            axWave.Title.String  = 'Waveform (SPL)';
        else
            axWave.YLim = [-120 0];
            axWave.YLabel.String = 'Level (dBFS)';
            axWave.Title.String  = 'Waveform (dBFS)';
        end

        % Spectrogram buffers — adapt window to frame size
        S.specWin  = min(1024, S.frameLength);           % window ≤ frame
        S.specNFFT = max(256, 2^nextpow2(S.specWin * 2)); % zero-pad for freq resolution
        S.specOLap = 0;
        S.specHop    = max(1, S.specWin - S.specOLap);
        S.specWinVec = hann(S.specWin,'periodic');
        S.specCols   = max(10, floor(S.specDispSec * S.fsActual / S.specHop));
        nFreq = floor(S.specNFFT/2) + 1;
        S.specFreq = (0:nFreq-1)' * (S.fsActual / S.specNFFT / 1000);  % kHz
        S.specBuf1 = -120 * ones(nFreq, S.specCols, 'single');
        S.specBuf2 = -120 * ones(nFreq, S.specCols, 'single');
        S.specColIdx1 = 1; S.specColIdx2 = 1;

        tAxis = (0:S.specCols-1) * (S.specHop / S.fsActual);
        try
            img1.XData = tAxis; img1.YData = S.specFreq; img1.CData = S.specBuf1;
            img2.XData = tAxis; img2.YData = S.specFreq; img2.CData = S.specBuf2;
        catch
        end

        axWave.XLim = [0 S.waveDispSec];     % already set above, guard for resize

        axSpec1.XLim = [0 S.specDispSec]; axSpec2.XLim = [0 S.specDispSec];
        yTop = S.fsActual/2/1000;  % kHz
        if ~isempty(S.specMaxHz), yTop = min(yTop, S.specMaxHz/1000); end
        axSpec1.YLim = [0 yTop]; axSpec2.YLim = [0 yTop];
        S.lastSpecYTop = yTop;

        % Auto state reset
        S.sampleCounter = int64(0);
        S.autoEventSamples = zeros(0,1,'int64');
        S.autoCooldownSamp = int64(0);

        S.dropEvents = 0; S.lastDt = 0; S.lastUiTic = tic; S.isRunning = true;

        rebuildInCheckboxes();
        rebuildOutCheckboxes();
        updateDisplayDropdowns();

        % Disable device + refresh/probe controls while running
        % (channel tab-switch buttons remain enabled so user can see/change channel
        %  selections in real time without needing to stop)
        setDevicePanelEnabled(false);
        btnRefresh.Enable   = 'off';
        btnRefreshCh.Enable = 'off';

        updateRecButton();

        lblStatus.Text = sprintf('RUNNING | Fs=%d', S.fsActual);
        logInfo('Capture loop started');

        captureLoop();

        btnStart.Enable='on';
        btnStop.Enable='off';

        % Re-enable after stop
        setDevicePanelEnabled(true);
        btnRefresh.Enable   = 'on';
        btnRefreshCh.Enable = 'on';

        updateRecButton();
    end

    function onStopStream(~,~)
        logInfo('--- STOP ---');
        S.isRunning=false;
    end

%% ── Recording button behaviour ───────────────────────────────────────
    function onRecordPressed(~,~)
        if ~S.isRunning
            uialert(fig,'Start the stream first.','Not running');
            return;
        end

        setRecParams();

        if S.recMode=="Tap"
            doTapRecord();
        elseif S.recMode=="Continuous"
            toggleContinuousRecord();
        else % Auto
            S.autoEnabled = ~S.autoEnabled;
            if S.autoEnabled
                lblRecState.Text = sprintf('REC: AUTO ARMED (thr=%.1f dB, peaks=%d)', S.autoThrDb, S.autoMinPeaks);
                logInfo(sprintf('AUTO armed: thr=%.1f dB peaks=%d cal=%.3g Pa/unit', S.autoThrDb, S.autoMinPeaks, S.autoCalibPaPerUnit));
            else
                lblRecState.Text = 'REC: off (auto disarmed)';
                logInfo('AUTO disarmed');
            end
            updateRecButton();
        end
    end

    function doTapRecord()
        preSamp  = round(S.preTrigSec * S.fsActual);
        postSamp = round(S.postTrigSec * S.fsActual);

        preAll = localGetLastFromRing(preSamp);
        if isempty(preAll)
            uialert(fig,'Ring buffer empty.','Tap');
            return;
        end

        S.tapData = preAll(:,S.inChIdx);
        S.tapCapturing = true;
        S.tapNeeded = postSamp;

        lblRecState.Text = 'Recording: TAP — capturing…';
        logInfo(sprintf('TAP triggered: pre=%.2fs post=%.2fs ch=[%s] (RAW)', ...
            S.preTrigSec, S.postTrigSec, localIdxToStr(S.inChIdx)));
        drawnow;
    end

    function toggleContinuousRecord()
        if ~S.contRecording
            preAll = localGetLastFromRing(round(S.preTrigSec*S.fsActual));
            if isempty(preAll)
                uialert(fig,'Ring buffer empty.','Continuous');
                return;
            end

            ts  = datetime('now','Format','yyyyMMdd_HHmmss_SSS');
            suf = strtrim(string(S.suffix));
            if strlength(suf)>0
                fname = sprintf('%s_%s.wav',char(ts),char(suf));
            else
                fname = sprintf('%s.wav',char(ts));
            end
            fp = fullfile(S.destFolder,fname);

            try
                [bps, isFlt] = localBitDepthFromStr(S.inBitDepthActual);
                S.wavW = localWavStreamOpen(fp, S.fsActual, numel(S.inChIdx), bps, isFlt);
                S.wavW = localWavStreamWrite(S.wavW, preAll(:,S.inChIdx));
                S.contFileName = fp;
                S.contRecording = true;
            catch ME
                S.contRecording = false;
                S.wavW = [];
                uialert(fig,ME.message,'Continuous failed');
                return;
            end

            lblRecState.Text = sprintf('REC: CONT ON — %s',fname);
            logInfo(sprintf('CONT started: %s ch=[%s] (RAW)',fname,localIdxToStr(S.inChIdx)));
        else
            try, localWavStreamClose(S.wavW); catch, end
            S.wavW = [];
            S.contRecording = false;

            [~,bn,ex] = fileparts(S.contFileName);
            lblRecState.Text = sprintf('REC: off (saved %s%s)',bn,ex);
            logInfo(sprintf('CONT stopped: %s%s',bn,ex));
        end

        updateRecButton();
        drawnow;
    end

%% ── Main capture loop ────────────────────────────────────────────────
    function captureLoop()
        lastTic = tic;
        while S.isRunning && isvalid(fig)
            try
                x = S.reader();
            catch
                x = [];
            end

            if isempty(x)
                drawnow limitrate;
                continue;
            end

            dt = toc(lastTic);
            lastTic = tic;
            S.lastDt = dt;

            if dt > 2.5*S.frameDur
                S.dropEvents = S.dropEvents + 1;
            end

            S.sampleCounter = S.sampleCounter + int64(size(x,1));

            localRingWrite(x);

            chW = min(max(1,S.waveChan),  size(x,2));
            chA = min(max(1,S.specChan1),size(x,2));
            chB = min(max(1,S.specChan2),size(x,2));

            localWaveUpdateFromChunk(x(:,chW));
            localSpecUpdateFromChunk(x(:,chA),1);
            localSpecUpdateFromChunk(x(:,chB),2);

            if S.autoEnabled && S.recMode=="Auto"
                localAutoDetectFromChunk(x(:,chW));
            end

            if S.tapCapturing && S.tapNeeded>0
                take = min(size(x,1), S.tapNeeded);
                S.tapData = [S.tapData; x(1:take, S.inChIdx)]; %#ok<AGROW>
                S.tapNeeded = S.tapNeeded - take;

                if S.tapNeeded<=0
                    S.tapCapturing = false;
                    localWriteWav(S.tapData);
                    S.tapData = [];
                    lblRecState.Text = 'REC: off (tap saved)';
                    logInfo('TAP saved (RAW)');
                end
            end

            if S.contRecording && ~isempty(S.wavW)
                try
                    S.wavW = localWavStreamWrite(S.wavW, x(:,S.inChIdx));
                catch ME
                    try, localWavStreamClose(S.wavW); catch, end
                    S.wavW = [];
                    S.contRecording = false;
                    lblRecState.Text = sprintf('REC: ERROR (%s)', ME.message);
                    logInfo(sprintf('CONT ERROR: %s', ME.message));
                    updateRecButton();
                end
            end

            if ~isempty(S.writer)
                switch S.outMode
                    case "Off"
                        % Same-device duplex: PortAudio's hardware ring buffer
                        % requires the writer to be fed every cycle even when
                        % monitoring is off, otherwise the output buffer starves
                        % and blocks the reader — causing dt to spike.
                        % Write silence to keep the driver clock ticking.
                        localWriteToOutputFixed( ...
                            zeros(size(x,1), max(2, double(S.outNumChannels))), 'silent-off');
                    case "Passthrough"
                        localPassthroughRealtime(x);
                    case "Heterodyne"
                        localHeterodyneRealtime(x);
                end
            end

            if toc(S.lastUiTic) >= (1/max(1,S.uiFps))
                S.lastUiTic = tic;

                if S.showVisuals
                    localWavePushToPlot(waveLine,axWave);
                    localSpecPushToImage(img1,axSpec1,1);
                    localSpecPushToImage(img2,axSpec2,2);

                    % Only update spec Y ceiling when it actually changes
                    yTop = S.fsActual/2/1000;  % kHz
                    if ~isempty(S.specMaxHz), yTop=min(yTop,S.specMaxHz/1000); end
                    if yTop ~= S.lastSpecYTop
                        axSpec1.YLim=[0 yTop]; axSpec2.YLim=[0 yTop];
                        S.lastSpecYTop = yTop;
                    end
                elseif S.lastShowVisuals && ~S.showVisuals
                    % Visuals just turned off — clear plots to black/blank
                    try, waveLine.YData = nan(size(waveLine.YData)); catch, end
                    try, img1.CData = -120 * ones(size(img1.CData)); catch, end
                    try, img2.CData = -120 * ones(size(img2.CData)); catch, end
                end
                S.lastShowVisuals = S.showVisuals;

                recTxt = 'off';
                if S.tapCapturing, recTxt='tap'; end
                if S.contRecording, recTxt='cont'; end
                if S.autoEnabled && S.recMode=="Auto", recTxt='auto'; end

                lblStatus.Text = sprintf('RUNNING | drop=%d | dt=%.3fs | rec=%s', ...
                    S.dropEvents, S.lastDt, recTxt);

                % Render exactly once per UI tick — tied to uiFps, not audio frame rate
                drawnow limitrate;
            end
        end

        % ── Close any in-flight recording ─────────────────────────────────
        if S.contRecording && ~isempty(S.wavW)
            try, localWavStreamClose(S.wavW); catch, end
            S.wavW = []; S.contRecording = false;
        end

        % Discard a partial TAP that was still accumulating
        if S.tapCapturing
            S.tapCapturing = false;
            S.tapData      = [];
            S.tapNeeded    = 0;
        end

        % Disarm auto-recording
        S.autoEnabled = false;

        % Reset heterodyne phase so next START has no phase discontinuity
        S.hetPhase = 0;

        cleanupAudio();

        if isvalid(fig)
            lblStatus.Text  = 'Status: stopped';
            lblRecState.Text = 'Recording: off';
            updateRecButton();
            logInfo('Stream stopped');
        end
    end

    function onOpenLink(~,~)
        % Find the URL matching the currently selected label
        sel = ddResLinks.Value;
        idx = find(strcmp(RES_LINKS(:,1), sel), 1);
        if isempty(idx), return; end
        url = RES_LINKS{idx, 2};
        logInfo(sprintf('Opening resource: %s %s %s', sel, char(8594), url));
        try
            web(url, '-browser');
        catch
            % Fallback for older MATLAB versions
            if ismac
                system(['open "' url '"']);
            elseif ispc
                system(['start "" "' url '"']);
            else
                system(['xdg-open "' url '"']);
            end
        end
    end

    function onClose(~,~)
        logInfo('--- CLOSE ---');
        S.isRunning = false;

        if S.contRecording && ~isempty(S.wavW)
            try, localWavStreamClose(S.wavW); catch, end
            S.wavW = []; S.contRecording = false;
        end

        S.tapCapturing = false; S.tapData = []; S.tapNeeded = 0;
        S.autoEnabled  = false;
        S.hetPhase     = 0;

        cleanupAudio();

        if isvalid(fig)
            delete(fig);
        end
    end

    function cleanupAudio()
        % release() + delete() — release drops the PortAudio stream;
        % delete destroys the System-object handle so MATLAB's internal
        % PortAudio bookkeeping is fully cleared.  Without delete(),
        % lingering object state causes "Invalid number of channels"
        % on same-device re-opens after a frame-size change.
        try, if ~isempty(S.reader), release(S.reader); delete(S.reader); end, catch, end
        try, if ~isempty(S.writer), release(S.writer); delete(S.writer); end, catch, end
        try, if ~isempty(S.duplex), release(S.duplex); delete(S.duplex); end, catch, end

        S.reader    = [];
        S.writer    = [];
        S.duplex    = [];
        S.useDuplex = false;
        S.outBuffer = zeros(0, max(2, double(S.outNumChannels)));

        % On macOS, Core Audio does not release the PortAudio port
        % synchronously on release().  Without this pause, an immediate
        % re-START gets a "port already in use" error.
        if ismac
            pause(0.30);
        end
    end

%% ── Waveform helpers (dB SPL / dBFS) ────────────────────────────────────
    function localWaveUpdateFromChunk(xChunk)
        x = single(xChunk(:));
        x = x(1:S.waveDecim:end);
        if isempty(x), return; end

        floorDb = -120;

        if S.autoCalibPaPerUnit > 0
            pRef = 20e-6; % Pa
            xPa = abs(double(x)) * double(S.autoCalibPaPerUnit);
            xPa(xPa < 1e-12) = 1e-12;
            xDb = 20*log10(xPa / pRef);   % dB SPL
            xDb(xDb < 0) = 0;
        else
            xAbs = abs(double(x));
            xAbs(xAbs < 1e-12) = 1e-12;
            xDb  = 20*log10(xAbs);        % dBFS (0 dB at |x|=1)
            xDb(xDb < floorDb) = floorDb;
        end

        n = numel(xDb);
        N = numel(S.waveBufDb);

        if isempty(S.waveBufDb) || N==0
            N = max(200, round(S.waveDispSec * S.wavePlotFs));
            S.waveBufDb = floorDb * ones(N,1,'single');
            S.waveIdx   = 1;
        end

        if n >= N
            S.waveBufDb = single(xDb(end-N+1:end));
            S.waveIdx   = 1;
            return;
        end

        idx = S.waveIdx;
        if idx + n - 1 <= N
            S.waveBufDb(idx:idx+n-1) = single(xDb);
            idx = idx + n;
            if idx > N, idx = 1; end
        else
            k = N - idx + 1;
            S.waveBufDb(idx:N) = single(xDb(1:k));
            S.waveBufDb(1:n-k) = single(xDb(k+1:end));
            idx = (n-k) + 1;
        end

        S.waveIdx = idx;
    end

    function localWavePushToPlot(ln, ax)
        if isempty(S.waveBufDb), return; end

        idx = S.waveIdx;
        if idx == 1
            y = S.waveBufDb;
        else
            y = [S.waveBufDb(idx:end); S.waveBufDb(1:idx-1)];
        end

        ln.YData = y;   % XData set once at START — never touched here

        % Update label/title only when calibration state toggles
        calibActive = (S.autoCalibPaPerUnit > 0);
        if calibActive ~= S.lastCalibActive
            S.lastCalibActive = calibActive;
            ax.YLimMode = 'manual';
            if calibActive
                ax.YLabel.String = 'SPL (dB re 20 \muPa)';
                ax.Title.String  = 'Waveform (SPL)';
            else
                ax.YLabel.String = 'Level (dBFS)';
                ax.Title.String  = 'Waveform (dBFS)';
            end
        end

        % Nominal range: uncalibrated [-120, 0], calibrated [0, 140].
        % Ceiling expands if data exceeds it; floor is always fixed.
        if calibActive
            yLo   = 0;
            yCeil = 140;
        else
            yLo   = -120;
            yCeil = 0;
        end
        finite_y = y(isfinite(y));
        yTop = yCeil;
        if ~isempty(finite_y)
            yTop = max(yCeil, max(finite_y));
        end
        % Round ceiling up to next 10 dB step for clean ticks
        yTop = ceil(yTop / 10) * 10;
        if ax.YLim(1) ~= yLo || ax.YLim(2) ~= yTop
            ax.YLim  = [yLo, yTop];
            ax.YTick = yLo:10:yTop;
        end
    end

%% ── Auto detection (lightweight) ──────────────────────────────────────
    function localAutoDetectFromChunk(xChunk)
        if S.autoCooldownSamp > 0
            S.autoCooldownSamp = max(int64(0), S.autoCooldownSamp - int64(numel(xChunk)));
            return;
        end

        if S.autoCalibPaPerUnit > 0
            thrPa = 20e-6 * 10^(double(S.autoThrDb)/20);
            thrUnit = thrPa / double(S.autoCalibPaPerUnit);
        else
            thrUnit = 10^(double(S.autoThrDb)/20);
        end

        thrUnit = max(thrUnit, 1e-12);
        ipiSamp = max(1, round(S.autoIpiSec * S.fsActual));

        evtIdx = localFindCallsSimple(xChunk, thrUnit, ipiSamp);
        if isempty(evtIdx), return; end

        chunkStart = S.sampleCounter - int64(size(xChunk,1)) + 1;
        absEvt = chunkStart + int64(evtIdx(:)) - 1;

        S.autoEventSamples = [S.autoEventSamples; absEvt]; %#ok<AGROW>

        preSamp = int64(round(S.preTrigSec * S.fsActual));
        keepFrom = S.sampleCounter - preSamp;
        S.autoEventSamples = S.autoEventSamples(S.autoEventSamples >= keepFrom);

        if numel(S.autoEventSamples) >= S.autoMinPeaks
            if ~S.tapCapturing && ~S.contRecording
                logInfo(sprintf('AUTO trigger: %d events in last %.2fs', numel(S.autoEventSamples), S.preTrigSec));
                doTapRecord();
                S.autoCooldownSamp = int64(round(S.autoCooldownSec * S.fsActual));
                S.autoEventSamples = zeros(0,1,'int64');
            end
        end
    end

    function evt = localFindCallsSimple(sig, thr, ipi)
        evt = [];
        try
            a = find(abs(double(sig)) > double(thr));
            if isempty(a), return; end
            d = diff(a);
            starts = [a(1); a(find(d > ipi)+1)]; %#ok<FNDSB>
            evt = starts;
        catch
            evt = [];
        end
    end

%% ── Spectrogram helpers ──────────────────────────────────────────────
    function localSpecUpdateFromChunk(xChunk,which)
        xChunk = single(xChunk(:));
        if isempty(xChunk), return; end

        hop = S.specHop;
        win = S.specWinVec;
        nfft = S.specNFFT;
        winLen = S.specWin;

        % If the chunk is shorter than the analysis window, zero-pad and
        % treat the whole chunk as one segment (keeps spectrogram alive
        % for small frame sizes like 256 or 512).
        N = numel(xChunk);
        if N < winLen
            xChunk = [xChunk; zeros(winLen - N, 1, 'single')];
        end

        nFrames = floor((numel(xChunk)-winLen)/hop)+1;
        if nFrames<=0, return; end

        for kk=1:nFrames
            i0 = 1+(kk-1)*hop;
            seg = xChunk(i0:i0+winLen-1).*win;

            pDB = 20*log10(abs(fft(seg,nfft))+1e-9);
            pDB = pDB(1:floor(nfft/2)+1);

            if which==1
                S.specBuf1(:,S.specColIdx1) = single(pDB);
                S.specColIdx1 = S.specColIdx1 + 1;
                if S.specColIdx1>S.specCols, S.specColIdx1=1; end
            else
                S.specBuf2(:,S.specColIdx2) = single(pDB);
                S.specColIdx2 = S.specColIdx2 + 1;
                if S.specColIdx2>S.specCols, S.specColIdx2=1; end
            end
        end
    end

    function localSpecPushToImage(img,ax,which) %#ok<INUSD>
        if which==1
            B = S.specBuf1; idx = S.specColIdx1;
        else
            B = S.specBuf2; idx = S.specColIdx2;
        end
        if isempty(B), return; end

        if idx==1
            C2 = B;
        else
            C2 = [B(:,idx:end), B(:,1:idx-1)];
        end

        img.CData = C2;   % XData/YData/XLim set once at START — not touched here
    end

%% ── Monitoring (Realtime) ────────────────────────────────────────────
    function [srcL, srcR] = localGetMonitorSourceChannels(frameNCh)
        srcL = min(max(1, S.monLeftChan),  frameNCh);
        srcR = min(max(1, S.monRightChan), frameNCh);
        if isempty(srcR), srcR = min(2, frameNCh); end
        if isempty(srcL), srcL = 1; end
    end

    function localHeterodyneRealtime(frame)
        if isempty(frame), return; end
        out = localBuildMonitorOutput(frame, true);
        out = localResampleStereo(out);
        out = out * double(S.monitorGain);
        out = max(-1, min(1, out));
        localWriteToOutputFixed(out, 'heterodyne');
    end

    function localPassthroughRealtime(frame)
        if isempty(frame), return; end
        out = localBuildMonitorOutput(frame, false);
        out = localResampleStereo(out);
        out = out * double(S.monitorGain);
        out = max(-1, min(1, out));
        localWriteToOutputFixed(out, 'passthrough');
    end

    function outFrame = localBuildMonitorOutput(frame, applyHet)
        % Build a full-width output frame  (N x nOut).
        %
        % Routing rules
        % ─────────────
        % One-to-one : each selected input channel k → output column k
        %              (after DC removal ± heterodyne)
        %
        % Col 1 (L ear)
        %   Mix OFF → Mon.Left  input signal
        %   Mix ON  → sum of all odd-numbered selected input signals
        %
        % Col 2 (R ear)
        %   Mix OFF → Mon.Right input signal
        %   Mix ON  → sum of all even-numbered selected input signals
        %
        % Mon.Left / Mon.Right channels are always included in the DSP
        % set so they appear in cols 1/2 even if not ticked in Input Channels.

        N        = size(frame, 1);
        frameNCh = size(frame, 2);
        nOut     = max(2, double(S.outNumChannels));
        outFrame = zeros(N, nOut);   % silence on all unselected output channels

        % Selected input + output channels (clamped to available range)
        validIn  = S.inChIdx( S.inChIdx  >= 1 & S.inChIdx  <= frameNCh);
        validOut = S.outChIdx(S.outChIdx >= 1 & S.outChIdx <= nOut);
        if isempty(validIn),  validIn  = 1; end
        if isempty(validOut), validOut = 1:min(2, nOut); end

        % Build processing set: validIn + Mon channels (Mix OFF needs them even
        % if not ticked as input channels).
        if S.mixToBoth
            procSet = unique(validIn(:)', 'stable');
        else
            [srcL, srcR] = localGetMonitorSourceChannels(frameNCh);
            procSet = unique([validIn(:)', srcL, srcR], 'stable');
        end

        % DC-remove all channels in procSet
        xSel = double(frame(:, procSet));
        xSel = xSel - mean(xSel, 1);

        % Optionally apply heterodyne (single carrier phase block for all cols)
        if applyHet
            phInc      = 2*pi * S.hetCarrierHz / S.fsActual;
            ph         = S.hetPhase + phInc * (0:N-1)';
            S.hetPhase = mod(S.hetPhase + phInc * N, 2*pi);
            xSel       = xSel .* cos(ph);
        end

        % ── One-to-one: input ch k → output col k (only selected outputs) ─
        for ci = 1:numel(validIn)
            k = validIn(ci);
            if k <= nOut && ismember(k, validOut)   % only write to selected output ch
                ciP = find(procSet == k, 1);
                outFrame(:, k) = xSel(:, ciP);
            end
        end

        % ── L / R monitor mix → cols 1 & 2 (only if those outputs selected) ─
        if S.mixToBoth
            oddMask  = mod(procSet, 2) == 1;
            evenMask = mod(procSet, 2) == 0;
            if any(oddMask),  L = sum(xSel(:, oddMask),  2); else, L = xSel(:, 1);   end
            if any(evenMask), R = sum(xSel(:, evenMask), 2); else, R = xSel(:, end); end
        else
            ciL = find(procSet == srcL, 1);
            ciR = find(procSet == srcR, 1);
            L = zeros(N, 1); R = zeros(N, 1);
            if ~isempty(ciL), L = xSel(:, ciL); end
            if ~isempty(ciR), R = xSel(:, ciR); end
        end

        if ismember(1, validOut), outFrame(:, 1) = L; end
        if nOut >= 2 && ismember(2, validOut), outFrame(:, 2) = R; end
    end

    function yOut = localResampleStereo(yIn)
        % Resample all columns (handles stereo or any N-channel frame).
        nC = size(yIn, 2);
        if isempty(yIn), yOut = zeros(0, max(1, nC)); return; end

        if S.fsActual == S.outFsActual
            yOut = yIn;
            return;
        end

        if S.useResample
            try
                cols = cell(1, nC);
                for c = 1:nC
                    cols{c} = resample(yIn(:,c), S.rsP, S.rsQ);
                end
                yOut = [cols{:}];
                return;
            catch
            end
        end

        d = max(1, round(S.fsActual / S.outFsActual));
        yOut = yIn(1:d:end, :);
    end

    function localWriteToOutputFixed(y,tag)
        if nargin<2, tag='output'; end
        if isempty(S.writer) || isempty(y), return; end

        if isvector(y), y = y(:); end
        if ~isa(y,'double'), y = double(y); end

        % Pad or trim to the number of channels the writer was opened with
        nC = max(2, double(S.outNumChannels));
        nc = size(y, 2);
        if nc < nC
            y(:, end+1:nC) = 0;   % pad silent channels to the right
        elseif nc > nC
            y = y(:, 1:nC);       % safety trim
        end

        fsz = double(S.outFrameSize);
        if isempty(fsz) || fsz<=0
            try, S.writer(y); catch ME, logInfo(sprintf('Writer error (%s): %s',tag,ME.message)); end
            return;
        end

        % Reset buffer if column count changed (e.g. mid-run device switch)
        if size(S.outBuffer, 2) ~= nC
            S.outBuffer = zeros(0, nC);
        end

        S.outBuffer = [S.outBuffer; y]; %#ok<AGROW>

        while size(S.outBuffer,1) >= fsz
            chunk = S.outBuffer(1:fsz,:);
            S.outBuffer(1:fsz,:) = [];
            try
                S.writer(chunk);
            catch ME
                logInfo(sprintf('Writer error (%s): %s',tag,ME.message));
            end
        end
    end

%% ── WAV helpers ──────────────────────────────────────────────────────
    function localWriteWav(data)
        if isempty(data), return; end
        try
            ts=datetime('now','Format','yyyyMMdd_HHmmss_SSS');
            suf=strtrim(string(S.suffix));
            if strlength(suf)>0
                fn=sprintf('%s_%s.wav',char(ts),char(suf));
            else
                fn=sprintf('%s.wav',char(ts));
            end
            % Respect the bit depth selected by the user
            [bps, isFlt] = localBitDepthFromStr(S.inBitDepthActual);
            if isFlt
                % audiowrite with single data + BitsPerSample=32 → IEEE float WAV
                audiowrite(fullfile(S.destFolder,fn), single(data), S.fsActual, 'BitsPerSample', 32);
            else
                audiowrite(fullfile(S.destFolder,fn), data, S.fsActual, 'BitsPerSample', bps);
            end
            if isFlt, depthStr='float'; else, depthStr='int'; end
            logInfo(sprintf('TAP saved: %s (%d-bit %s)', fn, bps, depthStr));
        catch ME
            uialert(fig,ME.message,'WAV write failed');
            logInfo(sprintf('TAP FAIL: %s',ME.message));
        end
    end

%% ── Ring buffer helpers ──────────────────────────────────────────────
    function localRingWrite(x)
        if isempty(S.ring), return; end
        L = size(x,1);
        R = size(S.ring,1);
        idx = S.ringWriteIdx;

        if idx+L-1 <= R
            S.ring(idx:idx+L-1,:) = single(x);
        else
            k = R-idx+1;
            S.ring(idx:R,:) = single(x(1:k,:));
            S.ring(1:(L-k),:) = single(x(k+1:end,:));
        end

        S.ringWriteIdx = mod(idx+L-1, R) + 1;
        S.ringFilled   = min(R, S.ringFilled + L);
    end

    function x = localGetLastFromRing(N)
        if isempty(S.ring) || S.ringFilled==0
            x = [];
            return;
        end

        N = min(N, S.ringFilled);
        R = size(S.ring,1);

        eI = S.ringWriteIdx-1;
        if eI<1, eI=R; end

        sI = eI - N + 1;
        if sI>=1
            x = S.ring(sI:eI,:);
        else
            x = [S.ring(R+sI:R,:); S.ring(1:eI,:)];
        end
    end

    function s = localIdxToStr(idx)
        if isempty(idx), s='-'; return; end
        s = sprintf('%d,',idx);
        s = s(1:end-1);
    end

    function s = localBitDepthString(bitsVal)
        try
            b = str2double(string(bitsVal));
            if isnan(b), b = 32; end
        catch
            b = 32;
        end
        if b==32
            s = "32-bit float";
        else
            s = sprintf('%d-bit integer', b);
        end
    end

end % BatRecorderGUI

%% ════════════════════════════════════════════════════════════════════════
%% LOG HTML BUILDER
%% ════════════════════════════════════════════════════════════════════════
function html = localBuildLogHtml(lines)
% Render log lines as coloured HTML:
%   error / fail / exception  →  bright orange  #ff6b1f
%   warn / fallback / note    →  yellow         #f0c040
%   everything else           →  green          #2eb872
rows = cell(1, numel(lines));
for k = 1:numel(lines)
    raw = lines{k};
    % HTML-escape special characters
    raw = strrep(raw, '&', '&amp;');
    raw = strrep(raw, '<', '&lt;');
    raw = strrep(raw, '>', '&gt;');
    raw = strrep(raw, '"', '&quot;');
    lo = lower(raw);
    if contains(lo,'fail') || contains(lo,'error') || contains(lo,'exception')
        cls = 'e';   % orange
    elseif contains(lo,'warn') || contains(lo,'fallback') || ...
           contains(lo,'capped') || contains(lo,'note:') || contains(lo,'unavailable')
        cls = 'w';   % yellow
    else
        cls = 'n';   % green
    end
    rows{k} = sprintf('<div class="%s">%s</div>', cls, raw);
end
body = strjoin(rows, '');
html = ['<html><head><style>' ...
    'body{background:#0f1012;margin:0;padding:4px 6px;' ...
    'font-family:"Courier New",Courier,monospace;font-size:10px;}' ...
    '.n{color:#2eb872}.e{color:#ff6b1f}.w{color:#f0c040}' ...
    'div{white-space:pre-wrap;line-height:1.4}' ...
    '</style></head><body>' body ...
    '<script>window.scrollTo(0,document.body.scrollHeight);</script>' ...
    '</body></html>'];
end

%% ════════════════════════════════════════════════════════════════════════
%% MODULE-LEVEL HELPERS
%% ════════════════════════════════════════════════════════════════════════
function f=resolveFont(candidates)
try
    avail=listfonts;
    for k=1:numel(candidates)
        if any(strcmpi(avail,candidates{k}))
            f=candidates{k};
            return;
        end
    end
catch
end
f='Helvetica';
end

function addTip(ctrl,tip)
try, ctrl.Tooltip=tip; catch, end
end

function p=makePanel(parent,title,row,C,FONT)
p=uipanel(parent,'Title',title,...
    'BackgroundColor',C.surface,'ForegroundColor',C.accent,...
    'HighlightColor',C.border,'FontName',FONT,'FontSize',10,'FontWeight','bold');
p.Layout.Row=row; p.Layout.Column=1; p.Scrollable='on';
end

function lb=mkLabel(parent,txt,row,col,FONT,C)
lb=uilabel(parent,'Text',txt,...
    'FontName',FONT,'FontSize',10,'FontWeight','bold',...
    'FontColor',C.txtDim,'BackgroundColor','none');
lb.Layout.Row=row; lb.Layout.Column=col;
end

function dd=mkDropdown(parent,items,val,row,col,FONT,C)
dd=uidropdown(parent,'Items',items,'Value',val,...
    'FontName',FONT,'FontSize',10,'BackgroundColor',C.bg,'FontColor',C.txt);
dd.Layout.Row=row; dd.Layout.Column=col;
end

function cb=mkCheckbox(parent,txt,val,row,col,FONT,C)
cb=uicheckbox(parent,'Text',txt,'Value',val,...
    'FontName',FONT,'FontSize',10,'FontColor',C.accent);
cb.Layout.Row=row; cb.Layout.Column=col;
end

function ef=mkNumField(parent,lims,val,row,col,FONT,C)
ef=uieditfield(parent,'numeric','Limits',lims,'Value',val,...
    'FontName',FONT,'FontSize',10,'BackgroundColor',[0.17 0.18 0.21],'FontColor',C.txt);
ef.Layout.Row=row; ef.Layout.Column=col;
end

function styleAxes(ax,ttl,xlbl,ylbl,C,FONT)
ax.Color=C.bg; ax.XColor=C.txtDim; ax.YColor=C.txtDim;
ax.GridColor=C.border; ax.MinorGridColor=C.border;
ax.Title.String=ttl; ax.Title.Color=C.txt;
ax.XLabel.String=xlbl; ax.XLabel.Color=C.txtDim;
ax.YLabel.String=ylbl; ax.YLabel.Color=C.txtDim;
ax.Title.FontName=FONT; ax.XLabel.FontName=FONT; ax.YLabel.FontName=FONT;
ax.FontName=FONT; ax.FontSize=9; box(ax,'off');
end

function applyFontToFig(~,~), end

function dest = localDefaultDestFolder()
% Documents/RUBAT/Rec/YYYYMMDD/ — cross-platform
try
    home = char(java.lang.System.getProperty('user.home'));
catch
    home = pwd;
end

if ispc
    % Windows: use the shell-reported Documents folder (handles OneDrive
    % redirection, non-English locale names, etc.)
    try
        [~, docPath] = system('powershell -NoProfile -Command "[Environment]::GetFolderPath(''MyDocuments'')"');
        docPath = strtrim(docPath);
        if isfolder(docPath)
            doc = docPath;
        else
            doc = fullfile(home, 'Documents');
        end
    catch
        doc = fullfile(home, 'Documents');
    end
else
    doc = fullfile(home, 'Documents');
end

dateFolder = char(datetime('now','Format','yyyyMMdd'));
dest = fullfile(doc,'RUBAT','Rec',dateFolder);
try
    if ~isfolder(dest), mkdir(dest); end
catch
end
end

%% ── Device enumeration (STRICT input vs output lists) ───────────────────
function [inReg,outReg]=localEnumerateDevicesStrict()
inReg =struct('label',{'Default'},'tbName',{'Default'},'devid',{-1});
outReg=struct('label',{'Default'},'tbName',{'Default'},'devid',{-1});

try
    % Force PortAudio to re-enumerate so hot-plug/unplug is detected.
    try, clear audiodevinfo; catch, end  %#ok<CLMEX>
    info=audiodevinfo;

    try, dr=audioDeviceReader(); knownIn=getAudioDevices(dr);  release(dr); catch, knownIn={}; end
    try, dw=audioDeviceWriter(); knownOut=getAudioDevices(dw); release(dw); catch, knownOut={}; end

    if isfield(info,'input') && ~isempty(info.input)
        for k=1:numel(info.input)
            raw=strtrim(info.input(k).Name); id=info.input(k).ID;
            if isempty(raw), continue; end
            tb=matchToolboxName(raw,knownIn);
            if any(strcmpi({inReg.tbName},tb)), continue; end
            inReg(end+1)=struct('label',raw,'tbName',tb,'devid',id); %#ok<AGROW>
        end
    end

    if isfield(info,'output') && ~isempty(info.output)
        for k=1:numel(info.output)
            raw=strtrim(info.output(k).Name); id=info.output(k).ID;
            if isempty(raw), continue; end
            tb=matchToolboxName(raw,knownOut);
            if any(strcmpi({outReg.tbName},tb)), continue; end
            outReg(end+1)=struct('label',raw,'tbName',tb,'devid',id); %#ok<AGROW>
        end
    end
catch
end
end

function tb=matchToolboxName(raw,known)
tb=''; lraw=lower(raw);
for k=1:numel(known)
    lk=lower(known{k});
    if contains(lk,lraw) || contains(lraw,lk)
        tb=known{k};
        return;
    end
end
if isempty(tb)
    tb=strtrim(regexprep(raw,'\s*\([^)]*\)\s*$',''));
    if isempty(tb), tb=raw; end
end
end

function entry = localFindDevEntry(devList, devID)
% Return the audiodevinfo struct entry matching devID, or [] if not found.
entry = [];
for k = 1:numel(devList)
    if devList(k).ID == devID
        entry = devList(k);
        return;
    end
end
end

function [fsList, bitsList] = localCapsFromEntry(~) %#ok<INUSD>
% On macOS/Core Audio, PortAudio runs every stream in shared mode and applies
% transparent sample-rate conversion.  There is NO way from MATLAB to
% distinguish hardware-native rates from resampled ones:
%   - audiodevinfo() scalar returns 1 for all combinations (SRC-masked)
%   - r.SampleRate readback returns the requested rate, not the hardware clock
%   - DefaultSampleRate / SupportedSampleRates struct fields are not populated
%     by PortAudio on macOS
%
% The only thing that IS detectable: rates above ~384 kHz throw a hard
% PortAudio error ("Invalid sample rate"), confirming the ceiling.  Channel
% count is detected reliably via open-probe in onInputDeviceChanged.
%
% Practical outcome: offer the full PortAudio-working list (up to 384 kHz).
% Users select the rate matching their hardware; localOpenReader falls back
% automatically at START if the device rejects the chosen rate.
FULL_FS_LIST = {'44100','48000','88200','96000','176400','192000','352800','384000'};
fsList   = FULL_FS_LIST;
bitsList = {'16','24','32'};
end

function [fsList, bitsList] = localProbeDeviceCaps(devID, isInput) %#ok<INUSD>
% Wrapper kept for on-demand calls from localUpdateDropdownsForSelection.
% Returns the same fixed list — see localCapsFromEntry for explanation.
[fsList, bitsList] = localCapsFromEntry([]);
end

function caps = localGetDeviceCaps(devIDorName,isInput)
caps = struct('id',devIDorName,'name',resolveName(devIDorName,isInput),...
    'fs',[],'nCh',[],'nBits',[],'isInput',isInput,'isOutput',~isInput);
try
    info=audiodevinfo;
    if isInput
        if isfield(info,'input')
            for k=1:numel(info.input)
                if isnumeric(devIDorName) && info.input(k).ID==devIDorName
                    caps.fs    = localCoerceVec(info.input(k).SupportedSampleRates);
                    caps.nCh   = localCoerceVec(info.input(k).SupportedNumChannels);
                    if isfield(info.input(k),'SupportedBitDepths')
                        caps.nBits = localCoerceVec(info.input(k).SupportedBitDepths);
                    end
                    caps.name = strtrim(info.input(k).Name);
                    break;
                end
            end
        end
    else
        if isfield(info,'output')
            for k=1:numel(info.output)
                if isnumeric(devIDorName) && info.output(k).ID==devIDorName
                    caps.fs    = localCoerceVec(info.output(k).SupportedSampleRates);
                    caps.nCh   = localCoerceVec(info.output(k).SupportedNumChannels);
                    if isfield(info.output(k),'SupportedBitDepths')
                        caps.nBits = localCoerceVec(info.output(k).SupportedBitDepths);
                    end
                    caps.name = strtrim(info.output(k).Name);
                    break;
                end
            end
        end
    end
catch
end
end

function v = localCoerceVec(x)
v = [];
try
    if isnumeric(x), v = x(:)'; return; end
    if iscell(x), v = cell2mat(x(:)'); v = v(:)'; return; end
catch
end
end

function name = resolveName(d,isInput)
if isInput
    name = resolveInputName(d);
else
    name = resolveOutputName(d);
end
end

function variants=localNameVariants(baseName,isInput)
variants={baseName};
try
    if isInput
        try, dr=audioDeviceReader(); known=getAudioDevices(dr); release(dr); catch, known={}; end
    else
        try, dw=audioDeviceWriter(); known=getAudioDevices(dw); release(dw); catch, known={}; end
    end
    known=known(:)'; lbase=lower(strtrim(baseName));
    for k=1:numel(known)
        lk=lower(strtrim(known{k}));
        if contains(lk,lbase) || contains(lbase,lk)
            if ~any(strcmpi(variants,known{k})), variants{end+1}=known{k}; end %#ok<AGROW>
        end
    end
catch
end
if ~any(strcmpi(variants,'Default')), variants{end+1}='Default'; end
end

function [reader,fsActual,nChActual,usedName,bitActual,attempts]=localOpenReader(devIDorName,fsReq,frameLen,nChReq,bitDepthReq)
attempts={}; reader=[]; usedName=''; bitActual='';
baseName=resolveInputName(devIDorName);
vars=localNameVariants(baseName,true);

fsTry=unique([fsReq,768000,705600,384000,352800,192000,176400,96000,88200,48000,44100],'stable');
% Dense channel list so no supported count is skipped (e.g. 12-ch Babyface):
chTry=unique([nChReq, 128,64,48,32,24,20,18,16,14,12,10,8,6,4,2,1],'stable');

bitActual = bitDepthReq;

lastErr=MException('Bat:noDevice','Could not open input "%s".',baseName);
for v=1:numel(vars)
    dn=vars{v};
    for fi=1:numel(fsTry)
        for ci=1:numel(chTry)
            try
                r=audioDeviceReader('Device',dn,'SampleRate',fsTry(fi),...
                    'NumChannels',chTry(ci),'SamplesPerFrame',frameLen);
                r(); fsActual=r.SampleRate; nChActual=r.NumChannels;
                usedName=r.Device; reader=r;
                attempts{end+1}=sprintf('OK in "%s" Fs=%d Ch=%d Frame=%d Bits=%s',usedName,fsActual,nChActual,frameLen,char(bitDepthReq)); %#ok<AGROW>
                return;
            catch ME
                lastErr=ME;
                attempts{end+1}=sprintf('FAIL in "%s" Fs=%d Ch=%d Frame=%d: %s',dn,fsTry(fi),chTry(ci),frameLen,ME.message); %#ok<AGROW>
                try, if exist('r','var'), release(r); end, catch, end
            end
        end
    end
end
rethrow(lastErr);
end

function nCh = localProbeOutputChannels(devIDorName, resolvedName, fsReq)
% Probe the true output channel count for a device using three strategies,
% in order of reliability:
%  1. audiodevinfo struct  — reads PortAudio caps without opening a handle.
%  2. Empirical write probe — open writer with increasing NumChannels values
%     and actually flush a frame to confirm the device accepts that width.
%  3. Fall back to 2.

nCh = 0;

% --- Strategy 1: audiodevinfo struct --------------------------------
try
    info = audiodevinfo;
    if isfield(info,'output') && ~isempty(info.output)
        % Match by numeric ID first, then by name substring.
        for k = 1:numel(info.output)
            matched = false;
            if isnumeric(devIDorName) && devIDorName >= 0
                matched = (info.output(k).ID == devIDorName);
            end
            if ~matched && ~isempty(resolvedName)
                matched = strcmpi(strtrim(info.output(k).Name), strtrim(resolvedName)) || ...
                          contains(lower(info.output(k).Name), lower(strtrim(resolvedName))) || ...
                          contains(lower(strtrim(resolvedName)), lower(info.output(k).Name));
            end
            if matched
                if isfield(info.output(k),'MaxOutputChannels')
                    nCh = double(info.output(k).MaxOutputChannels);
                elseif isfield(info.output(k),'NumChannels')
                    nCh = double(info.output(k).NumChannels);
                end
                break;
            end
        end
    end
catch
end
if nCh >= 1, return; end

% --- Strategy 2: incremental upward scan to find true maximum ----------
% Scanning downward (e.g. 128→64→32→16→8) skips non-power-of-2 counts
% like 12 (Babyface) or 10 (some RME devices). Scanning 1-by-1 upward
% finds the exact maximum.
baseName = resolvedName;
vars = localNameVariants(baseName, false);
for v = 1:numel(vars)
    dn = vars{v};
    lastOk = 0;
    for nc = 1:64
        w = [];
        try
            w = audioDeviceWriter('Device', dn, 'SampleRate', fsReq, ...
                'SupportVariableSizeInput', true);
            w(zeros(256, nc));
            release(w);
            lastOk = nc;
        catch
            try, if ~isempty(w), release(w); end, catch, end
            break;   % first failure = we've passed the maximum
        end
    end
    if lastOk >= 1
        nCh = lastOk;
        return;
    end
end

% --- Strategy 3: absolute fallback ----------------------------------
nCh = max(nCh, 2);
end

function [ok,usedName,attempts]=localProbeWriter(devIDorName,fsReq,bitDepthReq,frameLen)
attempts={}; ok=false; usedName='Default';
baseName=resolveOutputName(devIDorName);
vars=localNameVariants(baseName,false);
fsTry=unique([fsReq,48000,44100],'stable'); %#ok<NASGU>

for v=1:numel(vars)
    dn=vars{v};
    for fi=1:numel(unique([fsReq,48000,44100],'stable'))
        fsTryVal = unique([fsReq,48000,44100],'stable'); fsTryVal = fsTryVal(fi);
        try
            try
                w=audioDeviceWriter('Device',dn,'SampleRate',fsTryVal,...
                    'SupportVariableSizeInput',true);
            catch
                w=audioDeviceWriter('Device',dn,'SampleRate',fsTryVal);
            end
            w(zeros(256,2));
            usedName=w.Device; ok=true;
            attempts{end+1}=sprintf('OK out "%s" Fs=%d Bits=%s',usedName,w.SampleRate,char(bitDepthReq)); %#ok<AGROW>
            release(w);
            return;
        catch ME
            attempts{end+1}=sprintf('FAIL out "%s" Fs=%d Bits=%s: %s',dn,fsTryVal,char(bitDepthReq),ME.message); %#ok<AGROW>
            try, if exist('w','var'), release(w); end, catch, end
        end
    end
end
end

function [writer, usedName, bitActual, nChActual, attempts, fallbackUsed] = localOpenWriterRobust(devIDorName, fsActual, frameSize, sameDevice, bitDepthReq, nOutCh)
if nargin < 6 || isempty(nOutCh), nOutCh = 2; end
nOutCh = max(2, double(nOutCh));
attempts = {};
fallbackUsed = false;
bitActual = bitDepthReq;
nChActual = nOutCh;

try
    [writer, usedName, bitActual, nChActual, a1] = localOpenWriter(devIDorName, fsActual, frameSize, bitDepthReq, nOutCh);
    attempts = [attempts, a1];
    return;
catch ME
    attempts{end+1} = sprintf('FAIL out "%s" Fs=%d Bits=%s Ch=%d: %s', resolveOutputName(devIDorName), fsActual, char(bitDepthReq), nOutCh, ME.message);
    if ~isDuplexBufferConstraint(ME)
        rethrow(ME);
    end
    if sameDevice
        attempts{end+1} = 'Same-device buffer constraint detected: falling back to "Default" output for this run.';
    else
        attempts{end+1} = 'Buffer constraint detected: falling back to "Default" output for this run.';
    end
end

fallbackUsed = true;
try
    [writer, usedName, bitActual, nChActual, a2] = localOpenWriter(-1, fsActual, frameSize, bitDepthReq, nOutCh);
    attempts = [attempts, a2];
catch ME2
    attempts{end+1} = sprintf('FALLBACK FAIL out "Default" Fs=%d Bits=%s Ch=%d: %s', fsActual, char(bitDepthReq), nOutCh, ME2.message);
    rethrow(ME2);
end
end

function tf = isDuplexBufferConstraint(ME)
tf = false;
try
    msg = string(ME.message);
    tf = contains(msg, "buffer size parameter", 'IgnoreCase', true) && ...
        contains(msg, "must match", 'IgnoreCase', true);
catch
end
end

function [writer, usedName, bitActual, nChActual, attempts] = localOpenWriter(devIDorName, fsReq, frameSize, bitDepthReq, nOutCh)
if nargin < 5 || isempty(nOutCh), nOutCh = 2; end
nOutCh = max(2, double(nOutCh));
attempts = {};
writer   = [];
usedName = 'Default';
bitActual = bitDepthReq;
nChActual = nOutCh;

baseName = resolveOutputName(devIDorName);
vars     = localNameVariants(baseName,false);

fsTry    = unique([fsReq, 48000, 44100], 'stable');
frameTry = unique([max(64,round(frameSize)), 256], 'stable');

% Channel fallback: try requested count first, then progressively fewer.
% On same-device setups (e.g. Babyface), PortAudio may refuse the probed
% count after a previous run has altered Core Audio's internal state.
chTry = unique([nOutCh, nOutCh-2, nOutCh-4, 12, 10, 8, 6, 4, 2], 'stable');
chTry = chTry(chTry >= 2);

lastErr = MException('Bat:writerOpenFail','Could not open output "%s".', baseName);

for v = 1:numel(vars)
    dn = vars{v};
    for fi = 1:numel(fsTry)
        for ci = 1:numel(chTry)
            nc = chTry(ci);
            for fr = 1:numel(frameTry)
                fsz = frameTry(fr);
                try
                    try
                        w = audioDeviceWriter('Device', dn, 'SampleRate', fsTry(fi), ...
                            'SupportVariableSizeInput', true);
                    catch
                        w = audioDeviceWriter('Device', dn, 'SampleRate', fsTry(fi));
                    end

                    % Commit the channel layout by writing a real-width test frame
                    w(zeros(fsz, nc));

                    writer    = w;
                    usedName  = w.Device;
                    bitActual = bitDepthReq;
                    nChActual = nc;

                    attempts{end+1} = sprintf('OK out "%s" Fs=%d frame=%d Bits=%s Ch=%d', usedName, w.SampleRate, fsz, char(bitDepthReq), nc); %#ok<AGROW>
                    return;

                catch ME
                    lastErr = ME;
                    attempts{end+1} = sprintf('FAIL out "%s" Fs=%d frame=%d Bits=%s Ch=%d: %s', dn, fsTry(fi), fsz, char(bitDepthReq), nc, ME.message); %#ok<AGROW>
                    try, if exist('w','var'), release(w); end, catch, end
                end
            end
        end
    end
end

rethrow(lastErr);
end

function name=resolveInputName(d)
name='Default';
if isnumeric(d)&&d>=0
    try
        info=audiodevinfo;
        for k=1:numel(info.input)
            if info.input(k).ID==d
                raw=strtrim(info.input(k).Name);
                try, dr=audioDeviceReader(); known=getAudioDevices(dr); release(dr); catch, known={}; end
                tb=matchToolboxName(raw,known);
                if ~isempty(tb), name=tb; else, name=raw; end
                return;
            end
        end
    catch
    end
elseif ischar(d)||isstring(d)
    name=char(d);
end
end

function name=resolveOutputName(d)
name='Default';
if isnumeric(d)&&d>=0
    try
        info=audiodevinfo;
        for k=1:numel(info.output)
            if info.output(k).ID==d
                raw=strtrim(info.output(k).Name);
                try, dw=audioDeviceWriter(); known=getAudioDevices(dw); release(dw); catch, known={}; end
                tb=matchToolboxName(raw,known);
                if ~isempty(tb), name=tb; else, name=raw; end
                return;
            end
        end
    catch
    end
elseif ischar(d)||isstring(d)
    name=char(d);
end
end

%% ── Resampler setup ─────────────────────────────────────────────────────
function [bits, isFloat] = localBitDepthFromStr(s)
% Parse a bit-depth string such as "32-bit float", "24-bit integer", "16"
% Returns: bits (16/24/32) and isFloat (true when IEEE float)
try
    s = char(string(s));
    isFloat = ~isempty(regexpi(s,'float'));
    tok = regexp(s,'(\d+)','tokens','once');
    if isempty(tok)
        bits=16; isFloat=false; return;
    end
    bits = round(str2double(tok{1}));
    if isnan(bits) || bits<=0, bits=16; isFloat=false; end
catch
    bits=16; isFloat=false;
end
end

function [useResample,p,q] = localSetupResampler(fsIn, fsOut)
useResample = false; p=1; q=1;
if fsIn==fsOut, return; end
try
    [p,q] = rat(fsOut/fsIn, 1e-12);
    useResample = true;
catch
    useResample = false;
end
end

%% ── Streaming WAV (struct returned so dataBytes persists) ───────────────
function W=localWavStreamOpen(filename,fs,nCh,bitsPerSample,isFloat)
% bitsPerSample : 16 (default), 24, or 32
% isFloat       : true → 32-bit IEEE float (format 3); false → PCM (format 1)
if nargin<4 || isempty(bitsPerSample), bitsPerSample=16; end
if nargin<5 || isempty(isFloat),       isFloat=false;   end
bitsPerSample = round(double(bitsPerSample));
if ~ismember(bitsPerSample,[16 24 32]), bitsPerSample=16; end

fmtCode       = uint16(1 + 2*uint16(isFloat && bitsPerSample==32)); % 1=PCM, 3=float
bytesPerSamp  = ceil(bitsPerSample/8);

W.filename   = filename;  W.fs=fs;  W.nCh=nCh;
W.bits       = bitsPerSample;
W.isFloat    = isFloat && bitsPerSample==32;
W.bytesPerSamp = bytesPerSamp;
W.byteRate   = uint32(fs*nCh*bytesPerSamp);
W.blockAlign = uint16(nCh*bytesPerSamp);
W.dataBytes  = uint32(0);

[fid,msg]=fopen(filename,'Wb');
if fid<0, error('Cannot open WAV: %s',msg); end
W.fid=fid;

fwrite(fid,'RIFF','char');       fwrite(fid,uint32(0),'uint32');
fwrite(fid,'WAVE','char');       fwrite(fid,'fmt ','char');
fwrite(fid,uint32(16),'uint32'); fwrite(fid,fmtCode,'uint16');
fwrite(fid,uint16(nCh),'uint16'); fwrite(fid,uint32(fs),'uint32');
fwrite(fid,W.byteRate,'uint32'); fwrite(fid,W.blockAlign,'uint16');
fwrite(fid,uint16(bitsPerSample),'uint16');
fwrite(fid,'data','char');       fwrite(fid,uint32(0),'uint32');
end

function W=localWavStreamWrite(W,x)
if isempty(x), return; end
x=max(-1,min(1,double(x)));
bps = W.bits;
if W.isFloat
    % 32-bit IEEE float
    nBytes = numel(x)*4;
    fwrite(W.fid, single(x).', 'single');
elseif bps==16
    fwrite(W.fid, int16(round(x*32767)).', 'int16');
    nBytes = numel(x)*2;
elseif bps==24
    % 24-bit PCM: scale to 23-bit signed integer, write as 3 bytes little-endian
    xI = int32(max(-2^23, min(2^23-1, round(x*(2^23-1)))));
    rawBytes = typecast(xI(:), 'uint8');
    rawBytes = reshape(rawBytes, 4, []);
    rawBytes = rawBytes(1:3, :);    % keep 3 LSBs (little-endian)
    fwrite(W.fid, rawBytes(:), 'uint8');
    nBytes = numel(x)*3;
elseif bps==32
    fwrite(W.fid, int32(round(x*(2^31-1))).', 'int32');
    nBytes = numel(x)*4;
else
    fwrite(W.fid, int16(round(x*32767)).', 'int16');
    nBytes = numel(x)*2;
end
W.dataBytes = W.dataBytes + uint32(nBytes);
end

function localWavStreamClose(W)
fid=W.fid;
if fid<0, return; end
dSz=uint32(W.dataBytes);
fseek(fid,4,'bof');  fwrite(fid,uint32(36)+dSz,'uint32');
fseek(fid,40,'bof'); fwrite(fid,dSz,'uint32');
fclose(fid);
end