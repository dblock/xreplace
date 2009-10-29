unit MDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, StdCtrls;

type
  TMsgForm = class(TForm)
    BtnPanel: TPanel;
    ImgPanel: TPanel;
    Panel2: TPanel;
    CommentPanel: TPanel;
    MsgPanel: TPanel;
    MsgText: TMemo;
    CommentText: TMemo;
    TheImage: TImage;
    ErrorPanel: TPanel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
  public
    function isVisible: boolean;
    function MessageDlg(MStr,
                        CStr: string;
                        ATyp: TMsgDlgType;
                        CBtn: TMsgDlgButtons;
                        HCtx: LongInt;
                        ERp: string): word;
  end;

  procedure initMdlg;

var
  MsgForm: TMsgForm = nil;

implementation

uses xreplace;

{$R *.DFM}

procedure initMdlg;
begin
     if MsgForm = nil then begin
        MsgForm := TMsgForm.Create(Application);
        end;
     end;

function TMsgForm.IsVisible: boolean;
begin
     if MsgForm = nil then Result := False else Result := Self.Visible;
     end;

function TMsgForm.MessageDlg(MStr, CStr: string; ATyp: TMsgDlgType; CBtn: TMsgDlgButtons; HCtx: LongInt; Erp: string): word;
var
   BtnIndex: integer;
   procedure NextBtn(iKind: TBitBtnKind; iModalResult: integer);
   var
      AButton: TBitBtn;
   begin
        inc(BtnIndex);
        AButton:=TBitBtn.Create(Application);
        with AButton do begin
           Top:=(BtnPAnel.ClientHeight - Height) div 2;
           Left:=BtnPanel.ClientWidth-(Width+2)*BtnIndex;
           Visible:=True;
           Kind:=iKind;
           ModalResult:=iModalResult;
           BtnPanel.InsertControl(AButton);
           end;
      end;

const
   StdMsg: string = 'XReplace-32';
var
   ThisBtn: TBitBtn;
   i: integer;
begin
   MsgText.Text:=MStr;
   if Length(Erp) > 0 then ErrorPanel.Caption := Erp else ErrorPanel.Caption := XRVersion;
   CommentText.Text:=CStr;
   case ATyp of
      mtWarning:      MsgForm.Caption:=StdMsg+': Warning!';
      mtError:        MsgForm.Caption:=StdMsg+': Error!';
      mtInformation:  MsgForm.Caption:=StdMsg+': Information.';
      mtConfirmation: MsgForm.Caption:=StdMsg+': Please confirm.';
      mtCustom:       MsgForm.Caption:=StdMsg;
      end;

   BtnIndex:=0;

   for i:=0 to BtnPanel.ControlCount-1 do begin
      ThisBtn:=TbitBtn(BtnPanel.Controls[0]);
      BtnPanel.RemoveControl(ThisBtn);
      ThisBtn.Destroy;
      end;

   if mbOk in CBtn then NextBtn(bkOk, mrOk);
   if mbYes in CBtn then NextBtn(bkYes, mrYes);
   if mbNo in CBtn then NextBtn(bkNo, mrNo);
   if mbCancel in CBtn then NextBtn(bkCancel, mrCancel);
   if mbAbort in CBtn then NextBtn(bkAbort, mrAbort);
   if mbRetry in CBtn then NextBtn(bkRetry, mrRetry);
   if mbIgnore in CBtn then NextBtn(bkIgnore, mrIgnore);
   if mbAll in CBtn then NextBtn(bkAll, mrAll);
   if mbHelp in CBtn then NextBtn(bkHelp, mrOk);

   if Application.MainForm <> nil then begin
      try
      with MsgForm do begin
         Left:=Application.MainForm.Left+(Application.MainForm.Width - Width) div 2;
         Top:=Application.MainForm.Top+(Application.MainForm.Height - Height) div 2;
         end;
      except
         Left:=(Screen.Width - MsgForm.Width) div 2;
         Top:=(Screen.Height - MsgForm.Height) div 2;
      end;
   end;

   Result:=MsgForm.ShowModal;
   end;


procedure TMsgForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=112 then xRepl32.Help2Click(Sender);
   end;

procedure TMsgForm.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   try
   inherited;
   if not XReplaceOptions.Gen.ShiftOut then 
   with M.WindowPos^ do begin
         if x<0 then x:=0;
         if y<0 then y:=0;
         if x+cx>Screen.Width then x:=Screen.Width-cx;
         if y+cy>Screen.Height then y:=Screen.Height-cy;
      end;
   except
   end;
   end;


end.
