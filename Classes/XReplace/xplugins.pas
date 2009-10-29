unit xplugins;

interface

uses xrClasses, xopt, xlog, classes, sysutils;

type
    
    PReplRecord = ^TReplRecord;
    TReplRecord = record
       iStr: PChar;
       iRow: PCellProps;
       iOptions: PReplOptions;
       iLog: PLog;
       end;

    TXRPlugin = class
      public
       constructor Create(Path: string);
       procedure PerformReplace(ReplaceRecord: PReplRecord);
      private
       Malformed : boolean;
       PluginExecutable: string;
       end;

    TXRPluginManager = class
      public
       constructor Create;
       destructor Destroy; override;
       procedure RegisterPlugin(Plugin: TXRPlugin);
       procedure UnRegisterPlugin(Plugin: TXRPlugin);
       procedure PerformReplaceOp(_iStr: PChar; _iRow: PCellProps; _iOptions: PReplOptions; _iLog: PLog);
      private
       Plugins: TList;
       procedure PerformReplace(ReplaceRecord: PReplRecord);
      protected
       end;

implementation

procedure TXRPlugin.PerformReplace(ReplaceRecord: PReplRecord);
begin
     //---
     end;

procedure TXRPluginManager.PerformReplace(ReplaceRecord: PReplRecord);
var
   i: integer;
begin
     for i:=0 to Plugins.Count - 1 do TXRPlugin(Plugins[i]).PerformReplace(ReplaceRecord);
     end;

procedure TXRPluginManager.PerformReplaceOp(_iStr: PChar; _iRow: PCellProps; _iOptions: PReplOptions; _iLog: PLog);
var
   ReplaceRecord : PReplRecord;
begin
     new(ReplaceRecord);
     with ReplaceRecord^ do begin
          iStr:=_iStr;
          iRow:=_iRow;
          iOptions:=_iOptions;
          iLog:=_iLog;
          end;
     PerformReplace(ReplaceRecord);
     end;

constructor TXRPlugin.Create(Path: string);
begin
     PluginExecutable:=Path;
     if not FileExists(PluginExecutable) then Malformed := True else Malformed := False;
     end;

constructor TXRPluginManager.Create;
begin
     Plugins := TList.Create;
     end;

destructor TXRPluginManager.Destroy;
begin
     Plugins.Destroy;
     inherited;
     end;

procedure TXRPluginManager.RegisterPlugin(Plugin: TXRPlugin);
begin
     if Plugins.IndexOf(Plugin) = -1 then Plugins.Add(Plugin);
     end;

procedure TXRPluginManager.UnRegisterPlugin(Plugin: TXRPlugin);
var
   i: integer;
begin
     i:=Plugins.IndexOf(Plugin);
     if i <> -1 then Plugins.Remove(Plugin);
     end;


end.
