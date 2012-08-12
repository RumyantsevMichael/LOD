unit Bag;

interface

uses
  Item,
  UI.Grid;

type

  TBag = record
    item : array of TItem;
    count : Byte;
    used : Byte;

    grid : PGrid;

    gold : Integer;

    procedure SetGrid( grid : PGrid );

    procedure SetSize( size : Byte );

    function Add( item : TItem ): Boolean;
    function Del( index : Byte ): TItem;

    procedure Replace( index1, index2 : Byte );

    function Empty( out index : Byte ): Boolean;
    procedure Clear;

    procedure Render;
    procedure Update;
  end;

implementation

uses
  SubSystems,
  Input,

  Game,
  TaskList,
  UI,

  Item.Coin;

{ TBag }

procedure TBag.Render;
var
  i: Byte;
  j: Byte;
  x: Integer;
  y: Integer;
  w: Integer;
  h: Integer;
  k: Byte;
begin
  if grid <> nil then
  if grid.visible then
  begin
    k := 0;
    for j := 1 to grid.row do
    for i := 1 to grid.column do
    begin
      k := (j - 1) * grid.column + i - 1;

      x := grid.cell[ k ].x;
      y := grid.cell[ k ].y;
      w := grid.cell[ k ].w;
      h := grid.cell[ k ].h;

      if item[ k ] <> nil then
        if item[ k ].texture <> nil then
          item[ k ].texture.Draw2D( x, y, w, h );
    end;

    for j := 1 to grid.row do
    for i := 1 to grid.column do
      if grid.cell[ k ].focused then
        item[ k ].RenderInfo( mouse.state.iX, mouse.state.iY );
  end;
end;

procedure TBag.Update;
var
  i: Byte;
  j: Byte;
  k: Byte;
begin

  if grid <> nil then
    if grid.enabled then
      if mouse.bLeftClick then
        if GUIfocused^ then
        begin
          if grid.focused then
          for j := 1 to grid.row do
          for i := 1 to grid.column do
          begin
            k := (j - 1) * grid.column + i - 1;

            if grid.cell[ k ].focused then
            if grid.cell[ k ].enabled then
            if buffer = nil then
            begin
              if item[ k ] <> nil then
              begin
                buffer := item[ k ];
                Del( k );
              end;
            end
            else
            begin
              if item[ k ] = nil then
              begin
                item[ k ] := buffer;
                buffer := nil;
              end;
            end;
          end;
        end
        else
          if buffer <> nil then
          begin
            //map.Place(  );
            buffer := nil;
          end;

  for i := 0 to Length(item) - 1 do
    if item[ i ] <> nil then
      if item[ i ].ClassType = TCoin then
      begin
        Inc( gold, item[ i ].price );
        Del( i );
      end;
end;


function TBag.Empty( out index : Byte ): Boolean;
var
  i: Integer;
begin
  for i := 0 to count - 1 do
  if item[ i ] = nil then
  begin
    index := i;
    Result := True;
    Exit;
  end;

  Result := False;
end;

function TBag.Add( item : TItem ): Boolean;
var
  index : Byte;
begin
  Result := False;

  if used < count then
    if Empty( index ) = True then
    begin
      Self.item[ index ] := item;
      Inc( used );
      Result := True;
    end;
end;

function TBag.Del( index : Byte ): TItem;
begin
  Result := nil;
  if item[ index ] <> nil then
  begin
    Result := item[ index ];
    item[ index ] := nil;
    Dec( used );
  end;
end;

procedure TBag.Replace(index1, index2: Byte);
begin
  buffer := item[ index1 ];
            item[ index1 ] := item[ index2 ];
            item[ index2 ] := buffer;
  buffer := nil;
end;


procedure TBag.SetGrid( grid : PGrid );
var
  i: Integer;
begin
  Self.grid := grid;

  for i := 0 to count - 1 do
  begin
    grid.cell[ i ].enabled := true;
  end;
end;

procedure TBag.SetSize(size: Byte);
begin
  SetLength( item, size );
  count := size;
end;

procedure TBag.Clear;
var
  i: Byte;
begin
  for i := 0 to count - 1 do
    item[ i ] := nil;
end;

end.
