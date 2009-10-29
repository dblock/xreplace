unit batch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Gauges;

type
  TUnattended = class(TForm)
    GlobalProgressBar: TGauge;
    LocalProgressBar: TGauge;
    FileName: TLabel;
    AbortBatch: TBitBtn;
    xCaption: TLabel;
    procedure AbortBatchClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure initUnattended;

var
  Unattended: TUnattended = nil;

implementation

uses xreplace;

{$R *.DFM}

procedure initUnattended;
begin
     if Unattended = nil then begin
        Application.CreateForm(TUnattended, Unattended);
        end;
     end;

procedure TUnattended.AbortBatchClick(Sender: TObject);
begin
   xRepl32.InterruptReplace:=True;
   Unattended.Hide;
   end;

end.
