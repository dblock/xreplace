unit d32gen;

interface

uses Controls, ShlObj, ExtCtrls, SysUtils, WinProcs, Graphics, ShellApi, Forms, Menus;

   function StrToBool(Value: string): boolean;
   function BoolToBool(BoolValue : boolean): string;
   function BoolToStr(BoolValue : boolean): string;
   function BoolToInt(BoolValue: boolean): integer;
   function BS(iStr: string): string;
   function nBs(iStr: string): string;
   function GS(iStr: string): string;
   function GetWindowsDir: string;
   function GetSystemDir: string;
   function GetComputerNm: string;
   function ExtractAnIcon(FileName: string; TargetList1, TargetList2: TImageList): integer;
   function UserName: string;
   function PreviousInstance(FSendMsg: string): boolean;
   function GetSpecialFolder(id: integer): string;
   function GetPidlFolder(Pidl: PItemIdList): string;
   function StrPCopyMalloc(Dest: PChar; Source: string): PChar;
   function GetFileTypeExec(Ext: string): String;
   function GetFileTypeName(Ext: string): String;
   function ExtractDrive(Value: string): string;
   procedure ExtractImageIcon(FileName: string; TargetImage: tImage);
   procedure AppendToSystemMenu (Form: TForm; Item: string; ItemID: word);
   procedure AppendMenuPopup(Target, Source: TPopupMenu);
   procedure RemoveFileDirectory(iFile: PChar);

var
   NT351: boolean;                           {NT 3.5x does not support ExtractAssociatedIcon}
   DesktopFolderPath: string;
   WindowsDir: string;
   SystemDir: string;
   ComputerName: string;
   TempPath: string;

implementation

uses d32reg;

procedure RemoveFileDirectory(iFile: PChar);
begin
     if not DeleteFile(iFile) then RemoveDirectory(PChar(iFile));
     end;

function StrToBool(Value: string): boolean;
begin
     if CompareText(Value, 'True') = 0 then Result := True
     else if CompareText(Value, 'False') = 0 then Result := False
     else Result:=True;
     end;

function BoolToBool(BoolValue: boolean): string;
begin
   if BoolValue=True then BoolToBool:='Yes' else BoolToBool:='No';
   end;

function BoolToStr(BoolValue : boolean): string;
begin
   if BoolValue=True then BoolToStr:='True' else BoolToStr:='False';
   end;

function BoolToInt(BoolValue: boolean): integer;
begin
     if BoolValue then Result:=1 else Result:=0;
     end;

function BS(iStr: string): string;
begin
     if Length(iStr) > 0 then begin
        if iStr[Length(iStr)] <> '\' then Result := iStr + '\' else Result := iStr;
        end else Result := '\';
     end;

function nBS(iStr: string): string;
begin
     if Length(iStr) > 0 then if iStr[Length(iStr)] = '\' then Delete(iStr, Length(iStr), 1);
     Result := iStr;
     end;

function GetSystemDir: string;
var
   WD: PChar;
begin
     WD := StrAlloc(1024);
     if (GetSystemDirectory(WD, 1024) = 0) then Result:='' else Result := Bs(WD);
     end;

function GetWindowsDir: string;
var
   WD: PChar;
begin
     WD := StrAlloc(1024);
     if (GetWindowsDirectory(WD, 1024) = 0) then Result:='' else Result := Bs(WD);
     end;

function GetComputerNm: string;
var
   WD: PChar;
const
   cS: DWORD = 1024;
begin
     WD := StrAlloc(cS);
     if (GetComputerName(WD, cS) = FALSE) then Result:='This computer' else Result := WD;
     end;

function GS(iStr: string): string;
begin
     iStr := Trim(iStr);
     if iStr[1] <> '"' then Result := '"'+iStr+'"' else Result:=iStr;
     end;

function TrimFull(iStr: string): string;
begin
     if Length(iStr) = 0 then Result := '' else begin
     while (iStr[1] < ' ') and (Length(iStr) > 0) do Delete(iStr, 1, 1);
     while (iStr[Length(iStr)] < ' ') and (Length(iStr) > 0) do Delete(iStr, Length(iStr), 1);
     Result := iStr;
     end;
     end;


function ExtractAnIcon(FileName: string; TargetList1, TargetList2: TImageList): integer;
var
   aIcon: TIcon;
   IconIndex: WORD;
   Icon: hIcon;
   lIndex: integer;
   PFName: PChar;

           function AddIconToList(TargetList: TImageList): integer;
           begin
                Result := TargetList.addIcon(aIcon);
                end;
begin
     PFName := StrAlloc(MAX_PATH);
     StrPCopy(PFName, FileName);
     Icon := ShellApi.ExtractAssociatedIcon(Application.Handle, PFName, IconIndex);
     if (Icon <> 0) then begin
        aIcon := TIcon.Create;
        aIcon.Handle := Icon;
        if TargetList1 <> nil then lIndex := AddIconToList(TargetList1) else lIndex := -1;
        if TargetList2 <> nil then lIndex := AddIconToList(TargetList2);
        Result:=lIndex;
        end else Result:= -1;
     end;

procedure ExtractImageIcon(FileName: string; TargetImage: TImage);
var
   aIcon: TIcon;
   IconIndex: WORD;
   Icon: hIcon;
   PFName: PChar;
begin
     PFName := StrAlloc(MAX_PATH);
     StrPCopy(PFName, FileName);
     Icon := ShellApi.ExtractAssociatedIcon(Application.Handle,PFName, IconIndex);
     if (Icon <> 0) then begin
        aIcon := TIcon.Create;
        aIcon.Handle := Icon;
        if TargeTImage <> nil then TargetImage.Picture.Icon := aIcon;
        end;
     end;

function UserName: string;
var
   PUserName: PChar;
   nSize: dword;
begin
     nSize := 255;
     PUserName:=StrAlloc(nSize);
     while not GetUserName(PUserName, nSize) do Application.ProcessMessages;
     Result:=PUserName;
     end;

function PreviousInstance(FSendMsg: string): boolean;
var
  FMessageID: dword;
  hMapping: HWND;
  tmp: PChar;
begin
     Result:=False;
     GetMem(tmp, Length(FSendMsg) + 1);
     StrPCopy(tmp, FSendMsg);
     FMessageID := RegisterWindowMessage(tmp);
     FreeMem(tmp);
     hMapping := CreateFileMapping(HWND($FFFFFFFF), nil, PAGE_READONLY, 0, 32, 'JustOne Map');
  if (hMapping <> NULL) and (GetLastError <> 0) then
  begin
      PostMessage(hwnd_Broadcast, FMessageID, 0, 0);
      Result:=True;
      end;
end;

function GetSpecialFolder(id: integer): string;
var
   ppild: PItemIDList;
   szPath: PChar;
begin
     szPath := StrAlloc(MAX_PATH);
     SHGetSpecialFolderLocation(Application.Handle, id, ppild);
     SHGetPathFromIDList(ppild, szPath);
     Result := bs(szPath);
     end;

function GetPidlFolder(pidl: PItemIdList): string;
var
   szPath: PChar;
begin
     szPath := StrAlloc(MAX_PATH);
     SHGetPathFromIDLIST(pidl, szPath);
     Result := bs(szPath);
     end;

function StrPCopyMalloc(Dest: PChar; Source: string): PChar;
begin
     StrDispose(Dest);
     Dest := StrAlloc(Length(Source));
     Result := StrPCopy(Dest, Source);
     end;

function GetFileTypeName(Ext: string): string;
begin
     Result := QueryReg(HKEY_CLASSES_ROOT, Ext, '');
     if Result  <> '-1' then Result  := QueryReg(HKEY_CLASSES_ROOT, Result , '');
     if Result  = '-1' then Result  := Ext + ' file';
     end;

function GetFileTypeExec(ext: string): string;
var
   TmpDocument: PChar;
   TargetStr : PChar;
   TmpDocumentExt: string;
begin
     Result := '';
     TmpDocument := StrAlloc(MAX_PATH);
     if GetTempFileName(PChar(TempPath), 'ext', 0, TmpDocument) <> 0 then begin
        TmpDocumentExt := ChangeFileExt(TmpDocument, Ext);
        RenameFile(TmpDocument, TmpDocumentExt);
        TargetStr := Stralloc(MAX_PATH);
        if FindExecutable(PChar(TmpDocumentExt),PChar(ExtractFileDir(Application.ExeName)), TargetStr) > 32 then begin
           Result := TargetStr;
           if not FileExists(Result) then Result:='';
           end;
        DeleteFile(PChar(TmpDocumentExt));
        end;
     end;


function ExtractDrive(Value: string): string;
          var
             i, j: integer;
          begin
               if Copy(Value, 1, 2) = '\\' then begin
                  i := Pos('\', Copy(Value, 3, Length(Value)));
                  if i <> 0 then begin
                     Result := Copy(Value, 3 + i, Length(Value));
                     j := Pos('\', Result);
                     if j <> 0 then begin
                        Result := Copy(Value, 1, 2 + i) + Copy(Result, 1, j - 1);
                        end else Result := Value;
                     end else Result := '';
               end else if Value[2] = ':' then begin
                  if Value[3] = '\' then Result := Copy(Value, 1, 2) else Result := Value;
                  end else Result := '';
               end;

function IsNt351:boolean;
var
   VersionInfo: TOsVersionInfo;
begin
   VersionInfo.dwOsVersionInfoSize:=sizeof(TOsVersionInfo);
   if (GetVersionEx(VersionInfo)=false) then begin
      Result:=True;
      exit;
      end;
  if (VersionInfo.dwMajorVersion=3) and  {NT 3.x}
     (VersionInfo.dwPlatformId=2) and    {Windows NT}
     ((VersionInfo.dwMinorVersion=51) or {3.5 or 3.51}
     (VersionInfo.dwMinorVersion=50)) then Result:=True else Result:=False;
   end;

procedure AppendToSystemMenu (Form: TForm; Item: string; ItemID: word);
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

procedure AppendMenuPopup(Target, Source: TPopupMenu);
var
   i: integer;
   NewItem: TMenuItem;
begin
     NewItem := TMenuItem.Create(Target);
     NewItem.Caption := '-';
     Target.Items.Add(NewItem);
     for i:=0 to Source.Items.Count - 1 do begin
         NewItem := TMenuItem.Create(Target);
         with NewItem do begin
              Caption := Source.Items[i].Caption;
              OnClick := Source.Items[i].OnClick;
              end;
         Target.Items.Add(NewItem);
         end;
     end;


var
   CTempPath: PChar;
begin
     WindowsDir := GetWindowsDir;
     SystemDir := GetSystemDir;
     ComputerName := GetComputerNm;
     CTempPath:=StrAlloc(MAX_PATH);
     GetTempPath(MAX_PATH, CTempPath);
     TempPath := BS(CTempPath);
     NT351 := isNT351;
     end.

