unit Skill.Shokwave;

interface

uses
  DGLE2_types,

  Skill,
  Creature;

type

  TShokwave = class ( TSkill )

    pos : TPoint2;
    size : Single;
    size_max : Single;
    mp_price : Integer;

    damage : Integer;

    constructor Create; override;

    procedure Init( Parent : TCreature ); override;
    procedure Render; override;
    procedure Update( dt : Single ); override;
  end;

implementation

uses
  DGLE2,

  SubSystems,
  Resources,

  Map,
  Creature.Mob;

{ TShockwave }

constructor TShokwave.Create;
begin
  inherited;
  name := 'shockwave';
  mp_price := 1;
end;

procedure TShokwave.Init(Parent: TCreature);
begin
  inherited;

  Self.parent := Parent;

  if Parent.mp >= mp_price then
  begin
    parent.DecMP( mp_price );

    Pos := Parent.pos;

    damage := parent.energy * 1;

    time := 100;
    size := 0;
    size_max := 5;
  end;
end;

procedure TShokwave.Render;
var
  position : TPoint2;
begin
  inherited;

  if size < size_max then
  begin
    position.x := pos.x * TSX / TILE_SIZE;
    position.y := pos.y * TSY / TILE_SIZE;

    Render2D.DrawEllipse( position, Point2( size * TSX, size * TSY ), Round(size * TSX), Color4($9d1414), PF_SMOOTH );
  end;
end;

procedure TShokwave.Update(dt: Single);
var
  i: Integer;
begin
  inherited;

  if size < size_max then
  begin
    Dec( time, Round(dt) );

    if size < size_max then size := size + 0.5;
    if size > size_max then size := size_max;

    for i := 0 to parent.enemyList.count - 1 do
      if parent.enemyList.item[ i ] <> nil then
        if not parent.enemyList.item[ i ].isDead then
          if
            Sqrt( Sqr( pos.x -  parent.enemyList.item[i].pos.x ) +
            Sqr( pos.y -  parent.enemyList.item[i].pos.y )) <= size * TILE_SIZE
          then
          begin
            parent.enemyList.item[ i ].DecHP( damage );
            if parent.enemyList.item[ i ].isDead then
              parent.IncXP( 25 );
          end;
  end;
end;

end.
