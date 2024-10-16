program project;

{$ifdef FPC}
  {$mode Delphi}
{$endif}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, main, graph;

type

  { TDijkstra2 }

  TDijkstra2 = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

{ TDijkstra2 }

procedure TDijkstra2.DoRun;
var
  ErrorMsg: String;
begin

  { add your program here }
  TProgram.create;

  // stop program loop
  Terminate;
end;

constructor TDijkstra2.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

var
  Application: TDijkstra2;
begin
  Application:=TDijkstra2.Create(nil);
  Application.Title:='Dijkstra Pathfinding 2';
  Application.Run;
  Application.Free;
end.

