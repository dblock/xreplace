unit xshedule;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, StdCtrls, ExtCtrls, ComCtrls, Buttons, xreplace,
  Menus, BrowseDr, ShellApi, ShellView, TPicFile, d32reg, d32gen, ImgList;

type
  TxFShedule = class(TForm)
    sPanel: TPanel;
    fPanel: TPanel;
    rPanel: TPanel;
    TopPanel: TPanel;
    SheduleTree: TTreeView;
    ImageList1: TImageList;
    ShedActivate: TSpeedButton;
    MacroEditor: TSpeedButton;
    ShedClose: TSpeedButton;
    MainMenu1: TMainMenu;
    Shedule1: TMenuItem;
    CloseShedule1: TMenuItem;
    ActivateActivXR1: TMenuItem;
    N1: TMenuItem;
    MacroEditor1: TMenuItem;
    ModifyShedule: TSpeedButton;
    Item1: TMenuItem;
    AddModifySelected1: TMenuItem;
    AddNewShedule1: TMenuItem;
    AddShedule: TSpeedButton;
    SheduleDelete: TSpeedButton;
    DeleteSheduleObject1: TMenuItem;
    HelpAbout1: TMenuItem;
    Helo1: TMenuItem;
    N2: TMenuItem;
    AboutXReplace321: TMenuItem;
    Help: TSpeedButton;
    fDir: TShellView;
    HSplitter: TSplitter;
    FilterPanel: TPanel;
    fFilter: TFilterComboBox;
    fFile: TPicFileListBox;
    BBffDust: TBitBtn;
    procedure sPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SheduleTreeDragOver(Sender, Source: TObject; X, Y: Integer;State: TDragState; var Accept: Boolean);
    procedure SheduleTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SheduleTreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure SheduleTreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SheduleTreeCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
    procedure SheduleTreeChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure ShedActivateClick(Sender: TObject);
    procedure MacroEditorClick(Sender: TObject);
    procedure ShedCloseClick(Sender: TObject);
    procedure ModifySheduleClick(Sender: TObject);
    procedure AddSheduleClick(Sender: TObject);
    procedure SheduleDeleteClick(Sender: TObject);
    procedure AboutXReplace321Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure FilterPanelResize(Sender: TObject);
    procedure fDirChange(Sender: TObject; Node: TTreeNode);
    procedure fFilterChange(Sender: TObject);
    procedure fFileDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SheduleTreeChange(Sender: TObject; Node: TTreeNode);
    procedure TopPanelResize(Sender: TObject);
    procedure BBffDustDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure BBffDustDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    iList, jList: TStringList;
    MinWidth, MinHeight: integer;
    function MacroSelect(FileName: string): TTreeNode;
    procedure SheduleBinaryUpdate;
    procedure SheduleBinaryRestore;
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message WM_WindowPosChanging;
    procedure WMDropFiles(var M: TWMDropFiles); message WM_DROPFILES;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure UpdateDependencies;
  public
    { Public declarations }
  end;

  procedure InitXFShedule;

var
  xFShedule: TxFShedule = nil;

implementation

uses dshedule, macro, xopt;

{$R *.DFM}

procedure InitXFShedule;
begin
     if XFShedule = nil then begin
        Application.CreateForm(TxFShedule, xFShedule);
        end;
     end;

procedure TxFShedule.sPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   tW: integer;
begin
   if ssLeft in Shift then begin
      tw:=(X + fPanel.Width);
      if (tw <> fPanel.Width) and
         (tw < trunc(xFshedule.Width * 0.9)) and
         (tw > trunc(xFshedule.Width * 0.1)) then
          fPanel.Width:=tw;
      end;

   end;

procedure TxFShedule.FormCreate(Sender: TObject);
var
   ch, cw: integer;
begin
   iList := TStringList.Create;
   jList := TStringList.Create;
   MinWidth := Width;
   MinHeight := Height;
   DragAcceptFiles(Self.Handle, True);
   SheduleBinaryRestore;
   try cw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery+'\shedule\',
                    'width'); except cw:=0; end;
   try ch:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery+'\shedule\',
                    'height'); except ch:=0; end;
   if cw>=0 then xFShedule.Width:=cw;
   if ch>=0 then xFShedule.Height:=ch;
   try cw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery+'\shedule\',
                    'left'); except cw:=0; end;
   try ch:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery+'\shedule\',
                    'top'); except ch:=0; end;
   if cw>=0 then xFShedule.Left:=cw else xFShedule.Left:=(Screen.Width - xFShedule.Width) div 2;
   if ch>=0 then xFShedule.Top:=ch  else xFShedule.Top:=(Screen.Height - xFShedule.Height) div 2;
   try cw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery+'\shedule\',
                    'fpanel width'); except cw:=0; end;
   if cw > 0 then fPanel.Width:=cw;
   FormResize(Sender);
   if (XReplaceOptions.Gen.RememberDirs) and DirectoryExists(XReplaceOptions.Hidden.SheduleDirectory) then
      fDir.Directory := XReplaceOptions.Hidden.SheduleDirectory
      else fDir.Directory := 'C:\';
   fFilterChange(Self);
   end;

procedure TxFShedule.FormResize(Sender: TObject);
begin

   if fPanel.Width > trunc(xFShedule.Width * 0.9) then
      fPanel.Width:=trunc(xFShedule.Width * 0.9) else
   if fPanel.Width < trunc(xFShedule.Width * 0.1) then
      fPanel.Width:=trunc(xFShedule.Width * 0.1);

   end;

procedure TxFShedule.SheduleTreeDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   if (Sender is TPicFileListBox) then Accept:=True;
   end;

procedure TxFShedule.SheduleTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   i: integer;

begin
     if Source is TPicFileListBox then
        with Source as TPicFileListBox do
             for i:=0 to Items.Count - 1 do
                 if Selected[i] then
                    if FileExists(bs(Directory) + Items[i]) then
                       MacroSelect(bs(Directory) + Items[i]);
   end;

function TxFShedule.MacroSelect(FileName: string): TTreeNode;
var
   CurrentNode: TTreeNode;
begin
     CurrentNode:=SheduleTree.Items.GetFirstNode.GetfirstChild;
     while CurrentNode <> nil do begin
           if CompareText(CurrentNode.Text, FileName) = 0 then begin
              Result:=nil;
              exit;
              end;
           CurrentNode:=CurrentNode.GetNextSibling;
           end;
     Result:=SheduleTree.Items.AddChild(SheduleTree.Items.GetFirstNode, FileName);
     Result.ImageIndex:=2;
     Result.SelectedIndex := 2;
     xRepl32.ReplaceLog.oLog('added shedule macro: '+Result.Text,'shedule',XReplaceOptions.Log.Shed);
     SheduleTree.Items.GetFirstNode.Expand(False);
     UpdateDependencies;
     end;

procedure TxFShedule.SheduleTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   try
   if (Button = mbRight) and
      (SheduleTree.GetNodeAt(X, Y) <> nil) and
      (SheduleTree.GetNodeAt(X, Y) <> SheduleTree.Items.GetFirstNode) then begin
      SheduleTree.Selected:=SheduleTree.GetNodeAt(X, Y);
      initDoShedule;
      dOShedule.ShowModal;
      UpdateDependencies;
      end;
   except
   end;
end;

procedure TxFShedule.SheduleBinaryUpdate;
          function ShedDir(iStr: string): string;
          var
             i: integer;
          begin
               for i:=1 to Length(iStr) do
                   if iStr[i]='\' then iStr[i]:='/';
               Result:=iStR;
               end;
var
   iNode, cNode: TTreeNode;
   tData: PShedule;
begin
     DeleteKey(HKEY_CURRENT_USER,RootUpdate+'\shedule\','shedule container\');
     AddKey(HKEY_CURRENT_USER,RootUpdate+'\shedule\','shedule container');
     iNode:=SheduleTree.Items.GetFirstNode.GetFirstChild;
     while (iNode<>nil) do begin
           if iNode.Count <> 0 then begin
              cNode:=iNode.GetFirstChild;
              //caption node
              AddKey(HKEY_CURRENT_USER,RootUpdate+'shedule\shedule container\',
                     ShedDir(iNode.Text));
              while cNode <> nil do begin
                    //internal shedule node
                    AddKey(HKEY_CURRENT_USER,RootUpdate+'\shedule\shedule container\'+ShedDir(iNode.Text)+'\',
                           cNode.Text);
                    tData:=cNode.Data;
                    with tData^ do begin
{                         AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\shedule container\'+ShedDir(iNode.Text)+'\'+cNode.Text,
                                                     'eDayType',
                                                     eDayType);}
                         AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\shedule container\'+ShedDir(iNode.Text)+'\'+cNode.Text,
                                                     'eDayName',
                                                     eDayName);
                         AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\shedule container\'+ShedDir(iNode.Text)+'\'+cNode.Text,
                                                     'eDayNum',
                                                     eDayNum);
                         AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\shedule container\'+ShedDir(iNode.Text)+'\'+cNode.Text,
                                                     'eMonName',
                                                     eMonName);
                         AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\shedule container\'+ShedDir(iNode.Text)+'\'+cNode.Text,
                                                     'eYearVal',
                                                     eYearVal);
                         AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\shedule container\'+ShedDir(iNode.Text)+'\'+cNode.Text,
                                                     'eTimeVal',
                                                     eTimeVal);
                         end;
                    cNode:=cNode.GetNextSibling;
                    end;
              end;
           iNode:=iNode.GetNextSibling;
           end;
     end;

procedure TxFShedule.FormDestroy(Sender: TObject);
begin
   SheduleBinaryUpdate;
   {AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'shedule directory',
                               fDir.Directory);}
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'version control',
                               'XR162SHED100');
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'notice',
                               'modifying the shedules by hand is at your own risk');
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'height',
                               xFShedule.Height);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'width',
                               xFShedule.Width);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'top',
                               xFShedule.Top);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'left',
                               xFShedule.Left);
   AddReg(HKEY_CURRENT_USER,   RootUpdate+'\shedule\',
                               'fpanel width',
                               fPanel.Width);

   end;

procedure TXFShedule.SheduleBinaryRestore;
          function DeStr(iStr: string): string;
          var
             i: integer;
          begin
               for i:=1 to Length(iStR) do if iStr[i]='/' then iStr[i]:='\';
               Result:=iStr;
               end;
var
   i, j: integer;
   iShedule: PShedule;
   iNode, cNode:TTreeNode;
begin
     try
     GetKeyNames(HKEY_CURRENT_USER,
                 RootQuery+'\shedule\shedule container\',
                 iList);
     except
     exit;
     end;

     try
     for i:=0 to iList.Count - 1 do begin
         iNode:=MacroSelect(DeStr(iList[i]));
         if iNode <> nil then begin
            try
            jList.Clear;
            GetKeyNames(HKEY_CURRENT_USER,RootQuery+'\shedule\shedule container\'+iList[i], jList);
            for j:=0 to jList.Count - 1 do begin
            new(iShedule);
            with iShedule^ do begin
              //eDayType:=QueryReg(HKEY_CURRENT_USER,   RootQuery+'\shedule\shedule container\'+iList.Items[i]+'\'+jList.Items[j],'eDayType');
              eDayName:=QueryReg(HKEY_CURRENT_USER,   RootQuery+'\shedule\shedule container\'+iList[i]+'\'+jList[j],'eDayName');
              eDayNum:=QueryReg(HKEY_CURRENT_USER,   RootQuery+'\shedule\shedule container\'+iList[i]+'\'+jList[j],'eDayNum');
              eMonName:=QueryReg(HKEY_CURRENT_USER,   RootQuery+'\shedule\shedule container\'+iList[i]+'\'+jList[j],'eMonName');
              eYearVal:=QueryReg(HKEY_CURRENT_USER,   RootQuery+'\shedule\shedule container\'+iList[i]+'\'+jList[j],'eYearVal');
              eTimeVal:=QueryReg(HKEY_CURRENT_USER,   RootQuery+'\shedule\shedule container\'+iList[i]+'\'+jList[j],'eTimeVal');
              end;
            cNode:=SheduleTree.Items.AddChild(iNode, jList[j]);
            cNode.ImageIndex:=3;
            cNode.SelectedIndex := 3;            
            cNode.Data:=iShedule;
            cNode.Parent.Expand(True);
            end;
            except
            end;
         end;
         end;
     except
     exit;
     end;
     end;

procedure TxFShedule.SheduleTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     try
     if (key = VK_DELETE) and
        (SheduleTree.Selected <> SheduleTree.Items.GetFirstNode) and
        (SheduleTree.Selected <> nil) then begin
           if (SheduleTree.Selected.Parent = SheduleTree.Items.GetFirstNode) then
              xRepl32.ReplaceLog.oLog('removed sheduled macro: '+SheduleTree.Selected.Text,'shedule',XReplaceOptions.Log.Shed)
              else xRepl32.ReplaceLog.oLog('removed shedule object '+SheduleTree.Selected.Text + ' for '+SheduleTree.Selected.Parent.Text,'shedule',XReplaceOptions.Log.Shed);
                              SheduleTree.Selected.Destroy;
                              end;
     UpdateDependencies;
     except
        xRepl32.MyExceptionHandler(SheduleTree);
     end;
end;

procedure TxFShedule.SheduleTreeCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
     if Node = SheduleTree.Items.GetFirstNode then AllowCollapse:=False;
     end;

procedure TxFShedule.SheduleTreeChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
begin
     if Node = SheduleTree.Items.GetFirstNode then AllowChange:=False;
     end;

procedure TxFShedule.ShedActivateClick(Sender: TObject);
begin
   xRepl32.ShedActivate.Click;
   end;

procedure TxFShedule.MacroEditorClick(Sender: TObject);
begin
    {$ifdef Registered}
    initMacroEdit;
    MacroEdit.Show;
    {$Endif}
    end;

procedure TxFShedule.ShedCloseClick(Sender: TObject);
begin
   xFShedule.Close;
   end;

procedure TxFShedule.ModifySheduleClick(Sender: TObject);
var
   iRect: TRect;
begin
     try
     if SheduleTree.Selected = nil then exit;
     iRect:=SheduleTree.Selected.DisplayRect(True);
     SheduleTreeMouseDown(Sender, mbRight, [ssRight], iRect.Left+1, iRect.Top+1);
     except
     end;
     end;

procedure TxFShedule.AddSheduleClick(Sender: TObject);
begin
     with SheduleTree do begin
          if (Selected = nil) or (Selected = Items.GetFirstNode) then exit;
          if Selected.Parent <> Items.GetFirstNode then Selected:=Selected.Parent;
          ModifyShedule.Click;
          end;
     end;

procedure TxFShedule.SheduleDeleteClick(Sender: TObject);
var
   iKey: word;
begin
     if (SheduleDelete.Enabled) then begin
          iKey :=VK_DELETE;
          SheduleTreeKeyDown(Sender, iKey, []);
          end;
     end;

procedure TxFShedule.AboutXReplace321Click(Sender: TObject);
begin
     xRepl32.AboutXReplace321.Click;
     end;

procedure TxFShedule.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=27 then begin
      ShedClose.Click;
      end else
   if Key=112 then begin
      Help.Click;
      end;
   end;

procedure TxFShedule.HelpClick(Sender: TObject);
begin
     xRepl32.ShowHelp('schedule.html');
     end;

procedure TxFShedule.WMwindowposchanging(var M: TWMwindowposchanging);
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

procedure TxFShedule.WMDropFiles(var M: TWMDropFiles);
var
   i: integer;
   tStr: PChar;
begin
     tStr := AllocMem(MAX_PATH);
     with M do
     for i:=DragQueryFile(Drop, $FFFFFFFF, Nil, 0) - 1 downto 0 do begin
         DragQueryFile(Drop, i, tStr, 255);         if FileExists(tStr) then MacroSelect(tStr);         end;     end;

procedure TxFShedule.FilterPanelResize(Sender: TObject);
begin
     fFilter.Width := FilterPanel.ClientWidth;
     FilterPanel.ClientHEight := fFilter.Height;
     end;

procedure TxFShedule.fDirChange(Sender: TObject; Node: TTreeNode);
begin
     if (not fDir.isParsing) then begin
        fFile.SafeDirectory := fDir.Directory;
        XReplaceOptions.Hidden.SheduleDirectory := fDir.Directory;
        end;
     end;

procedure TxFShedule.fFilterChange(Sender: TObject);
begin
     fFile.Mask := fFilter.Mask;
     fFile.PublicUpdate;
     end;

procedure TxFShedule.fFileDblClick(Sender: TObject);
var
   LFile: string;
begin
   LFile := Bs(fFile.Directory) + fFile.Items[fFile.ItemIndex];
   if DirectoryExists(LFile) then fDir.Directory := LFile;
   end;

procedure TxFShedule.FormShow(Sender: TObject);
begin
     UpdateDependencies;
     end;

procedure TxFShedule.WMSysCommand(var Msg: TWMSysCommand);
begin
   if Msg.CmdType=SC_MINIMIZE then begin
      Self.Close;
      end else inherited;
   end;


procedure TxFShedule.SheduleTreeChange(Sender: TObject; Node: TTreeNode);
begin
     UpdateDependencies;
     end;

procedure TxFShedule.UpdateDependencies;
begin
     SheduleDelete.Enabled :=
        (SheduleTree.Selected <> SheduleTree.Items.GetFirstNode) and
        (SheduleTree.Selected <> nil);
     AddShedule.Enabled := SheduleDelete.Enabled;
     ModifyShedule.Enabled := SheduleDelete.Enabled;
     BBffDust.Enabled := SheduleDelete.Enabled;

     AddNewShedule1.Enabled := AddShedule.Enabled;
     AddModifySelected1.Enabled := ModifyShedule.Enabled;
     DeleteSheduleObject1.Enabled := SheduleDelete.Enabled;
     end;


procedure TxFShedule.TopPanelResize(Sender: TObject);
begin
     bbFFDust.Left := TopPanel.ClientWidth - bbFFDust.Width - 2;
     end;

procedure TxFShedule.BBffDustDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
     try
     if (Source is TTreeView) and (Source = SheduleTree) then
         Accept:=True else Accept:=False;
     except
     end;
     end;

procedure TxFShedule.BBffDustDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
     try
     SheduleDeleteClick(Self);
     except
     end;
     end;

end.

