unit Creature.Player;

interface

uses
  DGLE2_types,

  Creature,
  Item,
  RunePage;

type

  PPlayer = ^TPlayer;
  TPlayer = class ( TCreature )

    name : string;

    RunePage : TRunePage;

    LastBattle : Integer;

    procedure Attack( subject: PCreature ); override;

    procedure Init( group : Byte );
    procedure Render;
    procedure Update( dt : Single );

    procedure Drop;  override;
    procedure Death;
  end;

implementation

uses

  System.Math,

  SubSystems,
  Resources,
  Sound,

  Input,

  Game,
  World,
  Rune,
  Item.Coin;

{ TPlayer }

procedure TPlayer.Init( group : Byte );
begin
  inherited Init( group );

  name := 'Player';

  vitality := 5;
  energy := 5;
  dexterity := 5;

  hp_max := 90 + vitality * 2;
  hp_regen := vitality / 20;

  mp_max := 90 + energy * 2;
  mp_regen := energy / 20;

  speed := 4 + dexterity / 10;

  hp := hp_max;
  mp := mp_max;

  bag.SetSize( 18 );
  bag.used := 0;

  bag.Add( MakeRune('Iwaz', 1 ));
  bag.Add( MakeRune('Sowilu', 1 ));
  bag.Add( MakeRune('Berkana', 1 ));
end;

procedure TPlayer.Render;
var
  frame : Byte;
  x : Single;
  y : Single;
  i : Byte;
begin
  if not isDead then
  begin
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

    if ( trg.x <> pos.x ) and ( trg.y <> pos.y ) then
    begin
      x := trg.x * TSX / TILE_SIZE ;
      y := trg.y * TSY / TILE_SIZE ;
      Render2D.DrawPoint( Point2( x, y ), Color4($9d1414), Round( 5 * camera.scl ) );

      for i := 1 to 25 do
      begin
        x := ( trg.x + Cos( DegToRad( counter * 10 + i * 5 ) ) * TSX/2 ) * TSX / TILE_SIZE;
        y := ( trg.y + Sin( DegToRad( counter * 10 + i * 5 ) ) * TSY/2 ) * TSY / TILE_SIZE;
        Render2D.DrawPoint( Point2( x, y ), Color4($9d1414), Round( Sqrt( i ) * camera.scl ) );

        x := ( trg.x + Cos( DegToRad( counter * 10 + i * 5 + 180 ) ) * TSX/2 ) * TSX / TILE_SIZE;
        y := ( trg.y + Sin( DegToRad( counter * 10 + i * 5 + 180 ) ) * TSY/2 ) * TSY / TILE_SIZE;
        Render2D.DrawPoint( Point2( x, y ), Color4($9d1414), Round( Sqrt( i ) * camera.scl ) );
      end;
    end;

    txt_pack_Mob.Find('player').Draw2D(
      Round( pos.x * TSX/TILE_SIZE - TILE_SIZE/2 ),
      Round( pos.y * TSY/TILE_SIZE - TILE_SIZE  ),
      TILE_SIZE, TILE_SIZE, 0, frame );

    inherited Render;
  end;
end;

procedure TPlayer.Update(dt: Single);
begin
  inherited Update( dt );

  Inc( LastBattle );
  if LastBattle >= 250 then Sound.MusicList.SetTheme( Atmosphere );

  bag.Update;
  RunePage.Update;
end;


procedure TPlayer.Attack(subject: PCreature);
begin
  inherited;

  LastBattle := 0;
end;

procedure TPlayer.Drop;
var
  x : Byte;
  y : Byte;
begin
  if region <> nil then
  begin
    x := Round( pos.x - region.rect.x ) div TILE_SIZE + 1;
    y := Round( pos.y - region.rect.y ) div TILE_SIZE + 1;


    if bag.gold <> 0 then
    begin
      region.item[ x, y ] := TCoin.Create( bag.gold );
      bag.gold := 0;
    end;
  end;
end;

procedure TPlayer.Death;
begin
  inherited;
end;

end.
