unit Creature;

interface

uses
  DGLE2_types,

  TaskList,
  Bag,
  Map;

type

  TSpeakStack = record
    phrase : array of string;
    count: Integer;
    time : Integer;

    pos : TPoint2;
    cur : TPoint2;

    procedure Push(text: string; pos : TPoint2);
    procedure Render;
    procedure Update( dt : Single );
  end;

  PCreature = ^TCreature;

  TEnemyList = record
    item : array of PCreature;
    count : Integer;

    procedure Add( creature : PCreature );
    procedure Del( creature : PCreature );
    procedure Free;
  end;

  TCreature = class

    pos : TPoint2;
    dir : TPoint2;
    trg : TPoint2;
    ang : Single;
    delta : TPoint2;
    speed : Single;

    hp : Single;
    hp_max : Integer;
    hp_regen : Single;

    mp : Single;
    mp_max : Integer;
    mp_regen : Single;

    xp : Integer;
    xp_max : Integer;
    level : Byte;

    sp : Integer;

    vitality : Integer;
    energy : Integer;
    dexterity : Integer;

    dist_aggr   : Single;
    dist_attack : Single;

    isDead : Boolean;

    enemyList : TEnemyList;
    TaskList : TTaskList;
    SpeakStack : TSpeakStack;

    group : Byte;
    region : PRegion;

    bag : TBag;

    counter : Integer;

    procedure IncHP( value : Single );
    procedure DecHP( value : Single );
    function  GetHP: Single;

    procedure IncMP( value : Single );
    procedure DecMP( value : Single );
    function  GetMP: Single;

    procedure IncXP( value : Integer );
    procedure DecXP( value : Integer );
    function  GetXP: Single;

    procedure IncLVL;

    procedure IncEP;
    procedure DecEP;

    procedure Attack( subject : PCreature ); virtual; abstract;

    procedure Say( text : string );

    procedure Move( param : TTaskParam; out result : Boolean );
    procedure Take( param : TTaskParam; out result : Boolean );
    procedure Drop( param : TTaskParam; out result : Boolean );

    procedure Init( group : Byte );
    procedure Render;
    procedure Update( dt : Single );

    procedure Death; virtual; abstract;
  end;



implementation

uses
  System.Math,

  DGLE2,

  SubSystems,
  Resources,

  Convert,
  Game,
  Skill,
  Skill.Shokwave,
  Skill.Fireball;

{ TCreature }

procedure TCreature.Init( group : Byte );
begin
  Self.group := group;
  counter := Random( 256 );
  SpeakStack.count := 0;

  IncXP( 1 );
end;

procedure TCreature.Render;
var
  x : Single;
  y : Single;
begin
  if not isDead then
  begin
    Render2D.LineWidth( 2 );

      x := pos.x * TSX / TILE_SIZE;
      y := pos.y * TSY / TILE_SIZE;

      Render2D.DrawEllipse( Point2( x, y ), Point2( dist_aggr * TSX, dist_aggr * TSY ), Round(dist_aggr * TSX), Color4, PF_SMOOTH );
      Render2D.DrawEllipse( Point2( x, y ), Point2( dist_attack * TSX, dist_attack * TSY ), Round(dist_attack * TSX), Color4($9d1414), PF_SMOOTH );
    Render2D.LineWidth( 1 );
  end;

  SpeakStack.Render;
end;

procedure TCreature.Update(dt: Single);
var
  vec : TPoint2;
  new : TPoint2;
  reg : PRegion;
  l : Single;
  i: Integer;
  j: Integer;
begin
  inc( counter );

  if not isDead then
  begin

    TaskList.Update( Self );

    // movement

    for i := 1 to MAP_WIDTH do
    for j := 1 to MAP_HEIGHT do
      if PointInRect( pos, game.map.region[ i, j ].rect ) then
        region := @Game.map.region[ i, j ];

    vec.x := pos.x - trg.x;
    vec.y := pos.y - trg.y;

    l := Sqrt( Sqr( vec.x ) + Sqr( vec.y ));

    if
      ( pos.x <> trg.x ) and
      ( pos.y <> trg.y )
    then
    begin
      dir.x := -vec.x / l;
      dir.y := -vec.y / l;
    end;

    ang := RadToDeg( ArcTan( dir.y / dir.x ));
    if dir.x > 0 then ang := ang - 180;

    vec.x := vec.x / l * ( l - speed );
    vec.y := vec.y / l * ( l - speed );

    new.x := trg.x + vec.x;
    new.y := trg.y + vec.y;

    delta.x := pos.x - new.x;
    delta.y := pos.y - new.y;

    // collision

    reg := nil;
    if region <> nil then
      for j := region.y - 1 to region.y + 1 do
      for i := region.x - 1 to region.x + 1 do
        if ( i >= 0 ) and ( j >= 0 ) then
          if PointInRect( new, game.map.region[ i + 1, j + 1 ].rect ) then
            reg := @Game.map.region[ i + 1, j + 1 ];

    if reg <> nil then
      for j := 0 to 15 do
      for i := 0 to 15 do
        if
          PointInRect( new,
            Rectf(
              reg.rect.x + TILE_SIZE * i, reg.rect.y + TILE_SIZE * j,
              TILE_SIZE, TILE_SIZE ))
        then
          if reg.coll[ i + 1, j + 1 ] = 0 then
          begin
            pos.x := trg.x + vec.x;
            pos.y := trg.y + vec.y;
          end
          else
          begin
            trg.x := pos.x;
            trg.y := pos.y;
            Say('Здесь не пройти');
          end;

    if Sqrt( Sqr( pos.x - trg.x ) + Sqr( pos.y - trg.y ) ) < speed then
    begin
      pos.x := trg.x;
      pos.y := trg.y;
    end;


    // regeneration

    IncHP( hp_regen );
    IncMP( mp_regen );

    // stat

    hp_max := 90 + vitality * 2;
    hp_regen := vitality / 20;

    mp_max := 90 + energy * 2;
    mp_regen := energy / 20;

    speed := 4 + dexterity / 10;
  end;

  // speak

  SpeakStack.Update( dt );

end;


procedure TCreature.IncHP(value: Single);
begin
  hp := hp + value;
  if hp > hp_max then
  begin
    hp := hp_max;
  end;
end;

procedure TCreature.DecHP(value: Single);
begin
  if not isDead then
  begin
    hp := hp - value;
    if hp <= 0 then
    begin
      hp := 0;
      Death;
    end;
  end;
end;

function TCreature.GetHP: Single;
begin
  Result := hp / hp_max;
end;


procedure TCreature.IncMP(value: Single);
begin
  mp := mp + value;
  if mp > mp_max then
  begin
    mp := mp_max;
  end;
end;

procedure TCreature.DecMP(value: Single);
begin
  mp := mp - value;
  if mp < 0 then
  begin
    mp := 0;
    Say('Магическая энергия на исходе');
  end;
end;

function TCreature.GetMP: Single;
begin
  Result := mp / mp_max;
end;


procedure TCreature.IncXP( value : Integer );
begin
  Inc( xp, value );
  if xp > xp_max then
  begin
    IncLVL;
    xp := xp - xp_max;
    xp_max := level * 100;
  end;
end;

procedure TCreature.DecXP( value : Integer );
begin
  Dec( xp, value );
  if xp < 0 then
    xp := 0;
end;

function  TCreature.GetXP: Single;
begin
  Result := xp / xp_max;
end;


procedure TCreature.IncLVL;
begin
  Inc( level );
  Inc( sp, 5 );
end;


procedure TCreature.IncEP;
begin
  if sp > 0 then
  begin
    Inc( energy );
    Dec( sp );
  end;
end;

procedure TCreature.DecEP;
begin
  if energy > 0 then
  begin
    Dec( energy );
    Inc( sp );
  end;
end;


procedure TCreature.Say(text: string);
begin
  if SpeakStack.count > 0 then
  begin
    if SpeakStack.phrase[ SpeakStack.count - 1 ] <> text then
      SpeakStack.Push( text, pos );
  end
  else SpeakStack.Push( text, pos );
end;


procedure TCreature.Move( param : TTaskParam; out result : Boolean );
begin
  trg.x := param.x;
  trg.y := param.y;
  Result := ( pos.x = trg.x ) and ( pos.y = trg.y );
end;

procedure TCreature.Take( param : TTaskParam; out result : Boolean );
begin
  if ( pos.x = param.x ) and ( pos.y = param.y ) then
    if bag.Add( param.item^ ) then
      param.item^ := nil
    else
      Say('I can`t carry more');

  Result := True;
end;

procedure TCreature.Drop( param : TTaskParam; out result : Boolean );
var
  x : Byte;
  y : Byte;
begin
  x := Round( pos.x - region.rect.x ) div TILE_SIZE + 1;
  y := Round( pos.y - region.rect.y ) div TILE_SIZE + 1;

  if region.item[ x, y ] = nil then
  begin
    region.item[ x, y ] := param.item^;
    Result := True;
  end
  else
    result := false;
end;

{ TSpeakStack }

procedure TSpeakStack.Push(text: string; pos : TPoint2);
begin
  SetLength( phrase, count + 1 );
  phrase[ count ] := text;
  Inc( count );

  self.pos := pos;
  Self.cur := pos;
end;

procedure TSpeakStack.Render;
var
  x : Single;
  y : Single;
  w : Cardinal;
  h : Cardinal;
begin
  if count > 0 then
  begin
    FntPack.Find('Tahoma').GetTextDimensions( StrToPAChar( phrase[0]), w, h );

    x := cur.x * TSX / TILE_SIZE;
    y := cur.y * TSY / TILE_SIZE;
    Render2D.DrawRect( Rectf( x - 1, y - 1, w + 2, h + 2), Color4($0), PF_FILL );
    Render2D.DrawRect( Rectf( x, y, w, h), Color4, PF_FILL );

    FntPack.Find('Tahoma').Draw2D( Round(cur.x * TSX/TILE_SIZE ), Round(cur.y * TSY/TILE_SIZE),
                 StrToPAChar( phrase[0] ), Color4($0));
  end;
end;

procedure TSpeakStack.Update( dt : Single );
var
  i: Integer;
begin
  if count > 0 then
  begin
    Dec( time, Round(dt) );

    cur.y := cur.y - Sqrt(time);

    if time <= 0 then
    begin
      time := 20;
      cur := pos;
      i := 0;

      Dec( count );
      while i < count do
      begin
        phrase[ i ] := phrase[ i + 1 ];
        Inc( i );
      end;

      SetLength( phrase, count );
    end;
  end;
end;

{ TEnemyList }

procedure TEnemyList.Add(creature: PCreature);
begin
  SetLength( item, count + 1 );
  item[ count ] := creature;
  Inc( count );
end;

procedure TEnemyList.Del(creature: PCreature);
var
  i: Integer;
  j: Integer;
begin
  for i := 0 to count - 1 do
    if item[ i ] = creature then
    begin
      j := i;
      Dec( count );

      while j < count do
      begin
        item[ j ] := item[ j + 1 ];
        Inc( j );
      end;

      SetLength( item, count );
    end;
end;

procedure TEnemyList.Free;
begin
  SetLength( item, 0 );
  count := 0;
end;

end.
