unit dshedule;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Spin, Buttons, ComCtrls, ShellApi;

type

  PShedule = ^TShedule;
  TShedule = record
     //eDayType,
     eDayName,
     eDayNum,
     eMonName,
     eYearVal,
     eTimeVal : string;
     end;

  PxEvent = ^TxEvent;
  TxEvent = record
    eFileName: string;
    eShedule: PShedule;
    end;

  TDoShedule = class(TForm)
    ShedPanel: TPanel;
    tPerform: TPanel;
    cMonth: TListBox;
    WherePanel: TPanel;
    Panel2: TPanel;
    cDay: TListBox;
    cDate: TListBox;
    Panel3: TPanel;
    cYear: TListBox;
    cTime: TListBox;
    dPanel: TPanel;
    DaySelect: TListBox;
    DateSelect: TSpinEdit;
    MonthSelect: TListBox;
    YearSelect: TSpinEdit;
    HourEdit: TEdit;
    iPanel: TPanel;
    CheeseImage: TImage;
    SheduleOk: TBitBtn;
    wPanel: TLabel;
    SheduleCancel: TBitBtn;
    //SelTime: TDateTimePicker;
    //SetDateTime: TSpeedButton;
    //iSelDate: TSpeedButton;
    //iSelTime: TSpeedButton;
    procedure cEveryDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure cEveryDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure HourEditChange(Sender: TObject);
    procedure HourEditKeyPress(Sender: TObject; var Key: Char);
    procedure HourEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HourEditEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure CheeseImageDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure CheeseImageDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TypeSelectDblClick(Sender: TObject);
    procedure cEveryDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SheduleOkClick(Sender: TObject);
    procedure SheduleCancelClick(Sender: TObject);
    //procedure SetDateTimeClick(Sender: TObject);
    //procedure iSelDateClick(Sender: TObject);
    //procedure iSelTimeClick(Sender: TObject);
  private
    Year, Month, Day: word;
    Hour, Min, Sec, mSec: word;
    pHour, pMin: integer;
    function UniqueAdd(Source: TObject; Target: TListBox): boolean;
    procedure CompileShedule;
    procedure wGenAdd;
    procedure wGenFill;
    procedure tPUSelect(iPanel: TPanel);
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
  public
    { Public declarations }
  end;

  procedure initDoShedule;

var
  theShedule: PShedule;
  oShedule: TShedule;
  DoShedule: TDoShedule = nil;
const
   iSeparator : string = '----------------------------------------';
   YearBase: integer = 1990;

implementation

uses xshedule, xreplace;

{$R *.DFM}

procedure initDoShedule;
begin
     if DoShedule = nil then begin
        Application.CreateForm(TDoShedule, DoShedule);
        end;
     end;

procedure TDoShedule.wGenFill;
          procedure AddField(Target: TListBox; iStr: string);
          var
             i: integer;
             sAdd: string;
          begin
               //Target.Items.Clear;
               if Length(iStr)=0 then exit;
               if iStr<>'' then iStr:=iStr + ',';
               i:=Pos(',',iStr);
               while i<>0 do begin
                     sAdd:=Copy(iStr, 1, i - 1);
                     if (sAdd <> 'Weekday') and
                        (sAdd <> 'Month') and
                        (sAdd <> 'Year') then
                              Target.Items.Add(sAdd);
                     Delete(iStr, 1, i+1);
                     i:=Pos(',',iStr);
                     end;
               end;
begin
     if theShedule <> nil then
     with theShedule^ do begin
          //AddField(cEvery, eDayType);
          AddField(cDay, eDayName);
          AddField(cDate, eDayNum);
          AddField(cMonth, eMonName);
          Addfield(cYear, eYearVal);
          Addfield(cTime, eTimeVal);
          end;
     end;

procedure TDoShedule.wGenAdd;
          procedure wAdd(sStr: string);
          begin
               if sStr <> '' then
                  with wPanel do begin
                       if Caption <> '' then Caption:=Caption + ' ';
                       Caption:=Caption + SStr;
                       end;
               end;
begin
     wPanel.Caption:='';
     with theShedule^ do begin
          //if (eDayName<>'') or (eDayNum<>'') then wAdd(eDayType);
          //if (eDayType = '') and (eDayName <> '') then wAdd('on');
          if (eDayName = '') or (eDayName = 'Weekday') then wAdd('any');
          wAdd(eDayName);
          wAdd(eDayNum);
          if (eDayName<>'') or (eDayNum<>'') then wAdd('-');
          if (eMonName = '') or (eMonName = 'Month') then wAdd('any');
          wAdd(eMonName);
          if (eYearVal <> '') then wAdd('-');
          if (eYearVal = 'Year') then wAdd('any');
          wAdd(eYearVal);
          if (eTimeVal <> '') then wAdd('at');
          wAdd(eTimeVal);
          end;
     end;

procedure TDoShedule.CompileShedule;
          function FindItem(Target: TListBox; iStr: string): boolean;
          var
             i: integer;
          begin
               Result:=True;
               for i:=0 to Target.Items.Count - 1 do
                   if CompareText(Target.Items[i], iStr)=0 then exit;
               Result:=False;
               end;
          procedure AddItem(var tStr: string; sStr: string);
          begin
               if tStr <> '' then tStr:=tStr + ', ';
               tStr:=tStr + sStr;
               end;
var
   i: integer;
begin
     with theShedule^ do begin
          //every, except
          //eDayType:='';
          //if FindItem(cEvery, 'Except') then eDayType:='Except' else
          //if FindItem(cEvery, 'Every') then eDayType:='Every';
          //day
          eDayName:='';
          if (cDay.Items.Count = 0) then eDayName:='Weekday' else
          if FindItem(cDay, 'Weekday') or (cDay.Items.Count = 7) then begin
             eDayName:='Weekday';
             end else
             for i:=0 to cDay.Items.Count - 1 do AddItem(eDayName, cDay.Items[i]);
          //date
          eDayNum:='';
             for i:=0 to cDate.Items.Count - 1 do AddItem(eDayNum, cDate.Items[i]);
          //month
          eMonName:='';
          if (FindItem(cMonth, 'Month')) or
             (cMonth.Items.Count = 0) or
             (cMonth.Items.Count = 12) then eMonName:='Month' else
             for i:=0 to cMonth.Items.Count - 1 do AddItem(eMonName, cMonth.Items[i]);
          //year
          eYearVal:='';
          if cYear.Items.Count = 0 then AddItem(eYearVal, 'Year') else
             for i:=0 to cYear.Items.Count - 1 do AddItem(eYearVal, cYear.Items[i]);
          //time
          eTimeVal:='';
          if cTime.Items.Count = 0 then AddItem(eTimeVal, '00:00') else
             for i:=0 to cTime.Items.Count - 1 do AddItem(eTimeVal, cTime.Items[i]);
          //---
          wGenAdd;
          //---- pointer to shedule object
          end;

     end;

function TDoShedule.UniqueAdd(Source: TObject; Target: TListBox): boolean;
         function UniqueItemAdd(iStr: string): boolean;
         var
            i: integer;
         begin
              Result:=False;
              if iStr = iSeparator then exit;
              for i:=0 to Target.Items.Count - 1 do begin
                  if CompareText(Target.Items[i], iStr) = 0 then exit;
                  end;
              Target.Items.Add(iStr);
              Result:=True;
              end;
var
   i: integer;
begin
     //---
     Result:=False;
     if Source is TListBox then begin
        for i:=0 to (Source as TListBox).Items.Count - 1 do begin
            if (Source as TListBox).Selected[i] then begin
               Result:=UniqueItemAdd((Source as TListBox).Items[i]);
               end;
            end;
        end else
     if Source is TSpinEdit then begin
        Result:=UniqueItemAdd(IntTOStR((Source as TSpinEdit).Value));
        end else
     if Source is TEdit then begin
        Result:=UniqueItemAdd((Source as TEdit).Text);
        end else exit;
     CompileShedule;
     end;

procedure TDoShedule.cEveryDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
   try
   if (Source is tListBox) or (Source is tSpinEdit) or (Source is TEdit) then
      if ((Source as tControl).Parent = dPanel) then
        if ((Source as TControl).Tag = (Sender as TControl).Tag) then Accept:=True else Accept:=False;
   except
         Accept:=False;
   end;
   end;

procedure TDoShedule.cEveryDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
   UniqueAdd(Source, (Sender as TListBox));
   end;

procedure TDoShedule.HourEditChange(Sender: TObject);
var
   iHour, iMinute: integer;
   iSt: integer;
begin
   try
   iHour:=StrtoInt(Copy(HourEdit.Text, 1, Pos(':', HourEdit.Text) - 1));
   iMinute:=StrtoInt(Copy(HourEdit.Text, Pos(':', HourEdit.Text)+1, Length(HourEdit.Text)));
   if (iHour < 0) or (iHour > 23) or (iMinute < 0) or (iMinute > 59) then begin
      iSt:=HourEdit.SelStart;
      HourEdit.Text:=Format('%.2d:%.2d', [pHour, pMin]);
      HourEdit.SelStart:=iSt;
      end else begin
      pHour:=iHour;
      pMin:=iMinute;
      end;
   except
   end;
   end;

procedure TDoShedule.HourEditKeyPress(Sender: TObject; var Key: Char);
begin
     if not (Key in ['0'..'9']) then Key:=Chr(0);
     end;

procedure TDoShedule.HourEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
     with HourEdit do begin
          if (key = VK_Right) and (SelStart = 1) then SelStart:=SelStart+1;
          if (key in [VK_Left, VK_Right]) then exit;
          if not (Key in [Ord('0')..Ord('9'), Ord(VK_NUMPAD0)..Ord(VK_NUMPAD9)]) then Key:=0 else begin
             if SelStart = 2 then SelStart:=SelStart+1;
             SelLength:=1;
             end;
          end;
     end;

procedure TDoShedule.HourEditEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
     HourEdit.SetFocus;
     HourEdit.SelStart:=0;
     end;

procedure TDoShedule.CheeseImageDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   try
   if (Source is tListBox) or (Source is tSpinEdit) or (Source is TEdit) then
      if ((Source as tControl).Parent = dPanel) then
        Accept:=True else Accept:=False;
   except
         Accept:=False;
   end;
end;

procedure TDoShedule.CheeseImageDragDrop(Sender, Source: TObject; X, Y: Integer);
          procedure tPDrop(iPanel: TPanel);
          var
             i: integer;
          begin
               for i:=0 to iPanel.ControlCount - 1 do begin
                   if iPanel.Controls[i] is TListBox then begin
                      if iPanel.Controls[i].Tag = (Source as TControl).Tag then begin
                      UniqueAdd(Source, (iPanel.Controls[i] as TListBox));
                      exit;
                      end;
                   end else
                   if iPanel.Controls[i] is TPanel then begin
                      tPDrop(iPanel.Controls[i] as TPanel);
                      end;
               end;
               end;
begin
   tPDrop(tPerform);
   end;

procedure TDoShedule.TypeSelectDblClick(Sender: TObject);
begin
   CheeseImageDragDrop(Sender, Sender, 0, 0);
   end;

procedure TDoShedule.cEveryDblClick(Sender: TObject);
begin
  with (Sender as TListBox) do Items.Delete(ItemIndex);
  CompileShedule;
  end;

procedure TDoShedule.tPUSelect(iPanel: TPanel);
          var
             i, j: integer;
          begin
               for i:=0 to iPanel.ControlCount - 1 do begin
                   if iPanel.Controls[i] is TListBox then begin
                      for j:=0 to (iPanel.Controls[i] as TListBox).Items.Count - 1 do
                          (iPanel.Controls[i] as TListBox).Selected[j]:=False;
                      end else
                   if iPanel.Controls[i] is TPanel then begin
                      tPUSelect(iPanel.Controls[i] as TPanel);
                      end;
                   end;
               end;

procedure TDoShedule.FormShow(Sender: TObject);
          procedure tPClear(iPanel: TPanel);
          var
             i: integer;
          begin
               for i:=0 to iPanel.ControlCount - 1 do begin
                   if iPanel.Controls[i] is TListBox then begin
                      (iPanel.Controls[i] as TListBox).Items.Clear;
                      end else
                   if iPanel.Controls[i] is TPanel then begin
                      tPClear(iPanel.Controls[i] as TPanel);
                      end;
                   end;
               end;
begin
   DecodeDate(Now, Year, Month, Day);
   DecodeTime(Now, Hour, Min, Sec, mSec);
   tPClear(tPerform);
   tPUSelect(dPanel);
   with XFShedule.SheduleTree do
   if (Selected <> nil) then begin
      DateSelect.Value:=Day;
      DaySelect.Selected[DayOfWeek(Now) - 1]:=True;
      MonthSelect.Selected[Month - 1]:=True;
      YearSelect.Value:=Year;
      HourEdit.Text:=Format('%.2d:%.2d', [Hour, Min]);
      if (Selected.Data <> nil) then begin
         new(theShedule);
         theShedule^:=Tshedule(Selected.Data^);
         wGenAdd;
         wGenFill;
         end else begin
         new(theShedule);
         CompileShedule;
         end;
      end;
   end;

procedure TDoShedule.SheduleOkClick(Sender: TObject);
          function Unique(Parent: TTreeNode; iStr: string): boolean;
          var
             cNode: TTreeNode;
          begin
               Result:=True;
               if Parent = nil then exit;
               cNode:=Parent.GetFirstChild;
               while (cNode <> nil) do begin
                     if CompareText(cNode.Text, iStr) = 0 then exit;
                     cNode:=cNode.GetNextSibling;
                     end;
               result:=False;
               end;
var
   iNode:TTreeNode;
begin
   with xFShedule.SheduleTree do begin

   if not (Selected.Parent = Items.GetFirstNode) then begin
      iNode:=Selected;
      Selected:=Selected.Parent;
      iNode.Destroy;
      end;

      if not(Unique(Selected, wPanel.Caption)) then begin
         iNode:=Items.AddChild(Selected, wPanel.Caption);
         iNode.ImageIndex:=3;
         iNode.Data:=theShedule;
         iNode.Parent.Expand(True);

         xrepl32.ReplaceLog.oLog('added / modified schedule for '+iNode.Parent.Text+': '+wPanel.Caption,'schedule',XReplaceOptions.Log.Shed);
         end;

   end;
   DoShedule.Close;
   end;

procedure TDoShedule.SheduleCancelClick(Sender: TObject);
begin
     DoShedule.Close;
     end;

procedure TDoShedule.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   with M.WindowPos^ do begin
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

{procedure TDoShedule.SetDateTimeClick(Sender: TObject);
begin
     iSelDate.Click;
     iSelTime.Click;
     end;}

{procedure TDoShedule.iSelDateClick(Sender: TObject);
var
   Year, Month, Day: Word;
   i: integer;
begin
     try
     SheduleOk.SetFocus;
     tPUSelect(dPanel);
     DecodeDate(SelDate.Date, Year, Month, Day);
     DaySelect.Selected[DayOfWeek(SelDate.Date) - 1]:=True;
     DateSelect.Value:=Day;
     MonthSelect.Selected[Month - 1]:=True;
     YearSelect.Value:=Year;
     for i:=0 to dPanel.ControlCount - 1 do begin
         if dPanel.Controls[i] <> HourEdit then  CheeseImageDragDrop(dPanel.Controls[i], dPanel.Controls[i], 0, 0);
         end;
     except
     end;
     end;



procedure TDoShedule.iSelTimeClick(Sender: TObject);
var
   Hour, Min, Sec, MSec: Word;
begin
     SheduleOk.SetFocus;
     DecodeTime(SelTime.Time, Hour, Min, Sec, MSec);
     HourEdit.Text:=Format('%.2d:%.2d', [Hour, Min]);
     CheeseImageDragDrop(HourEdit, HourEdit, 0, 0);
     end;}

end.
