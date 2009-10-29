unit d32about;
{(c) Daniel Doubrovkine - 1996 - Stolen Technologies Inc. - University of Geneva }

interface

uses
    d32reg, d32debug, d32gen, Forms, Messages, StdCtrls, ExtCtrls, Graphics,
    Controls, Classes, WinTypes, SysUtils;

type


   TAboutForm = class(TForm)
       procedure WMNCHitTest(var M: TWMNCHitTest); message WM_NCHitTest;
       procedure WMwindowposchanging(var M: TWMwindowposchanging); message WM_WINDOWPOSCHANGING;
       end;

   AppAbout=class
      private
         AboutForm : TAboutForm;
         AboutText : TLabel;
         OkButton : TButton;
         CopyRight : TMemo;
         VersionLabel: TLabel;
         UpdateTimer : TTimer;
         DoNotCopyRight: TMemo;
         AppIcon: TImage;
         AppIconPicture : TPicture;
         procedure OkButtonClick(Sender: TObject);
         procedure FormQueryClose(Sender: TObject; var CanClose: boolean);
         procedure DoTimerUpdate(sender: TObjecT);
         procedure DisposeEverything;
         procedure FocusMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      public
         constructor Create(ApplicationName : string;
                            ApplicationAck : string;
                            Disclaimer : string);
      end;

   procedure CreateVersionString;
   function MemStatusString : string;

var
   VersionString: string;
   VersionInfo: TOsVersionInfo;

implementation

constructor AppAbout.Create(ApplicationName : string;
                            ApplicationAck : string;
                            Disclaimer: string);

var
   aLabel: TLabel;
begin
   aLabel := TLabel.Create(Application);

   AboutForm:=TAboutForm.CreateNew(Application);
   with AboutForm do begin
        OnCloseQuery :=FormQueryClose;
        width:=400;
        //height:=300;
        BorderIcons:= [biSystemMenu];
        BorderStyle:= bsToolWindow;
        Caption:= 'About ' + ApplicationName;
        Position:= poScreenCenter;

      end;

   with aLabel do begin
        AboutForm.InsertControl(aLabel);
        Font.Height:=-9;
        Font.Name:='Arial';
        Font.Style:=[];
        ParentFont:=False;
        Autosize := True;
        WordWrap := True;
        Align := alTop;
        end;

   AppIconPicture:=TPicture.Create;
   with AppIconPicture do begin
      Icon:=Application.Icon;
      end;
   AppIcon:=TImage.Create(Application);
   with AppIcon do begin
      Picture:=AppIconPicture;
      AutoSize:=True;
      Top:=5;
      Left:=5;
      end;
   OkButton:=TButton.Create(Application);
   AboutForm.InsertControl(OkButton);
   with OkButton do begin
      OnClick := OkButtonClick;
      Caption:='Thank you!';
      Left:=(AboutForm.ClientWidth - OkButton.Width -1 );
      Top:=AppIcon.Top+(AppIcon.Height-Height) div 2;
      Cancel:=True;
      end;
   AboutText:=TLabel.Create(Application);
   with AboutText do begin
      Caption:=ApplicationName;
      Font.Color := clBlack;
      Font.Height := -18;
      Font.Name := 'Arial';
      Font.Style := [fsBold];
      ParentFont := False;
      Left:=(AboutForm.ClientWidth - Width - OkButton.Width + AppIcon.Width + AppIcon.Left) div 2;
      Top:=AppIcon.Top+(AppIcon.Height-Height) div 2;
      end;
   CopyRight:=TMemo.Create(Application);
   AboutForm.InsertControl(CopyRight);
   with CopyRight do begin
      OnMouseDown := FocusMouseDown;
      Alignment:=taCenter;
      WordWrap := True;
      Font := aLabel.Font;
      ParentFont:=False;
      Width:=AboutForm.ClientWidth - 2;
      Left:=(AboutForm.ClientWidth - Width) div 2;
      Top:=2*AppIcon.Top+AppIcon.Height;
      Text:=ApplicationAck;
      aLabel.Caption := Text;
      ClientHeight := aLabel.ClientHeight + abs(Font.Size);
      end;
   DoNotCopyRight:=TMemo.Create(Application);
   AboutForm.InsertControl(DoNotCopyRight);
   with DoNotCopyRight do begin
      OnMouseDown := FocusMouseDown;
      Alignment:=taCenter;
      WordWrap := True;
      Width:=AboutForm.ClientWidth - 2;
      Left:=(AboutForm.ClientWidth - Width) div 2;
      Top:=CopyRight.Top+CopyRight.Height;
      Font := aLabel.Font;
      ParentFont:=False;
      Text:=Disclaimer;
      aLabel.Caption := Text;
      ClientHeight := aLabel.ClientHeight + abs(Font.Size);
      end;
   CreateVersionString;
   VersionLabel:=TLabel.Create(Application);
   AboutForm.InsertControl(VersionLabel);
   with VersionLabel do begin
      Alignment:=taCenter;
      Caption:=VersionString+Chr(10)+Chr(13)+MemStatusString;
      Top:=DoNotCopyRight.Top+DoNotCopyRight.Height+5;
      Left:=(AboutForm.ClientWidth - Width) div 2;
      end;
   UpdateTimer:=TTimer.Create(Application);
   with UpdateTimer do begin
      Enabled:=True;
      OnTimer:=DoTimerUpdate;
      Interval:=5000;
      end;
   with AboutForm do begin
      ClientHeight:= VersionLabel.Top+VersionLabel.Height+5;
      InsertControl(AboutText);
      Insertcontrol(AppIcon);
      RemoveControl(aLabel);
      ShowModal;
      aLabel.Destroy;
      while AboutForm.ControlCount > 0 do AboutForm.Controls[0].Destroy;
      AboutForm.Destroy;
      end;
   end;

procedure AppAbout.OkButtonClick(Sender : TObject);
begin
   {must replace with formclose}
   DisposeEverything;
   end;

procedure AppAbout.FormQueryClose(Sender: TObject; var CanClose: boolean);
begin
   {must replace with formclose}
   DisposeEverything;
   end;

procedure TAboutForm.WMNCHitTest(var M: TWMNCHitTest);
begin
   inherited;
   if M.Result = htClient then
      M.Result := htCaption;
   end;

procedure CreateVersionString;
var
   SystInfo : TSystemInfo;
   i : integer;
   ProcessorId: PChar;
   tmp : string;
begin
   VersionInfo.dwOsVersionInfoSize:=sizeof(TOsVersionInfo);                     {$ifdef Debug} DebugForm.Debug('vi::sizeOf(TOsVersionInfo):'+IntToStr(sizeof(TOsVersionInfo))); {$endif}
   if (GetVersionEx(VersionInfo)=false) then begin
      VersionString:='<unable to get system information>';                      {$ifdef Debug} DebugForm.Debug('vi::failed API:GetVersionEx'); {$endif}
      exit;
      end;
   GetSystemInfo(SystInfo);                                                     {$ifdef Debug} DebugForm.Debug('vi::successful API:GetSystemInfo'); {$endif}
   VersionString:=ComputerName + ' is running on '+ IntToStr(SystInfo.dwNumberofProcessors);
   case SystInfo.wProcessorArchitecture of
      0: case SystInfo.wProcessorLevel of
      3,386: VersionString:=VersionString + ' Intel 386 processor';
      4,486: VersionString:=VersionString + ' Intel 486 processor';
      5,586: VersionString:=VersionString + ' Intel Pentium processor';
      else
      case SystInfo.dwProcessorType of
         1,386: VersionString:=VersionString + ' Intel 386 processor';
         2,486: VersionString:=VersionString + ' Intel 486 processor';
         3,586: VersionString:=VersionString + ' Intel Pentium processor';
         else VersionString:=VersionString + ' Intel processor';
         end;
         end;
      1: case SystInfo.wProcessorLevel of
      4: VersionString:=VersionString + ' Mips R4000 processor';
      else VersionString:=VersionString + ' Mips processor';
      end;
      2: case SystInfo.wProcessorLevel of
         21064: VersionString:=VersionString + ' Alpha 21064 processor';
         21066: VersionString:=VersionString + ' Alpha 21066 processor';
         21164: VersionString:=VersionString + ' Alpha 21164 processor';
         else VersionString:=VersionString + ' Alpha processor';
         end;
      3: case SystInfo.wProcessorLevel of
         1: VersionString:=VersionString + ' PowerPC 601 processor';
         3: VersionString:=VersionString + ' PowerPC 603 processor';
         4: VersionString:=VersionString + ' PowerPC 604 processor';
         6: VersionString:=VersionString + ' PowerPC 603+ processor';
         9: VersionString:=VersionString + ' PowerPC 604+ processor';
         20: VersionString:=VersionString + ' PowerPC 620 processor';
         else VersionString:=VersionString + ' PowerPC processor';
         end;
      end;
   if SystInfo.dwNumberofProcessors>1 then VersionString:=VersionString+'s';     {$ifdef Debug} DebugForm.Debug('vi::running on: '+VersionString); {$endif}
   ProcessorId:=StrAlloc(1024);                                                  {$ifdef Debug} DebugForm.Debug('vi::PlatForm Id:'+IntToStr(versionInfo.dwPlatFormId)); {$endif}
   try
   if VersionInfo.dwPlatformId = 2 then
   for i:=0 to SystInfo.dwNumberofProcessors - 1 do begin                        {$ifdef Debug} DebugForm.Debug('vi::(re)entering processor id query loop'); {$endif}
      StrPCopy(ProcessorId,'HARDWARE\DESCRIPTION\System\CentralProcessor\'+IntToStr(i)); {$ifdef Debug} DebugForm.Debug('vi::StrPCopy CentralProcessor'); {$endif}
      tmp:=QueryReg(HKEY_LOCAL_MACHINE,ProcessorId,'VendorIdentifier');
      if tmp<> '-1' then VersionString:=VersionString+Chr(13)+Chr(10)+tmp;
      tmp:=QueryReg(HKEY_LOCAL_MACHINE,ProcessorId,'Identifier');              {$ifdef Debug} DebugForm.Debug('vi::Reg queries returned successful.'); {$endif}
      if tmp<> '-1' then VersionString:=VersionString+' '+tmp;                                    {$ifdef Debug} DebugForm.Debug('vi::Reg queries returned successful.'); {$endif}
      tmp:=Trim(IntToStr(QueryReg(HKEY_LOCAL_MACHINE,ProcessorId,'~MHz')));
      if tmp <> '-1' then VersionString:=VersionString+' at '+ tmp + ' MHz';   {$ifdef Debug} DebugForm.Debug('vi::MegaHerts successful'); {$endif}
      end;
   finally
      StrDispose(ProcessorId);                                                  {$ifdef Debug} DebugForm.Debug('vi::successful API:StrDispose(processorId)'); {$endif}
   end;

   try
   VersionString:=VersionString + Chr(13)+Chr(10)+'under';                      {$ifdef Debug} DebugForm.Debug('vi::entering final runlevel'); {$endif}
   case VersionInfo.dwPlatformId of
      0 : VersionString:=VersionString + ' Windows 3.1x ';   {this should not be possible}
      1 : VersionString:=VersionString + ' Windows 95 ';
      2 : VersionString:=VersionString + ' Windows NT ';
      end;                                                                       {$ifdef Debug} DebugForm.Debug('vi::almost ready / case successful'); {$endif}
   except
         {$ifdef Debug} DebugForm.Debug('vi::exception raised at dwPlatFormId case query'); {$endif}
   end;

   try
   VersionString:=VersionString +
                  IntToStr(VersionInfo.dwMajorVersion) + '.' +
                  IntToStr(VersionInfo.dwMinorVersion) + ' (build '+
                  IntToStr(VersionInfo.dwBuildNumber and $FFFF)+')';
   except
         {$ifdef Debug} DebugForm.Debug('vi::exception raised at BuildNumber query'); {$endif}
   end;
   {$ifdef Debug} DebugForm.Debug('vi::finished.'); {$endif}
   end;

function MemStatusString : string;
var
   MemStatus: TMemoryStatus;
begin
   try
   MemStatus.dwLength:=sizeOf(TMemoryStatus);
   GlobalMemoryStatus(MemStatus);                                               {$ifdef Debug} DebugForm.Debug('vi::successful API:GlobalMemoryStats'); {$endif}
   MemStatusString:='Total memory : '+FormatFloat('#,###" Kb (physical)"', MemStatus.dwTotalPhys/1024)+FormatFloat(' #,###" Kb"', MemStatus.dwTotalPageFile/1024) + ' (page file)' + Chr(13)+Chr(10) +
                    'Free memory : '+FormatFloat('#,###" Kb (physical)"', MemStatus.dwAvailPhys/1024)+FormatFloat(' #,###" Kb"', MemStatus.dwAvailPageFile/1024) + ' (page file)';
   except
   MemStatusString:='<unable to get memory information>';                        {$ifdef Debug} DebugForm.Debug('vi::exception raised at GetMemory'); {$endif}
   end;
   end;

procedure AppAbout.DoTimerUpdate(Sender: TObject);
begin
   with VersionLabel do begin
      Caption:=VersionString+Chr(10)+Chr(13)+MemStatusString;
      Top:=AboutForm.ClientHeight - VersionLabel.Height - 5;
      end;
   end;

procedure AppAbout.DisposeEverything;
begin
   UpdateTimer.Enabled:=False;
   AboutForm.ModalResult:=mrOk;
   end;

procedure TAboutForm.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   with M.WindowPos^ do begin
      if x<0 then x:=0;
      if y<0 then y:=0;
      if x+cx>Screen.Width then x:=Screen.Width-cx;
      if y+cy>Screen.Height then y:=Screen.Height-cy;
      end;
  end;


procedure AppAbout.FocusMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     if OkButton.Showing then OkButton.SetFocus;
     end;

end.


