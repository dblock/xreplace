unit xopt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ExtCtrls, Registry, FileCtrl, d32reg, d32about, d32debug;

type

  PReplOptions = ^TReplOptions;
  TReplOptions = record
     RegExp,
     CaseSensitive,
     PreserveDateTime,
     PromptOnReplace,
     OverwriteBackups,
     IncludeSource,
     FileAttributeCare,
     WarnIfBinary,
     WholeWordsOnly,
     CreateBackups,
     AlwaysCreateBackups,
     NoErrors,
     CopyRedirect : boolean;
     BackupExt : string;
     BackupLoc : string;
     //TargetCopies: integer;
     end;

  TLogOptions = record
     Create,
     Append,
     Edit,
     Modified,
     Untouched,
     FileSize,
     Directories,
     FilePaths,
     Header,
     Timings,
     MacroDetail,
     DropDetail,
     Everything,
     Rare,
     Batch,
     Shed : boolean;
     LogFile : string;
     end;

  TGenOptions = record
     DefaultViewerOnly,
     ShowFileGlyphs,
     SaveExitDirectory,
     ShowTaggedFileGlyphs,
     SAutoLoad,
     SEmptyActivate,
     PermanentResponse,
     ParallelDragDrop,
     PromptGrid,
     SortedTaggedList,
     ShiftOut,
     ShowAllButtons,
     ShowIntro,
     RememberDirs : boolean;
     end;

  THiddenOptions = record
     RedirectDirectory,
     ContainerDirectory,
     TreeDirectory,
     MacroDirectory,
     SheduleDirectory,
     Viewer,
     ViewerDirectory,
     StartupDirectory: string;
     end;

  TOptions = record
     Repl      : TReplOptions;
     Gen       : TGenOptions;
     Hidden    : THiddenOptions;
     Log       : TLogOptions
     end;

  TXOptions = class(TForm)
    xpOptions: TPageControl;
    xpReplacements: TTabSheet;
    ROptionsGroup: TGroupBox;
    xoCaseSensitive: TCheckBox;
    xoPromptReplace: TCheckBox;
    xoIncludeSource: TCheckBox;
    xoWarnBinary: TCheckBox;
    xpInterface: TTabSheet;
    GroupBox3: TGroupBox;
    xoDefViewer: TCheckBox;
    xoShowFileGlyphs: TCheckBox;
    xoShowTaggedGlyphs: TCheckBox;
    GroupBox4: TGroupBox;
    xoViewer: TEdit;
    xoGetFile: TSpeedButton;
    CommandPanel: TPanel;
    OkButton: TBitBtn;
    CancelButton: TBitBtn;
    xoSaveCurrentDir: TCheckBox;
    HelpCommand: TBitBtn;
    xoAttributeCare: TCheckBox;
    xpLog: TTabSheet;
    xoCreateLog: TCheckBox;
    LogPanel: TPanel;
    GroupBox5: TGroupBox;
    SpeedButton1: TSpeedButton;
    xoLogFileName: TEdit;
    xoLogAppend: TCheckBox;
    xoLogEdit: TCheckBox;
    GroupBox6: TGroupBox;
    xoLogModified: TCheckBox;
    xoLogUntouched: TCheckBox;
    xoLogFileSize: TCheckBox;
    xoLogDirectories: TCheckBox;
    xoLogPaths: TCheckBox;
    xoLogHeader: TCheckBox;
    xoLogTimings: TCheckBox;
    xoLogEverything: TCheckBox;
    DefCurrentPage: TSpeedButton;
    SpeedButton2: TSpeedButton;
    xoWholeWordsOnly: TCheckBox;
    xpAbout: TTabSheet;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    xLabel: TLabel;
    xoPermanentResponse: TCheckBox;
    xoRegister: TSpeedButton;
    xoNoErrors: TCheckBox;
    xoSAutoLoad: TCheckBox;
    xoEmptyActivate: TCheckBox;
    xoLogMacroDetail: TCheckBox;
    xoLogDropDetail: TCheckBox;
    xoLogInterface: TCheckBox;
    xoLogBatch: TCheckBox;
    xoLogShed: TCheckBox;
    xoCopyRedirect: TCheckBox;
    xoRememberDirs: TCheckBox;
    xoTCDec: TSpeedButton;
    xoTCInc: TSpeedButton;
    xoTargetCopies: TLabel;
    Label4: TLabel;
    xoParallelDrop: TCheckBox;
    xoSortedTaggedList: TCheckBox;
    xoPromptGrid: TCheckBox;
    xoRegExp: TCheckBox;
    xoShiftOut: TCheckBox;
    xoPreserveDateTime: TCheckBox;
    xpBackups: TTabSheet;
    GroupBox1: TGroupBox;
    changeBackupLocation: TSpeedButton;
    clearBackupLocation: TSpeedButton;
    xoBackLoc: TEdit;
    BackupGroup: TGroupBox;
    ChangeExt: TSpeedButton;
    xoBackExt: TEdit;
    GroupBox2: TGroupBox;
    xoOverwriteBack: TCheckBox;
    xoAlwaysCreateBackups: TCheckBox;
    xoCreateBackups: TCheckBox;
    xoShowIntro: TCheckBox;
    xoShowAllButtons: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure ChangeExtClick(Sender: TObject);
    procedure xoGetFileClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure HelpCommandClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure xoLogDirectoriesClick(Sender: TObject);
    procedure xoLogPathsClick(Sender: TObject);
    procedure xoCreateLogClick(Sender: TObject);
    procedure xoLogModifiedClick(Sender: TObject);
    procedure UpdateDependencies;
    procedure xoLogUntouchedClick(Sender: TObject);
    procedure ResetDefaults(Page: TTabSheet);
    procedure DefCurrentPageClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure xoAlwaysCreateBackupsClick(Sender: TObject);
    procedure xoRegisterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure xoRememberDirsClick(Sender: TObject);
    //procedure TargetCopyUpdate;
    procedure xoTCDecClick(Sender: TObject);
    procedure xoTCIncClick(Sender: TObject);
    procedure xoRegExpClick(Sender: TObject);
    procedure clearBackupLocationClick(Sender: TObject);
    procedure changeBackupLocationClick(Sender: TObject);
  public
    class function QueryRegString(Node, Name : string; RegDefault: string): string;
    class function QueryRegNumber(Node, Name : string; RegDefault: integer): integer;
    class function QueryRegBool(Node, Name : string; RegDefault: boolean): boolean;
    class procedure SetReg(Node, Name: string; RegValue: variant);
    procedure ShowAbout;
    procedure LoadOptions;
    procedure UpdateOptions;
    class procedure QueryOptions;
    class procedure UpdateRegistry;
    //procedure SetDirDrive(aDir: TDirectoryListBox; aDrive: TDriveComboBox; tStr: string);
  private
    MinWidth, MinHeight: integer;
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
    procedure WMNCHitTest(var M: TWMNCHitTest); message WM_NCHitTest;
  end;

  procedure initXOptions;

var
  XOptions: TXOptions = nil;
  XOldOptions: TOptions;
  XOLocalBackup : string = '[same location as original]';
  
const
  RootQuery: string = '\Software\Vestris Inc.\XReplace-32';
  RootUpdate: string = '\Software\Vestris Inc.\XReplace-32';

implementation

uses xreplace, MDlg, RForm,redirect {$ifdef registered}, xshedule, macro{$endif};

{$R *.DFM}

procedure TXOptions.ShowAbout;
begin
     xpOptions.ActivePage := xpAbout;
     ShowModal;
     end;

procedure initXOptions;
begin
     if XOptions = nil then begin
        Application.CreateForm(TXOptions, XOptions);
        {$ifdef Registered}
        xOptions.xoRegister.Destroy;
        {$endif}
        end;
     end;

{procedure TxOptions.TargetCopyUpdate;
begin
     if StrToInt(xoTargetCopies.Caption) < 9 then xoTCInc.Enabled:=True else xoTCInc.Enabled:=False;
     if StrToInt(xoTargetCopies.Caption) > 1 then xoTCDec.Enabled:=True else xoTCDec.Enabled:=False;
     xoTargetCopies.Update;
     end;}

procedure TXOptions.FormShow(Sender: TObject);
begin
   Left:=xRepl32.Left+(xRepl32.Width-XOptions.Width) div 2;
   Top:=xRepl32.Top+(xRepl32.Height-XOptions.Height) div 2;
   LoadOptions;
   //TargetCopyUpdate;
   XOldOptions:=XReplaceOptions;
   if OkButton.Showing then OkButton.SetFocus;
   with Image1 do begin
      Left:=5;
      Top:=5;
      end;
   with Label1 do begin
      Top:=Image1.Top;
      Caption:=VersionString;
      Left:=Image1.Width + (XpOptions.ActivePage.ClientWidth - Image1.Width - Width) div 2;
      end;
   with xLabel do begin
      Caption:=xrVersion;
      Top:=Label1.Top+Label1.Height+10;
      Left:=(XpOptions.ActivePage.ClientWidth - xLabel.Width) div 2;
      end;
   with Label2 do begin
      Top:=xLabel.Top+xLabel.Height+10;
      Caption:='Copyright © Vestris Inc. - (1996-2000)'+ #13#10+
               'Vestris Inc. - All Rights Reserved.'+ #13#10 +
               'http://www.vestris.com'+#13#10#10+
               'Build ' + XRBuild + #13#10 +
               {$ifdef Registered}
               'Registered version of XReplace-32.';
               {$else}
               'XReplace-32 is NOT freeware! Click on the World button to register. ' + #13#10 + IntToStr(ShareWareMax - xRepl32.TillExpired) + ' days of evaluation left.';
               {$endif}
      Left:=(XpOptions.ActivePage.ClientWidth - Width) div 2;
      end;
   end;

(*procedure TXOptions.SetDirDrive(aDir: TDirectoryListBox; aDrive: TDriveComboBox; tStr: string);
      begin
           try
           tStr:=xRepl32.FullToLFN(tStr);
           if DirectoryExists(tStr) then begin
              aDrive.Drive:=aDir.Directory[1];
              aDir.Directory:=tStr;
              end;
           except
           end;
           end;*)

class procedure TXOptions.QueryOptions;
begin
   with XReplaceOptions do begin
   //--------------------------------------------------------------------------------------------
   // replacements
   //--------------------------------------------------------------------------------------------
   Repl.AlwaysCreateBackups := QueryRegBool('replacements', 'always create backups', False);          //query always create backups
   Repl.CreateBackups       := QueryRegBool('replacements', 'create backups',        True);           //query create backups
   Repl.FileAttributeCare   := QueryRegBool('replacements', 'attribute care',        False);          //query attribute care
   Repl.WarnIfBinary        := QueryRegBool('replacements', 'warn if binary',        True);          //quering warn binary
   Repl.OverwriteBackups    := QueryRegBool('replacements', 'overwrite backups',     True);           //quering overwrite backups
   Repl.IncludeSource       := QueryRegBool('replacements', 'include source',        False);          //quering IncludeSource
   Repl.CaseSensitive       := QueryRegBool('replacements', 'case sensitive',        False);          //quering CaseSensitive
   Repl.RegExp              := QueryRegBool('replacements', 'assume regexp',         False);          //quering Assume Regular Expressions
   Repl.PromptOnReplace     := QueryRegBool('replacements', 'replace prompt',        False);          //quering ReplacePrompt
   Repl.WholeWordsOnly      := QueryRegBool('replacements', 'whole words only',      False);          //quering Whole Words Only
   {$ifdef Registered}
   Repl.PreserveDateTime    := QueryRegBool('replacements', 'preserve date time',    False);          //quering Preserve File Date and Time
   Repl.NoErrors            := QueryRegBool('replacements', 'unattended errors',     False);          //quering Errors as unattended
   Repl.CopyRedirect        := QueryRegBool('replacements', 'copy redirected',       False);          //quering Copy Redirected
   // Repl.TargetCopies := QueryRegNumber('replacements', 'target copies', 1);
   Repl.BackupLoc := QueryRegString('replacements', 'backup location', XOLocalBackup);
   {$else}
   // Repl.TargetCopies:=1;
   Repl.NoErrors := False;
   Repl.CopyRedirect := False;
   Repl.BackupLoc := XOLocalBackup;
   {$endif}
   // Backup extension
   Repl.BackupExt := QueryRegString('replacements', 'backup extension', 'xrp');

   xRepl32.FilterComboBox1.Filter := QueryRegString('general', 'filter', 'All files (*.*)|*.*');


   //--------------------------------------------------------------------------------------------
   // general
   //--------------------------------------------------------------------------------------------
   Gen.ShowFileGlyphs         := QueryRegBool('general', 'show glyphs',               True);                    //quering showglyphs
   Gen.ShowTaggedFileGlyphs   := QueryRegBool('general', 'show tagged glyphs',        True);                    //quering showtaggedglyphs
   {$ifdef Registered}
   Gen.SEmptyActivate         := QueryRegBool('general', 'empty activate activexr',   True);                    //quering semptyactivate
   Gen.SAutoLoad              := QueryRegBool('general', 'autoload activexr',         False);                   //quering sautoload
   Gen.ShowIntro              := QueryRegBool('general', 'show intro',                True);
   {$else}
   Gen.ShowIntro := True;
   Gen.SAutoLoad := False;
   Gen.SEmptyActivate := True;
   {$endif}

   Gen.DefaultViewerOnly      := QueryRegBool('general', 'default viewer only',       False);                   //quering use defonly
   Gen.SaveExitDirectory      := QueryRegBool('general', 'last directory',            True);                    //quering last directory
   Gen.PermanentResponse      := QueryRegBool('general', 'permanent response',        False);                   //quering permanent respose
   Gen.ParallelDragDrop       := QueryRegBool('general', 'parallel drag drop',        False);
   Gen.PromptGrid             := QueryRegBool('general', 'prompt on quit',            True);
   Gen.ShiftOut               := QueryRegBool('general', 'shift out',                 False);
   Gen.ShowAllButtons         := QueryRegBool('general', 'show all buttons',          False);
   Gen.SortedTaggedList       := QueryRegBool('general', 'sorted tagged list',        False);
   Gen.RememberDirs           := QueryRegBool('general', 'remember dirs',             True);                   //quering remember dirs
   //--------------------------------------------------------------------------------------------
   // hidden
   //--------------------------------------------------------------------------------------------
   // quering viewer
   Hidden.ViewerDirectory := QueryRegString('hidden', 'viewer directory', WinDir);
   Hidden.Viewer := QueryRegString('hidden', 'viewer', 'notepad.exe');

   // startup directory
   Hidden.StartupDirectory := QueryRegString('hidden', 'startup directory', xRepl32.ShellSpace.Directory);
   {$IFDEF Debug} DebugForm.Debug('xOpt::QueryOptions::LastDirectory: ' + Hidden.StartupDirectory);{$ENDIF}
   Hidden.RedirectDirectory := QueryRegString('hidden', 'redirect directory', '');
   Hidden.SheduleDirectory := QueryRegString('hidden', 'shedule directory', '');
   Hidden.MacroDirectory := QueryRegString('hidden', 'macro directory', '');
   Hidden.ContainerDirectory := QueryRegString('hidden', 'container directory', '');
   Hidden.TreeDirectory := QueryRegString('hidden', 'tree directory', '');

   if (Length(Hidden.ContainerDirectory) > 0) and DirectoryExists(Hidden.ContainerDirectory) then
      xRepl32.OpenDialog1.InitialDir := Hidden.ContainerDirectory;

   if (Length(Hidden.TreeDirectory) > 0) and DirectoryExists(Hidden.TreeDirectory) then
      xRepl32.OpenDialog2.InitialDir := Hidden.TreeDirectory;

   //--------------------------------------------------------------------------------------------
   // log
   //--------------------------------------------------------------------------------------------
   Log.Create      := QueryRegBool('log', 'create',        False);
   Log.Append      := QueryRegBool('log', 'append',        True);
   Log.Edit        := QueryRegBool('log', 'edit',          False);
   Log.Modified    := QueryRegBool('log', 'modified',      True);
   Log.Untouched   := QueryRegBool('log', 'untouched',     True);
   Log.FileSize    := QueryRegBool('log', 'file size',     True);
   Log.Header      := QueryRegBool('log', 'header',        True);
   Log.Timings     := QueryRegBool('log', 'timings',       True);
   Log.Everything  := QueryRegBool('log', 'everything',    True);
   Log.Rare        := QueryRegBool('log', 'interface',     False);
   {$ifdef Registered}
   Log.MacroDetail := QueryRegBool('log', 'macro detail',  True);
   Log.Batch       := QueryRegBool('log', 'batch',         True);
   Log.Shed        := QueryRegBool('log', 'shed',          True);
   {$endif}
   Log.DropDetail  := QueryRegBool('log', 'drop detail',   False);

   Log.LogFile     := QueryRegString('log', 'log file', 'xreplace.log');
   Log.Directories := QueryRegBool('log','directories', false);
   Log.FilePaths   := not Log.Directories;
   end;
   end;

procedure TXOptions.UpdateOptions;
begin
   try
   with XReplaceOptions do begin
      with repl do begin
         RegExp := xoRegExp.Checked;
         CaseSensitive:=xoCaseSensitive.Checked;
         PromptOnReplace:=xoPromptReplace.Checked;
         OverwriteBackups:=xoOverwriteBack.Checked;
         IncludeSource:=xoIncludeSource.Checked;
         WarnIfBinary:=xoWarnBinary.Checked;
         FileAttributeCare:=xoAttributeCare.Checked;
         WholeWordsOnly:=xoWholeWordsOnly.Checked;
         CreateBackups:=xoCreateBackups.Checked;
         AlwaysCreateBackups:=xoAlwaysCreateBackups.Checked;
         {$ifDef Registered}
         PreserveDateTime := xoPreserveDateTime.Checked;
         NoErrors:=xoNoErrors.Checked;
         CopyRedirect:=xoCopyRedirect.Checked;
         //TargetCopies:=StrToInt(xoTargetCopies.Caption);
         {$else if}
         NoErrors:=False;
         CopyRedirect:=False;
         //TargetCopies:=1;
         {$Endif}
         end;
      with gen do begin
         DefaultViewerOnly:=xoDefViewer.Checked;
         ShowFileGlyphs:=xoShowFileGlyphs.Checked;
         ShowTaggedFileGlyphs:=xoShowTaggedGlyphs.Checked;
         {$ifDef Registered}
         ShowIntro := xoShowIntro.Checked;
         SAutoLoad:=xoSAutoLoad.Checked;
         SEmptyActivate:=xoEmptyActivate.Checked;
         {$else}
         ShowIntro:=True;
         SAutoLoad:=False;
         SEmptyActivate:=True;
         {$endif}
         SaveExitDirectory:=xoSaveCurrentDir.Checked;
         PermanentResponse:=xoPermanentResponse.Checked;
         ParallelDragDrop := xoParallelDrop.Checked;
         PromptGrid := xoPromptGrid.Checked;
         ShiftOut := xoShiftOut.Checked;
         ShowAllButtons := xoShowAllButtons.Checked; 
         SortedTaggedList := xoSortedTaggedList.Checked;
         RememberDirs:=xoRememberDirs.Checked;
         end;
      with log do begin
         Create:=xoCreateLog.Checked;
         Append:=xoLogAppend.Checked;
         Edit:=xoLogEdit.Checked;
         Modified:=xoLogModified.Checked;
         Untouched:=xoLogUntouched.Checked;
         FileSize:=xoLogFileSize.Checked;
         Directories:=xoLogDirectories.Checked;
         Header:=xoLogHeader.Checked;
         Timings:=xoLogTimings.Checked;
         LogFile:=xoLogFileName.Text;
         Everything:=xoLogEverything.Checked;
         Rare:=xoLogInterface.Checked;
         DropDetail:=xoLogDropDetail.Checked;
         {$ifdef Registered}
         Batch:=xoLogBatch.Checked;
         Shed:=xoLogShed.Checked;
         MacroDetail:=xoLogMacroDetail.Checked;
         {$endif}
         end;
      end;
      UpdateDependencies;
   except
      xRepl32.MyExceptionHandler(Xoptions);
   end;
   end;

procedure TXOptions.LoadOptions;
begin
   try
   with XReplaceOptions do begin
      with repl do begin
         xoRegExp.Checked := RegExp;
         xoCaseSensitive.Checked:=CaseSensitive;
         xoPromptReplace.Checked:=PromptOnReplace;
         xoOverwriteBack.Checked:=OverwriteBackups;
         xoIncludeSource.Checked:=IncludeSource;
         xoWarnBinary.Checked:=WarnIfBinary;
         xoBackExt.Text:='.'+BackupExt;
         xoBackLoc.Text:=BackupLoc;
         xoAttributeCare.Checked:=FileAttributeCare;
         xoWholeWordsOnly.Checked:=WholeWordsOnly;
         xoCreateBackups.Checked:=CreateBackups;
         xoAlwaysCreateBackups.Checked:=AlwaysCreateBackups;
         xoCreateBackups.Visible:=not AlwaysCreateBackups;
         {$ifdef Registered}
         xoPreserveDateTime.Checked := PreserveDateTime;
         xoNoErrors.Checked:=NoErrors;
         xoCopyRedirect.Checked:=CopyRedirect;
         //xoTargetCopies.Caption:=IntToStr(TargetCopies);
         {$endif}
         end;
      with hidden do begin
         try
         if ViewerDirectory[Length(ViewerDirectory)]='\' then
            Delete(ViewerDirectory, Length(ViewerDirectory),1);
         except
         end;
         xoViewer.Text:=ViewerDirectory+'\'+Viewer;
         end;
      with gen do begin
         xoDefViewer.Checked:=DefaultViewerOnly;
         xoShowFileGlyphs.Checked:=ShowFileGlyphs;
         xoShowTaggedGlyphs.Checked:=ShowTaggedFileGlyphs;
         {$ifdef Registered}
         xoSAutoLoad.Checked:=SAutoLoad;
         xoEmptyActivate.Checked:=SEmptyActivate;
         xoShowIntro.Checked := ShowIntro;
         {$endif}
         xoSaveCurrentDir.Checked:=SaveExitDirectory;
         xoPermanentResponse.Checked:=PermanentResponse;
         xoParallelDrop.Checked:=ParallelDragDrop;
         xoPromptGrid.Checked := PromptGrid;
         xoShiftOut.Checked := ShiftOut;
         xoShowAllButtons.Checked := ShowAllButtons;
         xoSortedTaggedList.Checked := SortedTaggedList;
         xoRememberDirs.Checked:=RememberDirs;
         end;
      with log do begin
         xoCreateLog.Checked:=Create;
         LogPanel.Visible:=xoCreateLog.Checked;
         xoLogAppend.Checked:=Append;
         xoLogEdit.Checked:=Edit;
         xoLogModified.Checked:=Modified;
         xoLogUntouched.Checked:=Untouched;
         xoLogFileSize.Checked:=FileSize;
         xoLogDirectories.Checked:=Directories;
         xoLogPaths.Checked:=not xoLogDirectories.Checked;
         xoLogHeader.Checked:=Header;
         xoLogTimings.Checked:=Timings;
         xoLogFileName.Text:=LogFile;
         xoLogEverything.Checked:=Everything;
         xoLogInterface.Checked:=Rare;
         xoLogDropDetail.Checked:=DropDetail;
         {$ifdef Registered}
         xoLogBatch.Checked:=Batch;
         xoLogShed.Checked:=Shed;
         xoLogMacroDetail.Checked:=MacroDetail;
         {$endif}
         end;
      end;
      UpdateDependencies;
   except
      xRepl32.MyExceptionHandler(Xoptions);
   end;
   end;

class procedure TXOptions.UpdateRegistry;
begin
   with XReplaceOptions do begin
   try
   //--------------------------------------------------------------------------------------------
   // replacements
   //--------------------------------------------------------------------------------------------
   SetReg('replacements', 'always create backups', repl.AlwaysCreateBackups);
   SetReg('replacements', 'create backups', repl.CreateBackups);
   SetReg('replacements', 'attribute care', repl.FileAttributeCare);
   SetReg('replacements', 'backup extension', repl.BackupExt);
   SetReg('replacements', 'backup location', repl.BackupLoc);
   SetReg('replacements', 'overwrite backups', repl.OverwriteBackups);
   SetReg('replacements', 'case sensitive', repl.CaseSensitive);
   SetReg('replacements', 'assume regexp', repl.RegExp);
   SetReg('replacements', 'include source', repl.IncludeSource);
   SetReg('replacements', 'warn if binary', repl.WarnIfBinary);
   SetReg('replacements', 'whole words only', repl.WholeWordsOnly);
   SetReg('replacements', 'replace prompt', repl.PromptOnReplace);
   {$ifdef Registered}
   SetReg('replacements', 'preserve date time', repl.PreserveDateTime);
   SetReg('replacements', 'unattended errors', repl.NoErrors);
   SetReg('replacements', 'copy redirected', repl.CopyRedirect);
   //SetReg('replacements', 'target copies', repl.TargetCopies);
   {$endif}
   //--------------------------------------------------------------------------------------------
   // general
   //--------------------------------------------------------------------------------------------
   SetReg('general', 'filter', xRepl32.FilterComboBox1.Filter);
   SetReg('general', 'default viewer only', gen.DefaultViewerOnly);
   SetReg('general', 'show glyphs', gen.ShowFileGlyphs);
   SetReg('general', 'show tagged glyphs', gen.ShowTaggedFileGlyphs);
   {$ifDef Registered}
   SetReg('general', 'autoload activexr', gen.SAutoLoad);
   SetReg('general', 'activate empty activexr', gen.SEmptyActivate);
   SetReg('general', 'show intro', gen.ShowIntro);
   {$endif}
   SetReg('general', 'last directory', gen.SaveExitDirectory);
   SetReg('general', 'permanent response', gen.PermanentResponse);
   SetReg('general', 'parallel drag drop', gen.ParallelDragDrop);
   SetReg('general', 'prompt on quit', gen.PromptGrid);
   SetReg('general', 'shift out', gen.ShiftOut);
   SetReg('general', 'show all buttons', Gen.ShowAllButtons);
   SetReg('general', 'sorted tagged list', gen.SortedTaggedList);
   SetReg('general', 'remember dirs', gen.RememberDirs);
   //--------------------------------------------------------------------------------------------
   // hidden
   //--------------------------------------------------------------------------------------------
   SetReg('hidden', 'viewer directory', hidden.ViewerDirectory);
   SetReg('hidden', 'viewer', hidden.Viewer);
   SetReg('hidden', 'width', XRepl32.Width);
   SetReg('hidden', 'height', XRepl32.Height);
   SetReg('hidden', 'left', XRepl32.Left);
   SetReg('hidden', 'top', XRepl32.Top);
   SetReg('hidden', 'intermediate', xRepl32.XPanel.Height);
   SetReg('hidden', 'window state', Ord(xRepl32.WindowState));
   SetReg('hidden', 'startup directory', {xRepl32.DirectoryListBox1.Directory}xRepl32.ShellSpace.Directory);
   SetReg('hidden', 'dir width', XRepl32.ShellSpace.Width);
   SetReg('hidden', 'fil width', XRepl32.DPanel.Width);
   // for directory reload maintaince
   SetReg('hidden', 'redirect directory', hidden.RedirectDirectory);
   SetReg('hidden', 'shedule directory', hidden.SheduleDirectory);
   SetReg('hidden', 'macro directory', hidden.MacroDirectory);
   SetReg('hidden', 'container directory', hidden.ContainerDirectory);
   SetReg('hidden', 'tree directory', hidden.TreeDirectory);
   //--------------------------------------------------------------------------------------------
   // log
   //--------------------------------------------------------------------------------------------
   SetReg('log', 'create', log.create);
   SetReg('log', 'append', log.append);
   SetReg('log', 'edit', log.edit);
   SetReg('log', 'modified', log.modified);
   SetReg('log', 'untouched', log.untouched);
   SetReg('log', 'file size', log.filesize);
   SetReg('log', 'directories', log.directories);
   SetReg('log', 'header', log.header);
   SetReg('log', 'timings', log.timings);
   SetReg('log', 'log file', log.LogFile);
   SetReg('log', 'everything', log.everything);
   SetReg('log', 'interface', log.rare);
   {$ifdef Registered}
   SetReg('log', 'shed', log.shed);
   SetReg('log', 'batch', log.batch);
   SetReg('log', 'macro detail', log.macrodetail);
   {$endif}
   SetReg('log', 'drop detail', log.dropdetail);
   except
   end;
   end;
   end;


procedure TXOptions.ChangeExtClick(Sender: TObject);
var
  NewExtension: string;
  ClickedOK: Boolean;
  ValidExtension: boolean;
  i: LongInt;
begin
   ValidExtension:=False;
   NewExtension := '.'+xReplaceOptions.Repl.BackupExt;
   while not ValidExtension do begin
      ClickedOK := InputQuery(XRVersion, 'Please enter a new backup extension:', NewExtension);
      if ClickedOK then begin
         NewExtension:=Trim(NewExtension);
         if (Length(NewExtension)>0) then begin
            while NewExtension[1]='.' do begin
               Delete(NewExtension,1,1);
               if Length(NewExtension)<=0 then break;
               end;
            if Length(NewExtension)>0 then begin
               ValidExtension:=True;
               for i:=1 to Length(NewExtension) do if (Ord(NewExtension[i])<32) or (NewExtension[i] in ['*','?']) then ValidExtension:=False;
               end;
            end;
         end else break;
      if not ValidExtension then begin
         initMdlg;
         if MsgForm.MessageDlg('You must enter a valid extension!','You have entered an unusable extension, try .XRP for example.',mtWarning,[mbOk]+[mbCancel],0,'')=mrCancel then break;
         end;
      end;
      if ValidExtension then begin
         XReplaceOptions.Repl.BackupExt:=NewExtension;
         xoBackExt.Text:='.'+XReplaceOptions.Repl.BackupExt;
         end;
      end;

procedure TXOptions.xoGetFileClick(Sender: TObject);
begin
   try
   with XRepl32 do begin
   FileViewer.InitialDir:=XReplaceOptions.Hidden.ViewerDirectory;
   FileViewer.fileName:=XReplaceOptions.Hidden.Viewer;
   if FileViewer.Execute then begin
      XReplaceOptions.Hidden.Viewer:=ExtractFileName(FileViewer.FileName);
      XReplaceOptions.Hidden.ViewerDirectory:=ExtractFileDir(FileViewer.FileName);
      end;                                                                       {$IFDEF Debug}DebugForm.DebugDouble('TxRepl32::Viewer::from '+Sender.ClassName+'::succeeded.');{$ENDIF}
   with XReplaceOptions do begin
      if Hidden.ViewerDirectory[Length(Hidden.ViewerDirectory)]='\' then
         Delete(Hidden.ViewerDirectory, Length(Hidden.ViewerDirectory),1);
         xoViewer.Text:=Hidden.ViewerDirectory+'\'+Hidden.Viewer;
      end;
   end;
   except
      xRepl32.MyExceptionHandler(Sender);
   end;
   end;

procedure TXOptions.CancelButtonClick(Sender: TObject);
begin
   XReplaceOptions:=XOldOptions;
   end;

procedure TXOptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose:=False;
   if modalresult=mrCancel then CancelButtonClick(Sender);
   CanClose:=True;
   end;

procedure TXOptions.HelpCommandClick(Sender: TObject);
begin
   xRepl32.ShowHelp('options.html');
   end;

procedure TXOptions.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=112 then HelpCommandClick(SendeR);
   end;

procedure TXOptions.SpeedButton1Click(Sender: TObject);
begin
   with XRepl32 do begin
      SaveLog.FileName:=xoLogFileName.Text;
      if SaveLog.Execute=False then exit;
      If SaveLog.Filename='' then exit;
      xoLogFileName.Text:=SaveLog.FileName;
      end;
   end;

procedure TXOptions.xoLogDirectoriesClick(Sender: TObject);
begin
   if  xoLogPaths.Visible then
      xoLogPaths.Checked:=not xoLogDirectories.Checked else
      xoLogDirectories.Checked:=True;
   end;

procedure TXOptions.xoLogPathsClick(Sender: TObject);
begin
   xoLogDirectories.Checked:=not xoLogPaths.Checked;
   end;

procedure TXOptions.xoCreateLogClick(Sender: TObject);
begin
   LogPanel.Visible:=xoCreateLog.Checked;
   end;

procedure TXOptions.xoLogModifiedClick(Sender: TObject);
begin
   UpdateDependencies;
   end;

procedure TXOptions.UpdateDependencies;
begin
   {$ifdef Registered}
   if xoRegExp.Checked then begin
      xoCaseSensitive.Visible := False;
      xoWholeWordsOnly.Visible := False;
      xoIncludeSource.Visible := False;
      end else begin
   {$endif}
      xoCaseSensitive.Visible := True;
      xoWholeWordsOnly.Visible := True;
      xoIncludeSource.Visible := True;
   {$ifdef Registered}
      end;
   {$endif}
   if (not xoLogModified.Checked) and (not xoLogUntouched.Checked) then begin
      xoLogFileSize.Visible:=False;
      xoLogPaths.Visible:=False;
      xoLogDirectories.Checked:=True;
      xoLogPaths.Checked:=False;
      end else begin
      xoLogFileSize.Visible:=True;
      xoLogPaths.Visible:=True;
      end;
   if (xoRememberDirs.Checked) then begin
      xoSaveCurrentDir.Visible:=False;
      end else begin
      xoSaveCurrentDir.Visible:=True;
      end;
   end;

procedure TXOptions.xoLogUntouchedClick(Sender: TObject);
begin
   UpdateDependencies;
   end;

procedure TXOptions.ResetDefaults(Page: TTabSheet);
begin
   if Page = xpBackups then begin
      xoBackExt.Text:='.XRP';
      xoBackLoc.Text:=XOLocalBackup;
      xoOverwriteBack.Checked:=True;
      xoAlwaysCreateBackups.Checked:=False;
      xoCreateBackups.Visible:=True;
      end else
   if Page = xpReplacements then begin
      xoAttributeCare.Checked:=False;
      xoWarnBinary.Checked:=False;
      xoIncludeSource.Checked:=False;
      xoCaseSensitive.Checked:=False;
      xoRegExp.Checked := False;
      xoPromptReplace.Checked:=False;
      xoWholeWordsOnly.Checked:=False;
      xoCreateBackups.Checked:=True;
      {$ifdef Registered}
      xoPreserveDateTime.Checked := False;
      xoNoErrors.Checked:=False;
      xoCopyRedirect.Checked:=False;
      //xoTargetCopies.Caption:='1';
      {$endif}
      end else
   if Page = xpInterface then begin
      xoShowFileGlyphs.Checked:=True;
      xoShowTaggedGlyphs.Checked:=True;
      {$ifDef Registered}
      xoSAutoLoad.Checked:=False;
      xoEmptyActivate.Checked:=True;
      xoShowIntro.Checked := True;
      {$endif}
      xoDefViewer.Checked:=False;
      xoSaveCurrentDir.Checked:=False;
      xoViewer.Text:=WinDir+'\NOTEPAD.EXE';
      xoPermanentResponse.Checked:=False;
      xoParallelDrop.Checked := False;
      xoPromptGrid.Checked := True;
      xoShiftOut.Checked := False;
      xoShowAllButtons.Checked := False;
      xoSortedTaggedList.Checked := False;
      xoRememberDirs.Checked:=True;
      end else
   if Page = xpLog then begin
      xoCreateLog.Checked:=False;
      LogPanel.Visible:=xoCreateLog.Checked;
      xoLogAppend.Checked:=True;
      xoLogEdit.Checked:=False;
      xoLogModified.Checked:=True;
      xoLogUntouched.Checked:=True;
      xoLogFileSize.Checked:=True;
      xoLogDirectories.Checked:=True;
      xoLogPaths.Checked:=False;
      xoLogHeader.Checked:=True;
      xoLogTimings.Checked:=True;
      xoLogFileName.Text:='xreplace.log';
      xoLogEverything.Checked:=True;
      xoLogInterface.Checked:=False;
      xoLogDropDetail.Checked:=False;
      {$ifdef Registered}
      xoLogBatch.Checked:=True;
      xoLogShed.Checked:=True;
      xoLogMacroDetail.Checked:=True;
      {$endif}
      end;
   end;

procedure TXOptions.DefCurrentPageClick(Sender: TObject);
begin
   ResetDefaults(xpReplacements);
   ResetDefaults(xpBackups);
   ResetDefaults(xpInterface);
   ResetDefaults(xpLog);
   end;

procedure TXOptions.SpeedButton2Click(Sender: TObject);
begin
   ResetDefaults(xpOptions.ActivePage);
   end;

procedure TXOptions.xoAlwaysCreateBackupsClick(Sender: TObject);
begin
   xoCreateBackups.Visible := not xoAlwaysCreateBackups.Checked;
   end;

procedure TXOptions.OkButtonClick(Sender: TObject);
var
   LogFileDirectory : string;
begin
   if xoCreateLog.Checked then begin
     LogFileDirectory:=ExtractFilePath(xoLogFileName.Text);
     if LogFileDirectory = '' then LogFileDirectory:=xRepl32.ShellSpace.Directory;//xRepl32.DirectoryListBox1.Directory;
     if LogFileDirectory[Length(LogFileDirectory)]='\' then
        Delete(LogFileDirectory, Length(LogfileDirectory), 1);
     xoLogFileName.Text:=ExpandFileName(LogFileDirectory+'\'+ExtractFileName(xoLogFileName.Text));
     end;
   UpdateOptions;
   XRepl32.ReplaceLog.Init(XReplaceOptions.Log);
   end;

procedure TXOptions.xoRegisterClick(Sender: TObject);
begin
   try
   xRepl32.Register1.Click;
   except
   end;
   end;

procedure TXOptions.FormCreate(Sender: TObject);
begin
   try
   MinWidth := Self.Width;
   MinHeight := Self.Height;
   xoBackLoc.Text:=XOLocalBackup;
   {$ifndef Registered}
   xoRegExp.Checked := False;
   xoRegExp.Enabled := False;
   xoShowIntro.Enabled := False;
   xoPreserveDateTime.Enabled := False;
   xoCopyRedirect.Enabled:=False;
   xoNoErrors.Enabled:=False;
   xoEmptyActivate.Enabled:=False;
   xoSAutoLoad.Enabled:=False;
   xoLogMacroDetail.Enabled:=False;
   xoLogBatch.Enabled:=False;
   xoLogShed.Enabled:=False;
   changeBackupLocation.Enabled := False;
   clearBackupLocation.Enabled := False;
   //xoTargetCopies.Enabled:=False;
   xoTCDec.Enabled:=False;
   xoTCInc.Enabled:=False;
   {$endif}
   XPOptions.ActivePage:=xpReplacements;
   XOptions.ClientHeight:=OkButton.Height + OkButton.Top * 2 + xpOptions.Height;
   XOptions.ClientWidth:=OkButton.Left + OkButton.Width + DefCurrentPage.Left;
   except
   end;
   end;

procedure TXOptions.WMNCHitTest(var M: TWMNCHitTest);
begin
   inherited;
   if M.Result = htClient then
      M.Result := htCaption;
   end;

procedure TXOptions.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   try
   if not Self.Visible then exit;

   with M.WindowPos^ do begin

      if cx<=MinWidth then
         cx:=MinWidth;
      if cy<=MinHeight then
         cy:=MinHeight;

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
  except
  end;
  end;


procedure TXOptions.xoRememberDirsClick(Sender: TObject);
begin
     UpdateDependencies;
     end;


procedure TXOptions.xoTCDecClick(Sender: TObject);
begin
     {xoTargetCopies.Caption:=IntToStr(StrToInt(xoTargetCopies.Caption) - 1);
     TargetCopyUpdate;}
     end;

procedure TXOptions.xoTCIncClick(Sender: TObject);
begin
     {xoTargetCopies.Caption:=IntToStr(StrToInt(xoTargetCopies.Caption) + 1);
     TargetCopyUpdate;}
     end;

procedure TXOptions.xoRegExpClick(Sender: TObject);
begin
     UpdateDependencies;
     end;

procedure TXOptions.clearBackupLocationClick(Sender: TObject);
begin
     xoBackLoc.Text := XOLocalBackup;
     XReplaceOptions.Repl.BackupLoc:=xoBackLoc.Text;
     end;

procedure TXOptions.changeBackupLocationClick(Sender: TObject);
begin
     initDirSelect;
     if (CompareText(xoBackLoc.Text,XOLocalBackup) <> 0) and (DirectoryExists(xoBackLoc.Text)) then begin
        DirSelect.SelDir.Directory := xoBackLoc.Text;
        DirSelect.SelEdit.Text := xoBackLoc.Text;
        end else begin
        DirSelect.SelEdit.Text := '';
        end;
     DirSelect.Caption:= 'Backups root';
     if (DirSelect.ShowModal = mrOk) and DirectoryExists(DirSelect.SelDir.Directory) then begin
        xoBackLoc.Text:=DirSelect.SelDir.Directory;
        XReplaceOptions.Repl.BackupLoc:=xoBackLoc.Text;
        end;
     end;


class function TXOptions.QueryRegString(Node, Name : string; RegDefault: string): string;
var
      RegResult: Variant;
begin
   try
      RegResult := QueryReg(
         HKEY_CURRENT_USER,
         PChar(RootQuery + '\' + Node),
         PChar(Name));
      if (VarType(RegResult) <> varString) then begin
         Result := RegDefault;
         end else begin
         if (RegResult = '') or (RegResult = '-1') then
            Result := RegDefault
         else Result := RegResult;
         end;
   except
      Result := RegDefault;
   end;
   end;

class function TXOptions.QueryRegBool(Node, Name : string; RegDefault: boolean): boolean;
var
      RegResult: Variant;
begin
   try
      RegResult := QueryReg(
         HKEY_CURRENT_USER,
         PChar(RootQuery + '\' + Node),
         PChar(Name));
      if (VarType(RegResult) <> varInteger) then begin
         Result := RegDefault;
         end else begin
         if (RegResult = 1) then
            Result := true
         else Result := false;
         end;
   except
      Result := RegDefault;
   end;
   end;

class function TXOptions.QueryRegNumber(Node, Name : string; RegDefault: integer): integer;
var
      RegResult: Variant;
begin
   try
      RegResult := QueryReg(
         HKEY_CURRENT_USER,
         PChar(RootQuery + '\' + Node),
         PChar(Name));
      if (VarType(RegResult) <> varInteger) then begin
         Result := RegDefault;
         end else begin
         Result := RegResult
         end;
   except
      Result := RegDefault;
   end;
   end;

class procedure TXOptions.SetReg(Node, Name: string; RegValue: variant);
begin
   try
   AddReg(
      HKEY_CURRENT_USER,
      RootUpdate + '\' + Node + '\',
      Name,
      RegValue);
   except
   end;
   end;

end.
