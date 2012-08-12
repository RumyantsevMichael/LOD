unit UI.Panel;

interface

uses
  UI.Component;

type

  TPanel = class ( TComponent )
    constructor Create;

    procedure Render; override;
    procedure Update; override;
  end;

implementation

uses
  DGLE2,
  DGLE2_types,

  SubSystems,
  Resources;

var
  txt_angle : PTexture;
  txt_border : PTexture;

{ TPanel }

constructor TPanel.Create;
begin
  txt_angle := txt_pack_GUI.Find('angle');
  txt_border := txt_pack_GUI.Find('border');
end;

procedure TPanel.Render;
var
  i : Integer;
begin
  inherited;

  if visible then
  begin
    txt_angle.Draw2D( x_real, y_real, 3, 3 );

    for i := x_real + 3 to x_real + w - 3 do
      txt_border.Draw2D( i, y_real, 1, 3 );

    txt_angle.Draw2D( x_real + w - 3, y_real, 3, 3, 90 );

    for i := y_real + 3 to y_real + h - 6 do
     txt_border.Draw2D( x_real + w - 3, i, 3, 3, 90 );

    txt_angle.Draw2D( x_real + w - 3, y_real + h - 3, 3, 3, 180 );

    for i := x_real + 3 to x_real + w - 3 do
      txt_border.Draw2D( i, y_real + h - 3, 1, 3, 180 );

    txt_angle.Draw2D( x_real, y_real + h - 3, 3, 3, -90 );

    for i := y_real + 3 to y_real + h - 6 do
     txt_border.Draw2D( x_real, i, 3, 3, -90 );

     Render2D.DrawRect( Rectf( x_real + 3, y_real + 3, w - 6, h - 6 ), Color4($262828), PF_FILL );
  end;
end;

procedure TPanel.Update;
begin
  inherited;

  x_real := parent.x_real + x;
  y_real := parent.y_real + y;
end;

end.
