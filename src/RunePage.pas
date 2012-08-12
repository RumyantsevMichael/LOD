unit RunePage;

interface

uses
  Rune,
  Item,
  UI.Grid;

type

  TRunePage = record
    item : array [0..8] of TItem;
    used : Byte;

    grid : PGrid;

    procedure SetGrid( grid : PGrid );
    procedure Clear;

    procedure Render;
    procedure Update;
  end;

implementation

uses
  Input,

  Game;

{ TRunePage }

procedure TRunePage.Render;
var
  i : Byte;
  j : Byte;
  k : Byte;
  x : Integer;
  y : Integer;
  w : Integer;
  h : Integer;
begin
  if grid <> nil then
  if grid.visible then
  begin
    for j := 1 to grid.row do
    for i := 1 to grid.column do
    begin
      k := (j - 1) * grid.column + i - 1;

      x := grid.cell[ k ].x;
      y := grid.cell[ k ].y;
      w := grid.cell[ k ].w;
      h := grid.cell[ k ].h;

      if item[ k ] <> nil then
      begin
        if item[ k ].texture <> nil then
          item[ k ].texture.Draw2D( x, y, w, h );

        if grid.cell[ k ].focused then
          item[ k ].RenderInfo( mouse.state.iX, mouse.state.iY );
      end;
    end;
  end;
end;

procedure TRunePage.Update;
var
  i : Byte;
  j : Byte;
  k : Byte;
begin
  if grid <> nil then
    if grid.enabled then
      if grid.focused then
        if mouse.bLeftClick then
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
                item[ k ] := nil;
              end;
            end
            else
            begin
              if item[ k ] = nil then
                if buffer.ClassType = TRune then
                  begin
                    item[ k ] := buffer;
                    buffer := nil;
                  end;
            end;
          end;
end;


procedure TRunePage.SetGrid(grid: PGrid);
var
  i: Integer;
begin
  Self.grid := grid;

  for i := 0 to 8 do
  begin
    grid.cell[ i ].enabled := true;
  end;
end;

procedure TRunePage.Clear;
var
  i: Integer;
begin
  for i := 0 to 8 do
    item[ i ] := nil;
end;

end.
