{-----------------------------------------------------------------------------}
{ A component and a function (use the one you prefer) to encapsulate the      }
{ Win95 style directory selection dialog SHBrowseForFolder().                 }
{ Copyright 1996, Brad Stowers.  All Rights Reserved.                         }
{ This component can be freely used and distributed in commercial and private }
{ environments, provied this notice is not modified in any way and there is   }
{ no charge for it other than nomial handling fees.  Contact me directly for  }
{ modifications to this agreement.                                            }
{-----------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions  }
{ at bstowers@pobox.com or 72733,3374 on CompuServe.                          }
{ The lateset version will always be available on the web at:                 }
{   http://www.pobox.com/~bstowers/delphi/delphi.html                         }
{-----------------------------------------------------------------------------}
{ Date last modified:  03/17/96                                               }
{-----------------------------------------------------------------------------}

{ ----------------------------------------------------------------------------}
{ TBrowseDirectory v1.00                                                      }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   A dialog that displays the user's system in a heirarchial manner and      }
{   allows a selection to be made.  It is a wrapper for SHBrowseForFolder(),  }
{   which is rather messy to use directly.                                    }
{ Notes:                                                                      }
{   * Requires Pat Ritchey's ShellObj unit.  It is freely available on his    }
{     web site at http://ourworld.compuserve.com/homepages/PRitchey/          }
{   * Callbacks are not implemented in this version.                          }
{ ----------------------------------------------------------------------------}
{ Revision History:                                                           }
{ 1.00:  + Initial release                                                    }
{ ----------------------------------------------------------------------------}

unit BrowseDr;

{$IFNDEF WIN32}
  ERROR!  This unit only available on Win32!
{$ENDIF}

interface

uses ShlObj, activex, Controls, Classes, dsgnintf;

type
  { These are equivalent to the CSIDL_* constants in the Win32 (95?) API.  }
  { They are used to specify the root of the heirarchy.                    }
  { NOTE: the idDesktopExpanded is not docuemnted, but it seems to be used }
  {       by the Win95 Explorer.  I find it useful, but use at your own    }
  {       risk.  It may be "fixed" in some future release of Win95.        }
  TRootID = (
    idDesktop, idDesktopExpanded, idPrograms, idControlPanel, idPrinters,
    idPersonal, idFavorites, idStartup, idRecent, idSendTo, idRecycleBin,
    idStartMenu, idDesktopDirectory, idDrives, idNetwork, idNetHood, idFonts,
    idTemplates
   );
  { These are equivalent to the BIF_* constants in the Win32 (95?) API.   }
  { They are used to specify what items can be expanded, and what itmes   }
  { can be selected.                                                      }
  TBrowseFlag = (
    bfDirectoriesOnly, bfDomainOnly, bfAncestors, bfComputers, bfPrinters
    { , bfStatusText // Will be added when callback is implemented.       }
   );
  TBrowseFlags = set of TBrowseFlag;

{ For those of you who prefer to, you can display this dialog with only a }
{ function call, no component necessary.  Actually, the component simply  }
{ collects parameters and calls this function.                            }
function BrowseDirectory(var   Dest: string;         // Receives selected path
                         const AParent: TWinControl; // Who owns the window
                         const Title: string;        // Text shown above list
                               Root: TRootID;        // Root to browse from
                               Flags: TBrowseFlags   // What is legal to select
                        ): boolean;                  // True if selection made

{ For the component lover in all of us }
type
  TBrowseDirectoryDlg = class(TComponent)
  private
    { Property variables }
    FTitle: string;
    FRoot: TRootID;
    FOptions: TBrowseFlags;
    { Internal variables }
    FSelected: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Displays the dialog.  Returns true if user selected an item and       }
    { pressed OK, otherwise it returns false.                               }
    function Execute: boolean; virtual;
    { Runtime only property containing the item selected.  This will only   }
    { be valid after Execute is called and it returns TRUE.  At any other   }
    { time, it should be an empty ('') string.                              }
    property Selected: string read FSelected;
  published
    { Text to display above the selection tree.                             }
    property Title: string read FTitle write FTitle;
    { Item that is to be treated as the root of the display.                }
    property Root: TRootID read FRoot write FRoot default idDesktopExpanded;
    { Options to control what is allowed to be selected and expanded.       }
    property Options: TBrowseFlags read FOptions write FOptions default [];
  end;

  { A component editor (not really) to allow on-the-fly testing of the      }
  { dialog.  Right click the component and select 'Test Dialog', or simply  }
  { double click the component, and the browse dialog will be displayed     }
  { with the current settings.                                              }
  TBrowseDialogEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index : Integer); override;
    function GetVerb(Index : Integer): string; override;
    function GetVerbCount : Integer; override;
    procedure Edit; override;
  end;

procedure Register;

implementation

uses Windows, Forms, Dialogs, SysUtils;

// Utility functions used to convert from Delphi set types to API constants.
function ConvertRoot(Root: TRootID): integer;
const
  RootValues: array[TRootID] of integer = (
    CSIDL_DESKTOP, $0001, CSIDL_PROGRAMS, CSIDL_CONTROLS, CSIDL_PRINTERS,
    CSIDL_PERSONAL, CSIDL_FAVORITES, CSIDL_STARTUP, CSIDL_RECENT, CSIDL_SENDTO,
    CSIDL_BITBUCKET, CSIDL_STARTMENU, CSIDL_DESKTOPDIRECTORY, CSIDL_DRIVES,
    CSIDL_NETWORK, CSIDL_NETHOOD, CSIDL_FONTS, CSIDL_TEMPLATES
   );
begin
  Result := RootValues[Root];
end;

function ConvertFlags(Flags: TBrowseFlags): UINT;
const
  FlagValues: array[TBrowseFlag] of UINT = (
    BIF_RETURNONLYFSDIRS, BIF_DONTGOBELOWDOMAIN, BIF_RETURNFSANCESTORS,
    BIF_BROWSEFORCOMPUTER, BIF_BROWSEFORPRINTER
    {, BIF_STATUSTEXT // Will be added when callback is implemented.        }
   );
var
  Opt: TBrowseFlag;
begin
  Result := 0;
  { Loop through all possible values }
  for Opt := Low(TBrowseFlag) to High(TBrowseFlag) do
    if Opt in Flags then
      Result := Result OR FlagValues[Opt];
end;


function BrowseDirectory(var Dest: string; const AParent: TWinControl;
                         const Title: string; Root: TRootID;
                         Flags: TBrowseFlags): boolean;
var
  ShellMalloc: IMalloc;
  shBuff: PChar;
  BrowseInfo: TBrowseInfo;
  idRoot, idBrowse: PItemIDList;
begin
  Result := FALSE; // Assume the worst.
  Dest := ''; // Clear it out.
  SetLength(Dest, MAX_PATH);  // Make sure their will be enough room in dest.
  if CoGetMalloc(MEMCTX_TASK, ShellMalloc) = NOERROR then begin
  //if SHGetMalloc(ShellMalloc) = NOERROR then begin
    try
      shBuff := PChar(ShellMalloc.Alloc(MAX_PATH)); // Shell allocate buffer.
      if assigned(shBuff) then begin
        try
          // Get id for desired root item.
          SHGetSpecialFolderLocation(AParent.Handle, ConvertRoot(Root), idRoot);
          try
            with BrowseInfo do begin  // Fill info structure
              hwndOwner := AParent.Handle;
              pidlRoot := idRoot;
              pszDisplayName := shBuff;
              lpszTitle := PChar(Title);
              ulFlags := ConvertFlags(Flags);
              lpfn := NIL;
              lParam := 0;
            end;
            idBrowse := SHBrowseForFolder(BrowseInfo);
            if assigned(idBrowse) then begin
              try
                SHGetPathFromIDList(idBrowse, shBuff); // Turn into real path.
                Dest := shBuff; // Put it in user's variable.
                Result := TRUE; // Success!
              finally
                ShellMalloc.Free(idBrowse); // Clean up after ourselves
              end;
            end;
          finally
            ShellMalloc.Free(idRoot); // Clean-up.
          end;
        finally
          ShellMalloc.Free(shBuff); // Clean-up.
        end;
      end;
    finally
      // ShellMalloc.Release; // Clean-up.
    end;
  end;
end;


constructor TBrowseDirectoryDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitle := '';
  FRoot := idDesktopExpanded;
  FOptions := [];
  FSelected := '';
end;

destructor TBrowseDirectoryDlg.Destroy;
begin
  inherited Destroy;
  end;

function TBrowseDirectoryDlg.Execute: boolean;
var
  S: string;
  Parent: TWinControl;
begin
  { Determine who the parent is. }
  if Owner is TWinControl then
    Parent := Owner as TWinControl
  else
    Parent := Application.MainForm;
  { Call the function }
  Result := BrowseDirectory(S, Parent, FTitle, FRoot, FOptions);
  { If selectino made, update property }
  if Result then
    FSelected := S;
end;

// Component Editor (not really) to allow on the fly testing of the dialog
procedure TBrowseDialogEditor.ExecuteVerb(Index: Integer);
begin
  {we only have one verb, so exit if this ain't it}
  if Index <> 0 then Exit;
  Edit;
end;

function TBrowseDialogEditor.GetVerb(Index: Integer): AnsiString;
begin
  Result := 'Test Dialog';
end;

function TBrowseDialogEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TBrowseDialogEditor.Edit;
begin
  with TBrowseDirectoryDlg(Component) do
    if Execute then
      MessageDlg(Format('Item selected:'#13#13'%s', [Selected]),
                 mtInformation, [mbOk], 0);
end;


procedure Register;
begin
  { You may prefer it on the Dialogs page, I like it on Win95 because it is
    only available on Win95.                                                }
  RegisterComponents('Win95', [TBrowseDirectoryDlg]);
  RegisterComponentEditor(TBrowseDirectoryDlg, TBrowseDialogEditor);
end;


end.
