unit wait;

interface

uses
  Classes, Forms, SysUtils, Dialogs, ComCtrls, StdCtrls, Messages, Wintypes, mdlg;

type
   TWaitForm = class(TForm)
       procedure WMNCHitTest(var M: TWMNCHitTest); message WM_NCHitTest;
       end;

  TWorking = class(TThread)
  private
        iCaption: string;
        iPosition: LongInt;
        Moved: boolean;
        iBar: TProgressBar;
        iLabel: TLabel;
        iForm: TWaitForm;
        Killed: boolean;
        TimeStarted: TDateTime;
        TimeMoving: TDateTime;   //time to start moving in seconds
        isVisible: boolean;
        procedure iFormCreate;
        procedure Execute; override;
        procedure QueryVisible;
        procedure iFormShow;
  public
        constructor Create;
        procedure Kill;
        procedure oMessage(iStr: string);
        procedure oStatus(iInt: integer);
  end;

implementation

var
   isRunning: integer = 0;


{ TWorking }

constructor TWorking.Create;
var
   Hour, Min, Sec, MSec: Word;
begin
     TimeStarted:=Now;
     Priority:=tpLower;
     FreeOnTerminate:=True;
     DecodeTime(TimeStarted, Hour, Min, Sec, MSec);
     try TimeMoving:=EncodeTime((Hour + (Min + (Sec + 3) div 60) div 60) mod 24, (Min + (Sec + 3) div 60) mod 60, (Sec + 3) mod 60, MSec); except end;
     Killed:=False;
     Moved:=False;
     iCaption:='Please wait...';
     iPosition:=0;
     inherited Create(False);
     end;

procedure TWorking.QueryVisible;
begin
     try
     isVisible := MsgForm.isVisible or (isRunning > 0)
     except
     isVisible := False;
     end;
     end;

procedure TWorking.iFormCreate;
begin
     Moved:=True;
     iForm := TWaitForm.CreateNew(Application);
     with iForm do begin
          Position:=poScreenCenter;
          BorderStyle:=bsToolWindow;
          BorderIcons:=[];
          FormStyle:=fsStayOnTop;
          Caption:='XReplace-32';
          end;
     iBar:=TProgressBar.Create(iForm);
     iLabel:=TLabel.Create(iForm);
     iForm.InsertControl(iBar);
     iForm.InsertControl(iLabel);
     with iForm do begin
          Width:=iBar.Width + 20;
          Height:=iBar.Height + iLabel.Height + 50;
          end;
     with iLabel do begin
          Caption:=iCaption;
          Left:=10;
          Top:=5;
          Height := 20;
          Width := (iForm.ClientWidth - Left * 2);
          WordWrap := True;
          Font.Name := 'Arial';
          Font.Size := 8;
          end;
     with iBar do begin
          Height:=Height div 2;
          Left:=(iForm.ClientWidth - iBar.Width) div 2;
          Top:=(iForm.ClientHeight + iLabel.Height + iLabel.Top - iBar.Height) div 2;
          Position:=iPosition;
          end;
     if Killed then exit;
     end;

procedure TWorking.iFormShow;
begin
     iForm.Show;
     inc(isRunning);
     end;

procedure TWorking.Execute;
var
   Hour, Min, Sec, MSec: Word;
   NowTime: TDateTime;
begin
     while not Killed do begin
           Application.ProcessMessages;
           if not Moved then begin
              NowTime:=Now;
              try DecodeTime(NowTime, Hour, Min, Sec, MSec); except end;
              try NowTime:=EncodeTime(Hour, Min, Sec, MSec); except end;
              if NowTime >= TimeMoving then begin
                 Synchronize(QueryVisible);
                 while isVisible do begin
                       if Killed then break;
                       Application.ProcessMessages;
                       Synchronize(QueryVisible);
                       end;
                 if Killed then break;
                 Synchronize(iFormCreate);
                 while (isRunning > 0) and (not Killed) do Sleep(0);
                 if Killed then break;
                 Synchronize(iFormShow);
                 end;
              end;
           end;
     end;

procedure TWorking.Kill;
begin
     try
     Killed:=True;
     if Moved then begin
        iForm.Destroy;
        dec(isRunning);
        end;
     Moved:=False;
     except
     end;
     end;

procedure tWorking.oMessage(iStr: string);
begin
     try
     iCaption:=iStr;
     if Moved then begin
        iLabel.Caption:=iStr;
        end;
     except
     end;
     end;

procedure tWorking.oStatus(iInt: integer);
begin
     try
     iPosition:=iInt;
     if Moved then begin
        iBar.Position:=iInt;
        end;
     except
     end;
     end;

procedure TWaitForm.WMNCHitTest(var M: TWMNCHitTest);
begin
   inherited;
   if M.Result = htClient then
      M.Result := htCaption;
   end;


end.
