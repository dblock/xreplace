program xrep32;
{(c) Daniel Doubrovkine - 1996 - Stolen Technologies Inc. - University of Geneva }

uses
  Forms,
  Dialogs,
  xreplace in '..\Classes\XReplace\xreplace.pas' {xRepl32},
  RForm in '..\Classes\XReplace\RForm.pas' {ReplaceForm},
  TExec in '..\Classes\XReplace\TExec.pas',
  lzh in '..\Classes\XReplace\lzh.pas',
  MDlg in '..\Classes\XReplace\MDlg.pas' {MsgForm},
  xopt in '..\Classes\XReplace\xopt.pas' {XOptions},
  xlog in '..\Classes\XReplace\xlog.pas',
  StatForm in '..\Classes\XReplace\StatForm.pas',
  TPicFile in '..\Classes\PicFile\TPicFile.pas',
  wait in '..\Classes\XReplace\wait.pas',
  XRClasses in '..\Classes\XReplace\xrClasses.pas',
  xplugins in '..\Classes\XReplace\xplugins.pas',
  d32about in '..\Classes\Common\d32about.pas',
  d32debug in '..\Classes\Common\d32debug.pas',
  d32errors in '..\Classes\Common\d32errors.pas',
  d32gen in '..\Classes\Common\d32gen.pas',
  d32reg in '..\Classes\Common\d32reg.pas',
  xrintro in '..\Classes\XReplace\xrintro.pas' {XRIntroForm},
  ffProperties in '..\Classes\XReplace\ffProperties.pas' {FFProp},
  StrDropGrid in '..\Classes\StrDropGrid\StrDropGrid.pas',
  ShellView in '..\Classes\ShellView\ShellView.pas',
  PidlManager in '..\Classes\ShellView\PidlManager.pas',
  CPidl in '..\Classes\ShellView\CPidl.pas',
  TDropV in '..\Classes\DropView\TDropV.pas',
  TAdderThread in '..\Classes\DropView\TAdderThread.pas',
  globals in '..\Classes\XReplace\globals.pas',
  xshedule in '..\Classes\XReplace\xshedule.pas' {xFShedule},
  HlpBrowser in '..\Classes\XReplace\HlpBrowser.pas' {HtmlHelp},
  macro in '..\Classes\XReplace\macro.pas' {MacroEdit};

{$R *.RES}
begin
  Application.Initialize;
  InitializeGlobals;
  Application.Run;

end.


