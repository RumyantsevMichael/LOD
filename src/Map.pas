unit Map;

interface

uses
  DGLE2_types,
  Item;

const

  MAP_WIDTH = 10;
  MAP_HEIGHT = 10;

type

  PRegion = ^TRegion;
  TRegion = record
    coll : array [ 1..16, 1..16 ] of Byte;
    terrain : array [ 1..16, 1..16 ] of Byte;
    decor : array [ 1..16, 1..16 ] of Byte;
    vegetation : array [ 1..16, 1..16 ] of Byte;

    item : array [1..16, 1..16] of TItem;

    x : Integer;
    y : Integer;
    rect : TRectf;
    rect_s : TRectf;

    procedure Generate( x, y : Integer );
    procedure Load( num : Integer );
    procedure Save;

    procedure Render( layer : Byte );
    procedure Update( dt : Single );
    procedure Free;
  end;

  TMap = record
    region : array[1..MAP_HEIGHT] of array[1..MAP_WIDTH] of TRegion;

    counter : Integer;

    procedure Generate;
    procedure Load;
    procedure Save;

    procedure Render( layer : Byte );
    procedure Update( dt : Single );
    procedure Free;
  end;

const
  TILE_SIZE = 32;

var
  TSX : Byte = TIlE_SIZE;
  TSY : Byte = TILE_SIZE;

implementation

uses
  System.SysUtils,
  System.Math,

  DGLE2,

  SubSystems,
  Resources,
  Settings,

  Game,
  Item.Weapon;

var
  MapNum : array of Byte;

{ TMap }

procedure TMap.Generate;
var
  i: Integer;
  j: Integer;
begin
  Free;

  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
    region[ i, j ].Generate( i-1, j-1 );
end;

procedure TMap.Load;
var
  i: Integer;
  j: Integer;
begin
  Free;

  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
    region[ i, j ].Load( ( j - 1 ) * MAP_WIDTH + i );
end;

procedure TMap.Save;
var
  i: Integer;
  j: Integer;

  MapFile : IFile;
  Data : Byte;
  result : Cardinal;
begin
  MapNum := nil;

  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
    region[ i, j ].Save;

  HDDFileSystem.OpenFile('maps\test.map', FSOF_TRUNK or FSOF_BINARY or FSOF_WRITE, MapFile );

  for i := 0 to Length( MapNum ) - 1 do
  begin
    Data := MapNum[ i ];
    MapFile.Write( @Data, SizeOf( Byte ), result );
  end;
end;

procedure TMap.Render( layer : Byte );
var
  j: Integer;
  i: Integer;
begin
  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
  begin
    if IntersectRect(
         Rectf(
           camera.pos.x - Window.Width / camera.scl / 2 - TSX,
           camera.pos.y - window.height / camera.scl / 2 - TSY,
           Window.Width / camera.scl + 2 * TSX,
           Window.Height / camera.scl + 2 * TSY ),
         region[ i, j ].rect_s )
    then
      region[ i, j ].Render( layer );
  end;
end;

procedure TMap.Update(dt: Single);
var
  i : Byte;
  j : Byte;
begin
  Inc( counter );

  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
  begin
    if IntersectRect(
         Rectf(
           camera.pos.x - Window.Width / camera.scl / 2 - TSX,
           camera.pos.y - window.height / camera.scl / 2 - TSY,
           Window.Width / camera.scl + 2 * TSX,
           Window.Height / camera.scl + 2 * TSY ),
         region[ i, j ].rect_s )
    then
      region[ i, j ].Update( dt );

    region[ i, j ].rect := Rectf(
      region[ i, j ].x * TILE_SIZE * 16,
      region[ i, j ].y * TILE_SIZE * 16,
      TILE_SIZE * 16,
      TILE_SIZE * 16 );

    region[ i, j ].rect_s := Rectf(
      region[ i, j ].rect.x * TSX / TILE_SIZE,
      region[ i, j ].rect.y * TSY / TILE_SIZE,
      region[ i, j ].rect.width * TSX / TILE_SIZE,
      region[ i, j ].rect.height * TSY / TILE_SIZE );
  end;
end;

procedure TMap.Free;
var
  i: Integer;
  j: Integer;
begin
  for j := 1 to MAP_HEIGHT do
  for i := 1 to MAP_WIDTH do
    region[ i, j ].Free;
end;

{ TRegion }

procedure TRegion.Generate( x, y : Integer );
var
  i: Integer;
  j: Integer;
begin
  Self.x := x;
  Self.y := y;
  rect := Rectf( x * TSX * 16, y * TSY * 16, TSX * 16, TSY * 16 );

  for j := 1 to 16 do
  for i := 1 to 16 do
  begin
    coll[ i, j ] := 0;
    terrain[ i, j ] := 2;
    item[ i, j ] := nil;
  end;
end;

procedure TRegion.Load( num : Integer );
var
  i : Byte;
  j : Byte;

  MapFile : IFile;
  result : Cardinal;
  Data : Byte;
begin
  HDDFileSystem.OpenFile( 'maps\test.map', FSOF_READ or FSOF_BINARY, MapFile );
  MapFile.Seek( ( num - 1 ) * 16 * 16 * 4, FSSF_BEGIN, result );

  for j := 1 to 16 do
  for i := 1 to 16 do
  begin
    MapFile.Read( @Data, SizeOf( Byte ), result );
    coll[ i, j ] := Data;

    MapFile.Read( @Data, SizeOf( Byte ), result );
    terrain[ i, j ] := Data;

    MapFile.Read( @Data, SizeOf( Byte ), result );
    decor[ i, j ] := Data;

    MapFile.Read( @Data, SizeOf( Byte ), result );
    vegetation[ i, j ] := Data;
  end;
end;

procedure TRegion.Save;
var
  i : Byte;
  j : Byte;
begin
  for j := 1 to 16 do
  for i := 1 to 16 do
  begin
    SetLength( MapNum, Length( MapNum ) + 1 );
    MapNum[ Length( MapNum ) - 1 ] := coll[ i, j ];

    SetLength( MapNum, Length( MapNum ) + 1 );
    MapNum[ Length( MapNum ) - 1 ] := terrain[ i, j ];

    SetLength( MapNum, Length( MapNum ) + 1 );
    MapNum[ Length( MapNum ) - 1 ] := decor[ i, j ];

    SetLength( MapNum, Length( MapNum ) + 1 );
    MapNum[ Length( MapNum ) - 1 ] := vegetation[ i, j ];
  end;
end;

procedure TRegion.Render(layer: Byte);
var
  i: Integer;
  j: Integer;
  w: Cardinal;
  h: Cardinal;
begin
  case layer of
    0:
    begin
      for j := 0 to 15 do
      for i := 0 to 15 do
          tp_txt[ 1 ].Find('sand').Draw2D(
            Round( rect.x * TSX/TILE_SIZE + TSX*i - TSX/4 ),
            Round( rect.y * TSY/TILE_SIZE + TSY*j - TSY/4 ),
            Round( TSX + TSX/2 ),
            Round( TSY + TSY/2 ));
    end;

    1:
    begin

      for j := 0 to 15 do
      for i := 0 to 15 do
        if terrain[ i + 1, j + 1 ] = 1 then
          tp_txt[ 1 ].Find('dirt').Draw2D(
            Round( rect.x * TSX/TILE_SIZE + TSX*i - TSX/4 ),
            Round( rect.y * TSY/TILE_SIZE + TSY*j - TSY/4 ),
            Round( TSX + TSX/2 ),
            Round( TSY + TSY/2 ));

      for j := 0 to 15 do
      for i := 0 to 15 do
        if terrain[ i + 1, j + 1 ] = 2 then
          tp_txt[ 1 ].Find('grass').Draw2D(
            Round( rect.x * TSX/TILE_SIZE + TSX*i - TSX/4 ),
            Round( rect.y * TSY/TILE_SIZE + TSY*j - TSY/4 ),
            Round( TSX + TSX/2 ),
            Round( TSY + TSY/2 ));

      for j := 0 to 15 do
      for i := 0 to 15 do
        if terrain[ i + 1, j + 1 ] = 3 then
          tp_txt[ 1 ].Find('water').Draw2D(
            Round( rect.x * TSX/TILE_SIZE + TSX*i - TSX/4 ),
            Round( rect.y * TSY/TILE_SIZE + TSY*j - TSY/4 ),
            Round( TSX + TSX/2 ),
            Round( TSY + TSY/2 ));
    end;

    2:
    begin
      for j := 0 to 15 do
      for i := 0 to 15 do
        if decor[ i + 1, j + 1 ] <> 0 then
          Render2D.DrawSpriteS(
            tp_txt[ 2 ].Find('bush_' + IntToStr( decor[ i + 1, j + 1 ] ))^,
            Point2( rect.x * TSX/TILE_SIZE + TSX * i, rect.y * TSY/TILE_SIZE + TSY * j ),
            Point2( TSX, TSY ), 0, EF_DEFAULT );
    end;

    3:
    begin
      for j := 0 to 15 do
      for i := 0 to 15 do
        if vegetation[ i + 1, j + 1 ] <> 0 then
        begin
          tp_txt[ 3 ].Find('tree_' + IntToStr( vegetation[ i + 1, j + 1 ] )).GetDimension( w, h );

          Render2D.DrawSpriteS(
            tp_txt[ 3 ].Find('tree_' + IntToStr( vegetation[ i + 1, j + 1 ] ))^,
            Point2( rect.x * TSX/TILE_SIZE + TSX * i - w div 2 + TSX div 2, rect.y * TSY/TILE_SIZE + TSY * j - h + TSY ),
            Point2( w, h ), 0, EF_DEFAULT );
        end;
    end;

    4:
    begin
      for j := 0 to 15 do
      for i := 0 to 15 do
        if item[ i + 1, j + 1 ] <> nil then
        begin
          item[ i + 1, j + 1 ].texture.Draw2D(
            Round( rect.x * TSX/TILE_SIZE + TSX*i ),
            Round( rect.y * TSY/TILE_SIZE + TSY*j ),
            TSX, TSY );
        end;
    end;
  end;
end;

procedure TRegion.Update(dt: Single);
begin

end;

procedure TRegion.Free;
var
  i: Integer;
  j: Integer;
begin
  for j := 1 to 16 do
  for i := 1 to 16 do
  begin
    terrain[ i, j ] := 0;
    decor[ i, j ] := 0;
    vegetation[ i, j ] := 0;
  end;
end;

end.
