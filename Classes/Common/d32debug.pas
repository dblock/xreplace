unit d32debug;

interface

uses Classes, Forms, Messages, StdCtrls, SysUtils;

  {$ifdef Debug}
type
  TDebugForm=class(TForm)
     DebugMemo : TMemo;
     procedure Debug(Msg: string);
     procedure DebugDouble(Msg: string);
     end;
  {$endif}

  {$ifdef Debug}
   procedure InitDebug;
  {$endif}

  {$ifdef Debug}
  var
   DebugForm : TDebugForm;
  {$endif}

implementation

{$ifdef Debug}
procedure InitDebug;
begin
   if Assigned(DebugForm) then exit;
   DebugForm := TDebugForm.CreateNew(Application);
   with DebugForm do begin
      BorderStyle:=bsSingle;
      Caption:='Internal Debugger (c) D.D. - 1996, handle: '+IntToStr(Handle);
      Position:=poDesigned;
      Width:=800;
      Height:=200;
      Show;
      end;
   DebugForm.DebugMemo:= TMemo.Create(Application);
   with DebugForm.DebugMemo do begin
      Left:=1;
      Top:=1;
      Width:=DebugForm.ClientWidth-2;
      Height:=DebugForm.ClientHeight-2;
      Visible:=True;
      Text:='Initialized debug session...';
      ScrollBars:=ssVertical;
      end;
   DebugForm.InsertControl(DebugForm.DebugMemo);
   end;

procedure TDebugForm.DebugDouble(Msg: string);
begin
   try
   if DebugMemo.Lines[DebugMemo.Lines.Count-1]<>Msg then Debug(Msg);
   except
   InitDebug;
   end;
   end;

procedure TDebugForm.Debug(Msg: string);
begin
   {if not Application.Terminated then }DebugMemo.Lines.Add(Msg);
   end;

{$endif}

begin
     {$ifdef Debug}
     InitDebug;
     {$endif}
     end.
