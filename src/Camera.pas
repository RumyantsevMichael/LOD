unit Camera;

interface

uses
  DGLE2_types;

type

  TCamera = record
    pos : TPoint2;
    trg : TPoint2;
    vel : Single;
    scl : Single;

    screen : TRectf;

    border : Byte;

    procedure Update;
  end;

implementation

uses
  Settings,
  Input,
  World;

{ TCAmera }

procedure TCAmera.Update;
var
  brd : array [1..4] of Integer;
  vec : TPoint2;
  l : Single;
begin

  brd[1] := border;
  brd[2] := Window.Width - border;
  brd[3] := border;
  brd[4] := Window.Height - border;

  if mouse.state.iX < brd[1] then pos.x := pos.x - 12;
  if mouse.state.iX > brd[2] then pos.x := pos.x + 12;
  if mouse.state.iY < brd[3] then pos.y := pos.y - 12;
  if mouse.state.iY > brd[4] then pos.y := pos.y + 12;

  vec.x := pos.x - trg.x;
  vec.y := pos.y - trg.y;
  l := Sqrt( Sqr( vec.x) + Sqr( vec.y));

  vel := ( l/10 ) * 2/scl;

  vec.x := vec.x / l * ( l - vel );
  vec.y := vec.y / l * ( l - vel );

  pos.x := trg.x + vec.x;
  pos.y := trg.y + vec.y;

  if Sqrt( Sqr( pos.x - trg.x ) + Sqr( pos.y - trg.y )) < vel then
  begin
    pos.x := trg.x;
    pos.y := trg.y;
  end;

  scl := scl + mouse.state.iDeltaWheel / 1200;
  if scl < 0.3 then scl := 0.3;
  if scl > 3.0 then scl := 3.0;

  screen := Rectf(
    pos.x - Window.Width / scl / 2 - TSX,
    pos.y - window.height / scl / 2 - TSY,
    Window.Width / scl + 2 * TSX,
    Window.Height / scl + 2 * TSY );
end;

end.
