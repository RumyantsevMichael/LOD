unit TaskList;

interface

uses
  Item;

type

  TTaskType = ( Move, Take, Drop );

  PTaskParam = ^TTaskParam;
  TTaskParam = record
    x : Single;
    y : Single;
    item : PItem;
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
  function Task( ttype : TTaskType; param : TTaskParam ): TTask;

implementation

uses
  Creature;

function TaskParam( x, y : Single ): TTaskParam; overload;
begin
  Result.x := x;
  Result.y := y;
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
      Move:
      begin
        TCreature( Parent ).Move( Task[ 0 ].param, result );
      end;
      Take:
      begin
        TCreature( Parent ).Take( Task[ 0 ].param, result );
      end;
    end;
    if result then Next;
  end;
end;

procedure TTaskList.Free;
begin
  Task := nil;
end;

end.
