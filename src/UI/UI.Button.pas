unit UI.Button;

interface

uses
  Resources,

  UI.Component,
  UI.Caption;

type

  TButton = class ( TComponent )
    caption : string;

    onLeftPress : procedure;
    onRightPress : procedure;
    onLeftClick : procedure;
    onRightClick : procedure;

    img   : PTexture;
    img_f : PTexture;

    constructor Create;

    procedure Render; override;
    procedure Update; override;
  end;

implementation

uses
  DGLE2_types,

  SubSystems,
  Convert,
  Input;

{ TButton }

constructor TButton.Create;
begin
  inherited Create;

  onLeftPress := null;
  onRightPress := null;
  onLeftClick := null;
  onRightClick := null;
end;

procedure TButton.Render;
begin
  inherited;

  if visible then
  begin
    img.Draw2D( x_real, y_real, w, h );

    if focused then
      img_f.Draw2D( x_real, y_real, w, h );

    DrawCaption( Rectf( x_real, y_real, w, h ), caption, Color4 );
  end;
end;

procedure TButton.Update;
begin
  inherited;

  x_real := parent.x_real + x;
  y_real := parent.y_real + y;

  if enabled then
  if focused then
  begin
    if mouse.state.bLeftButton then
      onLeftPress;

    if mouse.state.bRightButton then
      onRightPress;

    if mouse.bLeftClick then
      onLeftClick;

    if mouse.bRightClick then
      onRightClick;
  end;
end;

end.
