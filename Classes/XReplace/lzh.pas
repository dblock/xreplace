unit lzh;
{(c) Daniel Doubrovkine - 1996 - Stolen Technologies Inc. - University of Geneva }
{code of this unit is mostly from S.W.A.G.}

Interface

uses SysUtils, Dialogs;

Const
  CompressedStringArraySize = MaxInt div 5;  { err on the side of generosity }

Type
  tCompressedStringArray = array [1..CompressedStringArraySize] of byte;
  pCompressedStringArray = ^tCompressedStringArray;

function GetCompressedString(Arr : pCompressedStringArray) : String;
function CompressString(st : String; Var Arr : pCompressedStringArray; Var len : LongInt) : pCompressedStringArray;
procedure MakeBestUse;

{converts st into a tCompressedStringArray of length len }

var
  FreqChar : Array[4..14] of Char = 'etaonirshdl';
  {can't be in [0..3] because two empty bits signify a space }

Implementation

uses xreplace;

Function GetCompressedString(Arr : pCompressedStringArray) : String;
Var
  Shift : Byte;
  i : Integer;
  ch : Char;
  st : String;
  b : Byte;

  Function GetHalfNibble : Byte;
  begin
    GetHalfNibble := (Arr[i] shr Shift) and 3;
    if Shift = 0 then begin
      Shift := 6;
      inc(i);
    end else dec(Shift,2);
  end;

begin
  st := '';
  i := 1;
  Shift := 6;
  Repeat
    b := GetHalfNibble;
    if b = 0 then
      ch := ' '
    else begin
      b := (b shl 2) or GetHalfNibble;
      if b = $F then begin
        b := GetHalfNibble shl 6;
        b := b or GetHalfNibble shl 4;
        b := b or GetHalfNibble shl 2;
        b := b or GetHalfNibble;
        ch := Char(b);
      end else
        ch := FreqChar[b];
    end;
    if ch <> #0 then st := st + ch;
  Until ch = #0;
  GetCompressedString := st;
end;

function CompressString(st : String; Var Arr : pCompressedStringArray; Var len : LongInt) : pCompressedStringArray;
{ converts st into a tCompressedStringArray of length len }
Var
  i : Integer;
  Shift : Byte;

  Procedure OutHalfNibble(b : Byte);
  begin
    Arr[len] := Arr[len] or (b shl Shift);
    if Shift = 0 then begin
      Shift := 6;
      inc(len);
      ReAllocMem(Arr,len);
      Arr[len]:=0;
    end else dec(Shift,2);
  end;

  Procedure OutChar(ch : Char);
  Var
    i : Byte;
    bych : Byte Absolute ch;
  begin
    if ch = ' ' then
      OutHalfNibble(0)
    else begin
      i := 4;
      While (i<15) and (FreqChar[i]<>ch) do inc(i);
      OutHalfNibble(i shr 2);
      OutHalfNibble(i and 3);
      if i = $F then begin
        OutHalfNibble(bych shr 6);
        OutHalfNibble((bych shr 4) and 3);
        OutHalfNibble((bych shr 2) and 3);
        OutHalfNibble(bych and 3);
      end;
    end;
  end;

begin
  len := 1;
  Shift := 6;
  Arr:=AllocMem(len);
  Arr[len]:=0;
  {fillChar(Arr,sizeof(Arr),0);}
  For i := 1 to length(st) do OutChar(st[i]);
  OutChar(#0);  { end of compressed String signaled by #0 }
  if Shift = 6
    then dec(len);
  CompressString:=Arr;
  Arr:=nil;
end;

procedure MakeBestUse;
var
   BestOf : array [0..255] of integer;
   BestFill, Smallest, SPos, j: integer;
   BestTen: array[0..9,0..1] of integer;
   ARow,i: LongInt;
begin

   for i:=0 to 255 do BestOf[i]:=0;
   for i:=0 to 9 do
    for j:=0 to 1 do
     BestTen[i,j]:=0;

   with xRepl32 do begin
   for ARow:=1 to StringGrid1.RowCount - 1 do begin
       for i:=1 to Length(GetLeftSide(ARow)) do
           inc(BestOf[Ord(GetLeftSide(ARow)[i])]);
       for i:=1 to Length(GetRightSide(ARow)) do
           inc(BestOf[Ord(GetRightSide(ARow)[i])]);
       for i:=1 to Length(GetLeftSplitSide(ARow)) do
           inc(BestOf[Ord(GetLeftSplitSide(ARow)[i])]);
       for i:=1 to Length(GetRightSplitSide(ARow)) do
           inc(BestOf[Ord(GetRightSplitSide(ARow)[i])]);
       end;
       end;

   BestFill:=0;
   Smallest:=0;
   SPos:=0;
   for i:=33 to 255 do begin
      if BestFill<9 then begin
         BestTen[BestFill,0]:=i;
         BestTen[BestFill,1]:=BestOf[i];
         if Smallest>BestOf[i] then begin
            Smallest:=BestOf[i];
            SPos:=BestFill;
            end;
         inc(BestFill);
         end else begin
            if BestOf[i]>Smallest then begin
               BestTen[SPos,0]:=i;
               BestTen[SPos,1]:=BestOf[i];
               Smallest:=BestOf[i];
               for j:=0 to 9 do
                  if BestTen[j,1]<Smallest then begin
                     Smallest:=BestTen[j,1];
                     SPos:=j;
                     break;
                     end;
               end;
         end;
      end;
   for i:=0 to 9 do begin
      FreqChar[i+4]:=Chr(BestTen[i,0]);
      end;
   end;

end.

