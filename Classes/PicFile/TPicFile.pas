unit TPicFile;
(*
                 TPicFile Component (Object Pascal - Delphi 2.0)
                           (c) Daniel Doubrovkine
  Stolen Technologies Inc. - University of Geneva - 1996 - All Rights Reserved
                       for XReplace-32, version 1.8

                   e-mail welcome: dblock@infomaniak.ch
                        no warranty of any kind
*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ShellApi, d32errors, ComCtrls, d32gen;

type

  PPFBThread = ^TPFBThread;
  TPFBThread = class;

  TPicFileListBox = class(TFileListBox)
  private
     procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
     procedure SetSafeDirectory(Value: string);
     procedure Loaded; override;
  protected
     PFBThread: TPFBThread;
     procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
     procedure PaintListBox(var Message: TWMPaint);
  public
     function isReading: boolean;
     constructor Create(AOwner: TComponent);  override;
     destructor Destroy; override;
     procedure PublicUpdate;
     property Directory: string read FDirectory write SetSafeDirectory;
     property SafeDirectory: string read FDirectory write SetSafeDirectory;
     procedure ReadfileNames; override;
     procedure Abort;
     end;

  TPFBThread = class(TThread)
  public
     procedure Kill;
     constructor Create(_TPFBOwner: TPicFileListBox; _TPFBPointer: PPFBThread);
     procedure Execute; override;
  private
     zList: TStringList;
     Killed: boolean;
     Reading: boolean;
     TPFBOwner: TPicFileListBox;
     TPFBPointer: PPFBThread;
     PFCaption: string;
     PFIcon: pointer;
     //procedure Sort;
     procedure AddObjectGeneral;
     procedure AddObject;
     function AddObjectFirst: integer;
     procedure Clear;
     procedure ReadDirectories;
     procedure ReadFileNames;
     end;

procedure Register;

implementation

uses PidlManager;

const
   Attributes: array[TFileAttr] of Word = (faReadOnly, faHidden, faSysFile, faVolumeID, faDirectory, faArchive, 0);

procedure TPicFileListBox.Abort;
begin
   if PFBThread <> nil then begin
      PFBThread.Kill;
      PFBThread.WaitFor;
      end;
   end;

destructor TPicFileListBox.Destroy;
begin
   inherited;
   Abort;
   end;

procedure TPicFileListBox.ReadfileNames;
begin
     exit;
     end;

procedure tPicFileListBox.Loaded;
begin
     inherited;
     //PublicUpdate;
     end;


function tPicFileListBox.isReading: boolean;
begin
     if PFBThread = nil then Result := False
     else Result := PFBThread.Reading;
     end;

procedure tPicFileListBox.PublicUpdate;
begin
     Abort;
     if (not Application.Terminated) then begin
      PFBThread := TPFBThread.Create(Self, @PFBThread);
      end;
     end;

procedure TPicFileListBox.SetSafeDirectory(Value: string);
begin
     if (FDirectory <> Value) and (DirectoryExists(Value)) then begin
        FDirectory := Value;
        ChDir(FDirectory); { go to the directory we want }
        PublicUpdate;
        end;
     end;

procedure Register;
begin
   RegisterComponents('Samples', [TPicFileListBox]);
   end;

constructor TPicFileListBox.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Sorted := False;
   end;

procedure TPicFileListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  offset: Integer;
  dc: HDC;
  Rgn: HRGN;
begin
  if Nt351 then inherited else begin
    dc := Canvas.Handle; //GetDc(Self.Handle);
    Rgn := CreateRectRgn(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
    SelectObject(dc, Canvas.Brush.Handle);
    SetBkMode(dc, TRANSPARENT);
    PaintRgn(dc, Rgn);
    if ShowGlyphs then begin
      offset:=Rect.bottom-Rect.top+3;
      try if Items.Objects[Index] <> nil then DrawIconEx(dc, Rect.Left+2, Rect.Top, TIcon(Items.Objects[Index]).Handle, Rect.Bottom-Rect.Top-2, Rect.Bottom-Rect.Top-2, 0, Canvas.Brush.Handle, DI_NORMAL); except end;
      end else offset := 0;

  SelectObject(dc, Canvas.Font.Handle);
  Rect.Left := Rect.Left + offset;
  try DrawText(dc, PChar(Items[Index]), -1, Rect, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX); except end;
  end;
  end;

procedure TPFBThread.ReadFileNames;
var
  AttrIndex: TFileAttr;
  FileExt: string;
  MaskPtr: PChar;
  Ptr: PChar;
  AttrWord: Word;
  FileInfo: TSearchRec;
  iStr: PChar;
  Icon: hIcon;
  IconIndex: word;
  aIcon: TIcon;
begin
  AttrWord := DDL_READWRITE;
  with TPFBOwner do
  if HandleAllocated then begin
     for AttrIndex := ftReadOnly to ftArchive do if AttrIndex in FileType then AttrWord := AttrWord or Attributes[AttrIndex];
     try
      MaskPtr := PChar(FMask);
      while MaskPtr <> nil do begin
        if Killed then break;
        Ptr := StrScan (MaskPtr, ';');
        if Ptr <> nil then Ptr^ := #0;
        if FindFirst(MaskPtr, AttrWord, FileInfo) = 0 then begin
          repeat
            if Killed then break;
            if not Showing then Application.ProcessMessages;
            if (ftNormal in FileType) or (FileInfo.Attr and AttrWord <> 0) then
              if (FileInfo.Attr and faDirectory) = 0 then begin
                FileExt := AnsiLowerCase(ExtractFileExt(FileInfo.Name));
                if NT351 then begin
                   PFCaption := FileInfo.Name;
                   PFIcon := CurrentPidlManager.shUnknownIcon;
                   //Synchronize(AddObject);
                   AddObjectGeneral;
                   end else begin
                   iStr := StrAlloc(MAX_PATH);
                   StrPCopy(iStr, bs(Directory) + FileInfo.Name);
                   Icon := ExtractAssociatedIcon(HINSTANCE, iStr, IconIndex);
                   aIcon := TIcon.Create;
                   aIcon.Handle := Icon;
                   StrDispose(iStr);
                   PFCaption := FileInfo.Name;
                   PFIcon := aIcon;
                   //Synchronize(AddObject);
                   AddObjectGeneral;
                   end;
                end;
          until FindNext(FileInfo) <> 0;
          FindClose(FileInfo);
        end;
        if Ptr <> nil then begin
          Ptr^ := ';';
          Inc (Ptr);
          end;
        MaskPtr := Ptr;
      end;
    finally
    end;
    Change;
  end;
  end;

procedure TPFBThread.ReadDirectories;
var
  AttrIndex: TFileAttr;
  AttrWord: Word;
  FileInfo: TSearchRec;
begin
  AttrWord := DDL_READWRITE;
  with TPFBOwner do begin
    for AttrIndex := ftReadOnly to ftArchive do if AttrIndex in FileType then AttrWord := AttrWord or Attributes[AttrIndex];
    try
        if FindFirst('*.*', AttrWord, FileInfo) = 0 then begin
          repeat
            if Killed then break;
            if (ftNormal in FileType) or (FileInfo.Attr and AttrWord <> 0) then
              if FileInfo.Attr and faDirectory <> 0 then
                if (FileInfo.Name <> '.') and (FileInfo.Name <> '..') then begin
                   PFCaption := FileInfo.Name;
                   PFIcon := CurrentPidlManager.shFolderIcon;
                   //Synchronize(AddObject);
                   AddObjectGeneral;
                   end;
          until FindNext(FileInfo) <> 0;
          FindClose(FileInfo);
        end;
    finally
    end;
    Change;
    end;
    end;

constructor TPFBThread.Create(_TPFBOwner: TPicFileListBox; _TPFBPointer: PPFBThread);
begin
     Killed := False;
     TPFBOwner := _TPFBOwner;
     TPFBPointer := _TPFBPointer;
     Reading := True;
     inherited Create(False);
     end;

procedure TPFBThread.Clear;
begin
     TPFBOwner.Clear;
     end;

{procedure TPFBThread.Sort;
  procedure QuickSort(a: TStrings; lo, hi: integer);
     procedure Sort(l, r: Integer);
        function Less(i,j: integer):boolean;
        begin
           Result := a[i] < a[j];  
           end;
     var
        i, j, x: integer;
     begin
          i := l; j := r; x := (l+r) DIV 2;
          repeat
                while Less(i, x) do i := i + 1;
                while Less(x, j) do j := j - 1;
                if i <= j then begin
                   a.Exchange(i, j);
                   i := i + 1; j := j - 1;
                   end;
             until i > j;
          if l < j then Sort(l, j);
          if i < r then Sort(i, r);
          end;
    begin
         Sort(Lo,Hi);
    end;

begin
     QuickSort(TPFBOwner.Items, 0, TPFBOwner.Items.Count - 1);
     end;}

procedure TPFBThread.Execute;
begin
     if Killed then exit;
     Synchronize(Clear);
     zList := TStringList.Create;
     if not Killed then ReadFileNames;
     Synchronize(AddObject);
     TPFBOwner.Update;
     TPFBOwner.Items.BeginUpdate;
     zList.Clear;
     if not Killed then ReadDirectories;
     Synchronize(AddObject);
     zList.Clear;
     TPFBOwner.Invalidate;
     TPFBPointer^ := nil;
     if (TPFBOwner.Items.Count = 0) then TPFBOwner.Canvas.TextOut(5, 5, '[none]');
     TPFBOwner.Items.EndUpdate;
     Reading := False;
     end;

procedure TPFBThread.AddObjectGeneral;
begin
     if zList.Count > 100 then TPFBOwner.Canvas.TextOut(5, 5, 'Working...');
     zList.InsertObject(AddObjectFirst, PFCaption, PFIcon);
     end;

function TPFBThread.AddObjectFirst: integer;
var
  i: integer;
begin
     for i := 0 to zList.Count - 1 do
         if CompareText(zList[i], PFCaption) > 0 then begin
            //if (PFIcon = zList.Objects[i]) or (PFIcon <> CurrentPidlManager.shFolderIcon) then begin
            Result := i;
            exit;
            end;
     Result := zList.Count;
     end;

procedure TPFBThread.AddObject;
var
   i, cnt: integer;
begin
     cnt := TPFBOwner.Items.Count;
     for i:=zList.Count - 1 downto 0 do TPFBOwner.Items.InsertObject(cnt, zList[i], zList.Objects[i]);
     end;

procedure TPFBThread.Kill;
begin
     Killed := True;
     end;

{procedure TPicFileListBox.WMPaint(var Message: TWMPaint);
begin
     inherited;
     if (Items.Count = 0) and (PFBThread = nil) then Canvas.TextOut(5, 5, '[none]');
     end;}

procedure TPicFileListBox.PaintListBox(var Message: TWMPaint);
var
    DrawItemMsg: TWMDrawItem;
    MeasureItemMsg: TWMMeasureItem;
    DrawItemStruct: TDrawItemStruct;
    MeasureItemStruct: TMeasureItemStruct;
    R: TRect;
    I, Y, H, W: Integer;
  begin
    { Initialize drawing records }
    DrawItemMsg.Msg := CN_DRAWITEM;
    DrawItemMsg.DrawItemStruct := @DrawItemStruct;
    DrawItemMsg.Ctl := Handle;
    DrawItemStruct.CtlType := ODT_LISTBOX;
    DrawItemStruct.itemAction := ODA_DRAWENTIRE;
    DrawItemStruct.itemState := 0;
    DrawItemStruct.hDC := Message.DC;
    DrawItemStruct.CtlID := Handle;
    DrawItemStruct.hwndItem := Handle;

    { Intialize measure records }
    MeasureItemMsg.Msg := CN_MEASUREITEM;
    MeasureItemMsg.IDCtl := Handle;
    MeasureItemMsg.MeasureItemStruct := @MeasureItemStruct;
    MeasureItemStruct.CtlType := ODT_LISTBOX;
    MeasureItemStruct.CtlID := Handle;

    { Draw the listbox }
    Y := 0;
    I := TopIndex;
    GetClipBox(Message.DC, R);
    H := Height;
    W := Width;
    while Y < H do begin
      MeasureItemStruct.itemID := I;
      if I < Items.Count then
        MeasureItemStruct.itemData := Longint(Pointer(Items.Objects[I]));
      MeasureItemStruct.itemWidth := W;
      MeasureItem(I, Integer(MeasureItemStruct.itemHeight));
      DrawItemStruct.itemData := MeasureItemStruct.itemData;
      DrawItemStruct.itemID := I;
      Dispatch(MeasureItemMsg);
      DrawItemStruct.rcItem := Rect(0, Y, MeasureItemStruct.itemWidth,
        Y + Integer(MeasureItemStruct.itemHeight));
      Dispatch(DrawItemMsg);
      Inc(Y, MeasureItemStruct.itemHeight);
      Inc(I);
      if I >= Items.Count then break;
    end;
  end;

procedure TPicFileListBox.WMPaint(var Message: TWMPaint);
begin
  if Message.DC <> 0 then begin
     PaintListBox(Message);
     end else inherited;
  if (Items.Count = 0) and (PFBThread = nil) then Canvas.TextOut(5, 5, '[none]');
  end;

end.
