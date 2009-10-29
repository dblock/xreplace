unit xlog;

interface

uses xOpt, Classes, MDlg, Dialogs,Windows, Messages, SysUtils,
     Controls, FileCtrl, Forms, d32reg, d32gen, d32errors, d32debug 
     {$ifdef registered}, batch{$endif}
     ;

type

PLog = ^TLog;
TLog = class
   private
      Running : boolean;
      Stream  : TFileStream;
      Options : TLogOptions;
   public
      procedure Init(iOptions: TLogOptions);
      procedure CleanUp;
      procedure CleanLog(iLog: string);
      procedure Log(iLog: string);
      procedure oLog(iLog: string; iType: string; iCheck: boolean);
   end;

implementation

uses XReplace;

procedure TLog.CleanUp;
begin
   if not Running then exit;
   if Stream <> nil then begin
      Stream.Destroy;
      Stream := nil;
      end;
   Running:=False;
   end;

procedure TLog.Init(iOptions: TLogOptions);
   procedure PromptInterrupt;
   begin
         {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::PromptedInterript.');{$ENDIF}
         {$ifdef Registered}if Unattended <> nil then{$endif} 
         if {$ifdef Registered}Unattended.Visible and {$endif}(not XReplaceOptions.Repl.NoErrors) then begin
         initMdlg;
         If (MsgForm.MessageDlg('You have chosen to create a Log file, but you have entered an invalid Log filename. Do you wish to continue?',
                             'The Create Log option is enabled, but an invalid or no filename for the Log file has been specified. '+
                             'This could be caused by a Log filename containing a fully qualified path and the Single Log option disabled. '+
                             'You may continue the replacements without creating a log file or cancel the operation and correct this problem.',
                              mtError,[mbYes, mbNo],0,''))= mrNo then begin
                              xRepl32.InterruptReplace:=True;
                              end;
         end;
       end;
begin
   try Options:=iOptions; except {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::iOptions desig exception raised.');{$ENDIF} end;

   try
   if Running then begin                                                         {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::Log is running.');{$ENDIF}
      if (not Options.Create) then begin
         Log('log closed.');
         CleanUp;                                                                {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::NoOptionsCreate.CleanUp:ok');{$ENDIF}
         exit;
         end else
      if not Options.Append then begin
         CleanUp;                                                                {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::NoOptionsAppend.CleanUp:ok');{$ENDIF}
         end else exit;
      end;
   except {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::cleanup / init exception raised.');{$ENDIF} end;
   Running:=False;                                                               {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::Options.Create:'+BoolToStr(Options.Create));{$ENDIF}

   if not Options.Create then exit;                                              {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::NoOptionsCreate.Exit:positive, step forward.');{$ENDIF}

   if (Pos('*',Options.LogFile)<>0) or
      (Pos('?',Options.LogFile)<>0) then begin
         PromptInterrupt;
         exit;
         end;                                                                    {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::LogName.Step1:ok');{$ENDIF}

   if DirectoryExists(Options.LogFile) then begin
      PromptInterrupt;
      exit;
      end;                                                                       {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::LogName.Step2:ok');{$ENDIF}

   {if ExtractFilePath(Options.LogFile)<>'' then begin
      if not Options.single then begin
         PromptInterrupt;
         exit;
         end;
      end;}

   if Length(Options.LogFile)=0 then begin
      PromptInterrupt;
      exit;
      end;                                                                       {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::LogName.Step3:ok');{$ENDIF}

   try                                                                           {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::ProtectedBlock.Entering');{$ENDIF}
   if (FileExists(Options.LogFile)) then begin
      if Options.Append then begin
         Stream:=TFileStream.Create(Options.LogFile, fmOpenWrite or fmShareDenyWrite);   {$IFDEF Debug}DebugForm.Debug('TLog::(1)StreamCreate:ok');{$ENDIF}
         Stream.Seek(0, 2);                                                              {$IFDEF Debug}DebugForm.Debug('TLog::(1)StreamSeek:ok');{$ENDIF}
         Running:=True;                                                                  {$IFDEF Debug}DebugForm.Debug('TLog::(1)Running.True');{$ENDIF}
         xRepl32.ReplaceLog.oLog('log file reopened by '+XRVersion + ' '+XRbuild,'',XReplaceOptions.Log.Everything);{$IFDEF Debug}DebugForm.Debug('TLog::(1)LogEverything');{$ENDIF}
         end else begin
         Stream:=TFileStream.Create(Options.LogFile, fmCreate);                          {$IFDEF Debug}DebugForm.Debug('TLog::(2)StreamCreate:ok');{$ENDIF}
         Stream.Destroy;                                                                 {$IFDEF Debug}DebugForm.Debug('TLog::(2)StreamDestroy:ok');{$ENDIF}
         Stream:=TFileStream.Create(Options.LogFile, fmOpenWrite or fmShareDenyWrite);   {$IFDEF Debug}DebugForm.Debug('TLog::(2)StreamOpen:ok');{$ENDIF}
         Running:=True;                                                                  {$IFDEF Debug}DebugForm.Debug('TLog::(2)Running.True');{$ENDIF}
         xRepl32.ReplaceLog.oLog('log file created by '+XRVersion + ' '+XRbuild,'',XReplaceOptions.Log.Everything); {$IFDEF Debug}DebugForm.Debug('TLog::(2)LogEverything');{$ENDIF}
         end;
      end else begin
         Stream:=TFileStream.Create(Options.LogFile, fmCreate);                          {$IFDEF Debug}DebugForm.Debug('TLog::(3)StreamCreate:ok');{$ENDIF}
         Stream.Destroy;                                                                 {$IFDEF Debug}DebugForm.Debug('TLog::(3)StreamDestroy:ok');{$ENDIF}
         Stream:=TFileStream.Create(Options.LogFile, fmOpenWrite or fmShareDenyWrite);   {$IFDEF Debug}DebugForm.Debug('TLog::(3)StreamOpen:ok');{$ENDIF}
         Running:=True;                                                                  {$IFDEF Debug}DebugForm.Debug('TLog::(3)Running.True');{$ENDIF}
         xRepl32.ReplaceLog.oLog('log file created.','',XReplaceOptions.Log.Everything); {$IFDEF Debug}DebugForm.Debug('TLog::(3)LogEverything');{$ENDIF}
         end;
                                                                                {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::ProtectedBlock:ok');{$ENDIF}
   except
                                                                               {$IFDEF Debug}DebugForm.Debug('TxRepl32.TLog.Init::ProtectedBlock:exception raised.');{$ENDIF}
      {$ifdef Registered}if Unattended <> nil then{$endif} 
      if {$ifdef registered}Unattended.Visible and {$endif}(not XReplaceOptions.Repl.NoErrors) then begin
      initMdlg;
      if MsgForm.MessageDlg('XReplace was unable to open / create a Log file : '+ Options.LogFile,
               'XReplace-32 has raised an exception while creating the Log file. Please check that the name is valid. '+
               'You may ignore this error and continue without a log file or abort the replacements operation in case there is one currently running.'+
               'You should correct the name of the log file in order to avoid this error next time you load XReplace-32.',
               mtError,[mbIgnore]+[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError))=mrAbort then xRepl32.InterruptReplace:=True;
               end;
      exit;

   end;
   end;

procedure TLog.Log(iLog: string);
var
   iStr: string;
begin
   if Options.Timings then iStr:=DateToStr(Date)+' '+TimeToStr(Time)+' '+':: '+iLog
                      else iStr:=iLog;
   CleanLog(iStr);
   end;

procedure TLog.CleanLog(iLog: string);
begin
   try
      if (not Running) then exit;
      if Stream <> nil then begin
         Stream.Write(PChar(iLog+#13#10)^, (Length(iLog)+2)*SizeOf(Char));
         end;
   except
      {$ifdef Registered}if Unattended <> nil then{$endif}
      if {$ifdef registered}Unattended.Visible and {$endif}(not XReplaceOptions.Repl.NoErrors) then begin
         initMdlg;
         if MsgForm.MessageDlg('XReplace was unable to write to a Log file : '+ Options.LogFile,
               'XReplace-32 has raised an exception while writing to the Log file. '+
               'You may ignore this error and continue without a log file or abort the replacements operation.',
               mtError,[mbIgnore]+[mbAbort],0,'[' + IntToStr(GetLastError) + '] ' + ErrorRaise(GetLastError))=mrAbort then xRepl32.InterruptReplace:=True;
         end;
         Running:=False;

      if Stream <> nil then begin
         Stream.Destroy;
         Stream := nil;
         end;

      exit;
   end;
   end;

procedure TLog.oLog(iLog, iType: string; iCheck: boolean);
begin
     if iCheck then begin
        if (iType <> '') then Log(iType+'::'+Trim(iLog))
        else Log(iLog);
        end;
     end;

end.
