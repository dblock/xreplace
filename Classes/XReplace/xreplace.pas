unit xreplace;
{(c) Daniel Doubrovkine - 1996 - Stolen Technologies Inc. - University of Geneva }

{$H+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ComCtrls, Grids, Buttons, ExtCtrls, Menus, Gauges,
  RForm, TExec, lzh, ShellApi, TPicFile, TDropV, MDlg, xOpt, xLog,
  Outline, DirOutln, Wait, StrDropGrid, ClipBrd, xrClasses, BrowseDr, ShlObj,
  ShellView, CPidl, PidlManager, d32reg, d32gen, d32errors, d32debug, d32about,
  xplugins, OleCtrls, xrintro, ffProperties, ImgList, HlpBrowser;

var
   gWaitState: TWorking;
const
   DragLimit: integer = 5;
   {$ifndef Registered}
   ShareWareMax : integer = 15;
   {$endif}
   minusTwo: array[0..1] of char = '-2';
   ValidSpace = [#13, #10, #9, #32, #255,'!','#','"','$','%','&','(',')','*','+',
                 ',','.','/',':',';','<','=','>','?','@','[','\',']','^','{','|',
                 '}','~','','Ä','Å','É','Ç','Ñ','Ü','Ö','á','à','â','ã','å','ç',
                 'é','è','ê','ë','í','ì','î','ó','ò','ô','ö','õ','ú','ù','û','ü',
                 '¢','°','£','§','•','¶','ß','®','©','™','´','¨','Ø','Æ','∞','±',
                 '≤','≥','¥','µ','∂','∑','∏','π','∫','ª','º','Ω','æ','ø'];
   xFullHeader:array[0..10] of char = 'xRep32v0175';
   xRepHeader: array[0..10] of char = 'xRep32v0155';
   xDirHeader: array[0..10] of char = 'xRep32v0172';
   gOptions: string = 'Options:';
   gFrom: string = 'Replace from:';
   gTo: string = 'Replace with:';
   hFrom: string = 'enter text you wish to replace';
   hTo: string = 'enter text you wish to replace with';
   hOptions: string = 'select single line options';
   hCaseSens: string = 'case sensitive';
   hWholeWord: string = 'whole words only';
   hInter : string = 'include source for interline';
   hPrompt: string = 'prompt on replace';
   hThird: string = 'drag and drop a row using this anchor';

type
   TROperation = (opReplace, opPreview);
   ReplaceThread=class{(TThread)}
     public
        procedure Create;
     private
        procedure Execute; {override;}
        procedure ProcessMultilineReplacements(FileName, Target: string);
        procedure MakeReplacements;
        function ParseTreeView(TreeView:TTreeView;TreeNode:TTreeNode;ParentDirectory:string):string;
     end;
   (*
   {$ifdef Registered}
   TNumChoose = class
   private
      cStatusBar: TStatusBar;
      cStatusPanel: TStatusPanel;
      cmdMinus: TSpeedButton;
      cmdPlus: TSpeedButton;
      numShow: TLabel;
      procedure IncChoose(Sender: TObject);
      procedure DecChoose(Sender: TObject);
   public
      constructor Create(StatusBar: TStatusBar; StatusPanel: TStatusPanel);
      procedure Redraw;
      end;
   {$endif}
   *)
   
   TSpaceMemo = class (TMemo)
   private
      KeyPressed: boolean;
      procedure WMDropFiles(var M: TWMDropFiles); message WM_DROPFILES;
      {$ifdef Registered}procedure TotCount(var totFound, totReplaced: integer);{$endif}
   public
      FEditCol, FEditRow: LongInt;
      EditLSLeft, EditLSRight, EditRSLeft, EditRSRight: boolean;
      ItemHeight: integer;
      NTBug: boolean;
      procedure EditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure EditChange(Sender: TObject);
      procedure EditKeyPress(Sender: TObject; var Key: Char);
      procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
      function GetItemHeight(Font: TFont): integer;
      function IsLeftSplit(const Row: LongInt): boolean;
      function IsEnabled(const Row: LongInt): boolean;
      function IsRightSplit(const Row: LongInt): boolean;
      procedure SetEditCol(Value: LongInt);
      procedure SetEditRow(Value: LongInt);
      property EditCol: LongInt read FEditCol write SetEditCol;
      property EditRow: LongInt read FEditRow write SetEditRow;
      end;

   TxRepl32 = class(TForm)
      SaveDialog1: TSaveDialog;
      OpenDialog1: TOpenDialog;
      SaveDialog2: TSaveDialog;
      OpenDialog2: TOpenDialog;
      xReplaceMenu: TMainMenu;
      xReplace1: TMenuItem;
      Flags1: TMenuItem;
      Fileselection1: TMenuItem;
      Replacements1: TMenuItem;
      Help1: TMenuItem;
      Go1: TMenuItem;
      N1: TMenuItem;
      Quit1: TMenuItem;
      ClearAdd1: TMenuItem;
      ffAdd: TMenuItem;
      Remove2: TMenuItem;
      DragDrop1: TMenuItem;
      WildcardSelect1: TMenuItem;
      wsRemoveAll: TMenuItem;
      Remove3: TMenuItem;
      Load1: TMenuItem;
      Save2: TMenuItem;
      N2: TMenuItem;
      Load2: TMenuItem;
      Save3: TMenuItem;
      Help2: TMenuItem;
      N3: TMenuItem;
      AboutXReplace321: TMenuItem;
      FileViewer: TOpenDialog;
      Clear1: TMenuItem;
      xrSaveAll: TMenuItem;
      N4: TMenuItem;
      SaveDialog3: TSaveDialog;
      EditOptions: TMenuItem;
      SaveLog: TSaveDialog;
      Add1: TMenuItem;
      JoinSplitMenu: TMenuItem;
      wsDragDrop: TMenuItem;
      InvertGrid1: TMenuItem;
      Register1: TMenuItem;
      DropViewPopup: TPopupMenu;
      dvEditFile: TMenuItem;
      dvParse: TMenuItem;
      dvRemove: TMenuItem;
      N6: TMenuItem;
      dvClearAll: TMenuItem;
      dvLoad: TMenuItem;
      dvSave: TMenuItem;
      XPanel: TPanel;
      VBPanel: TPanel;
      GlobalProgressBar: TGauge;
      LocalProgressBar: TGauge;
    xrpStatusBar: TStatusBar;
      MacrosEditMenu: TMenuItem;
      Shedule: TMenuItem;
      SheduleMenu: TMenuItem;
      MActivate: TMenuItem;
      N7: TMenuItem;
      MainPanel: TPanel;
      IncSourceMenu: TMenuItem;
      OptionsList: TImageList;
      CaseSensMenu: TMenuItem;
      WholeWordMenu: TMenuItem;
      PromptMenu: TMenuItem;
      N9: TMenuItem;
      dvRedirect: TMenuItem;
      N10: TMenuItem;
      wsRedirect: TMenuItem;
      InterruptPanel: TPanel;
      AddCancel: TSpeedButton;
      xoRegister: TSpeedButton;
      StringGrid1: TStringDropGrid;
      CommandPanel: TPanel;
      SBGo: TSpeedButton;
      sbOptions: TSpeedButton;
      SbFullSave: TSpeedButton;
      SBQuit: TSpeedButton;
      rowOptionsMenu: TMenuItem;
      AttemptPaste: TMenuItem;
      AttemptCopy: TMenuItem;
      StatusLabel: TLabel;
      dvClearModif: TMenuItem;
      N12: TMenuItem;
      RGridMenu: TPopupMenu;
      ShowRowStatistics1: TMenuItem;
      ClearRowStatistics1: TMenuItem;
      Rows1: TMenuItem;
      Grid1: TMenuItem;
      N5: TMenuItem;
      N8: TMenuItem;
      Clipboard1: TMenuItem;
      Statistics1: TMenuItem;
      N11: TMenuItem;
      RowStats: TMenuItem;
      iNternet: TSpeedButton;
      SBPreview: TSpeedButton;
      dvStats: TMenuItem;
      Preview1: TMenuItem;
      DPanel: TPanel;
      cmdMinusImage: TImage;
      cmdPlusImage: TImage;
      FileListBox1: TPicFileListBox;
      TreeView1: TDropView;
      ShellSpace: TShellView;
      LSplit: TSplitter;
      RSplit: TSplitter;
      filterPanel: TPanel;
      FilterComboBox1: TFilterComboBox;
    VSplitter: TSplitter;
    EditMenu: TPopupMenu;
    Edit1: TMenuItem;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    SelectAll1: TMenuItem;
    N13: TMenuItem;
    ShowTotals1: TMenuItem;
    EnableDisableRow: TMenuItem;
    RowInterline: TMenuItem;
    N14: TMenuItem;
    RegExpToggle: TSpeedButton;
    mnuAssumeRegExp: TMenuItem;
    FilesPopup: TPopupMenu;
    popRefresh: TMenuItem;
    N15: TMenuItem;
    Properties1: TMenuItem;
    IntroWindow: TMenuItem;
    xrLoadAll: TMenuItem;
    TopButtonPanel: TPanel;
    SBDragDrop: TSpeedButton;
    sbWildCardDrop: TSpeedButton;
    SBWildCard: TSpeedButton;
    SBRemoveAll: TSpeedButton;
    SBffClearAdd: TSpeedButton;
    SBffRemove: TSpeedButton;
    SBffAdd: TSpeedButton;
    SBTreeViewLoad: TSpeedButton;
    SBTreeViewSave: TSpeedButton;
    sbRedirect: TSpeedButton;
    MacroEditor: TSpeedButton;
    SheduleMacros: TSpeedButton;
    ShedActivate: TSpeedButton;
    BottomButtonPanel: TPanel;
    sbRpDisable: TSpeedButton;
    TabCopy: TSpeedButton;
    TabPaste: TSpeedButton;
    sbRpPrompt: TSpeedButton;
    sbRpWholeOnly: TSpeedButton;
    sbRpCaseSens: TSpeedButton;
    sbRpInclude: TSpeedButton;
    SBRpSplitRight: TSpeedButton;
    sbRpReverse: TSpeedButton;
    SBRpSplitLeft: TSpeedButton;
    SbRpClear: TSpeedButton;
    SBrpSave: TSpeedButton;
    SBrpLoad: TSpeedButton;
    sbRpInsertLine: TSpeedButton;
    SBrpRemove: TSpeedButton;
    ButtonBarsLabel: TLabel;
    ReplaceHintLabel: TLabel;
    btnExpandButtons: TSpeedButton;
    btnContractButtons: TSpeedButton;
    BBffDust: TImage;
    dvExpand: TMenuItem;
    dvClearRedirect: TMenuItem;
      procedure FilterComboBox1Change(Sender: TObject);
      procedure ListBox1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
      procedure FormCreate(Sender: TObject);
      procedure SBDragDropClick(Sender: TObject);
      procedure SBWildCardClick(Sender: TObject);
      procedure SBRemoveAllClick(Sender: TObject);
      procedure SBTreeViewLoadClick(Sender: TObject);
      procedure SBTreeViewSaveClick(Sender: TObject);
      procedure SBrpLoadClick(Sender: TObject);
      procedure SBrpSaveClick(Sender: TObject);
      procedure SBrpRemoveClick(Sender: TObject);
      procedure SBffClearAddClick(Sender: TObject);
      procedure SBffRemoveClick(Sender: TObject);
      procedure SBffAddClick(Sender: TObject);
      procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
      procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure BBffDustClick(Sender: TObject);
      procedure BBffDustDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
      procedure BBffDustDragDrop(Sender, Source: TObject; X, Y: Integer);
      procedure AddCancelClick(Sender: TObject);
      procedure SBGoClick(Sender: TObject);
      procedure Go1Click(Sender: TObject);
      procedure SBQuitClick(Sender: TObject);
      procedure TerminateXReplace(Force: boolean);
      procedure Quit1Click(Sender: TObject);
      procedure MyExceptionHandler(Sender: TObject);
      procedure MyExceptionHandlerStr(iStr: string);
      procedure StringGrid1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
      procedure StringGrid1DragDrop(Sender, Source: TObject; X, Y: Integer);
      procedure Help2Click(Sender: TObject);
      procedure AboutXReplace321Click(Sender: TObject);
      procedure FileListBox1DblClick(Sender: TObject);
      procedure SbRpClearClick(Sender: TObject);
      procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure StringGrid1TopLeftChanged(Sender: TObject);
      procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Longint; ARect: TRect; State: TGridDrawState);
      procedure SBRpSplitLeftClick(Sender: TObject);
      procedure StringGrid1SelectCell(Sender: TObject; Col, Row: Longint; var CanSelect: Boolean);
      procedure StringGrid1KeyPress(Sender: TObject; var Key: Char);
      procedure TreeView1DropFinished(Sender: TObject);
      procedure TreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
      procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure FillContainer(ContainerHandle: integer; xRepHeader: array of char);
      procedure SbFullSaveClick(Sender: TObject);
      procedure sbRpReverseClick(Sender: TObject);
      procedure EditOptionsClick(Sender: TObject);
      procedure sbRpInsertLineClick(Sender: TObject);
      procedure Replacements1Click(Sender: TObject);
      procedure SBRpSplitLeftMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure wsDragDropClick(Sender: TObject);
      procedure Register1Click(Sender: TObject);
      procedure dvEditFileClick(Sender: TObject);
      procedure dvParseClick(Sender: TObject);
      procedure dvRemoveClick(Sender: TObject);
      procedure TreeView1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure GripPanelMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
      procedure XPanelResize(Sender: TObject);
      procedure FormResize(Sender: TObject);
      procedure MacrosEditMenuClick(Sender: TObject);
      procedure SheduleClick(Sender: TObject);
      procedure MActivateClick(Sender: TObject);
      procedure TreeView1Changing(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
      procedure sbRpIncludeClick(Sender: TObject);
      procedure sbRpCaseSensClick(Sender: TObject);
      procedure sbRpWholeOnlyClick(Sender: TObject);
      procedure StringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
      procedure sbRpPromptClick(Sender: TObject);
      procedure DropViewPopupPopup(Sender: TObject);
      procedure Fileselection1Click(Sender: TObject);
      procedure dvRedirectClick(Sender: TObject);
      procedure TreeView1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure RPanelResize(Sender: TObject);
      procedure OpenDialog2Close(Sender: TObject);
      procedure OpenDialog1Close(Sender: TObject);
      procedure TabPasteClick(Sender: TObject);
      procedure TabCopyClick(Sender: TObject);
      procedure StringGrid1EndDrag(Sender, Target: TObject; X, Y: Integer);
      procedure SecretButton1Click(Sender: TObject);
      procedure SBRpSplitRightMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure SBRpSplitRightClick(Sender: TObject);
      procedure dvClearModifClick(Sender: TObject);
      procedure rShowStatsClick(Sender: TObject);
      procedure rClearStatsClick(Sender: TObject);
      procedure iNternetClick(Sender: TObject);
      procedure SBPreviewClick(Sender: TObject);
      procedure dvStatsClick(Sender: TObject);
      procedure TreeView1KeyPress(Sender: TObject; var Key: Char);
      procedure filterPanelResize(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure ShellSpaceMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure ShellSpaceChange(Sender: TObject; Node: TTreeNode);
      procedure TreeView1Expanded(Sender: TObject; Node: TTreeNode);
      procedure TreeView1Collapsed(Sender: TObject; Node: TTreeNode);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure ShowTotals1Click(Sender: TObject);
    procedure Rows1Click(Sender: TObject);
    procedure RGridMenuPopup(Sender: TObject);
    procedure sbRpDisableClick(Sender: TObject);
    procedure FileListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RegExpToggleClick(Sender: TObject);
    procedure mnuAssumeRegExpClick(Sender: TObject);
    procedure StatusLabelDblClick(Sender: TObject);
    procedure popRefreshClick(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure IntroWindowClick(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure xrLoadAllClick(Sender: TObject);
    procedure btnExpandButtonsClick(Sender: TObject);
    procedure btnContractButtonsClick(Sender: TObject);
    procedure dvExpandClick(Sender: TObject);
    procedure dvClearRedirectClick(Sender: TObject);
   public
      Operation : TROperation;
      EditText : TSpaceMemo;
      DraggingOver: boolean;
      LoadedStringGrid: string;
      LoadedFileList: string;
      LoadedFullState: string;
      {$ifndef Registered}
      TillExpired: integer;
      {$else}
      mustTerminate: boolean;
      {$endif}
      QuitNoQuery: boolean;
      ForceNotPermanentResponse: boolean;
      MacroLine: integer;
      ErrorMessages: boolean;
      CurrentStats, ReplaceStats: TStatistics;
      ReplaceLog : TLog;
      InterruptReplace: boolean;
      MyreplaceThread: ReplaceThread;
      function LoadContainer(ContainerName: string): boolean;
      function  CheckGridValid: boolean;
      procedure DisableEverything;
      procedure SetGridEdit;
      procedure EnableEverything;
      function  ContainerVersion(FileHandle:integer):longint;
      procedure AddCellProps;
      procedure ClearCellProps;
      procedure CloseEditText;
      procedure OpenEditText(iShow: boolean);
      {$ifdef Registered}
      procedure UpdateRegExpState;
      procedure SortGrid(Cat: integer);
      function MacroExecuteLine(iCommand: string; Serious: boolean): boolean;
      function MacroExecute(iFileName: string; Serious: boolean): boolean;
      {$endif}
      function GetSideStr(Row: LongInt; Col: integer): string;
      function GetLeftSide(Row: LongInt): string;
      function GetLeftSplitSide(Row: LongInt): string;
      function GetRightSide(Row: LongInt): string;
      function GetRightSplitSide(Row: LongInt): string;
      procedure SetLeftSide(Row: LongInt; iStr: string);
      procedure SetLeftSplitSide(Row: LongInt; iStr: string);
      procedure SetRightSide(Row: LongInt; iStr: string);
      procedure SetRightSplitSide(Row: LongInt; iStr: string);
      procedure ExtractRow(Row: LongInt);
      procedure InsertGridRow(iRow: LongInt);
      function CountSplit: integer;
      function LoadTree(ContainerName: string): boolean;
      function GetSource(ANode: TTreeNode): string;
      function GetTarget(ANode: TTreeNode): string;
      procedure SetOFound(ANode: TTreeNode; Found: LongInt);
      procedure SetOReplaced(ANode: TTreeNode; Replaced: LongInt);
      function GetOFound(ANode: TTreeNode): LongInt;
      function GetOReplaced(ANode: TTreeNode): LongInt;
      procedure GetOModifiedFiles(ANode: TTreeNode; var nModifiedCount, nTotalCount: LongInt);
      procedure SetSource(ANode: TTreeNode; iStr: string);
      procedure SetTarget(ANode: TTreeNode; iStr: string);
      procedure SetNodeType(ANode: TTreeNode; AType: NodeType);
      function GetNodeType(ANode: TTreeNode): NodeType;
      //function FullToLFN(AName: string): string;
      procedure StringGrid1Resize;
      procedure ToggleSplit(Sender: TObject; Col: LongInt);
      function GetSide(Row, Col: LongInt; Split: boolean): string;
      procedure LaunchHtml(iStr: string);
      procedure ShowIntroForm(EnableTimer: boolean);
      procedure ShowHelp(Url: string);
   private
      isChanging: boolean;
      HtmlBrowser: string;
      //drag over and anchor drop
      {$ifndef Registered}
      Expired: boolean;
      {$endif}
      dChanging: boolean;
      anchorRow: LongInt;
      anchorDragRow: LongInt;
      anchorDragging: boolean;

      PerformingCopyPaste: boolean;
      InterruptCopyPaste: boolean;

      iWaitState: TWorking;
      iWaitRunning: boolean;
      StopLoadingContainer: boolean;

      LoadingContainer: boolean;
      PerformingReplace: boolean;
      (*{$ifdef Registered} NumChoose: TNumChoose; {$endif}*)
      InitProcess:Boolean;
      ReplaceAll: boolean;
      //PluginManager: TXRPluginManager;
      {$ifndef Registered}
      procedure SharewareNag;
      {$else}
      procedure xReplaceInternalRegExp(var ReadLine:string;i:integer);
      {$endif}
      procedure UpdateGrid;
      procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GetMinMaxInfo;
      procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
      function LoadContainer0000(ContainerFileHandle:integer): boolean;
      function LoadContainer0100(ContainerFileHandle:integer): boolean;
      function LoadContainer0150(ContainerFileHandle:integer): boolean;
      function LoadContainer0151(ContainerFileHandle:integer): boolean;
      function LoadContainer0152(ContainerFileHandle:integer): boolean;
      function LoadContainer0153(ContainerFileHandle:integer): boolean;
      function LoadContainer0154(ContainerFileHandle:integer): boolean;
      function LoadContainer0155(ContainerFileHandle:integer): boolean;
      procedure CompactGrid;
      procedure PrepareLoadforGrid;
      function  ReadLine(ContainerFileHandle: integer;var buffer: string):integer;
      function  ReadInteger(var ContainerFileHandle:integer):integer;
      function  HandleEof(FileHandle: integer):boolean;
      function  HandleEofSize(FileHandle: integer; FSize: LongInt): boolean;
      function  FunctionSBffAddClick(Sender: TObject; var LocalFilterCombo: TfilterComboBox):integer;
      function  xReplace(ReadLine:string):string;
      procedure xReplaceInternal(var ReadLine:string;i:integer);
      procedure DisableVirtuallyEverything;
      procedure EnableVirtuallyEverything;
      procedure MakeVisible(TheRow: LongInt);
      function TreeLoad(FileName: string; NoPanic: boolean): boolean;
      procedure RemoveRow(const iRow: LongInt);
      procedure InsertRow(const iRow: LongInt);
      function AllEmpty(const i : LongInt): boolean;
      function LoadGrid0157(ContainerFileHandle: integer): boolean;
      function LoadGrid0172(ContainerFileHandle: integer): boolean;
      procedure FillGrid0172(ContainerFileHandle: integer; Item: TTreeNode; LocalId: integer);
      procedure FileExecute(FileName: string);
      procedure UpdateSpecialConditions;
      procedure AppendToSystemMenu (Form: TForm; Item: string; ItemID: word);
      procedure RegisterMsg (var Msg: TMsg; var Handled: boolean);
      function GetFullRedirection(ANode: TTreeNode): string;
      procedure InitGridContents(Row: integer);
      function ForceMkDir(ANode: string): boolean;
      procedure WildCardSelect(Prompt: boolean; sFilter: string);
      procedure WildCardDrop(Prompt: boolean; sFilter: string);
      function FileHandleSize(FileHandle: integer): LongInt;
      function FileHandlePos(FileHandle: integer): LongInt;
      procedure PrepareLoadGrid(var CurrentRow: LongInt);
      procedure PrepareRowStats(Sender: tObjecT);
      procedure MergeToPopup(Source, Target: TMenuItem);
      procedure PerformReplacements;
      procedure CountOccur(aNode: TTreeNode; var OFound, OReplaced: LongInt);
      procedure ResetGridHeader;
      procedure UpdateInterfacePerOptions;
   end;

var
   XReplaceOptions: TOptions;
   VirtuallyDisabled: integer = 0;
   MyNode: TTreeNode;
   xRepl32: TxRepl32;
   myFileMask: string;
   FormHeight: integer;
   FormWidth: integer;
   GridWidth:integer;
   TreeWidth:integer;
   GRRowWidth:integer;
   GPCounter:integer;
   BackupFileOverwrite:Boolean;
   ReplaceAllCurrent: boolean;
   DontReplaceCurrent: boolean;
   GlobalFileName: string;
   GridContents: PSuperLongArray;
   GridCount: LongInt;
   WinDir: PChar;
   FileAttributeCareLocal: boolean;
   FileLogString: string;

const
   LoadAppend: boolean=False;
   TreeAppend: boolean=False;
   MySeparator:array[0..10] of char = 'ø';
   XRversionId: string = '231060700';
   XRVersion: string ='XReplace-32 2.32';
   XRBuild : string = '2.32.0201.0';

implementation

{$ifdef Registered}
uses batch, macro, xshedule, actives, redirect;
function Search(iString: PChar; sSearchExp: PChar; sReplaceExp: PChar; var nPos: integer; var offset: integer; var replacelen: integer; var pReplaceStr: PChar; var Error: PChar): integer; cdecl external 'RegDll.dll' name 'Search';
{$endif}

{$R *.DFM}

procedure TxRepl32.MyExceptionHandlerStr(iStr: string);
begin
     ReplaceLog.oLog(IntToStr(GetLastError)+':'+ErrorRaise(GetLastError) + '- unexpected runtime exception error with '+iStr,'',XReplaceOptions.Log.Everything);
     if ErrorMessages then
     If (MsgForm.MessageDlg('Unexpected runtime exception error with '+iStr+'.',
               'XReplace-32 has raised an unexpected exception, this means an error has occured. '+
               'Please report the most exact circumstances when this has happenned to dblock@vestris.com. You should restart XReplace-32. Choosing Abort will terminate XReplace.',
               mtError,[mbIgnore]+[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError)))=mrAbort then Application.Terminate; {$IFDEF Debug}DebugForm.Debug('TxRepl32.Exception Raised.');{$ENDIF}
     end;

procedure TxRepl32.MyExceptionHandler(Sender: TObject);
begin
   If InitProcess=True then exit;
   if Application.Terminated then exit;
   ReplaceLog.oLog(IntToStr(GetLastError)+':'+ErrorRaise(GetLastError) + '- unexpected runtime exception error with '+Sender.ClassName,'',XReplaceOptions.Log.Everything);
   if ErrorMessages then
   If (MsgForm.MessageDlg('Unexpected runtime exception error with '+Sender.ClassName+'.',
               'XReplace-32 has raised an unexpected exception, this means an error has occured. '+
               'Please report the most exact circumstances when this has happenned to dblock@vestris.com. You should restart XReplace-32. Choosing Abort will terminate XReplace.',
               mtError,[mbIgnore]+[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError)))=mrAbort then Application.Terminate; {$IFDEF Debug}DebugForm.Debug('TxRepl32.Exception Raised:'+Sender.ClassName);{$ENDIF}
   end;

procedure TxRepl32.FilterComboBox1Change(Sender: TObject);
begin
   try
      FileListBox1.Mask := FilterComboBox1.Mask;
      FileListBox1.PublicUpdate;
      myFileMask:=FileListBox1.Mask;                                              {$IFDEF Debug}DebugForm.Debug('TxRepl32.FilterComboBox1Change:'+Sender.ClassName+'..'+FilterComboBox1.Filter);{$ENDIF}
      Remove2.Caption := 'Remove ' + myFileMask;
      ReplaceLog.oLog('filter set to '+ myFileMask,'interface',XReplaceOptions.Log.Rare);
   except
      FileListBox1.Mask:=myFileMask;                                              {$IFDEF Debug}DebugForm.Debug('TxRepl32.FilterComboBox1Change:Exception Raised:'+Sender.ClassName);{$ENDIF}
   end;
   end;

procedure TxRepl32.ListBox1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
   try
      if (Source is TFileListBox) or (Source is TDirectoryListBox) then Accept:=True else Accept:=False;
   except
      Accept:=False;
      MyExceptionHandler(Sender);
   end;
   end;

(*
function TxRepl32.FullToLFN(AName: string): string;

      function AlternateToLFN(alternateName: String): String;
      var
         temp: TWIN32FindData;
         searchHandle: THandle;
      begin
         searchHandle := FindFirstFile(PChar(alternateName), temp);
         if searchHandle <> ERROR_INVALID_HANDLE then
            result := String(temp.cFileName)
            else
            result := '';
            Windows.FindClose(searchHandle);
         end;

      function PartialLFN(AName: string): string;
      var
         i, SPos: integer;
      begin
      try
         SPos:=0;
         aName := nBs(aName);
         for i:=Length(AName) downto 1 do
           if AName[i]='\' then begin
             SPos:=i;
             break;
             end;

         if Length(AName) > 1 then
         if (SPos = 1) or (SPos = 2) and (Aname[1] = '\') and (AName[2] = '\') then begin
            Result := ANamE;
            exit;
            end;
         if SPos<>0 then Result:=FullToLFn(Copy(AName, 1, SPos-1))+'\'+
                                 ExtractFileName(AlterNateToLFN(AName)) else
                                 Result:=AName;                                     {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate.Full2LFN::result: '+Aname+' -> '+Result);{$ENDIF}

      except
         Result:=AName;
         exit;
      end;
      end;
begin
     Result:=PartialLFN(Trim(AName));
     end;
     *)

{$ifndef Registered}
procedure TxRepl32.SharewareNag;
begin
     MsgForm.MessageDlg('XReplace-32 shareware release has expired. No replacements will be possible.',
                                 'The Shareware agreement allows you to use XReplace-32 for a period of '+IntToStr(ShareWareMax)+' days. '+
                                 'You now have to register XReplace-32 if you continue to use it. You may also download the latest shareware release and register online at '+
                                 'http://www.vestris.com.', mtError, [mbOk], 0, '');
     TillExpired := ShareWareMax;
     Expired:=True;
     end;
{$endif}

procedure TxRepl32.FormCreate(Sender: TObject);
   procedure InitBrowser;
   var
      TmpHtmlDocument: PChar;
      TmpHtmlDocumentExt: string;
      BrowserStr : PChar;
   begin
     try
     HtmlBrowser := '';
     iNternet.Hint := iNternet.Hint + #13#10 + 'http://www.vestris.com';
     TmpHtmlDocument := StrAlloc(MAX_PATH);
     if GetTempFileName(PChar(TempPath), 'ucs', 0, TmpHtmlDocument) <> 0 then begin
        TmpHtmlDocumentExt := ChangeFileExt(TmpHtmlDocument, '.html');
        RenameFile(TmpHtmlDocument, TmpHtmlDocumentExt);
        BrowserStr := Stralloc(MAX_PATH);
        if FindExecutable(PChar(TmpHtmlDocumentExt),PChar(ExtractFileDir(Application.ExeName)), BrowserStr) > 32 then begin
           HtmlBrowser := BrowserStr;
           if not FileExists(HtmlBrowser) then HtmlBrowser:='';
           end;
        DeleteFile(TmpHtmlDocumentExt);
        end;
     if HtmlBrowser = '' then iNternet.Visible := False;
     except
        HtmlBrowser := '';
        iNternet.Visible := False;
        MyExceptionHandlerStr('InitBrowser');
     end;
     end;
   procedure RegisterXRClass;
   begin
      try
        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Container\', '', 'XReplace-32 Full State Container');
        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Container\DefaultIcon', '', Application.ExeName + ',0');
        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Container\Shell\', '', 'Open');
        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Container\Shell\Open\Command', '', Application.ExeName + ' "%1" -noexec -noquit');
        AddReg(HKEY_CLASSES_ROOT, '\.xpl', '', 'XReplace-32 Container');
        AddReg(HKEY_CLASSES_ROOT, '\.rpl', '', 'XReplace-32 Container');

        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Macro\', '', 'XReplace-32 Automation Macro');
        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Macro\DefaultIcon', '', Application.ExeName + ',0');
        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Macro\Shell\', '', 'Open');
        AddReg(HKEY_CLASSES_ROOT, '\XReplace-32 Macro\Shell\Open\Command', '', Application.ExeName + ' "%1"');
        AddReg(HKEY_CLASSES_ROOT, '\.xrm', '', 'XReplace-32 Macro');
        except
           MyExceptionHandlerStr('RegisterXRClass');
        end;
        end;
  {$ifndef Registered}
   procedure AddRevisionDate;
   var
      FirstRunDate: LongInt;
      Year, Mon, Day: Word;
   begin
        try
        DecodeDate(Now, Year, Mon, Day);
        FirstRunDate:=Day + Mon * 100 + Year * 10000;
        AddReg(HKEY_CURRENT_USER,   '\Console\Revision Data\_vxdr',
                                       XRVersionID,
                                       FirstRunDate);
        except
           MyExceptionHandlerStr('AddRevisionDate');
        end;
        end;
   function ElapsedDays(First, Second: TDateTime): LongInt;
   var
      aYear, aMon, aDay,
      bYear, bMon, bDay: word;
      internal1, internal2: LongInt;
      jnum: real;
      cd: integer;
      sOut: string;

      function Jul( mo, da, yr: integer): real;
      var
         i, j, k, j2, ju: real;
      begin
           i := yr;     j := mo;     k := da;
           j2 := int( (j - 14)/12 );
           ju := k - 32075 + int(1461 * ( i + 4800 + j2 ) / 4 );
           ju := ju + int( 367 * (j - 2 - j2 * 12) / 12);
           ju := ju - int(3 * int( (i + 4900 + j2) / 100) / 4);
           Jul := ju;
           end;
      begin
        try
        DecodeDate(First, aYear, aMon, aDay);
        DecodeDate(Second, bYear, bMon, bDay);
        jnum:=jul(aMon,aDay,aYear);
        str(jnum:10:0,sOut);
        val(sOut,internal1,cd);
        jnum:=jul(bMon,bDay,bYear);
        str(jnum:10:0,sOut);
        val(sOut,internal2,cd);
        Result:=internal1-internal2;
        except
        AddRevisionDate;
        Result:=0;
        end;
        end;
   
   procedure ExpirationManager;
   var
      FirstRunDate: LongInt;
      aDate: TDateTime;
      Year, Mon, Day: Word;
   begin
        try
        Expired:=False;
        try
         FirstRunDate := QueryReg(
            HKEY_CURRENT_USER,
            '\Console\Revision Data\_vxdr',
            XRVersionId);
        except
         FirstRunDate := 0;
        end;

        if FirstRunDate = -3 then begin
           SharewareNag;
           end else
        if FirstRunDate > 0 then begin
           try
           Year:=FirstRunDate div 10000;
           Mon:=FirstRunDate div 100 - Year * 100;
           Day:=FirstRunDate - Year * 10000 - Mon * 100;
           aDate:=EncodeDate(Year, Mon, Day);
           if (Now < aDate) then tillExpired := ShareWareMax + 1
           else tillExpired:=ElapsedDays(Now, aDate);
           //ShowMessage(IntToStr(15 - eDays) + ' left till expiration.');
           if tillExpired > ShareWareMax then begin
              AddReg(
                  HKEY_CURRENT_USER,
                  '\Console\Revision Data\_vxdr',
                  XRVersionID,
                  -3);
              SharewareNag;
              end;
           except
           AddRevisionDate;
           end;
           end else begin
           AddRevisionDate;
           end;
        except
           MyExceptionHandlerStr('EManager');
        end;
        end;

   procedure DeHint(Abutton: TSpeedButton);
   begin
      try
        with aButton do begin
             Enabled:=False;
             //Visible := False;
             Hint:=Hint + #13#10 + '(registered version only)';
             end;
        except
           MyExceptionHandlerStr('DeHint/' + AButton.Name);
        end;
        end;
   {$endif}

   procedure InitEditText;
   begin
         try
         EditText:=TSpaceMemo.Create(XPanel);                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::EditText(SpaceMemo).Create');{$ENDIF}
         CreateVersionString;                                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::VersionString.Create');{$ENDIF}
                                                                                 {$IFDEF Debug}with VersionInfo do DebugForm.Debug('TxRepl32.FormCreate::Windows Version:'+IntToStr(dwMajorVersion)+'.'+IntToStr(dwMinorVersion)+'/'+IntToStr(dwPlatFormId));{$ENDIF}
         UpdateSpecialConditions;
         with EditText do begin
              {check for NT 3.5x bug}
              if (VersionInfo.dwMajorVersion=3) and
                 (VersionInfo.dwPlatformId=2) and
                 ((VersionInfo.dwMinorVersion=51) or
                 (VersionInfo.dwMinorVersion=50)) then NtBug:=True else NtBug:=False; {$IFDEF Debug}DebugForm.Debug('TSpaceMemo::EditText::NT 3.5 bug assumed as '+BoolToStr(NTBug));{$ENDIF}

         EditText.PopupMenu := RGridMenu;

         EditLSLeft:=False;
         EditLSRight:=False;
         EditRSLeft:=False;
         EditRSRight:=False;

         WordWrap:=False;
         Visible:=False;
         WantTabs:=True;
         Font:=StringGrid1.font;
         ItemHeight:=GetItemHeight(Font);
         Tag:=0; //32;
         OnChange:=EditChange;
         OnKeyPress:=EditKeyPress;
         OnKeyDown:=EditKeyDown;
         OnKeyUp:=EditKeyUp;
         OnDragOver:=StringGrid1DragOver;
         OnDragDrop:=StringGrid1DragDrop;
         OnMouseMove:=EditMouseMove;
         end;
         XPanel.InsertControl(EditText);                                            {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::EditText.Insert:ok');{$ENDIF}
         except
               MyExceptionHandlerStr('InitEditText');
         end;
      end;
   procedure DragAcceptFileFromFileManager;
   begin
        try
        DragAcceptFiles(TreeView1.Handle, True);
        DragAcceptFiles(StringGrid1.Handle, True);
        except
           MyExceptionHandlerStr('DragAcceptFiles');
        end;
        end;
   procedure GetWinDir;
   begin
        try
          WinDir:=StrAlloc(MAX_PATH);
          GetWindowsDirectory(WinDir,MAX_PATH-1);                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::WindowsDirectory: '+WinDir);{$ENDIF}
        except
          MyExceptionHandlerStr('GetWinDir');
        end;
        end;
   procedure CreateReplaceLog;
   begin
        try
        ReplaceLog:=TLog.Create;                                                   {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::TLog.Create');{$ENDIF}
        ReplaceLog.Init(XReplaceOptions.Log);                                      {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::TLog.Init');{$ENDIF}
        ReplaceLog.oLog(XRVersion+' '+ XRBuild + ' successfully initialized.','',XReplaceOptions.Log.Everything);
        except
        {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::TLog.Init::Unexpected Exception Raised.');{$ENDIF}
           MyExceptionHandlerStr('CreateReplaceLog');
        end;
        end;
(*   procedure UpdateImageList1;
   begin
        {imagelist directory image}
        try
        with ImageList1 do begin
             AddIcon(Image2.Picture.Icon);
             AddIcon(Image2.Picture.Icon);
             AddIcon(Image1.Picture.Icon);
             AddIcon(Image3.Picture.Icon);
             end;                                                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::ImageList1:ok');{$ENDIF}
        except
        {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::ImageList1::Unexpected Exception Raised.');{$ENDIF}
        end;
        end;*)

   {$ifdef Registered}
   procedure InitStatusCopy;
   begin
        //NumChoose:=TnumChoose.Create(xrpStatusBar, xrpStatusBar.Panels[2]);
        end;
   {$endif}

   {
   procedure InitPluginManager;
   begin
        PluginManager := TXRPluginManager.Create;
        end;
        }

begin
     //---
     try
     InitProcess := True;
     initMdlg;
     {$ifndef Registered}
     ExpirationManager;
     {$endif}

{     MergeToPopup(EditMenu.Items, RGridMenu.Items);
     MergeToPopup(Replacements1, RGridMenu.Items);}

     RegisterXRClass;
     InitBrowser;
     dChanging:=False;
     InitEditText;
     //Win95Browser.Visible := not EditText.NTBug;
     DragAcceptFileFromFileManager;
     GetWinDir;

     TXOptions.QueryOptions;                                                        {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::QueryOptions returned');{$ENDIF}

     CreateReplaceLog;
     //UpdateImageList1;

     TreeView1.DropTerminated:=True;                                               {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::DropTerminated:ok');{$ENDIF}
     StopLoadingContainer:=False;
     LoadingContainer:=False;
     iWaitRunning:=False;
     PerformingReplace:=False;
     PerformingCopyPaste:=False;
     InterruptReplace:=False;
     QuitNoQuery := False;

     LoadedStringGrid:='';
     LoadedFileList:='';
     LoadedFullState:='';
     DraggingOver:=False;

     Application.HelpFile := ExtractFilePath(Application.ExeName) + 'docs\index.html';

     GridContents:=nil;
     GridCount:=0;                                                                 {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::SplitRows MemAlloc succeeded.');{$ENDIF}

     DragAcceptFiles(EditText.Handle, True);

     myFileMask:=FileListBox1.Mask;

     ClearCellProps;
     //InitPluginManager;

     //with FiltercomboBox1 do begin
     //     Clear;
     //     Filter:='(*.*)|*.*';
     //     end;                                                                     {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::FilterComboBox:ok');{$ENDIF}

     Caption:=XRVersion + ' Webmaster''s Choice';
     FormHeight:=xRepl32.Height;
     FormWidth:=xRepl32.Width;
     GridWidth:=StringGrid1.Width;
     TreeWidth:=TreeView1.Width;
     GRRowWidth:=StringGrid1.ColWidths[0];

     AppendToSystemMenu(XRepl32, '-', 0);  {Separator bar}
     anchorDragging:=False;

     {$ifdef Registered}
     mustTerminate := False;
     xrpStatusBar.Panels[0].Text:='Registered version of XReplace-32.';                                    {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
     RegExpToggle.Down := XReplaceOptions.Repl.RegExp;
     UpdateRegExpState;
     Help1.Caption := 'About and Help';
     xoRegister.Visible := False;
     Register1.Visible := False;
     {$else}
     xrpStatusBar.Panels[0].Text:='XReplace-32 is NOT freeware. Please register! Check help for details.';                                    {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
     AppendToSystemMenu(XRepl32, '&Register XReplace-32', 99);

     DeHint(MacroEditor);
     DeHint(ShedActivate);
     DeHint(SheduleMacros);
     DeHint(sbRpWholeOnly);
     DeHint(sbRpCaseSens);
     DeHint(sbRpPrompt);
     DeHint(sbRpInclude);
     DeHint(sbRpSplitRight);
     DeHint(sbRedirect);
     DeHint(TabPaste);
     DeHint(TabCopy);
     DeHint(SBPreview);
     DeHint(sbRpDisable);
     DeHint(RegExpToggle);

     {$IFDEF Debug}DebugForm.Debug('Finished dehinting menu items.');{$ENDIF}

     RowInterLine.Enabled := False;
     EnableDisableRow.Enabled := False;
     Preview1.Enabled := False;
     MacrosEditMenu.Enabled:=False;
     SheduleMenu.Enabled:=False;
     CaseSensMenu.Enabled:=False;
     PromptMenu.Enabled:=False;
     IncSourceMenu.Enabled:=False;
     WholeWordMenu.Enabled:=False;
     dvRedirect.Enabled:=False;
     dvClearRedirect.Enabled:=False;
     wsRedirect.Enabled:=False;
     TabPaste.Enabled:=False;
     TabCopy.Enabled:=False;
     AttemptCopy.Enabled:=False;
     AttemptPaste.Enabled:=False;                                                {$IFDEF Debug}DebugForm.Debug('Finished enabling menu items.');{$ENDIF}
     mnuAssumeRegExp.Enabled := False;
     {$endif}

     AppendToSystemMenu(XRepl32, '&About XReplace-32', 199);                     {$IFDEF Debug}DebugForm.Debug('Appended about item to system menu.');{$ENDIF}
     Application.OnMessage := XRepl32.RegisterMsg;                               {$IFDEF Debug}DebugForm.Debug('Initialized message registration.');{$ENDIF}

     if XReplaceOptions.Gen.SaveExitDirectory or XReplaceOptions.Gen.RememberDirs then
        ShellSpace.Directory := XReplaceOptions.hidden.StartupDirectory
        else ShellSpace.Directory := 'C:\';
                                                                              {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::DirectoryListBox.Directory: '+ShellSpace.Directory);{$ENDIF}
     TreeView1.ShowImages := XReplaceOptions.Gen.ShowTaggedFileGlyphs;
     FileListBox1.ShowGlyphs:=XReplaceOptions.Gen.ShowFileGlyphs;               {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::ShowGlyphs.Set');{$ENDIF}
     BottomButtonPanel.Visible:=XReplaceOptions.Gen.ShowAllButtons;
     TopButtonPanel.Visible:=XReplaceOptions.Gen.ShowAllButtons;

     ReplaceHintLabel.Visible := not BottomButtonPanel.Visible;
     ButtonBarsLabel.Visible := not TopButtonPanel.Visible;
     btnExpandButtons.Visible := not TopButtonPanel.Visible;

     XPanel.Height := TXOptions.QueryRegNumber('hidden', 'intermediate', XPanel.Height);
     XRepl32.Width := TXOptions.QueryRegNumber('hidden', 'width', XRepl32.Width);
     XRepl32.Height := TXOptions.QueryRegNumber('hidden', 'height', XRepl32.Height);
     XRepl32.Left := TXOptions.QueryRegNumber('hidden', 'left', XRepl32.Left);

     XRepl32.Top := TXOptions.QueryRegNumber('hidden', 'top', XRepl32.Top);

     XRepl32.ShellSpace.Width := TXOptions.QueryRegNumber('hidden', 'dir width', XRepl32.ShellSpace.Width);
     XRepl32.DPanel.Width := TXOptions.QueryRegNumber('hidden', 'fil width', XRepl32.DPanel.Width);

     XRepl32.Resize;

     XRepl32.WindowState := TWindowState(TXOptions.QueryRegNumber('hidden', 'window state', Ord(wsNormal)));

     {entering the string grid}
     try StringGrid1MouseDown(Self, mbLeft, [], StringGrid1.CellRect(0,1).Left+1, StringGrid1.CellRect(0,1).Top+1); except end;
     {$ifdef Registered}InitStatusCopy;{$endif}
     {finished init process}                                                      {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::InitProcess successfully terminated.');{$ENDIF}
     except
     MyExceptionHandler(Sender);
     end;
     InitProcess:=False;                                                          {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::InitProcess finally terminated.');{$ENDIF}
     end;

procedure TxRepl32.EnableVirtuallyEverything;
begin
   try
      dec(VirtuallyDisabled);
      if VirtuallyDisabled <> 0 then exit;
      SBGo.Enabled:=True;
      xrSaveAll.Enabled:=True;
      SBDragDrop.Enabled:=True;
      SbWildCardDrop.Enabled:=True;
      SBWildCard.Enabled:=True;
      SBRemoveAll.Enabled:=True;
      SbRpInsertLine.Enabled:=True;
      SBffClearAdd.Enabled:=True;
      SBffRemove.Enabled:=True;
      SBffAdd.Enabled:=True;
      SBtreeViewLoad.Enabled:=True;
      SBtreeViewSave.Enabled:=True;
      Go1.Enabled:=True;
      FileSelection1.Enabled:=True;
      Flags1.Enabled:=True;
      BBffdust.Enabled:=True;
      AddCancel.Visible:=False;
      SbFullSave.Enabled:=True;                                                 {$IFDEF Debug}DebugForm.Debug('TxRepl32.EnableVirtuallyEverything');{$ENDIF}
      {$ifdef Registered}
      RegExpToggle.Enabled := True;
      SBPreview.Enabled := True;
      sbRedirect.Enabled:=True;
      MActivate.Enabled:=True;
      if MacroEdit <> nil then begin
         MacroEdit.ExecuteButton.Enabled:=True;
         MacroEdit.ShedActivate.Enabled:=True;
         MacroEdit.ActivateActivXR1.Enabled:=True;
         MacroEdit.Execute.Enabled:=True;
         end;
      if XFShedule <> nil then begin
         XfShedule.ShedActivate.Enabled:=True;
         XfShedule.ActivateActivXR1.Enabled:=True;
         end;
      ShedActivate.Enabled:=True;
      {$endif}
   except
      MyExceptionHandler(Self);
   end;
   end;

procedure TxRepl32.DisableEverything;
begin
   try
      EditOptions.Enabled:=False;
      {$ifdef Registered}
      AttemptCopy.Enabled:=False;
      AttemptPaste.Enabled:=False;
      TabPaste.Enabled:=False;
      TabCopy.Enabled:=False;
      MacroEditor.Enabled:=False;
      ShedActivate.Enabled:=False;
      SheduleMacros.Enabled:=False;
      SbRpInclude.Enabled:=False;
      sbRpSplitRight.Enabled:=False;
      SbRpCaseSens.Enabled := False;
      sbRpWholeOnly.Enabled := False;
      sbRpPrompt.Enabled := False;
      sbRpDisable.Enabled := False;
      {$endif}
      SbOptions.Enabled:=False;
      FileListBox1.Enabled:=False;
      FilterComboBox1.Enabled:=False;
      DisableVirtuallyEverything;
      SBrpSave.Enabled:=False;
      SBrpLoad.Enabled:=False;
      SBRpSplitLeft.Enabled:=False;
      SbRpReverse.Enabled:=False;
      SbrpRemove.Enabled:=False;
      StringGrid1.Enabled:=False;
      Replacements1.Enabled:=False;
      SbRpClear.Enabled:=False;
      XReplace1.Enabled:=False;
      //Win95Browser.Enabled := False;
      TreeView1.CanDelete:=False;                                               {$IFDEF Debug}DebugForm.Debug('TxRepl32.DiableEverything');{$ENDIF}
   except
      MyExceptionHandler(Self);
   end;
   end;

procedure TxRepl32.EnableEverything;
begin
   try
      {$ifdef Registered}
      AttemptCopy.Enabled:=True;
      AttemptPaste.Enabled:=True;
      TabPaste.Enabled:=True;
      TabCopy.Enabled:=True;
      MacroEditor.Enabled:=True;
      ShedActivate.Enabled:=True;
      SheduleMacros.Enabled:=True;
      SbRpInclude.Enabled:=True;
      sbRpSplitRight.Enabled:=True;
      SbRpCaseSens.Enabled := True;
      sbRpWholeOnly.Enabled := True;
      sbRpPrompt.Enabled := True;
      sbRpDisable.Enabled := True;
      {$endif}
      EditOptions.Enabled:=True;
      SbOptions.Enabled:=True;
      ShellSpace.Enabled := True;
      FileListBox1.Enabled:=True;
      FilterComboBox1.Enabled:=True;
      EnableVirtuallyEverything;
      SBrpSave.Enabled:=True;
      SBrpLoad.Enabled:=True;
      SBRpSplitLeft.Enabled:=True;
      SbRpReverse.Enabled:=True;
      SBrpRemove.Enabled:=True;
      SbRpClear.Enabled:=True;
      StringGrid1.Enabled:=True;
      Replacements1.Enabled:=True;
      XReplace1.Enabled:=True;
      //Win95Browser.Enabled := True;
      TreeView1.CanDelete:=True;                                                {$IFDEF Debug}DebugForm.Debug('TxRepl32.EnableEverything');{$ENDIF}
   except
      MyExceptionHandler(Self);
   end;
   end;

procedure TxRepl32.DisableVirtuallyEverything;
begin
   try
      inc(VirtuallyDisabled);                                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.DiableVirtuallyEverything');{$ENDIF}
      xrSaveAll.Enabled:=False;
      SBGo.Enabled:=False;
      SBDragDrop.Enabled:=False;
      SbWildCard.Enabled:=False;
      SBWildCardDrop.Enabled:=False;
      SBRemoveAll.Enabled:=False;
      SbRpInsertLine.Enabled:=False;
      SBffClearAdd.Enabled:=False;
      SBffRemove.Enabled:=False;
      SBffAdd.Enabled:=False;
      SBtreeViewLoad.Enabled:=False;
      SBtreeViewSave.Enabled:=False;
      Go1.Enabled:=False;
      FileSelection1.Enabled:=False;
      Flags1.Enabled:=False;
      BBffDust.Enabled:=False;
      AddCancel.Visible:=True;
      SbFullSave.Enabled:=False;
      {$ifdef Registered}
      RegExpToggle.Enabled := False;
      SBPreview.Enabled := False;
      sbRedirect.Enabled:=False;
      MActivate.Enabled:=False;
      if MacroEdit <> nil then begin
         MacroEdit.ExecuteButton.Enabled:=False;
         MacroEdit.ShedActivate.Enabled:=False;
         MacroEdit.ActivateActivXR1.Enabled:=False;
         MacroEdit.Execute.Enabled:=False;
         end;
      if XFShedule <> nil then begin
         XfShedule.ShedActivate.Enabled:=False;
         XfShedule.ActivateActivXR1.Enabled:=False;
         end;
      ShedActivate.Enabled:=False;
      {$endif}
      //if VirtuallyDisabled < 0 then VirtuallyDisabled:=0;
   except
      MyExceptionHandler(Self);
   end;
   end;

procedure TxRepl32.PrepareLoadforGrid;
begin
   try
      {prepare grid}
      if EditText.Visible then begin
         CloseEditText;
         EditText.Text:='';
         EditText.Visible:=False;
         end;
      with StringGrid1 do begin
         if LoadAppend=True then CompactGrid
         else begin
              ClearCellProps;
              StringGrid1.RowCount:=2;
              end;
         end; {with}                                                              {$IFDEF Debug}DebugForm.Debug('TxRepl32.PrepareLoadforGrid(succeeded):'+Self.ClassName);{$ENDIF}
   except
       MyExceptionHandler(StringGrid1);
   end;
   end;

function TxRepl32.ReadLine(ContainerFileHandle: integer; var buffer: string):integer;
var
   ch:char;
begin
   try
      Application.ProcessMessages;
      ReadLine:=0;
      buffer:='';
      while (Ord(ch)<>10) do begin
         if FileRead(ContainerFileHandle,ch,1)<>1 then begin
            ReadLine:=-1;
            break;
            end;
         if (Ord(ch)>=32) then buffer:=buffer+ch;
         end;
   except
      ReadLine:=-1;
      MyExceptionHandler(Self);
      exit;
   end;
   end;

function TxRepl32.FileHandleSize(FileHandle: integer): LongInt;
var
   FPos: LongInt;
begin
   try
   FPos:=FileSeek(FileHandle,0,1);
   Result:=FileSeek(FileHandle,0,2);
   FileSeek(FileHandle,FPos,0);
   except
   Result:=0;
   end;
   end;

function TxRepl32.FileHandlePos(FileHandle: integer): LongInt;
begin
   try
   Result:=FileSeek(FileHandle,0,1);
   except
   Result:=0;
   end;
   end;

function TxRepl32.HandleEofSize(FileHandle: integer; FSize: LongInt): boolean;
begin
     try
     Application.ProcessMessages;
     if (FileSeek(FileHandle, 0, 1) >= FSize) then Result:=True else Result:=False;
     except
     Result:=False;
     end;
     end;

function TxRepl32.HandleEof(FileHandle: integer):boolean;
var
   FSize: LongInt;
   Fpos: LongInt;
begin
   try
   //Application.ProcessMessages;
   FPos:=FileSeek(FileHandle,0,1);
   FSize:=FileSeek(FileHandle,0,2);
   if FPos=FSize then HandleEof:=True
      else HandleEof:=False;
   FileSeek(FileHandle,FPos,0);
   except
      //MyExceptionHandler(Self);
      HandleEof:=True;
   end;
end;

function TxRepl32.ReadInteger(var ContainerFileHandle:integer):integer;
var
   shortBuffer: array[0..2] of char;
   myBuffer: string;
   Sign: integer;
begin
   try
   //Application.ProcessMessages;
   myBuffer:='';

      FileRead(ContainerFileHandle,shortBuffer,1);
      if (shortBuffer[0]='-') then begin
         Sign:=-1;
         FileRead(ContainerFileHandle,shortBuffer,1);
         end else Sign:=1;

   repeat
      If (HandleEof(ContainerFileHandle)=True) then begin
         ReadInteger:=-2;
         exit;
         end;
      if (shortBuffer[0]>='0') and (shortBuffer[0]<='9') then begin
         myBuffer:=myBuffer+shortBuffer[0];
         end else
      if (shortBuffer[0]=MySeparator[0]) then begin
         ReadInteger:=StrToInt(myBuffer)*sign;
         exit;
         end else begin
            ReadInteger:=-1;
            exit;
            end;
      FileRead(ContainerFileHandle,shortBuffer,1);
      until 1=0;
   except
      ReadInteger:=-2;
      //MyExceptionHandler(Self);
      exit;
   end;
end;

function TxRepl32.ContainerVersion(FileHandle:integer):longint;
var
   ReadBuffer: array [0..11] of char;
   FileId:array[0..7] of char;
begin
     try
     FileRead(FileHandle,ReadBuffer,11);
     StrLCopy(FileId,ReadBuffer,7);
     if FileId='xRep32v' then
     ContainerVersion:=(Ord(ReadBuffer[10])-Ord('0'))+
                       (Ord(ReadBuffer[9])-Ord('0'))*10+
                       (Ord(ReadBuffer[8])-Ord('0'))*100+
                       (Ord(ReadBuffer[7])-Ord('0'))*1000
                       else
                       ContainerVersion:=-1;                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.ContainerVersion returns: '+IntToStr(Result));{$ENDIF}
     except
        ContainerVersion:=-1;
        MyExceptionHandler(Self);
     end;
end;

procedure TxRepl32.SBDragDropClick(Sender: TObject);
begin
   try
   if TreeView1.DropTerminated then begin
      ShellSpace.Directory := FileListBox1.Directory;
      TreeView1.DragDrop(ShellSpace,0,0);
      end;
   except
      MyExceptionHandler(Sender);
   end;
   end;

procedure TxRepl32.WildCardDrop(Prompt: boolean; sFilter: string);
var
   LocalFilterCombo, OldFilterCombo: TfilterComboBox;
   CanDrop: integer;
begin
   try
   if not TreeView1.DropTerminated then exit;
   LocalFilterCombo:=TFilterComboBox.Create(Application);
   with LocalFilterCombo do begin
      Visible:=False;
      Application.MainForm.InsertControl(LocalFilterCombo);
      if Prompt then Filter := '' else Filter:=sFilter;
      end;
   CanDrop:=0;
   if Prompt then CanDrop:=FunctionSBffAddClick(SBWildCard, LocalFilterCombo) else
   if (sFilter <> '') then CanDrop:=1;
   if (CanDrop = 1) then
      with TreeView1 do begin
         OldfilterCombo:=FilterCombo;
         FilterCombo:=LocalFilterCombo;
         ShellSpace.Directory := FileListBox1.Directory;
         DragDrop(ShellSpace,0,0);
         FilterCombo:=OldFilterCombo;
         end;
   LocalFilterCombo.Destroy;
   except
      MyExceptionHandler(Application);
   end;
   end;

procedure TxRepl32.WildCardSelect(Prompt: boolean; sFilter: string);
var
   LFilterComboBox: TFiltercomboBox;
   i: LongInt;
begin
   try
   if not TreeView1.DropTerminated then exit;
   LFilterComboBox:=TFilterComboBox.Create(Application);
      with LFilterComboBox do begin
         Visible:=False;
         Application.MainForm.InsertControl(LFilterComboBox);
         Filter:=sFilter;
         end;

   i := 0;
   if Prompt then i:=FunctionSBffAddClick(SBWildCard, LFilterComboBox)
   else if (sFilter <> '') then i:=1;
   if (i = 1) then
      TreeView1.ExternalDragDrop(LFilterComboBox, FileListBox1.Directory, LFilterComboBox.Mask, nil, False);
   LFilterComboBox.Destroy;
   except
      MyExceptionHandler(xRepl32);
   end;
   end;

procedure TxRepl32.SBWildCardClick(Sender: TObject);
begin
   WildCardSelect(True, '');
   end;

procedure TxRepl32.SBRemoveAllClick(Sender: TObject);
begin
     try
     if TreeView1.DropTerminated then begin
        LoadedFileList:='';
        LoadedFullState:='';
        TreeView1.NodeDelete(TreeView1.Items.GetFirstNode);
        end;
     UpdateSpecialConditions;
     except
          MyExceptionHandler(Sender);
     end;
end;

function TxRepl32.TreeLoad(FileName: string; NoPanic: boolean): boolean;
begin
   try
   Result := False;
   if not FileExists(FileName) then exit;
   xrpStatusBar.Panels[0].Text:='Loading...(cancel is unavailable)';
   xrpStatusBar.Update;                                                       {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
   Screen.Cursor := crHourglass;
   TreeView1.LoadFromFile(FileName, NoPanic);
   xrpStatusBar.Panels[0].Text:='Done.';                                {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
   Screen.Cursor := crDefault;
   Result := True;
   except
      Result := False;
      MyExceptionHandler(Self);
   end;
   end;

procedure TxRepl32.SBTreeViewLoadClick(Sender: TObject);
begin
     try
     if not TreeView1.DropTerminated then exit;
     If TreeAppend=False then begin
        if OpenDialog2.Execute=false then exit;
        XReplaceOptions.Hidden.TreeDirectory:=ExtractFilePath(OpenDialog2.FileName);
        LoadTree(OpenDialog2.FileName);
        end;                                                                     {$IFDEF Debug}DebugForm.Debug('TxRepl32.TreeView1Load:(succeeded):'+Sender.ClassName);{$ENDIF}
     UpdateSpecialConditions;
     //Treeview1.HalfExpand;
     except
        MyExceptionHandler(Sender);
        xrpStatusBar.Panels[0].Text:='Failed to load the selection tree.';   {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
        Screen.Cursor := crDefault;
     end;
end;

procedure TxRepl32.SBTreeViewSaveClick(Sender: TObject);
var
   ContainerHandle: integer;
   doPrompt: boolean;
begin
     try
     if not TreeView1.DropTerminated then exit;
     If TreeAppend=False then begin

        if Hi(GetKeyState(VK_SHIFT))=255 then begin
           if LoadedFileList <> '' then begin
              SaveDialog2.FileName:=LoadedFileList;
              doPrompt:=False;
              end else doPrompt:=True;
           end else doPrompt:=True;

             if doPrompt then if SaveDialog2.Execute=False then exit;
             If SaveDialog2.Filename='' then exit;

             iWaitState:=TWorking.Create;
             iWaitRunning:=True;

             XReplaceOptions.Hidden.TreeDirectory:=ExtractFilePath(OpenDialog2.FileName);
             xrpStatusBar.Panels[0].Text:='Saving...';
             xrpStatusBar.Update;                                                  {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
             Screen.Cursor := crHourglass;
             //TreeView1.SaveToFile(SaveDialog2.FileName);

             ContainerHandle:=FileCreate(SaveDialog2.Filename);
             if ContainerHandle <= 0 then begin
             if ErrorMessages then
             MsgForm.MessageDlg('Error creating '+SaveDialog2.FileName,
                                'XReplace-32 has reported a system error while creating a container file.'
                                ,mtError,[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
             end else begin
             if (FileWrite(ContainerHandle,XDirHeader,Length(XDirHeader))=-1) then begin
                    ReplaceLog.oLog('error writing to '+SaveDialog2.FileName,'',XReplaceOptions.Log.Everything);
                    if ErrorMessages then
                       MsgForm.MessageDlg('Error writing to '+SaveDialog2.FileName,
                                          'XReplace-32 has reported a system error while writing to a file.',mtError,[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
                       FileClose(ContainerHandle);
                       EnableEverything;
                       UpdateGrid;

                       if iWaitRunning then begin
                          iWaitState.Kill;
                          iWaitRunning:=False;
                          end;

                       exit;
                       end;

             FillGrid0172(ContainerHandle, TreeView1.Items.GetFirstNode, 0);
             FileClose(ContainerHandle);
             end;

             LoadedFullState:='';
             LoadedFileList:=SaveDialog2.FileName;

             if iWaitRunning then begin
                iWaitState.Kill;
                iWaitRunning:=False;
                end;

             xrpStatusBar.Panels[0].Text:='Done.';                           {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
             Screen.Cursor := crDefault;
     end;                                                                        {$IFDEF Debug}DebugForm.Debug('TxRepl32.TreeView1Save:(succeeded):'+Sender.ClassName);{$ENDIF}
     except
          MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.SBrpLoadClick(Sender: TObject);
begin
     try
     DisableEverything;
     if Sender = FileListBox1 then begin
        OpenDialog1.Filename:=FileListBox1.FileName;
        end else
     if Sender is TLabel then begin
        OpenDialog1.FileName:=(Sender as TLabel).Caption;
        end else begin
        {get an existing name of a file to open}
        if OpenDialog1.Execute=False then begin
           EnableEverything;
           exit;
           end;
        if OpenDialog1.Filename='' then begin
           EnableEverything;
           exit;
           end;
        end;

     if Length(OpenDialog1.FileName) <> 0 then begin
        XReplaceOptions.Hidden.ContainerDirectory:=ExtractFilePath(OpenDialog1.FileName);
        SaveDialog1.FileName:=OpenDialog1.FileName;
        LoadContainer(OpenDialog1.FileName);
        end else begin
        EnableEverything;
        end;
        
     except
        EnableEverything;
        MyExceptionHandler(Sender);
     end;
     UpdateGrid;
     EditText.EditChange(Application);
     if EditText.Showing then EditText.SetFocus;
   end;

procedure TxRepl32.SBrpSaveClick(Sender: TObject);
var
   ContainerHandle : Integer;
   doPrompt: boolean;
begin
     try

     DisableEverything;
     with StringGrid1 do begin
        CompactGrid;
        {prompt for a filename with browse}

        if Hi(GetKeyState(VK_SHIFT))=255 then begin
           if LoadedStringGrid <> '' then begin
              SaveDialog1.FileName:=LoadedStringGrid;
              doPrompt:=False;
              end else doPrompt:=True;
           end else doPrompt:=True;

        if DoPrompt then
        if SaveDialog1.Execute=False then begin
           EnableEverything;
           UpdateGrid;
           SetGridEdit;
           exit;
           end;

        if SaveDialog1.Filename='' then begin
           EnableEverything;
           UpdateGrid;
           SetGridEdit;
           exit;
           end;

        iWaitState:=TWorking.Create;
        iWaitRunning:=True;

        MakeBestUse;
        {open the container file for writing}
        OpenDialog1.FileName:=SaveDialog1.Filename;
        XReplaceOptions.Hidden.ContainerDirectory:=ExtractFilePath(OpenDialog1.FileName);

        ContainerHandle:=FileCreate(SaveDialog1.Filename);
        if ContainerHandle <= 0 then begin
           if ErrorMessages then
           MsgForm.MessageDlg('Error opening '+SaveDialog1.FileName,
                              'XReplace-32 has reported a system error while opening a file.',
                              mtError,[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
           EnableEverything;
           UpdateGrid;
           SetGridEdit;

           if iWaitRunning then begin
              iWaitState.Kill;
              iWaitRunning:=False;
              end;

           exit;
           end;

        FillContainer(ContainerHandle, XRepHeader);

        FileClose(ContainerHandle);
        if bs(FileListBox1.Directory) = bs(XReplaceOptions.Hidden.ContainerDirectory) then FileListBox1.PublicUpdate;
     end;                                                                        {$IFDEF Debug}DebugForm.Debug('TxRepl32.SaveContainer:(succeeded):'+Sender.ClassName);{$ENDIF}
     except
          MyExceptionHandler(Sender);
     end;
     EnableEverything;
     UpdateGrid;

     LoadedFullState:='';
     LoadedStringGrid:=SaveDialog1.FileName;

     if iWaitRunning then begin
        iWaitState.Kill;
        iWaitRunning:=False;
        end;

     SetGridEdit;
     end;

procedure TxRepl32.FillContainer(ContainerHandle: integer; xRepHeader: array of char);
var
   MyRow:integer;
   xLeftSplit : char;
   xRightSplit: char;
   xInter : char;
   xWhole : char;
   xCase  : char;
   xPrompt: char;
   xReplaceCopies: char;
   xDisabled: char;
   MyRowContainedCol0Length,
   MyRowContainedCol1Length,
   MyRowContainedCol2Length,
   MyRowContainedCol3Length : PChar;

   MyRowContainedCol0,
   MyRowContainedCol1,
   MyRowContainedCol3,
   MyRowContainedCol2 : PChar;

   CompressedArray: pCompressedStringArray;
   CASize0, CASize1, CASize2, CASize3 : longint;
begin
    with StringGrid1 do begin
    {write XREP header}
    If (FileWrite(ContainerHandle,XRepHeader,Length(XRepHeader))=-1) or
       (FileWrite(ContainerHandle,FreqChar,10)=-1)
                 then begin
                    ReplaceLog.oLog('error writing to '+SaveDialog1.FileName,'',XReplaceOptions.Log.Everything);
                    if ErrorMessages then
                    MsgForm.MessageDlg('Error writing to '+SaveDialog1.FileName,
                                       'XReplace-32 has reported a system error while writing to a file.',mtError,[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
                    FileClose(ContainerHandle);
                    EnableEverything;
                    UpdateGrid;
                    exit;
                    end;
     {construct & write the replacement array}
     If RowCount>1 then
          for MyRow:=1 To RowCount-1 do begin

          if (RowCount - 1 > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc(Myrow / RowCount-1 * 100)); except end;

            if GridContents[MyRow].LeftSplit then xLeftSplit:='1' else xLeftSplit:='0';
            if GridContents[MyRow].RightSplit then xRightSplit:='1' else xRightSplit:='0';
            if GridContents[Myrow].Inter then xInter:='1' else xInter:='0';
            if GridContents[MyRow].CaseSens then xCase:='1' else xCase:='0';
            if GridContents[Myrow].WholeWord then xWhole:='1' else xWhole:='0';
            if GridContents[Myrow].Prompt then xPrompt:='1' else xPrompt:='0';
            xReplaceCopies := IntToStr(GridContents[Myrow].ReplaceCopies)[1];
            if GridContents[Myrow].Disabled then xDisabled:='1' else xDisabled:='0';

            MyRowContainedCol0:=pointer(CompressString(GetLeftSide(MyRow), CompressedArray, CASize0));
            MyRowContainedCol0Length:=StrAlloc(Length(IntToStr(CASize0))+1);
            StrPLCopy(MyRowContainedCol0Length,IntToStr(CASize0),Length(IntToStr(CASize0)));

            MyRowContainedCol1:=pointer(CompressString(GetRightSide(MyRow), CompressedArray, CASize1));
            MyRowContainedCol1Length:=StrAlloc(Length(IntToStr(CASize1))+1);
            StrPLCopy(MyRowContainedCol1Length,IntToStr(CASize1),Length(IntToStr(CASize1)));

            MyRowContainedCol2:=pointer(CompressString(GetLeftSplitSide(MyRow), CompressedArray, CASize2));
            MyRowContainedCol2Length:=StrAlloc(Length(IntToStr(CASize2))+1);
            StrPLCopy(MyRowContainedCol2Length,IntToStr(CASize2),Length(IntToStr(CASize2)));

            MyRowContainedCol3:=pointer(CompressString(GetRightSplitSide(MyRow), CompressedArray, CASize3));
            MyRowContainedCol3Length:=StrAlloc(Length(IntToStr(CASize3))+1);
            StrPLCopy(MyRowContainedCol3Length,IntToStr(CASize3),Length(IntToStr(CASize3)));

            If (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xLeftSplit,Length(xLeftSplit))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xRightSplit,Length(xRightSplit))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xInter,Length(xInter))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xCase,Length(xCase))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xWhole,Length(xWhole))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xPrompt,Length(xPrompt))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xReplaceCopies,Length(xReplaceCopies))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,xDisabled,Length(xDisabled))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or

               (FileWrite(ContainerHandle,MyRowContainedCol0Length^,Length(MyRowContainedCol0Length))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,MyRowContainedCol0^, CaSize0)=-1) or

               (FileWrite(ContainerHandle,MyRowContainedCol1Length^,Length(MyRowContainedCol1Length))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,MyRowContainedCol1^, CaSize1)=-1) or

               (FileWrite(ContainerHandle,MyRowContainedCol2Length^,Length(MyRowContainedCol2Length))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,MyRowContainedCol2^, CASize2)=-1) or

               (FileWrite(ContainerHandle,MyRowContainedCol3Length^,Length(MyRowContainedCol3Length))=-1) or
               (FileWrite(ContainerHandle,MySeparator,1)=-1) or
               (FileWrite(ContainerHandle,MyRowContainedCol3^, CASize3)=-1)

             then begin
                    ReplaceLog.oLog('error writing to '+SaveDialog1.FileName,'',XReplaceOptions.Log.Everything);
                    if ErrorMessages then
                    MsgForm.MessageDlg('Error writing to '+SaveDialog1.FileName,
                                       'XReplace-32 has reported a system error while writing to a file.',mtError,[mbAbort], 0, '[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
                    FileClose(ContainerHandle);
                    EnableEverything;

                    StrDispose(MyRowContainedCol0);
                    StrDispose(MyRowContainedCol1);
                    StrDispose(MyRowContainedCol2);
                    StrDispose(MyRowContainedCol3);
                    StrDispose(MyRowContainedCol0Length);
                    StrDispose(MyRowContainedCol1Length);
                    StrDispose(MyrowContainedCol2Length);
                    StrDispose(MyrowContainedCol3Length);
                    UpdateGrid;
                    exit;
                    end;

             FreeMem(MyRowContainedCol0);
             FreeMem(MyRowContainedCol1);
             FreeMem(MyRowContainedCol2);
             FreeMem(MyRowContainedCol3);

             StrDispose(MyRowContainedCol0Length);
             StrDispose(MyRowContainedCol1Length);
             StrDispose(MyrowContainedCol2Length);
             StrDispose(MyrowContainedCol3Length);
          end;
     end;
   end;

procedure TxRepl32.InitGridContents(Row: integer);
begin
     SetLeftSide(Row, '');
     SetRightSide(Row, '');
     SetLeftSplitSide(Row, '');
     SetRightSplitSide(Row, '');
     GridContents[Row].LeftSplit := False;
     GridContents[Row].RightSplit:=False;
     GridContents[Row].CaseSens := False;
     GridContents[Row].Prompt := False;
     GridContents[Row].Inter := False;
     GridContents[Row].Disabled := False;
     GridContents[Row].WholeWord := False;
     GridContents[Row].ReplaceCopies := 1;//XReplaceOptions.Repl.TargetCopies;
     GridContents[Row].occurrencesFound := 0;
     GridContents[Row].occurrencesReplaced := 0;
     end;

procedure TxRepl32.RemoveRow(const iRow: LongInt);
begin
   try
   if not((EditText.Visible) and (EditText.EditRow = iRow)) then
      with StringGrid1 do
           if (iRow = 1) and (RowCount = 2) then begin
              InitGridContents(1);
              StringGrid1.Repaint;
              end else begin
              ExtractRow(iRow);
              if EditText.EditRow > iRow then begin
                 EditText.EditRow := EditText.EditRow - 1;
                 EditText.EditChange(Application);
                 end;
              RowCount:=RowCount - 1;
              StringGrid1.Repaint;
              end;
   except
      MyExceptionHandler(Self);
      end;
   end;

procedure TxRepl32.InsertRow(const iRow: LongInt);
begin
   try
   if not((EditText.Visible) and (EditText.EditRow = iRow)) then
      with StringGrid1 do begin
           RowCount:=RowCount + 1;
           InsertGridRow(iRow);
           end;                                                                            {$IFDEF Debug}DebugForm.Debug('TxRepl32.StringGridRowInsert:(succeeded):'+Self.ClassName);{$ENDIF}
   except
      MyExceptionHandler(Self);
      end;
   end;

procedure TxRepl32.SBrpRemoveClick(Sender: TObject);
begin
   if EditText.Visible then begin
      with EditText do begin
         Visible:=False;
         RemoveRow(EditRow);
         UpdateGrid;
         if (EditRow > StringGrid1.RowCount) then EditRow := EditRow - 1;
         MakeVisible(EditRow);
         OpenEditText(True);
         end;
      end else RemoveRow(StringGrid1.Row);
   end;

procedure TxRepl32.SBffClearAddClick(Sender: TObject);
var
   oldFilter: string;
begin
   try
   oldFilter:=FilterComboBox1.Filter;
   FilterComboBox1.filter:='';
   FunctionSBffAddClick(SBffClearAdd, filterComboBox1);
   If FilterComboBox1.Filter='' Then FilterComboBox1.Filter:=oldFilter;          {$IFDEF Debug}DebugForm.Debug('TxRepl32.FilterAdd:(succeede):'+Sender.ClassName);{$ENDIF}
     except
          MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.SBffRemoveClick(Sender: TObject);
var i:integer;
    MyFilter:string;
begin
     try
     MyFilter:='';
     for i:=0 To FilterComboBox1.Items.Count-1 do begin
         If FilterComboBox1.Items[i]<>FilterComboBox1.Text then
         begin
             if Length(MyFilter)>0 Then MyFilter:=MyFilter+'|';
             MyFilter:=MyFilter+FilterComboBox1.Items[i]+'|'+Copy(FilterComboBox1.Items[i],2,Length(FilterComboBox1.Items[i])-2);
         end;
     end;
     FilterComboBox1.Filter:=MyFilter;
     If FilterComboBox1.Filter='' Then FilterComboBox1.Filter:='All Files (*.*)|*.*';      {$IFDEF Debug}DebugForm.Debug('TxRepl32.FilterBoxRemove:(succeeded):'+Sender.ClassName);{$ENDIF}
     except
          MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.SBffAddClick(Sender: TObject);
begin
     try
     FunctionSbffAddClick(SbffAdd, FilterComboBox1);
     except
          MyExceptionHandler(Sender);
     end;
end;

function TxRepl32.FunctionSBffAddClick(Sender: TObject; var LocalFilterCombo: TFilterComboBox):integer;
var
   MyTFileExtString: string;
   MyTFileShortString:string;
   UserClickOK: Boolean;
   i:integer;
label TFileExtAddGetString;
begin
   try
   MyTFileExtString:='*.*';
   TFileExtAddGetString:
     UserClickOK:= InputQuery('XReplace-32', 'Please enter a file flag:', MyTFileExtString);
     if UserClickOK then
      begin
          If (Pos('*',MyTFileExtString)=0) and (Pos('?',MyTFileExtString)=0) then begin
            if ErrorMessages then
            MsgForm.MessageDlg('You have entered an invalid files flag.',
                               'You must give a valid flag name containing ? or * chars!',mtWarning,[mbOK],0,'');
            MyTFileExtString:='*.*';
            goto TFileExtAddGetString;
            end;
          MyTFileShortString:=MyTFileExtString;
          MyTFileExtString:='('+MyTFileExtString+')|'+MyTFileExtString;

          for i:=0 To LocalFilterCombo.Items.Count-1 do begin
              If LocalFilterCombo.Items[i]='('+MyTFileShortString+')' then break;
          end;
          if LocalFilterCombo.Items.Count=0 Then LocalFilterCombo.Filter:=MyTFileExtString
          else if i=LocalFilterCombo.Items.Count then LocalFilterCombo.Filter:=LocalFilterCombo.Filter+'|'+MyTFileExtString;
          LocalFilterCombo.ItemIndex:=i;
          if Assigned(LocalFilterCombo.OnChange) then LocalFilterCombo.OnChange(LocalFilterCombo);
          //FilterComboBox1Change(FilterComboBox1);
          FunctionSbffAddClick:=1;
          end
      else
          FunctionSbffAddClick:=-1;                                              {$IFDEF Debug}DebugForm.Debug('TxRepl32.SBffAddClick:(succeeded):'+Sender.ClassName);{$ENDIF}
     except
          MyExceptionHandler(Sender);
          FunctionSbffAddClick:=-1;
     end;
end;

procedure TxRepl32.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
     try
     if not XReplace1.Enabled then begin
        CanClose:=False;
        exit;
        end;
     TreeView1.Kill;
     InterruptReplace:=True;
     CanClose:=False;
     SBQuitClick(Self);                                                          {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCloseQuery:(succeeded):'+Sender.ClassName);{$ENDIF}
     except
          MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.TreeView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   LName: string;
   LNode: TTreeNode;
   iPos: TPoint;
begin
   if not TreeView1.DropTerminated then exit;
   LNode := TreeView1.GetNodeAt(X,Y);
   if (LNode = nil) or (LNode.Text = NoTag) then exit;
   LNode.Selected := True;
   if Button = mbLeft then begin
     TreeView1.BeginDrag(False);
     end else
   if Button = mbRight then begin      LName:=TreeView1.GetCompletePath(LNode);      if FileExists(LName) or DirectoryExists(LName) then begin
         dvEditFile.Enabled:=True;
         dvParse.Enabled:=True;
         dvRemove.Enabled:=True;
         dvClearModif.Enabled := True;
         end else begin
         dvEditFile.Enabled:=False;
         dvParse.Enabled:=False;
         dvRemove.Enabled:=False;
         dvClearModif.Enabled := False;
         end;
   iPos.X:=X;
   iPos.Y:=Y;
   iPos:=TreeView1.ClientToScreen(iPos);
   DropViewPopup.Popup(iPos.X, iPos.Y);
   end;
end;

procedure TxRepl32.BBffDustClick(Sender: TObject);
begin
     try
     if TreeView1.DropTerminated then begin
        TreeView1.NodeDelete(TreeView1.Selected);                                 {$IFDEF Debug}DebugForm.Debug('TxRepl32.DustBinDelete:(succeeded):'+Sender.ClassName);{$ENDIF}
        UpdateSpecialConditions;
        end;
     except
           {ibidem}                                                              {$IFDEF Debug}DebugForm.Debug('TxRepl32.DustBinDelete:(failed, not fatal):'+Sender.ClassName);{$ENDIF}
     end;
end;

procedure TxRepl32.BBffDustDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
     try
     if (Source is TDropView) then
       if (Source as TDropView).DropTerminated then
         Accept:=True else Accept:=False;
     except
         MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.BBffDustDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
     try
        BBffDustClick(Self);                                            {$IFDEF Debug}DebugForm.Debug('TxRepl32.DustBinDrop:(succeeded):'+Sender.ClassName);{$ENDIF}
     except
        MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.AddCancelClick(Sender: TObject);
var
   CanCancel : boolean;
   rMsg: integer;
begin
   try
   if (TreeView1.DropTerminated) and
      (not LoadingContainer) and
      (not PerformingReplace) and
      (not PerformingCopyPaste) then exit;

   ReplaceLog.oLog('user interrupt request (query)','',XReplaceOptions.Log.Everything);

   if not TreeView1.DropTerminated then
      rMsg:=MsgForm.MessageDlg('Do you really want to cancel the drag and drop operation?',
                               'If you choose to cancel the current operation, XReplace will simply interrupt it '+
                               'without restoring the tagged files list of before the drag and drop operation.',
                               mtConfirmation,[mbYes]+[mbNo],0, '')
   else if LoadingContainer then
      rMsg:=MsgForm.MessageDlg('Do you really want to cancel loading the container?',
                               'If you choose to cancel loading the container, XReplace-32 will keep the already '+
                               'loaded strings and simply interrupt the loading without restoring the replacements grid of before the operation.',mtConfirmation,[mbYes]+[mbNo],0, '')
   else if PerformingReplace then
      rMsg:=MsgForm.MessageDlg('Do you really want to cancel the replacements operation?',
                               'If you choose to cancel the current replacements operation, '+
                               'XReplace-32 will interrupt all replacements in the current and in the following tagged files.',mtConfirmation,[mbYes]+[mbNo],0,'')
   else if PerformingCopyPaste then
      rMsg:=MsgForm.MessageDlg('Do you really want to cancel the copy/paste operation?',
                               'If you choose to cancel the current copy/paste operation, '+
                               'XReplace-32 will interrupt it as soon as possible keeping the already performed pasted or copied items.',mtConfirmation,[mbYes]+[mbNo],0,'')
   else rMsg:=MsgForm.MessageDlg('Do you really want to cancel?','Choose Yes if you want to abort the current operation and No if you wish to continue.',
                               mtConfirmation,[mbYes]+[mbNo],0,'');

   if rMsg=mrYes then CanCancel:=True else CanCancel:=False;
   if CanCancel then begin

     ReplaceLog.oLog('user interrupt request (confirmed)','',XReplaceOptions.Log.Everything);

     TreeView1.Kill;
     InterruptReplace:=True;                                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.OpCancel:(succeeded):'+Sender.ClassName);{$ENDIF}
     xrpStatusBar.Panels[0].Text:='Ready.';
     if PerformingReplace then begin
        ReplaceLog.oLog('aborting replacements operation (user cancelled)','',XReplaceOptions.Log.Everything);
        XRepl32.ReplaceLog.CleanLog(FileLogString);
        XRepl32.ReplaceLog.CleanLog('     cancelled.');
        FileLogString:='';
        end;
     if PerformingCopyPaste then begin
        ReplaceLog.oLog('aborting copy paste operation (user cancelled)','',XReplaceOptions.Log.Everything);
        InterruptCopyPaste:=True;
        end;
     if LoadingContainer then begin
        ReplaceLog.oLog('aborting container loading (user cancelled)','',XReplaceOptions.Log.Everything);
        StopLoadingContainer:=True;
        end;
     end else begin
         ReplaceLog.oLog('user interrupt request (cancelled)','',XReplaceOptions.Log.Everything);
         end;
     except
          MyExceptionHandler(Sender);
     end;
end;

function ReplaceThread.ParseTreeView(TreeView:TTreeView;TreeNode:TTreeNode;ParentDirectory:string):string;
  {$ifdef Registered}
  var
     CreationTime, LastAccessTime, LastWriteTime: TFileTime;

         function ReadSourceTime(Source: string): boolean;
         var
            SrchHdl: THandle;
            FileHdl: HFile;
            FindData: TWin32FindData;
         begin
            Result := False;
            if XReplaceOptions.Repl.PreserveDateTime then begin
               SrchHdl := FindFirstFile(PChar(Source), FindData);
               if SrchHdl <> INVALID_HANDLE_VALUE then begin
                  FileHdl := _lopen(PChar(Source), OF_WRITE);
                  if FileHdl <> HFILE_ERROR then begin
                     Result := GetFileTime(FileHdl, @CreationTime, @LastAccessTime, @LastWriteTime);
                     _lclose(FileHdl);
                     end;
                  end;
               end;
            end;

         procedure SetSourcetime(Source: string);
         var
            SrchHdl: THandle;
            FileHdl: HFile;
            FindData: TWin32FindData;
         begin
              SrchHdl := FindFirstFile(PChar(Source), FindData);
              if SrchHdl <> INVALID_HANDLE_VALUE then begin
                 FileHdl := _lopen(PChar(Source), OF_WRITE);
                 if FileHdl <> HFILE_ERROR then begin
                    SetFileTime(FileHdl, @CreationTime, @LastAccessTime, @LastWriteTime);
                    _lclose(FileHdl);
                    end;
                 end;
              end;
   {$endif}

var
   ANode:TTreeNode;
   LoggedDir : boolean;
{$ifdef Registered}
   RSetTime: boolean;
{$endif}
   Source, Target: string;
begin
     Application.ProcessMessages;
     with xRepl32 do begin
     try
     LoggedDir:=False;
     If InterruptReplace then exit;
     if Application.Terminated then exit;

     ANode:=TreeNode.GetFirstChild;
     while (ANode<>nil) do begin
           ANode.Selected:=True;

           if (ANode.ImageIndex in [shGeneric, shSelected]) or not(Assigned(TreeView1.StateImages)) and (ANode.Count=0) then
           If DirectoryExists(ParentDirectory+GetSource(ANode))=False then begin

              if not XReplaceOptions.Log.Directories then begin
                 FileLogString:='  replacing in '+PArentDirectory+GetSource(ANode);
                 end else begin
                 FileLogString:='  replacing in '+GetSource(ANode);
                 end;

           if FileExists(ParentDirectory+GetSource(ANode)) then begin
              if (XReplaceOptions.Log.Directories) and (not LoggedDir) then begin
                  LoggedDir:=True;
                  ReplaceLog.CleanLog('  parsing '+ParentDirectory);
                  end;

              if not XReplaceOptions.Log.Directories then begin
                 FileLogString:='  replacing in '+PArentDirectory+GetSource(ANode);
                 end else begin
                 FileLogString:='  replacing in '+GetSource(ANode);
                 end;
                 {$ifdef registered}
                 if Unattended <> nil then
                 if Unattended.Visible then begin
                    Unattended.FileName.Caption:=ParentDirectory+GetSource(ANode);
                    Unattended.FileName.Update;
                    end;
                 {$endif}

                 Source := ParentDirectory+GetSource(ANode);
                 Target := GetFullRedirection(ANode);

                 { Preserving time }

                 {$ifdef Registered}
                 RSetTime := ReadSourceTime(Source);
                 {$endif}

                 ProcessMultilineReplacements(Source, Target);

                 {$ifdef Registered}
                 if RSetTime then SetSourceTime(Source);
                 {$endif}

                 if (xRepl32.CurrentStats.occurrencesReplaced <> 0) then begin
                    {aNode.StateIndex := 4}
                    aNode.ImageIndex := shSelected;
                    aNode.SelectedIndex := aNode.ImageIndex;
                    end else begin
                    //aNode.StateIndex := 3;
                    aNode.ImageIndex := shGeneric;
                    aNode.SelectedIndex := aNode.ImageIndex;
                    end;
                 SetOFound(aNode, CurrentStats.occurrencesFound);
                 SetOReplaced(aNode, CurrentStats.occurrencesReplaced);
                 xrpStatusBar.Panels[0].Text:=ParentDirectory+GetSource(ANode);
                 xrpStatusBar.Update;                                              {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
                end
                 else begin
                 XRepl32.ReplaceLog.CleanLog(FileLogString);
                 XRepl32.ReplaceLog.CleanLog('     file not found.');

                 if ErrorMessages then
                 If MsgForm.MessageDlg('File '+GetSource(Anode)+' has not been found.',
                                       'One of the tagged files for replacement does not exist. Choose Abort to interrupt the replacements operation or Ignore to continue with the next file.',
                                       mtError,[mbIgnore, mbAbort],0,'')=mrAbort then begin
                    xRepl32.TreeView1.Kill;
                    InterruptReplace:=True;
                    exit;
                    end;
                 end;
              end;

           If InterruptReplace then exit;
           if Application.Terminated then exit;
           GPCounter:=GPCounter+1;

           GlobalProgressBar.Progress:=trunc(GPCounter / (TreeView1.Items.Count-1) * 100);
           GlobalProgressBar.Update;
           {$ifdef registered}
           if Unattended <> nil then
           if Unattended.Visible then begin
              Unattended.GlobalProgressBar.Progress := GlobalProgressBar.Progress;
              Unattended.GlobalProgressBar.Update;
              end;
           {$endif}
           ParseTreeView(TreeView1,ANode,ParentDirectory+GetSource(ANode)+'\');
           ANode:=TreeNode.GetNextChild(ANode);
           end;                                                                  {$IFDEF Debug}DebugForm.Debug('TxRepl32.ParseTreeView:(recursion succeeded).');{$ENDIF}
     except
          MyExceptionHandler(TreeView);
     end;
     end;
end;

procedure ReplaceThread.MakeReplacements;
begin
     with xRepl32 do begin
     try
     CompactGrid;
     ReplaceAll:=False;
     ReplaceStats.occurrencesFound:=0;
     ReplaceStats.occurrencesReplaced:=0;
     If CheckGridValid=False then exit;
     {initialize the progress meter}
     if XReplaceOptions.Log.Header then begin
        ReplaceLog.CleanLog('     replacements: '+IntToStr(StringGrid1.RowCount-1)+', interline: '+IntToStr(CountSplit));
        with XReplaceOptions.Repl do begin
           {$ifdef Registered}
           if RegExp then begin
               ReplaceLog.CleanLog('     assume regular exp  : '+BoolToBool(RegExp));
               ReplaceLog.CleanLog('     prompt on replace   : '+BoolToBool(PromptOnReplace));
               ReplaceLog.CleanLog('     overwriting backups : '+BoolToBool(OverwriteBackups));
               ReplaceLog.CleanLog('     warn if binary      : '+BoolToBool(WarnIfBinary));
               ReplaceLog.CleanLog('     backup extension    : .'+BackupExt);
               ReplaceLog.CleanLog('     attribute warning   : '+BoolToBool(FileAttributeCare));
           end else begin
           {$endif}
               ReplaceLog.CleanLog('     assume regular exp  : '+BoolToBool(RegExp));
               ReplaceLog.CleanLog('     case sensitive      : '+BoolToBool(CaseSensitive));
               ReplaceLog.CleanLog('     prompt on replace   : '+BoolToBool(PromptOnReplace));
               ReplaceLog.CleanLog('     whole words only    : '+BoolToBool(WholeWordsOnly));
               ReplaceLog.CleanLog('     overwriting backups : '+BoolToBool(OverwriteBackups));
               ReplaceLog.CleanLog('     include source      : '+BoolToBool(IncludeSource));
               ReplaceLog.CleanLog('     warn if binary      : '+BoolToBool(WarnIfBinary));
               ReplaceLog.CleanLog('     backup extension    : .'+BackupExt);
               ReplaceLog.CleanLog('     backup location     : '+BackupLoc);
               ReplaceLog.CleanLog('     attribute warning   : '+BoolToBool(FileAttributeCare));
           {$ifdef Registered}
               end;
           {$endif}
           if AlwaysCreateBackups then
              ReplaceLog.CleanLog('     create backups      : always')
              else if CreateBackups then ReplaceLog.CleanLog('     create backups      : for modified files only')
              else ReplaceLog.CleanLog('     create backups      : never');
           end;
        end;
     StatusLabel.Visible := False;
     GlobalProgressBar.Progress := 0;
     LocalProgressBar.Progress:=0;
     GlobalProgressBar.Visible:=True;
     LocalProgressBar.Visible:=True;
     GPCounter:=0;
     InterruptReplace:=False;
     BackupFileOverWrite:=XReplaceOptions.Repl.OverwriteBackups;
     FileAttributeCareLocal:=XReplaceOptions.Repl.FileAttributeCare;
     {parse the created files' tree}
            MyNode:=TreeView1.{GetDrivesNode}Items.GetFirstNode;
            DisableEverything;
            Application.ProcessMessages;
            While(MyNode<>nil) do begin
               ParseTreeView(TreeView1,MyNode{.Node},MyNode{.Node}.Text);
               MyNode:=MyNode.{NextParentNode}GetNextSibling;
               if InterruptReplace or Application.Terminated then break;
               end;
     EnableEverything;
     {finish and clean}
     //xrpStatusBar.Panels[0].Text:='Done. (total of '+IntToStr(ReplaceStats.occurrencesFound)+' occurrence(s) found - '+IntToStr(ReplaceStats.occurrencesReplaced)+' replaced)';    {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
     GlobalProgressBar.Visible:=False;
     LocalProgressBar.Visible:=False;                                            {$IFDEF Debug}DebugForm.Debug('TxRepl32.MakeReplacements:(succeeded).');{$ENDIF}
     StatusLabel.Caption:='Total of '+IntToStr(ReplaceStats.occurrencesFound)+' occurrence(s) found, '+#13#10+IntToStr(ReplaceStats.occurrencesReplaced)+' string(s) replaced.';    {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
     StatusLabel.Visible := True;
     except
     MyExceptionHandler(Self);
     EnableEverything;
     {finish and clean}
     //xrpStatusBar.Panels[0].Text:='Exception raised.';                       {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels.Items[0].Text);{$ENDIF}
     StatusLabel.Caption:='Exception raised.';
     GlobalProgressBar.Visible:=False;
     LocalProgressBar.Visible:=False;                                            {$IFDEF Debug}DebugForm.Debug('TxRepl32.MakeReplacements:(failed):'+Self.ClassName);{$ENDIF}
     end;
     end;
end;

procedure TxRepl32.CloseEditText;
begin
     with EditText do begin
          if EditLSRight then SetLeftSplitSide(EditRow, Text) else
          if EditRSRight then SetRightSplitSide(EditRow, Text) else
          if EditCol = 0 then SetLeftSide(EditRow, Text)
                         else SetRightSide(EditRow, Text);
          end;
     end;

procedure TxRepl32.OpenEditText(iShow: boolean);
begin
     with EditText do begin

     if iShow then UpdateGrid;

     if EditLSRight and not IsLeftSplit(EditRow) then EditLSRight:=False;
     if EditRSRight and not IsRightSplit(EditRow) then EditRSRight:=False;

     if EditLSRight then Text:=GetLeftSplitSide(EditRow) else
     if EditRSRight then Text:=GetRightSplitSide(Editrow) else
     if EditCol = 0 then Text:=GetLeftSide(EditRow) else
        Text:=GetRightSide(EditRow);

     if iShow then begin
        Visible:=True;
        EditChange(Application);
        if Showing then SetFocus; 
        end;
        end;
     end;


procedure TxRepl32.PerformReplacements;
begin
     try
     {MakeReplacements;}
     {$ifndef Registered}
     if Expired then begin
        ShareWareNag;
        exit;
        end;
     {$endif}

     if EditText.Visible then begin
        CloseEditText;
        EditText.Visible:=False;
        end;
        MyReplaceThread.Create{(False)};
        SetGridEdit;
     except
        MyExceptionHandler(xRepl32);
     end;
     end;

procedure TxRepl32.SBGoClick(Sender: TObject);
begin
     Operation := opReplace;
     PerformReplacements;
     end;

procedure TxRepl32.Go1Click(Sender: TObject);
begin
     try
     SBGoClick(Self);
     except
          MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.TerminateXReplace(Force: boolean);
var
   rMsg, sMsg: TModalResult;
begin
   try

   ShellSpace.Abort;

   {$ifdef Registered}
   if QuitNoQuery then exit;
   if MacroEdit <> nil then
      if (MacroEdit.Visible) and (not MacroEdit.MacroMemo.Enabled)
         then exit;
   if MacroEdit <> nil then
      if MacroEdit.Visible then
         MacroEdit.Close;
   {$endif}

   if (Force) then begin
         while not TreeView1.DropTerminated do
            Application.ProcessMessages;
         while LoadingContainer do
            Application.ProcessMessages;
         while PerformingReplace do
            Application.ProcessMessages;
         rMsg := mrYes;
      end else begin
         if not TreeView1.DropTerminated then
         rMsg:=MsgForm.MessageDlg('Do you really want to cancel the drag and drop operation?',
                               'If you choose to cancel the current operation, XReplace will simply interrupt it '+
                               'without restoring the tagged files list of before the drag and drop operation.',mtConfirmation,[mbYes]+[mbNo],0,'')
         else if LoadingContainer then begin
            MsgForm.MessageDlg('Please first cancel the container loading.',
                               'If you choose to cancel loading the container, XReplace-32 will keep the already loaded strings and '+
                               'simply interrupt the loading without restoring the replacements grid of before the operation.',mtConfirmation,[mbOk],0,'');
            rMsg := mrNo;
         end else if PerformingReplace then
            rMsg := MsgForm.MessageDlg(
                               'Do you really want to cancel the replacements operation?',
                               'If you choose to cancel the current replacements operation, '+
                               'XReplace-32 will interrupt all replacements in the current and in the following tagged files.',mtConfirmation,[mbYes]+[mbNo],0,'')
         else rMsg:=mrYes;
      end;

   if rMsg = mrYes then begin

     StopLoadingContainer:=True;
     InterruptReplace:=True;
     TXOptions.UpdateRegistry;

     if (not Force) and (XReplaceOptions.Gen.PromptGrid) then begin
        if LoadedFullState <> '' then begin
           sMsg := MsgForm.MessageDlg(
               'Do you wish to save the replacements grid and the tagged files list?',
               'If you don''t save now, all changes will be lost. If you don''t want to see this message in the future and never save the replacements grid nor the tagged files list, uncheck the Prompt on Quit option.',
               mtConfirmation,
               [mbYes]+[mbNo], 0, '');
           if sMsg = mrYes then begin
               sbFullSave.Click;
               exit;
               end;
           end else begin
               if StringGrid1.RowCount > 2 then
                  if MsgForm.MessageDlg(
                     'Do you wish to save the replacements grid?',
                     'If you don''t save now, all changes will be lost. If you don''t want to see this message in the future and never save the replacements grid, uncheck the Prompt on Quit option.',
                     mtConfirmation,
                     [mbYes]+[mbNo], 0, '') = mrYes then begin
                        sbRpSave.Click;
                        exit;
                        end;

               if (not TreeView1.isEmpty) then
                  if MsgForm.MessageDlg(
                     'Do you wish to save the tagged files list?',
                     'If you don''t save now, all changes will be lost. If you don''t want to see this message in the future and never save the tagged files list, uncheck the Prompt on Quit option.',
                     mtConfirmation,
                     [mbYes]+[mbNo], 0, '') = mrYes then begin
                        sbTreeViewSave.Click;
                        exit;
                        end;
           end;
        end;

     ReplaceLog.oLog(
         XRVersion + ' ' + XRBuild + ' successfully terminated.',
         '',
         XReplaceOptions.Log.Everything);

     ReplaceLog.CleanUp;
     ReplaceLog.Destroy;
     //PluginManager.Destroy;
     Application.ProcessMessages;

     Application.Terminate;

     end;
                                                                                 {$IFDEF Debug}DebugForm.Debug('TxRepl32.Terminate:(succeeded).');{$ENDIF}
     except
     end;
     end;

procedure TxRepl32.SBQuitClick(Sender: TObject);
begin
     TerminateXReplace(False);
     end;

procedure ReplaceThread.ProcessMultilineReplacements(FileName, Target: string);
var
   SourceFileBuffer: string;
   SSize, TSize: LongInt;
   //--------------------------------------------------------------
   function dbCopyFile(FileName, BackupFileName: string): string;
   var
      fName: string;
   begin
        try
        fName:=Copy(ExtractFileName(BackupFileName), 1, 5);
        BackupFileName:=ExtractFileDir(BackupfileName);
        if (BackupFileName[Length(BackupFileName)]<>'\') then BackupFileName:=BackupFileName +'\';
        fName:=fName + '~00.';
        fName:=fName + Copy(XReplaceOptions.Repl.BackupExt, 1, 3);
        if not BackupFileOverwrite then begin
        while (FileExists(BackupFileName + fName)) and (fName[7]<'9') do begin
              while (FileExists(BackupFileName + fName)) and (fName[8]<'9') do begin
                    inc(fName[8]);
                    end;
              if FileExists(BackupFileName + fName) then begin
                 fName[8]:='0';
                 inc(fName[7]);
                 end;
              end;
        if FileExists(BackupFileName + fName) then begin
           MsgForm.MessageDlg('Please clean up your backup files!',
                                       'XReplace-32 is working on a short names drive and has reached the 99 file limit for backups.'+
                                       'This means that you have at least 99 files like ?????~XX.XRP on your drive. Either set overwrite backups option or clean up the drive.',
                                       mtError,[mbIgnore],0,'');
           Result:='';
           exit;
           end;
        end;

        BackupFileName:=BackupFileName + fName;
           if CopyFile(PChar(FileName), PChar(BackupFileName), False)=False then Result:='' else Result:=BackupFileName;
        except
              Result:='';
        end;
        end;

   procedure OutPutRedirectBuffer(Target: string);
   var
      OutPutFile: TextFile;
   begin
     if xRepl32.Operation = opPreview then exit;
     if FileExists(Target) then begin
        //--- handle target file existance
        end;
     if DirectoryExists(Target) then begin
        Target:=ExpandFileName(Target + '\' + ExtractFileName(FileName));
        end;
     //create redirect directory
     if not(xRepl32.ForceMkDir(ExtractFileDir(Target))) then begin
        if xRepl32.ErrorMessages then
           if MsgForm.MessageDlg('Unable to create ' + Target + ' as defined by redirection. File will be skipped. Abort will interrupt all replacements.',
                                 'You have tried to redirect a file output to an invalid directory, drive or name. Please check the drive and the name you redirect to.',
                                  mtError,[mbIgnore, mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError)) = mrAbort then begin
                                 xRepl32.TreeView1.Kill;
                                 xRepl32.InterruptReplace:=True;
                                 end;
        FileLogString:=FileLogString + #13#10+'     unable to create '+Target+' as defined by redirection';
        xRepl32.CurrentStats.occurrencesReplaced:=0;
        exit;
        end;

     {$ifdef Registered}
     FileLogString:=FileLogString + #13#10+'     output to '+Target;
     {$endif}

     try
     AssignFile(OutPutFile, Target);
     if FileExists(Target) then Reset(OutPutFile);
     Rewrite(OutPutFile);
     Write(OutPutFile,SourceFileBuffer);
     TSize:=Length(SourcefileBuffer);
     Close(OutPutFile);
     except
        if xRepl32.ErrorMessages then
           if MsgForm.MessageDlg('An error has occured writing to ' + Target + ' Abort will interrupt all replacements.',
                              'XReplace-32 was unable to complete the replacements operation for the given file because of a disk error. File will be skipped.',
                              mtError,[mbIgnore, mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError)) = mrAbort then begin
                                                xRepl32.TreeView1.Kill;
                                                xRepl32.InterruptReplace:=True;
                                                end;
        FileLogString:=FileLogString + #13#10+'     error writing to '+Target+' '+IntToStr(GetLastError)+':'+ErrorRaise(GetLastError);
        xRepl32.CurrentStats.occurrencesReplaced:=0;
     end;
     end;
   //--------------------------------------------------------------
   function Backup: string;
   var
      BackupFileName: string;

      procedure CreateBackupFileName;
      var
         i: integer;
         newBackupDir: string;
      begin
         if CompareText(XReplaceOptions.Repl.BackupLoc, XOLocalBackup) = 0 then BackupFileName:=FileName+'.'+XReplaceOptions.Repl.BackupExt
         else begin
              try ForceDirectories(XReplaceOptions.Repl.BackupLoc); except end;
              if not DirectoryExists(XReplaceOptions.Repl.BackupLoc) then begin
                 MsgForm.MessageDlg('Unable to create backup root directory!',
                                       'XReplace-32 could not create '+ XReplaceOptions.Repl.BackupLoc + ', assuming current directory for backup.',
                                       mtError,[mbOk],0,'');
                 BackupFileName:=FileName+'.'+XReplaceOptions.Repl.BackupExt
                 end else begin
                 BackupFileName:=FileName+'.'+XReplaceOptions.Repl.BackupExt;

                 for i:=1 to Length(BackupFileName) do
                     if BackupFileName[i] = ':' then BackupFileName[i] := '\';
                 for i:=Length(BackupFileName) downto 2 do
                     if (BackupFileName[i] = '\') and (BackupFileName[i-1] = '\') then
                        Delete(BackupFileName, i, 1);

                 BackupFileName := bs(XReplaceOptions.Repl.BackupLoc) + BackupFileName;
                 NewBackupdir := ExtractFileDir(BackupFileName);
                 ForceDirectories(newBackupDir);
                 if not DirectoryExists(newBackupDir) then begin
                    MsgForm.MessageDlg('Unable to create backup directory!',
                                       'XReplace-32 could not create '+ newBackupDir + ', assuming current directory for backup.',
                                       mtError,[mbOk],0,'');
                 end;
              end;
           end;
         end;

   var
      iCnt: integer;
   begin
      with xRepl32 do begin {$I+}
      try
         CreateBackupFileName;
         if not BackupFileOverwrite then begin
            iCnt:=0;
            while (FileExists(BackupFileName)) and (iCnt <= 99) do begin
                  BackupFileName:=FileName+'.'+XReplaceOptions.Repl.BackupExt+IntToStr(iCnt);
                  inc(iCnt);
                  end;
            if FileExists(BackupFileName) then begin
                  MsgForm.MessageDlg('Please clean up your backup files!',
                                       'XReplace-32 is working on a short names drive and has reached the 99 file limit for backups.'+
                                       'This means that you have at least 99 files like *.XRP?? on your drive. Either set overwrite backups option or clean up the drive. You shall be prompted for further action.',
                                       mtError,[mbOk],0,'');
                  Result:='';
                  exit;
               end;
            end;

         if CopyFile(PChar(FileName), PChar(BackupFileName),False)=False then begin
            Backup := dbCopyFile(FileName, BackupFileName);
            end else  Backup:=BackupFileName;

      except
         Backup:='';
         MyExceptionHandler(Self);
      end; {try except}
      end; {with}
      end;{backup}
   //--------------------------------------------------------------
   function LoadBuffer(var FileName: string; var SourceFileBuffer: string; InitName: string): boolean;
   var
      FileHandle : Integer;
      FSize: LongInt;
      FBuf: PChar;
   begin
      Result:=False;
      FileHandle := FileOpen(FileName, fmOpenRead or fmShareExclusive);
      if FileHandle<=0 then exit;
      FSize:=FileSeek(FileHandle, 0, 2);
      SSize:=FSize;
      FileSeek(FileHandle, 0, 0);
      FBuf:=StrAlloc(FSize+1);
      FileRead(FileHandle, FBuf^, FSize);
      FBuf[FSize]:=Chr(0);
      SourceFileBuffer:=FBuf;
      Result:=True;
      if FileHandle<>0 then FileClose(FileHandle);
      if Length(FBuf)<>FSize then begin
         if (XReplaceOptions.Log.Untouched) then begin
            XRepl32.ReplaceLog.CleanLog(FileLogString);
            XRepl32.ReplaceLog.CleanLog('     file is binary.');
            end;
         Result:=False;
         if XReplaceOptions.Repl.WarnIfBinary then
            if xRepl32.ErrorMessages then
            MsgForm.MessageDlg('File '+InitName+' is binary!'+#13#10+'No action will be taken.',
                               'You have tagged a binary file, XReplace cannot perform any operations on this file. '+
                               'It will remain untouched, the backup will be deleted. Check the options to remove this warning.',
                               mtWarning, [mbOk],0,'');
         if not (xRepl32.Operation = opPreview) then DeleteFile(FileName);
         end;
      StrDispose(FBuf);
      end;
   //--------------------------------------------------------------
var
   SourceFileName: string;
   FileAttribute: integer;
   rP: integer;
begin
   try
   {$I+}
   xRepl32.LocalProgressBar.Progress:=0;
   {$ifdef registered}
   if Unattended <> nil then Unattended.LocalProgressBar.Progress:=0;
   {$endif}
   FileAttribute:=FileGetAttr(FileName);
   if FileAttribute=-1 then begin
      if xRepl32.ErrorMessages then
      if MsgForm.MessageDlg('Unable to get file attribute: '+FileName,
                         'XReplace-32 was unable to get the file''s attribute due to an unknown reason. '+
                         'The current file will be ignored. Abort will terminate all replacements.',
                         mtError, [mbIgnore, mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError)) = mrAbort then begin
                         xRepl32.TreeView1.Kill;
                         xRepl32.InterruptReplace:=True;
                         end;
      exit;
      end;
   if ((FileAttribute and faReadOnly) > 0) or
      ((FileAttribute and faSysFile) > 0) or
      ((FileAttribute and faHidden)> 0) then begin
         if FileAttributeCareLocal then begin
            if xRepl32.ErrorMessages then
            rp:=MsgForm.MessageDlg('File has a hidden, read-only or a system attribute. Do you still want to continue?',
                                   'XReplace-32 has encountered a file ('+FileName+') with a hidden, read-only or a system attribute. Choose Yes if you want to perform replacements '+
                                   'in this file anyway, choose No if you don''t. Choose Abort to interrupt all replacements including in this file. '+
                                   'Choose All to avoid this prompt for the currently tagged files. You can remove this prompt permanently in the options.'+
                                   'If you choose to continue, attribute of the file after the replacements will not change.',
                                   mtInformation,[mbAll]+[mbCancel]+[mbYes]+[mbNo],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError)) else rp:=mrAll;
            if rp=mrAll then FileAttributeCareLocal:=False;
            if rp=mrCancel then begin
               xRepl32.InterruptReplace:=True;
               XRepl32.ReplaceLog.CleanLog(FileLogString);
               XRepl32.ReplaceLog.CleanLog('     cancelled (attribute prompt).');
               exit;
               end;
            if rp=mrNo then exit;
            end;
         FileSetAttr(FileName, 0);
         end;

   if not (xRepl32.Operation = opPreview) then begin
     SourceFileName:=Backup;
     if xRepl32.InterruptReplace {or NoBackup} then begin
      FileSetAttr(FileName, FileAttribute);
      exit;
      end;
     xRepl32.LocalProgressBar.Progress:=25;
     {$ifdef registered}if Unattended <> nil then Unattended.LocalProgressBar.Progress:=25;{$endif}
     if SourceFileName='' then begin
      if xRepl32.ErrorMessages then
      if MsgForm.MessageDlg('Error performing backup of '+FileName,
                            'XReplace has encountered an error while creating a backup file. ' +
                            'No action will be taken. Abort will interrupt all replacements, Ignore will continue with the next file.',
                            mtError,[mbIgnore]+[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError)) = mrAbort then xRepl32.InterruptReplace:=True;
      FileSetAttr(FileName, FileAttribute);
      exit;
      end;
     end else begin
     SourcefileName := FileName;
     end;

   SourceFileBuffer:='';
   if LoadBuffer(SourceFileName, SourcefileBuffer, FileName)=False then begin
      FileSetAttr(FileName, FileAttribute);
      exit;
      end;
   xRepl32.LocalProgressBar.Progress:=50;
   {$ifdef registered}if Unattended <> nil then Unattended.LocalProgressBar.Progress:=50;{$endif}
   GlobalFileName:=FileName;
   ReplaceAllCurrent:=False;
   DontReplaceCurrent:=False;
   xRepl32.CurrentStats.occurrencesFound:=0;
   xRepl32.CurrentStats.occurrencesReplaced:=0;

   SourceFileBuffer:=xRepl32.XReplace(SourceFileBuffer);

   xRepl32.LocalProgressBar.Progress:=75;
   {$ifdef registered}if Unattended <> nil then Unattended.LocalProgressBar.Progress:=75;{$endif}

   if not (xRepl32.Operation = opPreview) then begin
      if (xRepl32.CurrentStats.occurrencesReplaced = 0) then begin
         {$ifdef Registered}
         if XReplaceOptions.Repl.CopyRedirect then begin
            OutputRedirectBuffer(Target);
            FileLogString:=FileLogString + #13#10+'     forced copy by XReplace-32 options.';
            end;
         {$endif}
         //CopyFile(PChar(SourceFileName), PChar(FileName), False);
         if (not XReplaceOptions.Repl.AlwaysCreateBackups) then DeleteFile(SourceFileName);
         end else begin
             OutputRedirectBuffer(Target);
             if (not XReplaceOptions.Repl.AlwaysCreateBackups) and
             (not XReplaceOptions.Repl.CreateBackups) then
             DeleteFile(SourceFileName);
             end;
      end; //oppreview

   with xRepl32 do
   with ReplaceStats do begin
        inc(occurrencesFound, CurrentStats.occurrencesFound);
        inc(occurrencesReplaced, CurrentStats.occurrencesReplaced);
        end;

   if (XReplaceOptions.Log.Untouched) and (xRepl32.CurrentStats.occurrencesReplaced=0) then begin
      XRepl32.ReplaceLog.CleanLog(FileLogString);
      XRepl32.ReplaceLog.CleanLog('     no replacements made.');
      end;
   if (XReplaceOptions.Log.Modified) and (xRepl32.CurrentStats.occurrencesReplaced<>0) then begin
      XRepl32.ReplaceLog.CleanLog(FileLogString);
      if XReplaceOptions.Log.FileSize then XRepl32.ReplaceLog.CleanLog('     file size: '+IntToStr(SSize)+' (bytes) -> '+IntToStr(TSize)+' (bytes)');
      XRepl32.ReplaceLog.CleanLog('     Total of '+IntToStr(xRepl32.CurrentStats.occurrencesFound)+' occurrence(s) found.');
      XRepl32.ReplaceLog.CleanLog('     Total of '+IntToStr(xRepl32.CurrentStats.occurrencesReplaced)+' replacement(s) made.');
      end;

   xRepl32.LocalProgressBar.Progress:=100;
   {$ifdef registered}if Unattended <> nil then Unattended.LocalProgressBar.Progress:=100;{$endif}
   FileSetAttr(FileName, FileAttribute);

   except
   xRepl32.MyExceptionHandler(Self);
   end;
   end;

function TxRepl32.xReplace(ReadLine:string):string;
var
   i:integer;
   prOFound, prOReplaced : longint;
begin
   try
   for i:=1 to StringGrid1.RowCount-1 do begin
      if EditText.isEnabled(i) and (not AllEmpty(i)) then begin
         prOFound := CurrentStats.occurrencesFound;
         prOReplaced := CurrentStats.occurrencesReplaced;
         {$ifdef Registered}
         if XReplaceOptions.Repl.RegExp then xReplaceInternalRegExp(ReadLine, i) else
         {$endif} xReplaceInternal(ReadLine, i);
         inc(GridContents^[i]^.occurrencesFound, CurrentStats.occurrencesFound - prOFound);
         inc(GridContents^[i]^.occurrencesReplaced, CurrentStats.occurrencesReplaced - prOReplaced);
         //PluginManager.PerformReplaceOp(PChar(ReadLine), GridContents[i], @XReplaceOptions.Repl, @ReplaceLog);
         end;
      end;
   xReplace:=ReadLine;
   except
      MyExceptionHandler(Self);
   end;
   end;

procedure TxRepl32.xReplaceInternal(var ReadLine:string;i:integer);
 function XID(iStr: string): string;
 var
    j: integer;
 begin
      Result:='';
      for j:=1 to GridContents[i].ReplaceCopies do begin
          Result:=Result + iStr;
          end;
      end;

 function Bound(AnyInteger, Min, Max: integer):integer;
 begin
    if AnyInteger<Min then Bound:=Min else
    if AnyInteger>Max then Bound:=Max else
    Bound:=AnyInteger;
    end;
 var
   occurrence: LongInt;
   Endoccurrence: LongInt;
   LeftSide:string;
   RightSide:string;
   MissingPart: string;
   CanReplace: boolean;
   CanReplaceWhole: boolean;
   ReplaceBy, ReplaceWhat: string;
   FinalResult: string;
const
   Displacer: integer=150;
begin
     try
        FinalResult:='';

        while (True) do begin

        if Application.Terminated or InterruptReplace and not ReplaceAll then begin
           FinalResult:=Concat(FinalResult, ReadLine);
           break;
           end;
        if (XReplaceOptions.Repl.CaseSensitive) or (GridContents[i].CaseSens) then occurrence:=Pos(GetLeftSide(i),ReadLine)
           else occurrence:=Pos(UpperCase(GetLeftside(i)),UpperCase(ReadLine));

        if (occurrence<>0) then begin

           LeftSide:=Copy(ReadLine, 0, occurrence-1);
           if EditText.IsLeftSplit(i) then begin
              RightSide:=Copy(ReadLine,occurrence+Length(GetLeftSide(i)),Length(ReadLine));
              if XReplaceOptions.Repl.CaseSensitive or (GridContents[i].CaseSens) then Endoccurrence:=Pos(GetLeftSplitSide(i),RightSide)
              else Endoccurrence:=Pos(UpperCase(GetLeftSplitSide(i)),UpperCase(RightSide));
              if Endoccurrence=0 then begin
                 FinalResult:=Concat(FinalResult, ReadLine);
                 break;
                 end;
              RightSide:=Copy(RightSide,Endoccurrence+Length(GetLeftSplitSide(i)),Length(RightSide));
              MissingPart:=Copy(ReadLine,occurrence,Endoccurrence+Length(GetLeftSide(i))+Length(GetLeftSplitSide(i))-1);
              ReplaceWhat := MissingPart;
              end else begin
              RightSide:=Copy(ReadLine,occurrence+Length(GetLeftSide(i)),Length(ReadLine));
              ReplaceWhat:=Copy(ReadLine, occurrence, Length(GetLeftSide(i)));
              end;

        {confirm the replacement}
        CanReplace:=False;

           {$IFDEF Debug}
              DebugForm.Debug('(left)'+LeftSide);
              DebugForm.Debug('(lrpl)'+GetLeftSide(i));
              DebugForm.Debug('(miss)'+MissingPart);
              DebugForm.Debug('(rrpl)'+GetLeftSplitSide(i));
              DebugForm.Debug('(rght)'+RightSide);
           {$ENDIF}

        //check whole words only
        CanReplaceWhole:=True;
        if XReplaceOptions.Repl.WholeWordsOnly or (GridContents[i].WholeWord) then begin
           try                                                                   {$IFDEF Debug}DebugForm.Debug('(replacing) whole words only check initialized');{$ENDIF}
           if EditText.IsLeftSplit(i) then begin
              {check leftside with split occurrence}
              if not (GetLeftSide(i)[1] in ValidSpace) then
                 if Length(LeftSide)>0 then
                    if not (LeftSide[Length(LeftSide)] in ValidSpace) then CanReplaceWhole:=False;
              {check rightside with split occurrence}
              if not (GetLeftSplitSide(i)[Length(GetLeftSplitSide(i))] in ValidSpace) then
                 if Length(RightSide)>0 then
                    if not (RightSide[1] in ValidSpace) then CanReplaceWhole:=False;
              {check between left and right split}
              if Length(MissingPart) = 0 then begin
                 if (not (GetLeftSide(i)[Length(GetLeftSide(i))] in ValidSpace)) and
                    (not (GetLeftSplitSide(i)[1] in ValidSpace)) then CanReplaceWhole:=False;
                 end else begin

                 if not (GetLeftSide(i)[Length(GetLeftSide(i))] in ValidSpace) then
                    if not (MissingPart[Length(GetLeftSide(i))+1] in ValidSpace) then
                       CanReplaceWhole:=False;

                 if not (GetLeftSplitSide(i)[1] in ValidSpace) then
                    if not (MissingPart[Length(MissingPart)-Length(GetLeftSplitSide(i))] in ValidSpace) then
                       CanReplaceWhole:=False;

                 end;
              end else begin  {not split}
              {check leftside with occurrence}
              if not (GetLeftSide(i)[1] in ValidSpace) then
                 if Length(LeftSide)>0 then
                    if not (LeftSide[Length(LeftSide)] in ValidSpace) then CanReplaceWhole:=False;
              {check rightside with occurrence}
              if not (GetLeftSide(i)[Length(GetLeftSide(i))] in ValidSpace) then
                 if Length(RightSide)>0 then
                    if not (RightSide[1] in ValidSpace) then CanReplaceWhole:=False;
              end;

           {$IFDEF Debug}DebugForm.Debug('(replacing) succeeded, check set to '+BoolToStr(CanReplaceWhole));{$ENDIF}
           except
              CanReplaceWhole:=False;
              {$IFDEF Debug}DebugForm.Debug('(replacing) check raised error, set to false');{$ENDIF}
           end;
           end;

     //ReplaceWhat:=MissingPart;

     if EditText.IsRightSplit(i) then begin
        Delete(MissingPart, Length(MissingPart) - Length(GetLeftSplitSide(i)) + 1, Length(MissingPart));
        Delete(MissingPart, 1, Length(GetLeftSide(i)));
        end;

     if CanReplaceWhole then begin
        inc(CurrentStats.occurrencesFound);
        if ReplaceAll then CanReplace:=True else
        if ReplaceAllCurrent then CanReplace:=True else
        if DontReplaceCurrent then CanReplace:=False else
        if not (xReplaceOptions.Repl.PromptOnReplace or GridContents[i].Prompt) then CanReplace:=True;
        if (xReplaceOptions.Repl.PromptOnReplace or GridContents[i].Prompt) and (not ReplaceAll) and (not ReplaceAllCurrent) and (not DontReplaceCurrent) then begin

          if (ReplaceForm = nil) then
               Application.CreateForm(TReplaceForm, ReplaceForm);

          ReplaceForm.Status.SimpleText:=GlobalFileName;

          if EditText.IsLeftSplit(i) then begin

             if EditText.IsRightSplit(i) then begin
                if (XReplaceOptions.Repl.IncludeSource) or (GridContents[i].Inter) then
                   ReplaceBy:=GetRightSide(i) + XID(MissingPart + GetRightSplitSide(i)) else
                   ReplaceBy:=GetRightSide(i) + XID(GetRightSplitSide(i));
                end else
             if (XReplaceOptions.Repl.IncludeSource) or (GridContents[i].Inter) then
                ReplaceBy:=GetLeftSide(i) + XID(GetRightSide(i)+GetLeftSplitSide(i)) else
                ReplaceBy:=XID(GetRightSide(i));

             end else begin
             //ReplaceWhat:=GetLeftSide(i);
             ReplaceBy:=XID(GetRightSide(i));
             end;

           {$IFDEF Debug}
                   DebugForm.Debug('::'+Copy(LeftSide,Bound(Length(LeftSide)-Displacer,1,Length(LeftSide)),Bound(Displacer,1,Length(LeftSide))));
                   DebugForm.Debug('::'+ReplaceWhat);
                   DebugForm.Debug('::'+Copy(RightSide,1,Displacer));
                   DebugForm.Debug('::'+Copy(LeftSide,Bound(Length(LeftSide)-Displacer,1,Length(LeftSide)),Bound(Displacer,1,Length(LeftSide))));
                   DebugForm.Debug('::'+ReplaceBy);
                   DebugForm.Debug('::'+Copy(RightSide,1,Displacer));
           {$ENDIF}

          ReplaceForm.LoadLine(
                Copy(LeftSide,
                     Bound(Length(LeftSide) - Displacer, 1, Length(LeftSide)),
                     Length(LeftSide)), // Bound(Displacer, 1, Length(LeftSide))), {+}
                ReplaceWhat,
                Copy(RightSide, 1, Displacer),
                Copy(LeftSide,
                     Bound(Length(LeftSide) - Displacer, 1, Length(LeftSide)),
                     Length(LeftSide)), // Bound(Displacer, 1, Length(LeftSide))){+},
                ReplaceBy,
                Copy(RightSide, 1, Displacer));

          case ReplaceForm.ShowModal of
           mrYes: {do replace}
                  CanReplace:=True;
           mrNo:  {don't replace}
                  CanReplace:=False;
           10002: {yes to all in current file}
                  begin
                  ReplaceAllCurrent:=True;
                  CanReplace:=True;
                  end;
           10003: {no to all in current file}
                  begin
                  DontReplaceCurrent:=True;
                  CanReplace:=False;
                  end;
           10000: {yes to all in all files}
                  begin
                  ReplaceAll:=True;
                  CanReplace:=True;
                  end;
           10001: {no to all in all files (cancel)}
                  begin
                  DontReplaceCurrent:=True;
                  InterruptReplace:=True;
                  CanReplace:=False;
                  end;
           end;
          {with ReplaceForm do begin
             Free;
             end;}
           end;
          {confirm the replacement}
        end else begin
           CanReplace:=False;
           end;{can replace whole}
        ReadLine:=leftside;
        if CanReplace then begin
           inc(CurrentStats.occurrencesReplaced);

           if EditText.IsRightSplit(i) then begin
                if (XReplaceOptions.Repl.IncludeSource) or (GridContents[i].Inter) then
                   ReadLine:=Concat(ReadLine, GetRightSide(i), XID(MissingPart + GetRightSplitSide(i))) else
                   ReadLine:=Concat(ReadLine, GetRightSide(i), GetRightSplitSide(i));
              end
           else if EditText.IsLeftSplit(i) and (XReplaceOptions.Repl.IncludeSource or GridContents[i].Inter) then
              ReadLine:=Concat(ReadLine,GetLeftSide(i),XID(GetRightSide(i) + GetLeftSplitSide(i)))
              else ReadLine:=Concat(ReadLine,XID(GetRightSide(i)));
        end else
            if EditText.IsLeftSplit(i) then ReadLine:=Concat(ReadLine,MissingPart)
               else ReadLine:=Concat(ReadLine,ReplaceWhat{GetLeftSide(i)});

           FinalResult:=Concat(FinalResult, ReadLine);
           ReadLine:=RightSide;

           end else begin
               FinalResult:=Concat(FinalResult, ReadLine);
               break; {occurrence}
               end;

           end;
        xrpStatusBar.Panels[0].Text:='Still working, (total of '+IntToStr(CurrentStats.occurrencesFound)+' occurrence(s) found - '+IntToStr(CurrentStats.occurrencesReplaced)+' replaced)';
        xrpStatusBar.Update;
        ReadLine:=FinalResult;
      except
         MyExceptionHandler(Self);
      end;
   end;

function TxRepl32.CheckGridValid:boolean;
var
   i:integer;
begin
     with xRepl32 do begin
     try
     if TreeView1.isEmpty then begin
        Result:=False;
        if ErrorMessages then
        MsgForm.MessageDlg('Nothing to do, there are no tagged files.',
                           'To perform a successful replacement, you must select files you wish to replace strings in.',
                           mtError,[mbOk],0,'');
        XRepl32.ReplaceLog.CleanLog('     error, no selected files.');
        exit;
        end;
     for i:=1 To StringGrid1.RowCount-1 do
        if GetLeftSide(i)='' then begin
           Result:=False;

           if ErrorMessages then
           MsgForm.MessageDlg('Nothing to do!','The replacements grid is either empty or contains lines with empty source. '+
                              'Please check the replacements grid and try again.',mtError,[mbOk],0,'');
           XRepl32.ReplaceLog.CleanLog('     error, replacements grid invalid or empty.');
           exit;
           end;

     Result := False;
     for i:=1 to StringGrid1.RowCount-1 do
         if EditText.isEnabled(i) and (not AllEmpty(i)) then begin
            Result := True;
            break;
            end;

     {$IFDEF Debug}DebugForm.Debug('TxRepl32.GetGridValid:(succeeded):'+Self.ClassName);{$ENDIF}
     except
        MyExceptionHandler(StringGrid1);
        Result:=False;
     end;
     end;
end;

procedure TxRepl32.Quit1Click(Sender: TObject);
begin
     try
      SBQuitClick(Self);
     except
          MyExceptionHandler(Sender);
     end;
end;

procedure TxRepl32.StringGrid1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
          {procedure ManualRepaint;
          var
             i, j: LongInt;
          begin
               with StringGrid1 do
               for i:=TopRow to TopRow + VisibleRowCount do
                   for j:=0 to ColCount - 1 do
                       OnDrawCell(Sender, j, i, CellRect(j, i), []);
               end;}
var
   ACol, ARow: LongInt;
begin
   try
   If (Source = FileListBox1) then begin
      Accept:=True
      end else
   if (Source = StringGrid1) then begin
      if Sender = EditText then ARow:=EditText.EditRow
         else StringGrid1.MouseToCell(X, Y, ACol, ARow);
      if ARow >= 1 then begin
         if (ARow <= StringGrid1.TopRow) and (ARow >= 2) then begin
            StringGrid1.TopRow:=stringGrid1.TopRow - 1;
            DraggingOver:=True;
         end else if (ARow >= StringGrid1.TopRow + StringGrid1.VisibleRowCount) then begin
            StringGrid1.TopRow:=StringGrid1.TopRow + 1;
            DraggingOver:=True;
            end;
         anchorDragRow:=ARow;
         StringGrid1.Repaint;
         DraggingOver:=False;
         xrpStatusBar.Panels[0].Text:='row '+IntToStr(anchorRow) + ' to ' + IntToStr(anchorDragRow);
         Accept:=True;
         end;
      end else Accept:=False;
   finally
          DraggingOver:=False;
   end;
   end;

procedure TxRepl32.StringGrid1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
   Prop: PCellProps;
begin                                                                            {$IFDEF Debug}DebugForm.Debug('TxRepl32.StringGrid::drop from '+Source.ClassName);{$ENDIF}
   if Source = FileListBox1 then SBrpLoadClick(FileListBox1)
   else if Source = StringGrid1 then begin
        if (anchorRow <> anchorDragRow) then begin

           CloseEditText;
           EditText.Visible:=False;
           new(Prop);
           Prop^ := GridContents^[anchorRow]^;

           if Hi(GetKeyState(VK_SHIFT))=255 then begin
              InsertRow(anchorDragRow);
              GridContents^[anchorDragRow]^:=Prop^;
              end else if Hi(GetKeyState(VK_CONTROL))=255 then begin
              GridContents^[anchorRow]^:=GridContents^[anchorDragRow]^;
              GridContents^[anchorDragRow]^:=Prop^;
              end else begin
              if anchorRow < anchorDragRow then inc(anchorDragRow);
              SetLeftSide(anchorRow, '');
              SetRightSide(anchorRow, '');
              SetLeftSplitSide(anchorRow, '');
              SetRightSplitSide(anchorRow, '');
              InsertRow(anchorDragRow);
              GridContents^[anchorDragRow]^:=Prop^;
              end;

           dispose(Prop);
           EditText.EditRow:=anchorDragRow;
           EditText.Visible:=True;
           UpdateGrid;
           EditText.EditChange(Sender);
           if EditText.Showing then EditText.SetFocus;
           end;
        end;
   end;

procedure TxRepl32.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   with M.WindowPos^ do begin
      if cx<=FormWidth then cx:=FormWidth;
      if cy<=FormHeight then cy:=FormHeight;
      if not XReplaceOptions.Gen.ShiftOut then begin
         if (cx<>Width) or (cy<>Height) then begin
           if x<0 then begin cx:=cx+x; x:=0; end;
           if y<0 then begin cy:=cy+y; y:=0; end;
           if x+cx>Screen.Width then cx:=Screen.Width-x;
           if y+cy>Screen.Height then cy:=Screen.Height-y;
         end else begin
           if x<0 then x:=0;
           if y<0 then y:=0;
           if x+cx>Screen.Width then x:=Screen.Width-cx;
           if y+cy>Screen.Height then y:=Screen.Height-cy;
         end;
      end;
      end;
  end;

procedure TxRepl32.Help2Click(Sender: TObject);
begin
   ShowHelp('index.html');
   end;

procedure TxRepl32.AboutXReplace321Click(Sender: TObject);
begin
  initXOptions;
  XOptions.ShowAbout;
  end;

procedure TXRepl32.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
   inherited;
   with Msg.MinMaxInfo^ do begin
      if ptMinTrackSize.x<FormWidth then ptMinTrackSize.x:= FormWidth;
      if ptMinTrackSize.y<FormHeight then ptMinTrackSize.y:= FormHeight;
      if ptMaxTrackSize.x>Screen.Width then ptMaxTrackSize.x:=Screen.Width;
      if ptMaxTrackSize.y>Screen.Height then ptMaxTrackSize.y:=Screen.Height;
      end;
   end;

procedure ReplaceThread.Execute;
var
   RString: string;
begin
   with xrepl32 do begin
      PerformingReplace:=True;
      ReplaceLog.Init(XReplaceOptions.Log);
      ReplaceLog.oLog('replacements operation started.','',XReplaceOptions.Log.Header);

      MakeReplacements;

      UpdateGrid;
      PerformingReplace:=False;
      if XReplaceOptions.Log.Header then begin
         RString:='replacements operation terminated';

         if ReplaceStats.occurrencesFound<>0 then begin
            RString:=RString+#13#10+'     Total of '+IntToStr(ReplaceStats.occurrencesFound)+' occurrence(s) found.';

            if ReplaceStats.occurrencesReplaced<>0 then
               RString:=RString+#13#10+'     Total of '+IntToStr(ReplaceStats.occurrencesReplaced)+' replacement(s) made.'
               else RString:=RString+#13#10+'     No replacements made.';

            end else RString:=RString+#13#10+'     No occurrences found.';

         ReplaceLog.Log(RString);
         end;
      if (XReplaceOptions.Log.Edit) and (XReplaceOptions.Log.Create) then
         TExecute.Create(WinDir+'\'+'NOTEPAD.EXE', XReplaceOptions.Log.LogFile, 0);
      end;
   end;

procedure TxRepl32.FileExecute(FileName: string);
var
   ShellRes: integer;
begin
   try
   ShellRes:=0;
   if not XReplaceOptions.Gen.DefaultViewerOnly then
   ShellRes:=ShellExecute(Self.Handle,'open',
                PChar(FileName),
                nil,PChar(ExtractFilePath(FileName)), SW_SHOWNORMAL);
   if (ShellRes < 32) or (XReplaceOptions.Gen.DefaultViewerOnly) then begin
      if FileExists(XReplaceOptions.Hidden.ViewerDirectory+'\'+XReplaceOptions.Hidden.Viewer) then
         TExecute.Create(XReplaceOptions.Hidden.ViewerDirectory+'\'+XReplaceOptions.Hidden.Viewer, FileName, 0)
         else begin
         XReplaceOptions.Hidden.ViewerDirectory:=Windir;
         XReplaceOptions.Hidden.Viewer:='NOTEPAD.EXE';
         TExecute.Create(WinDir+'\'+'NOTEPAD.EXE', FileName, 0);
         end;
         end;
   except
   end;
   end;

procedure TxRepl32.FileListBox1DblClick(Sender: TObject);
var
   LDirectory: string;
   LFile: string;
begin
   LDirectory:=ShellSpace.Directory;
   LFile := Bs(FileListBox1.Directory) + FileListBox1.Items[FileListBox1.ItemIndex];
   if FileExists(LFile) then FileExecute(LFile) else
   if DirectoryExists(LFile) then ShellSpace.Directory := LFile;
   end;

procedure TSpaceMemo.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
   iss: integer;
begin
   try
   if (GetKeyState(VK_INSERT) = 1) then xRepl32.xrpStatusBar.Panels[1].Text := 'Ovewrite'
   else xRepl32.xrpStatusBar.Panels[1].Text := 'Insert';                    
   if (GetKeyState(VK_INSERT) = 1) and (Key >= 32) and (KeyPressed) then
      if Ord(Text[SelStart+1]) > 32 then begin
         iSs := SelStart;
         Text := Copy(Text, 1, SelStart) + Copy(Text, SelStart + 2, Length(Text));
         SelStart := iSs;
         end;
   except
   end;
   if xRepl32.anchorDragging then xRepl32.StringGrid1.Repaint;
   end;

procedure TSpaceMemo.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
//   MyRect: TRect;
     EditEmpty: boolean;
begin
   {   if Key=112 then xRepl32.Help2Click(Sender);}
   KeyPressed := False;
   if xRepl32.anchorDragging then xRepl32.StringGrid1.Repaint;

   if Hi(GetKeyState(VK_CONTROL))=255 then begin

   if Key in [38,40, 39, 37] then begin
      if xRepl32.AllEmpty(EditRow) then EditEmpty:=True else EditEmpty:=False;

      xRepl32.CloseEditText;
      Visible:=False;
      xREpl32.UpdateGrid;
      {39 - right, 40 - down, 37 - left, 38 - up}
      case Key of
         37: begin
                if (EditCol = 1) and EditRSRight then begin
                   EditRSRight := False;
                   EditRSLeft  := True;
                   end else
                if (EditCol = 1) and (IsLeftSplit(EditRow)) then begin
                   EditLSRight := True;
                   EditLSLeft  := False;
                   EditRSLeft  := False;
                   EditCol := 0;
                   end else
                if (EditCol = 0) and EditLSRight then begin
                   EditLSLEft := True;
                   EditLSRight:= False;
                   end else begin
                   EditRSLeft:=False;
                   EditCol := 0;
                   end;
                end;
         39: begin
                  if (EditCol = 0) and EditLSLeft then begin
                     EditLSRight:=True;
                     EditLSLeft:=False;
                     end else
                  if (EditCol = 0) and (IsRightSplit(EditRow)) then begin
                     EditLSRight := False;
                     EditRSLeft := True;
                     EditRSRight := False;
                     EditCol := 1;
                     end else
                  if (EditCol = 1) and EditRSLeft then begin
                     EditRSLeft := False;
                     EditRSRight:= True;
                     end else begin
                     EditCol := 1;
                     EditLSRight:=False;
                     end;
                  end;
         40: begin
             if EditRow < xRepl32.StringGrid1.RowCount-1 then begin
                if not EditEmpty then EditRow := EditRow + 1;

                if (EditCol = 0) and IsLeftSplit(EditRow) then begin
                   EditLSLeft := True;
                   EditLSRight := False;
                   end else
                if (EditCol = 1) and IsRightSplit(EditRow) then begin
                   EditRSLeft:=True;
                   EditRSRight:=False;
                   end else begin
                   EditRSLeft:=False;
                   EditRSRight:=False;
                   EditLSRight:=False;
                   EditLSLeft:=False;
                   end;

                end;
             end;
         38: begin
             if EditRow >= 2 then begin
                EditRow := EditRow - 1;

                if (EditCol = 0) and IsLeftSplit(EditRow) then begin
                   EditLSLeft := True;
                   EditLSRight := False;
                   end else
                if (EditCol = 1) and IsRightSplit(EditRow) then begin
                   EditRSLeft:=True;
                   EditRSRight:=False;
                   end else begin
                   EditRSLeft:=False;
                   EditRSRight:=False;
                   EditLSRight:=False;
                   EditLSLeft:=False;
                   end;

                end;
             end;

         end;
      xRepl32.MakeVisible(EditRow);
      xRepl32.OpenEditText(True);
      end;

      if Hi(GetKeyState(VK_MENU))=255 then begin
      Case UpCase(Chr(Key)) of
         'D': if xRepl32.SbRpDisable.Enabled then xRepl32.SbRpDisable.Click;
         'I': if xRepl32.SbRpInclude.Enabled then xRepl32.SbRpInclude.Click;
         'C': if xRepl32.SbRpCaseSens.Enabled then xRepl32.SbRpCaseSens.Click;
         'W': if xRepl32.sbRpWholeOnly.Enabled then xRepl32.sbRpWholeOnly.Click;
         'P': if xRepl32.sbRpPrompt.Enabled then xRepl32.sbRpPrompt.Click;
         'S': if xRepl32.sbRpSplitLeft.Enabled then xRepl32.sbRpSplitLeft.Click;
         'L': if xRepl32.sbRpSplitRight.Enabled then xRepl32.sbRpSplitRight.Click;
         'X': if xRepl32.sbRpRemove.Enabled then xRepl32.sbRpRemove.Click;
         'T': if xRepl32.sbRpInsertLine.Enabled then xRepl32.sbRpInsertLine.Click;
         end;
      end;

    end;

   end;

procedure TxRepl32.UpdateGrid;
var
   i: integer;
begin
      {$IFDEF Debug}DebugForm.Debug('TxRepl32.UpdateGrid entry');{$ENDIF}
      with xRepl32.StringGrid1 do begin
      if RowCount>2 then
         for i:=1 to RowCount-2 do
             if AllEmpty(i) then begin
                xRepl32.RemoveRow(i);
                break;
                end;

      if not AllEmpty(RowCount-1) then begin
         RowCount := RowCount + 1;
         AddCellProps;
         end;

      if AllEmpty(RowCount-1) and AllEmpty(RowCount-2) then xRepl32.RemoveRow(RowCount-1);
      end;
      {$IFDEF Debug}DebugForm.Debug('TxRepl32.UpdateGrid term');{$ENDIF}
   end;

procedure TSpaceMemo.EditKeyPress(Sender: TObject; var Key: Char);
var
   //MyRect: Trect;
   LineCount:LongInt;
begin
   try
   if Key = Chr(10) then begin

      xRepl32.CloseEditText;

      Visible:=False;
      LineCount:=xRepl32.StringGrid1.RowCount;
      xRepl32.UpdateGrid;
      if xRepl32.StringGrid1.Showing then xRepl32.StringGrid1.SetFocus;
      with xRepl32 do begin
        if LineCount>xRepl32.StringGrid1.RowCount then begin
           Editcol:=0;
           end else
        if EditCol = 0 then begin
           if EditLSRight or (not IsLeftSplit(EditRow)) then begin
              EditCol := 1;
              EditRSRight:=False;
              if IsRightSplit(EditRow) then EditRSLeft:=True else EditRSLeft:=False;
              end;
           end else begin
           if XRepl32.StringGrid1.RowCount-2 >= EditRow then EditRow := EditRow + 1;
           EditCol:=0;
           EditLSRight:=False;
           if IsLeftSplit(EditRow) then EditLSLeft:=True else EditLSLeft:=False;
           end;
         MakeVisible(EditRow);
         //with StringGrid1 do MyRect:=CellRect(EditCol,EditRow);
         //if (EditCol=0) and (IsLeftSplit(EditRow)) then with MyRect do Left:=(Right-Left) div 2;
         //StringGrid1MouseDown(Self, mbLeft, [], MyRect.Left+1, MyRect.Top+1);
         xRepl32.OpenEditText(True);
         Key:=Chr(0);
         xRepl32.UpdateGrid;
         end;

      end else
   if Key=Chr(27) then begin
      xRepl32.CloseEditText;
      SelStart:=Length(Text);
      SelLength:=0;
      Perform(EM_SCROLLCARET,0,0);
      end else begin
      KeyPressed := True;
      end;
   except
      xRepl32.MyExceptionHandler(Sender);
   end;
   end;

function TSpaceMemo.GetItemHeight(Font: TFont): Integer;
var
   DC: HDC;
   SaveFont: HFont;
   Metrics: TTextMetric;
begin
   try
   DC := GetDC(0);
   SaveFont := SelectObject(DC, Font.Handle);
   GetTextMetrics(DC, Metrics);
   SelectObject(DC, SaveFont);
   ReleaseDC(0, DC);
   Result := Metrics.tmHeight;                                                   {$IFDEF Debug}DebugForm.DebugDouble('TSpaceMemo::GetItemHeight for '+Font.Name+'::succeeded:'+IntToStr(Result));{$ENDIF}
   except
      GetItemHeight:=13;
      xRepl32.MyExceptionHandler(Application);
   end;
   end;

procedure TSpaceMemo.EditChange(Sender: TObject);
var
  {j, }i, LinesCount, NewHeight, NewTop, TmpHeight, OldTop : LongInt;
  R: TRect;
begin
   try
   if Application.Terminated then exit;

   if NtBug then begin
      R := Rect(0,-1,ClientWidth,ClientHeight+1);
      SendMessage(Self.Handle, EM_SETRECT, 0, Longint(@R));
      end;

   LinesCount:=1;
   for i:=1 to Length(Text) do if Text[i]=Chr(13) then inc(LinesCount);
   if Lines.Count>LinesCount then LinesCount:=Lines.Count;

   TmpHeight:=xRepl32.StringGrid1.Height;//(xRepl32.ClientHeight-xRepl32.VBPanel.Height-xRepl32.xrpStatusBar.Height);
   OldTop:=xRepl32.StringGrid1.Top + (EditRow-xRepl32.StringGrid1.TopRow+1)*(xRepl32.StringGrid1.RowHeights[EditRow]+xRepl32.StringGrid1.GridLineWidth);
   NewHeight:=LinesCount*ItemHeight+6; {valid if grid linewidth stays at 1}
   If (NewHeight)<=(TmpHeight-OldTop) then NewTop:=OldTop else NewTop:=TmpHeight-NewHeight;
   if NewHeight>=TmpHeight then begin
      NewHeight:=(TmpHeight div ItemHeight-1)*ItemHeight+6;
      NewTop:=TmpHeight-NewHeight;
      Height:=NewHeight;
      Top:=NewTop;
      end else if NTBug then begin
         Height:=NewHeight;
         Top:=NewTop;
         R := Rect(0,-1,ClientWidth,ClientHeight+15);
         Perform(EM_SETRECTNP, 0, Longint(@R));
         end else begin
            Height:=NewHeight;
            Top:=NewTop;
            end;

  if NtBug then begin
     i:=(Height div ItemHeight-1);
     i:=LinesCount-i;
     Perform(EM_LINESCROLL,0,i-Perform(EM_GETFIRSTVISIBLELINE,0,0)-1);
     Perform(EM_SCROLLCARET,0,0);
     end;

  {$IFDEF Debug}DebugForm.Debug('TSpaceMemo::EditChange::EditLSRSRight:'+BoolToStr(EditLSRight)+'/'+BoolToStr(EditRSRight) + '/' + BoolToStr(EditLSLeft)+'/'+BoolToStr(EditRSLeft));{$ENDIF}

   with xRepl32 do begin
      if ((EditLSRight or EditLSLeft and (EditCol = 0)) or
          (EditRSRight or EditRSLeft and (EditCol = 1))) then
              Self.Width:=StringGrid1.ColWidths[EditCol] div 2 + 2 else
              Self.Width:=StringGrid1.ColWidths[EditCol] + 2;

      if (EditLSRight and (EditCol = 0)) then
         Self.Left:=StringGrid1.Left+(StringGrid1.ColWidths[EditCol] +StringGrid1.GridLineWidth) div 2
      else if (EditRSRight and (EditCol = 1)) then
         Self.Left:=StringGrid1.Left+(StringGrid1.ColWidths[EditCol] +StringGrid1.GridLineWidth) div 2 + EditCol * (StringGrid1.ColWidths[EditCol] + StringGrid1.GridLineWidth)
      else Self.Left:=StringGrid1.Left+(StringGrid1.ColWidths[EditCol]+StringGrid1.GridLineWidth)*(EditCol);

      end;                                                                       {$IFDEF Debug}DebugForm.DebugDouble('TSpaceMemo::EditChange::from '+Sender.ClassName+'::visible::'+BoolToStr(Visible)+'::succeeded.');{$ENDIF}

   {$ifdef Registered}
   with xRepl32 do begin
      if GridContents[EditRow].LeftSplit then begin
         sbRpInclude.Enabled:=True;
         sbRpSplitRight.Enabled:=True;
         end else begin
         sbRpInclude.Enabled:=False;
         sbRpSplitRight.Enabled:=False;
         end;
      if AllEmpty(EditRow) then begin
         sbRpInclude.Enabled:=False;
         sbRpCaseSens.Enabled:=False;
         sbRpWholeOnly.Enabled:=False;
         sbRpPrompt.Enabled:=False;
         sbRpDisable.Enabled:=False;
         end else begin
         sbRpCaseSens.Enabled:=True;
         sbRpWholeOnly.Enabled:=True;
         sbRpPrompt.Enabled:=True;
         sbRpDisable.Enabled:=True;
         end;
      if XReplaceOptions.Repl.RegExp then begin
         SbRpSplitLeft.Enabled := False;
         SbRpReverse.Enabled := False;
         SbRpSplitRight.Enabled := False;
         sbRpCaseSens.Enabled:=False;
         sbRpWholeOnly.Enabled:=False;
         end else begin
         SbRpSplitLeft.Enabled := True;
         SbRpReverse.Enabled := True;
         end;
      end;
   {$endif}

   xRepl32.UpdateGrid;
   {$ifdef Registered}
   //xRepl32.numChoose.Redraw;
   {$endif}
   except
   end;
   end;

{$ifdef Registered}
procedure txRepl32.SortGrid(Cat: integer);
procedure QSortGrid(left, right: integer);
var
   Pivot: integer;
   iStr: string;
   Prop: PCellProps;
   i, j: integer;
begin
       i := left;
       j := right;
       Pivot := (left + right) div 2;
       repeat
          iStr := GetSideStr(Pivot, Cat);

          while (CompareText(GetSideStr(i, Cat), iStr) < 0) do inc(i);
          while (CompareText(GetSideStr(j, Cat), iStr) > 0) do dec(j);
          if (i <= j) then begin
             //ShowMessage('Exchanging ' + GetSideStr(i, Cat) + ' -> ' + GetSideStr(j, Cat));
             Prop := GridContents[j];
             GridContents[j] := GridContents[i];
             GridContents[i] := Prop;
             inc(i);
             dec(j);
             end;
          until i > j;

          if i > right then exit;
          if j < left then exit;
          QSortGrid(left, j);
          QSortGrid(i, right);
       end;
begin
     CloseEditText;
     EditText.Text:='';
     EditText.Visible:=False;
     UpdateGrid;
     if (Cat in [0,1]) and (GridCount > 2) then QSortGrid(1, GridCount-2);
     UpdateGrid;
     StringGrid1.Repaint;
     SetGridEdit;
     end;
{$endif}

procedure TxRepl32.StringGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
          {$ifdef Registered}
          procedure SetOptionsCol(ARow, CCol, X: LongInt);
          begin
               try
               {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::SetOptionsCol() - ' + IntToStr(CCol)+'/'+IntToStr(ARow)+'/'+IntToStr(X));{$ENDIF}
                if AllEmpty(ARow) then exit;
                if (CCol = 2) then
                   with StringGrid1 do begin
                        X := X - ColWidths[0] - ColWidths[1];
                        if X < (RowHeights[0] + 4) then sbRpInclude.Click
                        else if X < 2*(RowHeights[0] + 4) then sbRpCaseSens.Click
                        else if X < 3*(RowHeights[0] + 4) then sbRpWholeOnly.Click
                        else if X < 4*(RowHeights[0] + 4) then sbRpPrompt.Click;
                        end;
               except
               end;
               end;
          procedure SetDragRow(ARow, CCol: LongInt);
          begin
               try
               {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::SetDragRow() - '+IntToStr(ARow)+'/'+IntToStr(CCol));{$ENDIF}
               if (CCol = 3) then begin
                  if AllEmpty(ARow) then exit;
                  StringGrid1.BeginDrag(False);
                  anchorRow:=ARow;
                  anchorDragging:=True;
                  end;
               except
               end;
               end;
          {$endif}
var
   CR, RC, ARow, ACol: Longint;
   {$ifdef Registered}
   CCol, CX: LongInt;
   {$endif}
   EditingLeft, EditingRight: boolean;
   GELeft, GERight: boolean;
   aPoint: TPoint;
begin
   try
   //if Button <>mbLeft then exit;
   StringGrid1.MouseToCell(X, Y, ACol, ARow);                                       {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::Init::from '+Sender.ClassName+'::mousedown on cell '+IntToStr(ACol)+'/'+IntToStr(ARow));{$ENDIF}
   {$ifdef Registered}
   CX := X;
   {$endif}
   CR:=EditText.EditRow;
   RC:=StringGrid1.RowCount;

   if ARow < 0 then begin
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::ARow<0,exit');{$ENDIF}
      exit;
      end;

   if ARow = 0 then begin
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::ARow=0');{$ENDIF}
      {$ifdef Registered}
      SortGrid(ACol);
      {$else}
      MessageDlg('Grid sorting is a registered version feature! Please DO register!', mtWarning, [mbOk], 0);
      {$endif}
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::grid sorted, exit');{$ENDIF}
      exit;
      end;

   {$ifdef Registered}
   CCol := ACol;
   if (ACol = 2) or (ACol = 3) then begin
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S1');{$ENDIF}
      ACol:=EditText.EditCol;
      if EditText.EditLSRight or EditText.EditRSRight then
         X:=StringGrid1.ColWidths[ACol] div 2 + (ACol * StringGrid1.ColWidths[0]) else X:=1;
      end;
      {$endif}

   if (EditText.IsLeftSplit(ARow) and (ACol = 0)) or
      (EditText.IsRightSplit(ARow) and (ACol = 1)) then begin
       {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S2');{$ENDIF}
       if (X >= (StringGrid1.ColWidths[ACol] div 2) + (ACol * StringGrid1.ColWidths[0])) then begin
          {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S3');{$ENDIF}
          EditingRight:=True;
          EditingLeft:=False;
          end else begin
          {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S4');{$ENDIF}
          EditingRight:=False;
          EditingLeft:=True;
          end;
       end else begin
       {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S5');{$ENDIF}
       EditingRight:=False;
       EditingLeft:=False;
       end;

          with EditText do begin
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S6');{$ENDIF}
        if ACol = 0 then begin
           {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S7');{$ENDIF}
           GELeft:=EditLSLeft;
           GERight:=EditLSRight;
           end else begin
           {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S8');{$ENDIF}
           GELeft:=EditRSLeft;
           GERight:=EditRSRight;
           end;

      if Visible and
        (GERight = EditingRight) and
        (GELeft = EditingLeft) and
        (EditCol = ACol) and
        (EditRow = ARow)
          then begin
               {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S9');{$ENDIF}
               {$ifdef Registered}
               SetOptionsCol(ARow, CCol, CX);
               SetDragRow(ARow, CCol);
               {$endif}
               exit;
               end;

      if Visible then begin
         {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S10');{$ENDIF}
         CloseEditText;
         end;

      EditCol:=ACol;
      EditRow:=ARow;

      if ACol = 0 then begin
         {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S11');{$ENDIF}
         EditLSRight:=EditingRight;
         EditLSLeft:=EditingLeft;
         EditRSRight:=False;
         EditRSLeft:=False;
         end else
      if ACol = 1 then begin
         {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S12');{$ENDIF}
         EditLSRight:=False;
         EditLSLeft:=False;
         EditRSRight:=EditingRight;
         EditRSLeft:=EditingLeft;
         end;
         //----------.-.-
      try MakeVisible(ARow); except end; {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S13');{$ENDIF}
      try OpenEditText(True); except end; {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S14');{$ENDIF}
      try Top:=StringGrid1.Top+(ARow-StringGrid1.TopRow+1)*(StringGrid1.RowHeights[ARow]+StringGrid1.GridLineWidth); except end;
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S15');{$ENDIF}
      try EditChange(Sender); except end; {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S16');{$ENDIF}
      {SelStart:=Length(Text);
      SelLength:=0;}
      SelStart:=0;
      SelLength:=Length(Text);

      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S17');{$ENDIF}
      Perform(EM_SCROLLCARET,0,0);

      if (RC>StringGrid1.RowCount) and (ARow>CR) then begin
         {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S18');{$ENDIF}
         MakeVisible(ARow - 1);
         OpenEditText(True);
         end;

      {$ifdef Registered}
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S19 (IMPORTANT)');{$ENDIF}
      SetOptionsCol(ARow, CCol, CX);
      {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S20');{$ENDIF}
      SetDragRow(ARow, CCol);
      {$endif}
      end;

      if (Button = mbRight) {$ifdef Registered}and (CCol in [0,1]){$endif} then begin
         {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S21');{$ENDIF}
         aPoint.X := X;
         aPoint.Y := Y;
         aPoint := StringGrid1.ClientToScreen(aPoint);
         PrepareRowStats(StringGrid1);
         RGridMenu.Popup(aPoint.X,aPoint.Y);
         end;

      finally
         {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::condition S22');{$ENDIF}
         if EditText.Visible then xRepl32.ActiveControl:=EditText;
         //EditText.MouseDown(Button, Shift, X, Y);
      end;

   end;

procedure TxRepl32.PrepareRowStats(Sender: TObject);
begin
     ShowRowStatistics1.Enabled := not AllEmpty(EditText.EditRow);
     RowStats.Enabled := ShowRowStatistics1.Enabled;
     {$ifdef Registered}
     if ShowRowStatistics1.Enabled then
         RowStats.Caption := IntToStr(GridContents[EditText.EditRow].occurrencesReplaced) +
                             ' / ' +
                             IntToStr(GridContents[EditText.EditRow].occurrencesReplaced)
         else RowStats.Caption := '(no statistics available)';
     EnableDisableRow.Enabled := xRepl32.sbrpDisable.Enabled;
     {$endif}
     IncSourceMenu.Enabled := xRepl32.sbRpInclude.Enabled and xRepl32.sbRpInclude.Visible; IncSourceMenu.Checked := GridContents[EditText.EditRow].Inter;
     CaseSensMenu.Enabled := xRepl32.sbRpCaseSens.Enabled and xRepl32.sbRpCaseSens.Visible; CaseSensMenu.Checked := GridContents[EditText.EditRow].CaseSens;
     WholeWordMenu.Enabled := xRepl32.sbRpWholeOnly.Enabled and xRepl32.sbRpWholeOnly.Visible; WholeWordMenu.Checked := GridContents[EditText.EditRow].WholeWord;
     PromptMenu.Enabled := xRepl32.sbRpPrompt.Enabled and xRepl32.sbRpPrompt.Visible; PromptMenu.Checked := GridContents[EditText.EditRow].Prompt;
     RowOptionsMenu.Enabled := PromptMenu.Enabled or WholeWordMenu.Enabled or CaseSensMenu.Enabled or IncSourceMenu.Enabled;
     end;

procedure TxRepl32.SbRpClearClick(Sender: TObject);
begin
   PrepareLoadforGrid;                                                          {$IFDEF Debug}DebugForm.Debug('TxRepl32::from '+Sender.ClassName+'::clear string grid::succeeded.');{$ENDIF}
   StringGrid1MouseDown(Self, mbLeft, [], StringGrid1.CellRect(0,1).Left+1, StringGrid1.CellRect(0,1).Top+1);
   end;

procedure TxRepl32.StringGrid1TopLeftChanged(Sender: TObject);
begin
   try
   if Application.Terminated then exit;
      try
      if EditText.Visible then begin
      if (EditText.EditRow>=StringGrid1.TopRow) and
         (EditText.EditRow<=StringGrid1.TopRow+StringGrid1.VisibleRowCount-1) then begin
          EditText.EditChange(Sender);
       end else begin
          CloseEditText;
          EditText.Visible:=False;
          end;
                                                                               {$IFDEF Debug}DebugForm.Debug('TStringGrid::TopLeftChanged::from '+Sender.ClassName+'::succeeded.');{$ENDIF}
      end;
      except
      end;
   except
       MyExceptionHandler(Sender);
   end;
   end;

function TxRepl32.GetSide(Row, Col: LongInt; Split: boolean): string;
begin
     if not Split then begin
        if Col = 0 then Result:=GetLeftSide(Row) else Result:=GetRightSide(Row);
        end else begin
        if Col = 0 then Result:=GetLeftSplitSide(Row) else Result:=GetRightSplitSide(Row);
        end;
     end;

procedure TxRepl32.StringGrid1DrawCell(Sender: TObject; Col, Row: Longint;ARect: TRect; State: TGridDrawState);
var
   {$ifdef Registered} iText: string;{$endif}
   ForceRefresh: boolean;
begin
   try
      {$IFDEF Debug}DebugForm.Debug('SDC::REG::S-1 - '+IntToStr(Col)+'/'+IntToStr(Row));{$ENDIF}
      with StringGrid1.Canvas do
           if Row = 0 then begin
              Brush.Color:=clNavy;
              Font.Color:=clWhite;
              Font.Name:='Times New Roman';
              Font.Style:=[fsItalic];
              Font.Size:=10;
              end else begin
                  if EditText.isEnabled(Row) then Brush.Color := clSilver else Brush.Color:=clGray;
                  if Col = 3 then begin
                     Font.Name:='Times New Roman';
                     Font.Style:=[fsItalic];
                     Font.Size:=8;
                     end else begin
                     Font := StringGrid1.Font;
                     end;
              end;

      if AnchorDragging and not DraggingOver then ForceRefresh:=False else ForceRefresh:=True;
      if AnchorDragging and (AnchorDragRow = Row) and (Col = 3) then
         if Hi(GetKeyState(VK_CONTROL))=255 then StringGrid1.Canvas.Brush.Color:=clOlive
         else if Hi(GetKeyState(VK_SHIFT))=255 then StringGrid1.Canvas.Brush.Color:=clLime
         else StringGrid1.Canvas.Brush.Color:=clYellow;

         try
            if (Col = 0) or (Col = 1) and ForceRefresh then begin

            if (EditText.IsLeftSplit(Row) and (Col = 0)) or
               (EditText.IsRightSplit(Row) and (Col = 1)) then begin
                    with ARect do begin
                         StringGrid1.Canvas.Rectangle(Left-1, Top-1, Left + (Right-Left) div 2+1, Bottom+1);
                         StringGrid1.Canvas.TextOut(Left+2,Top+1, GetSide(Row, Col, False));
                         StringGrid1.Canvas.Rectangle(Left + (Right-Left) div 2-1,Top-1, Right+1, Bottom+1);
                         StringGrid1.Canvas.TextOut(Left + (Right-Left) div 2+2,Top+2,GetSide(Row, Col, True));
                         exit;
                         end;
               end else begin //not split
                   with ARect do begin
                      StringGrid1.Canvas.Rectangle(Left-1, Top-1, Right+1, Bottom+1);
                      if Row = 0 then StringGrid1.Canvas.TextOut(Left+(StringGrid1.ColWidths[0] - StringGrid1.Canvas.TextWidth(GetSide(Row, Col, False))) div 2,Top - 1, GetSide(Row, Col, False))
                                 else StringGrid1.Canvas.TextOut(Left+2,Top+1, GetSide(Row, Col, False));
                      end;
               end;
            {end else if (Col = 1) and ForceRefresh then begin    //col = 1
                with ARect do begin
                   StringGrid1.Canvas.Rectangle(Left-1, Top-1, Right+1, Bottom+1);
                   if Row = 0 then StringGrid1.Canvas.TextOut(Left+(StringGrid1.ColWidths[0] - StringGrid1.Canvas.TextWidth(GetRightSide(Row))) div 2,Top - 1, GetRightSide(Row))
                              else StringGrid1.Canvas.TextOut(Left+2,Top+1, GetRightSide(Row));
                   end;}

                {$ifdef Registered}
              end else if (Col = 2) and ForceRefresh then begin
                   with ARect do begin
                   //if Row > 0 then StringGrid1.Canvas.Brush.Color:=clWhite;
                   {$IFDEF Debug}DebugForm.Debug('SDC::REG::S0 - '+IntToStr(Left-1)+'/'+IntToStr(Top-1)+'/'+IntToStr(Right+1)+'/'+IntToStr(Bottom+1));{$ENDIF}
                   StringGrid1.Canvas.Rectangle(Left-1, Top-1, Right+1, Bottom+1);
                   if Row = 0 then StringGrid1.Canvas.TextOut(Left+(StringGrid1.ColWidths[2] - StringGrid1.Canvas.TextWidth(gOptions)) div 2,Top - 1, gOptions)
                      else if not(AllEmpty(Row)) then begin

                      {$IFDEF Debug}DebugForm.Debug('SDC::REG::S1 - '
                        + IntToStr(Row) + ' - '
                        + BoolToStr(GridContents[Row].Inter and GridContents[Row].LeftSplit) + '/'
                        + BoolToStr(GridContents[Row].CaseSens) + '/'
                        + BoolToStr(GridContents[Row].WholeWord) + '/'
                        + BoolToStr(GridContents[Row].Prompt)
                              );{$ENDIF}


                      if GridContents[Row].Inter and GridContents[Row].LeftSplit then OptionsList.Draw(StringGrid1.Canvas, ARect.Left + 2, ARect.Top - 1, 0);
                      if GridContents[Row].CaseSens then OptionsList.Draw(StringGrid1.Canvas, ARect.Left + (StringGrid1.RowHeights[0] + 4), ARect.Top - 1, 1);
                      if GridContents[Row].WholeWord then OptionsList.Draw(StringGrid1.Canvas, ARect.Left + 2*(StringGrid1.RowHeights[0] + 3), ARect.Top - 1, 2);
                      if GridContents[Row].Prompt then OptionsList.Draw(StringGrid1.Canvas, ARect.Left + 3*(StringGrid1.RowHeights[0] + 3), ARect.Top - 1, 3);
                      end;
                   end;
                   end else if Col = 3 then begin
                       with ARect do begin
                            StringGrid1.Canvas.Rectangle(Left-1, Top-1, Right+1, Bottom+1);
                            iText:='('+IntToStr(Row) + ')';
                            if Row <> 0 then//then OptionsList.Draw(StringGrid1.Canvas, Left, Top, 4);
                               StringGrid1.Canvas.TextOut(Left+(StringGrid1.ColWidths[3] - StringGrid1.Canvas.TextWidth(iText)) div 2,Top + 1, iText)
                            end;
                   {$endif}
                   end;
            except
            end;

   except
      MyExceptionHandler(Sender);
   end;
   end;

procedure TxRepl32.ToggleSplit(Sender: TObject; Col: LongInt);
var
   RowToSplit: LongInt;
   isSplit: boolean;
begin
   try

   if EditText.Visible then begin
      CloseEditText;
      EditText.Visible:=False;
      RowToSplit:=EditText.EditRow;
      end else begin
      RowToSplit:=StringGrid1.Row;
      MakeVisible(RowToSplit);
      end;

      if Col = 0 then isSplit:=EditText.IsLeftSplit(RowToSplit)
      else if Col = 1 then isSplit:=EditText.IsRightSplit(RowToSplit)
      else exit;

      if isSplit then begin
         GridContents^[RowToSplit]^.RightSplit := False;
         if Col = 0 then GridContents^[RowToSplit]^.LeftSplit := False;

         with StringGrid1 do begin
            MakeVisible(RowToSplit);
            StringGrid1MouseDown(Sender, mbLeft, [], StringGrid1.CellRect(Col, RowToSplit).Left+1, StringGrid1.CellRect(Col, RowToSplit).Top+1);
            StringGrid1.Repaint;
            exit;
            end;
         end;
                                                                                 {$IFDEF Debug}DebugForm.Debug('SplitRows::not split '+IntToStr(RowToSplit)+ '/' + IntToStr(Col));{$ENDIF}
   if Col = 0 then begin
              GridContents^[RowToSplit]^.LeftSplit := True;
              end else if EditText.isLeftSplit(RowToSplit) then GridContents^[RowToSplit]^.RightSplit := True;
   StringGrid1MouseDown(Sender, mbLeft, [], StringGrid1.CellRect(Col,RowToSplit).Left+1, StringGrid1.CellRect(Col,RowToSplit).Top+1);
   StringGrid1.Repaint;
   except
   end;
   end;

procedure TxRepl32.SBRpSplitLeftClick(Sender: TObject);
begin
     {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::SbRpSplitLeftClick');{$ENDIF}
     ToggleSplit(Sender, 0);
     {$IFDEF Debug}with EditText do DebugForm.Debug('TxRepl32::GridSplitStatus::'+BoolToStr(IsLeftSplit(EditRow)) + '/' + BoolToStr(IsRightSplit(EditRow)));{$ENDIF}
     end;

procedure TxRepl32.MakeVisible(TheRow: LongInt);
var
   TR: LongInt;
begin
   try
   with StringGrid1 do begin
    {$IFDEF Debug}DebugForm.Debug('TxRepl32::GridStatus::TopRow:'+IntToStr(TopRow)+'::VisibleRowCount:'+IntToStr(VisibleRowCount)+'::Showing:'+IntToStr(TheRow));{$ENDIF}
      TR := TheRow - TopRow;
      if TR < 0 then begin
         TopRow:=TheRow;
         exit;
         end;
      if (TR < VisibleRowCount) then exit;
      TopRow := TheRow - VisibleRowCount;
      while(CellRect(0,TheRow).Bottom = 0) do TopRow := TopRow + 1;
      TopRow:= TopRow + 1;
      end;
   except
   end;
   end;

procedure TxRepl32.StringGrid1SelectCell(Sender: TObject; Col, Row: Longint; var CanSelect: Boolean);
begin
   CanSelect:=False;
   {MakeVisible(Row);}
   {StringGrid1MouseDown(Self, mbLeft, [], StringGrid1.CellRect(Col,Row).Left+1, StringGrid1.CellRect(Col,Row).Top+1);}
   end;

procedure TSpaceMemo.EditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   Screen.Cursor:=crDefault;
   end;

procedure TxRepl32.StringGrid1KeyPress(Sender: TObject; var Key: Char);
var
   MyRect: TRect;
begin
   if not EditText.Visible then begin
      MakeVisible(StringGrid1.Row);
      with StringGrid1 do MyRect:=CellRect(Col,Row);
      StringGrid1MouseDown(Self, mbLeft, [], MyRect.Left+1, MyRect.Top+1);
      SendMessage(EditText.Handle,WM_CHAR,Ord(Key),0);
      end;
   end;

procedure TxRepl32.TreeView1DropFinished(Sender: TObject);
begin
   MainPanel.Update;
   if TreeView1.Items.GetFirstNode<> nil then TreeView1.Items.GetFirstNode.Expand(False);
   ShellSpace.EndDrag(True);
   FileListBox1.EndDrag(True);
   UpdateSpecialConditions;
   if Edittext.Showing then EditText.SetFocus;
   EnableVirtuallyEverything;
   end;

procedure TxRepl32.TreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin
   DisableVirtuallyEverything;
   TreeView1.Multithread:=XReplaceOptions.Gen.PermanentResponse;
   if ForceNotPermanentResponse then TreeView1.Multithread:=False;
   end;

function TSpaceMemo.IsEnabled(const Row: LongInt): boolean;
begin
     if Row >= GridCount then Result := False else Result := not GridContents[Row].Disabled;
     end;

function TSpaceMemo.IsLeftSplit(const Row: LongInt): boolean;
begin
   if Row >= GridCount then Result := False else Result:=GridContents[Row].LeftSplit;
   end;

function TSpaceMemo.IsRightSplit(const Row: LongInt): boolean;
begin
   if Row >= GridCount then Result := False else Result:=GridContents[Row].RightSplit;
   end;

function TxRepl32.AllEmpty(const i: LongInt): boolean;
var
   LT, MT, RT, MR: string;
begin
   if (i < 0) or (i >= GridCount) then begin
      Result := False;
      exit;
      end;

   Result:=True;

   LT := GetLeftSide(i);
   RT := GetRightSide(i);
   MT := GetLeftSplitSide(i);
   MR := GetRightSplitSide(i);

   with EditText do
   if Visible then
      if EditRow = i then begin
         if EditLSRight then MT:=Text
         else if EditRSRight then MR:=Text
         else if EditCol = 0 then LT:=Text
         else if EditCol = 1 then RT:=Text;
         end;

   if EditText.IsLeftSplit(i) and (MT<>'') then Result:=False;
   if EditText.IsRightSplit(i) and (MR<>'') then Result:=False;
   if (LT<>'') or (RT<>'') then Result:=False;
   end;

procedure TxRepl32.CompactGrid;
var
   i: integer;
begin
   if EditText.Visible then begin
      CloseEditText;
      EditText.Visible:=False;
      end;
   with xRepl32.StringGrid1 do
        if RowCount > 2 then
           for i:=1 to RowCount-1 do
               if AllEmpty(i) then begin
                  xRepl32.RemoveRow(i);
                  break;
                  end;
   end;

procedure ReplaceThread.Create;
begin
   Execute;
   end;

procedure TxRepl32.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=27 then begin
      if EditText.Visible and EditText.Showing then EditText.SetFocus;
      end else
   if Key=112 then begin
      //if Application.MainForm.ActiveControl.Tag <> 0 then
      {WinHelp(Application.MainForm.Handle,
              PChar(Application.HelpFile),
              HELP_CONTEXTPOPUP,
              Application.MainForm.ActiveControl.Tag);}
              //else
      Help2Click(Sender);
      end;
   end;

procedure TxRepl32.SbFullSaveClick(Sender: TObject);
var
   ContainerHandle : Integer;
   doPrompt: boolean;
begin
   try
   DisableEverything;
   with StringGrid1 do begin
      CompactGrid;
      {prompt for a filename with browse}

        if Hi(GetKeyState(VK_SHIFT))=255 then begin
           if LoadedfullState <> '' then begin
              SaveDialog3.FileName:=LoadedFullState;
              doPrompt:=False;
              end else doPrompt:=True;
           end else doPrompt:=True;

      if doPrompt then
      if SaveDialog3.Execute=False then begin
         EnableEverything;
         UpdateGrid;
         SetGridEdit;
         exit;
         end;
      If SaveDialog3.Filename='' then begin
         EnableEverything;
         UpdateGrid;
         SetGridEdit;
         exit;
         end;

      OpenDialog1.FileName:=SaveDialog3.Filename;
      XReplaceOptions.Hidden.ContainerDirectory:=ExtractFilePath(OpenDialog1.FileName);
      ContainerHandle:=FileCreate(SaveDialog3.Filename);
      if ContainerHandle <= 0 then begin
         ReplaceLog.oLog('error opening '+SaveDialog3.FileName,'',XReplaceOptions.Log.Everything);
         if ErrorMessages then
            MsgForm.MessageDlg('Error opening '+SaveDialog3.FileName,'XReplace-32 has reported a system error while opening a file.',mtError,[mbOk],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
         EnableEverything;
         UpdateGrid;
         SetGridEdit;
         exit;
         end;

      FillContainer(ContainerHandle, XFullHeader);

        if (FileWrite(ContainerHandle,MySeparator,1)=-1) or
           (FileWrite(ContainerHandle,MinusTwo,2)=-1) or
           (FileWrite(ContainerHandle,xDirHeader,Length(XDirHeader))=-1) then begin
          ReplaceLog.oLog('error writing to '+SaveDialog3.FileName,'',XReplaceOptions.Log.Everything);
          if ErrorMessages then
             MsgForm.MessageDlg('Error writing to '+SaveDialog3.FileName,'XReplace-32 has reported a system error while writing to a file.',mtError,[mbOk],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
          FileClose(ContainerHandle);
          EnableEverything;
          UpdateGrid;
          SetGridEdit;
          exit;
          end;


      FillGrid0172(ContainerHandle, TreeView1.Items.GetFirstNode, 0);
      FileClose(ContainerHandle);
      if bs(FileListBox1.Directory) = bs(XReplaceOptions.Hidden.ContainerDirectory) then FileListBox1.PublicUpdate;
      LoadedFullState:=SaveDialog3.FileName;
      LoadedFileList:='';
      LoadedStringGrid:='';

   end;
   except
      MyExceptionHandler(Sender);
   end;
   EnableEverything;
   UpdateGrid;
   SetGridEdit;
   end;

procedure TxRepl32.FillGrid0172(ContainerFileHandle: integer; Item: TTreeNode; LocalId: integer);
begin
   while Item<>nil do begin
      if Item.Text = NoTag then exit;
      if (FileWrite(ContainerFileHandle,MySeparator,1)=-1) or
         (FileWrite(ContainerFileHAndle,PChar(IntToStr(LocalId))^,Length(IntToStr(LocalId)))=-1) or
         (FileWrite(ContainerFileHandle,MySeparator,1)=-1) or
         (FileWrite(ContainerFileHandle,PChar(GetSource(Item))^,Length(GetSource(Item)))=-1) or
         (FileWrite(ContainerFileHandle,MySeparator,1)=-1) or
         (FileWrite(ContainerFileHandle,PChar(GetTarget(Item))^,Length(GetTarget(Item)))=-1) then begin
                    if ErrorMessages then
                    MsgForm.MessageDlg('Error writing to '+SaveDialog3.FileName,'XReplace-32 has reported a system error while writing to a file.',mtError,[mbOk],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
                    FileClose(ContainerFileHandle);
                    EnableEverything;
                    UpdateGrid;
                    exit;
                    end;

      if Item.Count>0 then FillGrid0172(ContainerFileHandle, Item.GetFirstChild, LocalId+1);
      Item:=Item.GetNextSibling;
      end;
   end;

function TxRepl32.LoadGrid0157(ContainerFileHandle: integer): boolean;
const
   TempPrefix: array [0..2] of char = 'xr';
   iTab: array [0..1] of char = Chr(9);
var
   iChStr: string;
   iCh: char;
   TempName: PChar;
   iLevel, i, TCHandle: integer;
   NoPanic, CanLoad: boolean;
   FSize: LongInt;
begin
   try
   FSize:=FileHandleSize(ContainerFileHandle);
   TempName:=StrAlloc(MAX_PATH);
   GetTempFileName(PChar(TempPath), TempPrefix, 33, TempName);
   TCHandle:=FileCreate(TempName);

   if HandleEofSize(ContainerFileHandle, Fsize) then NoPanic:=True else NoPanic:=False;

   FileSeek(ContainerFileHandle,-2,1);
   while not HandleEofSize(ContainerFileHandle, Fsize) do begin

      if StopLoadingContainer then break;

      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      iLevel:=ReadInteger(ContainerFileHandle);
      iChStr:='';
      FileRead(ContainerFileHandle,iCh,1);
      while (iCh<>MySeparator[0]) do begin
         iChStr:=iChStr+iCh;
         if HandleEofSize(ContainerFileHandle, Fsize) then break;
         FileRead(ContainerFileHandle,iCh,1);
         end;

      for i:=1 to iLevel do FileWrite(TCHandle, iTab, 1);
      FileWrite(TCHandle, PChar(iChStr)^, Length(iChStr));
      FileWrite(TCHandle, PChar(Chr(13)+Chr(10))^, 2);
      end;

   FileClose(TCHandle);

   CanLoad:=True;
   if StopLoadingContainer then CanLoad:=False else
   if not TreeView1.DropTerminated then
      if MsgForm.MessageDlg('Do you really want to cancel the drag and drop operation?',
                            'If you choose to cancel the current drag and drop operation, XReplace-32 will load the full state container''s list instead.',mtConfirmation,[mbYes]+[mbNo],0,'')=mrYes then begin
         TreeView1.Kill;
         CanLoad:=True;
         end else CanLoad:=False;

   Result := False;
   if CanLoad then begin
      SBRemoveAllClick(Self);
      xrepl32.Refresh;
      if (not NoPanic) then Result := TreeLoad(TempName, True);
      end;

   Deletefile(TempName);
   except
      ReplaceLog.oLog('error reading from '+SaveDialog3.FileName,'',XReplaceOptions.Log.Everything);
      if ErrorMessages then
         MsgForm.MessageDlg('Error reading from '+SaveDialog3.FileName,'XReplace-32 has reported a system error while reading a file.',mtError,[mbOk],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
      FileClose(ContainerFileHandle);
      EnableEverything;
      UpdateGrid;
      Result := False;
      exit;
   end;
   TreeView1.UpdateGlyphs;
   end;

procedure TXRepl32.SetGridEdit;
begin
   MakeVisible(1);
   StringGrid1MouseDown(Self, mbLeft, [], StringGrid1.CellRect(0,1).Left+1, StringGrid1.CellRect(0,1).Top+1);
   end;

procedure TxRepl32.sbRpReverseClick(Sender: TObject);
var
   i: LongInt;
   iText: string;
begin
     if CountSplit > 0 then
         if ErrorMessages then
         if MsgForm.MessageDlg('Replacements grid contains split rows. Do you still wish to reverse it?',
                               'When inversing split rows XReplace will reverse the left column of the source with the target column, which makes no sense and may lead to unpredictable results in the replacement. Choose Yes if you still want to continue.',
                               mtInformation,[mbYes]+[mbNo],0,'')=MrNo then exit;
   if EditText.Visible then begin
      CloseEditText;
      EditText.Text:='';
      EditText.Visible:=False;
      end;

   with StringGrid1 do begin
      for i:=1 to RowCount-1 do begin
         iText:=GetRightSide(i);
         SetRightSide(i, GetLeftSide(i));
         SetLeftSide(i, iText);
         end;
      xRepl32.OpenEditText(True);
      xRepl32.StringGrid1.Repaint;
      end;
   end;

procedure TxRepl32.EditOptionsClick(Sender: TObject);
begin
   initXOptions;
   XOptions.ShowModal;
   UpdateInterfacePerOptions;
   end;

procedure TxRepl32.UpdateInterfacePerOptions;
begin
   TreeView1.ShowImages := XReplaceOptions.Gen.ShowTaggedFileGlyphs;
   FileListBox1.ShowGlyphs:=XReplaceOptions.Gen.ShowFileGlyphs;
   {$ifdef Registered}
   RegExpToggle.Down := XReplaceOptions.Repl.RegExp;
   {$endif}
   BottomButtonPanel.Visible:=XReplaceOptions.Gen.ShowAllButtons;
   TopButtonPanel.Visible:=XReplaceOptions.Gen.ShowAllButtons;
   ReplaceHintLabel.Visible := not BottomButtonPanel.Visible;
   ButtonBarsLabel.Visible := not TopButtonPanel.Visible;
   btnExpandButtons.Visible := not TopButtonPanel.Visible;
   end;

procedure TxRepl32.sbRpInsertLineClick(Sender: TObject);
var
   iLine : LongInt;
begin
   if EditText.Visible then begin
      with EditText do begin
         if AllEmpty(EditRow) then exit;
         CloseEditText;
         Visible:=False;
         iLine:=EditRow;
         UpdateGrid;
         CloseEditText;
         end;
      end else iLine:=StringGrid1.Row;


   InsertRow(iLine);
   SetLeftSide(iLine, ' ');
   StringGrid1MouseDown(Self, mbLeft, [], StringGrid1.CellRect(0,iLine).Left+1, StringGrid1.CellRect(0,iLine).Top+1);
   SetLeftSide(iLine, '');
   EditText.Text:='';
   end;

procedure TxRepl32.Replacements1Click(Sender: TObject);
begin
   {$ifdef Registered}
   mnuAssumeRegExp.Checked := XReplaceOptions.Repl.RegExp;
   invertGrid1.Enabled := not XReplaceOptions.Repl.RegExp;
   {$endif}
   if (not (Sender is TMenuItem)) or (CompareText(Copy((Sender as TMenuItem).Name, 1, Length('Merged')), 'Merged') <> 0) then
      PrepareRowStats(Replacements1);
   end;

procedure TxRepl32.SBRpSplitLeftMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
   with EditText do begin
   If IsLeftSplit(EditRow) then
      SbRpSplitLeft.Hint:='join current cell for interline replacement'
      else
      SbRpSplitLeft.Hint:='split current cell for interline replacement';
      end;
   end;

procedure TxRepl32.wsDragDropClick(Sender: TObject);
begin
     WildCardDrop(True, '');
     end;

procedure TxRepl32.Register1Click(Sender: TObject);
begin
   TExecute.Create(ExtractFilePath(Application.ExeName)+'REGISTER.EXE', '', 0);
   end;

procedure TxRepl32.dvEditFileClick(Sender: TObject);
begin
   FileExecute(TreeView1.GetCompletePath(TreeView1.Selected));
   end;

procedure TxRepl32.dvParseClick(Sender: TObject);
var
   LName: string;
   LShortName: string;
   i: LongInt;
begin
   LName:=TreeView1.GetCompletePath(TreeView1.Selected);
   LShortName:=TreeView1.Selected.Text;
   if DirectoryExists(LName) then begin
      ShellSpace.Directory := LName;
      end else
      if FileExists(LName) then begin
         ShellSpace.Directory := ExtractFilePath(LName);
         FileListBox1.PublicUpdate;
         for i:=0 to FileListBox1.Items.Count - 1 do
            if CompareText(FileListBox1.Items[i], LShortName)=0 then begin
               FileListBox1.Selected[i]:=True;
               FileListBox1.TopIndex:=i;
               break;
               end;
         end;
   end;

procedure TxRepl32.dvRemoveClick(Sender: TObject);
begin
   BBffDust.OnClick(Sender);
   end;

procedure TxRepl32.UpdateSpecialConditions;
begin
   if (TreeView1.isEmpty) then begin
      SBTreeViewSave.Enabled:=False;
      SBRemoveAll.Enabled:=False;
      BBFFDust.Enabled:=False;
      TreeView1.Invalidate;
      {$ifdef Registered}
      SBRedirect.Enabled:=False;
      {$endif}
      end else begin
      {$ifdef Registered}
      SBRedirect.Enabled:=True;
      {$endif}
      SBTreeViewSave.Enabled:=True;
      SBRemoveAll.Enabled:=True;
      BBFFDust.Enabled:=True;
      end;
   end;

procedure TxRepl32.TreeView1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (Key = 46) and (not LoadingContainer) and (TreeView1.DropTerminated) then begin
      BBffdust.OnClick(Sender);
      end else
   if (Key = 13) and (ssAlt in Shift) then dvRedirect.Click else
   if (Key = 13) then if TreeView1.Selected <> nil then with TreeView1.Selected do if Expanded then Collapse(False) else Expand(False);
   end;

procedure TxRepl32.StringGrid1Resize;
begin
     with StringGrid1 do begin
        {$ifdef Registered}
        ColWidths[2]:=75;
        ColWidths[3]:=Canvas.TextWidth(' ('+IntToStr(RowCount)+') ');
        {$endif}
        ColWidths[0]:=(ClientWidth - 25 {$ifdef Registered} - ColWidths[2] - ColWidths[3]{$endif}) div 2;
        ColWidths[1]:=ColWidths[0];
        end;
     end;

procedure TxRepl32.XPanelResize(Sender: TObject);
begin
     StringGrid1Resize;
     try
     if EditText.Visible then
        with EditText do begin
           EditChange(Sender);
           Perform(EM_SCROLLCARET,0,0);
           end;
     except
     end;
        StringGrid1TopLeftChanged(Sender);
   end;

procedure TxRepl32.GripPanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   NS, tH: integer;
begin
   NS:=StringGrid1.DefaultRowHeight*2+StringGrid1.GridLineWidth*4;
   if ssLeft in Shift then begin
      tH:=XPanel.Height - Y;
      if (th > (NS + VBPanel.Height + xrpStatusBar.Height)) and (th < XRepl32.CLientHeight / 1.5) then XPanel.Height:=tH;
      end;
   end;


procedure TxRepl32.FormResize(Sender: TObject);
var
   NS: integer;
begin
   xrpStatusBar.SizeGrip := (WindowState <> wsMaximized);
   NS:=StringGrid1.DefaultRowHeight*2+StringGrid1.GridLineWidth*4 + VBPanel.Height + xrpStatusBar.Height;
   if (XPanel.Height > (XRepl32.CLientHeight / 1.5)) or
      (Xpanel.Height < NS) then
      XPanel.Height:=trunc(XRepl32.CLientHeight / 1.5);
   end;

procedure TxRepl32.AppendToSystemMenu (Form: TForm; Item: string; ItemID: word);
var
   NormalSysMenu, MinimizedMenu: HMenu;
   AItem: array[0..255] of Char;
   PItem: PChar;
begin
   NormalSysMenu := GetSystemMenu(Form.Handle, false);
   MinimizedMenu := GetSystemMenu(Application.Handle, false);
   if Item = '-' then
   begin
     AppendMenu(NormalSysMenu, MF_SEPARATOR, 0, nil);
     AppendMenu(MinimizedMenu, MF_SEPARATOR, 0, nil);
   end
   else
   begin
     PItem := StrPCopy(@AItem, Item);
     AppendMenu(NormalSysMenu, MF_STRING, ItemID, PItem);
     AppendMenu(MinimizedMenu, MF_STRING, ItemID, PItem);
   end
   end; {AppendToSystemMenu}

procedure TXRepl32.RegisterMsg (var Msg: TMsg; var Handled: boolean);
begin
  if Msg.Message = WM_SYSCOMMAND then
    {$ifndef Registered}
    if Msg.wParam = 99 then Register1.Click else
    {$endif}
    if Msg.wParam = 199 then AboutXReplace321.Click;
       {Registration stuff}
end;

procedure TxRepl32.MacrosEditMenuClick(Sender: TObject);
begin
   {$ifdef Registered}
   initMacroEdit;
   MacroEditor.Enabled := False;
   MacroEdit.Show;
   MacroEditor.Enabled := True;
   {$Endif}
   end;

{$ifdef Registered}
function TxRepl32.MacroExecute(iFileName: string; Serious: boolean): boolean;
var
   FN: Textfile;
   tL: string;
begin
     try
     DisableEverything;
     ForceNotPermanentResponse:=True;
     AssignFile(FN, iFileName);
     Reset(FN);
     Result:=True;
     MacroLine:=0;
     while not Eof(FN) do begin
        ReadLn(FN, tL);
        inc(MacroLine);
        Result := MacroExecuteLine(tL, Serious);
        if Result = False Then Break;
        end;
     CloseFile(FN);
     ForceNotPermanentResponse:=False;
     EnableEverything;
     except
       EnableEverything;
       MacroLine:=-1;
       if MacroEdit <> nil then MacroEdit.AddError('unexpected error opening / reading ' + iFileName);
       ForceNotPermanentResponse:=False;
       Result:=False;
       exit;
     end;
     end;


function TxRepl32.MacroExecuteLine(iCommand: string; Serious: boolean): boolean;
         procedure SetOptions(var tOpt: boolean; lParam: string; lName: string);
         var
            iOpt: boolean;
         begin
              if (CompareText(lParam, 'true')=0) then iOpt:=True
              else if (CompareText(lParam, 'false')=0) then iOpt:=False
              else if (CompareText(lParam, '1')=0) then iOpt:=True
              else if (CompareText(lParam, '0')=0) then iOpt:=False
              else begin
                   if MacroEdit <> nil then MacroEdit.AddError('invalid parameter setting "'+lName+'"');
                   exit;
                   end;
              if Serious then tOpt := iOpt;
              end;
var
   lCommand: string;
   lParam: string;
   lDirectory: string;
   i: integer;
begin
     Result:=True;
     iCommand:=Trim(iCommand);
     if Length(iCommand)=0 then exit;
     ReplaceLog.oLog('executing/compiling: ' + iCommand,'macros',XReplaceOptions.Log.MacroDetail);
//     MacroEdit.AddError('executing::'+iCommand);
     if iCommand[1] = '#' then exit;
     i:=Pos(' ', iCommand);
     if i = 0 then begin
        lCommand:=Trim(iCommand);
        lParam:='';
        end else begin
        lCommand:=Trim(Copy(iCommand, 1, i - 1));
        lParam:=Trim(Copy(iCommand, i + 1, Length(iCommand)));
        end;
     if Length(iCommand)=0 then exit;
     try
     {filter}
     if (CompareText(lCommand, 'FILTER_SET')=0) then begin
        if lParam = '' then begin
           if MacroEdit <> nil then MacroEdit.AddError('missing parameter for "filter_set"');
           Result := False;
           exit;
           end;
        if Serious then begin
           FilterComboBox1.filter:='';
           FilterComboBox1.filter:='('+lParam+')|'+lParam;
           while FileListBox1.isReading do Application.ProcessMessages;
           end;
     end else if (CompareText(lCommand, 'FILTER_ADD')=0) then begin
        if lParam = '' then begin
           if MacroEdit <> nil then MacroEdit.AddError('missing parameter for "filter_add"');
           Result := False;
           exit;
           end;
        if Serious then begin
           FilterComboBox1.filter:=FilterComboBox1.Filter+'|'+'('+lParam+')|'+lParam;
           FilterComboBox1.ItemIndex:=FilterComboBox1.Items.Count - 1;
           while FileListBox1.isReading do Application.ProcessMessages;
           end;
     end else if (CompareText(lCommand, 'FILTER_CLEAR')=0) then begin
         if Serious then begin
            FilterComboBox1.filter:='';
            while FileListBox1.isReading do Application.ProcessMessages;
            end;
     {drive}
     end else if (CompareText(lCommand, 'CHD')=0) then begin
        MacroExecuteLine('cd '+ExtractFileDrive(lParam), Serious);
     {directory}
     end else if (CompareText(lCommand, 'CD')=0) then begin
        if lParam = '' then begin
           if MacroEdit <> nil then MacroEdit.AddError('missing parameter for "cd"');
           Result := False;
           exit;
           end;
         if Serious then begin
            lDirectory := lParam;
            lParam := ExpandFileName(lParam);
            if not DirectoryExists(lParam) then
               lParam := ExtractFileDir(lParam);
            if not DirectoryExists(lParam) then begin
               MacroEdit.AddError('invalid directory ' + lDirectory);
               Result := False;
               exit;
               end;
            ShellSpace.ParseToStrfolder(lParam);
            while ShellSpace.isExpanding do Application.ProcessMessages;
            while FileListBox1.isReading do Application.ProcessMessages;
            end;
     {file}
     end else if (CompareText(lCommand, 'FILE_SELECT')=0) then begin
         if lParam = '' then begin
            if MacroEdit <> nil then MacroEdit.AddError('missing parameter for "file_select"');
            Result := False;
            exit;
            end;
         if (Pos('?', lParam) <> 0) or (Pos('*', lParam)<>0) then begin
            if MacroEdit <> nil then MacroEdit.AddError('filter selections not supported by "file_select", use "wildcard_select" or "wildcard_drop"');
            Result := False;
            exit;
            end;
         if Serious then begin
            lParam:=ExtractFileName(lParam);
            for i:=0 to FileListBox1.Items.Count - 1 do begin
                if CompareText(FileListbox1.Items[i],lParam) = 0 then begin
                   FileListBox1.Selected[i]:=True;
                   break;
                   end;
                   end;
            end;
     end else if (CompareText(lCommand, 'FILE_CLEAR')=0) then begin
         if Serious then
            for i:=0 to FileListBox1.Items.Count - 1 do begin
                FileListBox1.Selected[i]:=False;
                end;
     end else if (CompareText(lCommand, 'FILE_DESELECT')=0) then begin
         if lParam = '' then begin
            if MacroEdit <> nil then MacroEdit.AddError('missing parameter for "file_deselect"');
            Result := False;
            exit;
            end;
         if Serious then begin
            lParam:=ExtractFileName(lParam);
            for i:=0 to FileListBox1.Items.Count - 1 do begin
                if CompareText(FileListbox1.Items[i],lParam) = 0 then begin
                   FileListBox1.Selected[i]:=False;
                   break;
                   end;
                end;
            end;
     {Commands}
     end else if (CompareText(lCommand, 'CALL')=0) then begin
         if Serious then MacroExecute(lParam, Serious);
     end else if (CompareText(lCommand, 'GO')=0) then begin
         if Serious then SbGo.Click;
     end else if (CompareText(lCommand, 'QUIT')=0) then begin
         if Serious then mustTerminate := True; //TerminateXReplace(True);//SbQuit.Click;
     {File Select}
     end else if (CompareText(lCommand, 'DIRDRAGDROP')=0) then begin
         if Serious then begin
            DragDrop1.Click;
            while not TreeView1.DropTerminated do Application.ProcessMessages;
            end;
     end else if (CompareText(lCommand, 'FILEDRAGDROP')=0) then begin
         if Serious then begin
            TreeView1.DragDrop(FileListBox1, 1, 1);
            while not TreeView1.DropTerminated do Application.ProcessMessages;
            end;
     end else if (CompareText(lCommand, 'REMOVEALL')=0) then begin
         if Serious then wsRemoveAll.Click;
     {Replacements Grid}
     end else if (CompareText(lCommand, 'GRID_CLEAR')=0) then begin
         if Serious then Clear1.Click;
     end else if (CompareText(lCommand, 'GRID_INVERT')=0) then begin
         if Serious then InvertGrid1.Click;
     end else if (CompareText(lCommand, 'GRID_LOAD')=0) then begin
         if Serious then begin
         DisableEverything;
         LoadContainer(lParam);
         end;
     end else if (CompareText(lCommand, 'REG_EXP')=0) then begin
         SetOptions(XReplaceOptions.Repl.RegExp, lParam, lCommand);
         RegExpToggle.Down := XReplaceOptions.Repl.RegExp;
         UpdateRegExpState;
     end else if (CompareText(lCommand, 'CASE_SENSITIVE')=0) then begin
         SetOptions(XReplaceOptions.Repl.CaseSensitive, lParam, lCommand);
     end else if (CompareText(lCommand, 'IGNORE_ERRORS')=0) then begin
         SetOptions(XReplaceOptions.Repl.NoErrors, lParam, lCommand);
     end else if (CompareText(lCommand, 'INCLUDE_SOURCE')=0) then begin
         SetOptions(XReplaceOptions.Repl.IncludeSource, lParam, lCommand);
     end else if (CompareText(lCommand, 'WHOLE_WORDS')=0) then begin
         SetOptions(XReplaceOptions.Repl.WholeWordsOnly, lParam, lCommand);
     end else if (CompareText(lCommand, 'PROMPT_REPLACE')=0) then begin
         SetOptions(XReplaceOptions.Repl.PromptOnReplace, lParam, lCommand);
     end else if (CompareText(lCommand, 'WILDCARD_SELECT')=0) then begin
         if Serious then WildCardSelect(False, lParam + '|' + lParam);
     end else if (CompareText(lCommand, 'WILDCARD_DROP')=0) then begin
         if Serious then WildCardDrop(False, lParam + '|' + lParam);
     end else if (CompareText(lCommand, 'COPY_REDIRECT')=0) then begin
         SetOptions(XReplaceOptions.Repl.CopyRedirect, lParam, lParam);
     end else begin
         if MacroEdit <> nil then MacroEdit.AddError('unknown command "' + lCommand+'"');
         Result:=False;
         end;
     except
        if MacroEdit <> nil then MacroEdit.AddError('unexpected error executing ' + lCommand);
        Result:=False;
        exit;
     end;
     end;
{$endif}

procedure TxRepl32.SheduleClick(Sender: TObject);
begin
   {$ifdef registered}
   initXFShedule;
   xFShedule.Show;
   {$endif}
   end;


procedure TxRepl32.MActivateClick(Sender: TObject);
begin
   {$ifdef registered}
   initActiveX;
   if VirtuallyDisabled = 0 then
    if (MActivate.Caption = '&Activate!') then begin
       ActiveX.SActivate
       end else begin
       ActiveX.SDeActivate;
       end;
   {$endif}
   end;

procedure TxRepl32.TreeView1Changing(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
begin
     if Node.Text = NoTag then begin
        AllowChange:=False;
        end;
     end;

procedure TxRepl32.AddCellProps;
var
   Prop: PCellProps;
begin
   new(Prop);
   with Prop^ do begin
        LeftSplit:=False;
        RightSplit:=False;
        Inter:=False;
        CaseSens:=False;
        Prompt:=False;
        WholeWord:=False;
        LeftSide:='';
        RightSide:='';
        LeftSplitSide:='';
        RightSplitSide:='';
        ReplaceCopies:=1;//XReplaceOptions.Repl.TargetCopies;
        occurrencesFound := 0;
        occurrencesReplaced := 0;
        Disabled:=False;
        end;
   inc(GridCount);
   ReAllocMem(GridContents,(GridCount + 2)*SizeOf(PCellProps));
   GridContents[GridCount - 1]:=Prop;
   StringGrid1Resize;
   end;

function TxRepl32.GetSideStr(Row: LongInt; Col: integer): string;
begin
     Case Col of
          0: Result := GetLeftSide(Row);
          1: Result := GetRightSide(Row);
          end;
     end;

function TxRepl32.GetLeftSide(Row: LongInt): string;
begin
     if Row >= GridCount then Result:='' else Result:=GridContents^[Row]^.LeftSide;
     end;

function TxRepl32.GetLeftSplitSide(Row: LongInt): string;
begin
     if Row >= GridCount then Result:='' else Result:=GridContents^[Row]^.LeftSplitSide;
     end;

function TxRepl32.GetRightSide(Row: LongInt): string;
begin
     if Row >= GridCount then Result:='' else Result:=GridContents^[Row]^.RightSide;
     end;

function TxRepl32.GetRightSplitSide(Row: LongInt): string;
begin
     if Row >= GridCount then Result:='' else Result:=GridContents^[Row]^.RightSplitSide;
     end;

procedure TxRepl32.SetLeftSide(Row: LongInt; iStr: string);
begin
     //if (EditText.EditRow = Row) and (EditText.EditCol = 0) then EditText.Text:=iStr;
     try
     GridContents^[Row]^.LeftSide:=iStr;
     except
     InsertGridRow(Row);
     GridContents^[Row]^.LeftSide:=iStr;
     end;
     end;

procedure TxRepl32.SetLeftSplitSide(Row: LongInt; iStr: string);
begin
     //if (EditText.EditRow = Row) and (EditText.EditLSRight) then EditText.Text:=iStr;
     try
     GridContents^[Row]^.LeftSplitSide:=iStr;
     except
     InsertGridRow(Row);
     GridContents^[Row]^.LeftSplitSide:=iStr;
     end;
     end;

procedure TxRepl32.SetRightSplitSide(Row: LongInt; iStr: string);
begin
     try
     GridContents^[Row]^.RightSplitSide:=iStr;
     except
     InsertGridRow(Row);
     GridContents^[Row]^.RightSplitSide:=iStr;
     end;
     end;

procedure TxRepl32.SetRightSide(Row: LongInt; iStr: string);
begin
     //if (EditText.EditRow = Row) and (EditText.EditCol = 1) then EditText.Text:=iStr;
     try
     GridContents^[Row]^.RightSide:=iStr;
     except
     InsertGridRow(Row);
     GridContents^[Row]^.RightSide:=iStr;
     end;
     end;

procedure TxRepl32.InsertGridRow(iRow: LongInt);
var
   i: integer;
   Prop: PCellProps;
begin
     try
     inc(GridCount);                                                             {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(incgridcount).');{$ENDIF}
     ReAllocMem(GridContents,(GridCount + 2)*SizeOf(PCellProps));                  {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(reallocmem).');{$ENDIF}
     for i:=GridCount downto iRow do begin
         GridContents[i+1]:=GridContents[i];
         end;                                                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(gridcontents).');{$ENDIF}
     New(Prop);                                                                  {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(newprop).');{$ENDIF}
     GridContents[iRow]:=Prop;                                                   {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(rowset).');{$ENDIF}
     InitGridContents(iRow);                                                     {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(initgridcontents).');{$ENDIF}
     StringGrid1Resize;
     StringGrid1.Repaint;
     {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(successful).');{$ENDIF}
     except
     {$IFDEF Debug}DebugForm.Debug('TxRepl32.InsertGridRow:(exception raised).');{$ENDIF}
     end;
     //StringGrid1.Update;
     end;

procedure TxRepl32.ExtractRow(Row: LongInt);
var
   i: integer;
   TempGridContents: ^SuperLongArray;
begin
     if GridCount > 0 then begin
     TempGridContents:=AllocMem(SizeOf(PCellProps)*(GridCount));
     for i:=0 to Row - 1 do begin
         TempGridContents[i]:=GridContents[i];
         end;
     for i:=Row + 1  to GridCount do begin
         TempGridContents[i - 1] := GridContents[i];
         end;
     Dispose(GridContents[Row]);
     GridContents:=@TempGridContents^;
     dec(GridCount);
     StringGrid1Resize;
     end;
     end;

procedure TxRepl32.ClearCellProps;
var
   i: integer;
begin
     LoadedFullState:='';
     LoadedStringGrid:='';

     if GridCount > 0 then
     for i:=0 to GridCount - 1 do begin
         if GridContents^[i]<>nil then Dispose(GridContents^[i]);
         end;

     FreeMem(GridContents, GridCount * SizeOf(PCellProps));
     GridContents:=nil;
     GridCount:=0;
     StringGrid1Resize;
      with StringGrid1 do begin
         AddCellProps;
         AddCellProps;
         {$ifdef registered}
         ColCount:=4;
         {$else}
         ColCount:=2;
         {$endif}
         RowCount:=2;
         ResetGridHeader;
         end;                                                                     {$IFDEF Debug}DebugForm.Debug('TxRepl32.FormCreate::StringGrid:ok');{$ENDIF}
     end;

procedure TxRepl32.sbRpIncludeClick(Sender: TObject);
begin
   {$ifdef Registered}
   {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::sbRpIncludeClick');{$ENDIF}
   if sbRpInclude.Enabled then
   if EditText.Visible then begin
      GridContents[EditText.EditRow].Inter:=not GridContents[EditText.EditRow].Inter;
      StringGrid1.Repaint;
      end;
   {$endif}
   end;

function TxRepl32.CountSplit: integer;
var
   i: integer;
begin
     Result:=0;
     for i:=0 to GridCount - 1 do begin
         if GridContents[i].LeftSplit then inc(Result);
     end;
     end;

procedure TxRepl32.sbRpCaseSensClick(Sender: TObject);
begin
   {$ifdef Registered}
   {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::sbRpCaseSensClick');{$ENDIF}
   if SbRpCaseSens.Enabled then
   if EditText.Visible then begin
      GridContents[EditText.EditRow].CaseSens:=not GridContents[EditText.EditRow].CaseSens;
      StringGrid1.Repaint;
      end;
   {$endif}
   end;

procedure TxRepl32.sbRpPromptClick(Sender: TObject);
begin
   {$ifdef Registered}
   {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::sbRpPromptClick');{$ENDIF}
   if SbRpPrompt.Enabled then
   if EditText.Visible then begin
      GridContents[EditText.EditRow].Prompt:=not GridContents[EditText.EditRow].Prompt;
      StringGrid1.Repaint;
      end;
   {$endif}
   end;

procedure TxRepl32.sbRpWholeOnlyClick(Sender: TObject);
begin
   {$ifdef Registered}
   {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::sbRpWholeOnlyClick');{$ENDIF}
   if sbRpWholeOnly.Enabled then
   if EditText.Visible then begin
      GridContents[EditText.EditRow].WholeWord:=not GridContents[EditText.EditRow].WholeWord;
      StringGrid1.Repaint;
      end;
   {$endif}
   end;

procedure TxRepl32.StringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   ACol, ARow: LongInt;
begin
     xrpStatusBar.Panels[0].Text:='';
     if LoadedFullState <> '' then xrpStatusBar.Panels[1].Text:=ExtractFileName(LoadedFullState) else
     if LoadedStringGrid <> '' then xrpStatusBar.Panels[1].Text:=ExtractFileName(LoadedStringGrid) else
     xrpStatusBar.Panels[1].Text := '';


     StringGrid1.MouseToCell(X,Y,ACol,ARow);
     if ARow = 0 then begin
        if ACol = 0 then StringGrid1.Hint:=hFrom else
        if ACol = 1 then StringGrid1.Hint:=hTo {$ifdef Registered} else
        if ACol = 2 then StringGrid1.Hint:=hOptions else
        if ACol = 3 then StringGrid1.Hint:=hThird;
        {$endif}
        end else
     {$ifdef Registered}
     if ACol = 3 then
        StringGrid1.Hint:=hThird else
     if ACol = 2 then begin
        with StringGrid1 do begin
             X := X - ColWidths[0] - ColWidths[1];
             if X < (RowHeights[0] + 4) then Hint:=hInter
             else if X < 2*(RowHeights[0] + 4) then Hint:=hCaseSens
             else if X < 3*(RowHeights[0] + 4) then Hint:=hWholeWord
             else if X < 4*(RowHeights[0] + 4) then Hint:=hPrompt;
             end;
        end else begin
        StringGrid1.Hint:='';
        end;
    {$endif}
     end;

procedure TxRepl32.DropViewPopupPopup(Sender: TObject);
var
   TreeCountFiles : integer;
begin
   dvExpand.Enabled := false;
   dvExpand.Caption := '&Expand All';
   if (TreeView1.Selected <> nil) then begin
      if (TreeView1.Selected.Count <> 0) then begin
         dvExpand.Enabled := true;
         dvExpand.Caption := '&Expand ' + TreeView1.Selected.Text;
      end;
   end;

   TreeCountFiles := TreeView1.CountFiles;
   dvClearAll.Caption := 'Remove &All';
   if (TreeCountFiles > 0) then begin
      dvClearAll.Caption := dvClearAll.Caption +
         ' (' + IntToStr(TreeCountFiles) + ' file';
      if TreeCountFiles > 1 then
         dvClearAll.Caption := dvClearAll.Caption + 's';
      dvClearAll.Caption := dvClearAll.Caption + ')';
      end;

   if (TreeView1.isEmpty) then begin
      dvClearAll.Enabled:=False;
      dvStats.Enabled := False;
      end else begin
      dvClearAll.Enabled:=True;
      dvStats.Enabled := True;
      end;

   dvSave.Enabled := dvClearAll.Enabled;
   {$ifdef Registered}
   dvRedirect.Enabled := dvClearAll.Enabled;
   dvClearRedirect.Enabled := (GetTarget(TreeView1.Selected) <> '')
   {$endif}
   end;

procedure TxRepl32.Fileselection1Click(Sender: TObject);
begin
   if TreeView1.isEmpty then wsRemoveAll.Enabled:=False else wsRemoveAll.Enabled:=True;
   Save3.Enabled:=wsRemoveAll.Enabled;
   sbTreeViewSave.Enabled:=wsRemoveAll.Enabled;
   {$ifdef Registered}
   wsRedirect.Enabled:=wsRemoveAll.Enabled;
   {$endif}
   end;

function TxRepl32.GetFullRedirection(ANode: TTreeNode): string;
   function GetItemRedir(ANode: TTreeNode): string;
          var
             tS, tT: string;
          begin
               tS := GetSource(ANode);
               tT := GetTarget(ANode);
               if (tT = '') then tT:=tS;

               if {(StrPos(PChar(tT), '\')<>nil) or} (StrPos(PChar(tT), ':')<>nil) or (StrLComp(PChar(tT), '\\', 2) = 0) then Result:=tT else
               if (ANode.Parent = nil) then Result:=tT else Result:=GetItemRedir(ANode.Parent)+'\'+tT;
               end;

   var
      fPos: integer;
      RStr: string;
      iDbl: boolean;
   begin
        if ANode = nil then exit;
        if ANode.Data = nil then exit;
        Result:=Trim(GetItemRedir(ANode));
        if CompareText(Copy(Result, 1, 2), '\\')=0 then begin
           iDbl:=True;
           RStr:=Copy(Result, 3, Length(Result));
           end else begin
           RStr:=Result;
           iDbl:=False;
           end;

        fPos:= Pos('\\', RStr);
        while (fPos <> 0) do begin
              Delete(RStr, fPos, 1);
              fPos:= Pos('\\', RStr);
              end;
        if iDbl then Result:='\\' else Result:='';
        Result:=Result+RStR;
        //Result:=ExpandFileName(Result);
        end;

procedure TxRepl32.dvRedirectClick(Sender: TObject);
{$ifdef Registered}
var
   FileName: string;
   TreeNode: TTreeNode;
   {$endif}
begin
     {$ifdef Registered}
     with TreeView1 do begin
          if Showing then SetFocus;
          if Selected = nil then exit;

          TreeNode := Selected;

          FileName := GetFullRedirection(TreeNode);
          initDirSelect;
          if DirectoryExists(FileName) then
            DirSelect.SelDir.Directory := FileName
          else DirSelect.SelDir.Directory := ExtractFilePath(FileName);

          FileName := GetTarget(TreeNode);
          DirSelect.SelEdit.Text := FileName;
          DirSelect.Caption:= 'Redirecting ' + GetSource(TreeNode);
          if DirSelect.ShowModal = mrOk then begin
             XReplaceOptions.Hidden.RedirectDirectory := DirSelect.SelDir.Directory;
             with DirSelect.SelEdit do
               if DirectoryExists(Text) and (GetNodeType(Selected) = nFile) then begin
                  if Text[Length(Text)]<>'\' then Text:=Text+'\';
                     Text := Text + GetSource(TreeNode);
                     end;

             SetTarget(TreeNode, DirSelect.SelEdit.Text);

             if GetTarget(Selected) <> '' then
               Selected.Text := GetSource(TreeNode) + ' -> ' + GetTarget(TreeNode)
             else Selected.Text := GetSource(TreeNode);
          end;
       end;
     {$endif}
     end;
//container loaders

function TxRepl32.LoadTree(ContainerName: string): boolean;
var
   AContainerVersion, ContainerFileHandle: integer;
begin
     try
     LoadingContainer:=True;
     StopLoadingContainer:=False;

     ReplaceLog.oLog('loading tagged files list: ' + ContainerName,'',XReplaceOptions.Log.Everything);
     ContainerFileHandle:=FileOpen(ContainerName, fmOpenRead);
     If ContainerFileHandle<=0 then begin
        ReplaceLog.oLog('error opening tagged files list for load: '+ContainerName,'',XReplaceOptions.Log.Everything);
        if ErrorMessages then
        MsgForm.MessageDlg('Error opening '+ ContainerName + ', tagged files list not loaded.',
                           'XReplace-32 has reported a system error while opening a container file.',mtError,[mbOk],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
        LoadingContainer:=False;
        Result := False;
        exit;
        end;

      AContainerVersion:=ContainerVersion(ContainerFileHandle);
      if AContainerVersion = -1 then begin
         FileClose(ContainerFileHandle);
         Result := TreeLoad(ContainerName, False);
         LoadingContainer:=False;
         exit;
         end else
      if AContainerVersion = 152 then begin
         FileSeek(ContainerFileHandle,11,0);
         Result := LoadGrid0157(ContainerFileHandle);
         end else
      if AContainerVersion = 172 then begin
         FileSeek(ContainerFileHandle,12,0);
         Result := LoadGrid0172(ContainerFileHandle);
         end else
      begin
        ReplaceLog.oLog('error parsing container '+ContainerName,'',XReplaceOptions.Log.Everything);
        if ErrorMessages then
        MsgForm.MessageDlg('Error parsing '+ContainerName,
                           'Your version of XReplace is too old for this container. '+
                           'You may find the latest release of XReplace on the world wide web at http://www.vestris.com',mtError,[mbOk],0,'');
        LoadingContainer:=False;
        Result := False;
        exit;
        end;

     FileClose(ContainerFileHandle);
     if Result then LoadedFileList:=ContainerName else LoadedFileList := '';
     LoadedFullState := '';
     ReplaceLog.oLog('container '+ContainerName+' loaded.','',XReplaceOptions.Log.Everything);
     except
         Result := False;
     end;

     LoadingContainer:=False;
     end;

function TxRepl32.LoadGrid0172(ContainerFileHandle: integer): boolean;
          function ReadString: string;
          var
             iCh: char;
          begin
               Result:='';
               FileRead(ContainerFileHandle,iCh,1);
               while (iCh<>MySeparator[0]) do begin
                     Result:=Result+iCh;
                     if HandleEof(ContainerFileHandle) then break;
                     FileRead(ContainerFileHandle,iCh,1);
                     end;
               end;
var
   pLevel, Level: integer;
   Source, Target: string;
   iNode: TTreeNode;
   FSize: LongInt;
begin
   //if not(Hi(GetKeyState(VK_SHIFT))=255) or (CompareText(TreeView1.Items.GetFirstNode.Text, NoTag)=0) then TreeView1.Items.Clear;

   TreeView1.NodeDeleteInternal(TreeView1.Items.GetFirstNode);
   
   try
   pLevel:=0;
   iNode:=nil;

   FSize:=FileHandleSize(ContainerFileHandle);

   while not HandleEofSize(ContainerFileHandle, Fsize) do begin

      if StopLoadingContainer then break;
      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      Level:=ReadInteger(ContainerFileHandle);
      if HandleEofSize(ContainerFileHandle, Fsize) then break;
      Source:=ReadString;
      Target:=ReadString;

      while (Level < pLevel) and (Level > 0) do begin
         iNode:=iNode.Parent;
         dec(pLevel);
         end;
      if Level = 0 then begin
         iNode:=TreeView1.RAdd(TreeView1.Items.GetFirstNode, Source, nFile);
         SetTarget(iNode, Target);
         end else
      if Level = pLevel then begin
         iNode:=TreeView1.RAdd(iNode, Source, nFile);
         SetTarget(iNode, Target);
         end else
      if Level > pLevel then begin
         iNode:=TreeView1.RAddChild(iNode, Source, nFile);
         SetTarget(iNode, Target);
         pLevel:=Level;
         end;
      {$ifdef Registered}
      if GetTarget(iNode) <> '' then iNode.Text:=GetSource(iNode) + ' -> '+GetTarget(iNode)
                                else iNode.Text:=GetSource(iNode);
      {$else}
      iNode.Text:=GetSource(iNode);
      {$endif}
      end;
         Result:=True;
         except
         Result := False;
         end;
   TreeView1.UpdateGlyphs;
   end;

function TxRepl32.LoadContainer0000(ContainerFileHandle:integer): boolean;
var
   CurrentRow: integer;
   buffer: string;
   LeftSide:string;
   RightSide:string;
   rdLine:integer;
   Errors: integer;
   fSize: LongInt;
begin
   try
   {prepare the grid for a new load}
   Errors:=0;
   PrepareLoadGrid(CurrentRow);
   {reiwind the old style container}

   FileSeek(ContainerFileHandle,0,0);
   rdLine:=0;
   FSize:=FileHandleSize(ContainerFileHandle);
   while rdLine<>-1 do begin
      if StopLoadingContainer then break;
      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;
      rdLine:=ReadLine(ContainerFileHandle,buffer);
      if buffer='' then SetLength(buffer,1)
      else
         If buffer[1]<>'\' then begin
            If Pos('|',buffer)=0 then begin
               if ErrorMessages then
               If MsgForm.MessageDlg('Container file has an error or is not a valid container file!',
                  'XReplace-32 has encountered an error in the replacements file you attempt to load. '+
                  'The file had no identification for it''s version and was assumed as being a DOS version of XReplace-32 container. Current line may be ignored or you may cancel loading.',
                  mtError,[mbIgnore]+[mbAbort],0,'')=mrAbort then begin
                  xrpStatusBar.Panels[0].Text:='Ready.';
                  Result := False;
                  exit;
                  end;
               inc(Errors);
               end
            else begin
               LeftSide:=Copy(buffer,1,Pos('|',buffer)-1);
               RightSide:=Copy(buffer,Pos('|',buffer)+1,Length(buffer));
               StringGrid1.RowCount:=CurrentRow+1;
               AddCellProps;
               SetLeftSide(StringGrid1.RowCount, LeftSide);
               SetRightSide(StringGrid1.RowCount, RightSide);
               CurrentRow:=CurrentRow+1;
               end;
            end;
         end;                                                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.LoadContainer0000:(succeeded):'+Self.ClassName);{$ENDIF}
      if Errors=0 then xrpStatusBar.Panels[0].Text:='Successfully loaded container (version id : none, assumed as DOS).'
         else xrpStatusBar.Panels[0].Text:='Loaded container (version id : none, assumed as DOS) with errors.';
      Result := True;
   except
      xrpStatusBar.Panels[0].Text:='Ready.';
      MyExceptionHandler(Self);
      Result := False;
   end;
   end;

function TxRepl32.LoadContainer0100(ContainerFileHandle:integer): boolean;
var
   HandledInteger:LongInt;
   ReplBuffer: PChar;
   CurrentRow:integer;
   FSize: LongInt;
begin
   {$I+}
   try
   PrepareLoadGrid(CurrentRow);
   HandledInteger:=ReadInteger(ContainerFileHandle);
   FSize:=FileHandleSize(ContainerFileHandle);
   while (HandledInteger<>-2) do begin
      if StopLoadingContainer then break;
      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;
      replBuffer:=StrAlloc(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);

      AddCellProps;
      SetLeftSide(CurrentRow, Copy(ReplBuffer,1,HandledInteger));
      StrDispose(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=StrAlloc(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSide(CurrentRow, Copy(ReplBuffer,1,HandledInteger));
      HandledInteger:=ReadInteger(ContainerFileHandle);
      StrDispose(ReplBuffer);

      CurrentRow:=CurrentRow+1;
      end;
   StringGrid1.RowCount:=GridCount;
   StringGrid1.Repaint;
   xrpStatusBar.Panels[0].Text:='Successfully loaded container. (version id : 1.00)';  {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels[0].Text);{$ENDIF}
   Result := True;
   except
      xrpStatusBar.Panels[0].Text:='Ready.';
      MyExceptionHandler(Self);
      Result := False;
      exit;
   end;
   end;

function TxRepl32.LoadContainer0151(ContainerFileHandle:integer): boolean;
var
   HandledInteger:LongInt;
   ReplBuffer: pCompressedStringArray;
   CurrentRow:integer;
   xCSplit: integer;
   junk: char;
   FSize: LongInt;
begin
   {$I+}
   try
   FSize := FileHandleSize(ContainerFileHandle);
   PrepareLoadGrid(CurrentRow);
   FileRead(ContainerFileHandle,FreqChar,10);
   FileRead(ContainerFileHandle,junk,1);
   if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.50 beta 3 of XReplace.'+
         ' Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
      end;
   xCSplit:=ReadInteger(ContainerFileHandle);
   HandledInteger:=ReadInteger(ContainerFileHandle);

   while (HandledInteger<>-2) and ((xCSplit=1) or (xCSplit=0)) do begin
      if StopLoadingContainer then break;

      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);

      AddCellProps;
      SetLeftSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetLeftSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      if xCSplit = 1 then GridContents^[CurrentRow]^.LeftSplit:=True;

      FreeMem(ReplBuffer);
      inc(CurrentRow);

      FileRead(ContainerFileHandle,junk,1);
      if junk<>MySeparator then begin

      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.50 beta 3 of XReplace. '+
         'Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
         xrpStatusBar.Panels[0].Text:='Ready.';
         Result := False;
         exit;
         end;
      xCSplit:=ReadInteger(ContainerFileHandle);
      HandledInteger:=ReadInteger(ContainerFileHandle);
      end;
   StringGrid1.RowCount:=GridCount;
   StringGrid1.Repaint;
   xrpStatusBar.Panels[0].Text:='Successfully loaded container (version id : 1.50 beta 3).';  {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels[0].Text);{$ENDIF}
   Result := True;
   except
      MyExceptionHandler(Self);
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
   end;
   end;

procedure TxRepl32.PrepareLoadGrid(var CurrentRow: LongInt);
begin
     if Hi(GetKeyState(VK_SHIFT))=255 then begin
        CurrentRow:=StringGrid1.RowCount - 1;
        if EditText.Visible then begin
           CloseEditText;
           EditText.Visible:=False;
           end;
        end else begin
        CurrentRow:=1;
        PrepareLoadforGrid;
        end;
     end;

function TxRepl32.LoadContainer0152(ContainerFileHandle:integer): boolean;
var
   HandledInteger:LongInt;
   ReplBuffer: pCompressedStringArray;
   CurrentRow:integer;
   xCSplit: integer;
   xCInter: integer;
   xCWhole: integer;
   xCCase: integer;
   xCPrompt: integer;
   junk: char;
   FSize: LongInt;
begin
   {$I+}
   try
   FSize:=FileHandleSize(ContainerFileHandle);
   PrepareLoadGrid(CurrentRow);
   FileRead(ContainerFileHandle,FreqChar,10);
   FileRead(ContainerFileHandle,junk,1);
   if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.71 of XReplace.'+
         ' Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
      end;

   xCSplit:=ReadInteger(ContainerFileHandle);
   xCInter:=ReadInteger(ContainerFileHandle);
   xCCase:=ReadInteger(ContainerFileHandle);
   xCWhole:=ReadInteger(ContainerFileHandle);
   xCPrompt:=ReadInteger(ContainerFileHandle);

   HandledInteger:=ReadInteger(ContainerFileHandle);

   while (HandledInteger<>-2)
         and ((xCCase = 1) or (xCCase = 0))
         and ((xCWhole = 1) or (xCWhole = 0))
         and ((xCSplit=1) or (xCSplit=0))
         and ((xcInter = 1) or (xcInter = 0))
         and ((xcPrompt = 1) or (xcPrompt = 0)) do begin

      if StopLoadingContainer then break;

      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);

      AddCellProps;

      SetLeftSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetLeftSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      if xCSplit = 1 then GridContents^[CurrentRow]^.LeftSplit:=True;
      {$ifdef Registered}
      if xCInter = 1 then GridContents^[CurrentRow]^.Inter:=True;
      if xCCase = 1 then GridContents^[CurrentRow]^.CaseSens:=True;
      if xCWhole = 1 then GridContents^[CurrentRow]^.WholeWord:=True;
      if xCPrompt = 1 then GridContents^[CurrentRow]^.Prompt:=True;
      {$endif}

      FreeMem(ReplBuffer);
      CurrentRow:=CurrentRow+1;

      FileRead(ContainerFileHandle,junk,1);
      if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.71 of XReplace. '+
         'Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
         xrpStatusBar.Panels[0].Text:='Ready.';
         Result := False;
         exit;
         end;

      xCSplit:=ReadInteger(ContainerFileHandle);
      xCInter:=ReadInteger(ContainerFileHandle);
      xCCase:=ReadInteger(ContainerFileHandle);
      xCWhole:=ReadInteger(ContainerFileHandle);
      xCPrompt:=ReadInteger(ContainerFileHandle);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      end;
   StringGrid1.RowCount:=GridCount;
   StringGrid1.Repaint;
   xrpStatusBar.Panels[0].Text:='Successfully loaded container (version id : 1.71).';  {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels[0].Text);{$ENDIF}
   Result := True;
   except
      MyExceptionHandler(Self);
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
   end;
   end;

function TxRepl32.LoadContainer0153(ContainerFileHandle:integer): boolean;
var
   HandledInteger:LongInt;
   ReplBuffer: pCompressedStringArray;
   CurrentRow:integer;
   xCLeftSplit: integer;
   xCRightSplit: integer;
   xCInter: integer;
   xCWhole: integer;
   xCCase: integer;
   xCPrompt: integer;
   junk: char;
   FSize: LongInt;
begin
   {$I+}
   try
   FSize:=FileHandleSize(ContainerFileHandle);
   PrepareLoadGrid(CurrentRow);
   FileRead(ContainerFileHandle,FreqChar,10);
   FileRead(ContainerFileHandle,junk,1);
   if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.75 of XReplace.'+
         ' Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
      end;

   xCLeftSplit:=ReadInteger(ContainerFileHandle);
   xCRightSplit:=ReadInteger(ContainerFileHandle);
   xCInter:=ReadInteger(ContainerFileHandle);
   xCCase:=ReadInteger(ContainerFileHandle);
   xCWhole:=ReadInteger(ContainerFileHandle);
   xCPrompt:=ReadInteger(ContainerFileHandle);

   HandledInteger:=ReadInteger(ContainerFileHandle);

   while (HandledInteger<>-2)
         and ((xCCase = 1) or (xCCase = 0))
         and ((xCWhole = 1) or (xCWhole = 0))
         and ((xCLeftSplit=1) or (xCLeftSplit=0))
         and ((xCRightSplit=1) or (xCRightSplit=0))
         and ((xcInter = 1) or (xcInter = 0))
         and ((xcPrompt = 1) or (xcPrompt = 0)) do begin

      if StopLoadingContainer then break;

      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);

      AddCellProps;

      SetLeftSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetLeftSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      if xCLeftSplit = 1 then GridContents^[CurrentRow]^.LeftSplit:=True;
      {$ifdef Registered}
      if xCRightSplit = 1 then GridContents^[CurrentRow]^.RightSplit:=True;
      if xCInter = 1 then GridContents^[CurrentRow]^.Inter:=True;
      if xCCase = 1 then GridContents^[CurrentRow]^.CaseSens:=True;
      if xCWhole = 1 then GridContents^[CurrentRow]^.WholeWord:=True;
      if xCPrompt = 1 then GridContents^[CurrentRow]^.Prompt:=True;
      {$endif}

      FreeMem(ReplBuffer);
      CurrentRow:=CurrentRow+1;

      FileRead(ContainerFileHandle,junk,1);
      if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.71 of XReplace. '+
         'Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
         xrpStatusBar.Panels[0].Text:='Ready.';
         Result := False;
         exit;
         end;

      xCLeftSplit:=ReadInteger(ContainerFileHandle);
      xCRightSplit:=ReadInteger(ContainerFileHandle);
      xCInter:=ReadInteger(ContainerFileHandle);
      xCCase:=ReadInteger(ContainerFileHandle);
      xCWhole:=ReadInteger(ContainerFileHandle);
      xCPrompt:=ReadInteger(ContainerFileHandle);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      end;

   FileSeek(ContainerFileHandle, -2, 1);
   StringGrid1.RowCount:=GridCount;
   StringGrid1.Repaint;
   xrpStatusBar.Panels[0].Text:='Successfully loaded container (version id : 1.75).';  {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels[0].Text);{$ENDIF}
   Result := True;
   except
      MyExceptionHandler(Self);
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
   end;
   end;

function TxRepl32.LoadContainer0154(ContainerFileHandle:integer): boolean;
var
   HandledInteger:LongInt;
   ReplBuffer: pCompressedStringArray;
   CurrentRow:integer;
   xCLeftSplit: integer;
   xCRightSplit: integer;
   xCInter: integer;
   xCWhole: integer;
   xCCase: integer;
   xCPrompt: integer;
   xcReplaceCopies: integer;
   junk: char;
   FSize: LongInt;
   FPosP: LongInt;
begin
   {$I+}
   try
   FSize:=FileHandleSize(ContainerFileHandle);
   PrepareLoadGrid(CurrentRow);
   FileRead(ContainerFileHandle,FreqChar,10);
   FileRead(ContainerFileHandle,junk,1);
   if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.76 of XReplace.'+
         ' Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
      end;

   FPosP:=FileSeek(ContainerFileHandle, 0, 1);
   xCLeftSplit:=ReadInteger(ContainerFileHandle);
   xCRightSplit:=ReadInteger(ContainerFileHandle);
   xCInter:=ReadInteger(ContainerFileHandle);
   xCCase:=ReadInteger(ContainerFileHandle);
   xCWhole:=ReadInteger(ContainerFileHandle);
   xCPrompt:=ReadInteger(ContainerFileHandle);
   xCReplaceCopies:=ReadInteger(ContainerFileHandle);

   HandledInteger:=ReadInteger(ContainerFileHandle);

   while (HandledInteger<>-2)
         and ((xCCase = 1) or (xCCase = 0))
         and ((xCWhole = 1) or (xCWhole = 0))
         and ((xCLeftSplit=1) or (xCLeftSplit=0))
         and ((xCRightSplit=1) or (xCRightSplit=0))
         and ((xcInter = 1) or (xcInter = 0))
         and ((xcPrompt = 1) or (xcPrompt = 0)) do begin

      if StopLoadingContainer then break;

      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);

      AddCellProps;

      SetLeftSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetLeftSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      if xCLeftSplit = 1 then GridContents^[CurrentRow]^.LeftSplit:=True;
      {$ifdef Registered}
      if xCRightSplit = 1 then GridContents^[CurrentRow]^.RightSplit:=True;
      if xCInter = 1 then GridContents^[CurrentRow]^.Inter:=True;
      if xCCase = 1 then GridContents^[CurrentRow]^.CaseSens:=True;
      if xCWhole = 1 then GridContents^[CurrentRow]^.WholeWord:=True;
      if xCPrompt = 1 then GridContents^[CurrentRow]^.Prompt:=True;
      if xCReplaceCopies >= 1 then GridContents^[CurrentRow]^.ReplaceCopies:=xCReplaceCopies else GridContents^[CurrentRow]^.ReplaceCopies:=1;
      {$else}
      if xCReplaceCopies >= 1 then GridContents^[CurrentRow]^.ReplaceCopies:=1 else GridContents^[CurrentRow]^.ReplaceCopies:=1;
      {$endif}

      FreeMem(ReplBuffer);
      CurrentRow:=CurrentRow+1;

      FileRead(ContainerFileHandle,junk,1);
      if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.71 of XReplace. '+
         'Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
         xrpStatusBar.Panels[0].Text:='Ready.';
         Result := False;
         exit;
         end;

      xCLeftSplit:=ReadInteger(ContainerFileHandle);
      FPosP:=FileSeek(ContainerFileHandle,0,1);
      xCRightSplit:=ReadInteger(ContainerFileHandle);
      xCInter:=ReadInteger(ContainerFileHandle);
      xCCase:=ReadInteger(ContainerFileHandle);
      xCWhole:=ReadInteger(ContainerFileHandle);
      xCPrompt:=ReadInteger(ContainerFileHandle);
      xCReplaceCopies:=ReadInteger(ContainerFileHandle);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      end;

   FileSeek(ContainerFileHandle, FPosP - FileSeek(ContainerFileHandle, 0, 1) + Length(xRepHeader), 1);
   StringGrid1.RowCount:=GridCount;
   StringGrid1.Repaint;
   xrpStatusBar.Panels[0].Text:='Successfully loaded container (version id : 1.76).';  {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels[0].Text);{$ENDIF}
   Result := True;
   except
      MyExceptionHandler(Self);
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
   end;
   end;

function TxRepl32.LoadContainer0155(ContainerFileHandle:integer): boolean;
var
   HandledInteger:LongInt;
   ReplBuffer: pCompressedStringArray;
   CurrentRow:integer;
   xCLeftSplit: integer;
   xCRightSplit: integer;
   xCInter: integer;
   xCWhole: integer;
   xCCase: integer;
   xCPrompt: integer;
   xCDisabled: integer;
   xcReplaceCopies: integer;
   junk: char;
   FSize: LongInt;
   FPosP: LongInt;
begin
   {$I+}
   try
   FSize:=FileHandleSize(ContainerFileHandle);
   PrepareLoadGrid(CurrentRow);
   FileRead(ContainerFileHandle,FreqChar,10);
   FileRead(ContainerFileHandle,junk,1);
   if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.82 of XReplace.'+
         ' Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
      end;

   FPosP:=FileSeek(ContainerFileHandle, 0, 1);
   xCLeftSplit:=ReadInteger(ContainerFileHandle);
   xCRightSplit:=ReadInteger(ContainerFileHandle);
   xCInter:=ReadInteger(ContainerFileHandle);
   xCCase:=ReadInteger(ContainerFileHandle);
   xCWhole:=ReadInteger(ContainerFileHandle);
   xCPrompt:=ReadInteger(ContainerFileHandle);
   xCReplaceCopies:=ReadInteger(ContainerFileHandle);
   xCDisabled := ReadInteger(ContainerFileHandle);

   HandledInteger:=ReadInteger(ContainerFileHandle);

   while (HandledInteger<>-2)
         and ((xCCase = 1) or (xCCase = 0))
         and ((xCWhole = 1) or (xCWhole = 0))
         and ((xCLeftSplit=1) or (xCLeftSplit=0))
         and ((xCRightSplit=1) or (xCRightSplit=0))
         and ((xcInter = 1) or (xcInter = 0))
         and ((xcPrompt = 1) or (xcPrompt = 0))
         and ((xcDisabled = 1) or (xcDisabled = 0))

         do begin

      if StopLoadingContainer then break;

      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);

      AddCellProps;

      SetLeftSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));
      FreeMem(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetLeftSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=AllocMem(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSplitSide(CurrentRow, GetCompressedString(pointer(ReplBuffer)));

      if xCLeftSplit = 1 then GridContents^[CurrentRow]^.LeftSplit:=True;
      {$ifdef Registered}
      if xCRightSplit = 1 then GridContents^[CurrentRow]^.RightSplit:=True;
      if xCInter = 1 then GridContents^[CurrentRow]^.Inter:=True;
      if xCCase = 1 then GridContents^[CurrentRow]^.CaseSens:=True;
      if xCWhole = 1 then GridContents^[CurrentRow]^.WholeWord:=True;
      if xCPrompt = 1 then GridContents^[CurrentRow]^.Prompt:=True;
      if xCReplaceCopies >= 1 then GridContents^[CurrentRow]^.ReplaceCopies:=xCReplaceCopies else GridContents^[CurrentRow]^.ReplaceCopies:=1;
      if xcDisabled = 1 then GridContents^[CurrentRow]^.Disabled := True;
      {$else}
      if xCReplaceCopies >= 1 then GridContents^[CurrentRow]^.ReplaceCopies:=1 else GridContents^[CurrentRow]^.ReplaceCopies:=1;
      {$endif}

      FreeMem(ReplBuffer);
      CurrentRow:=CurrentRow+1;

      FileRead(ContainerFileHandle,junk,1);
      if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.82 of XReplace. '+
         'Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
         xrpStatusBar.Panels[0].Text:='Ready.';
         Result := False;
         exit;
         end;

      xCLeftSplit:=ReadInteger(ContainerFileHandle);
      FPosP:=FileSeek(ContainerFileHandle,0,1);
      xCRightSplit:=ReadInteger(ContainerFileHandle);
      xCInter:=ReadInteger(ContainerFileHandle);
      xCCase:=ReadInteger(ContainerFileHandle);
      xCWhole:=ReadInteger(ContainerFileHandle);
      xCPrompt:=ReadInteger(ContainerFileHandle);
      xCReplaceCopies:=ReadInteger(ContainerFileHandle);
      xcDisabled := ReadInteger(ContainerFileHandle);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      end;

   FileSeek(ContainerFileHandle, FPosP - FileSeek(ContainerFileHandle, 0, 1) + Length(xRepHeader), 1);
   StringGrid1.RowCount:=GridCount;
   StringGrid1.Repaint;
   xrpStatusBar.Panels[0].Text:='Successfully loaded container (version id : 1.82).';  {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels[0].Text);{$ENDIF}
   Result := True;
   except
      MyExceptionHandler(Self);
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
   end;
   end;


function TxRepl32.LoadContainer0150(ContainerFileHandle:integer): boolean;
var
   HandledInteger:LongInt;
   ReplBuffer: PChar;
   CurrentRow:integer;
   xCSplit: integer;
   junk: char;
   Fsize: LongInt;
begin
   {$I+}
   try
   FSize:=FileHandleSize(ContainerFileHandle);
   PrepareLoadGrid(CurrentRow);
   FileRead(ContainerFileHandle,junk,1);
   if junk<>MySeparator then begin
      if ErrorMessages then
      MsgForm.MessageDlg('Invalid XReplace-32 container file.',
         'The container was identified as being created by version 1.50 beta 1 or 2 of XReplace.'+
         ' Neithertheless it contains an error and cannot be loaded entirely.',
         mtError,[mbOk],0,'');
      xrpStatusBar.Panels[0].Text:='Ready.';
      Result := False;
      exit;
      end;
   xCSplit:=ReadInteger(ContainerFileHandle);
   HandledInteger:=ReadInteger(ContainerFileHandle);

   while (HandledInteger<>-2) and ((xCSplit=1) or (xCSplit=0)) do begin

      if StopLoadingContainer then break;

      if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FileHandlePos(ContainerFileHandle) / Fsize) * 100)); except end;

      replBuffer:=StrAlloc(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);

      StringGrid1.RowCount:=CurrentRow+1;
      AddCellProps;

      SetLeftSide(CurrentRow, Copy(ReplBuffer,1,HandledInteger));
      StrDispose(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=StrAlloc(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetRightSide(CurrentRow, Copy(ReplBuffer,1,HandledInteger));
      StrDispose(ReplBuffer);

      HandledInteger:=ReadInteger(ContainerFileHandle);
      replBuffer:=StrAlloc(HandledInteger);
      FileRead(ContainerFileHandle,replBuffer^,HandledInteger);
      SetLeftSplitSide(CurrentRow, Copy(ReplBuffer,1,HandledInteger));
      if xCSplit=1 then begin
         MakeVisible(CurrentRow);
         StringGrid1MouseDown(Self, mbLeft, [], StringGrid1.CellRect(0,CurrentRow).Left+1, StringGrid1.CellRect(0,CurrentRow).Top+1);
         SBRpSplitLeftClick(Self);
         end;
         StrDispose(ReplBuffer);
         CurrentRow:=CurrentRow+1;

         FileRead(ContainerFileHandle,junk,1);
         if junk<>MySeparator then begin
            if ErrorMessages then
            MsgForm.MessageDlg('Invalid XReplace-32 container file.',
                               'The container was identified as being created by version 1.50 beta 1 or 2 of XReplace.'+
                               ' Neithertheless it contains an error and cannot be loaded entirely.',
                               mtError,[mbOk],0,'');
            xrpStatusBar.Panels[0].Text:='Ready.';
            Result := False;
            exit;
            end;
         xCSplit:=ReadInteger(ContainerFileHandle);
         HandledInteger:=ReadInteger(ContainerFileHandle);
         end;

     xrpStatusBar.Panels[0].Text:='Successfully loaded container (version id : 1.50 beta 1,2).';           {$IFDEF Debug}DebugForm.Debug(xrpStatusBar.Panels[0].Text);{$ENDIF}
     EditText.Visible:=False;
     Result := True;
     except
        xrpStatusBar.Panels[0].Text:='Ready.';
        MyExceptionHandler(Self);
        Result := False;
        exit;
     end;
end;

function TxRepl32.LoadContainer(ContainerName: string): boolean;
var
   ContainerFileHandle:integer;
   AContainerVersion: LongInt;
   MyRect: TRect;
begin
     ContainerFileHandle:=-1;
     try

     iWaitState:=TWorking.Create;
     iWaitRunning:=True;

     LoadingContainer:=True;
     StopLoadingContainer:=False;

     iWaitState.oMessage('Loading '+ExtractFileName(ContainerName));

     ReplaceLog.oLog('loading container: ' + ContainerName,'',XReplaceOptions.Log.Everything);
     Result:=True;
     ContainerFileHandle:=FileOpen(ContainerName, fmOpenRead);
     If ContainerFileHandle<=0 then begin
        ReplaceLog.oLog('error opening container for load: '+ContainerName,'',XReplaceOptions.Log.Everything);
        if ErrorMessages then
        MsgForm.MessageDlg('Error opening '+ ContainerName,
                           'XReplace-32 has reported a system error while opening a container file.',mtError,[mbOk],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
        EnableEverything;
        Result:=False;
        if iWaitRunning then begin
           iWaitRunning:=False;
           iWaitState.Kill;
           end;
        LoadingContainer:=False;
        exit;
        end;
     {}
      AContainerVersion:=ContainerVersion(ContainerFileHandle);
      ReplaceLog.oLog('cd '+ShellSpace.Directory,'interface',XReplaceOptions.Log.Rare);
      FileSeek(ContainerFileHandle,11,0);

      if AContainerVersion = -1 then Result := LoadContainer0000(ContainerFileHandle) else
      if AContainerVersion = 100 then Result := LoadContainer0100(ContainerFileHandle) else
      if AContainerVersion = 150 then Result := LoadContainer0150(ContainerFileHandle) else
      if AContainerVersion = 151 then Result := LoadContainer0151(ContainerFileHandle) else
      if AContainerVersion = 152 then Result := LoadContainer0152(ContainerFileHandle) else
      if AContainerVersion = 153 then Result := LoadContainer0153(ContainerFileHandle) else
      if AContainerVersion = 154 then Result := LoadContainer0154(ContainerFileHandle) else
      if AContainerVersion = 155 then Result := LoadContainer0155(ContainerFileHandle) else
      //full states
      if AContainerVersion = 157 then begin
         SaveDialog3.FileName:=OpenDialog1.FileName;
         Result := LoadContainer0151(ContainerFileHandle);
         if Result then Result := LoadGrid0157(ContainerFileHandle);
         if Result then LoadedFullState:=ContainerName else LoadedFullState := '';
         LoadedStringGrid:='';
         LoadedFileList:='';
         end else
      if AContainerVersion = 172 then begin
         SaveDialog3.FileName:=OpenDialog1.FileName;
         Result := LoadContainer0152(ContainerFileHandle);
         if Result then LoadGrid0172(ContainerFileHandle);
         if Result then LoadedFullState:=ContainerName else LoadedFullState := '';
         LoadedFileList:='';
         LoadedStringGrid:='';
         end else
      if AContainerVersion = 173 then begin
         SaveDialog3.FileName:=OpenDialog1.FileName;
         Result := LoadContainer0153(ContainerFileHandle);
         if Result then Result := LoadGrid0172(ContainerFileHandle);
         if Result then LoadedFullState:=ContainerName else LoadedFullState := '';
         LoadedStringGrid:='';
         LoadedFileList:='';
         end else
      if AContainerVersion = 174 then begin
         SaveDialog3.FileName:=OpenDialog1.FileName;
         Result := LoadContainer0154(ContainerFileHandle);
         if Result then Result := LoadGrid0172(ContainerFileHandle);
         if Result then LoadedFullState:=ContainerName else LoadedFullState := '';
         LoadedStringGrid:='';
         LoadedFileList:='';
         end else
      if AContainerVersion = 175 then begin
         SaveDialog3.FileName:=OpenDialog1.FileName;
         Result := LoadContainer0155(ContainerFileHandle);
         if Result then Result := LoadGrid0172(ContainerFileHandle);
         if Result then LoadedFullState:=ContainerName else LoadedFullState := '';
         LoadedStringGrid:='';
         LoadedFileList:='';
         end else
      if AContainerVersion = 170 then begin
         SaveDialog3.FileName:=OpenDialog1.FileName;
         Result := LoadContainer0152(ContainerFileHandle);
         if Result then Result := LoadGrid0157(ContainerFileHandle);
         if Result then LoadedFullState:=ContainerName else LoadedFullState := '';
         LoadedStringGrid:='';
         LoadedFileList:='';
         end else
      begin
        LoadedFullState:='';
        LoadedStringGrid:='';
        ReplaceLog.oLog('error parsing container '+OpenDialog1.FileName,'',XReplaceOptions.Log.Everything);
        if ErrorMessages then
        MsgForm.MessageDlg('Error parsing '+OpenDialog1.FileName,
                           'Your version of XReplace is too old for this container. '+
                           'You may find the latest release of XReplace on the world wide web at http://www.vestris.com',mtError,[mbOk],0,'');
        EnableEverything;
        Result:=False;
        if iWaitRunning then begin
           iWaitState.Kill;
           iWaitRunning:=False;
           end;

        LoadingContainer:=False;
        exit;
        end;
     finally
        FileClose(ContainerFileHandle);
     end;

     if Result then begin
        if LoadedFullState <> ContainerName then begin
           LoadedFullState:='';
           LoadedStringGrid:=ContainerName;
           end;
        try if not EditText.NTBug then if LoadedFullState <> '' then SHAddtoRecentDocs(SHARD_PATH, PChar(LoadedFullState)); except end;
        try if not EditText.NTBug then if LoadedStringGrid <> '' then SHAddtoRecentDocs(SHARD_PATH, PChar(LoadedStringGrid)); except end;
        end;

     UpdateSpecialConditions;
     StringGrid1.TopRow:=1;

     with StringGrid1 do begin
        Row:=1;
        Col:=0;
        MyRect:=CellRect(0,1);
        end;
     StringGrid1MouseDown(Self, mbLeft, [], MyRect.Left+1, MyRect.Top+1);
     EnableEverything;                                                           {$IFDEF Debug}DebugForm.Debug('TxRepl32.LoadContainer:(succeeded):'+Self.ClassName+'::version:'+IntToStr(AContainerVersion));{$ENDIF}
     TreeView1.HalfExpand;
     ReplaceLog.oLog('container '+ContainerName+' loaded.','',XReplaceOptions.Log.Everything);

     LoadingContainer:=False;

     if iWaitRunning then begin
        iWaitState.Kill;
        iWaitRunning:=False;
        end;
   end;

procedure TxRepl32.TreeView1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   aNode: TTreeNode;
   {$ifdef registered}
   OFound, OReplaced: LongInt;
   {$endif}
begin
     if not TreeView1.DropTerminated then exit;
     aNode := TreeView1.GetNodeAt(X, Y);
     if aNode <> nil then begin
        xrpStatusBar.Panels[0].Text:= GetFullRedirection(aNode);
        {$ifdef registered}
        OFound := GetOFound(aNode);
        OReplaced := GetOReplaced(aNode);
        CountOccur(aNode.GetFirstChild, OFound, OReplaced);
        xrpStatusBar.Panels[0].Text := xrpStatusBar.Panels[0].Text + ' ('+IntToStr(OFound) + '/' + IntToStr(OReplaced)+')';
        {$endif}
        end;

     if LoadedFullState <> '' then xrpStatusBar.Panels[1].Text:=ExtractFileName(LoadedFullState)
     else if LoadedFileList <> '' then xrpStatusBar.Panels[1].Text:=ExtractFileName(LoadedFileList)
     else xrpStatusBar.Panels[1].Text := '';
     end;

function TxRepl32.GetNodeType(ANode: TTreeNode): NodeType;
begin
     if ANode.Data <> nil then Result:=PRedirect(ANode.Data).fType else Result := nFile;
     end;

function TxRepl32.GetSource(ANode: TTreeNode): string;
begin
     Result:=PRedirect(ANode.Data).SourceFileName;
     end;

procedure TxRepl32.SetOFound(ANode: TTreeNode; Found: LongInt);
begin
     PRedirect(ANode.Data).OFound := Found;
     end;

procedure TxRepl32.SetOReplaced(ANode: TTreeNode; Replaced: LongInt);
begin
     PRedirect(ANode.Data).OReplaced := Replaced;
     end;

function TxRepl32.GetOFound(ANode: TTreeNode): LongInt;
begin
     if ANode.Data <> nil then Result := PRedirect(ANode.Data).OFound else Result := 0;
     end;

function TxRepl32.GetOReplaced(ANode: TTreeNode): LongInt;
begin
     if ANode.Data <> nil then Result :=  PRedirect(ANode.Data).OReplaced else Result := 0;
     end;

procedure TxRepl32.GetOModifiedFiles(ANode: TTreeNode; var nModifiedCount, nTotalCount: LongInt);
   procedure CountNode(MyNode: TTreeNode);
   begin
      if MyNode.ImageIndex = shSelected then begin
         inc(nModifiedCount);
         inc(nTotalCount);
         end else if (MyNode.ImageIndex = shGeneric) then begin
         inc(nTotalCount);
         end;
      end;

      procedure RecurseNode(MyNode: TTreeNode);
      begin
         while MyNode <> nil do begin
            CountNode(MyNode);
            RecurseNode(MyNode.GetFirstChild);
            MyNode := MyNode.GetNextSibling;
            end;
         end;

begin
     nModifiedCount := 0;
     nTotalCount := 0;
     if ANode <> nil then begin
         DisableEverything;
         CountNode(ANode);
         RecurseNode(ANode.GetFirstChild);
         EnableEverything;
         end;
     end;


function TxRepl32.GetTarget(ANode: TTreeNode): string;
begin
     Result:=PRedirect(ANode.Data).TargetFileName;
     end;

procedure TxRepl32.SetSource(ANode: TTreeNode; iStr: string);
begin
     PRedirect(ANode.Data).SourceFileName := iStr;
     end;

procedure TxRepl32.SetNodeType(ANode: TTreeNode; AType: NodeType);
begin
     PRedirect(ANode.Data).fType := AType;
     end;

procedure TxRepl32.SetTarget(ANode: TTreeNode; iStr: string);
begin
     {$ifdef Registered}
     PRedirect(ANode.Data).TargetFileName := iStr;
     {$else}
     PRedirect(ANode.Data).TargetFileName := '';
     {$endif}
     end;

function TxRepl32.ForceMkDir(ANode: string): boolean;
var
   ADir: string;
   iFound: integer;
begin
     ADir:=ExtractFileDrive(ANode);
     Delete(ANode, 1, Length(ADir));
     repeat
        iFound:=Pos('\', ANode);
        if iFound = 0 Then ADir := ADir + ANode Else ADir:=ADir + Copy(ANode, 1, iFound);
        if not DirectoryExists(Adir) then begin
           try
           MkDir(ADir);
           except
           Result:=False;
           exit;
           end;
           end;
        Delete(ANode, 1, iFound);
        until iFound = 0;
     Result:=True;
     end;

procedure TxRepl32.RPanelResize(Sender: TObject);
begin
   //BBFFDust.Left:=3;
   //BBFFDust.Top:=RPanel.ClientHeight - BBFFDust.Height - 3;//RPanel.ClientWidth - BBFFDust.Width - 2;
   end;

procedure TxRepl32.OpenDialog2Close(Sender: TObject);
begin
     OpenDialog2.InitialDir:='';
     end;

procedure TxRepl32.OpenDialog1Close(Sender: TObject);
begin
     OpenDialog1.InitialDir:='';
     end;

procedure TSpaceMemo.WMDropFiles(var M: TWMDropFiles);
begin
     with M do xRepl32.StringGrid1.Perform(Msg, Drop, Unused);
     end;


procedure TxRepl32.TabPasteClick(Sender: TObject);
{$ifdef Registered}
          function iProcess(iStr: string): string;
          var
             i: integer;
          begin
               Result:='';
               try
               if (iStr[1] = '"') and (iStr[Length(iStr)] = '"') then begin
                  Delete(iStr, 1, 1);
                  Delete(iStr, Length(iStr), 1);
                  for i:=1 to Length(iStr) do begin
                   case iStr[i] of
                      #10: begin
                           Result := Result + #13#10;
                           end;
                      else begin
                           Result := Result + iStr[i];
                           end;
                      end;
                   end;
                  end else Result := iStr;
               except
                     Result:=iStr;
               end;
               end;
const
   Delim: integer = 9;
var
   fStrings : TList;
   cText: string;
   iStrings: TStringList;
   //iIds: array[1..4] of Boolean;

   function GetTextItem: integer;
   var
      i, j, {m,} k: integer;
      CurrentLine: string;
   begin
       iStrings := TStringList.Create;
       Result:=0;

        k:=Pos(Chr(13), cText);
        if k<>0 then begin
           CurrentLine:=Copy(cText, 1, k - 1);
           Delete(cText, 1, k + 1);
           end else begin
           CurrentLine:=cText;
           cText:='';
           end;


      //m:=4;
      j:=Pos(Chr(Delim),CurrentLine);
      //for i:=1 to 3 do iIds[i]:=False;
      for i:=1 to 3 do begin
          if j = 0 then break;
          {if j = 0 then begin
             m := i;
             break;
             end;}
          iStrings.Add(Copy(CurrentLine, 1, j - 1));
          //iStrings[i]:=Copy(CurrentLine, 1, j - 1);
          Delete(CurrentLine, 1, j);
          //iIds[i]:=True;
          inc(Result);
          j:=Pos(Chr(Delim),CurrentLine);
          end;
      if Length(CurrentLine) > 0 then begin
         iStrings.Add(CurrentLine);
         //iStrings[m]:=CurrentLine;
         //iIds[m]:=True;
         inc(Result);
         end;
      if Result > 0 then fStrings.Add(iStrings);
      end;

var
   iRes: integer;
   iRow: integer;
   iWaitRunningLocal: boolean;
   TotalLen: LongInt;
   i: integer;
{$endif}

begin
     {$ifdef Registered}
     fStrings := TList.Create;
     PerformingCopyPaste:=True;
     InterruptCopyPaste:=False;

     DisableEverything;
     if not iWaitRunning then begin
        iWaitState:=TWorking.Create;
        iWaitRunning:=True;
        iWaitRunningLocal:=True;
        end else iWaitRunningLocal:=False;
     if iWaitRunning then try iWaitState.oMessage('Parsing Clipboard ...'); except end;

     try
     cText:=Clipboard.AsText;
     TotalLen:=Length(cText);
     if ((TotalLen = 0) or (not Clipboard.HasFormat(CF_TEXT))) then begin
        MsgForm.MessageDlg('Please copy tab dilimited fields to the clipboard.',
                           'You may use a spreadsheet software and copy entire rows that will then be pasted to the Replacements Grid.', mtError, [mbCancel], 0,'');
        EnableEverything;
        if iWaitRunningLocal then begin
           iWaitState.Kill;
           iWaitRunning:=False;
           end;
        PerformingCopyPaste:=False;
        exit;
        end;

     iRow:=EditText.EditRow;
     EditText.Visible:=False;
     StringGrid1.Enabled:=False;

     while Length(cText) > 0 do begin
           if InterruptCopyPaste then break;
           iWaitState.oStatus(trunc((1 - Length(cText) / TotalLen) * 100));
           Application.ProcessMessages;
           {iRes:=}GetTextItem;

{           InsertGridRow(iRow);

           SetLeftSide(iRow, iStrings[1]);
           if iRes > 2 then begin
              GridContents[iRow].LeftSplit := True;
              SetLeftSplitSide(iRow, iStrings[2]);
              SetRightSide(iRow, iStrings[3]);
              if iRes > 3 then begin
                 GridContents[iRow].RightSplit:=True;
                 SetRightSplitSide(iRow, iStrings[4]);
                 end;
              end else begin
              SetRightSide(iRow, iStrings[2]);
              end;
              }

           end; {while}

     for i:=fStrings.Count - 1 downto 0 do begin
         iRes := TStrings(fStrings[i]).Count;
         InsertGridRow(iRow);
         SetLeftSide(iRow, iProcess(TStrings(fStrings[i])[0]));
           if iRes > 2 then begin
              GridContents[iRow].LeftSplit := True;
              SetLeftSplitSide(iRow, iProcess(TStrings(fStrings[i])[1]));
              SetRightSide(iRow, iProcess(TStrings(fStrings[i])[2]));
              if iRes > 3 then begin
                 GridContents[iRow].RightSplit:=True;
                 SetRightSplitSide(iRow, iProcess(TStrings(fStrings[i])[3]));
                 end;
              end else begin
              if iRes >= 2 then SetRightSide(iRow, iProcess(TStrings(fStrings[i])[1]));
              end;
         TStrings(fStrings[i]).Destroy;
         end;

     fStrings.Destroy;
     StringGrid1.RowCount:=GridCount;
     UpdateGrid;
     StringGrid1.Enabled:=True;
     StringGrid1.Repaint;
     SetGridEdit;
     except
           MyExceptionHandler(Self);
     end;
     if iWaitRunningLocal then begin
        iWaitState.Kill;
        iWaitRunning:=False;
        end;
     EnableEverything;
     PerformingCopyPaste:=False;
     {$endif}
     end;

procedure TxRepl32.TabCopyClick(Sender: TObject);
{$ifdef Registered}
          function eProcess(iStr: string): string;
          var
             iCmd: boolean;
             i: integer;
          begin
               Result:='';
               iCmd := False;
               for i:=1 to Length(iStr) do begin
                   case iStr[i] of
                      #13: begin
                           iCmd := True;
                           end;
                      else begin
                           Result := Result + iStr[i];
                           end;
                      end;
                   end;
               if iCmd then Result := '"'+Result+'"';
               end;
const
   Delim: integer = 9;
var
   i: integer;
   TargetText: string;
   iWaitRunningLocal: boolean;
   {$endif}
begin
     {$ifdef Registered}
     PerformingCopyPaste:=True;
     InterruptCopyPaste:=False;
     DisableEverything;
     if not iWaitRunning then begin
        iWaitState:=TWorking.Create;
        iWaitRunning:=True;
        iWaitRunningLocal:=True;
        end else iWaitRunningLocal:=False;
     if iWaitRunning then try iWaitState.oMessage('Parsing Grid ...'); except end;

     if EditText.Visible then StringGrid1.Row:=EditText.EditRow;
     CloseEditText;
     try EditText.Visible:=False; except end;

     TargetText:='';
     for i:=1 to StringGrid1.RowCount - 1 do begin
         if InterruptCopyPaste then break;
         iWaitState.oStatus(trunc(i / StringGrid1.RowCount * 100));
         Application.ProcessMessages;
         if not AllEmpty(i) then begin
            TargetText:=TargetText + eProcess(GetLeftSide(i)) + Chr(Delim);
            if GridContents[i].LeftSplit then TargetText:=TargetText + eProcess(GetLeftSplitSide(i)) + Chr(Delim);
            TargetText:=TargetText + eProcess(GetRightSide(i));
            if GridContents[i].RightSplit then TargetText:=TargetText + Chr(Delim) + eProcess(GetRightSplitSide(i));
            TargetText:=TargetText + #13#10;
            end;
         end;
     ClipBoard.AsText:=TargetText;
     SetGridEdit;

     if iWaitRunningLocal then begin
        iWaitState.Kill;
        iWaitRunning:=False;
        end;
     EnableEverything;
     PerformingCopyPaste:=False;
     {$endif}
     end;

procedure TxRepl32.StringGrid1EndDrag(Sender, Target: TObject; X, Y: Integer);
begin
     anchorDragging:=False;
     StringGrid1.Repaint;
     end;

procedure TxRepl32.SecretButton1Click(Sender: TObject);
begin
     MsgForm.MessageDlg('Format hard disk?',
                        'Greetings from the author! Come and visit the XReplace-32 official discussion forum at http://www.vestris.com/agnes/split.html !',
                        mtConfirmation,
                        [mbYes], 0,'This is a joke:)');
     end;


procedure TxRepl32.SBRpSplitRightMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   {$ifdef Registered}
   with EditText do begin
   If IsRightSplit(EditRow) then
      SbRpSplitRight.Hint:='join current target cell for interline replacement'
      else
      SbRpSplitRight.Hint:='split current target cell for interline replacement';
      end;
   {$endif}
   end;

procedure TxRepl32.SBRpSplitRightClick(Sender: TObject);
begin
     {$ifdef Registered}
     ToggleSplit(Sender, 1);
     {$IFDEF Debug}with EditText do DebugForm.Debug('TxRepl32::GridSplitStatus::'+BoolToStr(IsLeftSplit(EditRow)) + '/' + BoolToStr(IsRightSplit(EditRow)));{$ENDIF}
     {$endif}
     end;

(*
{$ifdef Registered}
procedure TnumChoose.IncChoose(Sender: TObject);
begin
     inc(GridContents[xRepl32.EditText.EditRow].ReplaceCopies);
     Redraw;
     end;

procedure TnumChoose.DecChoose(Sender: TObject);
begin
     if GridContents[xRepl32.EditText.EditRow].ReplaceCopies > 1 then dec(GridContents[xRepl32.EditText.EditRow].ReplaceCopies);
     Redraw;
     end;

constructor TnumChoose.Create(StatusBar: TStatusBar; StatusPanel: TStatusPanel);
begin
     cmdMinus := TSpeedButton.Create(Application);
     cmdPlus  := TSpeedButton.Create(Application);
     numShow  := TLabel.Create(Application);
     with cmdMinus do begin
          ShowHint:=True;
          Hint:='decrease target replacements copies';
          Glyph:=xRepl32.cmdMinusImage.Picture.Bitmap;
          OnClick:=DecChoose;
          Flat:=True;
          Width := trunc(StatusBar.ClientHeight / 1.5);
          Height:= Width;
          Top:=(StatusBar.Height - Height) div 2 + 1;
          end;
     with cmdPlus do begin
          ShowHint:=True;
          Hint:='increase target replacements copies';
          Glyph:=xRepl32.cmdPlusImage.Picture.Bitmap;
          OnClick:=IncChoose;
          Flat:=True;
          Width := trunc(StatusBar.ClientHeight / 1.5);
          Height:= Width;
          Top:=(StatusBar.Height - Height) div 2 + 1;
          end;
     with numShow do begin
          Font.Color:=clBlue;
          Top:=(StatusBar.Height - Height) div 2 + 1;
          AutoSize:=True;
          end;

     cStatusBar:=StatusBar;
     cStatusPanel:=StatusPanel;

     with cStatusBar do begin
          InsertControl(cmdMinus);
          InsertControl(cmdPlus);
          InsertControl(numShow);
          end;

     Redraw;
     end;

procedure TNumChoose.Redraw;
begin
     try
     with cmdMinus do begin
          if (GridContents[xRepl32.EditText.EditRow].ReplaceCopies > 1) then
             Enabled:=True else Enabled:=False;
          Left:=cStatusBar.Panels[0].Width + cStatusBar.Panels[1].Width + 10;
          end;
     with numShow do begin
          try
          Caption:=' '+IntToStr(GridContents[xRepl32.EditText.EditRow].ReplaceCopies)+' ';
          except
          Caption:=' 0 ';
          end;
          Left:=cmdMinus.Left + cmdMinus.Width;
          end;
     with cmdPlus do begin
          if (GridContents[xRepl32.EditText.EditRow].ReplaceCopies < 9) then
             Enabled:=True else Enabled:=False;
          Left:=numShow.Left + numShow.Width;
          end;
     except
     end;
     end;
{$endif}
*)


procedure TxRepl32.dvClearModifClick(Sender: TObject);
          procedure RecurseNode(MyNode: TTreeNode);
          begin
               while MyNode <> nil do begin
                     //if MyNode.StateIndex = 4 then MyNode.StateIndex := 3;
                     if MyNode.ImageIndex = shSelected then begin
                        MyNode.ImageIndex := shGeneric;
                        MyNode.SelectedIndex := MyNode.ImageIndex;
                        end;
                     RecurseNode(MyNode.GetFirstChild);
                     MyNode := MyNode.GetNextSibling;
                     end;
               end;
begin
     DisableEverything;
     RecurseNode(TreeView1.Items.GetFirstNode);
     EnableEverything;
     end;

procedure TxRepl32.rShowStatsClick(Sender: TObject);
begin
     MsgForm.MessageDlg(
                        {$ifdef Registered}
                        'Total of ' +
                        IntToStr(GridContents[EditText.EditRow].occurrencesFound) +
                        '/' +
                        IntToStr(GridContents[EditText.EditRow].occurrencesReplaced) +
                        ' occurrences replaced.',
                        {$else}
                        'This is a registered version feature, please do register!',
                        {$endif}
               'These statistics are relevant of all recent replacements operations for the currently selected row. Use Clear Stats to reset all statistics information.',
               mtInformation, [mbOk],0,'');
    end;

procedure TxRepl32.rClearStatsClick(Sender: TObject);
var
   i: integer;
begin
   if ClearRowStatistics1.Enabled then begin
   for i:=1 to StringGrid1.RowCount-1 do begin
      GridContents^[i]^.occurrencesFound := 0;
      GridContents^[i]^.occurrencesReplaced := 0;
      end;
   EditText.SetEditRow(EditText.EditRow);
   MsgForm.MessageDlg('Done.',
                      'XReplace-32 has reset the replacements operations per row statistics to zero for each row.',
                      mtInformation,[mbOk], 0, '');
   end;
   end;

procedure TxRepl32.MergeToPopup(Source, Target: TMenuItem);
          procedure MergeToPopupAppend(Source, Target: TMenuItem; Append: boolean);
          var
             i: integer;
             aMenuItem: TMenuItem;
          begin
               if Append then begin
                  aMenuItem := TMenuItem.Create(Target);
                  with aMenuItem do begin
                       Caption := Source.Caption;
                       Enabled := Source.Enabled;
                       Checked := Source.Checked;
                       OnClick := Source.OnClick;
                       Name := 'Merged' + Source.Name;
                       end;
                  Target.Add(aMenuItem);
                  end else aMenuItem := Source;
               for i:=0 to Source.Count - 1 do
                   MergeToPopupAppend(Source[i], aMenuItem, True);
          end;
var
   i: integer;
begin
     for i:=0 to Source.Count - 1 do MergeToPopupAppend(Source[i], Target, True);
     end;

procedure TxRepl32.iNternetClick(Sender: TObject);
begin
     LaunchHtml('http://xreplace.vestris.com');
     end;

procedure TXRepl32.LaunchHtml(iStr: string);
var
   iRes: dword;
begin
     if FileExists(HtmlBrowser) then begin
        iRes := ShellExecute(Self.Handle, 'open', PChar(HtmlBrowser), PChar(iStr), PChar(ExtractFileDir(HtmlBrowser)), SW_MAXIMIZE);
        if iRes <= 32 then iRes := ShellExecute(Self.Handle, 'open', PChar(iStr), nil, PChar(ExtractFileDir(iStr)), SW_MAXIMIZE);
        if iRes <= 32 then Messagedlg('Please install a web browser on your PC.', mtError, [mbOk], 0);
        end else begin
        Messagedlg('Please install a web browser on your PC.', mtError, [mbOk], 0);
        end;
     end;



procedure TxRepl32.SBPreviewClick(Sender: TObject);
begin
     Operation := opPreview;
     PerformReplacements;
     end;

procedure TxRepl32.CountOccur(aNode: TTreeNode; var OFound, OReplaced: LongInt);
begin
     while ANode<>nil do begin
           if ANode.Count > 0 then CountOccur(ANode.GetFirstChild, OFound, OReplaced);
              if (xRepl32.GetNodeType(aNode) = nFile) then begin
                 OFound := OFound + GetOFound(aNode);
                 OReplaced := OReplaced + GetOReplaced(aNode);
                 end;
              ANode:=ANode.GetNextSibling;
              end;
     end;

procedure TxRepl32.dvStatsClick(Sender: TObject);
var
   OFound, OReplaced, OModifiedFiles, OTotalFiles: longint;
begin
   if TreeView1.Selected = nil then exit;
   OFound := GetOFound(TreeView1.Selected);
   OReplaced := GetOReplaced(TreeView1.Selected);
   GetOModifiedFiles(TreeView1.Selected, OModifiedFiles, OTotalFiles);
   CountOccur(TreeView1.Selected.GetFirstChild, OFound, oReplaced);
   MsgForm.MessageDlg(
                        {$ifdef Registered}
                        'Total of ' +
                        IntToStr(OFound) +
                        '/' +
                        IntToStr(OReplaced) +
                        ' occurrence(s) replaced, in ' +
                        IntToStr(OModifiedFiles) + '/' + IntToStr(OTotalFiles) + ' file(s),' +
                        ' under ' + TreeView1.Selected.Text + '.',
                        {$else}
                        'This is a registered version feature, please do register!',
                        {$endif}
               'These statistics are relevant of the latest replacements operation for the currently selected file, directory or drive.',
               mtInformation, [mbOk],0,'');

   end;

procedure TSpaceMemo.SetEditCol(Value: LongInt);
begin
     if Value <> FEditCol then begin
        FEditCol := Value;
        end;
     end;

{$ifdef Registered}
procedure TSpaceMemo.TotCount(var totFound, totReplaced: integer);
var
   i: LongInt;
begin
     totFound := 0;
     totReplaced := 0;
     for i:=0 to xRepl32.StringGrid1.RowCount - 1 do
         if GridCount > i then begin
            inc(totFound, GridContents[i].occurrencesFound);
            inc(totReplaced, GridContents[i].occurrencesReplaced);
            end;
     end;
{$endif}

procedure TSpaceMemo.SetEditRow(Value: LongInt);
   {$ifdef Registered}
var
   totFound, totReplaced: integer;
   {$endif}
begin
     {$ifdef Registered}
     TotCount(totFound, totReplaced);
     XRepl32.StatusLabel.Visible := True;
     xRepl32.StatusLabel.Caption := IntToStr(GridContents[Value].occurrencesFound) + '/' + IntToStr(totFound) +
                                       ' occurrence(s) found,'+ #13#10 +
                                       IntToStr(GridContents[Value].occurrencesReplaced) + '/' + IntToStr(totReplaced) +
                                       ' occurrence(s) replaced.';
     {$endif}
     if Value <> FEditRow then FEditRow := Value;
     end;


procedure TxRepl32.TreeView1KeyPress(Sender: TObject; var Key: Char);
begin
     if (Key in ['s','S']) then dvStats.Click;
     end;

procedure TxRepl32.filterPanelResize(Sender: TObject);
begin
     FilterComboBox1.Width := FilterPanel.ClientWidth;
     FilterPanel.ClientHeight := FiltercomboBox1.Height;
     end;

procedure TxRepl32.ShowIntroForm(EnableTimer: boolean);
begin
   if (XRIntroForm = nil) then
      Application.CreateForm(TXRIntroForm, XRIntroForm);

   XRIntroForm.closeTimer.Enabled := EnableTimer;
   XRIntroForm.shCheckBox.Checked := XReplaceOptions.Gen.ShowIntro;
   XRIntroForm.Show;
   end;

procedure TxRepl32.FormShow(Sender: TObject);
begin
     {ifdef Registered}
     if XReplaceOptions.Gen.ShowIntro then
     {endif}
         ShowIntroForm(true);
     ShellSpaceChange(Sender, ShellSpace.Selected);
     end;

procedure TxRepl32.ShellSpaceMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   aNode: TTreeNode;
begin
     if Button = mbRight then begin
        //...
     end else begin
         if isChanging then isChanging := False else begin
         //if not ShellSpace.isExpanding then begin
         aNode := ShellSpace.GetNodeAt(X, Y);
         if (aNode <> nil) and (aNode.Data <> nil) and (aNode = ShellSpace.Selected) then
           if DirectoryExists(PCPidl(aNode.Data)^.u_name) then
              ShellSpace.BeginDrag(False);
           end;
        end;
     end;

procedure TxRepl32.ShellSpaceChange(Sender: TObject; Node: TTreeNode);
begin
     if (not InitProcess) and (not ShellSpace.isParsing) then begin
        isChanging := True;
        FileListbox1.SafeDirectory := ShellSpace.Directory;
        end;
     if (FFProp = nil) then
         Application.CreateForm(TFFProp, FFProp);
     if FFProp.Visible then
         FFProp.ShowPropsVolume(ShellSpace.Directory);
     end;

procedure TxRepl32.TreeView1Expanded(Sender: TObject; Node: TTreeNode);
begin
     TreeView1.Refresh;
     end;

procedure TxRepl32.TreeView1Collapsed(Sender: TObject; Node: TTreeNode);
begin
     TreeView1.Refresh;
     end;


procedure TxRepl32.Cut1Click(Sender: TObject);
var
   iPos: integer;
begin
     with EditText do
     if SelLength > 0 then begin
        Copy1.Click;
        iPos := SelStart;
        Text := Copy(Text, 1, SelStart) + Copy(Text, SelStart + SelLength + 1,  Length(Text));
        SelStart := iPos;
        end;
     end;

procedure TxRepl32.Copy1Click(Sender: TObject);
begin
     if EditText.SelLength > 0 then Clipboard.AsText := Copy(EditText.Text, EditText.SelStart + 1, EditText.SelLength);
     end;

procedure TxRepl32.SelectAll1Click(Sender: TObject);
begin
     with EditText do begin
          SelStart := 0;
          SelLength := Length(Text);
          end;
     end;

procedure TxRepl32.Paste1Click(Sender: TObject);
var
   sPos: integer;
begin
     with EditText do begin
        sPos := SelStart + Length(Clipboard.AsText);
        Text := Copy(Text, 1, SelStart) + Clipboard.AsText + Copy(Text, SelStart + SelLength + 1,  Length(Text));
        SelStart := sPos;
        end;
     end;

procedure TxRepl32.ShowTotals1Click(Sender: TObject);
{$ifdef Registered}
var
   totFound, totReplaced: LongInt;
{$endif}
begin
     {$ifdef Registered}
     EditText.TotCount(totFound, totReplaced);
     {$endif}
     MsgForm.MessageDlg(
                        {$ifdef Registered}
                        'Total of ' +
                        IntToStr(totFound) +
                        '/' + 
                        IntToStr(totReplaced) +
                        ' occurrence(s) replaced.',
                        {$else}
                        'This is a registered version feature, please do register!',
                        {$endif}
               'These statistics are relevant of all recent replacements operations for the Replacements Grid. Use Clear Stats to reset all statistics information.',
               mtInformation, [mbOk],0,'');

     end;

procedure TxRepl32.Rows1Click(Sender: TObject);
begin
   if (not (Sender is TMenuItem)) or (CompareText(Copy((Sender as TMenuItem).Name, 1, Length('Merged')), 'Merged') <> 0) then
   with EditText do begin
        {$ifdef Registered}
        EnableDisableRow.Checked  := not IsEnabled(EditRow);
        JoinSplitMenu.Enabled := SBRpSplitLeft.Enabled;
        RowInterline.Enabled := SBRpSplitRight.Enabled;
        RowInterline.Checked := isRightSplit(EditRow);
        {$endif}
        if IsLeftSplit(EditRow) then JoinSplitMenu.Caption:='&Join' else JoinSplitMenu.Caption:='&Split';
        end;
   end;

procedure TxRepl32.RGridMenuPopup(Sender: TObject);
    procedure ClearCC(MenuItems: TMenuItem);
    var
       aItem: TMenuItem;
    begin
         with MenuItems do
         while Count > 0 do begin
             aItem := Items[0];
             ClearCC(aItem);
             Remove(aItem);
             aItem.Free;
             end;
         end;

begin
     ClearCC(RGridMenu.Items);
     Replacements1Click(Sender);
     Rows1Click(Sender);
     MergeToPopup(EditMenu.Items, RGridMenu.Items);
     MergeToPopup(Replacements1, RGridMenu.Items);
     end;


procedure TxRepl32.sbRpDisableClick(Sender: TObject);
begin
   {$ifdef Registered}
   {$IFDEF Debug}DebugForm.Debug('TSpaceMemo(StringGrid1.MouseDown)::sbRpDisableClick');{$ENDIF}
   if EditText.Visible then begin
      GridContents[EditText.EditRow].Disabled:=not GridContents[EditText.EditRow].Disabled;
      StringGrid1.Repaint;
      end;
   {$endif}
   end;

procedure TxRepl32.FileListBox1KeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
     if Key = 13 then FileListBox1DblClick(Sender);
     end;

procedure TxRepl32.RegExpToggleClick(Sender: TObject);
begin
     XReplaceOptions.Repl.RegExp := RegExpToggle.Down;
     {$ifdef Registered}
     UpdateRegExpState;
     {$endif}
     end;

procedure TxRepl32.mnuAssumeRegExpClick(Sender: TObject);
begin
     {$ifdef Registered}
     mnuAssumeRegExp.Checked := not mnuAssumeRegExp.Checked;
     XReplaceOptions.Repl.RegExp := mnuAssumeRegExp.Checked;
     RegExpToggle.Down := XReplaceOptions.Repl.RegExp;
     UpdateRegExpState;
     {$endif}
     end;

{$ifdef Registered}
procedure TxRepl32.UpdateRegExpState;
begin
     if XReplaceOptions.Repl.RegExp and (CountSplit > 0) then begin
        MsgForm.MessageDlg('Replacements grid contains split rows. You cannot enable RegExp!',
                               'Please remove all split rows. For more information, read the manual about regular expressions.',
                               mtInformation,[mbCancel],0,'');
        XReplaceOptions.Repl.RegExp := False;
        RegExpToggle.Down := XReplaceOptions.Repl.RegExp;
        end;
     EditText.EditChange(Self);
     ResetGridHeader;
     StringGrid1.Repaint;
     end;
{$endif}

procedure TxRepl32.ResetGridHeader;
begin
     {$ifdef Registered}
     if XReplaceOptions.Repl.RegExp then begin
        SetLeftSide(0, gFrom + ' (regexp)');
        SetRightSide(0, gTo + ' (regexp)');
        end else begin
     {$endif}
        SetLeftSide(0, gFrom);
        SetRightSide(0, gTo);
     {$ifdef Registered}
        end;
     {$endif}
     end;

{$ifdef Registered}
procedure TxRepl32.xReplaceInternalRegExp(var ReadLine:string;i:integer);
          const
               Displacer: integer=200;
          function Bound(AnyInteger, Min, Max: integer):integer;
          begin
               if AnyInteger<Min then Bound:=Min else
               if AnyInteger>Max then Bound:=Max else
               Bound:=AnyInteger;
               end;
          function REGSearch(iString: string; sSearchExp: string; sReplaceExp: string; var nPos: integer; var offset: integer; var replacelen: integer; var pReplaceStr: string; var Found: integer; var Replaced: integer): string;
          var
             pReplaceStrRes: PChar;
             iResult: integer;
             Error: PChar;
             CanReplace: boolean;
             RSide: string;
             LSide: string;
          begin
               if (Length(iString) > 0) and (Length(sSearchExp) > 0) and (Length(sReplaceExp) > 0) then begin
               try
               Found := 0;
               Replaced := 0;
               DontReplacecurrent := False;
               iResult := Search(PChar(iString), PChar(sSearchExp), pChar(sReplaceExp), nPos, offset, replacelen, pReplaceStrRes, Error);
               while (iResult > 0) do begin
                     CanReplace := False;
                     if Application.Terminated or InterruptReplace and not ReplaceAll then break;
                     pReplaceStr := pReplaceStrRes;
                     inc(Found);
                     inc(CurrentStats.occurrencesFound);
                     //---
                     // check if canreplace
                     //---
                     if not (xReplaceOptions.Repl.PromptOnReplace or GridContents[i].Prompt) then CanReplace:=True;
                     if (xReplaceOptions.Repl.PromptOnReplace or GridContents[i].Prompt) and (not ReplaceAll) and (not ReplaceAllCurrent) and (not DontReplaceCurrent) then begin

                        if (ReplaceForm = nil) then
                           Application.CreateForm(TReplaceForm, ReplaceForm);

                        ReplaceForm.Status.SimpleText:=GlobalFileName;
                        LSide := Copy(iString,Bound(offset-Displacer,1,offset),Bound(Displacer,1,offset));
                        Rside := Copy(iString, offset + replacelen + 1, Displacer);
                        ReplaceForm.LoadLine(
                               LSide,
                               Copy(iString, offset+1, replacelen),
                               RSide,
                               LSide,
                               pReplaceStr,
                               RSide);
                        case ReplaceForm.ShowModal of
                        mrYes: {do replace}
                               CanReplace:=True;
                        mrNo:  {don't replace}
                               CanReplace:=False;
                        10002: {yes to all in current file}
                        begin
                             ReplaceAllCurrent:=True;
                             CanReplace:=True;
                             end;
                        10003: {no to all in current file}
                        begin
                             DontReplaceCurrent:=True;
                             CanReplace:=False;
                             end;
                        10000: {yes to all in all files}
                        begin
                             ReplaceAll:=True;
                             CanReplace:=True;
                             end;
                        10001: {no to all in all files (cancel)}
                        begin
                             DontReplaceCurrent:=True;
                             InterruptReplace:=True;
                             CanReplace:=False;
                             end;
                             end;
                     end else if (not DontReplaceCurrent) then CanReplace := True;

                     if (CanReplace) then begin
                        inc(Replaced);
                        inc(CurrentStats.occurrencesReplaced);
                        Result := Result + Copy(iString, 0, offset) + pReplaceStr;
                        end else begin
                        Result := Result + Copy(iString, 0, offset + replacelen);
                        end;
                     iString := Copy(iString, offset + replacelen + 1, Length(iString));
                     xrpStatusBar.Panels[0].Text:='Still working, (total of '+IntToStr(CurrentStats.occurrencesFound)+' occurrence(s) found - '+IntToStr(CurrentStats.occurrencesReplaced)+' replaced)';
                     xrpStatusBar.Update;
                     iResult := Search(PChar(iString), PChar(sSearchExp), pChar(sReplaceExp), nPos, offset, replacelen, pReplaceStrRes, Error);
                     end;
               Result := Result + iString;
               except
                     MyExceptionHandler(Self);
               end;
          end else Result := '';
          end;

var
   nPos: integer;
   offset: integer;
   replacelen: integer;
   pReplaceStr: string;
   Found: integer;
   Replaced: integer;
begin
     ReadLine := REGSearch(ReadLine, GetLeftside(i), GetRightSide(i), nPos, offset, replacelen, pReplaceStr, Found, Replaced);
     end;

{$endif}

procedure TxRepl32.StatusLabelDblClick(Sender: TObject);
begin
     rClearStatsClick(Sender);
     end;
procedure TxRepl32.popRefreshClick(Sender: TObject);
begin
     ShellSpace.Rebuild;
     end;

procedure TxRepl32.Properties1Click(Sender: TObject);
begin
     if (FFProp = nil) then
         Application.CreateForm(TFFProp, FFProp);
     if not FFProp.Visible then
         FFProp.Visible := True;
     FFProp.ShowPropsVolume(ShellSpace.Directory);
     end;

procedure TxRepl32.IntroWindowClick(Sender: TObject);
begin
     ShowIntroForm(false);
     end;

procedure TxRepl32.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
      SBTreeViewSave.Enabled := not TreeView1.isEmpty;
      BBFFDust.Enabled := SBTreeViewSave.Enabled;
      SbRemoveAll.Enabled := SBTreeViewSave.Enabled;
      {$ifdef Registered}
      SbRedirect.Enabled := SBTreeViewSave.Enabled;
      {$endif}
     end;

procedure TxRepl32.xrLoadAllClick(Sender: TObject);
begin
     SBrpLoadClick(Sender);
     end;

procedure TxRepl32.btnExpandButtonsClick(Sender: TObject);
begin
   initXOptions;
   XReplaceOptions.Gen.ShowAllButtons := true;
   UpdateInterfacePerOptions;
   TXOptions.UpdateRegistry;
   end;

procedure TxRepl32.btnContractButtonsClick(Sender: TObject);
begin
   initXOptions;
   XReplaceOptions.Gen.ShowAllButtons := false;
   UpdateInterfacePerOptions;
   TXOptions.UpdateRegistry;
   end;

procedure TxRepl32.ShowHelp(Url: string);
begin
   if HtmlHelp = nil then
      Application.CreateForm(THtmlHelp, HtmlHelp);
   HtmlHelp.Show;
   HtmlHelp.Navigate(Url);
   end;

procedure TxRepl32.dvExpandClick(Sender: TObject);
var
   TreeNode: TTreeNode;
begin
   try
   if TreeView1.DropTerminated then begin
      TreeNode := TreeView1.Selected;
      TreeNode.Expand(True);
      end;
   except
      MyExceptionHandler(Sender);
   end;
   end;

procedure TxRepl32.dvClearRedirectClick(Sender: TObject);
begin
        SetTarget(TreeView1.Selected, '');
        TreeView1.Selected.Text := GetSource(TreeView1.Selected);
        end;

end.
