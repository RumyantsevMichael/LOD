unit Skill.Shokwave;

interface

uses
  DGLE2_types,
  DGLE2_EXT,

  Skill,
  Rune,
  Creature;

type

  TShokwave = class ( TSkill )

    pos : TPoint2;
    size : Single;
    size_max : Single;
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
  DGLE2,

  SubSystems,
  Resources,

  Game,
  World,
  TaskList;

{ TShockwave }

constructor TShokwave.Create;
begin
  inherited;

  name := 'shockwave';
  mp_price := 1;
end;

procedure TShokwave.Init( Parent : TCreature; target : TPoint2; Rune : array of TRune );
var
  i : Integer;
begin
  inherited;

  Self.parent := Parent;

  if Parent.mp >= mp_price then
  begin
    parent.DecMP( mp_price );

    for i := Low( rune ) to High( rune ) do
      if rune[ i ].name = 'Sowilu' then
        size_max := ( rune[ i ].Level );

    pos := Parent.pos;

    damage := parent.energy * 1;
    size := 0;

    //pp_Shokwave.CreateEmitter( Emitter, true );
  end;
end;

procedure TShokwave.Render;
var
  position : TPoint3;
  exist : Boolean;
begin
  inherited;

  if size < size_max then
  begin
    position.x := pos.x * TSX / TILE_SIZE;
    position.y := pos.y * TSY / TILE_SIZE;

    Render2D.DrawEllipse
    (
      Point2( position.x, position.y ),
      Point2( size * TSX, size * TSY ),
      Round( size * TSX ), Color4($9d1414, 128), PF_FILL
    );

    pp_Shokwave.EmitterExist( Emitter, exist );

    if exist then
    begin
      Emitter.SetPosition( position, true );
      Emitter.SetScale( size * camera.scl );
      pp_Shokwave.Draw2D;
    end;
  end;
end;

procedure TShokwave.Update(dt: Single);
var
  i: Integer;
  exist : Boolean;
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

            if parent.ClassName = 'TPlayer' then
              parent.enemyList.item[ i ].dist_aggr := parent.enemyList.item[ i ].dist_aggr_d * 2;

            if parent.enemyList.item[ i ].isDead then
              parent.IncXP( 25 );
          end;
  end
  else
  begin
    pp_Fireball.EmitterExist( Emitter, exist );

    if exist then pp_Fireball.KillEmitter( Emitter );
  end;
end;

end.
