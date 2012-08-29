unit UI.Component;

interface

uses
  UI;

type

  PComponent = ^TComponent;
  TComponent = class
    name : string;

    parent : PComponent;
    child : array of PComponent;

    x : Integer;
    y : Integer;
    w : Integer;
    h : Integer;

    x_real : Integer;
    y_real : Integer;

    visible : Boolean;
    enabled : Boolean;

    focused : Boolean;

    procedure SetParent( component : PComponent );
    procedure AddChild( component : PComponent );

    procedure SetVisible( value : Boolean );
    procedure SetEnabled( value : Boolean );

    constructor Create;

    procedure Render; virtual;
    procedure Update; virtual;
  end;

  TGUIPack = record
    Item : array of TComponent;
    count : Integer;
    focused : Boolean;

    function Add: Integer;
    function Find( name : string ): PComponent;

    procedure Render;
    procedure Update;
  end;

var
  debug : Boolean = false;

implementation

uses
  DGLE2_types,

  SubSystems,
  Input;

{ TGUIPack }

function TGUIPack.Add: Integer;
begin
  SetLength( Item, count + 1 );
  Result := count;
  Inc( count );
end;

function TGUIPack.Find(name: string): PComponent;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to count - 1 do
    if Item[ i ] <> nil then
      if Item[ i ].name = name then
      begin
        Result := @Item[ i ];
        Exit;
      end;
end;

procedure TGUIPack.Render;
var
  i: Integer;
begin
  for i := 0 to count - 1 do
    if Item[ i ] <> nil then
      Item[ i ].Render;
end;

procedure TGUIPack.Update;
var
  i: Integer;
begin
  focused := False;

  for i := 0 to count - 1 do
    if Item[ i ] <> nil then
    begin
      Item[ i ].Update;

      if Item[ i ].visible then
      if Item[ i ].focused then
        focused := True;
    end;
end;

{ TComponent }

constructor TComponent.Create;
begin
  inherited Create;
end;

procedure TComponent.Render;
begin
  if visible then
    if debug then
      Render2D.DrawRect( Rectf( x_real, y_real, w, h ), Color4 );
end;

procedure TComponent.Update;
begin
  if PointInRect( Point2( mouse.state.iX, mouse.state.iY ), Rectf( x_real, y_real, w, h )) then
    focused := True
  else
    focused := False;
end;


procedure TComponent.AddChild(component: PComponent);
begin
  SetLength( child, Length( child ) + 1 );
  child[ High( child ) ] := component;
end;

procedure TComponent.SetParent(component: PComponent);
begin
  parent := component;
end;

procedure TComponent.SetVisible(value: Boolean);
var
  i: Integer;
begin
  visible := value;

  for i := 0 to Length( child ) - 1 do
    if child[ i ] <> nil then
      child[ i ].SetVisible( value );
end;

procedure TComponent.SetEnabled(value: Boolean);
var
  i: Integer;
begin
  enabled := value;

  for i := 0 to Length( child ) - 1 do
    if child[ i ] <> nil then
      child[ i ].SetEnabled( value );
end;

end.
