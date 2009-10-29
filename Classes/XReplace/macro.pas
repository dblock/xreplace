unit macro;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, ExtCtrls, StdCtrls, Buttons, XReplace, FileCtrl,
  Wait, ShlObj, ShellApi, d32reg, d32gen, d32errors, d32debug, ImgList;

type

  PMacro = ^TMacro;
  TMacro = class
   public
     Contents : string;
     Original : string;
     OrgLen: integer;
     Name: string;
     Node: TTreeNode;
     FileName: string;
     constructor Create;
     destructor Destroy; override;
     end;

  {PArray=^TArray;
  TArray=array[0..MaxInt div 5] of TMacro;}

  TMacroEdit = class(TForm)
    CommandPanel: TPanel;
    MacroMenu: TMainMenu;
    MainMacro: TMenuItem;
    MacroLoad: TMenuItem;
    MacroSave: TMenuItem;
    N1: TMenuItem;
    New1: TMenuItem;
    ImageList1: TImageList;
    MacroOpen: TOpenDialog;
    SaveMacro: TSaveDialog;
    cNewMacro: TSpeedButton;
    cLoadMacro: TSpeedButton;
    cSaveMacro: TSpeedButton;
    cSaveAll: TSpeedButton;
    cCloseAll: TSpeedButton;
    cCloseMacro: TSpeedButton;
    Close1: TMenuItem;
    N2: TMenuItem;
    SaveAll1: TMenuItem;
    CloseAllMacros1: TMenuItem;
    SaveAs: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    N3: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    N4: TMenuItem;
    Close2: TMenuItem;
    MacroEditorClose: TSpeedButton;
    Execute: TMenuItem;
    ExecuteButton: TSpeedButton;
    ErrorPanel: TPanel;
    TopPanel: TPanel;
    MacroTree: TTreeView;
    SizePanel: TPanel;
    Panel1: TPanel;
    MacroStatus: TStatusBar;
    Delete1: TMenuItem;
    MacroDelete: TSpeedButton;
    CompileMacro: TSpeedButton;
    CheckCompile: TMenuItem;
    HelpandAbout1: TMenuItem;
    Help1: TMenuItem;
    N6: TMenuItem;
    AboutXReplace321: TMenuItem;
    MacroMemo: TRichEdit;
    PopupEdit: TPopupMenu;
    Undo: TMenuItem;
    N7: TMenuItem;
    Copy2: TMenuItem;
    Cut2: TMenuItem;
    Paste2: TMenuItem;
    ErrorList: TTreeView;
    SheduleMacros: TSpeedButton;
    ShedActivate: TSpeedButton;
    Run1: TMenuItem;
    N8: TMenuItem;
    Shedule1: TMenuItem;
    MacroShedule1: TMenuItem;
    activateActivXR1: TMenuItem;
    N5: TMenuItem;
    MacroEditorHelp: TSpeedButton;
    MacroMenuPopup: TPopupMenu;
    pmNew: TMenuItem;
    pmClose: TMenuItem;
    pmLoad: TMenuItem;
    pmSaveAs: TMenuItem;
    pmDelete: TMenuItem;
    pmCloseAll: TMenuItem;
    pmSaveAll: TMenuItem;
    pmCloseEditor: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure MacroTreeChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure MacroTreeChange(Sender: TObject; Node: TTreeNode);
    procedure SizePanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure cLoadMacroClick(Sender: TObject);
    procedure MacroMemoChange(Sender: TObject);
    procedure cSaveMacroClick(Sender: TObject);
    procedure cSaveAllClick(Sender: TObject);
    procedure cCloseAllClick(Sender: TObject);
    procedure cCloseMacroClick(Sender: TObject);
    procedure cNewMacroClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Close2Click(Sender: TObject);
    procedure ExecuteButtonClick(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MacroDeleteClick(Sender: TObject);
    procedure CompileMacroClick(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure AboutXReplace321Click(Sender: TObject);
    procedure MacroTreeKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure TopPanelResize(Sender: TObject);
    procedure ErrorListClick(Sender: TObject);
    procedure ErrorListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MacroTreeCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
    procedure ErrorListCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
    procedure ShedActivateClick(Sender: TObject);
    procedure SheduleMacrosClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MacroTreeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MacroTreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MacroTreeDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure MacroTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MacroMenuPopupPopup(Sender: TObject);
  private
    MacroArray: TList;
    MinHeight, MinWidth: integer;
    //mCount: integer;
    //MacroTable : PArray;
    CompileNode: TTreeNode;
    iWaitState: TWorking;
    iWaitRunning: boolean;
    function AddMacro(iName: string): PMacro;
    function NodeMacro(Node: TTreeNode): PMacro;
    procedure PutText(Node: TTreeNode);
    procedure GetText(Node: TTreeNode);
    function LoadMacroText(FileName: string; iMacro: PMacro): boolean;
    procedure SaveMacroText(FileName: string; iMacro: PMacro);
    procedure CloseMacro(Node: TTreeNode);
    procedure UpdateRegistry;
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
    procedure EnableEverything;
    procedure DisableEverything;
    procedure WMDropFiles(var M: TWMDropFiles); message WM_DROPFILES;
    procedure cLoadMacroFile(FileName: string);
    function DestroyDuplicate(iMacro: PMacro): boolean;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure UpdateDependencies;
  public
     procedure AddError(iErr: string);
  end;

  procedure initMacroEdit;

var
  MacroEdit: TMacroEdit = nil;

const
   UnsavedIndex : integer = 2;
   SavedIndex : integer = 1;

implementation

uses MDlg, xshedule, xopt;

procedure initMacroEdit;
begin
     if MacroEdit = nil then begin
        Application.CreateForm(TMacroEdit, MacroEdit);
        end;
     end;

{$R *.DFM}

function TMacroEdit.AddMacro(iName: string): PMacro;
var
   iMacro: PMacro;
   theNode: TTreeNode;
begin
   new(iMacro);
   iMacro^ := TMacro.Create;
   with iMacro^ do begin
        Name := iName;
        OrgLen:=-1;
        end;
   with MacroTree.Items do begin
        theNode:=AddChild(GetFirstNode, iName);
        theNode.StateIndex:=UnsavedIndex;
        iMacro^.Node:=theNode;
        GetFirstNode.Expand(True);
        xRepl32.ReplaceLog.oLog('added macro '+iMacro.Name,'macros',XReplaceOptions.Log.MacroDetail);
        end;
   MacroArray.Add(iMacro);
   Result:=iMacro;                                                               {$IFDEF Debug}DebugForm.Debug('Macro.Added:'+iMacro.Name + '//' + iMacro.FileName);{$ENDIF}
   end;

procedure TMacroEdit.FormCreate(Sender: TObject);
var
   ih, iw: integer;
begin
   MacroArray := TList.Create;
   //mCount := 0;
   iWaitRunning:=False;
   MinWidth := Width;
   MinHeight := Height;
   try ih:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\macros\',
                    'height'); except ih:=0; end;
   try iw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\macros\',
                    'width'); except iw:=0; end;
   if ih > 0 then MacroEdit.Height:=ih;
   if iw > 0 then MacroEdit.Width:=iw;

   try ih:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\macros\',
                    'top'); except ih:=0; end;
   try iw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\macros\',
                    'left'); except iw:=0; end;
   if ih > 0 then MacroEdit.Top:=ih;
   if iw > 0 then MacroEdit.Left:=iw;

   try ih:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\macros\',
                    'tree_width'); except ih:=0; end;
   try iw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\macros\',
                    'error_height'); except iw:=0; end;
   if ih > 0 then MacroTree.Width:=ih;
   if iw > 0 then ErrorPanel.Height:=iw;
   MacroMemo.Enabled:=False;
   DragAcceptFiles(Self.Handle, True);
   {$IFDEF Debug}DebugForm.Debug('TMacroEdit.FormCreate::macro directory candidate: '+ XReplaceOptions.Hidden.MacroDirectory);{$ENDIF}
   if XReplaceOptions.Gen.RememberDirs then
      if DirectoryExists(XReplaceOptions.Hidden.MacroDirectory) then
       if CompareText(Copy(XReplaceOptions.Hidden.MacroDirectory, 1, 2), '\\') <> 0 then
         MacroEdit.MacroOpen.InitialDir:=XReplaceOptions.Hidden.MacroDirectory;
   end;

procedure TMacroEdit.CloseMacro(Node: TTreeNode);
var
   i: integer;
   iRep: integer;
   iMacro: PMacro;
begin
   if (Node = nil) or (Node = MacroTree.Items.GetFirstNode) then exit;
   xRepl32.ReplaceLog.oLog('closing macro '+Node.Text,'macros',XReplaceOptions.Log.MacroDetail);
   if Node.StateIndex = UnsavedIndex then begin
   initMdlg;
   iRep :=(MsgForm.MessageDlg('The macro "'+ Node.Text + '" has been modified. Do you wish to save it?',
                              'You are about to close this macro. It''s contents have been change and answering No will not save those changes.',
                              mtWarning,[mbYes]+[mbNo]+[mbCancel],0,''));
      case iRep of
         mrYes:  begin
                 Node.Selected:=True;
                 cSaveMacro.Click;
                 end;
         mrCancel: exit;
         end;
      end;

   try
   for i:=0 to {mCount} MacroArray.Count - 1 do begin
       if PMacro(MacroArray[i])^.Node = Node then break;
       end;

   MacroTree.Items.Delete(Node);
   iMacro := MacroArray[i];
   MacroArray.Remove(iMacro);
   iMacro^.Destroy;
   except
   end;

   if MacroTree.Items.Count = 1 then begin
      MacroMemo.Text:='';
      MacroMemo.Enabled:=False;
      MacroStatus.SimpleText:='Ready.';
      end else begin
      MacroTree.Selected:=MacroTree.Items.GetFirstNode.GetFirstChild;
      if not iWaitRunning then MacroMemo.Enabled:=True;
      end;
   UpdateDependencies;
   end;

function TMacroEdit.NodeMacro(Node: TTreeNode): PMacro;
var
   i: integer;
begin
     Result:=nil;
     if Node = nil then exit;
     for i:=0 to MacroArray.Count {mCount} - 1 do begin
         if PMacro(MacroArray[i]).Node = Node then begin
         //if MacroTable^[i].Node = Node then begin
            //Result:=MacroTable^[i];
            Result := PMacro(MacroArray[i]);
            exit;
            end;
         end;
     end;

procedure TMacroEdit.GetText(Node: TTreeNode);
var
   iMacro: PMacro;
begin
   iMacro:=NodeMacro(Node);
   if (iMacro<>nil) and (Node <> nil) and (Node <> MacroTree.Items.GetFirstNode) then begin
      iMacro^.Contents := MacroMemo.Text;
      end;
   end;

procedure TMacroEdit.PutText(Node: TTreeNode);
var
   iMacro: PMacro;
begin
     iMacro:=NodeMacro(Node);
     if (iMacro<>nil) and (Node <> MacroTree.Items.GetFirstNode) and (Node <> nil) then begin
          MacroMemo.Text:=Copy(iMacro^.Contents, 1, Length(iMacro^.Contents));
          if not iWaitRunning then MacroMemo.Enabled:=True;
          end else begin
          MacroMemo.Text:='';
          MacroMemo.Enabled:=False;
          end;
     end;

procedure TMacroEdit.MacroTreeChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
begin
   if (MacroTree.Selected <> MacroTree.Items.GetFirstNode) then GetText(MacroTree.Selected);

   if Node = MacroTree.Items.GetFirstNode then begin
      AllowChange:=False;
      end;
   end;

procedure TMacroEdit.MacroTreeChange(Sender: TObject; Node: TTreeNode);
begin
   if MacroTree.Selected <> MacroTree.Items.GetFirstNode then begin
      PutText(Node);
      MacroStatus.SimpleText:=LowerCase(ExtractFileName(Node.Text));
      try MacroTree.SetFocus; except end;
      end else MacroStatus.SimpleText:='Ready.';
   UpdateDependencies;
   end;

procedure TMacroEdit.SizePanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   tW: integer;
begin
   if ssLeft in Shift then begin
      tw:=(X + MacroTree.Width);
      if (tw <> MacroTree.Width) and
         (tw < trunc(MacroEdit.Width * 0.9)) and
         (tw > trunc(MacroEdit.Width * 0.1)) then
          MacroTree.Width:=tw;
      end;
   end;

procedure TMacroEdit.FormResize(Sender: TObject);
begin
   if MacroTree.Width > trunc(MacroEdit.Width * 0.9) then MacroTree.Width:=trunc(MacroEdit.Width * 0.9) else
   if MacroTree.Width < trunc(MacroEdit.Width * 0.1) then MacroTree.Width:=trunc(MacroEdit.Width * 0.1);
   if ErrorPanel.Height > trunc(MacroEdit.ClientHeight * 0.8) then ErrorPanel.Height:=trunc(MacroEdit.ClientHeight * 0.8) else
   if ErrorPanel.Height < trunc(MacroEdit.ClientHeight / 5) then ErrorPanel.Height:=trunc(MacroEdit.ClientHeight / 5);
   end;

function TMacroEdit.LoadMacroText(FileName: string; iMacro: PMacro): boolean;
var
  FN: Textfile;
  tS: string;
  tL: string;
  fSize: LongInt;
  iWaitRunningLocal: boolean;
begin
     DisableEverything;
     if not iWaitRunning then begin
        iWaitState:=TWorking.Create;
        iWaitRunning:=True;
        iWaitRunningLocal:=True;
        end else iWaitRunningLocal:=False;

     if iWaitRunning then try iWaitState.oMessage('Loading '+ ExtractFileName(FileName)); except end;

     try
     if iWaitRunning then try iWaitState.oStatus(0); except end;
     xRepl32.ReplaceLog.oLog('loading macro '+FileName,'macros',XReplaceOptions.Log.MacroDetail);
     if (not FileExists(FileName)) then begin
        {$IFDEF Debug}DebugForm.Debug('Macro.MacroLoad:'+iMacro.FileName+'::failed at FileExists');{$ENDIF}
        xRepl32.ReplaceLog.oLog('unable to load '+FileName+' - file does not exist.','macros',XReplaceOptions.Log.MacroDetail);
        ErrorList.Items.AddChild(ErrorList.Items.GetFirstNode, 'unable to load '+FileName+' - file does not exist.').StateIndex:=UnsavedIndex;
        ErrorList.Items.GetFirstNode.Expand(False);
        Result:=False;
        if iWaitRunningLocal then begin
           iWaitState.Kill;
           iWaitRunning:=False;
           end;
        EnableEverything;
        exit;
        end;
     AssignFile(FN, FileName);
     Reset(FN);
     FSize:=FileSize(FN);
     ts:='';
     while not Eof(FN) do begin
        if (FSize > 0) and (iWaitRunning) then try iWaitState.oStatus(trunc((FilePos(FN) / Fsize) * 100)); except end;
        ReadLn(FN, tL);
        Application.ProcessMessages;
        tS := tS + tL + #13#10;
        end;
     CloseFile(FN);
     except
        {$IFDEF Debug}DebugForm.Debug('Macro.MacroLoad:'+iMacro.FileName+'::failed at ReadReset');{$ENDIF}
        xRepl32.ReplaceLog.oLog('error reading '+FileName,'macros',XReplaceOptions.Log.MacroDetail);
        ErrorList.Items.AddChild(ErrorList.Items.GetFirstNode, 'error reading '+FileName).StateIndex:=UnsavedIndex;
        ErrorList.Items.GetFirstNode.Expand(False);
        if xRepl32.ErrorMessages then begin
           initMdlg;
           MsgForm.MessageDlg('The file "'+ FileName + '" could not be found or error reading file.',
                              'You may choose Ok to continue normal operation of XReplace-32.',
                              mtWarning,[mbOk],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
           end;
     end;

     try
     iMacro.Contents := tS;
     iMacro.Original := tS;
     iMacro.OrgLen:=Length(tS);

     if (MacroTree.Selected <> nil) and
        (MacroTree.Selected <> MacroTree.Items.GetFirstNode) then begin
        GetText(MacroTree.Selected);
        end;

     EnableEverything;

     iMacro.Node.Selected:=True;
     iMacro.Node.StateIndex:=SavedIndex;

     try if not xRepl32.EditText.NTBug then SHAddtoRecentDocs(SHARD_PATH, PChar(FileName)); except end;

     Result:=True;                                                               {$IFDEF Debug}DebugForm.Debug('Macro.MacroLoad:'+iMacro.FileName);{$ENDIF}
     except
        xRepl32.ReplaceLog.oLog('unexpected error loading '+FileName,'macros',XReplaceOptions.Log.MacroDetail);
        ErrorList.Items.AddChild(ErrorList.Items.GetFirstNode, 'unexpected error loading '+FileName).StateIndex:=UnsavedIndex;
        ErrorList.Items.GetFirstNode.Expand(False);
        xRepl32.MyExceptionHandler(MacroEdit);
        Result:=False;
        EnableEverything;
     end;

     if iWaitRunningLocal then begin
           iWaitState.Kill;
           iWaitRunning:=False;
           end;
     end;

procedure TMacroEdit.SaveMacroText(FileName: string; iMacro: PMacro);
var
  FN: Textfile;
begin
     try
     xRepl32.ReplaceLog.oLog('saving macro '+FileName,'macros',XReplaceOptions.Log.MacroDetail);
     if FileName = '' then begin
        SaveMacro.Title:='Save "'+ExtractFileName(iMacro.Name)+'" as';
        if not SaveMacro.Execute then exit;
        FileName:=ExpandFileName(SaveMacro.FileName);
        XReplaceOptions.Hidden.MacroDirectory:=ExtractFilePath(FileName);
        iMacro.Name := FileName;
        iMacro.FileName := FileName;
        iMAcro.Node.Text:=FileName;
        end;
     DisableEverything;
     AssignFile(FN, FileName);
     Rewrite(FN);
     Write(FN, iMacro.Contents);
     CloseFile(FN);
     EnableEverything;
     iMacro.Original := iMacro.Contents;
     iMacro.OrgLen:=Length(iMacro.Original);
     MacroMemoChange(nil);
     except
        EnableEverything;
        xRepl32.ReplaceLog.oLog('unexpected error saving '+FileName,'macros',XReplaceOptions.Log.MacroDetail);
        ErrorList.Items.AddChild(ErrorList.Items.GetFirstNode, 'unexpected error saving '+FileName).StateIndex:=UnsavedIndex;
        ErrorList.Items.GetFirstNode.Expand(False);
        xRepl32.MyExceptionHandler(MacroEdit);
     end;
     end;

procedure TMacroEdit.cLoadMacroFile(FileName: string);
var
   iMacro: PMacro;
begin
      iWaitState:=TWorking.Create;
      iWaitRunning:=True;
      MacroOpen.InitialDir:=ExtractFilePath(FileName);
      XReplaceOptions.Hidden.MacroDirectory:=ExtractFilePath(FileName);
      iMacro:=AddMacro('New Macro '+IntToStr(MacroArray.Count+1));
      iMacro.FileName := ExpandFileName(FileName);
      iMacro.Name := iMacro.FileName;
      iMacro.Node.Text:=iMacro.Name;
      if not DestroyDuplicate(iMacro) then LoadMacroText(iMacro.FileName, iMacro);
      iWaitState.Kill;
     end;

procedure TMacroEdit.cLoadMacroClick(Sender: TObject);
begin
   if MacroOpen.Execute then begin
      cLoadMacroFile(MacroOpen.FileName);
      end;
   end;

procedure TMacroEdit.MacroMemoChange(Sender: TObject);
var
   iMacro: PMacro;
begin
   try
   iMacro:=NodeMacro(MacroTree.Selected);
   if iMacro <> nil then begin
      if Length(MacroMemo.Text) = iMacro.OrgLen then
         //if iMacro.Orginal <> '' then
            if MacroMemo.Text = iMacro.Original then begin
               iMacro.Node.StateIndex:=SavedIndex;
               exit;
               end;
      iMacro.Node.StateIndex:=UnsavedIndex;
      end;
   except
   end;
   end;

procedure TMacroEdit.cSaveMacroClick(Sender: TObject);
var
   iMacro: PMacro;
begin
   GetText(MacroTree.Selected);
   iMacro:=NodeMacro(MacroTree.Selected);
   if (MacroTree.Selected <> MacroTree.Items.GetFirstNode) and
      (MacroTree.Selected <> nil) then begin
      SaveMacro.FileName:=iMacro.FileName;
      SaveMacroText(iMacro.FileName, iMacro);
      end;
   end;

procedure TMacroEdit.cSaveAllClick(Sender: TObject);
var
   iNode: TTreeNode;
begin
   iNode:=MacroTree.Items.GetFirstNode.GetFirstChild;
   while iNode <> nil do begin
         iNode.Selected:=True;
         cSaveMacro.Click;
         iNode:=iNode.GetNextSibling;
         end;
   end;

procedure TMacroEdit.cCloseAllClick(Sender: TObject);
var
   iNode, tNode: TTreeNode;
begin
   try
   iNode:=MacroTree.Items.GetFirstNode.GetFirstChild;
   while iNode <> nil do begin
         tNode:=iNode;
         iNode:=iNode.GetNextSibling;
         CloseMacro(tNode);
         end;
   except
   end;
   end;

procedure TMacroEdit.cCloseMacroClick(Sender: TObject);
begin
   if MacroTree.Selected <> MacroTree.Items.GetFirstNode then begin
      CloseMacro(MacroTree.Selected);
      end;
   end;

procedure TMacroEdit.cNewMacroClick(Sender: TObject);
begin
   AddMacro('New Macro '+IntToStr(MacroArray.Count+1)).Node.Selected:=True;
   try MacroTree.SetFocus; except end;
   end;

procedure TMacroEdit.SaveAsClick(Sender: TObject);
var
   iMacro: PMacro;
begin
   GetText(MacroTree.Selected);
   iMacro:=NodeMacro(MacroTree.Selected);
   if (MacroTree.Selected <> MacroTree.Items.GetFirstNode) and
      (MacroTree.Selected <> nil) then begin
      SaveMacro.FileName:=iMacro.FileName;
      SaveMacroText('', iMacro);
      end;
   end;

procedure TMacroEdit.Undo1Click(Sender: TObject);
begin
  with MacroMemo do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
    end;

procedure TMacroEdit.Cut1Click(Sender: TObject);
begin
     MacroMemo.CutToClipboard;
     end;

procedure TMacroEdit.Copy1Click(Sender: TObject);
begin
     MacroMemo.CopyToClipboard;
     end;

procedure TMacroEdit.Paste1Click(Sender: TObject);
begin
     MacroMemo.PasteFromClipboard;
     end;

procedure TMacroEdit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   UpdateRegistry;
   cCloseAllClick(Sender);
   if MacroTree.Items.Count > 1 then CanClose:=False else CanClose:=True;
   end;

procedure TMacroEdit.UpdateRegistry;
var
   iFiles: string;
   iFileName: string;
   i: integer;
begin
   iFiles := '';
   for i:=0 to MacroArray.Count - 1 do begin
       iFileName := PMacro(MacroArray[i])^.FileName;
       if iFileName <> '' then iFiles := iFiles + iFileName + '*';
       end;

   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\macros\',
                               'recent files',
                               iFiles);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\macros\',
                               'height',
                               MacroEdit.Height);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\macros\',
                               'width',
                               MacroEdit.Width);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\macros\',
                               'top',
                               MacroEdit.Top);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\macros\',
                               'left',
                               MacroEdit.Left);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\macros\',
                               'tree_width',
                               MacroTree.Width);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\macros\',
                               'error_height',
                               ErrorPanel.Height);
   end;

function TMacroEdit.DestroyDuplicate(iMacro: PMacro): boolean;
var
   j: integer;
begin
      for j:=0 to MacroTree.Items.Count - 1 do begin
          if (CompareText(MacroTree.Items[j].Text, iMacro.Name) = 0) and
             (iMacro.Node <> MacroTree.Items[j]) then begin
                  MacroTree.Items.Delete(iMacro.Node);
                  MacroArray.Remove(iMacro);
                  iMacro.Destroy;
                  Result:=True;
                  exit;
                  end;
          end;
      Result:=False;
     end;

procedure TMacroEdit.FormShow(Sender: TObject);
var
   iFiles: string;
   i: integer;
   iMacro: PMacro;
begin
   iWaitState:=TWorking.Create;
   iWaitRunning:=True;
   try
   iFiles := QueryReg(HKEY_CURRENT_USER,   RootQuery+'\macros\','recent files');
   i:=Pos('*', iFiles);
   while (i<>0) do begin
      iMacro:=AddMacro('New Macro '+IntToStr(MacroArray.Count+1));
      iMacro^.FileName := Copy(iFiles, 1, i - 1);
      Delete(iFiles, 1, i);
      iMacro^.Name := iMacro^.FileName;
      iMacro.Node.Text:=iMacro.Name;
      if DestroyDuplicate(iMacro) then begin
         iWaitState.Kill;
         end else begin
         LoadMacroText(iMacro.FileName, iMacro);
         end;
      i:=Pos('*', iFiles);
      end;
   except
      xRepl32.MyExceptionHandler(MacroEdit);
   end;
     if iWaitRunning then iWaitState.Kill;
     iWaitRunning:=False;
     UpdateDependencies;
   end;

procedure TMacroEdit.Close2Click(Sender: TObject);
begin
   MacroEdit.Close;
   end;

procedure TMacroEdit.ExecuteButtonClick(Sender: TObject);
var
   iMacro: PMacro;
begin
   //ErrorList.Items.Clear;
   try
   try MacroTree.SetFocus; except end;
   iMacro:=NodeMacro(MacroTree.Selected);
   if iMacro = nil then exit;
   cSaveMacro.Click;
   if iMacro.Node.StateIndex = UnsavedIndex then exit;
   xRepl32.ReplaceLog.oLog('executing '+iMacro.FileName,'macros',XReplaceOptions.Log.MacroDetail);
   CompileNode:=ErrorList.Items.AddChild(ErrorList.Items.GetFirstNode, 'executing '+iMacro.FileName);
   xRepl32.MacroExecute(iMacro.FileName, True);
   xRepl32.MacroLine:=-1;
   if CompileNode.Count = 0 then begin
      CompileNode.StateIndex:=SavedIndex;
      AddError('successfully executed '+iMacro.FileName+', no errors found');
      end else begin
      CompileNode.StateIndex:=UnSavedIndex;
      AddError('macro '+iMacro.FileName+', executed with '+IntToStr(CompileNode.Count)+' error(s)');
      end;
   ErrorList.Items.GetFirstNode.Expand(False);
   CompileNode.Expand(True);
   except
      xRepl32.MyExceptionHandler(MacroEdit);
   end;
   if (xRepl32.mustTerminate) then xRepl32.TerminateXReplace(True);
   end;

procedure TMacroEdit.Panel1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   th: integer;
begin
   try
   if ssLeft in Shift then begin
      th:=(Panel1.Height - Y) + ErrorPanel.Height;
      if (th <> MacroEdit.Height) and
         (th < trunc(MacroEdit.ClientHeight * 0.8)) and
         (th > trunc(MacroEdit.ClientHeight / 5)) then
          ErrorPanel.Height:=th;
      end;
   except
   end;
   end;

procedure TMacroEdit.MacroDeleteClick(Sender: TObject);
var
   iMacro: PMacro;
begin
   try
   try MacroTree.SetFocus; except end;
   iMacro:=NodeMacro(MacroTree.Selected);
   if iMacro <> nil then begin
   initMdlg;
   if (MsgForm.MessageDlg('Are you sure you wish to delete "'+ MacroTree.Selected.Text + '"?',
                              'You are about to delete this macro. It''s file and contents will be destroyed without any recovery possibility.',
                              mtWarning,[mbYes]+[mbNo],0,'') = mrNo) then exit;

   iMacro.Node.StateIndex:=SavedIndex;
   if (iMacro.FileName <> '') and (FileExists(iMacro.FileName)) then if not DeleteFile(iMacro.FileName) then begin
      xRepl32.ReplaceLog.oLog('unexpected error deleting '+MacroTree.Selected.Text,'macros',XReplaceOptions.Log.MacroDetail);
      ErrorList.Items.AddChild(ErrorList.Items.GetFirstNode, 'unexpected error deleting '+MacroTree.Selected.Text).StateIndex:=UnsavedIndex;
      ErrorList.Items.GetFirstNode.Expand(False);
      initMdlg;
      MsgForm.MessageDlg('Error deleting "'+ MacroTree.Selected.Text + '"?',
                         'You may choose cancel to continue normal execution of XReplace-32',
                              mtError,[mbCancel],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
      exit;
      end;
   CloseMacro(iMacro.Node);
   end;
   except
      xRepl32.MyExceptionHandler(MacroEdit);
   end;
   end;

procedure TMacroEdit.CompileMacroClick(Sender: TObject);
var
   iMacro: PMacro;
begin
   try
   try MacroTree.SetFocus; except end;
   iMacro:=NodeMacro(MacroTree.Selected);
   if iMacro = nil then exit;
   cSaveMacro.Click;
   if iMacro.Node.StateIndex = UnsavedIndex then exit;
   //ErrorList.Clear;

   xRepl32.ReplaceLog.oLog('compiling '+iMacro.FileName,'macros',XReplaceOptions.Log.MacroDetail);
   CompileNode:=ErrorList.Items.AddChild(ErrorList.Items.GetFirstNode, 'compiling '+iMacro.FileName);
   xRepl32.MacroExecute(iMacro.FileName, False);
   xRepl32.MacroLine:=-1;
   if CompileNode.Count = 0 then begin
      CompileNode.StateIndex:=SavedIndex;
      AddError('successfully checked, no errors found');
      end else begin
      CompileNode.StateIndex:=UnSavedIndex;
      AddError('macro checked, '+IntToStr(CompileNode.Count)+' error(s) found');
      end;
   ErrorList.Items.GetFirstNode.Expand(False);
   CompileNode.Expand(True);
   except
      xRepl32.MyExceptionHandler(MacroEdit);
   end;
   end;

procedure TMacroEdit.AddError(iErr: string);
var
   LineText: string;
begin
     try
     if xRepl32.MacroLine > 0 then begin
        LineText:='(line '+IntToStr(xRepl32.MacroLine)+'):';
        //RichEdit1.SelAttributes.Size
        end else LineText:='';
     ErrorList.Items.AddChild(CompileNode, LineText+iErr);
     xRepl32.ReplaceLog.oLog(LineText + iErr,'macros',XReplaceOptions.Log.MacroDetail);
     except
        xRepl32.MyExceptionHandler(MacroEdit);
     end;
     end;

procedure TMacroEdit.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   try
   inherited;
   with M.WindowPos^ do begin
      if (cx < MinWidth) then cx := MinWidth;
      if (cy < MinHeight) then cy := MinHeight;
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


procedure TMacroEdit.Help1Click(Sender: TObject);
begin
     xRepl32.ShowHelp('macros.html');
     end;

procedure TMacroEdit.AboutXReplace321Click(Sender: TObject);
begin
     xRepl32.AboutXReplace321.Click;
     end;

procedure TMacroEdit.MacroTreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = 46 then MacroDelete.Click;
   end;

procedure TMacroEdit.TopPanelResize(Sender: TObject);
begin
   MacroMemo.Refresh;
   end;

procedure TMacroEdit.ErrorListClick(Sender: TObject);
begin
     //---
     end;

procedure TMacroEdit.ErrorListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
     try
     if (key = 46) and (ErrorList.Selected <> ErrorList.Items.GetFirstNode) then ErrorList.Selected.Destroy;
     except
        xRepl32.MyExceptionHandler(MacroEdit);
     end;
     end;

procedure TMacroEdit.MacroTreeCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
begin
     if Node = MacroTree.Items.GetFirstNode then AllowCollapse:=False;
     end;

procedure TMacroEdit.ErrorListCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
begin
     if Node = ErrorList.Items.GetFirstNode then AllowCollapse:=False;
     end;

procedure TMacroEdit.ShedActivateClick(Sender: TObject);
begin
   self.Hide;
   xRepl32.ShedActivate.Click;
   end;

procedure TMacroEdit.SheduleMacrosClick(Sender: TObject);
begin
   initXFShedule;
   xFShedule.Show;
   end;

procedure TMacroEdit.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=27 then begin
      Close2.Click;
      end else
   if Key=112 then begin
      Help1.Click;
      end;
end;

procedure TMacroEdit.MacroTreeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   iNode: TTreeNode;
begin
     if (Button = mbRight) and (not (ssShift in Shift)) and (not (ssAlt in Shift)) and (not (ssCtrl in Shift)) then begin
        iNode:=MacroTree.GetNodeAt(X, Y);
        if (iNode<>nil) and (iNode <> MAcroTree.Items.GetFirstNode) then iNode.Selected:=True;
        end;
     end;

procedure TMacroEdit.EnableEverything;
begin
     CommandPanel.Enabled:=True;
     MacroMemo.Enabled:=True;
     MacroTree.Enabled:=True;
     end;

procedure TMacroEdit.DisableEverything;
begin
     CommandPanel.Enabled:=False;
     MacroMemo.Enabled:=False;
     MacroTree.Enabled:=False;
     end;

procedure TMacroEdit.MacroTreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     if Button = mbLeft then
     with Sender as TTreeView do begin          if Selected <> nil then BeginDrag(True);          end;     end;

procedure TMacroEdit.WMDropFiles(var M: TWMDropFiles);
var
   i: integer;
   tStr: PChar;
begin
     tStr := AllocMem(MAX_PATH);
     with M do
     for i:=DragQueryFile(Drop, $FFFFFFFF, Nil, 0) - 1 downto 0 do begin
         DragQueryFile(Drop, i, tStr, 255);         if FileExists(tStr) then cLoadMacroFile(tStr);         end;     end;

procedure TMacroEdit.MacroTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
     if ((Source is TFileListBox) or (Source is TTreeView)) and (Source <> MacroTree) then Accept:=True else Accept := False;
     end;

procedure TMacroEdit.WMSysCommand(var Msg: TWMSysCommand);
begin
   if Msg.CmdType=SC_MINIMIZE then begin
      Self.Hide;
      end else inherited;
   end;


procedure TMacroEdit.MacroTreeDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
   try
   if Source is TFileListBox then cLoadMacroFile(ExpandFileName((Source as TFileListBox).Directory + '\' + (Source as TFileListBox).Items[(Source as TFileListBox).ItemIndex]))
   else if (Source is TTreeView) and (Source <> MacroTree) then if FileExists((Source as TTreeView).Selected.Text) then cLoadMacroFile(ExpandFileName((Source as TTreeView).Selected.Text));
   except
   end;
   end;

constructor TMacro.Create;
begin
     Contents:='';
     Original:='';
     OrgLen:=0;
     Name:='';
     FileName:='';
     end;

destructor TMacro.Destroy;
begin
     //---
     inherited;
     end;

procedure TMacroEdit.UpdateDependencies;
begin
     cSaveMacro.Enabled :=
      (MacroTree.Selected <> MacroTree.Items.GetFirstNode) and
      (MacroTree.Selected <> nil);
     cCloseMacro.Enabled := cSaveMacro.Enabled;
     MacroDelete.Enabled := cSaveMacro.Enabled;

     cSaveAll.Enabled := (MacroTree.Items.GetFirstNode.Count > 0);
     cCloseAll.Enabled := cSaveAll.Enabled;


     ExecuteButton.Enabled := cSaveMacro.Enabled;
     CompileMacro.Enabled := cSaveMacro.Enabled;

     New1.Enabled := cNewMacro.Enabled;
     Close1.Enabled := cCloseMacro.Enabled;
     MacroLoad.Enabled := cLoadMacro.Enabled;
     MacroSave.Enabled := cSaveMacro.Enabled;
     SaveAs.Enabled := cSaveMacro.Enabled;
     Delete1.Enabled := MacroDelete.Enabled;
     CloseAllMAcros1.Enabled := cCloseAll.Enabled;
     SaveAll1.Enabled := cSaveAll.Enabled;
     Run1.Enabled := ExecuteButton.Enabled;
     Edit1.Enabled := cCloseMacro.Enabled;
     end;


procedure TMacroEdit.MacroMenuPopupPopup(Sender: TObject);
begin
     pmNew.Enabled := cNewMacro.Enabled;
     pmClose.Enabled := cCloseMacro.Enabled;
     pmLoad.Enabled := cLoadMacro.Enabled;
     pmSaveAs.Enabled := cSaveMacro.Enabled;
     pmDelete.Enabled := MacroDelete.Enabled;
     pmCloseAll.Enabled := cCloseAll.Enabled;
     pmSaveAll.Enabled := cSaveAll.Enabled;
     end;

end.
