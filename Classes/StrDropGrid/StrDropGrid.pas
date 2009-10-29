unit StrDropGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ShellApi, StdCtrls;

type
  TStringDropGrid = class(TStringGrid)
  private
      FOnWMDropFiles : TNotifyEvent;
      procedure WMDropFiles(var M: TWMDropFiles); message WM_DROPFILES;
  published
    property OnWMDropFiles : TNotifyEvent read FOnWMDropFiles write FOnWMDropFiles;
  end;

procedure Register;

implementation

procedure TStringDropGrid.WMDropFiles(var M: TWMDropFiles);
var
   tStr: PChar;
   i: LongInt;
   iLabel: TLabel;
begin
     tStr := AllocMem(255);
     with M do begin
          i:=DragQueryFile(Drop, $FFFFFFFF, Nil, 0);
          if i = 1 then begin
             DragQueryFile(Drop, 0, tStr, 255);
             if FileExists(tStr) then begin
                iLabel:=TLabel.Create(Application);
                iLabel.Caption:=tStr;
                if (Assigned(FOnWMDropFiles)) then
                   FOnWMDropFiles(iLabel);
                // xRepl32.SBRpLoadClick(iLabel);
                iLabel.Destroy;
                end;
             end;
          Result:=0;
          end;     end;
//-----------------------------------
procedure Register;
begin
  RegisterComponents('Samples', [TStringDropGrid]);
end;

end.
