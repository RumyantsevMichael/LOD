unit Skill;

interface

uses
  DGLE2_types,
  Creature,
  Rune;

type

  PSkill = ^TSkill;
  TSkill = class
    name : string;
    time : Integer;
    parent : TCreature;

    constructor Create; virtual; abstract;
    destructor  Destroy; virtual; abstract;

    procedure   Init( Parent : TCreature; target : TPoint2; Rune : array of TRune ); virtual; abstract;
    procedure   Render; virtual; abstract;
    procedure   Update( dt : Single ); virtual; abstract;
  end;
  CSkill = class of TSkill;

  TSkillStack = record
    Item : array of TSkill;

    function Add: Integer;

    procedure Render;
    procedure Update( dt : Single );
  end;

procedure Init;
procedure Render;
procedure Update( dt : Single );

function GetAngle( point1, point2 : TPoint2 ): Single;

var
  SkillStack : TSkillStack;

implementation

uses
  System.Math;


procedure Init;
begin

end;

procedure Render;
begin
  SkillStack.Render;
end;

procedure Update( dt : Single );
begin
  SkillStack.Update( dt );
end;

{ TSkillStack }

function TSkillStack.Add;
var
  i : Integer;
  j : Integer;
  L : Integer;
  N : Boolean;
begin

  j := 0;
  N := True;
  L := Length( Item );

  if L > 0 then
  for i := 0 to L - 1 do
  begin
    if Item[ i ].time <= 0 then
    begin
      j := i;
      N := False;
    end;
  end;

  if N then
  begin
    SetLength( Item, L + 1 );
    j := L;
  end;

  Result := j;
end;

procedure TSkillStack.Render;
var
  i : Integer;
begin
  for i := 0 to Length( Item ) - 1 do
    if Item[ i ] <> nil then
      Item[ i ].Render;
end;

procedure TSkillStack.Update( dt : Single );
var
  i: Integer;
begin
  for i := 0 to Length( Item ) - 1 do
    if Item[ i ] <> nil then
    begin
      Item[ i ].Update( dt );

      //if Item[ i ].time <= 0 then
      //  Item[ i ].Destroy;
    end;
end;


function GetAngle( point1, point2 : TPoint2 ): Single;
var
  vec : TPoint2;
  dir : TPoint2;
  l : Single;
begin
  vec.x := point1.x - point2.x;
  vec.y := point1.y - point2.y;
  l := Sqrt( Sqr( vec.x ) + Sqr( vec.y ));

  if
    ( point1.x <> point2.x ) and
    ( point1.y <> point2.y )
  then
  begin
    dir.x := -vec.x / l;
    dir.y := -vec.y / l;
  end;

  Result := RadToDeg( ArcTan( dir.y / dir.x ));
  if dir.x > 0 then Result := Result - 180;
end;

end.
