unit Input;

interface

uses
  DGLE2_types;

type

  TKeyStack = record
    key : array of Byte;
    count : Byte;

    procedure Push( key_code : Integer );
    procedure Free;
  end;

  TMemKeyStack = record
    key : array of Byte;
    count : Byte;
    time : Integer;

    procedure Push( key_code : Integer );
    procedure Update;
    procedure Free;
  end;

  TMouse = record
    state : TMouseStates;

    bLeftClick : Boolean;
    bRightClick : Boolean;

  private
    time : array [1..2] of Integer;

    procedure Update;
  end;

procedure Init;
procedure Update;

procedure null;

var
  KeyStack : TKeyStack;
  KeyBind : array [1..220] of procedure;

  MemKeyStack : TMemKeyStack;

  mouse : TMouse;

implementation

uses
  SubSystems;

var
  wait : Integer;

procedure null;
begin
end;

procedure Init;
var
  i: Integer;
begin
  for i := 1 to 220 do
    KeyBind[ i ] := null;
end;

procedure Update;
var
  Pressed : Boolean;
  key : Integer;
  i : Integer;
begin
  SubSystems.Input.GetMouseStates( mouse.state );
  mouse.Update;

  KeyStack.Free;

  for key := 1 to 220 do
  begin
    SubSystems.Input.GetKey( key, Pressed );
    if Pressed then
      KeyStack.Push( key );
  end;

  Dec( wait );
  if wait <= 0 then
  for i := 0 to KeyStack.count - 1 do
  begin
    KeyBind[ KeyStack.key[ i ]];
    wait := 10;
  end;

  if KeyStack.count > 0 then
  begin
    if MemKeyStack.time <= 15 then
      MemKeyStack.Push( KeyStack.key[0] );
  end;

  MemKeyStack.Update;

end;

{ TKeyStack }

procedure TKeyStack.Push(key_code: Integer);
begin
  SetLength( key, count + 1 );

  key[ count ] := key_code;

  Inc( count );
end;

procedure TKeyStack.Free;
begin
  SetLength( key, 0 );
  count := 0;
end;

{ TMemKeyStack }

procedure TMemKeyStack.Push(key_code: Integer);
begin
  SetLength( key, count + 1 );
  key[ count ] := key_code;
  Inc( count );
  time := 20;
end;

procedure TMemKeyStack.Update;
begin
  Dec( time );
  if time <= 0 then
    Free;
end;

procedure TMemKeyStack.Free;
begin
  SetLength( key, 0 );
  count := 0;
  time := 0;
end;

{ TMouse }

procedure TMouse.Update;
begin
  Dec( time[1] );
  Dec( time[2] );

  if state.bLeftButton then
    time[1] := 20;

  if ( not state.bLeftButton ) and ( time[1] > 0 ) then
  begin
    bLeftClick := True;
    time[1] := 0;
  end
  else
    bLeftClick := False;

  if state.bRightButton then
    time[2] := 20;

  if ( not state.bRightButton ) and ( time[2] > 0 ) then
  begin
    bRightClick := True;
    time[2] := 0;
  end
  else
    bRightClick := False;

end;

end.
