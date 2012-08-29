unit Game;

interface

uses
  DGLE2,
  DGLE2_types,

  Camera,
  World,
  Creature.Player,
  Creature.Mob,
  Item;

var
  debug : Boolean = false;

procedure Init;
procedure Render;
procedure Update( const dt : Single );

function GetMapFocusedPoint: TPoint2;

var
  counter : Integer;
  time : Byte;

  camera : TCamera;

  player : TPlayer;
  buffer : TItem;

  foc_area : PArea;
  foc_reg : PRegion;
  foc_x : Byte;
  foc_y : Byte;

implementation

uses
  System.SysUtils,
  System.Math,

  SubSystems,
  Resources,
  Settings,

  Input,
  Sound,
  Convert,
  UI,
  Creature,
  TaskList,
  Rune,
  Runeword,
  Bag,
  Skill,
  Skill.Fireball,
  Skill.Shokwave;

function GetMapFocusedPoint: TPoint2;
begin
  Result.x := ( mouse.state.ix/camera.scl + camera.pos.x - Window.Width / camera.scl/2 ) * TILE_SIZE / TSX ;
  Result.y := ( mouse.state.iy/camera.scl + camera.pos.y - Window.Height / camera.scl/2 ) * TILE_SIZE / TSY ;
end;


procedure Exit;
begin
  EngineCore.QuitEngine;
end;

procedure Init;
var
  i: Integer;
  j: Integer;
  k: Integer;
  reg : PRegion;
  tile_x : Cardinal;
  tile_y : Cardinal;
  x : Integer;
  y : Integer;
begin
  Input.Init;

  with keyboard do
  begin
    Bind( KEY_ESCAPE     , key_Down, exit );
    Bind( KEY_I          , key_Down, OpenBag );
    Bind( KEY_B          , key_Down, OpenBag );
    Bind( KEY_A          , key_Up,   OpenStat );
    Bind( KEY_C          , key_Up,   OpenStat );
    Bind( KEY_NUMPADENTER, key_Down, Calculate );
    Bind( KEY_F1         , key_Up,   OpenHUD );
    Bind( KEY_D          , key_Up,   SwitchDebug );
  end;

  camera.border := 15;
  camera.scl := 1.5;

  Map.Load('Worlds\world.lodworld');

  Rune.Init;
  Runeword.Init;

  player := TPlayer.Create;
  player.Init( 1 );
  player.Spawn( Point2( 16, 16 ), 20 );

  j := 50;
  mobStack.Free;
  for i := 1 to j do
  begin
    k := mobStack.Add;
    mobStack.mob[ k ] := TMob.Create;
    mobStack.mob[ k ].Init( 2 );

    mobStack.mob[ k ].enemyList.Add( @player );

    SetLength( mobStack.mob[ k ].skillList, 2 );
    mobStack.mob[ k ].skillList[ 0 ] := TFireball;
    mobStack.mob[ k ].skillList[ 1 ] := TShokwave;

    repeat
      x := Random( WORLD_WIDTH  * AREA_WIDTH  * 16 * TILE_SIZE );
      y := Random( WORLD_HEIGHT * AREA_HEIGHT * 16 * TILE_SIZE );

      reg := Map.GetRegion( Point2( x, y ));
      Map.GetTile( Point2( x, y ), tile_x, tile_y );
    until reg^.collision[ tile_x, tile_y ] <> 255;

    mobStack.mob[ k ].Spawn( Point2( x, y ), 500 );
  end;

  for i := 0 to Length( mobStack.mob ) - 1 do
    player.enemyList.Add( @mobStack.mob[ i ] );

  UI.Init;

  Sound.Init;
end;

procedure Render;
var
  rect: TRectf;
  Pos : TPoint2;
  i : Integer;
  j : Byte;
  x : Single;
  y : Single;
begin

  Render2d.SetCamera( camera.pos, 0, Point2( camera.scl, camera.scl ));

    Map.Render( 2 );
    Map.Render( 3 );
    Map.Render( 5 );

    Skill.Render;

  Render2D.End2D;
  Render2D.Begin2D;

  Render2d.SetCamera( camera.pos, 0, Point2( camera.scl, camera.scl ));

    player.Render;

    Pos := GetMapFocusedPoint;

    for i := 0 to Length( mobStack.mob ) - 1 do
      if not mobStack.mob[ i ].isDead then
        if
          Sqrt( Sqr( pos.x - mobStack.mob[ i ].pos.x ) +
          Sqr( pos.y - mobStack.mob[ i ].pos.y ) ) < 10
        then
        begin
          for j := 1 to 25 do
          begin
            x := ( pos.x + Cos( DegToRad( counter * 10 + j * 5 ) ) * ( Sin(counter / 10) * TSX ) ) * TSX / TILE_SIZE;
            y := ( pos.y + Sin( DegToRad( counter * 10 + j * 5 ) ) * ( Sin(counter / 10) * TSY ) ) * TSY / TILE_SIZE;
            Render2D.DrawPoint( Point2( x, y ), Color4($ffffff), Round( Sqrt( j ) * camera.scl ) );

            x := ( pos.x + Cos( DegToRad( counter * 10 + j * 5 + 180 ) ) * (Sin(counter / 10) * TSX ) ) * TSX / TILE_SIZE;
            y := ( pos.y + Sin( DegToRad( counter * 10 + j * 5 + 180 ) ) * (Sin(counter / 10) * TSY ) ) * TSY / TILE_SIZE;
            Render2D.DrawPoint( Point2( x, y ), Color4($ffffff), Round( Sqrt( j ) * camera.scl ) );
          end;
        end;

    Creature.Mob.Render;

    Map.Render( 4 );
    if debug then Map.Render( 1 );

    if debug then
    begin
      if foc_reg <> nil then
      begin
        Render2D.DrawRect( foc_reg.rect_s, Color4($9d1414) );

        rect.x := foc_x * TSX + foc_reg.rect_s.x;
        rect.y := foc_y * TSY + foc_reg.rect_s.y;
        rect.width := TSX;
        rect.height := TSY;
        Render2D.DrawRect( rect, Color4($9d1414) );

        FntPack.Find('Tahoma').Draw2D( Round(rect.x), Round(rect.y),
        StrToPAChar(IntToStr(foc_x)+', '+IntToStr(foc_y)), Color4 );
      end;
    end;

  Render2d.SetCamera( Point2( 0, 0 ), 0, Point2( 1, 1 ));

    //if foc_reg <> nil then
      //if PointInRect( GetMapFocusedPoint, foc_reg.rect ) then
        //if foc_reg.item[ foc_x + 1, foc_y + 1] <> nil then
          //foc_reg.item[ foc_x + 1, foc_y + 1 ].RenderInfo( mouse.state.iX, mouse.state.iY );

    Render2D.DrawRect( Rectf( 0, 0, Window.Width, Window.Height ), Color4( $0, time ), PF_FILL );

    UI.Render;
end;

procedure Update( const dt : Single );
var
  i: Integer;
  vec : TPoint2;
  pos : TPoint2;
  l : Single;
  j: Integer;
  Param : TTaskParam;
begin
  Inc( counter );
  time := Round(Abs(Sin(RadToDeg( counter / 1000000 ))) * 192);

  Settings.Update;
  Input.Update;
  Sound.Update;

  Map.Update( dt );

  Pos := GetMapFocusedPoint;

  Creature.Mob.Update( dt );

  for i := 0 to Length( mobStack.mob ) - 1 do
    if not mobStack.mob[ i ].isDead then
    begin
      if Sqrt( Sqr( player.pos.x - mobStack.mob[i].pos.x ) +
               Sqr( player.pos.y - mobStack.mob[i].pos.y )) < 24
      then
      begin
        vec.x := mobStack.mob[i].pos.x - player.pos.x;
        vec.y := mobStack.mob[i].pos.y - player.pos.y;

        l := Sqrt( Sqr( Vec.x ) + Sqr( Vec.y ));
        vec.x := vec.x / l * ( 24 - l );
        vec.y := vec.y / l * ( 24 - l );

        mobStack.mob[i].trg.x := mobStack.mob[i].trg.x + vec.x;
        mobStack.mob[i].trg.y := mobStack.mob[i].trg.y + vec.y;
      end;

      if not GUIfocused^ then
        if Sqrt( Sqr( pos.x - mobStack.mob[i].pos.x ) +
                 Sqr( pos.y - mobStack.mob[i].pos.y )) < 50
        then
        begin
          mouse.state.iX := Round( mobStack.mob[i].pos.x * camera.scl * TSX / TILE_SIZE - camera.pos.x * camera.scl + Window.Width / 2 );
          mouse.state.iY := Round( mobStack.mob[i].pos.y * camera.scl * TSY / TILE_SIZE - camera.pos.y * camera.scl + Window.Height / 2 );
        end;
    end;

  {$REGION ' focused region '}
    Pos := GetMapFocusedPoint;

    foc_area := nil;
    for j := 0 to WORLD_HEIGHT - 1 do
    for i := 0 to WORLD_WIDTH - 1 do
      if PointInRect( pos, Map.area[ i, j ].rect ) then
        foc_area := @Map.area[ i, j ];

    foc_reg := nil;
    if foc_area <> nil then
      for j := 0 to AREA_HEIGHT - 1 do
      for i := 0 to AREA_WIDTH - 1 do
        if PointInRect( pos, foc_area.region[ i, j ].rect ) then
        begin
          foc_reg := @foc_area.region[ i, j ];
          foc_x := Round( pos.x - foc_reg.rect.x ) div TIlE_SIZE;
          foc_y := Round( pos.y - foc_reg.rect.y ) div TIlE_SIZE;
        end;
  {$ENDREGION}

  // Player

  if not GUIfocused^ then
  begin
    if mouse.state.bLeftButton then
      if foc_reg <> nil then
        if foc_reg.item[ foc_x + 1, foc_y + 1 ] <> nil then
        begin
          player.TaskList.Add( Task( t_Move, TaskParam( pos.x, pos.y )));
          Param.x := pos.x;
          Param.y := pos.y;
          Param.item := @foc_reg.item[ foc_x + 1, foc_y + 1 ];
          player.TaskList.Add( Task( t_Take, Param ));
        end;

    if mouse.state.bRightButton then
      if player <> nil then
        if not player.isDead then
        begin
          player.TaskList.Free;
          player.TaskList.Add( Task( t_Move, TaskParam( pos.x, pos.y )));
        end;
  end;

  vec.x := GetMapFocusedPoint.x - player.pos.x;
  vec.y := GetMapFocusedPoint.y - player.pos.y;
  l := Sqrt( Sqr( vec.x ) + Sqr( vec.y ) );

  player.dir.x := vec.x / l;
  player.dir.y := vec.y / l;

  player.Update( dt );

  Runeword.Update;
  Skill.Update( dt );

  {$REGION ' camera '}
    if player <> nil then
    begin
      camera.trg.x := player.pos.x * TSX / TILE_SIZE;
      camera.trg.y := player.pos.y * TSY / TILE_SIZE;
    end;

    if mouse.state.bMiddleButton then
    begin
      TSY := TSY + mouse.state.iDeltaY div 10;
      if TSY < TSX div 2 then TSY := TSX div 2;
      if TSY > TSX then TSY := TSX;

      camera.pos.x := player.pos.x * TSX / TILE_SIZE;
      camera.pos.y := player.pos.y * TSY / TILE_SIZE;
    end;

    camera.Update;
  {$ENDREGION}

  UI.Update;

end;

end.

