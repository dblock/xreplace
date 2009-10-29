unit redirect;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ExtCtrls, Buttons, BrowseDr, ComCtrls, ShellView;

type
  TDirSelect = class(TForm)
    MainPanel: TPanel;
    DirPanel: TPanel;
    SelEdit: TEdit;
    SelectPanel: TPanel;
    dsOk: TBitBtn;
    dsCancel: TBitBtn;
    SelDir: TShellView;
    procedure SelEditChange(Sender: TObject);
    procedure SelEditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SelDirChange(Sender: TObject; Node: TTreeNode);
  private
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
  end;

  procedure initDirSelect;

var
  DirSelect: TDirSelect = nil;

implementation

uses xreplace, xopt;

{$R *.DFM}

procedure initDirSelect;
begin
     if DirSelect = nil then begin
        Application.CreateForm(TDirSelect, DirSelect);
        end;
     end;

procedure TDirSelect.SelEditChange(Sender: TObject);
var
 ss, sl: integer;
begin
     try
     sl := SelEdit.SelStart;
     ss := SelEdit.SelLength;
     if (SelEdit.Text <> SelDir.Directory) and DirectoryExists(SelEdit.Text) then begin
          SelDir.Directory := SelEdit.Text;
          if SelEdit.Showing then SelEdit.SetFocus;
          SelEdit.SelStart := sl;
          SelEdit.SelLength := ss;
          end;
     except
     end;
     end;

procedure TDirSelect.SelEditKeyPress(Sender: TObject; var Key: Char);
begin
     if Key in ['>','<','[',']','?','*','¦','"','|'] then Key := Chr(0);
     end;

procedure TDirSelect.FormCreate(Sender: TObject);
begin
     if XReplaceOptions.Gen.RememberDirs then SelDir.Directory := XReplaceOptions.Hidden.RedirectDirectory;
     end;

procedure TDirSelect.FormShow(Sender: TObject);
begin
     SelEdit.text := SelDir.Directory;
     if SelDir.Showing then SelDir.SetFocus;
     SelEdit.SelStart:=Length(SelEdit.Text);
     end;

procedure TDirSelect.SelDirChange(Sender: TObject; Node: TTreeNode);
begin
     if DirectoryExists(SelDir.Directory) and (SelDir.Directory <> SelEdit.Text) then SelEdit.Text := SelDir.Directory;
     end;

procedure TDirSelect.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   with M.WindowPos^ do begin
      if not XReplaceOptions.Gen.ShiftOut then begin
         if (cx<>Width) or (cy<>Height) then begin
           if x<0 then begin cx:=cx+x; x:=0; end;
           if y<0 then begin cy:=cy+y; y:=0; end;
           if x+cx>Screen.Width then cx:=Screen.Width-x;
           if y+cy>Screen.Height then cy:=Screen.Height-y;
         end else begin
           if x<0 then x:=0;
           if y<0 then y:=0;
           if x+cx>Screen.Width then x:=Screen.Width-cx;
           if y+cy>Screen.Height then y:=Screen.Height-cy;
         end;
      end;
      end;
  end;


end.
