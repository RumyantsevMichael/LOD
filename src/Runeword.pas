unit Runeword;

interface

uses
  DGLE2_types,

  Skill,
  Rune;

type

  PRuneword = ^TRuneword;
  TRuneword = record
    name : string;
    rune : array of string;
    count : Byte;

    skill : CSkill;

    procedure Add( rune : string );
  end;

  TRunewordPack = record
    runeword : array of TRuneword;
    count : Integer;

    procedure Add( word : TRuneword );
    function Find( name : string ): PRuneword;
  end;

  TRuneStack = record
    rune : array of TRune;
    count : Byte;
    time : Integer;
    max_time : Integer;

    procedure Push( const rune : TRune );
    procedure SetTime( value : Integer );

    procedure Update;
    procedure Render( pos : TPoint2; size : Byte );
    procedure Free;
  end;

  function MakeRuneword( const name : string ): TRuneword;

  procedure Init;
  procedure Update;
  procedure Calculate;

var
  RunewordPack : TRunewordPack;
  RuneStack : TRuneStack;

implementation

uses
  SubSystems,
  Input,
  Game,
  Skill.Shokwave,
  Skill.Fireball,
  Skill.Poisoning;

procedure Init;
begin
  Skill.Init;
  RuneStack.SetTime( 25 );

  RunewordPack.Add( MakeRuneword('Shokwave'));
               RunewordPack.Find('Shokwave').Add('Iwaz');
               RunewordPack.Find('Shokwave').Add('Sowilu');
               RunewordPack.Find('Shokwave').skill := TShokwave;

  RunewordPack.Add( MakeRuneword('Fireball'));
               RunewordPack.Find('Fireball').Add('Sowilu');
               RunewordPack.Find('Fireball').Add('Iwaz');
               RunewordPack.Find('Fireball').skill := TFireball;

  RunewordPack.Add( MakeRuneword('Poisoning'));
               RunewordPack.Find('Poisoning').Add('Sowilu');
               RunewordPack.Find('Poisoning').Add('Berkana');
               RunewordPack.Find('Poisoning').Add('Iwaz');
               RunewordPack.Find('Poisoning').skill := TPoisoning;
end;

procedure Update;
var
  key: Integer;
begin
  for key := 71 to 81 do
    if keyboard.KeyDown[ key ] then
      Break;

  case key of
    71: if player.RunePage.item[ 0 ] <> nil then RuneStack.Push( player.RunePage.item[ 0 ] as TRune ); // num 7
    72: if player.RunePage.item[ 1 ] <> nil then RuneStack.Push( player.RunePage.item[ 1 ] as TRune ); // num 8
    73: if player.RunePage.item[ 2 ] <> nil then RuneStack.Push( player.RunePage.item[ 2 ] as TRune ); // num 9
    75: if player.RunePage.item[ 3 ] <> nil then RuneStack.Push( player.RunePage.item[ 3 ] as TRune ); // num 4
    76: if player.RunePage.item[ 4 ] <> nil then RuneStack.Push( player.RunePage.item[ 4 ] as TRune ); // num 5
    77: if player.RunePage.item[ 5 ] <> nil then RuneStack.Push( player.RunePage.item[ 5 ] as TRune ); // num 6
    79: if player.RunePage.item[ 6 ] <> nil then RuneStack.Push( player.RunePage.item[ 6 ] as TRune ); // num 1
    80: if player.RunePage.item[ 7 ] <> nil then RuneStack.Push( player.RunePage.item[ 7 ] as TRune ); // num 2
    81: if player.RunePage.item[ 8 ] <> nil then RuneStack.Push( player.RunePage.item[ 8 ] as TRune ); // num 3
  end;

  RuneStack.Update;
end;

procedure Calculate;
var
  i: Integer;
  j: Integer;
  k: Integer;
begin
  for i := 0 to RunewordPack.count - 1 do
    if RunewordPack.runeword[ i ].count = RuneStack.count then
      for j := 0 to RuneStack.count - 1 do
        if RuneStack.rune[ j ].name = RunewordPack.runeword[ i ].rune[ j ] then
        begin
          if j = RuneStack.count - 1 then
          begin
            k := SkillStack.Add;
            SkillStack.Item[ k ] := RunewordPack.runeword[ i ].skill.Create;
            SkillStack.Item[ k ].Init( player, GetMapFocusedPoint, RuneStack.rune );
            //player.Say( RunewordPack.runeword[ i ].name );
            RuneStack.Free;
          end;
        end
        else
          Break;

  RuneStack.Free;
end;


function MakeRuneword( const name : string ): TRuneword;
begin
  Result.name := name;
  Result.count := 0;
end;

{ TRuneword }

procedure TRuneword.Add(rune: string);
begin
  SetLength( Self.rune, count + 1 );
  Self.rune[ count ] := rune;
  Inc( count );
end;

{ TRunewordPack }

procedure TRunewordPack.Add( word : TRuneword );
begin
  SetLength( runeword, count + 1 );
  runeword[ count ] := word;
  Inc( count );
end;

function TRunewordPack.Find(name: string): PRuneword;
var
  i: Integer;
begin
  Result := @runeword[ 0 ];

  if count > 0 then
    for i := 0 to count - 1 do
      if runeword[ i ].name = name then
        Result := @runeword[ i ];
end;

{ TRuneStack }

procedure TRuneStack.Push( const rune: TRune);
begin
  SetLength( Self.rune, count + 1 );
  Self.rune[ count ] := rune;
  Inc( count );
  time := max_time;
end;

procedure TRuneStack.SetTime(value: Integer);
begin
  max_time := value;
end;

procedure TRuneStack.Render(pos: TPoint2; size: Byte);
var
  rect : TRectf;
  i: Integer;
begin
  rect := Rectf( pos.x - ( size * count ) / 2, pos.y - size / 2, size * count, size );

  for i := 0 to count - 1 do
  begin
    rune[ i ].texture^.Draw2D( Round( rect.x + i * size ), Round( rect.y ), size, size );
  end;

  Render2d.LineWidth( 5 );
    i := Round( time / max_time * rect.width );
    Render2D.DrawLine
    (
      Point2( rect.x, rect.y + size ),
      Point2( rect.x + i, rect.y + size ),
      Color4($9d1414)
    );
  Render2d.LineWidth( 1 );
end;

procedure TRuneStack.Update;
begin
  Dec( time );
  if time <= 0 then
    Free;
end;

procedure TRuneStack.Free;
begin
  rune := nil;
  SetLength( rune, 0 );
  count := 0;
  time := 0;
end;

end.
