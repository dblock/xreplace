unit CPidl;

interface

uses ShlObj, RegStr, WinProcs, SysUtils, ShellApi, Dialogs, activex, ComCtrls;

type

    TCPidlException = class(Exception);
    LPItemIdList = ^PItemIdList;
    PShellFolder = ^IShellFolder;

    PCPidl = ^TCPidl;
    TCPidl = class
        private
           m_QualifiedPidl: PItemIdList;
           m_pFolder: PShellFolder;
        public
           u_populating: boolean;
           u_node: TTreeNode;
           u_validated: boolean;
           u_infolder: string;
           u_name: string;
           m_pidl: PItemIdList;
           m_display: string;
           ulAttrs: UINT;
           function GetPidlCopy: PItemIdList;
           function GetSize(pidl: PItemIdList): integer;
           function GetNormalIcon: integer;
           function GetFileAttribs: DWORD;
           function GetSelectedIcon: integer;
           function GetDisplayName(var strName: string; dwFlags: DWORD): boolean;
           function GetExpandedPidl(var strName: string): PItemIdList;
           function GetFolder: PShellFolder;
           function Copy(pidl: PItemIdList): boolean;
           function Concat(pidl: PItemIdList): boolean;
           destructor Destroy; override;
           constructor Create(pidl: PItemIdList; pFolder: PShellfolder);
           function eCreate(cbSize: integer; ppidl: LPItemIdList): boolean;
           function SetQualifiedPidl(pidl: PItemIdList): boolean;
	   function GetQualifiedPidl: PItemIdList;
           end;

implementation

constructor TCPidl.Create(pidl: PItemIdList; pFolder: PShellfolder);
begin
     m_pidl := nil;
     if pidl <> nil then Copy(pidl);
     m_QualifiedPidl := nil;
     m_pFolder := pFolder;
     u_populating := False;
     //if pFolder <> nil then pFolder.AddRef;
     end;

function TCPidl.eCreate(cbSize: integer; ppidl: LPItemIdList): boolean;
var
   pMalloc: IMalloc;
   hr: hResult;
   WorkPidl: LPItemIdList;
begin
     if cbSize <= 0 then TCPidlException.Create('TCPidl::zero cbSize');
     WorkPidl := @m_pidl;
     if (ppidl <> nil) then WorkPidl := ppidl;
     hr := CoGetMalloc(MEMCTX_TASK, pMalloc);
     if (FAILED(hr)) then Result := False else begin
        if (WorkPidl^ <> nil) then pMalloc.Free(WorkPidl^);
        WorkPidl^ := PItemIdList(pMalloc.Alloc(cbSize));
        if (WorkPidl^ <> nil) then ZeroMemory(WorkPidl^, cbSize);
        // if (pMalloc <> nil) then pMalloc.Release;
        result := WorkPidl^ <> nil;
        end;
     end;

destructor TCPidl.Destroy;
var
   pMalloc: IMalloc;
   hr: HResult;
begin
   //if (m_pFolder <> nil) then m_pFolder.Release;
   hr := CoGetMalloc(MEMCTX_TASK, pMalloc);
   if (FAILED(hr)) then TCPidlException.Create('TCPidl::not enough memory');
   if (m_pidl <> nil) then pMalloc.Free(m_pidl);
   if (m_QualifiedPidl <> nil) then pMalloc.Free(m_QualifiedPidl);
   end;

function TCPidl.GetSize(pidl: PItemIdList): integer;
var
   cbTotal: integer;
   pMem: PChar;
begin
     cbTotal := 0;
     if pidl = nil then pidl := m_pidl;
     if pidl <> nil then begin
        cbTotal := cbTotal + sizeof(pidl^.mkid.cb);
        pMem := PChar(pidl);
        while (pidl^.mkid.cb <> 0) do begin
           cbTotal := cbTotal + pidl^.mkid.cb;
           pMem := pMem + pidl^.mkid.cb;
           pidl := PItemIdList(pMem);
           end;
        end;
     Result := cbTotal;
     end;

function TCPidl.GetPidlCopy: PItemIdList;
var
   cbTotal: integer;
begin
     cbTotal := m_pidl^.mkid.cb + sizeof(m_pidl^.mkid.cb);
     if eCreate(cbTotal, @Result) then begin
        CopyMemory(Result, m_pidl, cbTotal);
        end else Result := nil;
     end;

function TCPidl.Copy(pidl: PItemIdList): boolean;
var
   cbTotal: UINT;
begin
     if pidl = nil then TCPidlException.Create('TCPidl::Copy:nil pidl');
     cbTotal := pidl^.mkid.cb + sizeof(pidl^.mkid.cb);
     if eCreate(cbTotal, nil) then begin
        CopyMemory(m_pidl, pidl, cbTotal);
        Result := True;
        end else Result := False;
     end;

function TCPidl.Concat(pidl: PItemIdList): boolean;
var
   cb1, cb2: integer;
   CurPidl: TCPidl;
begin
     if pidl = nil then TCPidlException.Create('TCPidl::Copy:nil pidl');
     cb1 := GetSize(nil);
     cb2 := GetSize(pidl);
     CurPidl := TCPidl.Create(m_pidl, @m_pFolder);
     if (eCreate(cb1 + cb2, nil)) then begin
        CopyMemory(m_pidl, PItemIdList(CurPidl), cb1);
        CopyMemory(PChar(m_pidl) + cb1, pidl, cb2);
        Result := True;
        end else Result := False;
     end;

function TCPidl.GetNormalIcon: integer;
var
   sfi: TSHFileInfo;
begin
     SHGetFileInfo(PChar(m_pidl), 0, sfi, sizeof(TSHFILEINFO), SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
     Result := sfi.hIcon;
     end;

function TCPidl.GetFileAttribs: DWORD;
var
   sfi: TSHFileInfo;
begin
     SHGetFileInfo(PChar(m_pidl), 0, sfi, sizeof(TSHFILEINFO), SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
     Result := sfi.dwAttributes;
     end;

function TCPidl.GetSelectedIcon: integer;
var
   sfi: TSHFileInfo;
begin
     SHGetFileInfo(PChar(m_pidl), 0, sfi, sizeof(TSHFILEINFO), SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_OPENICON);
     Result := sfi.hIcon;
     end;

function TCPidl.GetDisplayName(var strName: string; dwFlags: DWORD): boolean;
         function StrRetToString(pidl: PItemIdList; lpStr: TStrRet): string;
         var
            wPath: PWideChar;
         begin
         case lpStr.uType of
		STRRET_WSTR: begin
                             wPath := lpStr.pOleStr;
                             Result := WideCharToString(wPath);
                             end;
		STRRET_OFFSET: Result := PChar(PChar(pidl) + lpStr.uOffset);
		STRRET_CSTR: begin
                             wPath := AllocMem(Sizeof(WideChar) * MAX_PATH);
                             MultiByteToWideChar(CP_ACP,0,lpStr.cStr,-1, wPath, MAX_PATH);
                             Result := WideCharToString(wPath);
                             FreeMem(wPath, Sizeof(WideChar) * MAX_PATH);
                             end;
		else Result := '';
                end;
                end;

var
   lpStr: TStrRet;
begin
     if (m_pFolder.GetDisplayNameOf(m_pidl, SHGDN_INFOLDER, lpStr) = NOERROR) then begin
        u_infolder := StrRetToString(m_pidl, lpStr);
        end;
     if (m_pFolder.GetDisplayNameOf(m_pidl, SHGDN_FORPARSING, lpStr) = NOERROR) then begin
        u_name := StrRetToString(m_pidl, lpStr);
        end;
     if (m_pFolder.GetDisplayNameOf(m_pidl, dwFlags, lpStr) = NOERROR) then begin
        strName := StrRetToString(m_pidl, lpStr);
        Result := True;
        end else Result := False;
     m_display := strName;
     end;

function TCPidl.GetExpandedPidl(var StrName: string): PItemIdList;
         function S2Ole(Str: string): PWideChar;
         var
            iRes: PWideChar;
         begin
              iRes := AllocMem(Length(Str) * Sizeof(WideChar));
              Result := StringToWideChar(Str, iRes, Length(Str));
              FreeMem(iRes, Length(Str) * Sizeof(WideChar));
              end;

var
   pDesktopFolder: PShellFolder;
   ulEaten: DWORD;
   pidl: PItemIdList;
   ulAttribs: DWORD;
   hr: HResult;
begin
     if not (GetDisplayName(strName, SHGDN_FORPARSING)) then begin
        Result := nil;
     end else begin
        new(pDesktopFolder);
	hr := SHGetDesktopFolder(pDesktopFolder^);
	if Succeeded(hr) then begin
	   hr := pDesktopFolder.ParseDisplayName(0, nil, S2Ole(strName), ulEaten, pidl, ulAttribs);
           if (FAILED(hr)) then Result := m_pidl else Result := pidl;
           end else Result := m_pidl;
        //dispose(pDesktopFolder);
        end;
     end;

function TCPidl.SetQualifiedPidl(pidl: PItemIdList): boolean;
var
   cb1, cb2: integer;
begin
	cb1 := GetSize(pidl);
	cb2 := GetSize(nil);
	if (eCreate(cb1 + cb2, @m_QualifiedPidl)) then begin
           CopyMemory(m_QualifiedPidl, pidl, cb1);
           CopyMemory((PChar(m_pidl)) + cb1, pidl, cb2);
           Result := True;
           end else Result := False;
        end;

function TCPidl.GetQualifiedPidl: PItemIdList;
begin
     Result := m_QualifiedPidl;
     end;

function TCPidl.GetFolder: PShellFolder;
begin
     Result := m_pFolder;
     end;

end.
