unit Skill.Fireball;

interface

uses
  DGLE2_types,

  Skill,
  Creature;

type

  TFireball = class ( TSkill )

    pos : TPoint2;
    ang : Single;
    vel : Single;

    mp_price : Integer;

    damage : Integer;

    constructor Create; override;

    procedure Init( Parent : TCreature ); override;
    procedure Render; override;
    procedure Update( dt : Single ); override;
  end;

implementation

uses
  System.Math,

  SubSystems,
  Resources,
  game,

  Map,
  Creature.Mob;

{ TFireball }

constructor TFireball.Create;
begin
  inherited;

  name := 'Fireball';
  mp_price := 10;
end;

procedure TFireball.Init(Parent: TCreature);
begin
  inherited;

  Self.parent := Parent;

  if Parent.mp >= mp_price then
  begin
    parent.DecMP( mp_price );

    time := 30;
    pos := Parent.pos;
    ang := parent.ang;
    vel := 20;

    damage := parent.energy * 5;
  end;
end;

procedure TFireball.Render;
var
  position : TPoint2;
begin
  inherited;

  if time > 0 then
  begin
    position.x := pos.x * TSX / TILE_SIZE;
    position.y := pos.y * TSY / TILE_SIZE;
    Render2D.DrawPoint( position, Color4($FF9B28), Round( 10 * camera.scl ) );
  end;
end;

procedure TFireball.Update(dt: Single);
var
  i : Integer;
begin
  inherited;

  if time > 0 then
  begin
    Dec( time, Round(dt) );

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
            if parent.enemyList.item[ i ].isDead then
              parent.IncXP( 25 );
          end;
  end;
end;

end.
