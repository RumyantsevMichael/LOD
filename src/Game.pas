unit Game;

interface

uses
  DGLE2,
  DGLE2_types,

  Camera,
  Map,
  Creature.Player,
  Creature.Mob,
  Item;

procedure Init;
procedure Render;
procedure Update( const dt : Single );

function GetMapFocusedPoint: TPoint2;

var
  counter : Integer;
  camera : TCamera;
  map : TMap;

  player : TPlayer;
  buffer : TItem;

  foc_reg : PRegion;
  foc_x : Byte;
  foc_y : Byte;

  plr_reg : PRegion;
  plr_x : Byte;
  plr_y : Byte;

  sndChannel : ISoundChannel;

implementation

uses
  System.SysUtils,
  System.Math,

  SubSystems,
  Resources,
  Settings,

  Input,
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
  sndChannel := nil;

  EngineCore.QuitEngine;
end;

procedure Init;
var
  i: Integer;
  j: Integer;
  k: Integer;
begin
  Input.Init;

  KeyBind[ 1 ] := Exit;
  KeyBind[ 15 ] := Init;
  KeyBind[ KEY_I ] := OpenBag;
  KeyBind[ KEY_B ] := OpenBag;
  KeyBind[ KEY_A ] := OpenStat;
  KeyBind[ KEY_C ] := OpenStat;
  KeyBind[ KEY_M ] := OpenMinimap;
  KeyBind[ KEY_F1 ] := OpenHUD;

  KeyBind[ KEY_D ] := SwitchDebug;

  camera.border := 15;
  camera.scl := 1;

  map.Generate;
  map.Load;

  Rune.Init;
  Runeword.Init;

  player := TPlayer.Create;
  player.Init( 1 );
  player.pos.x := 3000;
  player.pos.y := 2700;
  player.trg.x := 3000;
  player.trg.y := 2700;

  j := Random( 150 ) + 15;
  mobStack.Free;
  for i := 0 to j do
  begin
    k := mobStack.Add;
    mobStack.mob[ k ] := TMob.Create;
    mobStack.mob[ k ].Init( 2 );

    mobStack.mob[ k ].enemyList.Add( @player );

    SetLength( mobStack.mob[ k ].skillList, 1 );
    mobStack.mob[ k ].skillList[ 0 ] := TFireball;

    mobStack.mob[ k ].pos.x := Random( MAP_WIDTH  * 16 * 32 ) + 32;
    mobStack.mob[ k ].pos.y := Random( MAP_HEIGHT * 16 * 32 ) + 32;
    mobStack.mob[ k ].trg.x := Random( MAP_WIDTH  * 16 * 32 ) + 32;
    mobStack.mob[ k ].trg.y := Random( MAP_HEIGHT * 16 * 32 ) + 32;
  end;

  for i := 0 to Length( mobStack.mob ) - 1 do
    player.enemyList.Add( @mobStack.mob[ i ] );

  UI.Init;

  if Sound.Music then
    //snd_pack.Item[ Random( Length( snd_pack.Item ) ) ].Data.PlayEx( sndChannel, 0 );

  EngineCore.ConsoleExec('r2d_profiler 2');
  EngineCore.ConsoleExec('core_profiler 2');
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

    map.Render( 0 );
    map.Render( 1 );
    map.Render( 2 );
    map.Render( 4 );

    Skill.Render;

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

    map.Render( 3 );


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

    if plr_reg <> nil then
    begin
      Render2D.DrawRect( plr_reg.rect_s, Color4($9d1414) );

      rect.x := plr_x * TSX + plr_reg.rect_s.x;
      rect.y := plr_y * TSY + plr_reg.rect_s.y;
      rect.width := TSX;
      rect.height := TSY;
      Render2D.DrawRect( rect, Color4($9d1414) );

      FntPack.Find('Tahoma').Draw2D( Round(rect.x), Round(rect.y),
      StrToPAChar(IntToStr(plr_x)+', '+IntToStr(plr_y)), Color4 );
    end;

  Render2d.SetCamera( Point2( 0, 0 ), 0, Point2( 1, 1 ));

    //if foc_reg <> nil then
      //if PointInRect( GetMapFocusedPoint, foc_reg.rect ) then
        //if foc_reg.item[ foc_x + 1, foc_y + 1] <> nil then
          //foc_reg.item[ foc_x + 1, foc_y + 1 ].RenderInfo( mouse.state.iX, mouse.state.iY );

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

  Settings.Update;
  Input.Update;

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
        mobStack.mob[i].Say('Fuck you!');
      end;

      if Sqrt( Sqr( pos.x - mobStack.mob[i].pos.x ) +
               Sqr( pos.y - mobStack.mob[i].pos.y )) < 50
      then
      begin
        mouse.state.iX := Round( mobStack.mob[i].pos.x * camera.scl * TSX / TILE_SIZE - camera.pos.x * camera.scl + Window.Width / 2 );
        mouse.state.iY := Round( mobStack.mob[i].pos.y * camera.scl * TSY / TILE_SIZE - camera.pos.y * camera.scl + Window.Height / 2 );
      end;
    end;

  // focused region
  Pos := GetMapFocusedPoint;
  foc_reg := nil;

  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
  if PointInRect( pos, map.region[ i, j ].rect ) then
  begin
    foc_reg := @map.region[ i, j ];
    foc_x := Round( pos.x - foc_reg.rect.x ) div TILE_SIZE;
    foc_y := Round( pos.y - foc_reg.rect.y ) div TILE_SIZE;
  end;

  // Player

  if mouse.state.bLeftButton then
    if foc_reg <> nil then
      if foc_reg.item[ foc_x + 1, foc_y + 1 ] <> nil then
      begin
        player.TaskList.Add( Task( Move, TaskParam( pos.x, pos.y )));
        Param.x := pos.x;
        Param.y := pos.y;
        Param.item := @foc_reg.item[ foc_x + 1, foc_y + 1 ];
        player.TaskList.Add( Task( Take, Param ));
      end;

  if mouse.state.bRightButton then
  begin
    if Player <> nil then
    begin
      player.trg := GetMapFocusedPoint;
    end
    else
    begin
      camera.trg := GetMapFocusedPoint;
    end;
  end;

  vec.x := GetMapFocusedPoint.x - player.pos.x;
  vec.y := GetMapFocusedPoint.y - player.pos.y;
  l := Sqrt( Sqr( vec.x ) + Sqr( vec.y ) );

  player.dir.x := vec.x / l;
  player.dir.y := vec.y / l;

  player.Update( dt );

  // plr_reg

  plr_reg := nil;

  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
  if PointInRect( player.pos, map.region[ i, j ].rect ) then
  begin
    plr_reg := @map.region[ i, j ];
    plr_x := Round( player.pos.x - plr_reg.rect.x ) div TILE_SIZE;
    plr_y := Round( player.pos.y - plr_reg.rect.y ) div TILE_SIZE;
  end;

  // end

  Runeword.Update;
  Skill.Update( dt );

  // camera
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

  UI.Update;

end;

end.
