unit ShellView;

interface

uses Comctrls, activex, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, ShellApi, WinProcs, WinTypes, ShlObj, RegStr, FileCtrl, Menus,
     CPidl, d32gen, d32debug;


type

{    PLuThread = ^LUThread;
    LUThread = class(TThread)
       private
          ii: LongInt;
          ItemsList: TLisT;
          ListView: TListView;
          Killed: boolean;
          hPrev: TListItem;
          UpdatePointer: PLUThread;
          procedure NodeCreate;
       public
          constructor Create(_ItemsList: TList; _ListView: TListView; _UpdatePointer: PLUThread);
          procedure Execute; override;
          procedure Kill;
       end;}

    PPopThread = ^TPopThread;
    PSDirThread = ^TSDirThread;

    TShellView = class(TTreeView)
       public
             isExpanding : boolean;
             isParsing: boolean;
             constructor Create(AOwner: TComponent); override;
             destructor Destroy; override;
             procedure ParseToStrNode(iStr: string; Node: TTreeNode);
             procedure ParseToStrItem(iStr: string; Pure: boolean);
             procedure ParseToFolder(pidlObjExt: PCPidl);
             procedure ParseToStrfolder(folder: string);
             procedure ParseToPidl(pidlObjExt: PItemIdList);
             procedure UpdateNode(Node: TTreeNode);
             procedure Rebuild;
             procedure RebuildNode(Node: TTreeNode);
             procedure Abort;
       private
             ThreadsList: TList;
             isCollapsing: boolean;
             isLooking: boolean;
             //LUpdate : LUThread;
             RImageListSmall, RImageListLArge: TImageList;
             FListView: TListView;
             FNonFolders: boolean;
             procedure SetFListView(Value: TListView);
             function PopulateTreeNode(pFolder: PShellFolder; pidlQ: PItemIdList; hParent: TTreeNode): boolean;
             function CanExpand(Node: TTreeNode): boolean; override;
             function CanCollapse(Node: TTreENode): boolean; override;
             //procedure PopulateListView(pFolder: PShellFolder; pidlQ: PItemIdList; hParent: TTreeNode);
             procedure SetDirectory(Value: string);
             function GetDirectory: string;
             procedure SetFNonFolders(Value: boolean);
       protected
             procedure PopulateTreeInit;
             procedure Loaded; override;
             function CanChange(Node: TTreeNode): boolean; override;
       published
             property NonFolders: boolean read FNonFolders write SetFNonFolders;
             property Directory: string read GetDirectory write SetDirectory;
             property ListView: TListView read FListView write SetFListView;
             end;

    TPopThread = class(TThread)
       private
             hSortable: TTreeNode;
             Release: boolean;
             NodePidlObj : PCPidl;
             NodeAttrs : UINT;
             SetIconResult : boolean;
             pFolder: PShellFolder;
             pidlQ: PItemIdList;
             hParent: TTreeNode;
             ShellView: TShellView;
             NodeCaption: string;
             NodeParent: TTreeNode;
             procedure Execute; override;
             procedure AddNode;
             procedure DeleteNode;
             procedure SetIcon;
             function PopulateTreeNode(pFolder: PShellFolder; pidlQ: PItemIdList; hParent: TTreeNode): boolean;
             procedure PopulateTreeInit;
             procedure ParentSort;
             procedure AddToThreadsList;
             procedure RemoveFromThreadsList;
       public
             constructor Create(iShellView: TShellView; ipFolder: PShellFolder; ipidlQ: PItemIdList; ihParent: TTreeNode);
       end;

       TSDirThread = class(TThread)
       public
             constructor Create(iShellView: TShellView; iDirectory: string);
       private
             ShellView: TShellView;
             Directory: string;
             procedure AddToThreadsList;
             procedure RemoveFromThreadsList;
             procedure Execute; override;
       end;


procedure Register;

implementation

uses PidlManager;

const
     nilCaption : string = '';

constructor TSDirThread.Create(iShellView: TShellView; iDirectory: string);
begin
     ShellView := iShellView;
     Synchronize(AddToThreadsList);
     while ShellView.isLooking do Application.ProcessMessages;
     ShellView.isLooking := True;
     Directory := iDirectory;
     inherited Create(False);
     end;

procedure TSDirThread.Execute;
begin
     try
     ShellView.ParseToStrFolder(Directory);
     finally
     Synchronize(RemoveFromThreadsList);
     end;
     end;

procedure tShellView.Loaded;
begin
     inherited;
     if not (csDesigning in ComponentState) then PopulateTreeInit;
     end;

constructor TShellView.Create(AOwner: TComponent);
begin
     inherited;
     isParsing := False;
     isLooking := False;
     Images := CurrentPidlManager.ImageList;
     ThreadsList := TList.Create;
     end;

destructor TShellView.Destroy;
begin
   inherited;
   ThreadsList.Destroy;
   ThreadsList := nil;
   end;

procedure TShellView.Abort;
type
   PThread = ^TThread;
var
   AThread: PThread;
   i: integer;
begin

   while ThreadsList.Count <> 0 do begin
      AThread := PThread(ThreadsList.First);
      AThread.WaitFor;
      end;

   end;

procedure TShellView.PopulateTreeInit;
begin
     TPopThread.Create(Self, nil, nil, nil);
     end;

procedure TPopThread.PopulateTreeInit;
var
   pDesktopFolder: PShellFolder;
   hr: HRESULT;
   hNode: TTreeNode;
begin
     with ShellView do begin
     isExpanding := False;
     new(pDesktopFolder);
     hr := SHGetDesktopFolder(pDesktopFolder^);
     if (SUCCEEDED(hr)) then begin
        NodeParent := nil;
        ShellView.Items.Clear;
        new(NodepidlObj);
        NodepidlObj^ := TCPidl.Create(nil, pDesktopFolder);
        NodepidlObj.GetDisplayName(NodeCaption, SHGDN_NORMAL);
        synchronize(AddNode);
        with NodeParent do begin
           ImageIndex := shDesktop;
           SelectedIndex := ImageIndex;
           end;
        hNode := NodeParent;
        PopulateTreeNode(pDesktopFolder, NodepidlObj.m_pidl, hNode);
        hNode.Expand(False);
        end;
        end;
     end;

function TShellView.PopulateTreeNode(pFolder: PShellFolder; pidlQ: PItemIdList; hParent: TTreeNode): boolean;
begin
     Result := True;
     TPopThread.Create(Self, pFolder, pidlQ, hParent);
     end;

procedure TPopThread.AddNode;
begin
     NodeParent := ShellView.Items.AddChild(NodeParent, NodeCaption);
     NodeParent.Data := NodePidlObj;
     if Assigned(NodePidlObj) then NodePidlObj.u_node := NodeParent;
     end;

procedure TPopThread.DeleteNode;
begin
     NodeParent.Delete;
     end;

procedure TPopThread.ParentSort;
begin
     try
     if Assigned(hSortable) and Assigned(hSortable.Parent) and (hSortable.ImageIndex = shFolder) then begin
        {$IFDEF Debug}DebugForm.Debug('FFSHELL::AlphaSort:[' + hSortable.Text + ' sorting at ' + hSortable.Parent.Text + ']');{$ENDIF}
        hSortable.Parent.AlphaSort;
        end;
     except
     end;
     end;

procedure TPopThread.SetIcon;
begin
     SetIconResult := CurrentPidlManager.SetNodeIcon(NodePidlObj, NodeParent, nil, NodeAttrs);
     end;

function TPopThread.PopulateTreeNode(pFolder: PShellFolder; pidlQ: PItemIdList; hParent: TTreeNode): boolean;
var
   Nodes: TList;

         function isInList(PidlObj: PCPidl): boolean;
         var
            i: integer;
         begin
              Result := True;
              for i:=0 to Nodes.Count - 1 do
                  //if PCPidl(Nodes[i]).GetFolder.CompareIDs(0, pidl, PCPidl(Nodes[i]).m_pidl) = 0 then begin
                  if CompareText(PCPidl(Nodes[i]).u_name, PidlObj.u_name) = 0 then begin
                     PCPidl(Nodes[i]).u_validated := True;
                     exit;
                     end;
              Result := False;
              end;

         procedure UpdateNodes;
         var
            i: integer;
         begin
              for i:=Nodes.Count - 1 downto 0 do
                  if not PCPidl(Nodes[i]).u_validated then begin
                     PCPidl(Nodes[i]).u_node.Delete;
                     PCPidl(Nodes[i]).Destroy;
                     end;
              Nodes.Destroy;
              end;

         procedure ReadNodes;
         var
            Node: TTreENode;
         begin
              Nodes := TList.Create;
              Node := hParent.GetFirstChild;
              while (Node <> nil) and (Node.Data <> nil) do begin
                    Release := True;
                    PCPidl(Node.Data)^.u_validated := False;
                    Nodes.Add(Node.Data);
                    Node := Node.GetNextSibling;
                    end;
              end;
var
   hr: HResult;
   pEnumIdList: IEnumIdList;
   pidlNew: PItemIdList;
   ulFetched: DWORD;
   pMalloc: IMalloc;
begin
     Result := True;
     hSortable:=nil;
     if hParent = nil then PopulateTreeInit else
     if not FAILED(pFolder.EnumObjects(0, SHCONTF_FOLDERS or SHCONTF_INCLUDEHIDDEN or SHCONTF_NONFOLDERS, pEnumIDList)) then begin
        ReadNodes;
        hr := CoGetMalloc(MEMCTX_TASK, pMalloc);
        if SUCCEEDED(hr) then begin
           while(pEnumIDList.Next(1, pidlNew, ulFetched) = S_OK) do begin
              NodeAttrs := SFGAO_HASSUBFOLDER or SFGAO_FOLDER or SFGAO_SHARE or SFGAO_FILESYSANCESTOR or SFGAO_FILESYSTEM or SFGAO_REMOVABLE;
              pFolder.GetAttributesOf(1, pidlNew, NodeAttrs);
              if (NodeAttrs and SFGAO_FOLDER) > 0 then begin

                 new(NodePidlObj);
                 NodePidlObj^ := TCPidl.Create(pidlNew, pFolder);
                 if (pidlQ <> nil) then NodePidlObj.SetQualifiedPidl(pidlQ);
                 NodePidlObj.ulAttrs := NodeAttrs;
                 NodePidlObj.GetDisplayName(NodeCaption, SHGDN_NORMAL);
                 NodeParent := hParent;

                 if not isInList(NodePidlObj) then begin
                    synchronize(AddNode);
                    Synchronize(SetIcon);
                    Release := True;
                    if not SetIconResult then begin
                       synchronize(DeleteNode);
                       end else begin
                       hSortable := NodeParent;
                       NodeCaption := nilCaption;
                       NodePidlObj := nil;
                       synchronize(AddNode);
                       Release := True;
                       end;
                    end else dispose(NodePidlObj);
                 end;
           pMalloc.Free(pidlNew);
           end;
        Result := True;
        if Assigned(hSortable) then Synchronize(ParentSort);
        end;
        UpdateNodes;
     end;
   Release := True;
   end;

function TShellView.CanCollapse(Node: TTreeNode): boolean;
begin
     Result := inherited CanCollapse(Node);
     isCollapsing := True;
     end;

function TShellView.CanExpand(Node: TTreeNode): boolean;
var
   pidlObj: PCPidl;
   pFolder: PShellFolder;
   hr: HResult;
begin
     Result := inherited CanExpand(Node);
     if not (csDesigning in ComponentState) then
     if Result then
     if (Node.Data <> nil) and (Node.GetFirstChild.Text = nilCaption) then begin
        Node.GetFirstChild.Delete;
        pidlObj := Node.Data;
        new(pFolder);
        hr := pidlObj.GetFolder.BindtoObject(pidlObj.m_pidl, nil, IID_IShellFolder, pointer(pFolder^));
	if (SUCCEEDED(hr)) then begin
           if not PopulateTreeNode(pFolder, pidlObj.GetQualifiedPidl, Node) then Result := False
           else begin
                Invalidate;
                Selected := Node;
                end;
           end;
        end;
     end;


procedure TShellView.SetFListView(Value: TListView);
begin
     if Value <> FListView then begin
        FListView := Value;
        if RImageListSmall = nil then begin
           RImageListSmall := TImageList.Create(Self);
           RImageListSmall.Width := 16;
           RImageListSmall.Height := 16;
           end;
        if RImageListLarge = nil then begin
           RImageListLarge := TImageList.Create(Self);
           RImageListLarge.Width := 32;
           RImageListLarge.Height := 32;
           end;
        FListView.SmallImages := RImageListSmall;
        end;
     end;


function TShellView.CanChange(Node: TTreeNode): boolean;
var
   pidlObj: PCPidl;
   pFolder: PShellFolder;
   Bound: boolean;
       function Bind: boolean;
       begin
            if Bound then Result := True else
               if Node = Items.GetFirstNode then begin
                  Bound := SUCCEEDED(SHGetDesktopFolder(pFolder^));
                  Result := bound;
                  end else begin
                  Bound := Succeeded(pidlObj.GetFolder.BindtoObject(pidlObj.m_pidl, nil, IID_IShellFolder, pointer(pFolder^)));
                  Result := Bound;
                  end;
            end;

       procedure UnBind;
       begin
            //if Bound then pFolder.Release;
            end;
begin
     if Node = nil then begin
        Result := False;
        exit;
        end;

     Result := inherited CanChange(Node) and (Node.Data <> nil);
     if isCollapsing then begin
        isCollapsing := False;
        exit;
        end;

     if (not isExpanding) and Result then
     if (Node <> nil) and (not Node.Expanded) then begin
        Bound := False;
        pidlObj := Node.Data;
        new(pFolder);
        {if Assigned(FListView) then
           if Bind then PopulateListView(pFolder, pidlObj.GetQualifiedPidl, Node);}
        {if (not Node.Expanded) then begin
           Node.DeleteChildren;}
        if Bind then
           if not PopulateTreeNode(pFolder, pidlObj.GetQualifiedPidl, Node) then
              Result := False;
           //end;

        UnBind;
        end;
     end;
(*
procedure TShellView.PopulateListView(pFolder: PShellFolder; pidlQ: PItemIdList; hParent: TTreeNode);
var
   pMalloc: IMAlloc;
   EnumIdList: IEnumIdList;
   pidlNew: PItemIdList;
   ulFetched: LongInt;
   pidlObj: PCPidl;
   aItemsList: TList;
begin
        if LUpdate <> nil then LUpdate.Kill;
        while LUpdate <> nil do Application.ProcessMessages;
        FListView.Items.Clear;

        if pFolder = nil then exit;
        FListView.SmallImages.Clear;
        CurrentPidlManager.InitImages(FListView.SmallImages);
        aItemslist := TList.Create;

        if SUCCEEDED(CoGetMalloc(MEMCTX_TASK, pMalloc)) then begin
	   if SUCCEEDED(pFolder.EnumObjects(0, SHCONTF_FOLDERS or SHCONTF_NONFOLDERS, EnumIDList)) then begin
              while(EnumIDList.Next(1, pidlNew, ulFetched) = S_OK) do begin
              new(pidlObj);
              pidlObj^ := TCPidl.Create(pidlNew, pFolder);
              pidlObj.ulAttrs := SFGAO_HASSUBFOLDER or SFGAO_FOLDER or SFGAO_SHARE or SFGAO_FILESYSANCESTOR or SFGAO_FILESYSTEM or SFGAO_REMOVABLE;
              pFolder.GetAttributesOf(1, pidlNew, pidlObj.ulAttrs);
              aItemsList.Add(pidlObj);
              end;
           //EnumIDList.Release;
           LUpdate := LUThread.Create(aItemsList, FListView, @LUpdate);
           end;
        pMalloc.Release;
        end;
     end;
     *)

procedure TShellView.ParseToStrFolder(Folder: string);
          procedure SetCurrentFolderNetwork;
          var
             CSIDL_NETWORK_pidl: PItemIdlIst;
          begin
               SHGetSpecialFolderLocation(HINSTANCE, CSIDL_NETWORK, CSIDL_NETWORK_pidl);
               Selected := Items.GetFirstNode;
               ParseToPidl(CSIDL_NETWORK_pidl);
               end;
          procedure SetCurrentFolderMyComputer;
          var
             CSIDL_DRIVES_pidl: PItemIdlIst;
          begin
               SHGetSpecialFolderLocation(HINSTANCE, CSIDL_DRIVES, CSIDL_DRIVES_pidl);
               Selected := Items.GetFirstNode;
               ParseToPidl(CSIDL_DRIVES_pidl);
               end;
          procedure ParseToDirectory(idir: string);
          var
             FileName: string;
          begin
               while isExpanding do Application.ProcessMessages;
               iDir := nBs(iDir);
               FileName := ExtractFileName(iDir);
               if (fileName <> iDir) and (Length(FileName) <> 0) then
                  ParseToDirectory(Copy(iDir, 1, Length(iDir) - Length(FileName)))
                  else FileName := iDir;
               if Length(FileName) > 0 then begin
                  ParseToStrItem(FileName, False);
                  end;
               end;
var
   fDrive: string;
begin
     {$IFDEF Debug}DebugForm.Debug('FFSHELL::changing to ' + Folder);{$ENDIF}
     isParsing := True;
     fDrive := ExtractDrive(Folder);
     {$IFDEF Debug}DebugForm.Debug('FFSHELL::fdrive:[' + fDrive + ']');{$ENDIF}
     if Length(fDrive) > 0 then begin
        if Copy(fDrive, 1, 2) = '\\' then begin
           SetCurrentFolderNetwork;
           {$IFDEF Debug}DebugForm.Debug('FFSHELL::ParseToDirectory:[' + Copy(Folder, 3, Length(Folder)) + ']');{$ENDIF}
           ParseToDirectory(Copy(Folder, 3, Length(Folder)));
           //ParseToStrItem(Copy(Folder, 3, Length(Folder)), False);
           end else begin
           SetCurrentFolderMyComputer;
           ParseToStrItem(Bs(fDrive), True);
           ParseToDirectory(Copy(Folder, 3, Length(Folder)));
           end;
        isParsing := False;
        if Assigned(OnChange) then OnChange(Self, Selected);
        if (Owner as TForm).Showing then SetFocus;
        end;
     end;

procedure TShellView.ParseToStrItem(iStr: string; Pure: boolean);
var
   hNode: TTreeNode;
   i: LongInt;
   cStr: string;
begin
     while isExpanding  do Application.ProcessMessages;
     hNode := Selected;
     {$IFDEF Debug}DebugForm.Debug('FFSHELL::ParseToStrItem(Selected):[' + Selected.Text + ']');{$ENDIF}
     if hNode <> nil then begin
        if not hNode.Expanded then hNode.Expand(False);
        for i:=0 to hNode.Count - 1 do begin
            if Pure then cStr := PCPidl(hNode[i].Data).u_name else cStr := PCPidl(hNode[i].Data).u_infolder;
            {$IFDEF Debug}DebugForm.Debug('FFSHELL::ParseToStrItem:[' + iStr + '---' + cStr + ']');{$ENDIF}
            if CompareText(iStr, cStr) = 0 then begin
               hNode[i].Expand(False);
               hNode[i].Selected := True;
               exit;
               end;
            end;
        end;
     end;

procedure TShellView.ParseToPidl(pidlObjExt: PItemIdList);
var
   hNode: TTreeNode;
   i: LongInt;
begin
     while isExpanding do Application.ProcessMessages;
     hNode := Selected;
     if hNode <> nil then begin
        if not hNode.Expanded then hNode.Expand(False);
        for i:=0 to hNode.Count - 1 do begin
            if PCPidl(hNode[i].Data)^.GetFolder.CompareIDs(0, pidlObjExt, PCPidl(hNode[i].Data).m_pidl) = 0 then begin
               hNode[i].Expand(False);
               hNode[i].Selected := True;
               exit;
               end;
            end;
        end;
     end;

procedure TShellView.ParseToFolder(pidlObjExt: PCPidl);
var
   hNode: TTreeNode;
   i: LongInt;
begin
     while isExpanding do Application.ProcessMessages;
     hNode := Selected;
     if hNode <> nil then begin
        if not hNode.Expanded then hNode.Expand(False);
        for i:=0 to hNode.Count - 1 do begin
            if pidlObjExt.GetFolder.CompareIDs(0, pidlObjExt.m_pidl, PCPidl(hNode[i].Data).m_pidl) = 0 then begin
               hNode[i].Expand(False);
               hNode[i].Selected := True;
               exit;
               end;
            end;
        end;
     end;

{constructor LUThread.Create(_ItemsList: TList; _ListView: TLIstView; _UpdatePointer: PLUThread);
begin
     ItemsList := _ItemsList;
     ListView := _ListView;
     Killed := False;
     FreeOnTerminate := True;
     UpdatePointer := _UpdatePointer;
     inherited Create(False);
     end;

procedure LUThread.Execute;
var
   i: integer;
begin
     for i:=0 to ItemsList.Count - 1 do begin
         ii := i;
         if Killed then break;
         Synchronize(NodeCreate);
         end;
     UpdatePointer^ := nil;
     end;

procedure LUThread.NodeCreate;
begin
     PCPidl(ItemsList[ii]).GetDisplayName(PCPidl(ItemsList[ii]).m_display, SHGDN_NORMAL);
     hPrev := ListView.Items.Add;
     with hPrev do begin
          Caption := PCPidl(ItemsList[ii]).m_display;
          Data := ItemsList[ii];
          end;
     CurrentPidlManager.SetNodeIcon(PCPidl(ItemsList[ii]), nil, hPrev, PCPidl(ItemsList[ii]).ulAttrs);
     end;

procedure LUThread.Kill;
begin
     Killed := True;
     end;}

procedure TShellView.Setdirectory(Value: string);
begin
     if (Directory <> Value) and DirectoryExists(Value) then begin
        // ParseToStrFolder(Value);
        TSDirThread.Create(Self, Value);
        end;
     end;

function TShellView.GetDirectory: string;
var
   aNode: TTreeNode;
begin
     aNode := Selected;
     if (aNode <> nil) and (aNode.Data <> nil) then begin
        Result := PCPidl(aNode.Data)^.u_name;
        end else Result := '';
     end;

procedure TShellView.SetFNonFolders(Value: boolean);
begin
     if FNonFolders <> Value then begin
        FNonFolders  := Value;
        end;
     end;


constructor TPopThread.Create(iShellView: TShellView; ipFolder: PShellFolder; ipidlQ: PItemIdList; ihParent: TTreeNode);
begin
     hParent := ihParent;
     if Assigned(hParent) and PCPidl(hParent.Data).u_populating then begin
        Release := True;
        exit;
        end;
     Release := False;
     ShellView := iShellView;
     Synchronize(AddToThreadsList);
     while ShellView.isExpanding do Application.ProcessMessages;
     if Application.Terminated then exit;
     ShellView.isExpanding := True;
     pFolder := ipFolder;
     pidlQ := iPidlQ;
     if Assigned(hParent) then PCPidl(hParent.Data).u_populating := True;
     inherited Create(False);
     while not Release and not Application.Terminated do Application.ProcessMessages;
     end;

procedure TPopThread.Execute;
begin
     try
     PopulateTreeNode(pFolder, pidlQ, hParent);
     if Assigned(hParent) then PCPidl(hParent.Data).u_populating := False;
     finally
     Synchronize(RemoveFromThreadsList);
     end;
     end;

procedure TShellView.UpdateNode(Node: TTreeNode);
begin
     {Node.Collapse(True);
     Node.DeleteChildren;}
     isCollapsing := False;
     isExpanding := False;
     CanChange(Node);
     Node.Expand(False);
     end;

procedure TShellView.Rebuild;
var
   CurNode: TTreeNode;
   PNode: TTreeNode;
begin
     PNode := Selected;
     Items.BeginUpdate;
     CurNode := Items.GetFirstNode;
     while Assigned(CurNode) and not Application.Terminated do begin
           RebuildNode(CurNode);
           CurNode := CurNode.GetNextSibling;
           end;
     if Assigned(PNode) then PNode.Selected := True;
     Items.EndUpdate;
     end;

procedure TShellView.RebuildNode(Node: TTreeNode);
var
   CurNode: TTreeNode;
begin
     if Node.Expanded then begin
        CurNode := Node.GetFirstChild;
        while Assigned(CurNode) and not Application.Terminated do begin
              RebuildNode(CurNode);
              CurNode := CurNode.GetNextSibling;
              end;
        Node.Collapse(False);
        UpdateNode(Node);
        Node.Selected := True;
        end;
     end;

procedure TShellView.ParseToStrNode(iStr: string; Node: TTreeNode);
begin
     Node := Node.GetFirstChild;
     while (Node <> nil) and not Application.Terminated do begin
           if CompareText(Node.Text, iStr) = 0 then begin
              Node.Selected := True;
              exit;
              end;
           Node := Node.GetNextSibling;
           end;
     end;

procedure TPopThread.AddToThreadsList;
begin
   if ShellView.ThreadsList <> nil then begin
      ShellView.ThreadsList.Add(self);
      end;
   end;

procedure TPopThread.RemoveFromThreadsList;
begin
   if ShellView.ThreadsList <> nil then begin
      ShellView.isExpanding := False;
      ShellView.ThreadsList.Remove(self);
      end;
   end;

procedure TSDirThread.AddToThreadsList;
begin
   if ShellView.ThreadsList <> nil then begin
      ShellView.ThreadsList.Add(self);
      end;
   end;

procedure TSDirThread.RemoveFromThreadsList;
begin
   if ShellView.ThreadsList <> nil then begin
      ShellView.isLooking := False;
      ShellView.ThreadsList.Remove(self);
      end;
   end;

procedure Register;
begin
     RegisterComponents('Win95', [TShellView])
     end;

end.
