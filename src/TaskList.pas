unit TaskList;

interface

uses
  DGLE2_types,
  Item;

type

  TTaskType = ( t_Move, t_Take, t_Relive );

  PTaskParam = ^TTaskParam;
  TTaskParam = record
    x : Single;
    y : Single;
    item : PItem;
    time : Integer;
  end;

  PTask = ^TTask;
  TTask = record
    ttype : TTaskType;
    param : TTaskParam;
  end;

  TTaskList = record
    Task : array of TTask;
    count : Byte;

    procedure Update( parent : Pointer );

    procedure Add( task : TTask );
    procedure Next;
    procedure Free;
  end;

  function TaskParam( x, y : Single ): TTaskParam; overload;
  function TaskParam( pos : TPoint2 ): TTaskParam; overload;
  function Task( ttype : TTaskType; param : TTaskParam ): TTask;

implementation

uses
  Creature;

function TaskParam( x, y : Single ): TTaskParam; overload;
begin
  Result.x := x;
  Result.y := y;
end;

function TaskParam( pos : TPoint2 ): TTaskParam; overload;
begin
  Result.x := pos.x;
  Result.y := pos.y;
end;

function Task( ttype : TTaskType; param : TTaskParam ): TTask;
begin
  Result.ttype := ttype;
  Result.param := param;
end;

{ TTaskList }

procedure TTaskList.Add( task : TTask );
begin
  SetLength( Self.Task, count + 1 );
  Self.Task[ count ] := task;
  Inc( count );
end;

procedure TTaskList.Next;
var
  i: Integer;
begin
  i := 0;

  while i < count - 1 do
  begin
    Task[ i ] := Task[ i + 1 ];
    Inc( i );
  end;

  Dec( count );
  SetLength( Task, count );
end;

procedure TTaskList.Update( parent : Pointer );
var
  i: Integer;
  result : Boolean;
begin
  if count <> 0 then
  begin
    case Task[ 0 ].ttype of
      t_Move  : TCreature( Parent ).Move   ( Task[ 0 ].param, result );
      t_Take  : TCreature( Parent ).Take   ( Task[ 0 ].param, result );
      t_Relive: TCreature( Parent ).Respawn( Task[ 0 ].param, result );
    end;

    if result then
      Next
    else
    case Task[ 0 ].ttype of
      t_Relive: Dec( Task[ 0 ].param.time );
    end;
  end;
end;

procedure TTaskList.Free;
begin
  count := 0;
  Task := nil;
end;

end.
