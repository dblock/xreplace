unit piclist;

interface

uses FileCtrl, Windows, Messages, WinTypes, WinProcs, StdCtrls, Classes, Forms, Graphics,
     ShellApi, SysUtils, ComCtrls, Dialogs;

type
  TPicFileListBox = class(TFileListBox)
     constructor Create(AOwner: TComponent); override;
     procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
     end;

implementation

constructor TPicFileListBox.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   end;

procedure TPicFileListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  offset: Integer;
  IconIndex: word;
  dc: hdc;
  Icon: hIcon;
begin
  with Canvas do
  begin
    FillRect(Rect);
    offset := 2;
    if ShowGlyphs then
    begin
      Icon:=ExtractAssociatedIcon(Application.Handle,PChar(Directory+'\'+Items[Index]),IconIndex);
      if (Icon <> 0) then begin
         dc:=GetDc(Self.Handle);
         DrawIconEx(dc,
                    Rect.Left+2,
                    Rect.Top,
                    Icon,
                    Rect.Bottom-Rect.Top-2,
                    Rect.Bottom-Rect.Top-2,
                    0,
                    Brush.Handle,
                    DI_NORMAL);
         end;
      offset:=Rect.bottom-Rect.top+3;
    end;
    TextOut(Rect.Left + offset, Rect.Top, Items[Index])
  end;
end;

end.

