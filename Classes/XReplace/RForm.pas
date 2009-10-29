unit RForm;
{(c) Daniel Doubrovkine - 1996 - Stolen Technologies Inc. - University of Geneva }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, d32gen, d32reg;

type
  TReplaceForm = class(TForm)
    GroupBox1: TGroupBox;
    Yes: TBitBtn;
    No: TBitBtn;
    YesAll: TBitBtn;
    GroupBox2: TGroupBox;
    NoAll: TBitBtn;
    AllNoAll: TBitBtn;
    AllYesAll: TBitBtn;
    Status: TStatusBar;
    FromStrings: TMemo;
    ToStrings: TMemo;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroupBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FormHeight: integer;
    FormWidth: integer;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GetMinMaxInfo;
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
    procedure UpdateRegistry;
  public
    procedure LoadLine(SLeftSide,
                                SString,
                                SRightSide,
                                TLeftSide,
                                TString,
                                TRightSide: string);

  end;


var
      ReplaceForm: TReplaceForm;

implementation

uses xreplace, xopt;

{$R *.DFM}

procedure TReplaceForm.LoadLine(SLeftSide,
                                SString,
                                SRightSide,
                                TLeftSide,
                                TString,
                                TRightSide: string);
begin
   with FromStrings do begin
      Clear;
      Text:=SLeftSide+SSTring+SRightSide;
      SelStart:=Length(SLeftSide);
      SelLength:=Length(SString);
      end;
   with ToStrings do begin
      Clear;
      Text:=TLeftSide+TString+TRightSide;
      SelStart:=Length(TLeftSide);
      Sellength:=Length(TString);
      end;
   end;

procedure TReplaceForm.FormResize(Sender: TObject);
begin
   FromStrings.Height:=(ClientHeight - GroupBox2.Height - Status.Height) div 2;
   FromStrings.Width := ClientWidth;
   ToStrings.Height:=FromStrings.Height;
   ToStrings.Width := ClientWidth;
   ToStrings.Top:=FromStrings.Height;
   GroupBox1.Top:=ToStrings.Top+ToStrings.Height;
   GroupBox2.Top:=GroupBox1.Top;
   GroupBox1.Width := (ClientWidth - GroupBox2.Width);
   GroupBox2.Left := ClientWidth - GroupBox2.Width;
   SendMessage(Tostrings.Handle,EM_SCROLLCARET,0,0);
   SendMessage(FromStrings.Handle,EM_SCROLLCARET,0,0);
   end;

procedure TReplaceForm.FormShow(Sender: TObject);
begin
   //Left:=xRepl32.Left+(xRepl32.Width-Width) div 2;
   //Top:=xRepl32.Top+(xRepl32.Height-Height) div 2;
   end;

procedure TReplaceForm.GroupBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   Screen.Cursor := crDefault;
   end;

procedure TReplaceForm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
   inherited;
   with Msg.MinMaxInfo^ do begin
      if ptMinTrackSize.x<FormWidth then ptMinTrackSize.x:= FormWidth;
      if ptMinTrackSize.y<FormHeight then ptMinTrackSize.y:= FormHeight;
      if ptMaxTrackSize.x>Screen.Width then ptMaxTrackSize.x:=Screen.Width;
      if ptMaxTrackSize.y>Screen.Height then ptMaxTrackSize.y:=Screen.Height;
      end;
   end;

procedure TReplaceForm.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   with M.WindowPos^ do begin
      if cx<=FormWidth then cx:=FormWidth;
      if cy<=FormHeight then cy:=FormHeight;
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


procedure TReplaceForm.FormCreate(Sender: TObject);
var
   ih,iw: integer;
begin
     FormHeight:=Height;
     FormWidth:=Width;
     try ih:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\hidden\',
                    'rform-height'); except ih:=0; end;
     try iw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\hidden\',
                    'rform-width'); except iw:=0; end;
     if ih > 0 then Height:=ih;
     if iw > 0 then Width:=iw;
     try ih:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\hidden\',
                    'rform-top'); except ih:=0; end;
     try iw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\hidden\',
                    'rform-left'); except iw:=0; end;
     if ih > 0 then Top:=ih;
     if iw > 0 then Left:=iw;
     end;

procedure TReplaceForm.UpdateRegistry;
begin
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\hidden\',
                               'rform-height',
                               Height);
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\hidden\',
                               'rform-width',
                               Width);
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\hidden\',
                               'rform-top',
                               Top);
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\hidden\',
                               'rform-left',
                               Left);
   end;


procedure TReplaceForm.FormDestroy(Sender: TObject);
begin
     UpdateRegistry;
     end;

end.
