unit Input;

interface

uses
  DGLE2_types;

type

  TAction = procedure;
  PAction = ^TAction;

  TMouse = record
      state : TMouseStates;

      pos : TPoint2;

      bLeftClick : Boolean;
      bRightClick : Boolean;
      bMiddleClick : Boolean;

      bLeftUp : Boolean;
      bRightUp : Boolean;
      bMiddleUp : Boolean;

    private
      click : array [1..3] of Integer;
      up : array [1..3] of Integer;

      procedure Update;
  end;

  TEventType = ( key_Down, key_Up, key_Press );

  TKeyboard = record

      bCapsLock	: Boolean;
      bLShift		: Boolean;
      bRShift		: Boolean;
      bLCtrl		: Boolean;
      bRCtrl		: Boolean;
      bLAlt		  : Boolean;
      bRAlt		  : Boolean;

      KeyDown    : array [1..220] of Boolean;
      KeyUp      : array [1..220] of Boolean;
      KeyPress   : array [1..220] of Boolean;

      procedure Init;

      procedure Bind  ( key : Byte; event : TEventType; action : TAction );
      procedure Unbind( key : Byte; event : TEventType );

    private
      state : TKeyboardStates;

      NewKeyDown : array [1..220] of Boolean;

      BindUp      : array [1..220] of TAction;
      BindDown    : array [1..220] of TAction;
      BindPress   : array [1..220] of TAction;

      procedure Update;
  end;

procedure Init;
procedure Update;

procedure null;

var
  mouse : TMouse;
  keyboard : TKeyboard;
  joystick : TJoystickStates;

implementation

uses
  SubSystems;

procedure null;
begin
end;

procedure Init;
var
  i: Integer;
begin
  keyboard.Init;
end;

procedure Update;
begin
  mouse.Update;
  keyboard.Update;
end;

{ TMouse }

procedure TMouse.Update;
begin
  SubSystems.Input.GetMouseStates( state );

  pos := Point2( state.iX, state.iY );

  Dec( click[1] );
  Dec( click[2] );
  Dec( click[3] );
  Dec( up[1] );
  Dec( up[2] );
  Dec( up[3] );

  if state.bLeftButton then
    click[1] := 20;

  if ( not state.bLeftButton ) and ( click[1] > 0 ) then
  begin
    bLeftClick := True;
    click[1] := 0;

    bLeftUp := True;
    up[1] := 20;
  end
  else
    bLeftClick := False;

  if state.bRightButton then
    click[2] := 20;

  if ( not state.bRightButton ) and ( click[2] > 0 ) then
  begin
    bRightClick := True;
    click[2] := 0;

    bRightUp := True;
    up[2] := 20;
  end
  else
    bRightClick := False;

  if state.bMiddleButton then
    click[3] := 20;

  if ( not state.bMiddleButton ) and ( click[3] > 0 ) then
  begin
    bMiddleClick := True;
    click[3] := 0;

    bMiddleUp := True;
    up[3] := 20;
  end
  else
    bMiddleClick := False;

  if up[1] <= 0 then bLeftUp := False;
  if up[2] <= 0 then bRightUp := False;
  if up[3] <= 0 then bMiddleUp := False;
end;

{ TKeyboard }

procedure TKeyboard.Init;
var
  key: Integer;
  event: Integer;
begin
  for key := 1 to 220 do
  begin
    NewKeyDown [ key ] := False;
    KeyPress   [ key ] := False;
    KeyDown    [ key ] := False;
    KeyUp      [ key ] := False;

    for event := 0 to 2 do Bind( key, TEventType( event ), null );
  end;
end;

procedure TKeyboard.Bind(key: Byte; event: TEventType; action: TAction);
begin
  case event of
    key_Down  : BindDown  [ key ] := action;
    key_Up    : BindUp    [ key ] := action;
    key_Press : BindPress [ key ] := action;
  end;
end;

procedure TKeyboard.Unbind(key: Byte; event: TEventType);
begin
  case event of
    key_Down  : BindDown  [ key ] := null;
    key_Up    : BindUp    [ key ] := null;
    key_Press : BindPress [ key ] := null;
  end;
end;

procedure TKeyboard.Update;
var
  Pressed : Boolean;
  key : Integer;
begin
  {$REGION ' States '}
    SubSystems.Input.GetKey( KEY_LSHIFT, Pressed );
    if Pressed then bLShift := True else bLShift := False;

    SubSystems.Input.GetKey( KEY_RSHIFT, Pressed );
    if Pressed then bRShift := True else bRShift := False;

    SubSystems.Input.GetKey( KEY_LCONTROL, Pressed );
    if Pressed then bLCtrl := True else bLCtrl := False;

    SubSystems.Input.GetKey( KEY_RCONTROL, Pressed );
    if Pressed then bRCtrl := True else bRCtrl := False;

    SubSystems.Input.GetKey( KEY_LALT, Pressed );
    if Pressed then bLAlt := True else bLAlt := False;

    SubSystems.Input.GetKey( KEY_RALT, Pressed );
    if Pressed then bRAlt := True else bRAlt := False;
  {$ENDREGION}

  for key := 1 to 220 do
  begin
    SubSystems.Input.GetKey( key, Pressed );

    if Pressed
      then NewKeyDown [ key ] := True
      else NewKeyDown [ key ] := False;

    if NewKeyDown [ key ] = True then
    begin
      if KeyPress[ key ] = True
        then KeyDown [ key ] := False
        else KeyDown [ key ] := True;

      KeyPress [ key ] := True;
      KeyUp    [ key ] := False;
    end
    else
    begin
      if KeyPress[ key ] = True
        then KeyUp [ key ] := True
        else KeyUp [ key ] := False;

      KeyDown  [ key ] := False;
      KeyPress [ key ] := False;
    end;

    if KeyPress [ key ] then BindPress [ key ];
    if KeyDown  [ key ] then BindDown  [ key ];
    if KeyUp    [ key ] then BindUp    [ key ];
  end;
end;

end.
