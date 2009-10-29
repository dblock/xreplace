unit StatForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type
  TStatusForm = class(TForm)
    StatTimer: TTimer;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    Bevel1: TBevel;
    procedure StatTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private                            
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
    procedure WMNCHitTest(var M: TWMNCHitTest); message WM_NCHitTest;
    procedure HideTitleBar;
  public
    procedure Status(SStr: string);
    function CanvasWidth: Integer;
  end;

  procedure initStatusForm;

var
  StatusForm: TStatusForm = nil;

implementation

uses xreplace;

{$R *.DFM}

procedure initStatusForm;
begin
     if StatusForm = nil then begin
        Application.CreateForm(TStatusForm, StatusForm);
        end;
     end;

procedure TStatusForm.StatTimerTimer(Sender: TObject);
begin
   try
   if XRepl32.TreeView1.DropTerminated then begin
      StatTimer.Enabled:=False;
      StatusForm.Close;
      end;
   except
   end;
   end;

procedure TStatusForm.FormShow(Sender: TObject);
begin
   Left:=XRepl32.Left+(XRepl32.Width - StatusForm.Width) div 2;
   Top:=XRepl32.Top+(XRepl32.Height - StatusForm.Height) div 2;
   StatTimer.Enabled:=True;
   end;

procedure TStatusForm.BitBtn1Click(Sender: TObject);
begin
   XRepl32.TreeView1.Kill;
   end;

procedure TStatusForm.Status(SStr: string);
begin
   try
   Label1.Caption:=SStr;
   Label1.Update;
   except
   end;
   end;

procedure TStatusForm.WMNCHitTest(var M: TWMNCHitTest);
begin
   inherited;
   if M.Result = htClient then
      M.Result := htCaption;
   end;

Procedure TStatusForm.HideTitlebar;
Var
   Save : LongInt;
Begin
   if BorderStyle=bsNone then Exit;
   Save:=GetWindowLong(Handle,gwl_Style);
   if (Save and ws_Caption)=ws_Caption then Begin
      Case BorderStyle of
         bsSingle,
         bsSizeable : SetWindowLong(Handle,gwl_Style,Save and
           (not(ws_Caption)) or ws_border);
         bsDialog : SetWindowLong(Handle,gwl_Style,Save and
           (not(ws_Caption)) or ds_modalframe or ws_dlgframe);
         end;
     Height:=Height-getSystemMetrics(sm_cyCaption);
     Refresh;
     end;
   end;


procedure TStatusForm.FormCreate(Sender: TObject);
begin
   HideTitleBar;
   end;

function TStatusForm.CanvasWidth: Integer;
begin
     Result:=StatusForm.Bevel1.ClientWidth
     end;

procedure TStatusForm.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   with M.WindowPos^ do begin
      if not XReplaceOptions.Gen.ShiftOut then begin
           if x<0 then x:=0;
           if y<0 then y:=0;
           if x+cx>Screen.Width then x:=Screen.Width-cx;
           if y+cy>Screen.Height then y:=Screen.Height-cy;
      end;
      end;
  end;


end.
