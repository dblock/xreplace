unit TDropV;
(*
               TreeDropView Component (Object Pascal - Delphi 2.0)
                           (c) Daniel Doubrovkine
  Stolen Technologies Inc. - University of Geneva - 1996 - All Rights Reserved
                       for XReplace-32, version 1.51

             This source code is free for educational purposes only.
             If you intend to use this code in an application other
             than freeware, please contact the author for agreement.

                   e-mail welcome: dblock@infomaniak.ch
                         no warranty of any kind
*)
interface

uses
  Classes, ComCtrls, FileCtrl, Controls, Forms, Dialogs, SysUtils, Buttons,
  WinTypes, Messages, MDlg, StatForm, ShellApi, StdCtrls, xrClasses, ShellView,
  PidlManager, TPicFile, d32gen;

const
   NoTag: string = '[no files tagged]';

type
  {--- the TDropView class, descendant from TTreeView ---}
  TDropView = class(TTreeView)
  private
     {public TreeDropView drive node pointer}
     Recurse: boolean;
     FShowImages: boolean;
     FStatusBar: TStatusBar;
     FOnDropFinished: TNotifyEvent;
     {the drop aborter}
     FDropTree: boolean;
     {if this is True, empty directories are also added, otherwise the are
      deleted as recursion finds no files to add}
     FEmpty: boolean;
     {indicates user can delete an item dropped}
     FDelete: boolean;
     {the filter combo to use, if a filter combo is attached, the files of type
      in it only will be added}
     FFilterCombo: TFilterComboBox;
     FMultithreadDrop: boolean;
     {drag drop functions, overriding TTreeView dragdrops with private functions}
     procedure DragDrop(Source: TObject; X, Y: Integer); override;
     procedure PrivateDragDrop(Sender, Source: TObject; X, Y: Integer);
     {drag over functions, overriding TTreeView dragovers with private functions}
     procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
     procedure PrivateDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
     {keyup functions, overriding the TTreeView keyups, for item deletion with Del key}
     procedure KeyUp(var Key: Word; Shift: TShiftState); override;
     {setting the newly declared property values}
     procedure SetDropTree(Value: boolean);
     procedure SetEmpty(Value: boolean);
     procedure SetDelete(Value: boolean);
     procedure SetMultithread(Value: boolean);
     procedure WMDropFiles(var M: TWMDropFiles); message WM_DROPFILES;
     procedure SetIcon(ATreeNode: TTreeNode; iType: NodeType);
     procedure Loaded; override;
     procedure ExternalDragDropPrivate(Directory: string; gMask: string; SelList: tStringList; Recurse: boolean);
     procedure TerminateDragDrop;
     procedure PrepareDragDrop(Source: TObject);
     procedure CheckNoTag;
  public
     InterruptDrop: boolean;
     {updated by the adder thread indicated that it has finished the drop operation}
     DropTerminated: boolean;
     procedure Status(StatString: string);
     procedure StatusVariant(StatString: string; Force: boolean);
     function CountFiles: longint;
     procedure UpdateGlyphs;
     constructor Create(AOwner: TComponent); override; {no comment ...}
     function RAddChild(iParent: TTreeNode; Caption: string; iType: NodeType): TTreeNode;
     function RAdd(iParent: TTreeNode; Caption: string; iType: NodeType): TTreeNode;
     procedure SetShowImages(Value: boolean);
     procedure NodeDeleteInternal(Node: TtreeNode);
     function isEmpty: boolean;
     procedure FileSort;
     procedure ExternalDragDrop(Source: TObject; Directory: string; gMask: string; SelList: tStringList; Recurse: boolean);
  published
     property ShowImages: boolean read FShowImages write SetShowImages;
     property Multithread: boolean read FMultithreadDrop write SetMultithread default True;
     {the associated FilterComboBox affects the type of the files droppped}
     property FilterCombo: TFilterComboBox read FFilterCombo write FFilterCombo default nil;
     {check FDropTree}
     property DropTree: boolean read FDropTree write SetDropTree default True;
     {check FEmpty}
     property Empty: boolean read FEmpty write SetEmpty default True;
     {check FDelete}
     property CanDelete: boolean read FDelete write SetDelete default True;
     {kill the current drop operation if any, does not generate an exception
      if no operation running}
     procedure Kill;
     {get the complete path of a node}
     function GetCompletePath(ANode: TTreeNode): string;
     property OnDropFinished: TNotifyEvent read FOnDropFinished write FOnDropFinished;
     property StatusBar: TStatusBar read FStatusBar write FStatusBar;

     procedure LoadFromFile(const FileName: string; NoPanic: boolean);
     procedure HalfExpand;
     procedure NodeDelete(Node: TTreeNode);
     destructor Destroy; override;
  end;

 procedure Register;                                        {component register}

implementation

uses xreplace, TAdderThread;
{--- TreeDropView ----------------------------------------------------------------------}
procedure tDropView.NodeDeleteInternal(Node: TtreeNode);
          procedure DisposeDelete(ANode: TTreeNode);
          var
             ttNode, tNode: TTreeNode;
             {EXPERIMENTAL LNode: TTreeNode;}
          begin
               tNode := ANode.GetFirstChild;
               while tNode <> nil do begin
                     ttNode := tNode.GetNextSibling;
                     DisposeDelete(tNode);
                     tNode := ttNode; //tNode.GetNextSibling;
                     end;
               {EXPERIMENTAL LNode := PRedirect(aNode.Data)^.Parent;}
               {EXPERIMENTAL if LNode <> nil then PRedirect(LNode.Data)^.Children.Delete(LNode.IndexOf(aNode));}
               {EXPERIMENTAL PRedirect(ANode.Data)^.Children.Destroy;}
               Dispose(PRedirect(ANode.Data));
               aNode.Delete;
               end;
begin
     if Node.Data <> nil then DisposeDelete(Node);
     CheckNoTag;
     end;

procedure TDropView.CheckNoTag;
begin
     while (Items.Count > 0) and (Items[0].Text = NoTag) do Items[0].Delete;
     if Items.Count = 0 then
     with Items.AddChild(nil, NoTag) do begin
          ImageIndex := shGeneric;
          SelectedIndex := shGeneric;
          end;
     end;

procedure TDropView.NodeDelete(Node: TTreeNode);
begin
   if CanDelete then begin
      NodeDeleteInternal(Node);
      if (Self.Showing) then Self.SetFocus;
      end;
   end;

destructor TDropView.Destroy;
begin
     inherited;
     end;

procedure tDropView.PrepareDragDrop(Source: TObject);
begin
     // destroy the top void node
     if Self.Items.Count > 0 then if Self.Items.GetFirstNode.Text = NoTag then Self.Items.GetFirstNode.Destroy;
     // write log
     xRepl32.ReplaceLog.oLog('drop operation initialized from ' + Source.ClassName,'dragdrop',XReplaceOptions.Log.DropDetail);
     // check simple file loading
     // single directory drop?
     if Hi(GetKeyState(VK_CONTROL)) <> 0 then recurse := False else recurse := True;
     InterruptDrop:=False;
     DropTerminated:=False;
     DragAcceptFiles(Self.Handle, False);
     //ShowMessage(IntToStr(Hi(GetKeyState(VK_CONTROL))) + ' ' + BoolToStr(Recurse));
     end;

procedure TDropView.TerminateDragDrop;
begin
     if (not DropTerminated) and (not FMultithreadDrop) then begin
        initStatusForm;
        StatusForm.ShowModal;
        end;
     while not DropTerminated do Application.ProcessMessages;
     DragAcceptFiles(Handle, True);
     {drop has finished, dynamic stuff can rest in peace}
     if StatusForm <> nil then StatusForm.Hide;
     xRepl32.ReplaceLog.oLog('drop operation successfully terminated.','dragdrop',XReplaceOptions.Log.DropDetail);
     Status('Ready.');
     end;

procedure TDropView.PrivateDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   gMask: string;
          procedure dgFileListBoxDrop;
          var
             i: integer;
             SelList: TStringList;
          begin
          if Source is TPicFileListBox then begin
             SelList := TStringList.Create;
             for i:=0 to (Source as TPicFileListBox).Items.Count - 1 do
                 if (Source as TPicFileListBox).Selected[i] then
                    SelList.Add((Source as TPicFileListBox).Items[i]);
             ExternalDragDropPrivate((Source as TPicFileListBox).Directory, gMask, SelList, Recurse);
             //AdderThread.Create(Self, (Source as TPicFileListBox).Directory, gMask, SelList, Recurse);
             end;
          end;

          function dgFileLoad: boolean;
          var
             i: integer;
          begin
             if (Source is TFileListBox) and (Hi(GetKeyState(VK_SHIFT)) <> 0) then begin
                   with (Source as TPicFileListBox) do
                        for i:=0 to Items.Count - 1 do
                            if Selected[i] then
                               xRepl32.LoadTree(Bs(Directory) + Items[i]);

                   HalfExpand;
                   Result := True;
                   end else Result := False;
             end;
var
   i: integer;
begin
     PrepareDragDrop(Source);
     if not dgFileLoad then begin
        if Assigned(FilterCombo) then begin
           FilterCombo.Enabled := False;
           for i:=0 to FilterCombo.Items.Count - 1 do begin
               FilterCombo.ItemIndex := i;
               gMask := gMask + Filtercombo.Mask + ';';
               end;
           FilterCombo.Enabled := True;
           end else gMask := '*.*';
        if gMask = '' then gMask := '*.*';
        {set default state}
        if Source is TShellView then begin       {dropping from a shell view}
           //AdderThread.Create(Self, (Source as TShellView).Directory, gMask, nil, Recurse);
           ExternalDragDropPrivate((Source as TShellView).Directory, gMask, nil, Recurse);
           end else dgFileListBoxDrop;
        {this is really ugly, wait for the drop to terminate}
        end;
     TerminateDragDrop;
     end;

procedure tDropView.ExternalDragDrop(Source: TObject; Directory: string; gMask: string; SelList: tStringList; Recurse: boolean);
begin
     if Assigned(OnDragDrop) then OnDragDrop(Source, Source, 0, 0);
     PrepareDragDrop(Source);
     ExternalDragDropPrivate(Directory, gMask, SelList, Recurse);
     TerminateDragDrop;
     if Assigned(OnDropFinished) then OnDropFinished(Source);     
     end;

procedure tDropView.ExternalDragDropPrivate(Directory: string; gMask: string; SelList: tStringList; Recurse: boolean);
begin
     AdderThread.Create(Self, Directory, gMask, SelList, Recurse);
     end;

procedure TDropView.PrivateDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  try
  if DropTerminated then                    {avoid dropping on a working TDropView}
  if (Source is TPicFileListBox) or
     (Source is TShellView) or
     (Source is TDirectoryListBox) then
     Accept:=True else Accept:=False;
  except
     Accept:=False;
  end;
  end;

procedure TDropView.DragDrop(Source: TObject; X, Y: Integer);
begin
   try
   inherited DragDrop(Source, X, Y);
   PrivateDragDrop(Self, Source, X, Y);
   if Assigned(FOnDropFinished) then FOnDropFinished(Self);
   except
   end;
   end;

procedure TDropView.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
   try
   inherited DragOver(Source, X, Y, State, Accept);
   PrivateDragOver(Self, Source, X, Y, State, Accept);
   except
   end;
   end;

procedure TDropView.KeyUp(var Key: Word; Shift: TShiftState);
begin
   try
   inherited KeyUp(Key, Shift);
   //if FDelete then PrivateKeyUp(Key, Shift);
   except
   end;
   end;

procedure TDropView.SetShowImages(Value: Boolean);
begin
     if Value <> FShowImages then begin
        if Value then Images := CurrentPidlManager.ImageList else Images := nil;
        FShowImages := Value;
        Invalidate;
        end;
     end;

procedure TDropView.Loaded;
begin
     inherited;
     CheckNoTag;
     end;

constructor TDropView.Create(AOwner: TComponent);
begin
   FShowImages := True;
   DropTree:=True;                               {drop entire trees}
   Empty:=False;                                 {don't drop empty directories}
   CanDelete:=True;                              {can delete items}
   DropTerminated:=True;                         {doing nothing now}
   inherited Create(AOwner);                     {go for it}
   Images := CurrentPidlManager.ImageList;
   end;


procedure TDropView.SetIcon(ATreeNode: TTreeNode; iType: NodeType);
begin
        case iType of
             nDirectory : begin
                        ATreeNode.ImageIndex := shFolder;
                        ATreeNode.SelectedIndex := shFolderOpen;
                        end;
             nDrive:    begin
                        ATreeNode.ImageIndex := shHdd;
                        ATreeNode.SelectedIndex := shHdd;
                        end;

             end;
     end;

function TDropView.RAddChild(iParent: TTreeNode; Caption: string; iType: NodeType): TTreeNode;
var
      Redirect: PRedirect;
      ATreeNode: TTreeNode;
   begin
        if (iParent <> nil) and (iParent.Text = NoTag) then begin
           iParent.Delete;
           iParent := nil;
           end;
        Status('Adding '+ Caption);
        new(Redirect);
        {EXPERIMENTAL if iParent <> nil then PRedirect(iParent.Data)^.Children.Add(Caption);}
        with Redirect^ do begin
             Parent := iParent;
             {EXPERIMENTAL Children := TStringList.Create;}
             SourceFileName:=Caption;
             TargetFileName:='';
             fType:=iType;
             OFound := 0;
             OReplaced := 0;
             end;
        if iType = nDirectory then
           ATreeNode:=Self.Items.AddChildFirst(iParent, Caption)
           else ATreeNode:=Self.Items.AddChild(iParent, Caption);
        ATreeNode.Data:=Redirect;
        if XReplaceOptions.Log.DropDetail then xRepl32.ReplaceLog.oLog('adding ' + GetCompletePath(ATreeNode),'dragdrop',XReplaceOptions.Log.DropDetail);
        SetIcon(ATreeNode, iType);
        Result:=ATreeNode;
        end;

procedure TDropView.FileSort;
   procedure FileSortLocal(Node: TTreeNode);
         function CustomSortProc(Node1, Node2: TTreeNode; ParamSort: integer): integer; stdcall;
         begin
              if PRedirect(Node1.Data)^.fType = PRedirect(Node2.Data)^.fType then Result := lstrcmp(PChar(Node1.Text),  PChar(Node2.Text))
              else if PRedirect(Node1.Data)^.fType = nDirectory then Result := -1
              else Result := 1;
              end;
  var
    I: Integer;
    {EXPERIMENTAL iParentList: TStringList;}
  begin
    if InterruptDrop then exit;
    StatusVariant('Sorting... '+Node.Text, True);
    {EXPERIMENTAL iParentList := PRedirect(Node.Data)^.Children;}
    {EXPERIMENTAL iParentList.Clear;}
    Node.CustomSort(@CustomSortProc, 0);
    for I := 0 to Node.Count - 1 do begin
        {EXPERIMENTAL iParentList.Add(Node[i].Text);}
        if  Node[I].HasChildren then FileSortLocal(Node[i]);
        end;
    end;

var
   Node: TTreeNode;
begin
     Node := Items.GetFirstNode;
     while Node <> nil do begin
           if Node.HasChildren then FileSortLocal(Node);
           Node := Node.GetNextSibling;
           end;
     end;

function TDropView.RAdd(iParent: TTreeNode; Caption: string; iType: NodeType): TTreeNode;
begin
     if (iParent <> nil) and (iParent.Text = NoTag) then begin
        iParent.Delete;
        iParent := nil;
        end;
     if (iParent <> nil) then
        Result := RAddChild(PRedirect(iParent.Data)^.Parent, Caption, iType)
        else Result := RAddChild(nil, Caption, iType);
     end;

procedure TDropView.Kill;
begin
   try
   InterruptDrop:=True;
   except
   end;
   end;

procedure TDropView.SetEmpty(Value: boolean);
begin
   try
   if Value<>FEmpty then begin
      FEmpty:=Value;
      Update;
      end;
   except
   end;
   end;

procedure TDropView.SetDropTree(Value: boolean);
begin
   try
   if Value<>FDropTree then begin
      FDropTree:=Value;
      Update;
      end;
   except
   end;
   end;

procedure TDropView.SetDelete(Value: boolean);
begin
   try
   if Value<>FDelete then begin
      FDelete:=Value;
      Update;
      end;
   except
   end;
   end;

procedure TDropView.SetMultithread(Value: boolean);
begin
   try
   if Value<>FMultithreadDrop then begin
      FMultithreadDrop:=Value;
      Update;
      end;
   except
   end;
   end;

function TDropView.GetCompletePath(ANode: TTreeNode): string;
var
   TStr: string;
begin
   try
   if ANode.Parent<>nil then begin
      Result:=GetCompletePath(ANode.Parent);
      if Result[Length(Result)]<>'\' then Result:=Result+'\';
      if ANode.Data <> nil then begin
         tStr:=xRepl32.GetSource(ANode);;
         end else tStr:=ANode.Text;
      Result:=Result+tStr;
   end else begin
      if ANode.Data <> nil then begin
         tStr:=xRepl32.GetSource(ANode);
         end else tStr:=ANode.Text;
       Result:=tStr;
       end;
   except
      Result:=ANode.Text;
   end;
   end;

procedure TDropView.Status(StatString: string);
begin
     StatusVariant(StatString, False);
     end;

procedure TDropView.StatusVariant(StatString: string; Force: boolean);
begin
   try
      if HandleAllocated then
      if (not xReplaceOptions.Gen.ParallelDragDrop) or (Force) then 
      if (not FMultithreadDrop) or (Force) then begin
         initStatusForm;
         StatusForm.Status(StatString)
         end else
      if Assigned(StatusBar) then begin
         StatusBar.SimpleText:=StatString;
         StatusBar.Update;
         end;
   except
   end;
   end;

procedure TDropView.UpdateGlyphs;
   procedure UpdateRedirect(ANode: TTreeNode);
   var
        Redirect: PRedirect;
   begin
        if ANode.Data = nil then begin
           new(Redirect);
           with Redirect^ do begin
             OFound := 0;
             OReplaced := 0;
             end;
           ANode.Data:=Redirect;
           xRepl32.SetSource(ANode, ANode.Text);
           xRepl32.SetTarget(ANode, '');
           end;
        end;
   procedure RecurseNode(ANode: TTreeNode);
   begin
      while ANode<>nil do begin
         UpdateRedirect(ANode);
         if ANode.Count>0 then begin
            RecurseNode(ANode.GetFirstChild);
            if ANode.ImageIndex <= 0 then begin
               aNode.ImageIndex := shFolder;
               aNode.SelectedIndex := shFolderOpen;
               xrepl32.SetNodeType(ANode, nDirectory);
               end;
            end else
         if DirectoryExists(GetCompletePath(ANode)) then begin
            aNode.ImageIndex := shFolder;
            aNode.SelectedIndex := shFolderOpen;
            xRepl32.SetNodeType(ANode, nDirectory);
            end else begin
            aNode.ImageIndex := shGeneric;
            aNode.SelectedIndex := aNode.ImageIndex;
            xRepl32.SetNodeType(ANode, nFile);
            end;
         ANode:=ANode.GetNextSibling;
         end;
      end;
var
   ANode: TTreeNode;
begin
     Status('Updating glyphs...');
     ANode:=Items.GetFirstNode;
     while(ANode<>nil) do begin
         aNode.ImageIndex := shHdd;
         aNode.SelectedIndex := shHdd;
         UpdateRedirect(ANode);
         xRepl32.SetNodeType(ANode, nDrive);
         RecurseNode(ANode);
         ANode:=ANode.GetNextSibling;
         end;
      Status('Ready...');
   end;

procedure TDropView.LoadFromFile(const FileName: string; NoPanic: boolean);
var
   ANode: TTreeNode;
   AText: string;
begin
   try
   Status('Loading file (cancel is unavailable) ...');
   inherited LoadFromFile(FileName);
   ANode:=Items.GetFirstNode;
   while ANode<>nil do begin
      AText:=ANode.Text;
      System.Delete(AText,1,1);
      System.Delete(AText, 4, Length(AText));
      if AText<>':\' then begin
         initMdlg;
         if NoPanic then MsgForm.MessageDlg('Error! The file container of the full state save is invalid!','The file you have attempted to load is either corrupt or has not been saved with XReplace-32! The tagged files list will not be restored.',mtError,[mbOk],0,'')
         else MsgForm.MessageDlg('Error! Attemted to load an invalid file container!','The file you have attempted to load is either corrupt or has not been saved with XReplace-32!',mtError,[mbOk],0,'');
         Items.Clear;
         break;
         end;
      ANode:=ANode.GetNextSibling;
      end;
   except
   end;
   HalfExpand;
   end;

procedure TDropView.HalfExpand;
   function ExpandDirectories(ANode: TTreeNode): boolean;
   begin
      Result:=True;
      while ANode<>nil do begin
         if ANode.Count>0 then begin
            if ExpandDirectories(ANode.GetfirstChild) then
               try
               Anode.Expand(False)
               except
               end
            else
               try
               ANode.Collapse(True);
               except
               end
            end else
            if not DirectoryExists(GetCompletePath(ANode)) then Result:=False;
         ANode:=ANode.GetNextSibling;
      end;
      end;
begin
   try
   Status('Half expanding directores...');
   ExpandDirectories(Items.GetFirstNode);
   Refresh;
   Status('Ready.');
   except
   end;
   end;

procedure TDropView.WMDropFiles(var M: TWMDropFiles);
var
   tStr: PChar;
   SelList: TStringList;
   i: LongInt;
begin
     if Assigned(OnDragDrop) then OnDragDrop(nil, nil, 0, 0);
     if Self.Items.Count > 0 then if Self.Items.GetFirstNode.Text = NoTag then Self.Items.GetFirstNode.Destroy;
     xRepl32.ReplaceLog.oLog('drop operation initialized from Windows Explorer','dragdrop',XReplaceOptions.Log.DropDetail);
     if Hi(GetKeyState(VK_CONTROL)) <> 0 then recurse := False else recurse := True;
     InterruptDrop:=False;
     DropTerminated:=False;
     DragAcceptFiles(Self.Handle, False);
     tStr := AllocMem(MAX_PATH);
     SelList := TStringList.Create;
     with M do begin
          for i:=DragQueryFile(Drop, $FFFFFFFF, Nil, 0) - 1 downto 0 do begin
              DropTerminated := False;
              DragQueryFile(Drop, i, tStr, MAX_PATH);              if InterruptDrop then break;              if DirectoryExists(tStr) then AdderThread.Create(Self, tStr, '*.*', nil, Recurse)              else begin              SelList.Clear;              SelList.Add(ExtractFileName(tStr));              end;          if SelList.Count > 0 then AdderThread.Create(Self, ExtractFileDir(tStr), '*.*', SelList, Recurse);          while not DropTerminated do Application.ProcessMessages;          end;     end;     DropTerminated := True;     FreeMem(tStr);     SelList.Destroy;     DragAcceptFiles(Self.Handle, True);     if Assigned(FOnDropFinished) then FOnDropFinished(Self);     end;function TDropView.isEmpty: boolean;var   fNode: tTreeNode;begin     if Items = nil Then Result := True     Else Begin        fNode := Items.GetFirstNode;        if (fNode <> nil) and (fNode.Text <> NoTag) Then Result := False Else Result := True;     end;     end;
function TDropView.CountFiles: longint;
         function CountNodeFiles(aNode: TTreeNode): longint;
         begin
              Result := 0;
              while ANode<>nil do begin
                    if ANode.Count>0 then Result := Result + CountNodeFiles(ANode.GetFirstChild);
                    if (xRepl32.GetNodeType(aNode) = nFile) then Result := Result + 1;
                    ANode:=ANode.GetNextSibling;
                    end;
              end;
begin
     Result := CountNodeFiles(Self.Items.GetFirstNode);
     end;

{--------------------------------------------------------------}
procedure Register;
begin
  try
  RegisterComponents('Samples', [TDropView]);
  except
  end;
end;

end.
