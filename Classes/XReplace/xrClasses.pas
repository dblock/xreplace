unit XRClasses;

interface

uses Classes, Comctrls;

type

   NodeType = (nFile, nDirectory, nDrive);

   PRedirect = ^TRedirect;
   TRedirect = record
             Parent: TTreeNode;
             OFound, OReplaced: LongInt;
             SourceFileName: string;
             TargetFileName: string;
             fType: NodeType;
             end;

   PCellProps = ^TCellProps;
   TCellProps = record
            LeftSplit: boolean;
            RightSplit: boolean;
            Inter: boolean;
            CaseSens: boolean;
            WholeWord: boolean;
            Prompt: boolean;
            LeftSide: string;
            LeftSplitSide: string;
            RightSide: string;
            RightSplitSide: string;
            ReplaceCopies: integer;
            OccurrencesFound: longint;
            OccurrencesReplaced: longint;
            Disabled: boolean;
            end;

   PSuperLongArray = ^SuperLongArray;
   SuperLongArray = array[0..MaxInt div 5] of PCellProps;

   TStatistics = record
      occurrencesFound,
      occurrencesReplaced: LongInt;
      end;

implementation

end.
 