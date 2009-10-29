unit PidlManager;

interface

uses ShlObj, RegStr, Graphics, WinTypes, WinProcs,
     ComCtrls, Dialogs, CPidl, SysUtils, ShellApi, Forms,
     Classes, d32gen, Controls;

var
   shDesktop, shMyComputer, shFolder, shFolderOpen, shFolderShared, shFolderOpenShared,
   shFloppy, shFloppyShared, shHdd, shHddShared, shCDRom, shCdRomShared, shRecycled,
   shRecycledFull, shNetwork, shWorkGroup, shWorkstation, shHddNetwork, shPrinterNetwork,
   shControlPanel, shPrinters, shNeighborhood, shGeneric, shSelected: integer;

type
    TPidlManager = class(TComponent)
        private
           statusCreating: boolean;
           CSIDL_BITBUCKET_pidl,
           CSIDL_DRIVES_pidl,
           CSIDL_NETWORK_pidl,
           CSIDL_CONTROLS_pidl,
           CSIDL_PRINTERS_pidl: PItemIdList;
           procedure InitPidls;
           procedure InitImages;
        public
           shFolderIcon: TIcon;
           shUnknownIcon: tIcon;
           ImageList: TImageList;
           constructor Create(AOwner: TComponent); override;
           function SetNodeIcon(pidlObj: PCPidl; Node: TTreeNode;  Item: TListItem; ulAttrs: DWORD): boolean;
        end;

var
   CurrentPidlManager: TPidlManager;

{$R SHIcons.Res}

implementation

uses ImgList;

procedure TPidlManager.InitPidls;
begin
     SHGetSpecialFolderLocation(HINSTANCE, CSIDL_PRINTERS, CSIDL_PRINTERS_pidl);
     SHGetSpecialFolderLocation(HINSTANCE, CSIDL_BITBUCKET, CSIDL_BITBUCKET_pidl);
     SHGetSpecialFolderLocation(HINSTANCE, CSIDL_NETWORK, CSIDL_NETWORK_pidl);
     SHGetSpecialFolderLocation(HINSTANCE, CSIDL_DRIVES, CSIDL_DRIVES_pidl);
     SHGetSpecialFolderLocation(HINSTANCE, CSIDL_CONTROLS, CSIDL_CONTROLS_pidl);
     end;

constructor TPidlManager.Create(AOwner: tComponent);
begin
     inherited;
     statusCreating := True;
     shFolderIcon := nil;
     shUnknownIcon := nil;
     InitPidls;
     InitImages;
     end;

procedure TPidlManager.InitImages;
var
   idCounter : integer;
          procedure incId(var idProperty: integer);
          begin
               idProperty := idCounter;
               inc(idCounter);
               end;
begin
     idCounter := 0;
     ImageList := TImageList.Create(nil);
     ImageList.ResourceLoad(ImgList.TResType(rtBitmap), 'SH_GENERIC', clWhite);
        incId(shGeneric);
        if shUnknownIcon = nil then begin
           shUnknownIcon := TIcon.Create;
           ImageList.GetIcon(shGeneric, shUnknownIcon);
           end;
        incId(shSelected);
     ImageList.ResourceLoad(rtBitmap, 'SH_DESKTOP', clWhite);
        incId(shDesktop);
        incId(shMyComputer);
     ImageList.ResourceLoad(rtBitmap, 'SH_RECYCLED', clWhite);
        incId(shRecycled);
        incId(shRecycledFull);
     ImageList.ResourceLoad(rtBitmap, 'SH_FOLDERS', clWhite);
        incId(shFolder);
        if shFolderIcon = nil then begin
           shFolderIcon := TIcon.Create;
           ImageList.GetIcon(shFolder, shFolderIcon);
           end;
        incId(shFolderOpen);
        incId(shFolderShared);
        incId(shFolderOpenShared);
     ImageList.ResourceLoad(rtBitmap, 'SH_FLOPPY', clWhite);
        incId(shFloppy);
        incId(shFloppyShared);
     ImageList.ResourceLoad(rtBitmap, 'SH_HDD', clWhite);
        incId(shHdd);
        incId(shHddShared);
        incId(shHddNetwork);
     ImageList.ResourceLoad(rtBitmap, 'SH_CDROM', clWhite);
        incId(shCDRom);
        incId(shCdRomShared);
     ImageList.ResourceLoad(rtBitmap, 'SH_NETWORK', clWhite);
        incId(shNetwork);
        incId(shWorkGroup);
        incId(shWorkstation);
        incId(shNeighborhood);
     ImageList.ResourceLoad(rtBitmap, 'SH_PRINTER', clWhite);
        incId(shPrinters);
        incId(shPrinterNetwork);
     ImageList.ResourceLoad(rtBitmap, 'SH_CONTROLPANEL', clWhite);
        incId(shControlPanel);
     end;

function TPidlManager.SetNodeIcon(pidlObj: PCPidl; Node: TTreeNode; Item: TListItem; ulAttrs: DWORD): boolean;
          procedure SetIndex(Normal, Selected: integer);
          begin
               if Node <> nil then begin
                  Node.ImageIndex := Normal;
                  Node.SelectedIndex := Selected
                  end else
               if Item <> nil then begin
                  Item.ImageIndex := Normal;
                  end;
               end;
var
   aIndex: integer;
begin
     Result :=True;
     if pidlObj.GetFolder.CompareIDs(0, pidlObj.m_pidl, CSIDL_BITBUCKET_pidl) = 0 then begin
        SetIndex(shRecycled, shRecycled);
        Result := FalsE;
     end else if pidlObj.GetFolder.CompareIDs(0, pidlObj.m_pidl, CSIDL_DRIVES_pidl) = 0 then begin
        SetIndex(shMyComputer, shMyComputer);
        if (Node <> nil) and StatusCreating then begin
           StatusCreating := False;
           Node.Expand(False);
           end;
     end else if pidlObj.GetFolder.CompareIDs(0, pidlObj.m_pidl, CSIDL_NETWORK_pidl) = 0 then setIndex(shNeighborhood, shNeighborhood)
{     else if pidlObj.GetFolder.CompareIDs(0, pidlObj.m_pidl, CSIDL_PRINTERS_pidl) = 0 then setIndex(shPrinters, shPrinters)
     else if pidlObj.GetFolder.CompareIDs(0, pidlObj.m_pidl, CSIDL_CONTROLS_pidl) = 0 then setIndex(shControlPanel, shControlPanel)}
     else if (ulAttrs and SFGAO_FILESYSTEM) > 0 then begin
         case GetDriveType(PChar(pidlObj.u_name)) of
                      0,1:               begin
                                         if (Item <> nil) and (pidlObj.u_name <> '') and FileExists(pidlObj.u_name) then begin
                                            aIndex := ExtractAnIcon(pidlObj.u_name,TImageList((Item.ListView as TListView).SmallImages),TImageList((Item.ListView as TListView).LargeImages));
                                            setindex(aIndex, 0);
                                            end else
                                         if (ulAttrs and SFGAO_SHARE) > 0 then
                                            setIndex(shFolderShared, shFolderOpenShared)
                                            else setIndex(shFolder, shFolderOpen);
                                         end;
                      DRIVE_REMOVABLE:   begin
                                         if (ulAttrs and SFGAO_SHARE) > 0 then
                                            setIndex(shFloppyShared, shFloppyShared)
                                            else setIndex(shFloppy, shFloppy);
                                         end;
                      DRIVE_FIXED:       begin
                                         if (ulAttrs and SFGAO_SHARE) > 0 then
                                            setIndex(shHddShared, shHddShared)
                                            else setIndex(shHdd, shHdd)
                                         end;
                      DRIVE_REMOTE:      begin
                                         setIndex(shHddNetwork, shHddNetwork)
                                         end;
                      DRIVE_CDROM:       begin
                                         if (ulAttrs and SFGAO_SHARE) > 0 then
                                            setIndex(shCDROMShared, SHCDROMShared)
                                            else setIndex(SHCDROM, shCDROM);
                                         end;
                      DRIVE_RAMDISK:     begin
                                         setIndex(shHdd, shHdd)
                                         end;
                      end;
        end else begin
             if (Node <> nil) and  (Node.Parent <> nil) then
                   if PCPidl(Node.Parent.Data).GetFolder.CompareIDs(0, PCPidl(Node.Parent.Data).m_pidl, CSIDL_DRIVES_pidl) = 0 then Result := False;
             if Item <> nil then setIndex(shGeneric, 0)
             else if Node <> nil then setIndex(shFolder, shFolderOpen);
         end;
   end;


initialization
     CurrentPidlManager := TPidlManager.Create(nil);
finalization
     CurrentPidlManager.destroy;
     end.
