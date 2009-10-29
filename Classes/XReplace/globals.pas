unit globals;

interface

procedure InitializeGlobals;

implementation

uses
  sysutils,
  Forms,
  Dialogs,
  xreplace,
  xrintro,
  ffproperties,
  mdlg,
  {$ifdef Registered}
  batch,
  xshedule,
  actives,
  macro,
  {$endif}
  {$ifdef Debug}
  d32debug,
  {$endif}
  d32gen;

procedure AnalyseParam;
var
   i: integer;
   CurrentParam: string;
   ContainerFileHandle: integer;
   //---
   pExec: boolean;
   pQuit: boolean;
   cLoaded: boolean;
begin

   {$ifndef Registered}
   if(ParamCount > 0) then begin
      MDlg.MsgForm.MessageDlg(
         'Registered version feature exclusively! Command line parameters ignored.',
         'Unable to inititalize batch mode for replacements. This is a Registered version of XReplace-32 feature only! '+
         'You may register online at http://www.vestris.com.',
         mtError,[mbOk],0,'');
      exit;
      end;
   {$else}

     if ParamCount = 0 then exit;
     xRepl32.ReplaceLog.oLog('batch mode for '+XRVersion+' successfully initialized.','batch',XReplaceOptions.Log.Batch);
     pExec:=True;
     pQuit:=True;
     cLoaded:=False;
     for i:=1 to ParamCount do begin

         CurrentParam := Trim(ParamStr(i));

         if CurrentParam[1] in ['-','/'] then begin
            Delete(CurrentParam, 1, 1);
            end;

         if (CompareText(CurrentParam, 'noexec') = 0) then begin
            pExec:=False
         end else if (CompareText(CurrentParam, 'noquit') = 0) then begin
            pQuit:=False
         end else begin

            initUnattended;
            Unattended.xCaption.Caption:=XRVersion;
            Unattended.Show;

            ContainerFileHandle := FileOpen(ParamStr(i), fmOpenRead);
            if ContainerFileHandle > 0 then begin
               if (xRepl32.ContainerVersion(ContainerFileHandle)<> -1) then begin
                  xRepl32.ReplaceLog.oLog('command line arg identified as container: ' + CurrentParam, 'batch',
                                          XReplaceOptions.Log.Batch);
                  FileClose(ContainerFileHandle);
                  xRepl32.DisableEverything;
                  xRepl32.LoadContainer(CurrentParam);
                  cLoaded := True;
                  end else begin
                  xRepl32.ReplaceLog.oLog('command line arg assumed as macro: ' + CurrentParam, 'batch',
                                          XReplaceOptions.Log.Batch);
                  FileClose(ContainerFileHandle);
                  xRepl32.MacroExecute(CurrentParam, true);
                  pExec:=False;
                  end;
               end else begin
               xRepl32.ReplaceLog.oLog('invalid command line parameter (unable to open file): '+ CurrentParam,
                                       'batch',XReplaceOptions.Log.Batch);
               end;
            end;
         end;

      xRepl32.ReplaceLog.oLog('automatic replacements execution at command line set to ' +
         BoolToStr(pExec), 'batch', XReplaceOptions.Log.Batch);
      xRepl32.ReplaceLog.oLog('automatic termination at command line set to ' +
         BoolToStr(pQuit), 'batch', XReplaceOptions.Log.Batch);

      if pExec and cLoaded then begin
        xRepl32.sbGo.Click;
        end;

     if not xRepl32.InterruptReplace then begin
        xRepl32.SetGridEdit;
        if Unattended <> nil then begin
            Unattended.Hide;
            end;
        if pQuit then begin
            xRepl32.ReplaceLog.oLog('command line unforced terminate invoked.', 'batch',
            XReplaceOptions.Log.Batch);
            xRepl32.TerminateXReplace(True);
            end;
        end else begin
         xRepl32.ReplaceLog.oLog('command line operation has been interrupted, loading XReplace-32 interface.',
                                 'batch', XReplaceOptions.Log.Batch);
        end;
     {$endif}
     end;

procedure InitializeGlobals;
begin
  {$IfDef Debug}InitDebug;{$EndIf}
  Application.Title := 'XReplace-32';
  Application.CreateForm(TxRepl32, xRepl32);
  xRepl32.ErrorMessages:=True;

  {$IFDEF Debug}DebugForm.Debug('xRep32::Application.CreateForm has finished.');{$ENDIF}

  {$ifdef Registered}
  if (XReplaceOptions.Repl.NoErrors) then begin
      xRepl32.ErrorMessages:=False;
      xRepl32.ReplaceLog.oLog('error messages disabled for batch mode.','batch',XReplaceOptions.Log.Batch);
      end else begin
      xRepl32.ErrorMessages:=True;
      xRepl32.ReplaceLog.oLog('error messages maintained for batch mode.','batch',XReplaceOptions.Log.Batch);
      end;
  {$endif}

  {$IFDEF Debug}DebugForm.Debug('xRep32::AnalyseParam.');{$ENDIF}

  AnalyseParam;

  {$ifDef Registered}
  if (xReplaceOptions.Gen.SAutoLoad) then begin
     if (XReplaceOptions.Repl.NoErrors) then
         xRepl32.ErrorMessages:=False
     else xRepl32.ErrorMessages:=True;
     xRepl32.Show;
     initActiveX;
     ActiveX.SActivate;
     end;
  {$endIf}

  {$IFDEF Debug}DebugForm.Debug('xRep32::Application.Run.');{$ENDIF}
  {$IFDEF Debug}DebugForm.Debug('xRep32::directory is ' + Xrepl32.ShellSpace.Directory);{$ENDIF}
   end;

end.
