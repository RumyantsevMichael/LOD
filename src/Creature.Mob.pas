unit Creature.Mob;

interface

uses
  DGLE2_types,

  Creature,
  Skill;

type

  TMob = class ( TCreature )
    skillList : array of CSkill;

    procedure Attack( subject: PCreature ); override;

    procedure Init( group : Byte );
    procedure Render;
    procedure Update( dt : Single );

    procedure Drop; override;
    procedure Death;
  end;

  TMobStack = record
    mob : array of TMob;

    function Add: Integer;
    procedure Free;
  end;

var
  mobStack : TMobStack;

  procedure Render;
  procedure Update( dt : Single );

implementation

uses
  System.Math,

  DGLE2,

  SubSystems,
  Resources,
  Sound,

  Game,
  World,

  TaskList,
  Item,
  Item.Coin,

  Rune;

procedure Render;
var
  i: Integer;
begin
  for i := 0 to Length( mobStack.mob ) - 1 do
    mobStack.mob[ i ].Render;
end;

procedure Update( dt : Single );
var
  vec : TPoint2;
  i : INteger;
  j : Integer;
  l : Single;
begin
  for i := 0 to Length( mobStack.mob ) - 1 do
    mobStack.mob[ i ].Update( dt );

  for i := 0 to Length( mobStack.mob ) - 1 do
  for j := 0 to Length( mobStack.mob ) - 1 do
    if i <> j then
      if not mobStack.mob[ i ].isDead then
      if not mobStack.mob[ j ].isDead then
      begin
        if Sqrt( Sqr( mobStack.mob[i].pos.x - mobStack.mob[j].pos.x ) +
                 Sqr( mobStack.mob[i].pos.y - mobStack.mob[j].pos.y )) < 24
        then
        begin
          vec.x := mobStack.mob[j].pos.x - mobStack.mob[i].pos.x;
          vec.y := mobStack.mob[j].pos.y - mobStack.mob[i].pos.y;

          l := Sqrt( Sqr( Vec.x ) + Sqr( Vec.y ));
          vec.x := vec.x / l * ( 24 - l );
          vec.y := vec.y / l * ( 24 - l );

          mobStack.mob[j].trg.x := mobStack.mob[j].trg.x + vec.x;
          mobStack.mob[j].trg.y := mobStack.mob[j].trg.y + vec.y;
        end;
      end;

  for i := 0 to Length( mobStack.mob ) - 1 do
  for j := 0 to Length( mobStack.mob ) - 1 do
    if i <> j then
      if not mobStack.mob[ i ].isDead then
        if not mobStack.mob[ j ].isDead then
          if mobStack.mob[ i ].group <> mobStack.mob[ j ].group then
            if Sqrt( Sqr( mobStack.mob[ i ].pos.x - mobStack.mob[ j ].pos.x ) +
                     Sqr( mobStack.mob[ i ].pos.y - mobStack.mob[ j ].pos.y ) ) < 300
            then
              mobStack.mob[ i ].Attack( @mobStack.mob[ j ] );

end;

{ TMob }

procedure TMob.Init( group : Byte ) ;
begin
  inherited Init( group );

  energy := 5;
  vitality := 5;
  dexterity := 5 + ( Random( 2 ) - 1 );

  dist_aggr := 5;
  dist_aggr_d := 5;
  dist_attack := 4.5;
  dist_Attack_d := 4.5;

  hp_max := 90 + vitality * 2;
  hp_regen := vitality / 20;

  mp_max := 90 + energy * 2;
  mp_regen := energy / 20;

  xp := 25;

  speed := 4 + dexterity / 10;

  hp := hp_max;
  mp := mp_max;

  bag.SetSize( 6 );
  bag.used := 0;

  bag.Add( TCoin.Create( Random( 20 ) + 10 ));
  bag.Add( MakeRune('Berkana', Random( 2 ) + 1 ));
end;

procedure TMob.Render;
var
  frame : Byte;
  x: Single;
  y: Single;
  i : Integer;
begin
  if not isDead then
  begin
    for i := 0 to Round( GetHP * 360 ) do
    begin
      x := ( pos.x + Cos( DegToRad( i ) ) * TSX/2 ) * TSX / TILE_SIZE;
      y := ( pos.y + Sin( DegToRad( i ) ) * TSY/2 ) * TSY / TILE_SIZE;
      Render2D.DrawPoint( Point2( x, y ), Color4($9d1414), 2 );
    end;

    frame := 0;
    if ( -0.5 < dir.x ) and ( dir.x <= 0.5 ) and ( 0.5 < dir.y ) and ( dir.y <= 1.0 ) then frame := 0;
    if ( -1.0 < dir.x ) and ( dir.x <= -0.5 ) and ( 0.5 <= dir.y ) and ( dir.y < 1.0 ) then frame := 6;
    if ( -1.0 <= dir.x ) and ( dir.x < -0.5 ) and ( -0.5 <= dir.y ) and ( dir.y < 0.5 ) then frame := 12;
    if ( -1.0 < dir.x ) and ( dir.x <= -0.5 ) and ( -1.0 <= dir.y ) and ( dir.y < -0.5 ) then frame := 18;
    if ( -0.5 < dir.x ) and ( dir.x <= 0.5 ) and ( -1.0 < dir.y ) and ( dir.y <= -0.5 ) then frame := 24;
    if ( 0.5 < dir.x ) and ( dir.x <= 1.0 ) and ( -1.0 <= dir.y ) and ( dir.y < -0.5 ) then frame := 30;
    if ( 0.5 <= dir.x ) and ( dir.x < 1.0 ) and ( -0.5 <= dir.y ) and ( dir.y < 0.5 ) then frame := 36;
    if ( 0.5 < dir.x ) and ( dir.x <= 1.0 ) and ( 0.5 <= dir.y ) and ( dir.y < 1.0 ) then frame := 42;

    if ( delta.x <> 0 ) and ( delta.y <> 0 ) then frame := counter mod 6 + frame;

    txt_pack_Mob.Find('bot').Draw2D(
      Round( pos.x * TSX/TILE_SIZE - TILE_SIZE/2 ),
      Round( pos.y * TSY/TILE_SIZE - TILE_SIZE ),
      TILE_SIZE, TILE_SIZE, 0, frame );
  end;

  inherited Render;
end;

procedure TMob.Update(dt: Single);
var
  i: Integer;
  x: Single;
  y: Single;
begin
  inherited Update( dt );

  if not isDead then
  begin
    if counter mod 128 = 0 then
    begin
      x := (Random(32) + 64) * Sin( Random( 360 ) + pi/2 ) + pos.x;
      y := (Random(32) + 64) * Sin( Random( 360 ) ) + pos.y;
      TaskList.Add( Task( t_Move, TaskParam( x, y )));
    end;

    for i := 0 to enemyList.count - 1 do
      if enemyList.item[ i ] <> nil then
        if not enemyList.item[ i ].isDead then
          if Sqrt( Sqr( pos.x - enemyList.item[ i ].pos.x ) +
                   Sqr( pos.y - enemyList.item[ i ].pos.y )) <= dist_aggr * TILE_SIZE
          then
          begin
            TaskList.Free;
            Attack( enemyList.item[ i ] );

            Sound.MusicList.SetTheme( Battle );

            if enemyList.item[ i ].ClassName = 'TPlayer' then
              enemyList.item[ i ].Attack( @Self );
          end;
  end;
end;


procedure TMob.Attack(subject: PCreature);
var
  vec : TPoint2;
  l : Single;
  k : Integer;
begin
  if not isDead then
  begin
    vec.x := subject.pos.x - pos.x;
    vec.y := subject.pos.y - pos.y;
    l := Sqrt( Sqr( vec.x ) + Sqr( vec.y ) );

    dir.x := vec.x / l;
    dir.y := vec.y / l;

    if Sqrt( Sqr( pos.x - subject.pos.x ) +
             Sqr( pos.y - subject.pos.y ) ) <= dist_attack * TILE_SIZE
    then
    begin
      if counter mod 32 = 0 then
      begin
        //k := SkillStack.Add;
        //     SkillStack.Item[ k ] := skillList[ Random( Length( skillList ) ) ].Create( nil );
        //     SkillStack.Item[ k ].Init( self );
      end;
    end
    else
    begin
      trg.x := pos.x + vec.x / l * ( dist_attack );
      trg.y := pos.y + vec.y / l * ( dist_attack );
    end;
  end;
end;

procedure TMob.Death;
begin
  inherited;
end;

procedure TMob.Drop;
var
  x : Byte;
  y : Byte;
  i: Byte;
begin
  if region <> nil then
  begin
    x := Round( pos.x - region.rect.x ) div TILE_SIZE + 1;
    y := Round( pos.y - region.rect.y ) div TILE_SIZE + 1;


    case Random( 3 ) of
      0:;
      1:
      begin
        if bag.gold <> 0 then
          region.item[ x, y ] := TCoin.Create( bag.gold );
        bag.gold := 0;
      end;
      2: if bag.NotEmpty( i ) then region.item[ x, y ] := bag.item[ i ];
    end;
  end;
end;

{ TMobStack }

function TMobStack.Add: Integer;
var
  i: Integer;
  j: Integer;
  N: Boolean;
  L: Integer;
begin

  j := 0;
  N := True;
  L := Length( mob );

  for i := 0 to L - 1 do
  begin
    if mob[ i ].hp <= 0 then
    begin
      j := i;
      N := False;
      Break;
    end;
  end;

  if N then
  begin
    SetLength( mob, L + 1 );
    j := L;
  end;

  Result := j;
end;

procedure TMobStack.Free;
begin
  SetLength( mob, 0 );
end;

end.
