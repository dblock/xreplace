unit actives;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, dshedule, ComCtrls, StdCtrls, TrayIcon,
  Menus, d32reg, d32gen, d32errors, d32debug;

const
  DayType : array[1..7] of string = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
  MonthType : array[1..12] of string =  ('January','February','March','April','May','June','July','August','September','October','November','December');

type
  TActiveX = class(TForm)
    xPanel: TPanel;
    ccPanel: TPanel;
    STimer: TTimer;
    ActivePanel: TPanel;
    ExecHistory: TTreeView;
    Panel1: TPanel;
    cTopPanel: TLabel;
    Panel2: TPanel;
    SheduleMacros: TSpeedButton;
    MacroEditor: TSpeedButton;
    ActivClose: TSpeedButton;
    cPanel: TLabel;
    SheduleTray: TTrayIcon;
    TrayMenu: TPopupMenu;
    CloseActivXR1: TMenuItem;
    MacroEditor1: TMenuItem;
    N1: TMenuItem;
    MacroShedule1: TMenuItem;
    N2: TMenuItem;
    AboutXReplace321: TMenuItem;
    procedure STimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ExecHistoryChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ExecHistoryCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure ActivCloseClick(Sender: TObject);
    procedure MacroEditorClick(Sender: TObject);
    procedure SheduleMacrosClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SheduleTrayClick(Sender: TObject);
    procedure AboutXReplace321Click(Sender: TObject);
  private
    MacroShown: boolean;
    SheduleShown: boolean;
    SheduleWorking: boolean;
    rHour, rMin: integer;
    MinHeight, MinWidth: integer;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message WM_WINDOWPOSCHANGING;
  public
    procedure SActivate;
    procedure SDeActivate;
  end;

  procedure initActiveX;

var
  ActiveX: TActiveX = nil;

implementation

uses xreplace, xshedule, macro, MDlg, xopt;

{$R *.DFM}

procedure initActiveX;
begin
     if ActiveX = nil then begin
        Application.CreateForm(TActiveX, ActiveX);
        end;
     end;

procedure TActiveX.WMSysCommand(var Msg: TWMSysCommand);
begin
   if Msg.CmdType=SC_MINIMIZE then begin
      Self.Hide;
      SheduleTray.Active:=True;
      end else inherited;
   end;

procedure TActiveX.SActivate;
begin
     xRepl32.ReplaceLog.oLog('ActivXR activated.','schedule',XReplaceOptions.Log.Shed);

     xRepl32.Enabled:=False;
     if Assigned(MacroEdit) then MacroEdit.Enabled:=False;
     if Assigned(XFShedule) then xFShedule.Enabled:=False;

     rHour:=-1;
     rMin:=-1;
     xRepl32.Hide;

     if Assigned(MacroEdit) and MacroEdit.Visible then begin
        MacroShown := True;
        MacroEdit.Hide;
        end else MacroShown := False;

     if Assigned(XFShedule) and XFShedule.Visible then begin
        XFShedule.Hide;
        SheduleShown := True;
        end else SheduleShown := False;

     ActiveX.Perform(WM_SYSCOMMAND, SC_MINIMIZE, 0);
     //ActiveX.Show;
     STimer.Enabled:=True;
     ActiveX.ActivePanel.Color:=clGreen;
     xRepl32.MActivate.Caption := '&Deactivate!';
     STimer.OnTimer(Application);
     end;

procedure TActiveX.SDeActivate;
begin
     while SheduleWorking do Application.ProcessMessages;
     STimer.Enabled:=False;

     xRepl32.Enabled:=True;
     if MacroEdit <> nil then MacroEdit.Enabled:=True;
     if xfShedule <> nil then xFShedule.Enabled:=True;
     if MacroShown then MacroEdit.Show;
     if SheduleShown then XFShedule.Show;
     Application.Restore;

     xRepl32.ErrorMessages:=True;

     xRepl32.MActivate.Caption := '&Activate!';
     ActiveX.ActivePanel.Color:=clBtnFace;
     SheduleTray.Active := False;
     ActiveX.Hide;
     xRepl32.Show;
     xRepl32.ReplaceLog.oLog('ActivXR deactivated.','schedule',XReplaceOptions.Log.Shed);
     end;

procedure TActiveX.STimerTimer(Sender: TObject);
          function BoolToStr(iB: boolean): string;
          begin
               if iB then Result:='True' else Result:='False';
               end;
          function MatchIn(Source, Target: string): boolean;
          var
             i, j: integer;
             mSource, mTarget, oldTarget: string;
          begin
               Result:=False;
               if Length(Source)=0 then exit;
               if (Source<>'') then Source:=Source + ',';
               i:=Pos(',',Source);
               while (i<>0) do begin
                     mSource := Copy(Source, 1, i - 1);
                     //target side
                     oldTarget:=Target;
                     if Length(oldTarget) = 0 then exit;
                     if (oldTarget<>'') then OldTarget:=oldTarget+',';
                     j:=Pos(',',oldTarget);
                     while j<>0 do begin
                           mTarget:=Copy(oldTarget, 1, j - 1);
                           if CompareText(mSource,mTarget)=0 then begin
                              Result:=True;
                              exit;
                              end;
                           Delete(OldTarget, 1, j + 1);
                           j:=Pos(',',oldTarget);
                           end;
                     Delete(Source, 1, i + 1);
                     i:=Pos(',',Source);
                     end;
                 Result:=False;
                 //ShowMessage('found!');
               end;
          procedure ExecuteEvent(iEvent: PxEvent; iNow: PShedule; Present: TDateTime);
          begin
               with iEvent.eShedule^ do begin
                    if MatchIn(eTimeVal, iNow^.eTimeVal) then
                       if MatchIn('Weekday',eDayName) or MatchIn(eDayName, iNow^.eDayName) then
                          if MatchIn('Month',eMonName) or MatchIn(eMonName, iNow^.eMonName) then
                             if (eDayNum = '') or MatchIn(eDayNum, iNow^.eDayNum) then
                                if MatchIn('Year',eYearVal) or MatchIn(eYearVal, iNow^.eYearVal) then begin
                                   //xPanel.Caption:='executing '+iEvent^.eFileName
                                   xRepl32.ReplaceLog.oLog('executing '+iEvent^.eFileName + ' (ActivXR)','schedule',XReplaceOptions.Log.Shed);
                                   if xRepl32.MacroExecute(iEvent^.eFileName, True) then begin
                                      ExecHistory.Items.AddChild(ExecHistory.Items.GetFirstNode, iEvent^.eFileName + ' -> '+DateToStr(Present)+' '+TimeToStr(Present));
                                      xRepl32.ReplaceLog.oLog(iEvent^.eFileName + ' -> '+DateToStr(Present)+' '+TimeToStr(Present)+ ' successfully executed.','schedule',XReplaceOptions.Log.Shed);
                                      end else begin
                                      ExecHistory.Items.AddChild(ExecHistory.Items.GetFirstNode, iEvent^.eFileName + ' -> '+DateToStr(Present)+' '+TimeToStr(Present)+ ' (there were errors)');
                                      xRepl32.ReplaceLog.oLog(iEvent^.eFileName + ' -> '+DateToStr(Present)+' '+TimeToStr(Present)+ ' executed with errors.','schedule',XReplaceOptions.Log.Shed);
                                      end;
                                   ExecHistory.Items.GetFirstNode.Expand(True);
                                   end;
                    end;
               end;
          function CreateEvent(iNode: TTreeNode): pXEvent;
          begin
               new(Result);
               with Result^ do begin
                    eFileName:=iNode.Parent.Text;
                    eShedule:=iNode.Data;
                    end;
               end;
var
   iEvent: PxEvent;
   iNode: TTreeNode;
   isNode: TTreeNode;
   iNow: PShedule;
   Year, Month, Day, Hour, Min, Sec, MSec: Word;
   iCount: integer;
   Present: TDateTime;
begin
   initXFShedule;
   Present:=Now;
   DecodeDate(Present, Year, Month, Day);
   DecodeTime(Present, Hour, Min, Sec, MSec);
   cTopPanel.Caption:=Format('%.2d:%.2d:%.2d', [Hour, Min, Sec]);
   if SheduleWorking then exit;
   SheduleWorking:=True;
   //--- create the now shedule event
   if (rHour = Hour) and (rMin = Min) then begin
      SheduleWorking:=False;
      exit;
      end;
   rHour:=Hour;
   rMin:=Min;
   iCount:=0;
   new(iNow);
   with iNow^ do begin
      //eDayName:=DayType[Day];
      eMonName:=MonthType[Month];
      eDayNum:=IntToStr(Day);
      eYearVal:=IntToStr(Year);
      eTimeVal:=Format('%.2d:%.2d', [Hour, Min]);
      eDayName:=DayType[DayOfWeek(Present)];
      //ShowMessage(eDayNum+' '+eDayName+' '+eMonName+' '+eYearVal+' '+eTimeVal);
      end;
   //---
   iNode:=xFShedule.SheduleTree.Items.GetFirstNode.GetFirstChild;
   while iNode <> nil do begin

         iSNode:=iNode.GetFirstChild;
         while iSNode<>nil do begin
               iEvent:=CreateEvent(iSNode);
               inc(iCount);
               ccPanel.Enabled:=False;
               ExecuteEvent(iEvent, iNow, Present);
               ccPanel.Enabled:=True;
               iSNode:=iSNode.GetNextSibling;
               end;

         iNode:=iNode.GetNextSibling;
         end;
   if iCount = 0 then begin
      if not XReplaceOptions.Gen.SEmptyActivate then begin
         if xRepl32.ErrorMessages then begin
         initMDlg;
         (MsgForm.MessageDlg('ActivXR activation is useless. No events scheduled.',
               'XReplace-32 was asked to activate the Schedule ActivXR module for time and date scheduled events. There are though no events scheduled. The module will be closed.',
               mtError,[mbOk],0,''));
               end;
         SheduleWorking:=False;
         SDeActivate;
         exit;
         end;
         end;

   cPanel.Caption:=IntToStr(iCount) + ' event(s) scheduled.';
   SheduleTray.ToolTip := 'XReplace-32 - ' + IntToStr(iCount) + ' event(s) scheduled.';
   SheduleWorking:=False;
   end;

procedure TActiveX.FormCreate(Sender: TObject);
var
   ch, cw: integer;
begin
     MinHeight := Height;
     MinWidth := Width;
     try cw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\shedule\',
                    'activXR width'); except cw:=0; end;
     try ch:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\shedule\',
                    'activXR height'); except ch:=0; end;
     if cw>=0 then ActiveX.Width:=cw;
     if ch>=0 then ActiveX.Height:=ch;
     try cw:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\shedule\',
                    'activXR left'); except cw:=0; end;
     try ch:=QueryReg(HKEY_CURRENT_USER,
                    RootQuery + '\shedule\',
                    'activXR top'); except ch:=0; end;
     if cw>=0 then ActiveX.Left:=cw else ActiveX.Left:=(Screen.Width - ActiveX.Width) div 2;
     if ch>=0 then ActiveX.Top:=ch  else ActiveX.Top:=(Screen.Height - ActiveX.Height) div 2;

     SheduleWorking:=False;
     ActiveX.Resize;
     rHour:=-1;
     rMin:=-1;
     end;

procedure TActiveX.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   SDeActivate;
   end;

procedure TActiveX.ExecHistoryChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
   AllowChange:=False;
   end;

procedure TActiveX.ExecHistoryCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
   AllowCollapse:=False;
   end;

procedure TActiveX.ActivCloseClick(Sender: TObject);
begin
   ActiveX.SDeActivate;
   XRepl32.Show;
   end;

procedure TActiveX.MacroEditorClick(Sender: TObject);
begin
   ActiveX.SDeActivate;
   initMacroEdit;
   MacroEdit.Show;
   end;

procedure TActiveX.SheduleMacrosClick(Sender: TObject);
begin
   ActiveX.SDeActivate;
   xRepl32.SheduleClick(Sender);
   end;

procedure TActiveX.FormDestroy(Sender: TObject);
begin
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\shedule\',
                               'activXR height',
                               ActiveX.Height);
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\shedule\',
                               'activXR width',
                               ActiveX.Width);
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\shedule\',
                               'activXR top',
                               ActiveX.Top);
   AddReg(HKEY_CURRENT_USER,   RootUpdate + '\shedule\',
                               'activXR left',
                               ActiveX.Left);
   end;


procedure TActiveX.SheduleTrayClick(Sender: TObject);
begin
     SheduleTray.Active := False;
     ActiveX.Show;
     end;

procedure TActiveX.AboutXReplace321Click(Sender: TObject);
begin
     xRepl32.AboutXReplace321.Click;
     end;

procedure TActiveX.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   try
   inherited;
   with M.WindowPos^ do begin
      if (cx < MinWidth) then cx := MinWidth;
      if (cy < MinHeight) then cy := MinHeight;
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
   except
   end;
   end;

end.
