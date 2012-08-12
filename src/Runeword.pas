unit Runeword;

interface

uses
  Skill;

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
    rune : array of string;
    count : Byte;
    time : Integer;

    procedure Push( const rune : string );
    procedure Update;
    procedure Free;
  end;

  function MakeRuneword( const name : string ): TRuneword;

  procedure Init;
  procedure Update;

var
  RunewordPack : TRunewordPack;
  RuneStack : TRuneStack;

implementation

uses
  Input,
  Game,
  Skill.Shokwave,
  Skill.Fireball;

procedure Init;
begin
  Skill.Init;

  RunewordPack.Add( MakeRuneword('FusRoDah'));
               RunewordPack.Find('FusRoDah').Add('Iwaz');
               RunewordPack.Find('FusRoDah').Add('Sowilu');
               RunewordPack.Find('FusRoDah').skill := TShokwave;

  RunewordPack.Add( MakeRuneword('DahRoFus'));
               RunewordPack.Find('DahRoFus').Add('Sowilu');
               RunewordPack.Find('DahRoFus').Add('Iwaz');
               RunewordPack.Find('DahRoFus').skill := TFireball;
end;

procedure Update;
var
  i: Integer;
  j: Integer;
  k: Integer;
begin
  if KeyStack.count > 0 then
  begin
    if RuneStack.time <= 15 then
    begin
      case KeyStack.key[ 0 ] of
        71: if player.RunePage.item[ 0 ] <> nil then RuneStack.Push( player.RunePage.item[ 0 ].name ); // num 7
        72: if player.RunePage.item[ 1 ] <> nil then RuneStack.Push( player.RunePage.item[ 1 ].name ); // num 8
        73: if player.RunePage.item[ 2 ] <> nil then RuneStack.Push( player.RunePage.item[ 2 ].name ); // num 9
        75: if player.RunePage.item[ 3 ] <> nil then RuneStack.Push( player.RunePage.item[ 3 ].name ); // num 4
        76: if player.RunePage.item[ 4 ] <> nil then RuneStack.Push( player.RunePage.item[ 4 ].name ); // num 5
        77: if player.RunePage.item[ 5 ] <> nil then RuneStack.Push( player.RunePage.item[ 5 ].name ); // num 6
        79: if player.RunePage.item[ 6 ] <> nil then RuneStack.Push( player.RunePage.item[ 6 ].name ); // num 1
        80: if player.RunePage.item[ 7 ] <> nil then RuneStack.Push( player.RunePage.item[ 7 ].name ); // num 2
        81: if player.RunePage.item[ 8 ] <> nil then RuneStack.Push( player.RunePage.item[ 8 ].name ); // num 3
      end;
    end;
  end;

  RuneStack.Update;

  for i := 0 to RunewordPack.count - 1 do
  begin
    if RunewordPack.runeword[ i ].count = RuneStack.count then
    begin
      for j := 0 to RuneStack.count - 1 do
      begin
        if RuneStack.rune[ j ] = RunewordPack.runeword[ i ].rune[ j ] then
        begin
          if j = RuneStack.count - 1 then
          begin
            k := SkillStack.Add;
            SkillStack.Item[ k ] := RunewordPack.runeword[ i ].skill.Create;
            SkillStack.Item[ k ].Init( player );
            player.Say( RunewordPack.runeword[ i ].name );

            RuneStack.Free;
          end;
        end
        else
          Break;
      end;
    end;
  end;
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

procedure TRuneStack.Push( const rune: string);
begin
  SetLength( Self.rune, count + 1 );
  Self.rune[ count ] := rune;
  Inc( count );
  time := 20;
end;

procedure TRuneStack.Update;
begin
  Dec( time );
  if time <= 0 then
    Free;
end;

procedure TRuneStack.Free;
begin
  SetLength( rune, 0 );
  count := 0;
  time := 0;
end;

end.
