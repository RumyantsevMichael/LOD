unit UI.Grid;

interface

uses
  DGLE2_types,

  Resources,

  UI.Component;

type

  TCell = class ( TComponent )
    img : PTexture;
    img_f : PTexture;
    img_d : PTexture;

    constructor Create;

    procedure Render; override;
    procedure Update; override;
  end;

  PGrid = ^TGrid;
  TGrid = class ( TComponent )
    cell : array of TCell;

    row : Byte;
    column : Byte;

    size : TPoint2;

    constructor Create( column, row : Byte );

    procedure Render; override;
    procedure Update; override;
  end;

implementation

uses
  DGLE2,

  SubSystems,

  Input;

{ TGrid }

constructor TGrid.Create( column, row : Byte );
var
  i: Integer;
begin
  inherited Create;

  Self.row := row;
  Self.column := column;

  SetLength( cell, row * column );

  for i := 0 to Length( cell ) - 1 do
  begin
    cell[ i ] := TCell.Create;
    cell[ i ].visible := True;
    cell[ i ].enabled := False;
  end;
end;

procedure TGrid.Render;
var
  j: Integer;
  i: Integer;
begin
  inherited;

  if visible then
  begin
    for j := 1 to row do
    for i := 1 to column do
      cell[ (j - 1) * column + i - 1 ].Render;
  end;
end;

procedure TGrid.Update;
var
  i: Integer;
  j: Integer;
  grid : TRectf;
begin
  inherited Update;

  x_real := parent.x_real + x;
  y_real := parent.y_real + y;

  for j := 1 to row do
  for i := 1 to column do
  begin
    grid.x := x_real + w / column * ( i - 1 );
    grid.y := y_real + h / row * ( j - 1 );
    grid.width := w / column;
    grid.height := h / row;

    cell[ (j - 1) * column + i - 1 ].x := Round( grid.x + grid.width / 2 - size.x / 2 );
    cell[ (j - 1) * column + i - 1 ].y := Round( grid.y + grid.height / 2 - size.y / 2 );
    cell[ (j - 1) * column + i - 1 ].w := Round( size.x );
    cell[ (j - 1) * column + i - 1 ].h := Round( size.y );

    cell[ (j - 1) * column + i - 1 ].Update;
  end;
end;

{ TCell }

constructor TCell.Create;
begin
  inherited Create;

  img := txt_pack_GUI.Find('bag');
  img_f := txt_pack_GUI.Find('bag_f');
  img_d := txt_pack_GUI.Find('bag_d');
end;

procedure TCell.Render;
begin
  inherited;

  if visible then
  begin
    if enabled then
      img.Draw2D( x, y, w, h );

    if focused then
      img_f.Draw2D( x, y, w, h );

    if not enabled then
      img_d.Draw2D( x, y, w, h );
  end;
end;

procedure TCell.Update;
begin
  inherited Update;

  x_real := x;
  y_real := y;
end;

end.
