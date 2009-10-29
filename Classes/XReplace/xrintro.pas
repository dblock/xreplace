unit xrintro;

// Code originated in the April/May 1996 Visual Developer by the Coriolos
// Group.  Written originally for MFC and ported to Delphi by Brad Choate
// Questions?  E-mail to: choate@cswnet.com

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type

    PInfArray = ^TInfArray;
    TInfArray = array[0..MaxInt div 10] of TPoint;

  TXRIntroForm = class(TForm)
    Image1: TImage;
    xLabel: TLabel;
    xVersion: TLabel;
    Bevel1: TBevel;
    shCheckBox: TCheckBox;
    cmdClose: TSpeedButton;
    xoRegister: TSpeedButton;
    closeTimer: TTimer;
    procedure FormResize( Sender: TObject );
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
    procedure shCheckBoxClick(Sender: TObject);
    procedure xoRegisterClick(Sender: TObject);
    procedure closeTimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
         procedure WMNCHitTest(var M: TWMNCHitTest); message WM_NCHitTest;
         procedure WMwindowposchanging(var M: TWMwindowposchanging); message WM_WINDOWPOSCHANGING;
  public
    { Public declarations }
  end;

var
  XRIntroForm: TXRIntroForm;

implementation

uses xreplace, d32about;

{$R *.DFM}

procedure SetWin( w: HWND );
var
    PointsList: TList;
    
    procedure AddPoint(x,y: integer);
    var
       Point: PPoint;
    begin
         new(Point);
         Point^.X := X;
         POint^.Y := Y;
         PointsList.Add(Point);
         end;

    procedure Build(var rgn: HRGN);
    var
       PointsArray: PInfArray;
       i: integer;
    begin
         PointsArray:=AllocMem((PointsList.Count + 1) * sizeof(TPoint));
         for i:=0 to PointsList.Count - 1 do PointsArray[i] := TPoint(PointsList[i]^);
         rgn := CreatePolygonRgn( PointsArray^, PointsList.Count, WINDING );
         FreeMem(PointsArray);
         end;

    procedure Combine(var rgn: HRGN; var rgnTemp: HRGN; Mode: integer);
    begin
         CombineRgn(rgn, rgn, rgnTemp, Mode);
         end;

    procedure Draw(var rgn: HRGN);
    begin
         if ( rgn <> 0 ) then SetWindowRgn( w, rgn, true );
         end;

  var
    rgn: HRGN;
    rgnTemp: HRGN;
    wrect: TRect;
  begin

  if ( SetWindowRgn( w, 0, false ) = 0) then exit;
  if ( not GetWindowRect( w, wrect ) ) then exit;

  PointsList := TList.Create;
  AddPoint(186,7);
  AddPoint(118,7);
  AddPoint(118,0);
  AddPoint(113,7);
  AddPoint(27,7);
  AddPoint(15,11);
  AddPoint(9,16);
  AddPoint(4,24);
  AddPoint(4,28);
  AddPoint(4,32);
  AddPoint(9,40);
  AddPoint(58,90);
  AddPoint(60,95);
  AddPoint(54,98);
  AddPoint(46,83);
  AddPoint(45,92);
  AddPoint(34,81);
  AddPoint(27,79);
  AddPoint(29,85);
  AddPoint(17,75);
  AddPoint(8,73);
  AddPoint(0,69);
  AddPoint(14,89);
  AddPoint(22,96);
  AddPoint(18,97);
  AddPoint(25,102);
  AddPoint(16,102);
  AddPoint(30,110);
  AddPoint(26,112);
  AddPoint(23,112);
  AddPoint(24,115);
  AddPoint(10,122);
  AddPoint(5,125);
  AddPoint(2,130);
  AddPoint(1,156);
  AddPoint(0,157);
  AddPoint(1,158);
  AddPoint(2,194);
  AddPoint(2,197);
  AddPoint(2,201);
  AddPoint(7,208);
  AddPoint(12,214);
  AddPoint(18,219);
  AddPoint(23,220);
  AddPoint(29,220);
  AddPoint(36,216);
  AddPoint(76,177);
  AddPoint(87,177);
  AddPoint(104,170);
  AddPoint(103,185);
  AddPoint(108,184);
  AddPoint(107,175);
  AddPoint(117,178);
  AddPoint(120,178);
  AddPoint(129,185);
  AddPoint(134,186);
  AddPoint(132,177);
  AddPoint(140,181);
  AddPoint(147,182);
  AddPoint(182,215);
  AddPoint(187,218);
  AddPoint(196,218);
  AddPoint(203,216);
  AddPoint(wrect.Right - wrect.Left, 216);
  AddPoint(wrect.Right - wrect.Left, 6);

  Build(rgn);

  PointsList.Clear;
  AddPoint(107,29);
  AddPoint(43,29);
  AddPoint(38,30);
  AddPoint(36,35);
  AddPoint(36,37);
  AddPoint(40,41);
  AddPoint(77,77);
  AddPoint(75,68);
  AddPoint(87,80);
  AddPoint(93,79);
  AddPoint(92,56);
  AddPoint(96,63);
  AddPoint(99,61);
  AddPoint(99,44);
  AddPoint(102,46);
  AddPoint(104,31);
  AddPoint(106,31);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(40,135);
  AddPoint(35,139);
  AddPoint(33,146);
  AddPoint(61,155);
  AddPoint(66,149);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(32,166);
  AddPoint(33,171);
  AddPoint(34,177);
  AddPoint(36,177);
  AddPoint(46,171);
  AddPoint(41,170);
  AddPoint(46,166);
  AddPoint(31,164);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(80,115);
  AddPoint(90,126);
  AddPoint(86,128);
  AddPoint(79,114);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(117,28);
  AddPoint(118,35);
  AddPoint(120,35);
  AddPoint(118,47);
  AddPoint(124,45);
  AddPoint(118,59);
  AddPoint(119,61);
  AddPoint(134,53);
  AddPoint(122,81);
  AddPoint(127,81);
  AddPoint(136,66);
  AddPoint(134,76);
  AddPoint(132,81);
  AddPoint(176,37);
  AddPoint(173,32);
  AddPoint(164,29);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(126,124);
  AddPoint(131,130);
  AddPoint(142,115);
  AddPoint(138,113);
  AddPoint(126,121);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(162,139);
  AddPoint(183,141);
  AddPoint(179,135);
  AddPoint(177,131);
  AddPoint(169,136);
  AddPoint(162,138);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(157,156);
  AddPoint(164,163);
  AddPoint(182,163);
  AddPoint(183,143);
  AddPoint(171,150);
  AddPoint(165,151);
  AddPoint(165,154);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  PointsList.Clear;
  AddPoint(230,7);
  AddPoint(186,7);
  AddPoint(197,9);
  AddPoint(206,15);
  AddPoint(210,36);
  AddPoint(154,94);
  AddPoint(156,98);
  AddPoint(166,102);
  AddPoint(169,99);
  AddPoint(170,104);
  AddPoint(181,95);
  AddPoint(182,98);
  AddPoint(188,92);
  AddPoint(200,76);
  AddPoint(190,106);
  AddPoint(192,107);
  AddPoint(186,114);
  AddPoint(198,120);
  AddPoint(206,127);
  AddPoint(209,136);
  AddPoint(210,206);
  AddPoint(206,211);
  AddPoint(203,216);
  AddPoint(230,216);
  Build(rgnTemp);
  Combine(rgn, rgnTemp, RGN_XOR);

  Draw(rgn);
  PointsList.Destroy;
  end;

procedure TXRIntroForm.FormResize(Sender: TObject);
begin
     SetWin(Handle);
     Invalidate;
     end;

procedure TXRIntroForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     // Make sure we have cleared our last region prior to closing the app
     SetWindowRgn( Handle, 0, false );
     end;

procedure TXRIntroForm.FormShow(Sender: TObject);
begin
     SetWin( Handle );
     end;

procedure TXRIntroForm.WMNCHitTest(var M: TWMNCHitTest);

   function Intersect(AObject: TSpeedButton): boolean;
   var
      Point: TPoint;
   begin
      Point.X := AObject.Left;
      Point.Y := AObject.Top;
      Point := ClientToScreen(Point);

      if (M.XPos > Point.X) and (M.XPos < (Point.X + AObject.Width))
         and (M.YPos > Point.Y) and (M.YPos < (Point.Y + AObject.Height)) then Result := True
         else Result := False;
      end;

begin
   inherited;
   if M.Result = htClient then begin
      if Intersect(cmdClose) {$ifndef Registered}or Intersect(xoRegister){$endif} then exit;
      M.Result := htCaption;
      end;
   end;

procedure TXRIntroForm.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   with M.WindowPos^ do begin
      if x<0 then x:=0;
      if y<0 then y:=0;
      if x+cx>Screen.Width then x:=Screen.Width-cx;
      if y+cy>Screen.Height then y:=Screen.Height-cy;
      end;
  end;

procedure TXRIntroForm.FormCreate(Sender: TObject);
begin
     {$ifndef Registered}
     shCheckBox.Enabled := False;
     xoRegister.Visible := True;
     {$endif}
     xLabel.Caption:=xrVersion;
     xVersion.Caption:=
               'Copyright © Vestris Inc. - (1996-2000)'+ #13#10+
               'Vestris Inc. - All Rights Reserved.'+ #13#10 +
               'http://www.vestris.com'+#13#10#10+
               {$ifdef Registered}
               'Registered version of XReplace-32.';
               {$else}
               'XReplace-32 is NOT freeware! ' + #13#10 +
               'Click on the World button to register. ' + #13#10 +
               IntToStr(ShareWareMax - xRepl32.TillExpired) + ' days of evaluation left.';
               {$endif}
     end;


procedure TXRIntroForm.cmdCloseClick(Sender: TObject);
begin
     Hide;
     end;


procedure TXRIntroForm.shCheckBoxClick(Sender: TObject);
begin
     XReplaceOptions.Gen.ShowIntro := shCheckBox.Checked;
     end;


procedure TXRIntroForm.xoRegisterClick(Sender: TObject);
begin
     {$ifndef Registered}
     xRepl32.Register1.Click;
     {$endif}
     end;

procedure TXRIntroForm.closeTimerTimer(Sender: TObject);
begin
     closeTimer.Enabled := False;
     if Visible then Hide;
     end;

procedure TXRIntroForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
     if (Key = 27) then Hide;
     end;

end.

