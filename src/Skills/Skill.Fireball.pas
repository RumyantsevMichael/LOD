unit Skill.Fireball;

interface

uses
  DGLE2_types,
  DGLE2_EXT,

  Skill,
  Rune,
  Creature;

type

  TFireball = class ( TSkill )

    pos : TPoint2;
    ang : Single;
    vel : Single;

    mp_price : Integer;

    damage : Integer;

    Emitter : IParticleEmitter;

    constructor Create; override;

    procedure Init( Parent : TCreature; target : TPoint2; Rune : array of TRune ); override;
    procedure Render; override;
    procedure Update( dt : Single ); override;
  end;

implementation

uses
  System.Math,

  SubSystems,
  Resources,
  Sound,
  game,

  World,
  Creature.Mob,
  TaskList;

{ TFireball }

constructor TFireball.Create;
begin
  inherited;

  name := 'Fireball';
  mp_price := 10;
end;

procedure TFireball.Init( Parent : TCreature; target : TPoint2; Rune : array of TRune );
var
  i : Integer;
begin
  inherited;

  Self.parent := Parent;

  if Parent.mp >= mp_price then
  begin
    parent.DecMP( mp_price );

    for i := Low( rune ) to High( rune ) do
      if rune[ i ].name = 'Iwaz' then
        damage := rune[ i ].Level * 10;

    time := 30;
    pos := Parent.pos;
    ang := GetAngle( pos, target );
    vel := 20;

    //pp_Fireball.CreateEmitter( Emitter, true );
  end;
end;

procedure TFireball.Render;
var
  position : TPoint3;
  exist : Boolean;
begin
  inherited;

  if time > 0 then
  begin
    position.x := pos.x * TSX / TILE_SIZE;
    position.y := pos.y * TSY / TILE_SIZE;

    Render2D.DrawPoint
    (
      Point2( position.x, position.y ),
      Color4( $ff0000, 128 ), Round( Sqrt( camera.scl ) * 10 )
    );

    pp_Fireball.EmitterExist( Emitter, exist );

    if exist then
    begin
      Emitter.SetPosition( position, true );
      Emitter.SetScale( Sqrt( camera.scl ));
      pp_Fireball.Draw2D;
    end;
  end;
end;

procedure TFireball.Update(dt: Single);
var
  i : Integer;
  exist : Boolean;
begin
  inherited;

  Dec( time, Round(dt) );

  if time > 0 then
  begin
    pos.x := pos.x - cos(DegToRad( ang )) * vel;
    pos.y := pos.y - Sin(DegToRad( ang )) * vel;

    for i := 0 to parent.enemyList.count - 1 do
      if parent.enemyList.item[ i ] <> nil then
        if not parent.enemyList.item[ i ].isDead then
          if
            Sqrt( Sqr( pos.x -  parent.enemyList.item[i].pos.x ) +
            Sqr( pos.y -  parent.enemyList.item[i].pos.y )) <= 30
          then
          begin
            parent.enemyList.item[ i ].DecHP( damage );

            if parent.ClassName = 'TPlayer' then
            begin
              parent.enemyList.item[ i ].dist_aggr := parent.enemyList.item[ i ].dist_aggr * 2;
              parent.enemyList.item[ i ].dist_attack := parent.enemyList.item[ i ].dist_attack * 2;
            end;

            time := 0;

            if parent.enemyList.item[ i ].isDead then
            begin
              parent.IncXP( parent.enemyList.item[ i ].xp );
              parent.enemyList.item[ i ].xp := 0;
            end;
          end;
  end
  else
  begin
    pp_Fireball.EmitterExist( Emitter, exist );

    if exist then pp_Fireball.KillEmitter( Emitter );
  end;
end;

end.
