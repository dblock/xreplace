unit TAdderThread;

interface

uses
  Classes, ComCtrls, FileCtrl, Controls, Forms, Dialogs, SysUtils, Buttons,
  WinTypes, Messages, MDlg, StatForm, ShellApi, StdCtrls, xrClasses, ShellView,
  PidlManager, TPicFile, TDropV, xreplace, d32gen, d32errors;

type
 {--- the multithread adder to the TDropView ---}

  MaskThread = class(TThread)
  private
     TreeDropView: TDropView;      {dropping target}
     Directory: string;
     Mask: string;
     Addflag: integer;
     ParentNode: tTreeNode;
     Recurse: boolean;

     sacParent: TTreeNode;
     sacCaption: string;
     sacType: NodeType;
     sacResult: TTreeNode;
     function RAddChild(iParent: TTreeNode; iCaption: string; iType: NodeType): TTreeNode;
     procedure SyncAddChild;
     procedure ErrorRaised;
     procedure Execute; override;
     procedure DropMask(iParent: TTreeNode; iDirectory, Mask: string; AddFlag: integer);
     function CreateLeaf(DirName: string; iNode: TTreeNode): TTreeNode;
     function CreateFileNode(FileName: string; iNode: TTreeNode): TTreeNode;
     procedure ThreadCounterDecrement;
  public
     constructor Create(TrDropView: TDropView; iParent: TTreeNode; iDirectory, iMask: string; iAddFlag: integer; iRecurse: boolean);
     end;

  AdderThread = class(TThread)
  private
     TreeDropView: TDropView;      {dropping target}
     Directory: string;
     FileList: TStringList;
     Mask: string;
     Recurse: boolean;

     sacParent: TTreeNode;
     sacCaption: string;
     sacType: NodeType;
     sacResult: TTreeNode;
     socDrive: string;
     socDriveResult: TTreeNode;
     function RAddChild(iParent: TTreeNode; iCaption: string; iType: NodeType): TTreeNode;
     procedure SyncAddChild;
     procedure SyncDrive;
     function CreateDriveMultithread(Drive: string): TTreeNode;
     procedure Cleanup(Node: TTreeNode);
     procedure Execute; override;
     procedure ErrorRaised;
  public
     constructor Create(TrDropView: TDropView; iDirectory, iMask: string; iFileList: TStringList; iRecurse: boolean);
     function CreateDrive(Drive: string): TTreeNode;
     function CreateNode(Directory, FileName: string): TTreeNode;
     function CreateDirectory(iDir: string; iNode: TTreeNode): TTreeNode;
     function CreateLeaf(DirName: string; iNode: TTreeNode): TTreeNode;
     function CreateFileNode(FileName: string; iNode: TTreeNode): TTreeNode;
     end;

  function StrIndexOf(Node: TTreeNode; Caption: string): TTreeNode;
  procedure DropDirectories(TreeDropView: TDropView; iParent: TTreeNode; iDirectory: string; Mask: string; Recurse: boolean);
  procedure DropFiles(TreeDropView: TDropView; iParent: TTreeNode; iDirectory: string; Mask: string; Recurse: boolean);

implementation

{const
   Attributes: array[0..5] of Word = (faReadOnly, faHidden, faSysFile, faArchive, faAnyFile, 0);}
var
   ThreadCounter: integer = 0;
   pStatus: string = 'Parallelizing... (experimental), please wait.';

constructor MaskThread.Create(TrDropView: TDropView; iParent: TTreeNode; iDirectory, iMask: string; iAddFlag: integer; iRecurse: boolean);
begin
     inc(ThreadCounter);
     Recurse:=iRecurse;
     TreeDropView:=TrDropView;
     Directory := iDirectory;
     Mask := iMask;
     AddFlag := iAddFlag;
     ParentNode:=iParent;
     Application.ProcessMessages;
     if xReplaceOptions.Gen.ParallelDragDrop then inherited Create(False) else Execute;
     //Execute;
     end;

procedure MaskThread.ErrorRaised;
begin
     MsgForm.MessageDlg('Unexpected runtime exception while selecting files.',
                        'XReplace-32 has raised an exception, this means an error has occured. '+
                        'Drag and drop operation is now being terminated.',
                        mtError,[mbCancel],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
     end;

procedure AdderThread.ErrorRaised;
begin
     MsgForm.MessageDlg('Unexpected runtime exception while selecting files.',
                        'XReplace-32 has raised an exception, this means an error has occured. '+
                        'Drag and drop operation is now being terminated.',
                        mtError,[mbCancel],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError));
     end;

procedure MaskThread.ThreadCounterDecrement;
begin
     dec(ThreadCounter);
     end;

procedure MaskThread.Execute;
begin
     try
     DropMask(ParentNode, Directory, Mask, AddFlag);
     Synchronize(ThreadCounterDecrement);
     if xReplaceOptions.Gen.ParallelDragDrop then TreeDropView.StatusVariant(pStatus + #13#10 + IntToStr(ThreadCounter) + ' thread(s).', True);
     except
        if not TreeDropView.InterruptDrop then begin
           TreeDropView.InterruptDrop := True;
           Synchronize(ErrorRaised);
           end;
     end;
     end;

procedure DropDirectories(TreeDropView: TDropView; iParent: TTreeNode; iDirectory: string; Mask: string; Recurse: boolean);
begin
     if TreeDropView.InterruptDrop or Application.Terminated then exit;
     MaskThread.Create(TreeDropView, iParent, iDirectory, Mask, faDirectory, Recurse);
     end;

procedure DropFiles(TreeDropView: TDropView; iParent: TTreeNode; iDirectory: string; Mask: string; Recurse: boolean);
begin
     if TreeDropView.InterruptDrop or Application.Terminated then exit;
     TreeDropView.Status('Parsing '+ Mask);
     MaskThread.Create(TreeDropView, iParent, iDirectory, Mask, 0, Recurse);
     end;

procedure MaskThread.DropMask(iParent: TTreeNode; iDirectory, Mask: string; AddFlag: integer);
var
   //AttrIndex: integer;
   MaskPtr: PChar;
   Ptr: PChar;
   //AttrWord: Word;
   FileInfo: TSearchRec;
   CurrentNode: TTreeNode;
   cnt: integer;
   ProcessMask: string;
   initCount: integer;
   FFiles: TStringList;
begin
     cnt := 0;
     TreeDropView.Status('Parsing '+ iDirectory);
     initCount := iParent.Count;
     FFiles := TStringList.Create;
     if AddFlag <> 0 then ProcessMask := '*.*' else ProcessMask := Mask;
     {
     AttrWord := DDL_READWRITE;
     for AttrIndex := 0 to 5 do AttrWord := AttrWord or Attributes[AttrIndex];
     AttrWord := AttrWord or AddFlag;
     }
     try
                MaskPtr := PChar(ProcessMask);
                while MaskPtr <> nil do begin
                      Ptr := StrScan (MaskPtr, ';');
                      if Ptr <> nil then Ptr^ := #0;
                      if Length(MaskPtr) > 0 then
                      if FindFirst(bs(iDirectory) + MaskPtr, {AttrWord}faAnyFile, FileInfo) = 0 then begin
                      repeat
                            inc(cnt);
                            if TreeDropView.InterruptDrop or Application.Terminated then exit;
                            //if (FileInfo.Attr and AttrWord <> 0) then
                               if (FileInfo.Attr and faDirectory) = 0 then begin
                                  if (AddFlag = 0) then begin
                                     if InitCount = 0 then RAddChild(iParent, FileInfo.Name, nFile)
                                                      else CreateFileNode(FileInfo.Name, iParent);
                                     FFiles.Add(FileInfo.Name);
                                     end;
                                  if ((Cnt > 500) or (ThreadCounter = 1)) and (xReplaceOptions.Gen.ParallelDragDrop) then TreeDropView.StatusVariant(pStatus + #13#10 + IntToStr(ThreadCounter) + ' thread(s).' + #13#10 + FileInfo.Name, True);
                                  end else begin
                                  if AddFlag <> 0 then
                                  if (FileInfo.Name <> '.') and (FileInfo.Name <> '..') then begin

                                     if InitCount = 0
                                        then CurrentNode := RAddChild(iParent, FileInfo.Name, nDirectory)
                                        else CurrentNode := CreateLeaf(FileInfo.Name, iParent);

                                     try
                                     if Recurse then DropDirectories(TreeDropView, CurrentNode, bs(iDirectory) + FileInfo.Name, Mask, Recurse);
                                     DropFiles(TreeDropView, CurrentNode, bs(iDirectory) + FileInfo.Name, Mask, Recurse);
                                     except
                                     if not TreeDropView.InterruptDrop then begin
                                        TreeDropView.InterruptDrop := True;
                                        Synchronize(ErrorRaised);
                                        end;
                                     end;
                                     end;
                                  end;
                      until FindNext(FileInfo) <> 0;
                      try SysUtils.FindClose(FileInfo); except end;
                end;
                if Ptr <> nil then begin
                   Ptr^ := ';';
                   Inc (Ptr);
                   end;
                MaskPtr := Ptr;
                end;
                finally
                end;
             end;

{--- multithread adderthread execution ------------------------------------------------}
procedure AdderThread.Cleanup(Node: TTreeNode);
var
   NextNode: TTreeNode;
begin
     while Node <> nil do begin
           NextNode := Node.GetNextSibling;
           if PRedirect(Node.Data)^.Ftype in [nDirectory, nDrive] then begin
              if (Node.HasChildren) then Cleanup(Node.GetFirstChild);
              if not (Node.HasChildren) then TreeDropView.NodeDeleteInternal(Node);
              end;
           Node := NextNode;
           end;
     end;

procedure AdderThread.Execute;
          procedure DropDirectory(iParent: TTreeNode; iDirectory: string);
          var
             CurrentNode: TTreeNode;
             FileDrive: string;
             oDirectory: string;
          begin
               oDirectory := iDirectory;
               if iParent = nil then begin
                  FileDrive := ExtractFileDrive(iDirectory);
                  Delete(iDirectory, 1, Length(FileDrive));
                  iParent := CreateDrive(FileDrive);
                  CurrentNode := CreateDirectory(iDirectory, iParent)
                  end else CurrentNode := CreateLeaf(ExtractFileName(iDirectory), iParent);
               try
               if Recurse then DropDirectories(TreeDropView, CurrentNode, oDirectory, Mask, Recurse);
               DropFiles(TreeDropView, CurrentNode, oDirectory, Mask, Recurse);
               except
               if not TreeDropView.InterruptDrop then begin
                  TreeDropView.InterruptDrop := True;
                  Synchronize(ErrorRaised);
                  end;
               end;
               end;

          procedure DropFromFileList(iParent: TTreeNode; iDirectory: string; FileList: TStringList);
          var
             i: integer;
          begin
               if iParent = nil then iParent := CreateNode(iDirectory, '');
               for i:=0 to FileList.Count - 1 do begin
                   if DirectoryExists(bs(iDirectory) + fileList[i]) then DropDirectory(nil, bs(iDirectory) + fileList[i])
                   else CreateFileNode(fileList[i], iParent);
                   end;
               end;

begin
   try
   if FileList <> nil then DropFromFileList(nil, Directory, FileList)
   else DropDirectory(nil, Directory);
   finally
   while ThreadCounter > 0 do Application.ProcessMessages;
   if xReplaceOptions.Gen.ParallelDragDrop then TreeDropView.StatusVariant('Cleaning up...', True) else TreeDropView.Status('Cleaning up...'); 
   Cleanup(TreeDropView.Items.GetFirstNode);
   if XReplaceOptions.gen.SortedTaggedList then begin
      TreeDropView.StatusVariant('Sorting...', True);
      TreeDropView.FileSort;
      end;
   TreeDropView.DropTerminated:=True;
   end;
   end;

procedure AdderThread.SyncDrive;
begin
     socDriveResult := CreateDriveMultithread(socDrive);
     end;

function AdderThread.CreateDrive(Drive: string): TTreeNode;
begin
     socDrive := Drive;
     Synchronize(SyncDrive);
     Result := socDriveResult;
     end;

function AdderThread.CreateDriveMultithread(Drive: string): TTreeNode;
begin
     with TreeDropView do begin
     Drive := bs(Drive);
     Result:=Items.GetFirstNode;
     while Result<>nil do begin
         if CompareText(Drive, Result.Text) = 0 then break;
         Result:=Result.GetNextSibling;
         end;
     if Result = nil then begin
        Result := RAdd(TreeDropView.Items.GetFirstNode, Drive, nDrive);
        Invalidate;
        end;
     end;
     end;

function StrIndexOf(Node: TTreeNode; Caption: string): TTreeNode;
{var
   aIndex: integer;}
begin
     {Node := Node.GetFirstChild;
     while Node <> nil do begin
           if Node.Text = Caption then begin
              Result := Node;
              exit;
              end;
           Node := Node.GetNextSibling;
           end;}

     Result := nil;
     Node := Node.GetLastchild;
     while Node <> nil do begin
           if Node.Text = Caption then begin
              Result := Node;
              exit;
              end;
           Node := Node.GetPrevSibling;
           end;
     {Result := nil;
     if (Node <> nil) then begin
        aIndex := PRedirect(Node.Data)^.Children.IndexOf(Caption);
        if aIndex <> -1 then Result := Node[aIndex];
        end;}
     end;

function AdderThread.CreateDirectory(iDir: string; iNode: TTreeNode): TTreeNode;
var
   FileName: string;
begin
   iDir := nBs(iDir);
   FileName := ExtractFileName(iDir);
   if (fileName <> iDir) and (Length(FileName) <> 0) then
      iNode := CreateDirectory(Copy(iDir, 1, Length(iDir) - Length(FileName)), iNode)
      else FileName := iDir;
   if Length(FileName) > 0 then begin
      Result := StrIndexOf(iNode, FileName);
      if Result = nil then Result := {TreeDropView.}RAddChild(iNode, FileName, nDirectory);
      end else Result := iNode;
   end;

function AdderThread.CreateFileNode(FileName: string; iNode: TTreeNode): TTreeNode;
begin
     Result := StrIndexOf(iNode, FileName);
     if Result = nil then
        Result := {TreeDropView.}RAddChild(iNode, FileName, nFile);
     end;

function MaskThread.CreateFileNode(FileName: string; iNode: TTreeNode): TTreeNode;
begin
     Result := StrIndexOf(iNode, FileName);
     if Result = nil then
        Result := {TreeDropView.}RAddChild(iNode, FileName, nFile);
     end;

function MaskThread.CreateLeaf(DirName: string; iNode: TTreeNode): TTreeNode;
begin
     Result := StrIndexOf(iNode, DirName);
     if Result = nil then Result := {TreeDropView.}RAddChild(iNode, DirName, nDirectory);
     end;

function AdderThread.CreateLeaf(DirName: string; iNode: TTreeNode): TTreeNode;
begin
     Result := StrIndexOf(iNode, DirName);
     if Result = nil then Result := {TreeDropView.}RAddChild(iNode, DirName, nDirectory);
     end;

function AdderThread.CreateNode(Directory, FileName: string): TTreeNode;
var
   FileDrive: string;
   FileDriveNode: TTreeNode;
begin
     FileDrive := ExtractFileDrive(Directory);
     Delete(Directory, 1, Length(FileDrive));
     FileDriveNode := CreateDrive(FileDrive);
     Result := CreateDirectory(Directory, FileDriveNode);
     if Length(FileName) > 0 then Result := CreateFileNode(FileName, Result);
     end;

constructor AdderThread.Create(TrDropView: TDropView; iDirectory, iMask: string; iFileList: TStringList; iRecurse: boolean);
begin
     Recurse := iRecurse;
     TreeDropView:=TRDropView;
     Directory := iDirectory;
     FileList := iFileList;
     Mask :=  iMask;
     if xReplaceOptions.Gen.ParallelDragDrop then TreeDropView.StatusVariant(pStatus, True);
     inherited Create(False);
     //Execute;
     end;

function MaskThread.RAddChild(iParent: TTreeNode; iCaption: string; iType: NodeType): TTreeNode;
begin
     sacParent := iParent;
     sacCaption := iCaption;
     sacType := iType;
     Synchronize(SyncAddChild);
     result := sacResult;
     end;

procedure MaskThread.SyncAddChild;
begin
     sacResult := TreeDropView.RAddChild(sacParent, sacCaption, sacType);
     end;

function AdderThread.RAddChild(iParent: TTreeNode; iCaption: string; iType: NodeType): TTreeNode;
begin
     sacParent := iParent;
     sacCaption := iCaption;
     sacType := iType;
     Synchronize(SyncAddChild);
     result := sacResult;
     end;

procedure AdderThread.SyncAddChild;
begin
     sacResult := TreeDropView.RAddChild(sacParent, sacCaption, sacType);
     end;



end.
